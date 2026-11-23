# F2 实时小屋、宠物绘制与房主管理设计

> 日期：2026-11-23 · 对应前端 TRD v1.10 第 20 章 W5–6 的 F2 · 后端依赖 B4（已完成）· 状态：待确认

## 1. 目的

F1 让“入房”跑通，但小屋 Tab 只是一张成员列表，别人上线、加入都要下拉刷新才看得到。F2 要让同一间小屋里的人**实时看到彼此**：谁在线、谁睡着、谁点了谁的宠物（里程碑 M2“多人实时可见”）。

用户最看重的验收：**一台模拟器 + 一台安卓真机，两边互相看到对方宠物上线、下线**；并且 F1 已有的操作（输码入房、背包、生成验证码、分享海报）在 F2 后全部照常可用，F2 列出的操作一个不砍。

团队没有美术，F2 同时把占位宠物换成**用代码画的 16 只宠物**，以后有正式美术再替换，调用方不变。

## 2. 范围

**做（分两段，同一份计划）**

- **F2a 实时与场景**
  - 会话级 WebSocket 客户端：连接、鉴权、重连退避、前后台、`4401` 刷新、`server.restart`、限流。
  - 房间事件 reducer（TRD 第 7 章规则 1–9），每间房一份实时状态。
  - 小屋 Tab 由成员列表换成场景：墙、窗、木地板、地毯，5 个座位。
  - 宠物：16 只代码绘制，无描边；姿态 `idle`（待机）、`sleep`（离线）、`cute`（卖萌）。
  - presence：离线的宠物睡觉，上线立即醒来。
  - 点他人宠物：本地立刻卖萌，发 `pet.tap`；收到 `pet.action` 时在对应座位卖萌。
  - 断线超过 3 秒显示“正在重连…”。
- **F2b 管理与退出**
  - 房主：长按成员宠物 → 底部弹层“移除出小屋” → 二次确认；`⋯` 菜单 → 管理小屋页（`/room/:id/manage`）：成员列表（可移除）与“解散小屋”。
  - 成员：在他人小屋 `⋯` 菜单 → “退出小屋” → 二次确认。
  - 被移除 / 被解散 / 在另一台设备退出：收到 `room.kicked` 后离开该房间，回到自己的小屋，`left` 以外提示“你已离开该小屋”。
  - `code.invalidated`：刷新背包列表。

**不做**

- 聊天与消息事件（TRD 规则 10、11）——F3。
- 打卡、装扮、举报屏蔽、长按“查看资料”——F4。
- 养成（吃 / 洗 / 睡 + level + 亲密度 + 解锁玩法）——**第二版**，MVP 不做（用户决定）。F2 不画“吃”“洗”。
- 强制更新页：F2 只解析 `hello.proto` / `min_app_version` 并在不兼容时停止重连、记日志；页面放到 F6（我的决定）。
- 深链、推送、Widget——F5。

**反目标**（技术上能跑但算失败）

- 场景在上下线、点宠物时整页闪烁或重建背包等无关页面。
- 断网、切后台再回来后，看到的成员 / 在线状态和服务端不一致且不会自己恢复。
- 16 只宠物画风不统一（有的有描边、有的比例不同）。

## 3. 约束

- 设备：安卓模拟器 + 一台安卓真机。真机连本机后端要用电脑的局域网 IP；后端需监听 `0.0.0.0`；Android 默认禁止明文 HTTP，需确认 debug 构建允许连该 IP（见 9.3）。
- 协议以后端 TRD 第 9 章为准：帧 `{t, id?, seq?, d}`；每连接最多订阅 2 间房；`pet.tap` 每秒最多 2 次（超出服务端静默丢弃）；`room.sub` 每 10 秒最多 10 次。
- 只用现有依赖 + `dart:io` 的 `WebSocket`；不引入 Rive（用户决定改为代码绘制）。

## 4. 做法比较（用户已选 A）

| | 做法 | 取舍 |
| :-- | :-- | :-- |
| **A. 两层（已选）** | 会话级 `WsClient` + 每间房一份实时状态（快照 + reducer）；`roomsProvider` 仍只管“我在哪几间房” | 上下线这类高频小变化只重建场景；F3 聊天沿用同一套事件分发；多一层、reducer 要单测 |
| B. 全进 `roomsProvider` | 事件直接改房间列表 | 少一层；但每次上下线整张列表重建，背包、标题跟着刷新；F3 要拆开，等于返工 |
| C. 轮询 | 定时拉 `GET /rooms/mine` | 达不到 PRD 300ms；后端 B4 已就绪，放弃 |

## 5. 已定的决定

**用户决定**

- 做法 A。
- 宠物用代码绘制，画风按样例（圆滚滚 Q 版，同一套身体，靠颜色 / 耳朵 / 尾巴 / 花纹区分），**无描边**。
- 场景按样例：暖色木屋，房主在中间最前，其余按座位号排左前、右前、左后、右后，后排略小。
- 卖萌 = A 点 B 的宠物时 B 宠物的反应，同屋都看到；吃 / 洗 / 睡（养成）与 level、亲密度放第二版。
- 验收：模拟器 + 真机互相看到上下线；F1 与 F2 的操作都要有。

**我的决定**（可推翻）

- 场景继续放在小屋 Tab（F1 已如此），不新开 `/room/:id` 页；`/room/:id/manage` 照 TRD 新增。
- 点自己的宠物也卖萌，只在本地播放，不发 `pet.tap`（服务端要求目标是“其他成员”）。
- 长按自己 / 在他人小屋长按别人：F2 不弹菜单（F4 放举报屏蔽）。
- 成员变化（`member.joined` / `member.left` / `room.kicked`）后重新拉一次 `GET /rooms/mine`，而不是在本地改列表：这类事件很少，重拉能顺带更新 `regen_remaining_today` 与背包状态，逻辑最简单。
- `last_seq` 只存内存，不写 prefs（服务端 v1.4 起不使用 `last_seq`，每次订阅都给快照；TRD 规则 7 相应删除）。
- 切到后台：PRD F3.2 要求“离开 App 时立即睡着”，TRD 9.2 写的是“后台 30 秒后断开”，两者冲突。**按 PRD**：`AppLifecycleState.paused` 时立即断开（下拉通知栏触发的 `inactive` 不断开），`resumed` 立即重连。TRD 9.2 改掉“30 秒”。
- 宠物 16 只的特征表（6.2）是我定的初稿，实现时可微调，但必须守住“同一套身体、无描边”。
- 卖萌动画时长约 1.2 秒；同一只宠物动画进行中再被点，从头重播，不叠加。
- 本地 `pet.tap` 节流：每只目标宠物 500ms 内只发一次，且整条连接每秒最多发 2 次（服务端限制按连接计算），超出只在本地播放、不发送。
- 解散会连续收到多条 `member.left`：对 `roomsProvider.refresh()` 做合并（500ms 内多次只刷一次）。
- 样例（画风与场景的参照）：`.superpowers/brainstorm/3370-1795341157/content/pets-v1.html`、`room-scene-v1.html`（不入库，实现时本地打开参考）。

## 6. 设计

### 6.1 结构

```
lib/core/realtime/
  ws_frame.dart          帧编解码 {t,id,seq,d}
  ws_transport.dart      接口：connect(url, headers) → 收发 + close code；IoWsTransport 用 dart:io WebSocket（pingInterval 25s）
  ws_client.dart         连接状态机、退避、鉴权、前后台；暴露 connectionState 流 + events 流 + send()
  ws_providers.dart      wsClientProvider（readyUserIdProvider 非空时创建并连接，变空时关闭）
lib/features/room/application/
  room_live.dart         RoomLive（成员 + presence + seq + 人数）与 RoomEventReducer（纯函数）
  room_live_provider.dart roomLiveProvider(roomId)
  realtime_coordinator.dart 订阅管理与事件分发（见 6.3）
  pet_actions.dart       每间房的一次性动作流（卖萌），场景订阅
  room_admin.dart        移除 / 解散 / 退出（调用 REST，处理错误）
lib/features/pet/presentation/
  pet_painter.dart       PetSpec（16 只参数）+ CustomPainter
  pet_view.dart          改为 PetView(petType, pose, size)，内部 AnimationController；pose: idle/sleep/cute
lib/features/room/presentation/
  room_tab.dart          场景版
  room_scene.dart        背景 + 5 座位锚点 + 名牌
  room_manage_page.dart  /room/:id/manage
  member_sheet.dart      长按成员弹层
```

PetView 的对外接口保留 `petType` 与 `size`，新增可选 `pose`（默认 `idle`），F0 的揭晓页、F1 的海报不用改调用。海报里静态绘制（不播放动画）。

### 6.2 宠物绘制

- 一个 `PetPainter`，画布 200×200 逻辑坐标，按 `PetSpec` 画：身体族（`mammal` / `bird` / `fish`）、主色、浅色（脸 / 肚）、深色（花纹 / 内耳）、耳朵、尾巴、脸部花纹、头顶配件。
- 族：`mammal` = 大头 + 小身 + 两脚；`bird` = 圆身 + 两翼 + 喙（无耳）；`fish`（仅海豚）= 圆身 + 胸鳍 + 尾鳍，无脚。
- 姿态：
  - `idle`：轻微呼吸（2.4s 循环缩放），睁眼。
  - `sleep`：闭眼弧线，慢呼吸（3.4s），头顶飘 z，整体略降饱和度。
  - `cute`：大眼双高光，跳一下 + 歪头，冒 3 颗爱心；1.2s 后回到当前状态（在线 → `idle`，离线 → `sleep`）。
- 动画只用 Flutter 动画；场景外层 `RepaintBoundary`，每只宠物一个；App 不在前台时 `TickerMode` 关闭。

| pet_type | 族 | 主色 | 特征 |
| :-- | :-- | :-- | :-- |
| lone_leopard | mammal | 浅金 | 圆耳、深色斑点、长尾 |
| leader_lion | mammal | 金黄 | 鬃毛圈、圆耳、尾端毛球 |
| thinker_owl | bird | 棕 | 耳羽簇、大圆眼圈、小喙 |
| clever_fox | mammal | 橙红 | 尖耳、白脸颊、蓬松尾白尖 |
| guardian_deer | mammal | 浅棕 | 小鹿角、背上白点、短尾 |
| guide_dolphin | fish | 天蓝 | 胸鳍、尾鳍、浅色肚 |
| healing_rabbit | mammal | 奶白 | 长耳粉内耳、团子尾 |
| happy_shiba | mammal | 柴橙 | 三角耳、奶白脸、卷尾 |
| steady_beaver | mammal | 深棕 | 小圆耳、门牙、扁尾 |
| order_sheepdog | mammal | 灰白 | 垂耳、额前毛、蓬松身 |
| guardian_penguin | bird | 藏青 | 白脸心形、橙喙橙脚 |
| warm_otter | mammal | 栗色 | 小圆耳、浅色口鼻、胡须 |
| calm_blackcat | mammal | 黑灰 | 尖耳、绿眼、细长尾 |
| daring_falcon | bird | 灰蓝 | 钩喙、眼下深纹、尖翼 |
| easygoing_alpaca | mammal | 米白 | 头顶卷毛、立耳、长脖 |
| party_parrot | bird | 鲜绿 | 头顶彩羽、红胸、弯喙 |

### 6.3 实时数据流

```
WsClient ──events──► RealtimeCoordinator
                       ├─ room.snapshot / member.* / presence.update ─► roomLiveProvider(roomId) 经 reducer 更新
                       ├─ member.joined / member.left ─► roomsProvider.refresh()
                       ├─ pet.action ─► petActionsProvider(roomId) 发一次性事件
                       ├─ room.kicked ─► 取消订阅、清该房实时状态、roomsProvider.refresh()、按 reason 提示
                       ├─ code.invalidated ─► codesProvider.refresh()
                       ├─ resync ─► 对相应房间重新 room.sub
                       └─ error{ref} ─► room.sub 的 ROOM_NOT_FOUND 按规则 9；RATE_LIMITED 1 秒后重订
roomsProvider（房间 id 集合）变化 ─► Coordinator：新房间 room.sub，消失的房间 room.unsub
WsClient 进入 ready ─► Coordinator：对所有房间 room.sub
```

- **订阅**：订阅“我在的全部房间”（最多 2 间，等于服务端上限），不只是当前选中的那间。这样两间都能实时，切换时立刻有数据。
- **场景数据来源**：有快照时用 `roomLiveProvider(roomId)`；快照到达前用 `roomsProvider` 里的成员，presence 视为未知 → 画 `idle`（不先画睡觉，避免一进来全员“睡着再醒”）。
- **reducer**（纯函数，输入旧状态 + 事件，输出新状态 + 副作用列表，如“需要重新订阅”）：
  1. `room.snapshot` 整体替换，`lastSeq = seq`。
  2. 带 seq 的事件：`seq ≤ lastSeq` 丢弃；`seq == lastSeq+1` 应用；有缺口且缺口 < 20 先缓冲，1 秒内补齐则依序应用，否则输出“重新订阅”；缺口 ≥ 20 直接“重新订阅”。
  3. 不带 seq 的事件直接应用，不改 `lastSeq`。
  4. `member.joined` 有则覆盖、无则加入；`member.left` 有则删、无则忽略；人数随之更新。
  5. 未知事件忽略。
- 同一房间 1 秒内的重新订阅合并为一次（TRD 9.2）。

### 6.4 WsClient

| 项 | 行为 |
| :-- | :-- |
| 地址 | 新增环境变量 `WS_URL`（`env/dev_android.json`：`ws://10.0.2.2:8090/api/v1/ws`） |
| 状态 | `disconnected → connecting → connected →（hello）ready`；`subscribed` 是每间房的状态，放在 Coordinator 里，不进 WsClient |
| 鉴权 | 升级请求头 `Authorization: Bearer <access>`；连前解析 access token（JWT）的 `exp`，剩余 < 60 秒先走刷新；升级返回 401 时刷新一次再连 |
| 刷新 | 复用 `AuthInterceptor` 的单飞刷新逻辑（抽出一个 `TokenRefresher`，REST 与 WS 共用，保证同时只刷一次）；刷新被服务端拒绝 → 会话结束，与 REST 一致 |
| 关闭码 | `4401` 刷新后立即重连，不退避；`4001`（被同账号更新的连接替换）不重连；`1001` / `server.restart` 随机等待 1–10 秒；其余走退避 |
| 退避 | 1、2、4、8、16、30 秒，加 0–30% 抖动；连上稳定 60 秒后重置 |
| 升级失败 | 429 按 `Retry-After`；503 `NOT_READY` 同 `server.restart`；403 `ONBOARDING_REQUIRED` 不重连 |
| 前后台 | `paused` 立即关闭（1000）；`resumed` 立即重连（清退避）；`inactive` 不处理 |
| 网络 | 不额外监听网络变化；断开后按退避重试即可（我的决定，少一个依赖） |
| 协议版本 | `hello.proto` 主版本 > 1 或 `min_app_version` 高于当前版本：停止重连，记日志（页面在 F6） |
| 心跳 | 只用 `pingInterval: 25s`，应用层不实现 |
| 指示 | 非 `ready` 持续 3 秒以上显示“正在重连…”，回到 `ready` 立即隐藏；`paused` 期间不算 |

### 6.5 场景与交互

- **布局**：场景占小屋 Tab 除底栏外的全部区域；背景（墙、窗、置物架、地板、地毯）用 `CustomPainter` 画。座位锚点用相对比例：
  - 1 号（房主）：(50%, 88%)，宽 32%
  - 2 号 / 3 号：(21%, 79%) / (79%, 79%)，宽 28%
  - 4 号 / 5 号：(33%, 65%) / (67%, 65%)，宽 24%
  - 锚点是宠物脚底中心。
- **名牌**：宠物下方白色胶囊，`[👑]` + 昵称（空时用宠物名）；不显示语言标识（见第 10 节）。离线时名牌略淡。
- **空位**：虚线椭圆软垫；自己小屋的空位显示“＋ 邀请”，点了去背包；他人小屋的空位只有软垫。
- **顶部**：左侧房间切换胶囊“我的小屋 ▾ 4/5”（在两间房时可点切换，只有一间时不显示箭头）；右侧 `⋯`：自己的小屋 → “管理小屋”；他人小屋 → “退出小屋”。
- **solo**（自己小屋只有自己，且不在他人小屋）：场景照常画，下方卡片“小屋里只有你一个人。邀请朋友，或用验证码去朋友的小屋”，按钮“输入验证码”“邀请朋友”。
- **点宠物**：他人宠物 → 本地 `cute` + `pet.tap`；自己宠物 → 本地 `cute`；离线（睡觉）的宠物也能点，点完回到睡觉。
- **下拉刷新**：场景不是列表，去掉下拉刷新；F1 的“回到前台刷新 `roomsProvider`”保留。

### 6.6 房主管理与退出（F2b）

| 操作 | 入口 | 确认文案要点 | 接口 | 成功后 |
| :-- | :-- | :-- | :-- | :-- |
| 移除成员 | 长按他人宠物（仅自己小屋）→ 弹层；或管理页成员行 | 对方将离开小屋，且不能再加入这间小屋 | `DELETE /rooms/{id}/members/{user_id}`（幂等） | 刷新 `roomsProvider`；场景由 `member.left` 更新 |
| 解散 | 管理页底部 | 所有成员将离开，未使用的验证码作废；小屋保留 | `POST /rooms/{id}/dissolve` | 刷新 `roomsProvider` 与 `codesProvider`，回到小屋 Tab |
| 退出 | 他人小屋 `⋯` | 退出后座位空出，用过的码不会恢复 | `POST /rooms/{id}/leave` | 刷新 `roomsProvider`，选中自己的小屋 |

- 管理页：标题“管理小屋”；成员列表（宠物小图、昵称、房主标签；非房主行右侧“移除”）；底部红色“解散小屋”（只有自己一人时置灰）。进入时若该房间不是自己的，直接返回小屋 Tab。
- 错误：`NOT_ROOM_OWNER`、`OWNER_CANNOT_LEAVE`（提示用“解散”）、`ROOM_NOT_FOUND`（按已离开处理）、网络错误（SnackBar，可重试）。文案进 ARB。
- 被移出（`room.kicked`）：若正选中该房间，切回自己的小屋；`kicked` / `dissolved` 提示“你已离开该小屋”（不区分原因、不显示操作者）；`left` 不提示。若在管理页时自己的房间状态变化，管理页随 provider 更新。

## 7. 测试

- **单元**：reducer（快照替换、seq 丢弃 / 应用 / 缺口缓冲 / 超时重订 / 缺口 ≥20、幂等、无 seq 事件、未知事件）；WsClient（假 transport + 假时钟：hello→ready、退避序列与抖动范围、60 秒稳定重置、4401 刷新立即重连、4001 不重连、server.restart 1–10 秒、429 Retry-After、paused 关闭 / resumed 重连、exp < 60 秒先刷新）；Coordinator（房间集合变化时 sub/unsub、ready 后全部重订、RATE_LIMITED 1 秒后重订、1 秒内合并、room.kicked 处理）；`pet.tap` 节流。
- **Widget**：场景按 seat_no 放置、离线为 `sleep`、点他人宠物发 `pet.tap`、收到 `pet.action` 播放 `cute`、重连提示 3 秒阈值、⋯ 菜单按身份不同、移除 / 解散 / 退出的确认与错误提示、被移出后切回自己小屋。
- **Golden**：一张 16 只 × 3 姿态的静态宠物图（无文字，不受字体影响），人工看过再入库。
- **手动验收（模拟器 A + 真机 B）**：见第 8 节。

## 8. 验收清单

1. 前置：后端 `task up && task migrate && task seed && task dev`（监听 `0.0.0.0`）；模拟器用 `env/dev_android.json`，真机用 `env/local.json`（电脑局域网 IP，由 `env/local.example.json` 复制）。
2. F1 回归：新账号 onboarding → solo 场景 → 背包复制码 → 另一台输码入房 → 礼盒奖励码 → 背包生成验证码与剩余次数 → 分享页保存与系统分享。
3. 上下线：A、B 同屋。B 按 Home 键 → A 看到 B 的宠物睡着（目标 ≤ 1 秒）；B 回到 App → A 看到醒来。B 杀进程 → A 最迟约 70–105 秒后看到睡着（服务端心跳过期 + 扫描）。
4. 点宠物：A 点 B 的宠物 → A 立刻卖萌，B 那边同一只也卖萌；连点不刷爆。
5. 新人加入：C 输 A 的码 → A、B 不用刷新就看到 C 坐下。
6. 断网：A 关 Wi-Fi 超过 3 秒出现“正在重连…”，开回后消失，状态与 B 一致。
7. 管理：A 长按 B → 移除 → B 自动回到自己的小屋并提示；B 再输 A 的码得到“验证码无效”。A 解散 → 所有成员离开，背包里未使用的码变“已作废”。
8. 退出：B 进入 A 的小屋后从 ⋯ 退出 → A 看到座位空出。
9. `flutter analyze && flutter test` 全绿。

## 9. 环境与配置

1. `env/dev_android.json` 加 `WS_URL`。
2. 真机用 `env/local.json`（已在 `.gitignore`）：`API_BASE_URL` / `WS_URL` 用电脑局域网 IP（占位 `192.168.x.x`，README 说明自行替换）；不提交真实 IP 也可以，提供入库模板 `env/local.example.json`（我的决定：提交 example，`env/local.json` 本来就在 `.gitignore`）。
3. 明文 HTTP：已核实 `android/app/src/debug/AndroidManifest.xml` 设了 `usesCleartextTraffic="true"`，真机连局域网 IP 不用改。
4. 后端监听：后端 `.env` 设 `APP_HOST=0.0.0.0`（`.env.example` 已有说明），不改代码。
5. App 版本：用于 `min_app_version` 比较的版本号通过 `--dart-define`（如 `APP_VERSION`）传入，不新增依赖。

## 10. 名牌的语言标识（用户决定：F2 不做）

PRD F3.4 的“母语国旗标识”在 F2 不做，名牌只显示 👑（房主）与昵称。前端 TRD 11.4 注明此项延后。

## 11. 文档改动（F2 设计确认后一次完成，三份文档 + 变更记录，两个仓库一致）

- **PRD**（升 v1.9）：
  - 第 2.3 节 / 后续版本：新增“养成（第二版）：吃 / 洗 / 睡为养成动作，累积 level；level 越高亲密度越高，解锁更多玩法”；第二版待定项：“睡”作为养成动作与“离线即睡觉”如何区分。
  - F3.3：点他人宠物的反应为“卖萌”等动作；点自己的宠物只在本地播放。
- **前端 TRD**（升 v1.11）：
  - 3 / 10.2 / 10.3 / 16：宠物由 Rive 改为代码绘制（`PetPainter` + `PetSpec`），MVP 姿态 `idle` / `sleep` / `cute`，第二版加 `eat` / `wash`（养成）；正式美术到位前全程代码绘制，接口不变；资源体积预算相应更新。
  - 6.2：`/room/:id` 不单独做，场景在小屋 Tab；`/room/:id/manage` 保留。
  - 7：规则 7（`last_seq` 写 prefs）删除；`roomControllerProvider` 改名 `roomLiveProvider`，F2 只含成员与 presence，打卡与装扮 F4 再加。
  - 9.2：前后台改为“`paused` 立即断开”（对齐 PRD F3.2）；`4001` 不重连；`403 ONBOARDING_REQUIRED` 不重连；强制更新页 F6。
  - 11.4 / 11.6：场景布局、⋯ 菜单、长按弹层、管理页、solo 卡片；名牌的母语国旗标识延后，F2 不做。
  - 19.4：`WS_URL` 在 F2 加入；新增真机环境文件。
  - 20：F2 行写明 F2a / F2b 与验收设备。
- **后端 TRD**（升 v1.13）：只在演进路线（18.3）提一句第二版养成功能，接口不变。

## 12. 留给实现者

- 16 只宠物的具体颜色值、形状细节（守住 6.2 的族与特征、无描边、同一套比例）。
- 背景画法细节与配色（参考样例：暖米色墙、竖条纹、白框窗、木地板、粉色地毯）。
- 名牌、弹层、管理页的具体间距与字号（沿用现有主题）。
- `TokenRefresher` 的抽取方式（保证 REST 与 WS 共用单飞刷新即可）。
