# F1 验证码入房、背包与分享海报 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 已 onboarding 的用户能用验证码住进别人的小屋，在背包里查看、生成、保存和分享自己的验证码；小屋 Tab 用成员列表直观显示 solo / inRoom。

**Architecture:** 沿用 F0 的 feature-first + Riverpod MVVM。新增 `room/`、`invite/` 两个 feature；生成代码只在各自 `data/` 里转换成领域对象（`Room`、`InviteCode`、`JoinOutcome`）。`solo` / `inRoom` 由 `roomsProvider` 派生，会话与 redirect 只多放行两个新路由。没有 WebSocket，房间与背包在固定时机刷新。

**Tech Stack:** Flutter 3.50.0 / Dart 3.14.0、flutter_riverpod 3、go_router、dio + retrofit（swagger_parser 生成）、gen-l10n、mocktail；新增 `qr_flutter`、`share_plus`、`path_provider`、`gal`。

**Spec:** `docs/superpowers/specs/2026-11-21-f1-join-backpack-design.md`（另见前端 TRD v1.10 的 6.1、6.2、11.2、11.3、11.4）

## Global Constraints

- 生成代码（`lib/gen/`）只在 feature 的 `data/` 里使用；`application/` 与 `presentation/` 只见领域对象。
- UI 只认 `error.code`，不显示服务端 `message`；客户端只做格式预校验。
- 验证码字符集 `23456789ABCDEFGHJKLMNPQRSTUVWXYZ`（32 个），校验正则 `^[2-9A-HJ-NP-Z]{8}$`，显示为 `XXXX-XXXX`；请求与链接里不带连字符。
- 页面打开时不自动读剪贴板；输错不清空输入。
- 海报逻辑尺寸 360×480，`pixelRatio: 3` 导出 1080×1440 PNG；二维码内容 `{SHARE_BASE_URL}/j/{code}`。
- `SHARE_BASE_URL` 占位值 `https://petbridge.example.com`，只经 `Env.shareBaseUrl` 读取。
- 房主管理、退出小屋、WebSocket、App Links 不在 F1 做。
- 五种语言 ARB：`en`（源）与 `zh_Hans` 由实现者写；`ja`、`ko`、`zh_Hant` AI 初译，保持 `@@x-reviewed: false`。新 key 按前缀分组：`room_*`、`join_*`、`bag_*`、`share_*`、`err_*`。
- 每个任务结束跑 `flutter analyze` 与 `flutter test` 全绿。
- **提交节奏：开始执行前由用户确定**（逐任务审核提交，或批量做完一起审核）。无论哪种，提交前都先给用户审 diff，通过后按任务、按阶段拆成多个提交，推送 `jinheng main`。后端仓库不在本计划中提交。

## Review Focus

1. **退出登录换另一个账号**：上一个账号的房间、验证码、冷却倒计时不能残留 → Task 4 `rooms cleared when session leaves ready`、Task 6 `join state cleared when session changes`、Task 8 `codes cleared when session leaves ready`。
2. **下拉刷新或回到前台时网络失败**：保留已显示的列表，只用 SnackBar 提示，不切到整页错误 → Task 4 `refresh failure keeps previous rooms`、Task 8 `refresh failure keeps previous codes`。
3. **冷却中杀掉 App 再打开**：本地倒计时丢失，再次提交时服务端返回 `CODE_COOLDOWN`，重新开始倒计时 → Task 6 `server cooldown starts countdown on a fresh controller`。
4. **从成功页“去分享”时背包列表还在刷新**：分享页要等列表加载完再判断，不能先显示“不能再分享” → Task 9 `share page waits for codes before deciding`。
5. **很长的房主昵称或长语言文案**：房间标题与分段切换省略显示，不溢出 → Task 5 `long owner nickname is ellipsized`。

---

## 文件结构

```
lib/
├── config/env.dart                                  # + shareBaseUrl
├── config/error_codes.dart                          # + 入房相关错误码
├── core/network/interceptors/error_map_interceptor.dart  # + Retry-After
├── core/clock.dart                                  # clockProvider（新）
├── app/router/{routes.dart, app_router.dart}        # + /join、/share/:code，Tab 换成真页面
├── features/
│   ├── room/
│   │   ├── application/{room.dart, rooms_provider.dart}
│   │   ├── data/room_repository.dart
│   │   └── presentation/{room_tab.dart, room_title.dart}
│   ├── invite/
│   │   ├── application/{invite_code.dart, codes.dart, join_controller.dart, codes_provider.dart, remaining.dart}
│   │   ├── data/{invite_repository.dart, poster_sink.dart}
│   │   └── presentation/{join_page.dart, bag_tab.dart, share_page.dart, widgets/{code_field.dart, code_tile.dart, poster_canvas.dart}}
│   └── home/presentation/home_shell.dart            # + 回到前台刷新
android/app/src/main/AndroidManifest.xml             # + WRITE_EXTERNAL_STORAGE maxSdk 28
env/dev_android.json                                 # + SHARE_BASE_URL
test/                                                # 与 lib/ 同构；test/features/invite/goldens/poster.png
```

---

### Task 1: 配置、限流头与错误码文案

**Files:**
- Modify: `lib/config/env.dart`、`env/dev_android.json`、`lib/core/network/interceptors/error_map_interceptor.dart`、`lib/config/error_codes.dart`、`assets/l10n/app_*.arb`
- Create: `lib/core/clock.dart`
- Test: `test/config/env_test.dart`、`test/core/network/error_map_interceptor_test.dart`、`test/config/error_codes_test.dart`

**Interfaces:**
- Produces:
  - `Env.shareBaseUrl`（`String.fromEnvironment('SHARE_BASE_URL', defaultValue: 'https://petbridge.example.com')`）。
  - `final clockProvider = Provider<DateTime Function()>((_) => DateTime.now);`
  - 429 且有整数 `Retry-After` 头时，`AppFailure.details['retry_after_seconds']` 为该整数；body 里已有同名字段时以 body 为准。
  - `localizedError` 新增：`CODE_INVALID`、`ROOM_FULL`、`ALREADY_MEMBER`、`AGE_RESTRICTED`、`ROOM_LIMIT`、`CODE_COOLDOWN`、`ONBOARDING_REQUIRED`、`CODE_ISSUE_LIMIT`（通用句，按 reason 的细分在 Task 8）。

- [ ] **Step 1: 写失败的测试**
  - `error_map_interceptor_test`：`RATE_LIMITED copies Retry-After into details`（头 `Retry-After: 42` → `details['retry_after_seconds'] == 42`）；`non-integer Retry-After is ignored`（`Retry-After: soon` → 无该键）；`CODE_COOLDOWN keeps body retry_after_seconds`（body 给 1800、无头 → 1800）。
  - `error_codes_test`：上面 8 个 code 都不回落到 `err_UNKNOWN` 的文字。
  - `env_test`：`shareBaseUrl defaults to placeholder`。
- [ ] **Step 2: 运行确认失败** — `flutter test test/config test/core/network`。
- [ ] **Step 3: 实现**。ARB 文案（zh_Hans）：无效 `验证码无效或已失效`；满员 `这个小屋已经满员了`；已在房内 `你已经在这个小屋里了`；年龄 `未成年人与成年人不能住在同一个小屋`；房间上限 `你已经在 2 间小屋里了，请先退出一间`；冷却 `尝试次数过多，请稍后再试`；未 onboarding `请先完成注册`；补码 `暂时无法生成验证码`。`env/dev_android.json` 加 `"SHARE_BASE_URL": "https://petbridge.example.com"`。
- [ ] **Step 4: 运行确认通过** — `flutter gen-l10n && flutter test && flutter analyze`。
- [ ] **Step 5: 提交信息** `feat(core): add share base URL, Retry-After details and join error texts`

---

### Task 2: 验证码格式工具

**Files:**
- Create: `lib/features/invite/application/invite_code.dart`、`lib/features/invite/application/remaining.dart`
- Test: `test/features/invite/invite_code_test.dart`、`test/features/invite/remaining_test.dart`

**Interfaces:**
- Produces（纯函数）：
  - `String normalizeCode(String raw)`：转大写，只保留字符集内字符，截到 8 位。
  - `String normalizePaste(String text)`：若含 `/j/<段>` 取该段，再 `normalizeCode`。
  - `bool isValidCode(String code)`：匹配 `^[2-9A-HJ-NP-Z]{8}$`。
  - `String formatCode(String code)`：长度 > 4 时在第 4 位后插 `-`。
  - `String? validCodeParam(String? raw)`：`raw` 原样匹配正则才返回，否则 `null`（深链与路由参数用，不做规范化）。
  - `String shareLink(String base, String code)`：去掉 `base` 末尾 `/` 后拼 `/j/$code`。
  - `sealed class Remaining`：`RemainingDays(int days)`、`RemainingHours(int hours)`、`RemainingSoon()`；`Remaining remainingUntil(DateTime expiresAt, DateTime now)`：≥24 小时为天（向下取整），1–23 小时为小时，否则 Soon。

- [ ] **Step 1: 写失败的测试**
  - `normalizes case, spaces and hyphens`：`' abcd-2345 '` → `'ABCD2345'`。
  - `drops characters outside the alphabet`：`'O0I1ab23'` → `'AB23'`。
  - `truncates to 8`：`'ABCD2345XY'` → `'ABCD2345'`。
  - `paste extracts code from share link`：`'来玩 https://petbridge.example.com/j/P9WD2HKR 吧'` → `'P9WD2HKR'`。
  - `formatCode`：`'ABCD2345'` → `'ABCD-2345'`；`'ABC'` → `'ABC'`；`'ABCD2'` → `'ABCD-2'`。
  - `validCodeParam rejects lowercase and hyphen`：`'abcd2345'`、`'ABCD-2345'`、`null` → `null`；`'ABCD2345'` → 原值。
  - `shareLink trims trailing slash`：`('https://x.com/', 'ABCD2345')` → `'https://x.com/j/ABCD2345'`。
  - `remainingUntil`：差 6 天 3 小时 → `RemainingDays(6)`；差 23 小时 59 分 → `RemainingHours(23)`；差 59 分 → `RemainingSoon()`；已过期 → `RemainingSoon()`。
- [ ] **Step 2: 运行确认失败** — `flutter test test/features/invite`。
- [ ] **Step 3: 实现**。
- [ ] **Step 4: 运行确认通过** — `flutter test && flutter analyze`。
- [ ] **Step 5: 提交信息** `feat(invite): add invite code formatting and validity helpers`

---

### Task 3: 房间与验证码的数据层

**Files:**
- Create: `lib/features/room/application/room.dart`、`lib/features/room/data/room_repository.dart`、`lib/features/invite/application/codes.dart`、`lib/features/invite/data/invite_repository.dart`
- Modify: `test/helpers/fakes.dart`（加 `MockRoomRepository`、`MockInviteRepository`）
- Test: `test/features/room/room_repository_test.dart`、`test/features/invite/invite_repository_test.dart`

**Interfaces:**
- Consumes: `PetBridgeApi`、`dioProvider`、`AppFailure.from`；测试用 `test/core/network/fake_adapter.dart`。
- Produces:
  - `enum RoomStatus { open, full, closed }`、`enum RoomRole { owner, member }`
  - `class RoomMember { final String userId; final String? nickname; final String? petType; final int seatNo; final RoomRole role; }`
  - `class Room { final String id; final bool isOwner; final RoomStatus status; final int memberCount; final int capacity; final List<RoomMember> members; final int? regenRemainingToday; RoomMember? get owner; int get freeSeats; }`（`members` 按 `seatNo` 升序；`regenRemainingToday` 在 Task 10 之前恒为 `null`）
  - `abstract interface class RoomRepository { Future<List<Room>> listMine(); }` + `roomRepositoryProvider`
  - `enum CodeStatus { unused, used, expired, voided }`（`void` 映射为 `voided`）
  - `class InviteCode { final String code; final CodeStatus status; final DateTime expiresAt; final String roomId; final int roomMemberCount; final int roomCapacity; }`
  - `class IssuedCode { final String code; final DateTime expiresAt; }`
  - `class JoinOutcome { final String roomId; final int memberCount; final int capacity; final List<RoomMember> members; final List<IssuedCode> rewards; RoomMember? get owner; }`
  - `abstract interface class InviteRepository { Future<JoinOutcome> join(String code); Future<List<InviteCode>> listCodes(); Future<IssuedCode> regen(String roomId); }` + `inviteRepositoryProvider`
  - 所有方法只抛 `AppFailure`。

- [ ] **Step 1: 写失败的测试**（假 adapter 返回 openapi 示例形状的 JSON）
  - `listMine maps rooms and sorts members by seat`（成员乱序给出 → 按 `seat_no` 排；`role: owner` → `RoomRole.owner`；`owner` getter 返回房主）。
  - `listMine tolerates null nickname and pet_type`。
  - `join maps rewards and members`；`join with empty rewards gives empty list`。
  - `join sends the code as typed`（请求体 `code` 等于传入值）。
  - `listCodes maps void to voided`。
  - `regen returns the issued code`。
  - `409 ROOM_FULL surfaces as AppFailure`（code `ROOM_FULL`、status 409）。
- [ ] **Step 2: 运行确认失败** — `flutter test test/features/room test/features/invite`。
- [ ] **Step 3: 实现**，写法同 `ApiOnboardingRepository`（`try` 包住生成客户端，`AppFailure.from`）。
- [ ] **Step 4: 运行确认通过** — `flutter test && flutter analyze`。
- [ ] **Step 5: 提交信息** `feat(room): add room and invite code repositories`

---

### Task 4: 房间状态（solo / inRoom）与回到前台刷新

**Files:**
- Create: `lib/features/room/application/rooms_provider.dart`
- Modify: `lib/features/home/presentation/home_shell.dart`
- Test: `test/features/room/rooms_provider_test.dart`、`test/features/home/home_shell_test.dart`

**Interfaces:**
- Consumes: `RoomRepository`（Task 3）、`sessionControllerProvider`。
- Produces:
  - `class RoomsController extends AsyncNotifier<List<Room>>`：`build()` 监听 `sessionControllerProvider.select((s) => s is SessionReady ? s.me.id : null)`，为 `null` 时返回 `[]` 且不请求；否则 `listMine()`。`Future<void> refresh()`：成功替换；失败时若已有数据则保留数据并重新抛出 `AppFailure`（供页面提示），没有数据则进入 `AsyncError`。
  - `final roomsProvider = AsyncNotifierProvider<RoomsController, List<Room>>(RoomsController.new);`
  - `enum RoomMode { solo, inRoom }`；`RoomMode roomModeFor(List<Room> rooms)`：任一 `memberCount > 1` 为 `inRoom`。
  - `final roomModeProvider = Provider<RoomMode>`：没有数据时为 `solo`。
  - `Room? defaultRoomFor(List<Room> rooms)`：第一间 `memberCount > 1`，否则第一间，空列表为 `null`。
  - `final selectedRoomIdProvider = NotifierProvider<SelectedRoomId, String?>`，方法 `select(String roomId)`。
  - `final selectedRoomProvider = Provider<Room?>`：选中 id 在列表里就用它，否则 `defaultRoomFor`。
  - `HomeShell` 回到前台（`AppLifecycleListener.onResume`）时调用 `roomsProvider.notifier.refresh()` 与 `codesProvider.notifier.refresh()`（Task 8 之前只刷房间；忽略刷新抛出的错误）。

- [ ] **Step 1: 写失败的测试**
  - `roomModeFor`：`[]` → solo；只有自己的房间 1 人 → solo；自己的房间 2 人 → inRoom；自己 1 人 + 他人 3 人 → inRoom。
  - `defaultRoomFor`：自己 1 人 + 他人 3 人 → 他人那间；自己 2 人 + 他人 3 人 → 自己那间。
  - `selected room falls back when it disappears`：选中他人房间后列表只剩自己房间 → 返回自己房间。
  - `fetches when session is ready` / `rooms cleared when session leaves ready`（`FakeSessionController.current = SessionUnauthenticated()` 后值为 `[]`）。
  - `refresh failure keeps previous rooms`（第二次 `listMine` 抛 `NETWORK` → 值仍为第一次结果，`refresh()` 抛出该 failure）。
  - `home_shell_test`：`refreshes rooms on resume`（`tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed)` 后 `listMine` 多调用一次）。
- [ ] **Step 2: 运行确认失败** — `flutter test test/features/room test/features/home`。
- [ ] **Step 3: 实现**。
- [ ] **Step 4: 运行确认通过** — `flutter test && flutter analyze`。
- [ ] **Step 5: 提交信息** `feat(room): derive solo and in-room state from my rooms`

---

### Task 5: 小屋 Tab（成员列表占位）

**Files:**
- Create: `lib/features/room/presentation/room_tab.dart`、`lib/features/room/presentation/room_title.dart`
- Modify: `lib/app/router/routes.dart`（加 `Routes.join = '/join'`，供按钮跳转；路由本身在 Task 7 挂上）、`lib/app/router/app_router.dart`（小屋分支换成 `RoomTab`）、`assets/l10n/app_*.arb`
- Test: `test/features/room/room_tab_test.dart`

**Interfaces:**
- Consumes: `roomsProvider`、`roomModeProvider`、`selectedRoomProvider`、`selectedRoomIdProvider`（Task 4）、`SessionReady.me`、`PetView`、`petName`。
- Produces:
  - `String roomTitle(AppLocalizations l, Room room)`：`isOwner` → `room_title_mine`（我的小屋）；否则房主昵称非空 → `room_title_of(name)`（{name}的小屋）；否则 `room_title_friend`（朋友的小屋）。
  - `class RoomTab extends ConsumerWidget`。

- [ ] **Step 1: 写失败的测试**（覆盖 `roomsProvider` 与会话；用一个带 `/join`、`/home/bag` 占位页的测试 `GoRouter` 包住 `RoomTab`，断言跳转后的路径）
  - `solo shows own pet and join button`（显示 `PetView`、昵称 · MBTI、“输入验证码”；点击后路由到 `/join`）。
  - `in room lists members by seat with owner tag`（自己显示 `room_me` “我”；房主带 `room_owner_tag`；不显示 MBTI）。
  - `shows free seats and invite button only for own room with space`（自己房间 3/5 → “还有 2 个空位” + “邀请朋友”，点击到 `/home/bag`；他人房间 → 无“邀请朋友”）。
  - `two rooms show a switcher`（分段两项，标签含 `3/5` 与 `4/5`；点第二项切换成员列表）；`one room hides the switcher`。
  - `first load failure shows retry`（重试后 `listMine` 再被调用）。
  - `long owner nickname is ellipsized`（30 字昵称，`tester.takeException()` 为 `null`，标题 `Text` 的 `overflow == TextOverflow.ellipsis`）。
- [ ] **Step 2: 运行确认失败** — `flutter test test/features/room/room_tab_test.dart`。
- [ ] **Step 3: 实现**，布局按 spec 6.1 与线框；下拉刷新调用 `refresh()`，失败时 SnackBar 显示 `localizedError`。ARB：`room_title_mine`、`room_title_of`、`room_title_friend`、`room_me`、`room_owner_tag`、`room_free_seats`（{count}）、`room_count`（{count}/{capacity}）、`room_invite`、`room_solo_hint`、`room_locked_title`、`room_locked_body`、`room_join_button`。
- [ ] **Step 4: 运行确认通过** — `flutter gen-l10n && flutter test && flutter analyze`。
- [ ] **Step 5: 提交信息** `feat(room): show solo pet and room member list in the room tab`

---

### Task 6: 输码流程 controller

**Files:**
- Create: `lib/features/invite/application/join_controller.dart`
- Test: `test/features/invite/join_controller_test.dart`

**Interfaces:**
- Consumes: `normalizeCode`、`normalizePaste`、`isValidCode`、`validCodeParam`（Task 2）；`InviteRepository.join`（Task 3）；`roomsProvider.notifier.refresh()`、`selectedRoomIdProvider`（Task 4）；`clockProvider`（Task 1）。
- Produces:
  - `class JoinState { final String input; final bool submitting; final AppFailure? failure; final DateTime? blockedUntil; final JoinOutcome? result; bool isBlocked(DateTime now); Duration remaining(DateTime now); bool canSubmit(DateTime now); }`（`canSubmit` = 合法 8 位且未提交中且未被冷却）
  - `class JoinController extends Notifier<JoinState>`（非 autoDispose，App 生命周期内保留；会话用户变化时重建）：`void setInput(String raw)`、`void paste(String text)`、`void prefill(String? param)`、`Future<void> submit()`、`void leave()`（清空 `input`、`failure`、`result`，保留 `blockedUntil`）、`void selectRoom(String roomId)`（转调 `selectedRoomIdProvider`）。
  - `submit` 成功：`result` 设为结果，选中该房间，刷新 `roomsProvider`；`codesProvider` 的刷新在 Task 8 接上。失败：`failure` 设为该错误，输入不变；`CODE_COOLDOWN` / `RATE_LIMITED` 带 `retry_after_seconds` 时 `blockedUntil = now + 秒数`。
  - `final joinControllerProvider = NotifierProvider<JoinController, JoinState>(JoinController.new);`

- [ ] **Step 1: 写失败的测试**（假时钟、`MockInviteRepository`）
  - `setInput normalizes and canSubmit only at 8 valid chars`。
  - `paste extracts link code`；`prefill ignores invalid param`（`'abc'` → 输入仍为空）。
  - `success stores outcome, selects room and refreshes rooms`。
  - `failure keeps input`（`CODE_INVALID` 后 `input` 不变、`failure.code == 'CODE_INVALID'`）。
  - `cooldown blocks until retry_after elapses`（`retry_after_seconds: 1800` → `isBlocked(now)` 为真、`remaining == 30 分钟`；时钟前进 1800 秒 → 为假）。
  - `RATE_LIMITED without retry_after does not block`。
  - `leave clears input but keeps cooldown`。
  - `server cooldown starts countdown on a fresh controller`（新容器、无本地状态，提交得到 `CODE_COOLDOWN` 900 秒 → 被冷却 15 分钟）。
  - `submit ignored while submitting`（连续两次调用只调用一次 `join`）。
  - `join state cleared when session changes`（换成另一个 `me.id` 后 `blockedUntil == null`）。
- [ ] **Step 2: 运行确认失败** — `flutter test test/features/invite/join_controller_test.dart`。
- [ ] **Step 3: 实现**。
- [ ] **Step 4: 运行确认通过** — `flutter test && flutter analyze`。
- [ ] **Step 5: 提交信息** `feat(invite): add join flow controller with cooldown countdown`

---

### Task 7: 输码页与成功页

**Files:**
- Create: `lib/features/invite/presentation/join_page.dart`、`lib/features/invite/presentation/widgets/code_field.dart`
- Modify: `lib/app/router/routes.dart`（`redirectFor` 放行 `/join`）、`lib/app/router/app_router.dart`（挂 `/join`，读 `?code=` 传给页面）、`assets/l10n/app_*.arb`
- Test: `test/features/invite/join_page_test.dart`、`test/app/router/redirect_test.dart`

**Interfaces:**
- Consumes: `joinControllerProvider`（Task 6）、`formatCode`（Task 2）、`localizedError`、`clockProvider`。
- Produces: `class JoinPage extends ConsumerStatefulWidget { const JoinPage({String? initialCode}); }`；进入时 `prefill(initialCode)`，`dispose` 时 `leave()`。`Routes.sharePath(String code)` 在 Task 9 定义，本任务“去分享”按钮使用它，所以先在 `routes.dart` 加 `static const share = '/share'` 与 `static String sharePath(String code) => '$share/$code';`。

- [ ] **Step 1: 写失败的测试**
  - `redirect_test`：`ready on /join -> null`；`ready on /share/ABCD2345 -> null`；`needsOnboarding on /join -> /onboarding/lang`。
  - `join button disabled until 8 valid chars`；`field shows XXXX-XXXX`。
  - `paste button fills from clipboard`（用 `tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, …)` 返回 `Clipboard.getData` 的文本）；`does not read clipboard on open`（打开页面时 handler 未收到 `Clipboard.getData`）。
  - `error text shown under field and input kept`（`ROOM_FULL` → 显示 `err_ROOM_FULL` 文字，输入框仍为原值）。
  - `ALREADY_MEMBER offers go to room`（点击后选中 `details.room_id`，路由到 `/home`）。
  - `cooldown disables field, paste and button and shows mm:ss`（`29:59` 格式；推进假时钟与 `tester.pump(1s)` 后文字变化；到点后按钮恢复）。
  - `success with rewards shows gift and share`（“去分享”到 `/share/<第一个码>`）；`success without rewards hides gift`（只有“去小屋看看”）。
  - `prefills valid code param`。
- [ ] **Step 2: 运行确认失败** — `flutter test test/features/invite/join_page_test.dart test/app/router`。
- [ ] **Step 3: 实现**，布局按 spec 6.2 与线框；倒计时用页面内每秒 `Timer.periodic` 重建；礼盒用缩放 + 淡入。冷却时提示用 `join_retry_in`（{time}）替代通用文案。ARB：`join_title`、`join_hint`、`join_paste`、`join_submit`、`join_retry_in`、`join_go_room`、`join_success_title`、`join_success_body`（{room}）、`join_reward_title`、`join_reward_body`、`join_share`。
- [ ] **Step 4: 运行确认通过** — `flutter gen-l10n && flutter test && flutter analyze`。
- [ ] **Step 5: 手动验证** — 本地后端 `task dev` + `task seed`；开发登录新账号走完 onboarding，小屋 Tab 为 solo；输入种子码 `DEVA2345` → 成功页 → 去小屋看看显示成员列表；`FULL2345` 显示满员文案。
- [ ] **Step 6: 提交信息** `feat(invite): add join page with error, cooldown and reward states`

---

### Task 8: 背包 Tab

**Files:**
- Create: `lib/features/invite/application/codes_provider.dart`、`lib/features/invite/presentation/bag_tab.dart`、`lib/features/invite/presentation/widgets/code_tile.dart`
- Modify: `lib/app/router/app_router.dart`（背包分支换成 `BagTab`）、`lib/features/invite/application/join_controller.dart`（成功后也刷新 `codesProvider`）、`lib/features/home/presentation/home_shell.dart`（回到前台也刷新背包）、`assets/l10n/app_*.arb`
- Test: `test/features/invite/codes_provider_test.dart`、`test/features/invite/bag_tab_test.dart`、`test/features/invite/join_controller_test.dart`、`test/features/home/home_shell_test.dart`

**Interfaces:**
- Consumes: `InviteRepository.listCodes / regen`（Task 3）、`roomsProvider`（Task 4）、`remainingUntil`、`formatCode`（Task 2）。
- Produces:
  - `class CodesController extends AsyncNotifier<List<InviteCode>>`：`build` 同 `RoomsController` 的会话规则；`refresh()` 同 Task 4 的失败规则；`Future<IssuedCode> regen()`：用 `roomsProvider` 里 `isOwner` 的房间 id，成功后刷新背包与 `roomsProvider`，失败抛 `AppFailure`。
  - `final codesProvider = AsyncNotifierProvider<CodesController, List<InviteCode>>(CodesController.new);`
  - `String regenFailureText(AppLocalizations l, AppFailure f)`：`CODE_ISSUE_LIMIT` 按 `details.reason`（`room_full` / `enough_unused` / `daily_limit` / `lifetime_limit`）给四句，其他走 `localizedError`。

- [ ] **Step 1: 写失败的测试**
  - `codes_provider_test`：`codes cleared when session leaves ready`；`refresh failure keeps previous codes`；`regen uses own room id and refreshes codes and rooms`。
  - `join_controller_test` 追加：`success refreshes codes`。
  - `home_shell_test` 追加：`refreshes codes on resume`。
  - `bag_tab_test`：
    - `shows four status labels and room count`（每项显示 `小屋 3/5`）。
    - `unused shows remaining validity and share`（6 天 → `还剩 6 天`；点“分享”到 `/share/<code>`）；`used has no share button`。
    - `regen disabled with hint when own room is full`。
    - `regen remaining line hidden while regenRemainingToday is null`；`regen disabled when regenRemainingToday is 0`（显示“今天的生成次数已用完”）；`shows regen remaining count`（2 → “今天还可以生成 2 次”）。
    - `regen failure shows reason text`（`enough_unused` → 对应文字）；`regen success shows snackbar`。
    - `empty list shows empty state`；`top-right opens join`。
- [ ] **Step 2: 运行确认失败** — `flutter test test/features/invite test/features/home`。
- [ ] **Step 3: 实现**，布局按 spec 6.3；下拉刷新失败用 SnackBar。ARB：`bag_title`、`bag_join`、`bag_status_unused / used / expired / void`、`bag_room_count`（{count}/{capacity}）、`bag_days_left`（{days}）、`bag_hours_left`（{hours}）、`bag_expiring`、`bag_share`、`bag_regen`、`bag_regen_full`、`bag_regen_remaining`（{count}）、`bag_regen_none_left`、`bag_regen_done`、`bag_empty`、`bag_regen_room_full`、`bag_regen_enough_unused`、`bag_regen_daily_limit`、`bag_regen_lifetime_limit`。
- [ ] **Step 4: 运行确认通过** — `flutter gen-l10n && flutter test && flutter analyze`。
- [ ] **Step 5: 提交信息** `feat(invite): add backpack tab with code list and regeneration`

---

### Task 9: 分享海报（保存到相册与系统分享）

**Files:**
- Create: `lib/features/invite/presentation/share_page.dart`、`lib/features/invite/presentation/widgets/poster_canvas.dart`、`lib/features/invite/data/poster_sink.dart`
- Modify: `pubspec.yaml`（`flutter pub add qr_flutter share_plus path_provider gal`）、`android/app/src/main/AndroidManifest.xml`、`lib/app/router/app_router.dart`（挂 `/share/:code`）、`assets/l10n/app_*.arb`
- Test: `test/features/invite/share_page_test.dart`、`test/features/invite/poster_canvas_test.dart`（含 golden `test/features/invite/goldens/poster.png`）

**Interfaces:**
- Consumes: `codesProvider`（Task 8）、`validCodeParam`、`formatCode`、`shareLink`（Task 2）、`Env.shareBaseUrl`、`SessionReady.me.petType`、`PetView`、`Routes.sharePath`（Task 7）。
- Produces:
  - `class PosterCanvas extends StatelessWidget { const PosterCanvas({required String petType, required String code, required int memberCount, required int capacity, required String link}); }`（固定 360×480）。
  - `enum SaveResult { saved, denied }`
  - `abstract interface class PosterSink { Future<SaveResult> saveToGallery(Uint8List png); Future<void> share(Uint8List png, String text); }` + `posterSinkProvider`。实现：保存用 `Gal.hasAccess()` / `Gal.requestAccess()` / `Gal.putImageBytes`，无权限返回 `denied`；分享把 PNG 写到 `getTemporaryDirectory()` 后 `SharePlus.instance.share(ShareParams(files: [XFile(path)], text: text))`。
  - `Future<Uint8List> capturePng(GlobalKey boundaryKey)`：等 `WidgetsBinding.instance.endOfFrame` 后 `toImage(pixelRatio: 3)`。
  - Manifest：`<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" android:maxSdkVersion="28" />`，其余按 `gal` README 的 Android 要求补齐。

- [ ] **Step 1: 写失败的测试**
  - `poster_canvas_test`：`poster golden`（`matchesGoldenFile('goldens/poster.png')`，用测试默认字体）；`capture produces 1080x1440 png`（解码 PNG 头的宽高）。
  - `share_page_test`（覆盖 `posterSinkProvider` 为 mock）：
    - `share page waits for codes before deciding`（`codesProvider` 处于加载中时显示进度，不显示“不能再分享”）。
    - `unknown or used code shows not shareable`；`invalid code param shows not shareable`。
    - `share passes png and text with link`（文字含 `XXXX-XXXX` 与 `https://petbridge.example.com/j/<code>`）。
    - `save shows saved snackbar`；`save denied shows permission text`。
- [ ] **Step 2: 运行确认失败** — `flutter test test/features/invite/share_page_test.dart test/features/invite/poster_canvas_test.dart`。
- [ ] **Step 3: 实现**，按 spec 6.4；生成 golden：`flutter test --update-goldens test/features/invite/poster_canvas_test.dart`，人工看一眼图片再入库。ARB：`share_title`、`share_headline`、`share_room_count`（{count}/{capacity}）、`share_save`、`share_system`、`share_text`（{code}/{link}）、`share_saved`、`share_denied`、`share_unavailable`。
- [ ] **Step 4: 运行确认通过** — `flutter gen-l10n && flutter test && flutter analyze`。
- [ ] **Step 5: 手动验证** — 模拟器（API 34）分享弹出系统面板、保存后相册可见；如有 API 28 模拟器，首次保存弹权限、拒绝后显示提示。
- [ ] **Step 6: 提交信息** `feat(invite): add share poster with save and system share`

---

### Task 10: 接上今日剩余补码次数（等后端）

**前置：** 后端已在 `GET /rooms/mine` 的 `RoomDetail` 加入可空的 `regen_remaining_today` 并合入（在后端仓库另行完成，本计划不改后端）。

**Files:**
- Modify: `lib/gen/**`（重新生成）、`lib/features/room/data/room_repository.dart`
- Test: `test/features/room/room_repository_test.dart`、`test/gen/contract_decode_test.dart`

**Interfaces:**
- Consumes: Task 3 的 `Room.regenRemainingToday`；Task 8 的背包显示已按该字段写好。

- [ ] **Step 1: 重新生成客户端** — `powershell -File tool/gen_api.ps1`，确认 `RoomDetail` 有 `int? regenRemainingToday`。
- [ ] **Step 2: 写失败的测试** — `listMine maps regen_remaining_today`（自己房间 2 → 2；他人房间 `null` → `null`）；`contract_decode_test` 加一条带该字段的 `RoomDetail`。
- [ ] **Step 3: 运行确认失败** — `flutter test test/features/room test/gen`。
- [ ] **Step 4: 实现映射**。
- [ ] **Step 5: 运行确认通过** — `flutter test && flutter analyze`。
- [ ] **Step 6: 提交信息**（两段）`build: regenerate API client for regen remaining count`、`feat(room): map today's remaining regen count`

---

### Task 11: 端到端联调与收尾

- [ ] **Step 1: 前置** — 后端 `task up && task migrate && task seed && task dev`；`flutter run --dart-define-from-file=env/dev_android.json`。
- [ ] **Step 2: 两人入房** — 开发登录新账号 A 完成 onboarding → 小屋 Tab solo；背包复制 A 的码。退出，登录新账号 B 完成 onboarding → 输入 A 的码 → 成功页礼盒有奖励码 → 小屋 Tab inRoom、两间房可切换。退出换回 A → 小屋 Tab 显示 B（或在 A 已登录的设备回到前台 / 下拉刷新后出现）。
- [ ] **Step 3: 异常路径** — `FULL2345` 满员；连输 5 次错码出现 30 分钟倒计时，离开再回来仍在；种子用户 F 输 A 的码得到年龄限制；B 再输 A 的另一个码得到“已在小屋里”并能跳过去。
- [ ] **Step 4: 背包与海报** — 生成验证码直到被拒，确认拒绝原因文案；（Task 10 完成后）剩余次数从 3 降到 0 且按钮置灰；分享页保存与系统分享都可用，导出 PNG 为 1080×1440。
- [ ] **Step 5: 全量检查** — `flutter analyze && flutter test`。
- [ ] **Step 6: 文档同步核对** — 实现中若改了设计，按规则更新三份文档并写变更记录，两个仓库 `md5sum` 一致（后端仓库的文档改动不提交，交用户处理）。
- [ ] **Step 7: 提交信息** — 无改动则不提交；有文档改动：`docs: sync F1 implementation notes`。

---

## Self-Review

- **Spec 覆盖**：输码页规则与错误表（T2、T6、T7）、成功页与奖励（T7）、背包列表 / 人数 / 有效期 / 生成验证码 / 拒绝原因 / 今日剩余（T8、T10）、海报内容 / 导出 / 保存 / 分享 / 依赖与权限（T9）、小屋 Tab solo 与 inRoom / 标题规则 / 切换（T5）、房间数据刷新时机（T4、T6、T8）、路由与 redirect（T7、T9）、Retry-After（T1）、`SHARE_BASE_URL`（T1）、多语言（各任务）、golden 只做海报（T9）、手动端到端（T7、T9、T11）、后端字段（T10 前置）。
- **类型一致**：`Room`、`RoomMember`、`RoomRole`、`RoomStatus`、`InviteCode`、`CodeStatus.voided`、`IssuedCode`、`JoinOutcome`、`RoomMode`、`roomsProvider`、`selectedRoomIdProvider`、`selectedRoomProvider`、`codesProvider`、`joinControllerProvider`、`clockProvider`、`Routes.join`、`Routes.sharePath`、`PosterSink`、`SaveResult` 在各任务 Interfaces 中同名使用。
- **待实现时确认**：`gal` 在 Android 8–9 的 Manifest 细节以其 README 为准（T9）；`AsyncNotifier` 刷新失败保留旧值的写法按 Riverpod 3 的 `AsyncValue` API 实现（T4、T8）。
