# F2 实时小屋、宠物绘制与房主管理 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 同一间小屋的人实时看到彼此在线 / 睡觉、点宠物卖萌；小屋 Tab 换成代码绘制的场景与 16 只宠物；房主能移除成员、解散，成员能退出。

**Architecture:** 会话级 `WsClient`（`core/realtime/`）只负责连接与收发；`RealtimeCoordinator`（`features/room/application/`）管理订阅、把事件交给纯函数 reducer，结果放进每间房一份的 `roomLiveProvider(roomId)`；`roomsProvider` 仍只表示“我在哪几间房”，成员变化时重拉。宠物与背景都用 `CustomPainter` 绘制。分 F2a（Task 1–8）与 F2b（Task 9–11）。

**Tech Stack:** Flutter 3.50.0 / Dart 3.14.0、flutter_riverpod 3、go_router、dio + retrofit、`dart:io` WebSocket、gen-l10n、mocktail；dev 依赖新增 `fake_async`（已在 lock 里，作为直接 dev 依赖声明）。

**Spec:** `docs/superpowers/specs/2026-11-23-f2-realtime-room-design.md`（另见后端 TRD 7.3、第 9 章；前端 TRD 第 7、9、10、11.4、11.6 章）

## Global Constraints

- 协议以后端 TRD 第 9 章为准：帧 `{t, id?, seq?, d}`，JSON 文本帧；客户端帧 `id` 自己生成。
- 每连接最多订阅 2 间房；`pet.tap` 服务端每连接每秒 2 次；`room.sub` 每 10 秒 10 次。
- 退避 1、2、4、8、16、30 秒，加 0–30% 抖动；`ready` 持续 60 秒后重置。
- `4401` 刷新后立即重连；`4001` 与升级 `403 ONBOARDING_REQUIRED` 不重连；`1001` / `server.restart` / 升级 `503` 随机等 1–10 秒；升级 `429` 按 `Retry-After`。
- access token 剩余 < 60 秒先刷新再连；REST 与 WS 共用一个单飞刷新。
- `AppLifecycleState.paused` 立即关闭连接（1000），`resumed` 立即重连并清退避；`inactive` 不处理。
- 重连提示：非 `ready` 持续 ≥ 3 秒才显示，`paused` 期间不显示。
- 心跳只用 `pingInterval: Duration(seconds: 25)`。
- seq 缺口 < 20 缓冲最多 1 秒，否则重订；同一房间 1 秒内重订合并。`last_seq` 只在内存。
- `pet.tap` 本地节流：同一目标 500ms 一次，整条连接任意 1 秒内最多 2 次；超出只本地播放。
- 成员变化触发的 `roomsProvider.refresh()` 500ms 内合并为一次。
- 宠物：无描边，同一套 200×200 比例；姿态只有 `idle` / `sleep` / `cute`；`cute` 1.2 秒，进行中再触发从头播。
- 座位锚点（脚底中心，相对场景）：1 `(0.50, 0.88, w 0.32)`，2 `(0.21, 0.79, 0.28)`，3 `(0.79, 0.79, 0.28)`，4 `(0.33, 0.65, 0.24)`，5 `(0.67, 0.65, 0.24)`。
- 名牌只显示 👑（房主）+ 昵称（空时用宠物名），不显示语言标识。
- `kicked` / `dissolved` 提示“你已离开该小屋”，不区分原因、不显示操作者；`left` 不提示。
- 生成代码只在 `data/` 用；UI 只认 `error.code`。五语 ARB：`en`、`zh_Hans` 实现者写，`ja`、`ko`、`zh_Hant` AI 初译保持 `@@x-reviewed: false`；新 key 前缀 `room_*`、`manage_*`、`err_*`。
- 每个任务结束 `flutter analyze` 与 `flutter test` 全绿。
- **提交**：每个任务完成后先给用户审 diff，通过后再按任务提交；推送 `jinheng main`。后端仓库的文档改动不提交，交用户处理。

## Review Focus

1. **退出登录换账号**：旧连接关闭、旧房间实时状态清空、不再给旧房间发订阅 → Task 5 `session leaving ready stops client and clears live rooms`。
2. **后台很久后回来，access token 已过期**：先刷新再连，不先吃一次 401 / 4401 → Task 3 `expiring token is refreshed before connect`。
3. **退出 / 被移出时正看着那间房或在管理页**：切回自己的小屋，管理页自动返回 → Task 11 `kicked while on manage page returns to room tab`。
4. **离开房间后迟到的快照或事件**：不在列表里的房间的帧丢弃，并补发 `room.unsub` → Task 5 `frames for unlisted room are dropped`。
5. **快速连点多只宠物**：任意 1 秒内最多发 2 个 `pet.tap`，本地动画照常 → Task 5 `taps across pets are capped at two per second`。

---

## 文件结构

```
lib/
├── config/env.dart                         # + wsUrl, appVersion
├── config/error_codes.dart                 # + NOT_ROOM_OWNER, OWNER_CANNOT_LEAVE, ROOM_NOT_FOUND
├── core/network/token_refresher.dart       # 新：单飞刷新 + jwtExpiry（从 AuthInterceptor 抽出）
├── core/network/interceptors/auth_interceptor.dart   # 改用 TokenRefresher
├── core/network/dio_client.dart            # tokenRefresherProvider
├── core/realtime/{ws_frame.dart, ws_transport.dart, ws_client.dart, backoff.dart}
├── app/app.dart                            # watch realtimeCoordinatorProvider
├── app/router/{routes.dart, app_router.dart}   # + /room/:id/manage
├── features/pet/presentation/{pet_spec.dart, pet_painter.dart, pet_view.dart}
├── features/room/
│   ├── application/{room_live.dart, room_reducer.dart, realtime_coordinator.dart, room_view.dart, room_admin.dart}
│   ├── data/room_repository.dart           # + removeMember / dissolve / leave
│   └── presentation/{room_tab.dart, room_scene.dart, room_backdrop.dart, room_top_bar.dart, member_sheet.dart, room_manage_page.dart}
env/dev_android.json                        # + WS_URL
env/local.example.json                      # 新；env/local.json 已在 .gitignore
docs（两个仓库）：PRD、前端 TRD、后端 TRD 及三份变更记录
```

---

## F2a 实时与场景

### Task 1: 同步三份文档

**Files:**
- Modify（前端仓库，再原样复制到后端仓库）：`产品需求文档（PRD）：跨国 MBTI 情感 AI 电子宠物.md`、`产品需求文档（PRD）变更记录.md`、`前端技术设计文档（TRD）：PetBridge（Flutter）.md`、`前端技术设计文档（TRD）变更记录.md`、`后端技术设计文档（TRD）：PetBridge.md`、`后端技术设计文档（TRD）变更记录.md`

**Interfaces:** 无代码。内容按 spec 第 11 节，版本：PRD v1.9、前端 TRD v1.11、后端 TRD v1.13；版本表各加一行，变更记录各加一节。

- [ ] **Step 1: 改 PRD**：后续版本加入养成（吃 / 洗 / 睡 → level → 亲密度 → 解锁玩法，第二版），第二版待定项“养成的睡 vs 离线即睡觉”；F3.3 写明被点宠物的反应是卖萌、点自己的宠物只本地播放。
- [ ] **Step 2: 改前端 TRD**：3、10.2、10.3、16（Rive → `PetPainter` + `PetSpec`，MVP 姿态 idle/sleep/cute，第二版 eat/wash）；6.2（不做 `/room/:id`，保留 `/room/:id/manage`）；7（删规则 7，`roomControllerProvider` → `roomLiveProvider`，F2 只含成员与 presence）；9.2（paused 立即断开、4001 与 403 不重连、强制更新页 F6）；11.4 / 11.6（场景、⋯ 菜单、长按弹层、管理页、solo 卡片、国旗延后）；19.4（`WS_URL`、真机环境文件）；20（F2a / F2b 与验收设备）。
- [ ] **Step 3: 改后端 TRD**：18.3 演进路线加一句第二版养成功能，接口不变。
- [ ] **Step 4: 复制到后端仓库并核对** — 两边 6 个文件 `md5sum` 一致。
- [ ] **Step 5: 提交信息**（前端仓库）`docs: bump PRD to v1.9 and both TRDs for F2`

### Task 2: 配置与共用刷新

**Files:**
- Create: `lib/core/network/token_refresher.dart`、`env/local.example.json`
- Modify: `lib/config/env.dart`、`env/dev_android.json`、`lib/core/network/interceptors/auth_interceptor.dart`、`lib/core/network/dio_client.dart`、`pubspec.yaml`（dev：`fake_async`）
- Test: `test/core/network/token_refresher_test.dart`、`test/core/network/auth_interceptor_test.dart`（改构造方式，断言不变）、`test/config/env_test.dart`

**Interfaces:**
- Produces:
  - `Env.wsUrl`（`WS_URL`，默认 `ws://10.0.2.2:8090/api/v1/ws`）；`Env.appVersion`（`APP_VERSION`，默认 `1.0.0`）。
  - `DateTime? jwtExpiry(String token)`：解析 JWT payload 的 `exp`（秒），格式不对返回 `null`。
  - `class TokenRefresher { TokenRefresher({required SecureStore store, required RefreshFn refresh, required void Function() onSessionExpired}); Future<TokenPair> fresh({String? sentWithAccess}); Future<String?> validAccess(DateTime now); static bool endsSession(Object e); }` — `fresh` 是现有 `_freshTokens` + `_runRefresh` 的搬家（单飞、已被别人刷新则直接返回、拒绝时清 token 并回调一次）；`validAccess` 无 token 返回 `null`，`exp` 距 `now` < 60 秒（或解析不出 `exp` 时不刷新）则先 `fresh()`。
  - `final tokenRefresherProvider = Provider<TokenRefresher>`（用 `refreshFnProvider`、`onSessionExpiredProvider`）；`AuthInterceptor({required TokenRefresher refresher, required Dio retryDio, required SecureStore store})`。

- [ ] **Step 1: 写失败的测试**
  - `jwtExpiry reads exp`（payload `{"exp":1800000000}` → `DateTime.fromMillisecondsSinceEpoch(1800000000*1000, isUtc: true)`）；`jwtExpiry returns null for garbage`。
  - `validAccess refreshes when under 60s left`（exp = now+59s → 调一次 refresh，返回新 access）；`validAccess keeps token with 61s left`（不调 refresh）；`concurrent fresh calls share one refresh`（两次并发 → refresh 调 1 次）。
  - `env_test`：`wsUrl defaults to emulator host`。
  - 现有 `auth_interceptor_test` 全部改为经 `TokenRefresher` 构造后照样通过。
- [ ] **Step 2: 运行确认失败** — `flutter test test/core/network test/config`。
- [ ] **Step 3: 实现**。`env/dev_android.json` 加 `"WS_URL": "ws://10.0.2.2:8090/api/v1/ws"`；`env/local.example.json` 同 dev_android 但两个地址用 `192.168.x.x`（`env/local.json` 已在 `.gitignore`，不用改）。
- [ ] **Step 4: 运行确认通过** — `flutter test && flutter analyze`。
- [ ] **Step 5: 提交信息** `refactor(network): share token refresh between REST and realtime`

### Task 3: WsClient

**Files:**
- Create: `lib/core/realtime/ws_frame.dart`、`ws_transport.dart`、`backoff.dart`、`ws_client.dart`
- Test: `test/core/realtime/ws_frame_test.dart`、`backoff_test.dart`、`ws_client_test.dart`、`test/core/realtime/fake_transport.dart`

**Interfaces:**
- Consumes: `TokenRefresher`（Task 2）、`Env.wsUrl`、`Env.appVersion`。
- Produces:
  - `class WsFrame { const WsFrame(this.t, {this.id, this.seq, this.d = const {}}); final String t; final String? id; final int? seq; final Map<String, Object?> d; static WsFrame decode(String raw); String encode(); }` — `decode` 对非 JSON / 无 `t` 抛 `FormatException`。
  - `abstract interface class WsTransport { Future<WsConnection> connect(Uri url, Map<String, String> headers); }`；`abstract interface class WsConnection { Stream<String> get messages; void send(String text); Future<void> close([int code = 1000]); int? get closeCode; }`（`messages` 结束即连接断开）；`class WsUpgradeException implements Exception { const WsUpgradeException(this.status, {this.retryAfter, this.code}); final int status; final Duration? retryAfter; final String? code; }`。
  - `IoWsTransport`：用 `HttpClient` 手动握手（`Connection: Upgrade`、`Upgrade: websocket`、`Sec-WebSocket-Version: 13`、随机 `Sec-WebSocket-Key`），非 101 时读状态码、`Retry-After`、body 的 `error.code` 抛 `WsUpgradeException`；101 时 `detachSocket()` → `WebSocket.fromUpgradedSocket(socket, serverSide: false)`，`pingInterval = Duration(seconds: 25)`。（`WebSocket.connect` 拿不到状态码，所以不用它。）
  - `Duration backoffDelay(int attempt, double jitter)`：`attempt` 0..→ 1,2,4,8,16,30,30… 秒 × `(1 + jitter)`，`jitter ∈ [0, 0.3]`。
  - `enum WsConnState { disconnected, connecting, connected, ready }`
  - `class WsClient { WsClient({required WsTransport transport, required Uri url, required TokenRefresher tokens, required DateTime Function() clock, required String appVersion, Random? random}); WsConnState get state; Stream<WsConnState> get states; Stream<WsFrame> get frames; bool get halted; void start(); void pause(); void resume(); Future<void> stop(); String? send(String t, Map<String, Object?> d); }`
    - `frames` 发出除 `hello` 外的所有服务端帧（含 `server.restart`、`error`），解析失败的帧丢弃。
    - `send` 只在 `ready` 时发送并返回帧 id（`c{n}` 自增），否则返回 `null`。
    - `halted`：收到 4001、升级 403、或 `hello.proto` > 1、或 `min_app_version` 高于 `appVersion` 后为 true，不再重连，直到 `stop()` 后再 `start()`。
    - `pause()` 关闭（1000）且不重连；`resume()` 清退避立即连。

- [ ] **Step 1: 写失败的测试**（`fake_async` + `FakeTransport` 可脚本化：成功 / 抛 `WsUpgradeException` / 推帧 / 以某关闭码结束）
  - `ws_frame_test`：`round trips t id seq d`；`decode rejects frame without t`。
  - `backoff_test`：`attempt 0..6 gives 1,2,4,8,16,30,30 s without jitter`；`jitter 0.3 stretches 8s to 10.4s`。
  - `hello moves connected to ready`；`sends bearer header`；`expiring token is refreshed before connect`（Review Focus 2）；
  - `reconnects with backoff after drop`（第 1、2 次失败后分别在 1s、2s（jitter 0）重试）；`backoff resets after 60s ready`；
  - `4401 refreshes then reconnects without delay`；`4001 halts`；`upgrade 403 halts`；`upgrade 401 refreshes once then retries`；
  - `server.restart waits 1 to 10 s`（random 固定 → 期望值）；`upgrade 503 waits 1 to 10 s`；`upgrade 429 waits Retry-After`；
  - `pause closes and stays closed`；`resume reconnects at once`；`proto 2 halts`；`min_app_version above current halts`；
  - `send returns null unless ready`。
- [ ] **Step 2: 运行确认失败** — `flutter test test/core/realtime`。
- [ ] **Step 3: 实现**。`IoWsTransport` 不写单测（真机验收覆盖）。
- [ ] **Step 4: 运行确认通过** — `flutter test && flutter analyze`。
- [ ] **Step 5: 提交信息** `feat(realtime): add WebSocket client with auth, backoff and lifecycle`

### Task 4: 房间实时状态与 reducer

**Files:**
- Create: `lib/features/room/application/room_live.dart`、`room_reducer.dart`
- Test: `test/features/room/room_reducer_test.dart`

**Interfaces:**
- Consumes: `WsFrame`（Task 3）、`RoomRole`、`RoomStatus`（`room.dart`）。
- Produces:
  - `enum Presence { online, offline, unknown }`
  - `class LiveMember { const LiveMember({required String userId, String? nickname, String? petType, required int seatNo, required RoomRole role, required Presence presence}); LiveMember copyWith({Presence? presence}); }`
  - `class RoomLive { const RoomLive({required String roomId, required int lastSeq, required RoomStatus status, required int memberCount, required int capacity, required bool isOwner, required List<LiveMember> members, Map<int, WsFrame> buffered = const {}}); }`（`members` 按 `seatNo` 排序；`buffered` 存等待补缺口的带 seq 帧）
  - `sealed class RoomEffect`：`Resubscribe(String roomId)`、`StartGapTimer(String roomId)`、`MembershipChanged(String roomId)`
  - `class ReduceResult { const ReduceResult(this.state, [this.effects = const []]); final RoomLive? state; final List<RoomEffect> effects; }`
  - `ReduceResult reduceRoom(RoomLive? state, WsFrame frame)` — 只处理 `room.snapshot`、`member.joined`、`member.left`、`presence.update`；其他类型原样返回。
  - `ReduceResult gapTimedOut(RoomLive state)` → 清 `buffered`，`[Resubscribe]`。
  - 快照负载：`d.seq`、`d.room{status, member_count, capacity, is_owner, members[{user_id, nickname, pet_type, seat_no, role, presence}]}`；`member.joined`：帧级 `seq`、`d.member{…, presence}`；`member.left`：`d.user_id`；`presence.update`：`d.user_id`、`d.status`。

- [ ] **Step 1: 写失败的测试**
  - `snapshot replaces state and sets lastSeq`（旧 lastSeq 50，快照 seq 3 → 3）；
  - `event with seq <= lastSeq is dropped`；`next seq applies and advances`；
  - `gap under 20 buffers and asks for timer`（lastSeq 5，收 7 → 不应用，`[StartGapTimer]`；再收 6 → 6、7 依序应用，lastSeq 7，`buffered` 空）；
  - `gap of 20 or more resubscribes`（lastSeq 5，收 26 → `[Resubscribe]`）；`gapTimedOut resubscribes and clears buffer`；
  - `member.joined upserts by user id`（已存在 → 覆盖，人数不变）；`member.left removes or ignores`；成员事件都带 `[MembershipChanged]`；
  - `event without seq applies without touching lastSeq`（`presence.update` 与无 seq 的 `member.joined`）；
  - `events before any snapshot are ignored`（state 为 null 时非快照帧 → state 仍 null，无副作用）；
  - `unknown type is ignored`。
- [ ] **Step 2: 运行确认失败** — `flutter test test/features/room/room_reducer_test.dart`。
- [ ] **Step 3: 实现**（纯函数，不读时钟）。
- [ ] **Step 4: 运行确认通过** — `flutter test && flutter analyze`。
- [ ] **Step 5: 提交信息** `feat(room): add live room state and event reducer`

### Task 5: RealtimeCoordinator

**Files:**
- Create: `lib/features/room/application/realtime_coordinator.dart`、`room_view.dart`
- Modify: `lib/app/app.dart`（`ref.watch(realtimeCoordinatorProvider)` 保活）、`lib/features/home/presentation/home_shell.dart`（不再自己监听生命周期刷新房间——改由 coordinator 统一；背包刷新保留）
- Test: `test/features/room/realtime_coordinator_test.dart`、`test/features/room/room_view_test.dart`

**Interfaces:**
- Consumes: `WsClient`（Task 3）、`reduceRoom` / `gapTimedOut`（Task 4）、`roomsProvider`、`readyUserIdProvider`、`selectedRoomIdProvider`、`codesProvider`、`clockProvider`。
- Produces:
  - `final wsClientProvider = Provider<WsClient?>`：`readyUserIdProvider` 非空时建一个并 `start()`，`onDispose` 调 `stop()`；为空时 `null`。
  - `class PetAction { const PetAction({required String targetUserId, String? fromUserId}); }`
  - `enum KickReason { kicked, dissolved, left }`；`class KickNotice { const KickNotice(this.roomId, this.reason); }`
  - `class RealtimeCoordinator { Stream<PetAction> petActions(String roomId); Stream<KickNotice> get kicks; bool tapPet(String roomId, String targetUserId); }` — `tapPet` 总是先在 `petActions(roomId)` 发出本地动作；按 Global Constraints 节流后才 `send('pet.tap', …)`，返回是否发送。
  - `final realtimeCoordinatorProvider = Provider<RealtimeCoordinator>`（持有 `AppLifecycleListener`：`onPause` → `pause()`，`onResume` → `resume()` + `roomsProvider.refresh()`）
  - `final roomLiveProvider = NotifierProvider.family<RoomLiveNotifier, RoomLive?, String>`（只由 coordinator 写）
  - `final wsReconnectingProvider = NotifierProvider<…, bool>`：非 `ready` 持续 3 秒为 true，`ready` 或 `paused` 立即 false。
  - `class RoomView { roomId, isOwner, memberCount, capacity, List<LiveMember> members }`；`final roomViewProvider = Provider.family<RoomView?, String>`：有 `roomLiveProvider` 用它；否则用 `roomsProvider` 里的成员，`presence = unknown`。
- 行为：
  - `ready` 后对 `roomsProvider` 里全部房间发 `room.sub{room_id}`；房间集合变化时新增的 sub、消失的 `room.unsub` 并清掉其 `roomLiveProvider`。
  - 帧路由：带 `d.room_id` 且不在当前房间集合里的帧丢弃（Review Focus 4）。四种房间帧 → `reduceRoom`；处理副作用：`Resubscribe`（同房 1 秒内合并）、`StartGapTimer`（1 秒后 `gapTimedOut`）、`MembershipChanged`（`roomsProvider.refresh()`，500ms 合并）。
  - `pet.action` → `petActions(room_id)`；`room.kicked` → unsub、清该房实时状态、若 `selectedRoomIdProvider` 是该房则选自己的房间、`roomsProvider.refresh()`、发出 `KickNotice`；`code.invalidated` → `codesProvider.refresh()`；`resync` → 对 `d.room_id`（缺省全部）重订；`error{ref}` 对应 `room.sub`：`ROOM_NOT_FOUND` 同 kicked 但不发 `KickNotice`，`RATE_LIMITED` 1 秒后重订。
  - `readyUserIdProvider` 变化：所有实时状态清空（Review Focus 1）。

- [ ] **Step 1: 写失败的测试**（假 `WsClient`：可推帧、记录 `send`；`ProviderContainer` + `MockRoomRepository`）
  - `subscribes every listed room when ready`；`unsubscribes a room that left the list`；
  - `snapshot fills roomLiveProvider`；`member.joined triggers one merged rooms refresh`（500ms 内 3 条 → `listMine` 多调 1 次）；
  - `resubscribe requests within 1s are merged`；`gap timer resubscribes after 1s`；
  - `pet.action reaches petActions of its room`；`tapPet emits local action and sends pet.tap`；`same target within 500ms sends once`；`taps across pets are capped at two per second`（Review Focus 5）；
  - `room.kicked clears room, selects own room and emits notice`；`left kick emits notice with reason left`；`ROOM_NOT_FOUND on sub acts as kicked without notice`；`RATE_LIMITED on sub retries after 1s`；`resync without room_id resubscribes all`；`code.invalidated refreshes codes`；
  - `frames for unlisted room are dropped`（Review Focus 4）；`session leaving ready stops client and clears live rooms`（Review Focus 1）；
  - `reconnecting shows only after 3s`；
  - `room_view_test`：`falls back to rooms list with unknown presence`；`prefers live state once snapshot arrived`。
- [ ] **Step 2: 运行确认失败** — `flutter test test/features/room`。
- [ ] **Step 3: 实现**。
- [ ] **Step 4: 运行确认通过** — `flutter test && flutter analyze`。
- [ ] **Step 5: 提交信息** `feat(room): route realtime events into live room state`

### Task 6: 16 只代码绘制宠物

**Files:**
- Create: `lib/features/pet/presentation/pet_spec.dart`、`pet_painter.dart`
- Modify: `lib/features/pet/presentation/pet_view.dart`
- Test: `test/features/pet/pet_spec_test.dart`、`test/features/pet/pet_view_test.dart`（改写）、`test/features/pet/pet_sheet_golden_test.dart` + `test/features/pet/goldens/pet_sheet.png`

**Interfaces:**
- Produces:
  - `enum PetPose { idle, sleep, cute }`；`enum PetFamily { mammal, bird, fish }`
  - `class PetSpec { const PetSpec({required PetFamily family, required Color body, required Color light, required Color dark, required EarShape ears, required TailShape tail, MarkShape marks = MarkShape.none, TopperShape topper = TopperShape.none}); }`（`EarShape`、`TailShape`、`MarkShape`、`TopperShape` 枚举由实现者按 spec 6.2 特征表定义）
  - `const Map<String, PetSpec> petSpecs`（16 个 key 与 `pet_catalog.dart` 一致）；`PetSpec specFor(String petType)`（未知 → 灰色中性 mammal）
  - `class PetPainter extends CustomPainter { PetPainter({required PetSpec spec, required PetPose pose, required double phase, double cuteProgress = -1}); }` — 逻辑画布 200×200 缩放到 size；`phase ∈ [0,1)` 驱动呼吸 / z；`cuteProgress ∈ [0,1]` 时画卖萌（跳、歪头、爱心），否则按 `pose`。
  - `class PetView extends StatefulWidget { const PetView({required String petType, double size = 160, PetPose pose = PetPose.idle, int cuteTick = 0, bool animate = true, Key? key}); }` — `cuteTick` 变大时播放 1.2 秒卖萌后回到 `pose`；`animate: false` 画静止帧（海报用）；`TickerMode` 关闭时停。
- 视觉：无描边；腮红、眼睛高光；`sleep` 闭眼弧线 + z + 降饱和；参照 `.superpowers/brainstorm/3370-1795341157/content/pets-v1.html`。

- [ ] **Step 1: 写失败的测试**
  - `pet_spec_test`：`every catalog pet has a spec`；`unknown pet falls back`。
  - `pet_view_test`：`cuteTick plays cute then returns to pose`（pump 0.6s → painter `cuteProgress` 在 (0,1)；pump 到 1.3s → `-1`）；`retriggering cute restarts it`；`animate false paints a still frame`（无挂起的 ticker）；`sleep pose uses sleep painter`。
  - `pet_sheet_golden_test`：16 只 × 3 姿态（cute 取 progress 0.45）静态网格，无文字。
- [ ] **Step 2: 运行确认失败** — `flutter test test/features/pet`。
- [ ] **Step 3: 实现**；生成 golden：`flutter test --update-goldens test/features/pet/pet_sheet_golden_test.dart`，**发给用户看过再入库**。确认 F0 揭晓页、F1 海报（改用 `animate: false`）仍正常。
- [ ] **Step 4: 运行确认通过** — `flutter test && flutter analyze`（含海报 golden 需要时更新，同样先给用户看）。
- [ ] **Step 5: 提交信息** `feat(pet): draw the 16 pets in code with idle, sleep and cute poses`

### Task 7: 小屋场景

**Files:**
- Create: `lib/features/room/presentation/room_backdrop.dart`、`room_scene.dart`、`room_top_bar.dart`
- Modify: `lib/features/room/presentation/room_tab.dart`、`assets/l10n/app_*.arb`
- Test: `test/features/room/room_scene_test.dart`、`test/features/room/room_tab_test.dart`（改写）

**Interfaces:**
- Consumes: `roomViewProvider`、`realtimeCoordinatorProvider`（`petActions`、`tapPet`）、`wsReconnectingProvider`（Task 5）；`PetView`（Task 6）；`selectedRoomProvider`、`roomsProvider`、`roomModeProvider`、`roomTitle`（F1）。
- Produces:
  - `const Map<int, SeatAnchor> seatAnchors`（Global Constraints 的值）；`class SeatAnchor { const SeatAnchor(this.x, this.y, this.width); }`
  - `class RoomScene extends StatefulWidget { const RoomScene({required RoomView view, required String meId, required Stream<PetAction> actions, required void Function(String userId) onTapPet, void Function(String userId)? onLongPressPet, VoidCallback? onInvite}); }` — 宠物姿态：`offline` → `sleep`，其余 `idle`；收到 `actions` 中目标在场的 `PetAction` 时该座位 `cuteTick++`。
  - `class RoomTopBar extends StatelessWidget { const RoomTopBar({required String title, required int memberCount, required int capacity, required bool canSwitch, required VoidCallback onSwitch, Widget? menu}); }`（`menu` 位置 F2b 填）
- 小屋 Tab：去掉 F1 的列表与下拉刷新；场景 + 顶部栏；solo 卡片（`room_solo_card`、按钮 `room_join_button` → `/join`、`room_invite` → 背包）；重连胶囊 `room_reconnecting`；空位：自己的房间显示 `room_seat_invite`（点 → 背包），他人房间只画软垫。点击：自己 → 只本地 `cuteTick++`；他人 → `tapPet`。
- ARB：`room_solo_card`、`room_seat_invite`、`room_reconnecting`（保留 F1 仍在用的 key，删除不再用的）。

- [ ] **Step 1: 写失败的测试**
  - `pets sit at their seat anchors`（seat 4 的宠物中心约在宽 33%、脚底约在高 65%）；`offline member sleeps`；`unknown presence is idle`；
  - `tapping another pet calls tapPet`；`tapping own pet plays locally without tapPet`；`incoming action plays cute on target`；
  - `own room empty seat opens bag`（断言跳到 `/home/bag`）；`friend room empty seat has no invite`；
  - `solo shows card with join and invite`；`reconnecting pill follows provider`；
  - `nameplate shows crown and nickname, falls back to pet name`；`long nickname is ellipsized`。
- [ ] **Step 2: 运行确认失败** — `flutter test test/features/room`。
- [ ] **Step 3: 实现**，背景配色与布局参照 `room-scene-v1.html`；每只宠物外包 `RepaintBoundary`。
- [ ] **Step 4: 运行确认通过** — `flutter gen-l10n && flutter test && flutter analyze`。
- [ ] **Step 5: 提交信息** `feat(room): replace the member list with the live room scene`

### Task 8: F2a 双机验收

- [ ] **Step 1: 前置** — 后端 `.env` 设 `APP_HOST=0.0.0.0`，`task up && task migrate && task seed && task dev`；复制 `env/local.example.json` 为 `env/local.json` 并填电脑局域网 IP；模拟器 `flutter run --dart-define-from-file=env/dev_android.json`，真机 `--dart-define-from-file=env/local.json`。
- [ ] **Step 2: F1 回归** — spec 第 8 节第 2 条走一遍。
- [ ] **Step 3: 上下线 / 点宠物 / 新人加入 / 断网** — spec 第 8 节第 3–6 条。
- [ ] **Step 4: 记录结果** 给用户；有问题回到对应任务修。无代码改动不提交。

## F2b 管理与退出

### Task 9: 管理接口与错误文案

**Files:**
- Modify: `lib/features/room/data/room_repository.dart`、`lib/config/error_codes.dart`、`assets/l10n/app_*.arb`、`test/helpers/fakes.dart`
- Create: `lib/features/room/application/room_admin.dart`
- Test: `test/features/room/room_repository_test.dart`、`test/features/room/room_admin_test.dart`、`test/config/error_codes_test.dart`

**Interfaces:**
- Produces:
  - `RoomRepository` 新增：`Future<void> removeMember(String roomId, String userId)`、`Future<void> dissolve(String roomId)`、`Future<void> leave(String roomId)`（失败抛 `AppFailure`）。
  - `class RoomAdmin { Future<void> remove(String roomId, String userId); Future<void> dissolve(String roomId); Future<void> leave(String roomId); }`、`final roomAdminProvider`：成功后 `roomsProvider.refresh()`（`dissolve` 另刷 `codesProvider`；`leave` 后选自己的房间）；`ROOM_NOT_FOUND` 视为已离开：照样刷新并正常返回；其他失败原样抛出。
  - `localizedError` 新增 `NOT_ROOM_OWNER`（你不是这个小屋的房主）、`OWNER_CANNOT_LEAVE`（房主不能退出自己的小屋，可以在管理页解散）、`ROOM_NOT_FOUND`（这个小屋已经不存在了）。

- [ ] **Step 1: 写失败的测试**
  - repository：三个方法打到 `DELETE /api/v1/rooms/r1/members/u2`、`POST /api/v1/rooms/r1/dissolve`、`POST /api/v1/rooms/r1/leave`；错误转 `AppFailure`。
  - `room_admin_test`：`remove refreshes rooms`；`dissolve refreshes rooms and codes`；`leave selects own room`；`ROOM_NOT_FOUND is treated as already gone`；`OWNER_CANNOT_LEAVE is rethrown`。
  - `error_codes_test`：三个 code 不回落到 `err_UNKNOWN`。
- [ ] **Step 2: 运行确认失败** — `flutter test test/features/room test/config`。
- [ ] **Step 3: 实现**。
- [ ] **Step 4: 运行确认通过** — `flutter gen-l10n && flutter test && flutter analyze`。
- [ ] **Step 5: 提交信息** `feat(room): add remove, dissolve and leave actions`

### Task 10: 管理页、长按弹层与退出入口

**Files:**
- Create: `lib/features/room/presentation/member_sheet.dart`、`room_manage_page.dart`
- Modify: `lib/app/router/routes.dart`、`lib/app/router/app_router.dart`、`lib/features/room/presentation/room_tab.dart`、`room_top_bar.dart` 的 `menu`、`assets/l10n/app_*.arb`
- Test: `test/features/room/room_manage_page_test.dart`、`test/features/room/member_sheet_test.dart`、`test/features/room/room_tab_test.dart`、`test/app/router/routes_test.dart`

**Interfaces:**
- Consumes: `roomAdminProvider`（Task 9）、`roomViewProvider`、`RoomScene.onLongPressPet`。
- Produces:
  - `Routes.roomManage = '/room/:id/manage'`、`String Routes.roomManagePath(String id)`；`redirectFor` 在 `SessionReady` 放行 `/room/` 前缀。
  - `⋯` 菜单：自己的房间 `manage_open`（→ 管理页）；他人房间 `room_leave` → 确认框 `room_leave_confirm_title/body` → `leave`。
  - 长按他人宠物（仅自己房间）→ `MemberSheet`：标题“昵称 · 宠物名”，一项 `manage_remove` → 确认框 `manage_remove_confirm_title/body`（说明对方将无法再加入）→ `remove`。
  - 管理页：标题 `manage_title`；成员行（`PetView` 小图、昵称、房主标签，非房主行 `manage_remove`）；底部红色 `manage_dissolve`（只有自己一人时置灰）→ 确认框 `manage_dissolve_confirm_title/body`（所有成员离开、未使用验证码作废、小屋保留）→ `dissolve` → 回小屋 Tab。进入时房间不在列表或不是自己的 → 回小屋 Tab。
  - 失败：SnackBar `localizedError`；进行中按钮禁用。

- [ ] **Step 1: 写失败的测试**
  - `own room menu shows manage only`；`friend room menu shows leave only`；`leave asks to confirm then calls leave`；`cancel does nothing`；
  - `long press on member in own room opens sheet`；`long press in friend room does nothing`；`long press on self does nothing`；`remove asks to confirm then calls remove`；
  - `manage page lists members with remove except owner`；`dissolve disabled when alone`；`dissolve confirms, calls dissolve and returns to room tab`；`non-owner room redirects to room tab`；`failure shows snackbar and re-enables button`；
  - `routes_test`：`ready user may open /room/x/manage`。
- [ ] **Step 2: 运行确认失败** — `flutter test test/features/room test/app/router`。
- [ ] **Step 3: 实现**，布局参照 `room-scene-v1.html` 第 ②③ 屏。ARB：`manage_title`、`manage_open`、`manage_remove`、`manage_remove_confirm_title`、`manage_remove_confirm_body`（{name}）、`manage_dissolve`、`manage_dissolve_confirm_title`、`manage_dissolve_confirm_body`、`room_leave`、`room_leave_confirm_title`、`room_leave_confirm_body`、`common_cancel`（若已有同义 key 则复用）。
- [ ] **Step 4: 运行确认通过** — `flutter gen-l10n && flutter test && flutter analyze`。
- [ ] **Step 5: 提交信息** `feat(room): add manage page, member sheet and leave entry`

### Task 11: 被移出的提示与回退

**Files:**
- Modify: `lib/features/home/presentation/home_shell.dart`、`lib/features/room/presentation/room_manage_page.dart`、`assets/l10n/app_*.arb`
- Test: `test/features/home/home_shell_test.dart`、`test/features/room/room_manage_page_test.dart`

**Interfaces:**
- Consumes: `RealtimeCoordinator.kicks`（Task 5）。
- Produces: `HomeShell` 订阅 `kicks`：`kicked` / `dissolved` 弹 SnackBar `room_left_notice`（你已离开该小屋），`left` 不弹；管理页所看的房间从 `roomsProvider` 消失时 `context.go(Routes.home)`。

- [ ] **Step 1: 写失败的测试** — `kicked shows left notice`；`dissolved shows the same notice`；`left shows nothing`；`kicked while on manage page returns to room tab`（Review Focus 3）。
- [ ] **Step 2: 运行确认失败** — `flutter test test/features/home test/features/room`。
- [ ] **Step 3: 实现**。
- [ ] **Step 4: 运行确认通过** — `flutter gen-l10n && flutter test && flutter analyze`。
- [ ] **Step 5: 提交信息** `feat(room): tell the user when they were moved out of a room`

### Task 12: 全量验收与收尾

- [ ] **Step 1: 双机验收** — spec 第 8 节第 1–8 条全部走一遍（模拟器 A + 真机 B，必要时第三个账号 C 用模拟器切换登录）。
- [ ] **Step 2: 全量检查** — `flutter analyze && flutter test`。
- [ ] **Step 3: 文档核对** — 实现中若偏离 spec，按规则补进三份文档与变更记录，两个仓库 `md5sum` 一致（后端仓库不提交）。
- [ ] **Step 4: 提交信息** — 有文档改动：`docs: sync F2 implementation notes`；否则不提交。
