import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:math';

import 'package:petbridge/core/realtime/ws_frame.dart';
import 'package:petbridge/core/realtime/ws_transport.dart';

/// A JWT whose payload is [payload]; the signature is not checked anywhere.
String fakeJwt(Map<String, Object?> payload) {
  String enc(Object o) =>
      base64Url.encode(utf8.encode(jsonEncode(o))).replaceAll('=', '');
  return '${enc({'alg': 'none'})}.${enc(payload)}.sig';
}

/// A [Random] that always answers [value] (in `[0, 1)`).
class FixedRandom implements Random {
  new(this.value);

  final double value;

  @override
  double nextDouble() => value;

  @override
  int nextInt(int max) => (value * max).floor();

  @override
  bool nextBool() => value >= 0.5;
}

/// One scripted server connection.
class FakeConnection implements WsConnection {
  final _incoming = StreamController<String>();
  final sent = <String>[];

  /// The code the client closed with, `null` while it has not closed.
  int? closedWith;

  @override
  int? closeCode;

  @override
  Stream<String> get messages => _incoming.stream;

  @override
  void send(String text) => sent.add(text);

  @override
  Future<void> close([int code = 1000]) async {
    closedWith ??= code;
    _end(code);
  }

  void push(WsFrame frame) => _incoming.add(frame.encode());

  void pushRaw(String raw) => _incoming.add(raw);

  void hello({int proto = 1, String minAppVersion = '1.0.0'}) => push(
    WsFrame(
      'hello',
      d: {
        'server_time': '2026-11-23T12:00:00Z',
        'heartbeat_sec': 25,
        'proto': proto,
        'min_app_version': minAppVersion,
      },
    ),
  );

  /// The server ends the connection with [code] (`null`: no close frame).
  void drop([int? code]) => _end(code);

  void _end(int? code) {
    if (_incoming.isClosed) return;
    closeCode = code;
    unawaited(_incoming.close());
  }
}

/// Records every connect. Each connect takes the next scripted outcome from
/// [script] (a [FakeConnection] to succeed with, an [Exception] to throw, or
/// a [Completer] of [FakeConnection] to wait on); with nothing scripted it
/// succeeds with a new [FakeConnection].
class FakeTransport implements WsTransport {
  final script = Queue<Object>();
  final calls = <({Uri url, Map<String, String> headers})>[];
  final connections = <FakeConnection>[];

  FakeConnection get last => connections.last;

  /// How many times [close] was called.
  int closed = 0;

  @override
  void close() => closed++;

  @override
  Future<WsConnection> connect(Uri url, Map<String, String> headers) async {
    calls.add((url: url, headers: Map.of(headers)));
    final next = script.isEmpty ? FakeConnection() : script.removeFirst();
    if (next is Completer<FakeConnection>) {
      final conn = await next.future;
      connections.add(conn);
      return conn;
    }
    if (next is! FakeConnection) throw next as Exception;
    connections.add(next);
    return next;
  }
}
