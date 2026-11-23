import 'package:flutter_test/flutter_test.dart';
import 'package:petbridge/core/realtime/ws_frame.dart';

void main() {
  test('round trips t id seq d', () {
    const frame = WsFrame(
      'member.left',
      id: 'c3',
      seq: 7,
      d: {'room_id': 'r1', 'reason': 'left'},
    );

    final back = WsFrame.decode(frame.encode());

    expect(back.t, 'member.left');
    expect(back.id, 'c3');
    expect(back.seq, 7);
    expect(back.d, {'room_id': 'r1', 'reason': 'left'});

    final bare = WsFrame.decode('{"t":"resync"}');
    expect(bare.id, isNull);
    expect(bare.seq, isNull);
    expect(bare.d, isEmpty);
  });

  test('decode rejects frame without t', () {
    expect(() => WsFrame.decode('{"d":{}}'), throwsFormatException);
    expect(() => WsFrame.decode('{"t":3}'), throwsFormatException);
    expect(() => WsFrame.decode('[1]'), throwsFormatException);
    expect(() => WsFrame.decode('not json'), throwsFormatException);
  });
}
