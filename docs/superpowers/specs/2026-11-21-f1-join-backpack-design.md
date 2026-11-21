# F1 验证码入房、背包与分享海报设计

> 日期：2026-11-21 · 对应前端 TRD v1.9 第 20 章 W3–4 的 F1 · 后端依赖 B3（已完成）与一个小改动（第 10 节）· 状态：已确认（2026-11-21）

## 1. 目的

让一个已完成 onboarding 的用户能**用验证码住进别人的小屋**，并且能在背包里**查看、生成、分享自己的验证码**，在 Android 上把 M1“核心机制跑通”走一遍：A 注册得到验证码 → 分享给 B → B 输入后进入 A 的小屋并获得自己的奖励码 → 两人都看到小屋里有对方。

用户最在意的是**能亲眼看到结果**：入房前后页面要有明显不同，不能只靠一句提示。所以 F1 的小屋 Tab 先用一个简单的成员列表展示房间，F2 再把列表换成真正的小屋场景。

## 2. 范围

**做**

- **验证码输入页 `/join`**：8 位输入、粘贴按钮、各错误码独立文案、冷却与限流倒计时、成功页揭晓奖励码。
- **背包 Tab**：验证码列表（状态、绑定小屋人数、剩余有效期）、分享入口、房主“生成验证码”并显示今日剩余次数（PRD F2.9）、右上角“输入验证码”入口。
- **分享海报 `/share/:code`**：1080×1440 PNG，含宠物、验证码、人数、二维码；可**保存到相册**，也可通过系统分享面板分享（PRD F2.5）。
- **小屋 Tab**：`solo` 显示自己的宠物与“输入验证码”入口；`inRoom` 显示房间成员列表，在两间房里时可以切换。
- **房间数据**：`GET /rooms/mine` 决定 `solo` / `inRoom`，在启动、入房成功、回到前台、下拉刷新时更新。
- **配置**：新增 `SHARE_BASE_URL`，先用占位地址。
- **网络层小改**：`RATE_LIMITED` 的 `Retry-After` 响应头写进 `AppFailure.details`。
- **后端配套**：`GET /rooms/mine` 的自己小屋增加 `regen_remaining_today`（第 10 节）。

**不做（移到 F2 或更后）**

- **房主管理与退出小屋**（移除成员、解散、退出）——**用户决定移到 F2**，与小屋场景一起做。接口在 B3 已有，前端 F1 不调用。
- WebSocket（F2）：F1 里“别人加入了我的小屋”不会实时出现，要等回到前台或下拉刷新。
- 小屋场景、座位、宠物动画（F2）。
- App Links / 深链配置（F5）：F1 只让 `/join?code=` 能预填。
- 埋点、推送、真实域名、iOS。

**反目标**（技术上能跑但算失败）

- 客户端自己判断验证码能不能用（只做格式预校验，结论以服务端为准）。
- 显示服务端的 `error.message`。
- 输错后清空用户已输入的内容。
- 页面打开时自动读剪贴板。
- 手写接口模型（必须用 `lib/gen/` 里的生成代码）。

## 3. 做法选择

小屋 Tab 显示什么（用户已选 A）：

| 做法 | 内容 | 取舍 |
| :-- | :-- | :-- |
| **A. 列表占位（已选）** | solo 显示自己的宠物 + 解锁入口；inRoom 显示成员列表与房间切换 | 入房结果肉眼可见，M1 可验收；列表在 F2 会被场景替换 |
| B. 继续“即将开放” | 只在背包放入口，入房成功只弹提示 | 工作量最小，但入房后界面没有变化，无法验收 |

`solo` / `inRoom` 放在哪里（用户已选甲）：

| 做法 | 内容 | 取舍 |
| :-- | :-- | :-- |
| **甲. 房间状态单独成 provider（采用）** | `SessionReady` 不变；新增 `roomsProvider`（拉 `/rooms/mine`）和派生的 `roomModeProvider`（`solo` / `inRoom`）；小屋 Tab 读它 | 房间请求失败不影响登录与路由；router 不需要改，因为 solo 与 inRoom 可去的页面完全一样 |
| 乙. 照 TRD 6.1 并进 `sessionProvider` | `SessionReady` 拆成 `SessionSolo` / `SessionInRoom` | 启动和登录要等 `/rooms/mine` 返回才能出首页，房间接口失败还要决定会话怎么办；redirect 对两者规则相同，拆开没有收益 |

采用甲，TRD 6.1 / 第 7 章同步改写（见第 13 节）。

## 4. 目录（按需建层，沿用 F0 规则）

```
lib/features/
├── room/
│   ├── data/room_repository.dart          # listMine()
│   ├── application/rooms_provider.dart    # roomsProvider、roomModeProvider、selectedRoomProvider
│   └── presentation/room_tab.dart         # solo / inRoom 两种视图
├── invite/
│   ├── data/invite_repository.dart        # join()、listCodes()、regenCode()
│   ├── application/
│   │   ├── invite_code.dart               # 规范化、格式化、校验（纯函数）
│   │   ├── join_controller.dart           # 输入、提交、冷却倒计时、结果
│   │   └── codes_provider.dart            # 背包列表、生成验证码
│   └── presentation/
│       ├── join_page.dart                 # 输入态 + 成功态
│       ├── bag_tab.dart
│       ├── share_page.dart
│       └── widgets/(code_field、code_tile、poster_canvas)
```

`room/` 在 F2 继续加场景与房主管理；`invite/` 与 TRD 第 5 章一致。

## 5. 数据与状态

### 5.1 房间（`roomsProvider`）

- `AsyncNotifier<List<RoomDetail>>`，在会话为 `SessionReady` 时拉 `GET /rooms/mine`；会话变成其他状态时清空。
- 刷新时机：进入 `SessionReady`（登录、恢复会话、完成 onboarding）；入房成功；App 回到前台（`AppLifecycleListener.onResume`）；小屋 Tab 下拉刷新。刷新失败时保留旧数据，只在没有数据时显示错误与“重试”。
- `roomModeProvider`：任一房间 `member_count > 1` → `inRoom`，否则 `solo`（与 TRD 6.1 判定一致）。
- `selectedRoomProvider`：当前在小屋 Tab 显示哪一间。默认取第一间 `member_count > 1` 的房间（接口已把自己的小屋排在最前）；入房成功或 `ALREADY_MEMBER` 跳转时设为那一间；所选房间消失时回到默认。只存在内存里。

### 5.2 背包（`codesProvider`）

- `AsyncNotifier<List<CodeListItem>>`，拉 `GET /codes`（接口已按新到旧排序，`status` 已是有效状态）。
- 刷新时机：首次进入背包；入房成功（可能有奖励码）；生成验证码成功；回到前台；下拉刷新。
- `regen()`：用 `roomsProvider` 里 `is_owner == true` 的房间 id 调 `POST /rooms/{id}/codes`，成功后刷新背包列表与 `roomsProvider`（拿到新的 `regen_remaining_today`）。

### 5.3 输码（`joinControllerProvider`）

- 状态：`input`（规范化后的 0–8 位字符）、`submitting`、`failure`（`AppFailure?`）、`blockedUntil`（`DateTime?`）、`result`（`JoinResult?`）。
- **冷却与限流跨页面保留**：controller 在 App 生命周期内保持（`keepAlive`），离开再回来仍显示剩余倒计时；输入内容在离开页面时清空，`blockedUntil` 保留。
- 倒计时用注入的时钟（测试可控），每秒刷新一次显示，到点自动解除禁用。

## 6. 页面

### 6.1 小屋 Tab

- **solo**：大号 `PetView`（自己的 `pet_type`）、昵称 · MBTI、“你的宠物正在等新朋友”，下面一个虚线框“小屋还没解锁 · 输入朋友的验证码，或把你的验证码分享出去”，按钮“输入验证码”→ `/join`。
- **inRoom**：
  - 在两间房里时，顶部是分段切换；只有一间时不显示切换。
  - 房间标题：自己的小屋叫“我的小屋”，别人的叫“{房主昵称}的小屋”（房主即 `role == owner` 的成员；昵称为空时叫“朋友的小屋”），后面带人数 `3/5`。**接口没有房间名，这是我的决定。**
  - 成员按 `seat_no` 排列：小号 `PetView`、昵称（自己显示“我”）、房主带“房主”标签。MBTI 不在成员信息里，**不显示**（线框里画了，实际接口没有这个字段）。
  - 下面一行“还有 N 个空位”；自己的小屋未满时显示“邀请朋友”按钮 → 切到背包 Tab。
  - 没有“管理 / 退出”入口（F2）。
- 加载中显示骨架；首次加载失败显示错误文案 + “重试”。

### 6.2 验证码输入页 `/join`

- **输入规则**：输入时自动转大写，去掉空格与连字符，只保留字符集 `2-9 A-H J-N P-Z`（共 32 个），最多 8 位；显示时在第 4 位后加 `-`。8 位齐全且匹配 `^[2-9A-HJ-NP-Z]{8}$` 时“加入小屋”才可点。
- **粘贴按钮**：读剪贴板一次，规范化后填入（超出 8 位截断）。如果粘贴的是分享链接（含 `/j/{code}`），取链接里的码。**取链接是我的决定。**
- **`/join?code=`**：参数先用正则校验，合法才预填，否则忽略。
- **错误**：显示在输入框下方，不清空输入。

| 错误 | 文案方向 | 额外处理 |
| :-- | :-- | :-- |
| `CODE_INVALID` | 验证码无效或已失效 | — |
| `ROOM_FULL` | 这个小屋已经满员了 | — |
| `ALREADY_MEMBER` | 你已经在这个小屋里了 | 按钮“去小屋看看”，按 `details.room_id` 选中该房间并回到小屋 Tab |
| `AGE_RESTRICTED` | 未成年人与成年人不能住同一个小屋 | — |
| `ROOM_LIMIT` | 你已经在 2 间小屋里，请先退出一间 | F1 还没有退出入口，文案先这样写 |
| `CODE_COOLDOWN` | 尝试次数过多，请 mm:ss 后再试 | `details.retry_after_seconds` 倒计时，输入框、粘贴、按钮全部禁用 |
| `RATE_LIMITED` | 同上 | 用 `Retry-After` 响应头倒计时；没有该头时只显示文案、不禁用 |
| 其他 | `localizedError` 通用文案 | — |

- **成功**：同一页切到成功态，标题“欢迎入住！”，“你加入了 {房主昵称}的小屋”。
  - `rewards` 非空时显示礼盒卡片，列出奖励码（`XXXX-XXXX`）与“分享给朋友，让他们住进你的小屋”；按钮“去分享”→ 第一个奖励码的 `/share/:code`。
  - `rewards` 为空时（例如同一房间的奖励已领过）不显示礼盒，只有“去小屋看看”。
  - “去小屋看看”→ 选中刚加入的房间，回到小屋 Tab。
  - 成功后刷新 `roomsProvider` 与 `codesProvider`。重复提交同一个已成功的码会再次得到 200 与原来的奖励，照样显示成功页。
  - 礼盒动效先用简单的缩放 + 淡入，正式动效等美术。

### 6.3 背包 Tab

- 顶部栏标题“背包”，右上角“输入验证码”→ `/join`。
- 列表每项：验证码（`XXXX-XXXX`，等宽字体）、状态标签（未使用 / 已使用 / 已过期 / 已作废）、绑定小屋的当前人数“小屋 3/5”（取自该码的 `room`，对应 PRD F2.4）、未使用的显示剩余有效期（≥1 天显示“还剩 N 天”，不足 1 天显示“还剩 N 小时”，不足 1 小时显示“即将过期”）和“分享”按钮。来源（注册 / 入房奖励 / 自己生成）不显示。
- 底部“＋ 生成验证码”：
  - 按钮下方显示“今天还可以生成 N 次”（自己小屋的 `regen_remaining_today`）；为 0 时按钮置灰，提示“今天的生成次数已用完”。
  - 自己的小屋满员（`status == full`）时置灰，下方提示“小屋已满，先腾出空位”（优先于次数提示）。
  - 其他拒绝原因（已有足够未使用、总数上限）前端无法提前知道，点了再按服务端结果提示。
  - 点击后成功：列表刷新，新码在最上面，SnackBar“已生成新的验证码”。
  - 失败 `CODE_ISSUE_LIMIT` 按 `details.reason` 显示：`room_full` 小屋已满；`enough_unused` 你已经有足够的未使用验证码，先分享它们吧；`daily_limit` 今天的生成次数已用完；`lifetime_limit` 已达到可生成的上限。其他错误用通用文案。
- 空列表显示“还没有验证码”；下拉刷新；首次加载失败显示“重试”。

### 6.4 分享页 `/share/:code`

- 从 `codesProvider` 找到该码；找不到或已不是“未使用”时显示“这个验证码不能再分享了”和返回按钮。
- 页面上按比例缩小展示海报，下方两个按钮：“保存到相册”与“系统分享”。
- **海报内容**（逻辑尺寸 360×480，导出时 `pixelRatio: 3` 得到 1080×1440）：自己的 `PetView`、标题“来我的小屋玩吧！”、验证码 `XXXX-XXXX`、“小屋 {member_count} / {capacity} 人”（取自该码的 `room`）、二维码，内容是 `{SHARE_BASE_URL}/j/{code}`，code 不带连字符。
- **导出**：海报包在 `RepaintBoundary` 里，等这一帧布局完成后 `toImage` → PNG 字节，两个按钮共用。使用系统字体。
  - **系统分享**：PNG 写入临时目录 → `share_plus` 分享文件，附文字“来我的小屋玩吧！验证码 XXXX-XXXX {链接}”。
  - **保存到相册**：用 `gal` 写入系统相册，成功后 SnackBar“已保存到相册”。Android 10 及以上不需要权限；Android 8–9 需要 `WRITE_EXTERNAL_STORAGE`（Manifest 里用 `maxSdkVersion="28"` 限定），首次保存时由 `gal` 请求，用户拒绝时提示“需要相册权限才能保存”。
- 新增依赖：`qr_flutter`（二维码）、`share_plus`（系统分享）、`path_provider`（临时文件）、`gal`（保存到相册）。

## 7. 路由

| 路径 | 页面 | 说明 |
| :-- | :-- | :-- |
| `/home` | 小屋 Tab | F0 是占位，F1 换成 `RoomTab` |
| `/home/bag` | 背包 Tab | F0 是占位，F1 换成 `BagTab`（TRD 原写 `/codes`，按 F0 实际路径改） |
| `/join` | 输码页 | 全屏，盖在 Tab 上方；支持 `?code=` |
| `/share/:code` | 分享页 | 全屏；`:code` 先用正则校验 |

`redirectFor` 的 `SessionReady` 分支放行 `/home*`、`/join`、`/share/*`；其他会话状态不变。

## 8. 网络层

- `ErrorMapInterceptor`：429 且带 `Retry-After`（整数秒）时，把它写进 `AppFailure.details['retry_after_seconds']`，与 `CODE_COOLDOWN` 的字段同名，页面统一读这一个键。
- 新增错误码文案：`CODE_INVALID`、`ROOM_FULL`、`ALREADY_MEMBER`、`AGE_RESTRICTED`、`ROOM_LIMIT`、`CODE_COOLDOWN`、`CODE_ISSUE_LIMIT`（四种 reason）、`ONBOARDING_REQUIRED`。

## 9. 环境配置

`env/dev_android.json` 新增 `"SHARE_BASE_URL": "https://petbridge.example.com"`（占位，上线前换成真实域名）；`Env.shareBaseUrl` 读取，去掉末尾的 `/` 后拼 `/j/{code}`。

## 10. 后端配套：今日剩余补码次数

PRD F2.9 要求显示今日剩余次数，但 B3 的接口只在用完时返回 `daily_limit`，没有这个数字（用户决定由后端补字段）。

- **字段**：`RoomDetail` 新增 `regen_remaining_today`（integer，nullable）。只对 `is_owner == true` 的房间给出，值为 `max(0, OWNER_REGEN_DAILY_LIMIT − 房主在自己时区今天已补码的次数)`，与 `regenBlocked` 用同一套 `LocalDayBounds` 与 `CountRegenBetween` 计算；别人的小屋为 `null`。
- **只反映每日次数**，不反映满员、已有足够未使用、总数上限，这些仍以 `POST /rooms/{id}/codes` 的结果为准。
- **改动范围**（后端仓库）：`api/openapi.yaml`、`RoomDetail` 模型与 `GET /rooms/mine` 的组装、对应测试；后端 TRD 7.8 / 第 8 章写入该字段。改完后前端重新生成 `lib/gen/`。
- **注意**：后端仓库目前有 B5a 进行中、尚未提交的改动（其中也改了 `api/openapi.yaml`），这个补字段要在后端单独做、单独提交，避免混进 B5a。
- 前端顺序：背包的其他部分不依赖它，可以先做；“今日剩余次数”一项在后端字段合入、重新生成客户端之后再接上。

## 11. 多语言

ARB 五种语言新增：小屋 Tab、输码页、成功页、背包、分享页、上述错误码。`en` 与 `zh-Hans` 由我写；`ja`、`ko`、`zh-Hant` 先用 AI 初译，标记待校对（同 F0）。

## 12. 测试

- **单元**：验证码规范化 / 格式化 / 校验（大小写、空格、连字符、非法字符、超长、链接提取）；`roomModeProvider` 派生（无房间、只有自己、自己房间 >1、加入他人）；`selectedRoomProvider` 默认与回退；`joinController` 各错误码的状态、冷却倒计时到点解除（假时钟）、离开页面后冷却保留；剩余有效期格式化；`CODE_ISSUE_LIMIT` reason 映射；拦截器读取 `Retry-After`；`redirectFor` 放行新路由。
- **Widget**：输码页（不足 8 位不可点、出错保留输入、冷却禁用、成功有 / 无奖励两种）；小屋 Tab（solo、inRoom 单间、两间切换、首次失败重试）；背包（四种状态标签、小屋人数、今日剩余次数及为 0 时置灰、满员时置灰、生成失败文案）；分享页（码不可用时的提示、保存成功与权限被拒的提示）。
- **Golden**：TRD 19.2 要求输码页错误态与分享海报的 golden。Windows 上字体渲染与 CI 不一致，F1 先只做海报的一张 golden，用测试字体；其余以 widget 测试覆盖。**这是我的决定。**
- **手动端到端**（Android 模拟器 + 本地后端 `task seed`）：开发登录种子用户 A → 小屋 Tab 为 solo；B 输入 A 的码 → B 进入 inRoom、看到礼盒奖励码；A 回到前台或下拉刷新后变成 inRoom；`FULL2345` 得到 `ROOM_FULL`；连输 5 次错码出现冷却倒计时；种子用户 F 输成年人的码得到 `AGE_RESTRICTED`；背包生成验证码与四种拒绝原因中能触发的几种；分享页弹出系统分享面板，导出的 PNG 是 1080×1440；“保存到相册”后在相册里能看到海报；连续生成到每日上限，剩余次数从 3 降到 0 且按钮置灰。

## 13. 三份文档的同步修改

前端 TRD 升到 v1.10，后端 TRD 升到 v1.10（只为 `regen_remaining_today`）；PRD 不变（F2.5 保存、F2.9 剩余次数都按原要求做到）。改完后两个仓库的三份文档及变更记录保持一致。

**后端 TRD**：7.8 自助补码与第 8 章 `GET /rooms/mine` 写入 `regen_remaining_today` 的含义与计算方式。

**前端 TRD**：

- **第 20 章**：F1 一行改为“验证码输入、背包、分享海报、小屋 Tab 成员列表（F2 换成场景）”（onboarding 与占位宠物已在 F0 完成）；**房主管理（11.6）与退出小屋归入 F2**。
- **6.1 / 第 7 章**：`solo` / `inRoom` 由 `roomsProvider` 派生的 `roomModeProvider` 给出，不并进 `sessionProvider`；redirect 只看 `SessionReady`。F2 接入 WebSocket 后，`member.joined` 等事件同样更新 `roomsProvider`。
- **6.2 路由表**：背包为 `/home/bag`，分享页为 `/share/:code`，`/join` 不变。
- **11.0 线框**：背包右上角加“输入验证码”；补输码成功页。
- **11.2**：补 `RATE_LIMITED` 用 `Retry-After` 倒计时、`ALREADY_MEMBER` 跳到该房间、粘贴支持分享链接、成功页无奖励时不显示礼盒、冷却跨页面保留。
- **11.3**：海报同时提供保存到相册（`gal`，Android 8–9 需存储权限）与系统分享；背包项显示绑定小屋人数；剩余有效期的显示规则；生成验证码显示今日剩余次数，为 0 或满员时置灰。
- **19.4**：`SHARE_BASE_URL` 在 F1 加入，先用占位地址。
- **19.2**：F1 golden 只做海报。

## 14. 留给实现者

- 礼盒与入房动效：简单的缩放 + 淡入即可。
- 分段切换、标签、卡片样式用 Material 3 组件，跟随现有主题色。
- ARB key 沿用 F0 的命名（`room_*`、`join_*`、`bag_*`、`share_*`、`err_*`）。
- 两个开发者账号的切换：用开发登录退出再登录即可，不需要额外工具。
