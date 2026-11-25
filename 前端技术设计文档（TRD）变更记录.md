# 前端技术设计文档（TRD）变更记录：PetBridge（Flutter）

> 本文收录《前端技术设计文档（TRD）：PetBridge（Flutter）》每个版本的变更说明，新版本写在最上面。正文只描述当前设计；正文中的“（v1.x 新增）”等标记指向这里对应版本的说明。

---

## V1.14 变更说明

F3 聊天设计定稿，对齐后端 TRD v1.16 与 PRD v1.12；设计见 `docs/superpowers/specs/2026-11-25-f3-chat-design.md`，计划见 `docs/superpowers/plans/2026-11-25-f3-chat.md`。**用户的决定**：① **私聊与小屋通知分开**（11.0、11.4）：每个成员一个单独会话，全屋消息放小屋通知（公告板），二者不混在同一个列表；聊天 Tab 改为会话列表。② **真正的群聊放第二版**。③ **会话历史**由后端消息接口按会话筛选（`scope=room` / `peer_id`）翻页。

**其余由实现者定下**：④ **路由**（6.2）：取消 `/room/:id/chat`，新增 `/room/:id/notice`、`/room/:id/dm/:userId` 两个全屏详情页。⑤ **合并规则**（第 7 章规则 10）：翻译与润色状态分别判断，按 `scope` 归入会话。⑥ **补消息**（第 7 章规则 11）：原来的“用本地最新消息 id 补”会漏消息、漏译文更新和撤回，改为每间房一个 `sync_cursor`、起点回看 10 秒与未定消息、补完后对账。⑦ **网络层**（8.1、8.2）：`IdempotencyInterceptor` / `RetryInterceptor` 不加，幂等以请求体 `client_msg_id` 为准，重试由 outbox 统一负责；新增 `notice_daily` 与 `chat_dm_restricted` 文案，写明可空对象的契约写法。⑧ **本地存储**（第 12 章）：每用户一个库，登出删除、会话过期不删；离开小屋删该房间全部聊天数据；不引入 `connectivity_plus`，补发时机为 WS ready 与回到前台；新增发送结果表；Android 自动备份排除该库。⑨ **未读、短语、润色**（11.4）：放 F3b，未读只存本机，润色开关离开页面即复位。⑩ **降级与联调**（第 18 章、19.5）：“AI 降级”一行去掉重试按钮（与 v1.9 一致），离线不单独判断，联调要另开 `task worker`，新增小屋通知与后台补消息两项。⑪ **排期**（第 20 章）：F3 拆为 F3a 会话与收发、F3b 增强。⑫ 4.3、4.5 的链路图、第 5 章目录、第 7 章 provider、11.6、19.2、21.1 同步更新；文首后端 TRD 版本写为 v1.16、PRD 写为 v1.12。

---

## V1.13 变更说明

对齐后端 TRD v1.15 的 B6b（打卡与装扮）与 PRD v1.11；后端设计见 `docs/superpowers/specs/2026-11-25-b6b-checkin-decor-design.md`。界面在 F4 实现，本次只定接口约定、合并规则与文案。① **状态来源**（11.5）：改为 `room.snapshot` 的 `progress`、`decor`、`checkin_expires_at` 加 REST 响应与 WS 事件；原写的 `GET /rooms/{id}` 后端 v1.4 起就不实现。② **两个事件不带 seq**（4.5、第 7 章规则 3、新增规则 12）：能量取较大、打卡状态取较晚、装扮取并集；快照照旧整体替换。③ **装扮由代码绘制**（5、10.1、10.3、16）：没有美术资源，与宠物、背景一致，不再用 WebP，去掉 `assets/decor/`；剪影由同一套绘制填单色得到。④ **界面行为**（11.5）：打卡按钮与勾都只比较 `checkin_expires_at`，过零点不需要事件；全员奖励不解释规则，只在发奖励时提示；庆祝动画只由 REST 响应触发，解锁动画只由响应与 `decor.unlocked` 触发、快照不触发，避免重复播放；新增装扮列表页。⑤ **文案**（11.5）：九条界面文案与 12 件装扮名称，五种语言，写在 ARB。⑥ 8.2 去掉过时的“（B6 起才会出现）”；第 20 章排期注明后端 B6 完成；文首后端 TRD 版本写为 v1.15、PRD 写为 v1.11。

---

## V1.12 变更说明

对齐后端 TRD v1.14 的 B6a（内容审核、举报与屏蔽）与 PRD v1.10；后端设计见 `docs/superpowers/specs/2026-11-23-b6a-moderation-safety-design.md`。界面在 F4 实现，本次只定接口约定与处理规则。① **`CONTENT_BLOCKED` 两种文案**（8.2、11.1、第 18 章）：发消息被拦（不带 `details`）时气泡标“消息未能送达”，不提供重试、不自动重试（同一条重发仍会被拦），不说明原因，对应 PRD 5.2；onboarding 昵称被拦（`details.fields = ["nickname"]`）时在昵称框下提示“这个昵称不能使用，请换一个”，停在昵称页。新增 `BLOCK_LIMIT`（已屏蔽 500 人）与举报超过每日次数（`RATE_LIMITED`）的文案。② **新事件 `message.removed`**（第 7 章规则 10、第 18 章）：负载只有 `room_id`、`message_id`，表示这条消息对自己已被审核隐藏（只隐藏该语言组或整条撤回），从列表与本地缓存删掉卡片，不弹提示；原文卡片在 `message.new` 时已经显示过，所以这一步必须做。发送者自己不会收到，界面不暴露审核结论。③ **关闭码 4403 不重连**（9.2、第 18 章）：账号被封禁或删除，清空 token、回到登录页并提示“账号已停用”，与 REST 403 `ACCOUNT_DISABLED` 处理相同（后端计划自己拍板的决定第 5 条）。④ **屏蔽与举报的接口约定**（11.4）：`POST /blocks`、`DELETE /blocks/{user_id}`、`GET /blocks`（“我的 → 屏蔽列表”）；屏蔽双向生效、对方无感知、不影响同屋（用户选定的方案 2），屏蔽后刷新消息，对方的消息（含屏蔽前收到的）不再返回，解除后恢复。`POST /reports` 从宠物长按或消息长按进入，举报原因枚举为 `harassment` / `spam` / `sexual` / `self_harm` / `minor_safety` / `other`，`note` 选填且不超过 500 字，每人每天 20 次，重复举报返回同一条；举报后询问是否同时屏蔽（服务端不自动屏蔽）。⑤ 排期（第 20 章）注明后端 B6 拆为 B6a 合规、B6b 养成；第 22 章对应关系加上后端 7.9。⑥ 文首“配套文档”后端 TRD 版本写为 v1.14，“对应 PRD”写为 v1.10。

---

## V1.11 变更说明

F2（实时小屋、宠物绘制与房主管理）设计定稿，对齐 PRD v1.9 与后端 TRD v1.13；详细设计见 `docs/superpowers/specs/2026-11-23-f2-realtime-room-design.md`。后端接口不变。① **宠物由 Rive 改为代码绘制**（3、10.2、10.3、16）：团队暂无美术，16 只宠物用 `PetPainter` + `PetSpec` 画（圆滚滚 Q 版、同一套身体、无描边），MVP 姿态 `idle` / `sleep` / `cute`，第二版加 `eat` / `wash`（养成）；`PetView` 改为 `PetView(petType, pose, size)`，旧调用不用改；不再有 `.riv` 与资源体积预算，正式美术到位后可替换内部实现。WebSocket 也改用 `dart:io` 的 `WebSocket`，不新增依赖。② **不做 `/room/:id`**（6.2）：场景放在小屋 Tab，`/room/:id/manage` 保留。③ **第 7 章**：规则 7 删除（`last_seq` 只存内存，服务端每次订阅都给快照），其余规则编号不变；`roomControllerProvider` 改名 `roomLiveProvider`，F2 只含成员与 presence。④ **9.2**：前后台改为“`paused` 立即断开”，对齐 PRD F3.2“离开 App 时立即睡着”（原写“后台 30 秒后断开”与 PRD 冲突，按 PRD）；`4001` 与 `403 ONBOARDING_REQUIRED` 不重连；强制更新页放到 F6，F2 只停止重连并记日志。⑤ **11.4 / 11.6**：写入场景布局与座位比例、名牌、空位、⋯ 菜单、solo 卡片、轻触与长按弹层、重连提示、管理页；**名牌的母语国旗标识（PRD F3.4）延后，F2 不做**（用户决定，PRD 条文不变）。⑥ **19.4**：加入 `WS_URL` 与 `APP_VERSION`；真机环境文件仍用 `env/local.json`（已在 `.gitignore`），新增入库模板 `env/local.example.json`（局域网 IP 用 `192.168.x.x` 占位）。⑦ **第 20 章**：F2 分 F2a（实时与场景）与 F2b（管理与退出），验收设备为安卓模拟器 + 一台安卓真机。⑧ 顺带改正：11.6 引用 reducer 规则的编号由 5 改为 8（`room.kicked` 是规则 8）；文首“配套文档”后端 TRD 版本写为 v1.13。

---

## V1.10 变更说明

F1（验证码入房、背包与分享海报）设计定稿，对齐后端 TRD v1.10，PRD 不变；详细设计见 `docs/superpowers/specs/2026-11-21-f1-join-backpack-design.md`。① **排期调整**（第 20 章）：onboarding 与占位宠物已在 F0 完成，F1 改为验证码输入、背包、分享海报、小屋 Tab 成员列表；**房主管理（11.6）与退出小屋移到 F2**，与小屋场景一起做。② **`solo` / `inRoom` 不并进会话**（6.1、第 7 章）：会话保持四态，`solo` / `inRoom` 由 `roomsProvider` 派生的 `roomModeProvider` 给出；两者可去的页面相同，并进会话只会让启动等 `/rooms/mine`、并且要处理它失败时会话怎么办。F1 没有 WebSocket，房间数据在进入 `ready`、入房成功、回到前台、下拉刷新时拉取。③ **小屋 Tab 先用成员列表占位**（11.4）：入房结果要能直接看到；接口没有房间名，标题用“我的小屋”或“{房主昵称}的小屋”。④ **路由按实际路径改**（6.2、11.0）：背包 `/home/bag`，分享海报 `/share/:code`。⑤ **输码页细节**（11.0、11.2）：成功态在同一页，没有奖励码时不显示礼盒；`ALREADY_MEMBER` 可跳到该房间；`RATE_LIMITED` 按 `Retry-After` 倒计时；粘贴支持分享链接；冷却倒计时在 App 生命周期内保留。⑥ **背包与海报**（11.0、11.3）：显示绑定小屋人数与剩余有效期，右上角可进输码页；生成验证码显示今日剩余次数（后端 v1.10 新字段 `regen_remaining_today`），为 0 或满员时置灰；海报可保存到相册（`gal`，Android 8–9 需存储权限）与系统分享，对应 PRD F2.5、F2.9。⑦ `SHARE_BASE_URL` 在 F1 加入，先用占位地址（19.4）；F1 的 golden 只做分享海报（19.2）。

---

## V1.9 变更说明

对齐后端 TRD v1.9 的 B5 消息协议与 PRD v1.8。① **原文卡片先到**（4.5②、11.4、第 18 章）：接收者先收到 `message.new`（原文，译文 `pending`，卡片显示“翻译中”骨架屏），翻译结束收到新事件 `message.translated`，润色结束收到 `message.polished`。② **消息事件的 reducer 规则**（第 7 章规则 10）：三种事件都不带 seq，负载都是完整的 `MessageView`，按 `message.id` 插入或更新，与到达顺序无关；delivery 状态只前进不后退。发送者本人也会收到自己的 `message.new`（带 `client_msg_id`），用于替换 outbox 的本地气泡和同步其他设备。③ **重新订阅后补消息**（第 7 章规则 11、9.2、第 12 章）：每次收到 `room.snapshot` 都用 `GET /rooms/{id}/messages?after=<本地最新消息 id>` 补齐；拉取结果一律从旧到新，支持 `before` / `after` 双向翻页。④ **翻译失败不提供手动重试**（11.4、第 18 章、21.1）：卡片显示原文 + “暂无法翻译”，服务端 24 小时内自动重试，成功后自动换成译文。⑤ **润色改为异步**（8.2、11.4）：`POST /deliveries/{id}/polish` 立即返回 202，结果走 `message.polished`，取消原先放宽到 12 秒的超时；按钮只在文本消息、翻译完成、尚未润色时显示；发送时润色次数已用完（`polish_requested=false`）消息照常发出并轻提示。⑥ **新增错误码文案**（8.2）：`QUOTA_EXCEEDED` 按 `details.reason` 分四种，`POLISH_NOT_READY`、`DELIVERY_NOT_FOUND`、`CONTENT_BLOCKED`。⑦ 发消息的幂等以请求体 `client_msg_id` 为准（8.1）；未成年人不显示私聊入口（11.4）；已读延到 B7（21.1）。

---

## V1.8 变更说明

前后端代码审查发现的问题，对齐后端 TRD v1.8，PRD 不变。① **网络不好不再被登出**（8.1）：v1.7 的 `AuthInterceptor` 只要刷新失败就清空 token 并回到登录页，地铁里刷新超时或服务端回 5xx 都会把用户踢下线。现在只有服务端明确拒绝（400 / 401 / 403：`REFRESH_INVALID`、`REFRESH_REUSED`、`ACCOUNT_DISABLED` 等）才结束会话；网络错误与 5xx 保留 token，原请求以这次刷新的失败（如 `NETWORK`）报错，下一个请求或用户重试时再刷新。启动恢复会话时因此显示“可重试”，不会误回登录页。② **两个 token 一次写入**（8.1、第 12 章）：v1.7 分两次写 access 与 refresh，中间被杀会留下“新 access + 已作废的 refresh”，下次刷新被后端当成重放、整族吊销。现在两者以 JSON 存在同一个键 `auth_tokens` 里；旧版本的两个键在第一次读取时迁移并删除。配合后端 v1.8 的 60 秒重试宽限，刷新响应在路上丢失也不再导致登出。③ **新增 `err_NOT_READY` 文案**（8.2）：后端在服务重启或 Google 公钥暂时不可达时返回 503 `NOT_READY`，界面提示“服务暂时不可用，请稍后重试”，不再落到通用错误文案。

---

## V1.7 变更说明

对齐 PRD v1.7 与后端 TRD v1.7（新增 10.3 MBTI 语气重构逻辑）。语气怎么改完全由服务端决定，前端不实现任何 MBTI 改写规则，也不在界面上展示接收方的 MBTI。前端只有一处变化：`message.polished` 新增 `polish_status`（`done` / `fallback`）；`fallback` 表示润色结果没通过服务端校验，润色文本为空，信使卡片继续显示基础译文，“AI 润色译文”一栏标“未润色”且不再显示“让 AI 润色”按钮（11.4、第 18 章）。MVP 只有“轻”档润色，输入栏的“AI 润色”开关不变，不需要档位选择。

---

## V1.6 变更说明

F0 在模拟器上端到端联调后，补齐实现中定下的细节，与后端 TRD v1.6 同步，PRD 不变。① **界面语言的取值顺序**：本地保存的选择 → `/me` 的 `native_lang` → 系统语言；退出登录清除本地选择、回到系统语言，再次登录按 `native_lang` 恢复（11.1、第 13 章）。② **启动时恢复会话**：拉 `/me` 遇到网络错误或 5xx 时保留令牌，启动页显示错误文案与“重试”；其他失败（如刷新令牌失效）清除令牌、回登录页（6.1、6.2）。③ **Google 登录**：用户取消或设备上没有 Google 账号时静默留在登录页，不显示错误；其他失败显示 `err_GOOGLE_SIGN_IN_FAILED`（6.2）。④ 设备返回的时区不是 IANA 名（如模拟器的 `GMT`）时，onboarding 提交 `UTC`（11.1）。⑤ Onboarding 进度条共 5 步，测试与结果页算第 3 步，直接选 MBTI 时跳过第 3 步（11.1）。⑥ 契约约定：openapi 3.0.3 中可空的枚举字段必须把 `null` 写进枚举值，否则生成的模型解析不了未 onboarding 用户的 `/me`（8.2）。⑦ 界面组件库 `material_ui` 的本地化需用它自己的 `GlobalMaterialLocalizations.delegates`，不能用 `gen-l10n` 默认带的 `flutter_localizations` 代理，否则非英文下顶部栏报错（第 13 章）。

---

## V1.5 变更说明

对齐后端 TRD v1.5（B4 安全加固），PRD 不变。① 服务端在升级所用 access token 到期时以关闭码 **4401** 断开连接：客户端收到后先刷新 token，再**立即**重连，不走退避（9.2）。前端本来就在 token 剩余不足 60 秒时先刷新再连，所以正常情况下 4401 后的重连在 3 秒内完成，不会出现“正在重连”提示。② 升级请求可能返回 HTTP 429 `RATE_LIMITED`（按 `Retry-After` 等待后重连）或 503 `NOT_READY`（服务重启中，按 `server.restart` 的随机等待处理）（9.2）。③ `room.sub` 每连接每 10 秒最多 10 次，超出会收到 `error{RATE_LIMITED}`；缺口触发的重新订阅要合并，同一房间 1 秒内不重复订阅（第 7 章 reducer 规则 2、5）。

---

## V1.4 变更说明

对齐 PRD v1.6 与后端 TRD v1.4（B4 WebSocket 协议定稿，详见后端仓库 `docs/superpowers/specs/2026-11-17-b4-realtime-design.md`）。① **reducer 以订阅快照为准**（4.5③、第 7 章）：每次 `room.sub` 服务端都下发完整 `room.snapshot`，客户端用它整体替换房间状态，并把 `last_seq` **设为**快照的 seq（不取较大值，Redis 重启后 seq 会从头开始）；之后丢弃 seq ≤ `last_seq` 的事件，不带 seq 的事件直接应用，成员事件按 `user_id` 幂等；发现缺口或收到 `resync` 时对该房间重新发 `room.sub`，不再拉 `GET /rooms/{id}`（后端 MVP 不实现该接口）（9.2）。② **presence 只有 online / offline**：离线成员的 `PetView` 显示为睡觉（`mood=3`），收到 `presence.update` 立即切换，用户回到 App 时同屋的人立刻看到他的宠物醒来（10.1）；`member.joined` 自带新成员的 presence。③ `room.kicked` 新增 `reason=left`（自己在另一台设备上退出），处理与被移除相同但不提示；新增 `error` 帧与 `room.unsub`（第 7 章）。④ `WS_URL` 改为 `ws://10.0.2.2:8090/api/v1/ws`，与 REST 同一基础路径（19.4）。⑤ 订阅范围写明：连接后订阅自己所有在席房间（自己的 + 已加入的）（6.1）。

---

## V1.3 变更说明

对齐 PRD v1.5 与后端 TRD v1.3，前端 F0（登录与 onboarding）设计定稿，详见 `docs/superpowers/specs/2026-11-16-f0-login-onboarding-design.md`。① **契约生成改用 `swagger_parser`**（纯 Dart，无需 Java），替代 `openapi-generator` dart-dio（第 3 章、8.2）。② **环境先只建 dev**：暂不建 staging / prod flavor 与多入口，只用一个 `main.dart` + `--dart-define-from-file`；新增 `GOOGLE_SERVER_CLIENT_ID`、`APPLE_LOGIN_ENABLED` 两个键；本地后端端口改为 **8090**（与后端 `.env` 一致）（19.4、19.5）。③ **feature 内按需建层**：本地模型先放在用到它的 `application/`，出现跨 feature 共用时再建 `shared/models/`（第 5 章）。④ **首页底部导航改为四个 Tab：小屋 / 聊天 / 背包 / 我的**，场景与聊天分开，与常见社交 App 一致（11.0 线框、6.2 路由、11.4）。⑤ Onboarding 写入 4 道测试题、每个维度可手动翻转确认、“未满 13 岁”独立说明页（11.1、6.2）；会话状态在小屋阶段之前先用 `unknown / unauthenticated / needsOnboarding / ready` 四态（6.1）。⑥ **Apple 登录延后**：目前没有 Mac 与 Apple 开发者账号，F0 只做按钮与接口层（`APPLE_LOGIN_ENABLED=false`），上架 iOS 前必须补齐（第 20 章、21.1）。⑦ Android `applicationId` 定为 `io.github.jinheng0301.petbridge`，`minSdk 26`；Google 登录用 `google_sign_in` v7，`serverClientId` 为 Web 客户端 ID（第 3 章、15 章前）。⑧ 联调与测试去掉 docker compose，改为本机原生 PostgreSQL + Memurai 与 go-task；worker 尚未实现（19.2、19.5、21.2）。⑨ 背包状态“已满员作废”改为“已作废”（满员与解散都会作废）；错误处理补 `ROOM_NOT_FOUND`、`ONBOARDING_REQUIRED`、`ALREADY_MEMBER` 直接进房（11.3、第 18 章）。⑩ 宠物资源与 `PetView` 改按 `pet_type`（如 `happy_shiba`）命名，不再按 MBTI：后端成员信息只下发 `pet_type`（4.6、第 5 章、10.1、10.2、21.1）。其余章节（WebSocket 客户端、小屋渲染、本地存储、性能与安全）不变。

---

## （2026-11-14 结构调整，无功能变更）

第 4 章“总体架构”扩写为 4.1～4.6：新增 mermaid 总览图、分层职责与依赖规则、MVVM 对应、三条关键链路时序图（启动与会话判定 / 发送消息 / WS 事件入站）、子系统解耦说明；第 5 章“项目目录结构”改为 feature-first 且 feature 内按 `data / application / presentation / models` 分层，新增 `config/`、`shared/`（通用组件与共用模型）、`app/router`、`app/event_reducer`，并给出与常见前端分层的对照表；新增 11.0“界面总览与线框大纲”。`core/config/env.dart` 调整为 `config/env.dart`（19.4 同步）。

---

## V1.2 变更说明

对齐 PRD v1.4 与后端 TRD v1.2。① **修复会话状态机**（6.1、第 7 章）：V1.1 中只有"自己加入他人房间"才会从 `solo` 进入 `inRoom`，且 `solo` 状态不连接 WebSocket——朋友加入了你的小屋，你却收不到 `member.joined`、看不到小屋，最关键的邀请链路会直接坏掉。现改为 `solo` / `inRoom` 由房间数据派生（任一在席房间的成员数 > 1 即为 `inRoom`，全部回到 1 人时退回 `solo`，双向可切换），WebSocket 在完成 onboarding 后即连接并订阅自己的小屋，回到前台时再调用一次 `GET /rooms/mine` 校正。② **新增房主管理界面**（新增 11.6 节、6.2 新增 `/room/:id/manage` 路由）：移除成员、解散、自助补码，房主在自己的小屋里不显示"退出小屋"；被移除或被解散的一方收到 `room.kicked` 后退回首页、清除该房间的本地消息缓存与 `last_seq`，只提示"你已离开该小屋"，不展示原因与操作者（第 7 章 reducer 新增规则 5，第 18 章补充降级体验）。③ 极简测试确定为 4 题（每维度 1 题），PRD 已同步，11.1、21.1 去掉"待确认"。④ 错误码展示新增 `ROOM_LIMIT`、`NOT_ROOM_OWNER`、`OWNER_CANNOT_LEAVE`、`CODE_ISSUE_LIMIT`（后者按 `details.reason` 区分四种文案）。⑤ Widget 刷新对齐后端新增的 `widget.refresh` data-only 推送，并通过 `PUT /devices/current` 上报 `widget_installed`（14.2）；iOS 对静默推送有系统节流，不保证送达，Widget 上继续标注更新时间。⑥ 联调清单（19.5）补充房主移除成员、解散与补码、别人加入我的小屋三个场景。其余章节（网络层、WebSocket 客户端、小屋渲染、本地存储、i18n、性能与安全）不变。

---

## V1.1 变更说明

暂不首发中国大陆；新增 MVVM 架构说明；强制更新接口已与后端对齐。
