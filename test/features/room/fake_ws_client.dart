import 'dart:async';

import 'package:petbridge/core/realtime/ws_client.dart';
import 'package:petbridge/core/realtime/ws_frame.dart';

/// A [WsClient] the test drives: it moves state and pushes frames on
/// request, and records what the coordinator sends and calls.
class FakeWsClient implements WsClient {
  final _states = StreamController<WsConnState>.broadcast(sync: true);
  final _frames = StreamController<WsFrame>.broadcast(sync: true);

  /// Every frame sent while `ready`, in order.
  final sent = <WsFrame>[];
  final calls = <String>[];
  var _state = WsConnState.disconnected;
  var _lastId = 0;

  @override
  bool halted = false;

  bool get disposed => calls.contains('dispose');

  @override
  WsConnState get state => _state;

  @override
  Stream<WsConnState> get states => _states.stream;

  @override
  Stream<WsFrame> get frames => _frames.stream;

  void moveTo(WsConnState next) {
    _state = next;
    _states.add(next);
  }

  void push(String t, Map<String, Object?> d, {int? seq}) =>
      _frames.add(WsFrame(t, seq: seq, d: d));

  /// The `room_id`s of the sent frames of type [t].
  List<Object?> sentRooms(String t) => [
    for (final f in sent)
      if (f.t == t) f.d['room_id'],
  ];

  @override
  void start() => calls.add('start');

  @override
  void pause() {
    calls.add('pause');
    moveTo(WsConnState.disconnected);
  }

  @override
  void resume() => calls.add('resume');

  @override
  Future<void> stop() async {
    calls.add('stop');
    _state = WsConnState.disconnected;
  }

  @override
  Future<void> dispose() async {
    await stop();
    calls.add('dispose');
    await _states.close();
    await _frames.close();
  }

  @override
  String? send(String t, Map<String, Object?> d) {
    if (_state != WsConnState.ready) return null;
    final id = 'c${++_lastId}';
    sent.add(WsFrame(t, id: id, d: d));
    return id;
  }
}
