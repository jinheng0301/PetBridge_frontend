import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

/// Opens realtime connections. A seam so tests can script the server.
abstract interface class WsTransport {
  /// Opens a socket to [url] sending [headers] with the upgrade request.
  /// Throws [WsUpgradeException] when the server answers the upgrade with
  /// anything but 101.
  Future<WsConnection> connect(Uri url, Map<String, String> headers);

  /// Frees what the transport holds; open connections are not touched and
  /// [connect] must not be called afterwards.
  void close();
}

/// One open socket. When [messages] ends the connection is gone, and
/// [closeCode] says why (`null` if no close frame arrived).
abstract interface class WsConnection {
  Stream<String> get messages;
  void send(String text);
  Future<void> close([int code = 1000]);
  int? get closeCode;
}

/// The server refused the upgrade with HTTP [status].
class WsUpgradeException implements Exception {
  const new(this.status, {this.retryAfter, this.code});

  final int status;

  /// From the `Retry-After` header (seconds), when present.
  final Duration? retryAfter;

  /// `error.code` from the JSON body, when present.
  final String? code;

  @override
  String toString() => 'WsUpgradeException($status, $code)';
}

/// [WsTransport] over `dart:io`. Does the upgrade handshake by hand because
/// `WebSocket.connect` hides the status code of a refused upgrade.
class IoWsTransport implements WsTransport {
  new([HttpClient? client, Random? random])
    : _client = client ?? (HttpClient()..connectionTimeout = _connectTimeout),
      _random = random ?? Random.secure();

  static const _connectTimeout = Duration(seconds: 10);

  /// The only heartbeat: WS control-frame pings (backend TRD ch. 9).
  static const pingInterval = Duration(seconds: 25);

  final HttpClient _client;
  final Random _random;

  @override
  Future<WsConnection> connect(Uri url, Map<String, String> headers) async {
    final httpUrl = url.replace(scheme: url.scheme == 'wss' ? 'https' : 'http');
    final key = base64.encode(List.generate(16, (_) => _random.nextInt(256)));

    final request = await _client.openUrl('GET', httpUrl);
    request
      ..followRedirects = false
      ..headers.set(HttpHeaders.connectionHeader, 'Upgrade')
      ..headers.set(HttpHeaders.upgradeHeader, 'websocket')
      ..headers.set('Sec-WebSocket-Version', '13')
      ..headers.set('Sec-WebSocket-Key', key);
    headers.forEach(request.headers.set);

    // `connectionTimeout` covers only the TCP connect; a peer that accepts
    // and never answers the upgrade must not hang the handshake.
    final response = await request.close().timeout(
      _connectTimeout,
      onTimeout: () {
        request.abort(TimeoutException('WebSocket upgrade timed out'));
        throw TimeoutException('WebSocket upgrade timed out', _connectTimeout);
      },
    );
    if (response.statusCode != HttpStatus.switchingProtocols) {
      throw WsUpgradeException(
        response.statusCode,
        retryAfter: _retryAfter(response.headers.value('retry-after')),
        code: await _errorCode(response),
      );
    }

    final socket = await response.detachSocket();
    final ws = WebSocket.fromUpgradedSocket(
      socket,
      serverSide: false,
      // No permessage-deflate was offered, so none may be used.
      compression: CompressionOptions.compressionOff,
    )..pingInterval = pingInterval;
    return _IoWsConnection(ws);
  }

  @override
  void close() => _client.close();

  static Duration? _retryAfter(String? value) {
    final seconds = value == null ? null : int.tryParse(value.trim());
    return seconds == null || seconds < 0 ? null : Duration(seconds: seconds);
  }

  static Future<String?> _errorCode(HttpClientResponse response) async {
    try {
      final Object? body = jsonDecode(await utf8.decodeStream(response));
      if (body is Map<String, Object?>) {
        final error = body['error'];
        if (error is Map<String, Object?>) {
          final code = error['code'];
          if (code is String) return code;
        }
      }
    } on Object {
      // No JSON body: the status alone has to do.
    }
    return null;
  }
}

class _IoWsConnection implements WsConnection {
  new(this._ws);

  final WebSocket _ws;

  @override
  Stream<String> get messages => _ws.where((m) => m is String).cast<String>();

  @override
  void send(String text) => _ws.add(text);

  @override
  Future<void> close([int code = 1000]) => _ws.close(code);

  @override
  int? get closeCode => _ws.closeCode;
}
