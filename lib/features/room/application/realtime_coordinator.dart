import 'dart:async';

import 'package:flutter/widgets.dart' show AppLifecycleListener;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show NotifierProviderFamily;
import 'package:petbridge/config/env.dart';
import 'package:petbridge/core/clock.dart';
import 'package:petbridge/core/network/app_failure.dart';
import 'package:petbridge/core/network/token_refresher.dart';
import 'package:petbridge/core/realtime/ws_client.dart';
import 'package:petbridge/core/realtime/ws_frame.dart';
import 'package:petbridge/core/realtime/ws_transport.dart';
import 'package:petbridge/features/invite/application/codes_provider.dart';
import 'package:petbridge/features/room/application/room.dart';
import 'package:petbridge/features/room/application/room_live.dart';
import 'package:petbridge/features/room/application/room_reducer.dart';
import 'package:petbridge/features/room/application/rooms_provider.dart';

/// Makes the session's socket. Tests override it with a fake client.
final wsClientFactoryProvider = Provider<WsClient Function()>((ref) {
  final tokens = ref.watch(tokenRefresherProvider);
  final clock = ref.watch(clockProvider);
  return () => WsClient(
    transport: IoWsTransport(),
    url: Uri.parse(Env.wsUrl),
    tokens: tokens,
    clock: clock,
    appVersion: Env.appVersion,
  );
});

/// The realtime socket of the ready user, started at once; `null` without
/// one. A new user gets a new client; the old one is disposed, which also
/// covers a client that went idle because its session ended.
final wsClientProvider = Provider<WsClient?>((ref) {
  if (ref.watch(readyUserIdProvider) == null) return null;
  final client = ref.watch(wsClientFactoryProvider)()..start();
  ref.onDispose(() => unawaited(client.dispose()));
  return client;
});

/// A pet in a room was tapped: by someone else ([fromUserId] set, from a
/// `pet.action`), or by the user on this device ([fromUserId] `null`).
class PetAction {
  const new({required this.targetUserId, this.fromUserId});

  final String targetUserId;
  final String? fromUserId;
}

enum KickReason { kicked, dissolved, left }

/// The user is no longer in [roomId]: a `room.kicked`, or a joined room
/// gone from the list without one (removed while the app was paused).
class KickNotice {
  const new(this.roomId, this.reason);

  final String roomId;
  final KickReason reason;
}

/// Rooms the user is leaving on this device (`RoomAdmin.leave`), so their
/// going away is not reported as a [KickNotice] (own rooms never are).
/// Reset per ready user; the coordinator takes an entry out once the room
/// has gone.
final expectedDeparturesProvider = Provider<Set<String>>((ref) {
  ref.watch(readyUserIdProvider);
  return <String>{};
});

/// Live state of one room, `null` until its snapshot arrives. Written only
/// by [RealtimeCoordinator]; reset when the ready user changes.
class RoomLiveNotifier extends Notifier<RoomLive?> {
  new(this.roomId);

  final String roomId;

  @override
  RoomLive? build() {
    ref.watch(readyUserIdProvider);
    return null;
  }

  // A method, not a setter: only the coordinator calls it.
  // ignore: use_setters_to_change_properties
  void set(RoomLive? live) => state = live;
}

final NotifierProviderFamily<RoomLiveNotifier, RoomLive?, String>
roomLiveProvider = NotifierProvider.family(RoomLiveNotifier.new);

/// Whether to show "reconnecting…": the socket has not been `ready` for
/// 3 s. Never while the app is in the background or the client has halted.
/// Written only by [RealtimeCoordinator].
class WsReconnecting extends Notifier<bool> {
  @override
  bool build() {
    ref.watch(wsClientProvider);
    return false;
  }

  // A method, not a setter: only the coordinator calls it.
  // ignore: use_setters_to_change_properties
  void set(bool reconnecting) => state = reconnecting;
}

final wsReconnectingProvider = NotifierProvider<WsReconnecting, bool>(
  WsReconnecting.new,
);

/// Keeps the socket subscribed to the user's rooms and routes its frames:
/// room state through [reduceRoom] into [roomLiveProvider], pet taps to
/// [petActions], `room.kicked` to [kicks]. Also owns the app lifecycle for
/// the socket: closed on `paused`, reconnected on `resumed`.
class RealtimeCoordinator {
  new(this._ref, this._client) : _me = _ref.read(readyUserIdProvider) {
    final client = _client;
    if (client != null) {
      _subs
        ..add(client.states.listen(_onState))
        ..add(client.frames.listen(_onFrame));
      if (client.state != WsConnState.ready) _startReconnectTimer();
    }
    _ref.listen(
      roomsProvider,
      (_, next) => _onRooms(next),
      fireImmediately: true,
    );
  }

  /// The server takes at most this many subscriptions per connection.
  static const _maxRooms = 2;

  /// Resubscribes to one room are at least this far apart (frontend TRD 9.2).
  static const _resubscribeGap = Duration(seconds: 1);
  static const _gapWait = Duration(seconds: 1);
  static const _rateLimitedWait = Duration(seconds: 1);
  static const _roomsRefreshMerge = Duration(milliseconds: 500);
  static const _reconnectingAfter = Duration(seconds: 3);

  /// A tap on the same pet is sent at most once in this time…
  static const _sameTargetGap = Duration(milliseconds: 500);

  /// …and at most [_tapsPerWindow] taps go out in any [_tapWindow].
  static const _tapWindow = Duration(seconds: 1);
  static const _tapsPerWindow = 2;

  final Ref _ref;
  final WsClient? _client;
  final String? _me;
  final _subs = <StreamSubscription<Object?>>[];
  final _kicks = StreamController<KickNotice>.broadcast();
  final _petActions = <String, StreamController<PetAction>>{};

  /// The rooms to be subscribed: the listed ones, own room first.
  var _rooms = <String>[];

  /// Which of [_rooms] the user joined rather than owns.
  var _joined = <String>{};

  /// `room.sub` frame id → room, for `error.ref`.
  final _subRefs = <String, String>{};
  final _lastSubAt = <String, DateTime>{};
  final _resubTimers = <String, Timer>{};
  final _gapTimers = <String, Timer>{};

  /// Unlisted rooms already sent a `room.unsub`, so stray frames are not
  /// answered one by one.
  final _unsubscribed = <String>{};
  Timer? _roomsRefreshTimer;
  Timer? _reconnectTimer;
  bool _paused = false;

  final _lastTapAt = <String, DateTime>{};
  final _recentTaps = <DateTime>[];

  /// One-off pet actions in [roomId], for its scene to play.
  Stream<PetAction> petActions(String roomId) => _petActionsOf(roomId).stream;

  Stream<KickNotice> get kicks => _kicks.stream;

  /// Plays the tap locally at once, then sends `pet.tap` unless the target
  /// is the user's own pet, the room is not subscribed, or the throttle
  /// says no (Global Constraints). Returns whether it was sent.
  bool tapPet(String roomId, String targetUserId) {
    _petActionsOf(roomId).add(PetAction(targetUserId: targetUserId));
    final client = _client;
    if (client == null || targetUserId == _me || !_rooms.contains(roomId)) {
      return false;
    }
    final now = _now();
    final key = '$roomId/$targetUserId';
    final last = _lastTapAt[key];
    if (last != null && now.difference(last) < _sameTargetGap) return false;
    _recentTaps.removeWhere((t) => now.difference(t) >= _tapWindow);
    if (_recentTaps.length >= _tapsPerWindow) return false;
    final sent = client.send('pet.tap', {
      'room_id': roomId,
      'target_user_id': targetUserId,
    });
    if (sent == null) return false;
    _lastTapAt[key] = now;
    _recentTaps.add(now);
    return true;
  }

  DateTime _now() => _ref.read(clockProvider)();

  StreamController<PetAction> _petActionsOf(String roomId) =>
      _petActions.putIfAbsent(roomId, StreamController.broadcast);

  // --- connection ---------------------------------------------------------

  void _onState(WsConnState state) {
    if (state == WsConnState.ready) {
      _setReconnecting(false);
      _onReady();
      return;
    }
    if (_client?.halted ?? false) {
      _setReconnecting(false);
      return;
    }
    _startReconnectTimer();
  }

  /// A new connection has no subscriptions: subscribe every room afresh.
  void _onReady() {
    _subRefs.clear();
    _lastSubAt.clear();
    _unsubscribed.clear();
    for (final t in _resubTimers.values) {
      t.cancel();
    }
    _resubTimers.clear();
    _rooms.forEach(_sendSub);
  }

  void _startReconnectTimer() {
    if (_paused || _reconnectTimer != null) return;
    if (_client?.state == WsConnState.ready) return;
    _reconnectTimer = Timer(_reconnectingAfter, () {
      _reconnectTimer = null;
      if (_paused || _client?.state == WsConnState.ready) return;
      if (_client?.halted ?? false) return;
      _setReconnecting(true);
    });
  }

  void _setReconnecting(bool value) {
    if (!value) {
      _reconnectTimer?.cancel();
      _reconnectTimer = null;
    }
    _ref.read(wsReconnectingProvider.notifier).set(value);
  }

  void _onAppPaused() {
    _paused = true;
    _setReconnecting(false);
    _client?.pause();
  }

  void _onAppResumed() {
    _paused = false;
    _client?.resume();
    if (_client != null) _startReconnectTimer();
    unawaited(_quietly(_ref.read(roomsProvider.notifier).refresh));
  }

  // --- subscriptions ------------------------------------------------------

  void _onRooms(AsyncValue<List<Room>> next) {
    // Only settled lists: a reload may still carry the previous user's.
    if (next is! AsyncData<List<Room>>) return;
    final listed = next.value.take(_maxRooms).toList();
    final rooms = [for (final r in listed) r.id];
    final added = rooms.where((id) => !_rooms.contains(id)).toList();
    final removed = _rooms.where((id) => !rooms.contains(id)).toList();
    final joinedBefore = _joined;
    _rooms = rooms;
    _joined = {
      for (final r in listed)
        if (!r.isOwner) r.id,
    };
    final expected = _ref.read(expectedDeparturesProvider);
    for (final id in removed) {
      _dropRoom(id);
      // A room.kicked already took the room out of [_rooms] (and told the
      // user); one that just disappeared went while the app was paused.
      if (!expected.remove(id) && joinedBefore.contains(id)) {
        _kicks.add(KickNotice(id, KickReason.kicked));
      }
    }
    for (final id in added) {
      _unsubscribed.remove(id);
      _sendSub(id);
    }
  }

  void _sendSub(String roomId) {
    final id = _client?.send('room.sub', {'room_id': roomId});
    if (id == null) return;
    _subRefs[id] = roomId;
    _lastSubAt[roomId] = _now();
  }

  /// Subscribes again, at most once per [_resubscribeGap] for a room;
  /// requests inside the gap become one sub at its end.
  void _resubscribe(String roomId) {
    if (!_rooms.contains(roomId) || _resubTimers.containsKey(roomId)) return;
    final last = _lastSubAt[roomId];
    final wait = last == null
        ? Duration.zero
        : _resubscribeGap - _now().difference(last);
    if (wait <= Duration.zero) {
      _sendSub(roomId);
      return;
    }
    _resubTimers[roomId] = Timer(wait, () {
      _resubTimers.remove(roomId);
      if (_rooms.contains(roomId)) _sendSub(roomId);
    });
  }

  /// Stops following [roomId]: unsubscribes and forgets its live state.
  void _dropRoom(String roomId) {
    _resubTimers.remove(roomId)?.cancel();
    _gapTimers.remove(roomId)?.cancel();
    _client?.send('room.unsub', {'room_id': roomId});
    _unsubscribed.add(roomId);
    final live = roomLiveProvider(roomId);
    if (_ref.read(live.exists)) _ref.read(live.notifier).set(null);
  }

  /// The user left [roomId] (`room.kicked`, or `ROOM_NOT_FOUND` on sub).
  void _leaveRoom(String roomId, KickReason? notice) {
    _joined.remove(roomId);
    final expected = _ref.read(expectedDeparturesProvider).remove(roomId);
    if (_rooms.remove(roomId)) _dropRoom(roomId);
    if (_ref.read(selectedRoomProvider)?.id == roomId) {
      final rooms = _ref.read(roomsProvider).value ?? const <Room>[];
      final own = rooms.where((r) => r.isOwner && r.id != roomId).firstOrNull;
      if (own != null) {
        _ref.read(selectedRoomIdProvider.notifier).select(own.id);
      }
    }
    _refreshRoomsSoon();
    if (notice != null && !expected) _kicks.add(KickNotice(roomId, notice));
  }

  // --- frames -------------------------------------------------------------

  void _onFrame(WsFrame frame) {
    final d = frame.d;
    switch (frame.t) {
      case 'room.kicked':
        final roomId = d['room_id'];
        if (roomId is! String) return;
        // Not listed: nothing to leave, the list just needs catching up.
        if (!_rooms.contains(roomId)) {
          _refreshRoomsSoon();
          return;
        }
        _leaveRoom(roomId, _kickReason(d['reason']));
        return;
      case 'code.invalidated':
        unawaited(_quietly(_ref.read(codesProvider.notifier).refresh));
        return;
      case 'error':
        _onError(d);
        return;
      case 'resync':
        final roomId = d['room_id'];
        if (roomId is String) {
          _resubscribe(roomId);
        } else {
          [..._rooms].forEach(_resubscribe);
        }
        return;
    }

    final roomId = _roomIdOf(frame);
    if (roomId == null) return;
    if (!_rooms.contains(roomId)) {
      // A late frame for a room the user is no longer in (Review Focus 4).
      if (_unsubscribed.add(roomId)) {
        _client?.send('room.unsub', {'room_id': roomId});
      }
      return;
    }
    switch (frame.t) {
      case 'room.snapshot' ||
          'member.joined' ||
          'member.left' ||
          'presence.update':
        _reduce(roomId, (live) => reduceRoom(live, frame));
      case 'pet.action':
        final target = d['target_user_id'];
        if (target is! String) return;
        final from = d['from_user_id'];
        _petActionsOf(roomId).add(
          PetAction(
            targetUserId: target,
            fromUserId: from is String ? from : null,
          ),
        );
    }
  }

  void _onError(Map<String, Object?> d) {
    final ref = d['ref'];
    final roomId = ref is String ? _subRefs.remove(ref) : null;
    if (roomId == null || !_rooms.contains(roomId)) return;
    switch (d['code']) {
      case 'ROOM_NOT_FOUND':
        _leaveRoom(roomId, null);
      case 'RATE_LIMITED':
        _resubTimers[roomId]?.cancel();
        _resubTimers[roomId] = Timer(_rateLimitedWait, () {
          _resubTimers.remove(roomId);
          if (_rooms.contains(roomId)) _sendSub(roomId);
        });
    }
  }

  void _reduce(String roomId, ReduceResult Function(RoomLive? live) reducer) {
    final notifier = _ref.read(roomLiveProvider(roomId).notifier);
    final result = reducer(_ref.read(roomLiveProvider(roomId)));
    notifier.set(result.state);
    if (result.state?.buffered.isEmpty ?? true) {
      _gapTimers.remove(roomId)?.cancel();
    }
    for (final effect in result.effects) {
      switch (effect) {
        case Resubscribe():
          _resubscribe(effect.roomId);
        case StartGapTimer():
          _gapTimers[effect.roomId] ??= Timer(_gapWait, () {
            _gapTimers.remove(effect.roomId);
            _onGapTimeout(effect.roomId);
          });
        case MembershipChanged():
          _refreshRoomsSoon();
      }
    }
  }

  void _onGapTimeout(String roomId) {
    final live = _ref.read(roomLiveProvider(roomId));
    if (live == null || live.buffered.isEmpty || !_rooms.contains(roomId)) {
      return;
    }
    _reduce(roomId, (_) => gapTimedOut(live));
  }

  /// One `roomsProvider.refresh()` for every member change within 500 ms.
  void _refreshRoomsSoon() {
    _roomsRefreshTimer ??= Timer(_roomsRefreshMerge, () {
      _roomsRefreshTimer = null;
      unawaited(_quietly(_ref.read(roomsProvider.notifier).refresh));
    });
  }

  static String? _roomIdOf(WsFrame frame) {
    final id = frame.d['room_id'];
    if (id is String) return id;
    final room = frame.d['room'];
    if (frame.t == 'room.snapshot' && room is Map<String, Object?>) {
      final roomId = room['id'];
      if (roomId is String) return roomId;
    }
    return null;
  }

  static KickReason _kickReason(Object? raw) => switch (raw) {
    'left' => KickReason.left,
    'dissolved' => KickReason.dissolved,
    _ => KickReason.kicked,
  };

  /// A failed reload keeps what is shown; the next trigger tries again.
  static Future<void> _quietly(Future<void> Function() reload) async {
    try {
      await reload();
    } on AppFailure {
      // Keep what is shown.
    }
  }

  void _dispose() {
    for (final s in _subs) {
      unawaited(s.cancel());
    }
    for (final t in [..._resubTimers.values, ..._gapTimers.values]) {
      t.cancel();
    }
    _roomsRefreshTimer?.cancel();
    _reconnectTimer?.cancel();
    unawaited(_kicks.close());
    for (final c in _petActions.values) {
      unawaited(c.close());
    }
  }
}

/// The session's [RealtimeCoordinator]. `PetBridgeApp` keeps it alive.
final realtimeCoordinatorProvider = Provider<RealtimeCoordinator>((ref) {
  // A new user gets a fresh coordinator even when the client stays null.
  ref.watch(readyUserIdProvider);
  final coordinator = RealtimeCoordinator(ref, ref.watch(wsClientProvider));
  // `inactive` (e.g. the notification shade) is deliberately not handled.
  final lifecycle = AppLifecycleListener(
    onPause: coordinator._onAppPaused,
    onResume: coordinator._onAppResumed,
  );
  ref.onDispose(() {
    lifecycle.dispose();
    coordinator._dispose();
  });
  return coordinator;
});
