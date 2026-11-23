import 'dart:convert';

/// One realtime frame: `{t, id?, seq?, d}` as JSON text (backend TRD ch. 9).
class WsFrame {
  const new(this.t, {this.id, this.seq, this.d = const {}});

  /// Event type, e.g. `room.snapshot`.
  final String t;

  /// Client-chosen frame id; the server echoes it in `error.ref`.
  final String? id;

  /// Room sequence number, only on room-wide state events.
  final int? seq;

  final Map<String, Object?> d;

  /// Parses [raw]. Throws [FormatException] when it is not a JSON object with
  /// a string `t`.
  // A static method, not a factory: the agreed interface (plan, Task 3).
  // ignore: prefer_constructors_over_static_methods
  static WsFrame decode(String raw) {
    final Object? json = jsonDecode(raw);
    if (json is! Map<String, Object?>) {
      throw const FormatException('frame is not a JSON object');
    }
    final t = json['t'];
    if (t is! String) throw const FormatException('frame has no t');
    final id = json['id'];
    final seq = json['seq'];
    final d = json['d'];
    return WsFrame(
      t,
      id: id is String ? id : null,
      seq: seq is num ? seq.toInt() : null,
      d: d is Map<String, Object?> ? d : const {},
    );
  }

  String encode() => jsonEncode({
    't': t,
    if (id != null) 'id': id,
    if (seq != null) 'seq': seq,
    'd': d,
  });
}
