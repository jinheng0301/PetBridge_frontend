import 'dart:async';
import 'dart:math';

import 'package:petbridge/core/network/token_refresher.dart';
import 'package:petbridge/core/realtime/backoff.dart';
import 'package:petbridge/core/realtime/ws_frame.dart';
import 'package:petbridge/core/realtime/ws_transport.dart';

enum WsConnState { disconnected, connecting, connected, ready }

/// Why the client halted; only [displaced] is undone by [WsClient.resume].
enum _HaltReason { displaced, refused, accountDisabled }

/// The session's one realtime socket: connects with the access token,
/// reconnects with backoff, and passes server frames on. Knows nothing about
/// rooms; subscriptions are the caller's job, redone after each `ready`.
///
/// Reconnect rules (backend TRD 7.3, ch. 9):
/// - drops and failed connects back off 1, 2, 4, 8, 16, 30 s plus 0–30%
///   jitter; the backoff resets once a connection has been `ready` for 60 s;
/// - close 4401 and upgrade 401 refresh the token, then reconnect at once
///   (a second 401 in a row backs off instead);
/// - upgrade 403, `hello.proto` > 1 and `min_app_version` above ours halt:
///   no reconnect until [stop] then [start];
/// - close 4001 (displaced by the user's newer connections) halts too, but
///   [resume] (this device back in the foreground) reconnects;
/// - close 4403 (account banned or deleted) halts and ends the session the
///   way a refresh rejected with `ACCOUNT_DISABLED` does: tokens cleared,
///   `onSessionExpired` run;
/// - close 1001, a `server.restart` frame and upgrade 503 wait 1–10 s;
///   upgrade 429 waits `Retry-After`.
class WsClient {
  new({
    required this._transport,
    required this._url,
    required this._tokens,
    required this._clock,
    required this._appVersion,
    Random? random,
  }) : _random = random ?? Random();

  static const _readyResetAfter = Duration(seconds: 60);
  static const _maxJitter = 0.3;

  /// Longest wait for [WsTransport.connect], whatever the transport does.
  static const _connectTimeout = Duration(seconds: 10);
  static const _supportedProto = 1;

  final WsTransport _transport;
  final Uri _url;
  final TokenRefresher _tokens;
  final DateTime Function() _clock;
  final String _appVersion;
  final Random _random;

  final _states = StreamController<WsConnState>.broadcast();
  final _frames = StreamController<WsFrame>.broadcast();

  WsConnState _state = WsConnState.disconnected;
  bool _running = false;
  bool _paused = false;
  _HaltReason? _haltReason;
  bool _disposed = false;

  /// Bumped whenever the current connect attempt or connection is abandoned,
  /// so its late results are ignored.
  int _generation = 0;

  WsConnection? _conn;
  StreamSubscription<String>? _sub;
  String? _connAccess;
  Timer? _retryTimer;
  Timer? _readyTimer;
  int _attempts = 0;
  bool _refreshedFor401 = false;
  bool _restartAnnounced = false;
  int _lastFrameId = 0;

  WsConnState get state => _state;

  Stream<WsConnState> get states => _states.stream;

  /// Every server frame except `hello`; unparsable frames are dropped.
  Stream<WsFrame> get frames => _frames.stream;

  /// The server told us not to come back (see class doc).
  bool get halted => _haltReason != null;

  void start() {
    if (_running || _disposed) return;
    _running = true;
    _paused = false;
    _haltReason = null;
    _resetBackoff();
    unawaited(_connect());
  }

  /// Closes the socket (1000) and stays closed until [resume].
  void pause() {
    if (!_running || _isHardHalted) return;
    _paused = true;
    _drop();
  }

  /// Reconnects at once with a fresh backoff, if paused or waiting to retry,
  /// or halted by close 4001.
  void resume() {
    if (!_running || _isHardHalted) return;
    if (!_paused && _state != WsConnState.disconnected) return;
    _paused = false;
    _haltReason = null;
    _resetBackoff();
    unawaited(_connect());
  }

  Future<void> stop() async {
    _running = false;
    _paused = false;
    _haltReason = null;
    final conn = _conn;
    _drop(closeConn: false);
    await conn?.close();
  }

  /// [stop]s for good and ends [states] and [frames]; [start] does nothing
  /// afterwards.
  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    await stop();
    _transport.close();
    await Future.wait([_states.close(), _frames.close()]);
  }

  /// Sends a client frame and returns its id, or `null` when not `ready`.
  String? send(String t, Map<String, Object?> d) {
    final conn = _conn;
    if (_state != WsConnState.ready || conn == null) return null;
    final id = 'c${++_lastFrameId}';
    conn.send(WsFrame(t, id: id, d: d).encode());
    return id;
  }

  /// Connects, first refreshing the token: always when [rejected] (the
  /// access token the server just refused), otherwise only if it is about to
  /// expire.
  Future<void> _connect({String? rejected}) async {
    _retryTimer?.cancel();
    _retryTimer = null;
    final generation = ++_generation;
    _setState(WsConnState.connecting);

    final String? access;
    try {
      access = rejected == null
          ? await _tokens.validAccess(_clock())
          : (await _tokens.fresh(sentWithAccess: 'Bearer $rejected')).access;
    } on Object catch (e) {
      if (generation != _generation) return;
      if (TokenRefresher.endsSession(e)) {
        _endSession();
      } else {
        _retryIn(_backoff());
      }
      return;
    }
    if (generation != _generation) return;
    if (access == null) {
      _endSession();
      return;
    }

    final WsConnection conn;
    try {
      final pending = _transport.connect(_url, {
        'Authorization': 'Bearer $access',
      });
      conn = await pending.timeout(
        _connectTimeout,
        onTimeout: () {
          // A connection that still turns up later is closed unused.
          unawaited(pending.then((c) => c.close(), onError: (Object _) {}));
          throw TimeoutException(
            'WebSocket connect timed out',
            _connectTimeout,
          );
        },
      );
    } on WsUpgradeException catch (e) {
      if (generation == _generation) _onUpgradeRefused(e, access);
      return;
    } on Object {
      if (generation == _generation) _retryIn(_backoff());
      return;
    }
    if (generation != _generation) {
      unawaited(conn.close());
      return;
    }

    _conn = conn;
    _connAccess = access;
    _refreshedFor401 = false;
    _restartAnnounced = false;
    _setState(WsConnState.connected);
    _sub = conn.messages.listen(
      _onMessage,
      onError: (Object _) {},
      onDone: () => _onClosed(conn, generation),
    );
  }

  void _onUpgradeRefused(WsUpgradeException e, String access) {
    switch (e.status) {
      case 401 when !_refreshedFor401:
        _refreshedFor401 = true;
        unawaited(_connect(rejected: access));
      case 403:
        _halt(_HaltReason.refused);
      case 429:
        _retryIn(e.retryAfter ?? _backoff());
      case 503:
        _retryIn(_restartWait());
      default:
        _retryIn(_backoff());
    }
  }

  void _onMessage(String raw) {
    final WsFrame frame;
    try {
      frame = WsFrame.decode(raw);
    } on FormatException {
      return;
    }
    if (frame.t == 'hello') {
      _onHello(frame);
      return;
    }
    if (frame.t == 'server.restart') _restartAnnounced = true;
    if (!_frames.isClosed) _frames.add(frame);
  }

  void _onHello(WsFrame hello) {
    final proto = hello.d['proto'];
    final minVersion = hello.d['min_app_version'];
    if ((proto is num && proto > _supportedProto) ||
        (minVersion is String &&
            compareAppVersions(minVersion, _appVersion) > 0)) {
      _halt(_HaltReason.refused);
      return;
    }
    if (_state != WsConnState.connected) return;
    _setState(WsConnState.ready);
    _readyTimer = Timer(_readyResetAfter, () => _attempts = 0);
  }

  void _onClosed(WsConnection conn, int generation) {
    if (generation != _generation) return;
    final access = _connAccess;
    _sub = null;
    _conn = null;
    _connAccess = null;
    _readyTimer?.cancel();
    _readyTimer = null;

    switch (conn.closeCode) {
      case 4401:
        unawaited(_connect(rejected: access));
      case 4001:
        _halt(_HaltReason.displaced);
      case 4403:
        _halt(_HaltReason.accountDisabled);
        unawaited(_tokens.endSession());
      case 1001:
        _retryIn(_restartWait());
      case _ when _restartAnnounced:
        _retryIn(_restartWait());
      default:
        _retryIn(_backoff());
    }
  }

  void _retryIn(Duration delay) {
    _setState(WsConnState.disconnected);
    _retryTimer = Timer(delay, () => unawaited(_connect()));
  }

  Duration _backoff() =>
      backoffDelay(_attempts++, _random.nextDouble() * _maxJitter);

  /// 1–10 s, so a restarted server is not hit by everyone at once.
  Duration _restartWait() =>
      Duration(milliseconds: 1000 + (_random.nextDouble() * 9000).round());

  void _resetBackoff() {
    _attempts = 0;
    _refreshedFor401 = false;
  }

  bool get _isHardHalted =>
      _haltReason != null && _haltReason != _HaltReason.displaced;

  void _halt(_HaltReason reason) {
    _haltReason = reason;
    _drop();
  }

  /// No tokens any more (signed out or the refresh was rejected; the
  /// refresher has already reported it). Stays down until [start].
  void _endSession() {
    _running = false;
    _drop();
  }

  /// Abandons the current attempt or connection, closing it with 1000.
  void _drop({bool closeConn = true}) {
    _generation++;
    _retryTimer?.cancel();
    _retryTimer = null;
    _readyTimer?.cancel();
    _readyTimer = null;
    unawaited(_sub?.cancel());
    _sub = null;
    final conn = _conn;
    _conn = null;
    _connAccess = null;
    if (closeConn && conn != null) unawaited(conn.close());
    _setState(WsConnState.disconnected);
  }

  void _setState(WsConnState next) {
    if (next == _state) return;
    _state = next;
    if (!_states.isClosed) _states.add(next);
  }
}

/// Compares dotted numeric versions (`1.10.0` > `1.9.0`); a missing or
/// non-numeric part counts as 0 and anything after `-` or `+` is ignored.
int compareAppVersions(String a, String b) {
  List<int> parts(String v) => v
      .split(RegExp('[-+]'))
      .first
      .split('.')
      .map((p) => int.tryParse(p.trim()) ?? 0)
      .toList();
  final pa = parts(a);
  final pb = parts(b);
  for (var i = 0; i < max(pa.length, pb.length); i++) {
    final x = i < pa.length ? pa[i] : 0;
    final y = i < pb.length ? pb[i] : 0;
    if (x != y) return x.compareTo(y);
  }
  return 0;
}
