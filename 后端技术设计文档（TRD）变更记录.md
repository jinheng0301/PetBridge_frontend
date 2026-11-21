# 后端技术设计文档（TRD）变更记录：PetBridge

> 本文收录《后端技术设计文档（TRD）：PetBridge》每个版本的变更说明，新版本写在最上面。正文只描述当前设计；正文中的“（v1.x 新增）”等标记指向这里对应版本的说明。

---

## V1.9 变更说明

B5（消息收发与 AI 网关）设计定稿，对齐 PRD v1.8 与前端 TRD v1.9，详细设计见 `docs/superpowers/specs/2026-11-21-b5-messaging-ai-gateway-design.md`。① **落库即推原文卡片**（4.5②、7.4、第 9 章）：原写法是翻译完成才发 `message.new`，AI 一慢接收者就什么都看不到，与 12.2“先发原文卡片”和前端的“翻译中”骨架屏矛盾。现在消息落库后立即给每个接收者和发送者本人发 `message.new`，翻译结束发新事件 `message.translated`，润色结束发 `message.polished`。三者共用 `MessageView` 结构、都不带 seq、只投给订阅了该房间的连接，客户端按消息 id 插入或更新，delivery 状态只前进不后退。② **断线后从数据库补消息**（7.3、7.4、第 11 章）：`GET /rooms/{id}/messages` 支持 `before` / `after` 双向游标，重新订阅后用 `after` 补齐；删除 B4 留待评估的 Redis Stream `room:{rid}:events`。③ **供应商定为 Gemini 主力 + Claude 备用**（第 3 章、10.1、10.2、15.4）：都用官方 Go SDK，主备顺序由 `AI_PRIMARY` 决定，模型名都在环境变量里；Claude 默认用 `claude-haiku-5-5`。Gemini 免费层的数据会被 Google 用于改进产品，只能用于开发，production 下 `GEMINI_FREE_TIER` 必须为 false。**不接机器翻译兜底**，删除 `pkg/mt` 与 `MT_FALLBACK_API_KEY`、`LLM_PRIMARY_*`、`LLM_SECONDARY_*`。④ **翻译失败自动重试**（7.4、12.2）：都失败时 `translation_status = failed`，卡片显示原文 + “暂无法翻译”，不提供手动重试；asynq 重试 3 次后，由 worker 的补偿扫描每 10 分钟再试，24 小时后放弃。补偿扫描同时捡起停住的 `pending` 翻译与润色。⑤ **Redis 不可用时消息照常翻译**（4.1、7.4、12.2）：无法入队时 api 在本进程内有上限地翻译，结果经 B4 的本机兜底推送。⑥ **预算与配额**（10.2、第 11 章）：翻译与润色的估算成本都累加进 `ai:cost:{yyyymmdd}`；超过日预算关闭润色，超过 2 倍连翻译也停止；发送方润色开关每条消息扣 1 次，失败不退；润色总开关先用 `AI_POLISH_ENABLED`（B5 不建 `app_config`）。⑦ **接口与错误码**（第 8 章）：新增 `DELIVERY_NOT_FOUND`（404）、`POLISH_NOT_READY`（409）、`QUOTA_EXCEEDED` 的 `details.reason`、`CONTENT_BLOCKED` 定为 422；短语接口版本相同返回 304；已读接口移到 B7。⑧ **表结构**（6.1）：`deliveries` 增加 `translation_status`、`translate_attempts`、`polish_by`、`created_at`、`updated_at`，`messages` 增加 `phrase_id`、`polish_requested`；迁移 0004（B5a）、0005（B5b，`ai_usage_daily`）。⑨ 源语言取发送者母语，不做语言识别；纯 emoji 或标点的文本不翻译（7.4）。⑩ 第 17 章 B5 拆为 B5a（消息与翻译）、B5b（润色与成本）；15.5 本地运行加 `task worker`、冒烟步骤更新；16、18 章补充测试、假设与风险。

---

## V1.8 变更说明

前后端代码审查发现的问题，对齐前端 TRD v1.8，PRD 不变。① **refresh token 重试宽限**（7.1、第 13 章）：轮换后的旧 refresh token 在 **60 秒内**再次出现、且所在 token 族里仍有可用 token 时，视为客户端没收到或没存下上一次轮换的响应（超时、存储写一半时 App 被杀），返回一对新 token，并吊销该族其余所有可用 token，保证同一族始终只有一个可用 token；超过 60 秒、或该族已登出/已被判定盗用，仍按重放处理（吊销整族，`REFRESH_REUSED`）。并发用同一个旧 token 刷新时按行锁排队，每个请求都成功，最后一个留下。② **Google 公钥拉取失败返回 503 `NOT_READY`**（7.1、第 8 章）：此前 JWKS 下载失败和签名错误一样回 401，客户端会当成“登录被拒”；现在区分开，前端提示“服务暂时不可用，请稍后重试”。③ **`ROOM_CAPACITY` 生效**（7.1、15.4）：此前该变量只写在配置里，代码从未读取，房间容量始终是建表默认值 5。现在 onboarding 新建小屋时使用它，取值 2–5（`room_members.seat_no` 只有 1–5 号座位），超出范围启动即报错；只影响之后新建的小屋。分配座位时按房间自己的容量取座位号，不再写死 5。④ **注册邀请码的过期时间截到微秒**（7.1）：与奖励码、补码一致，首次 onboarding 的响应与之后幂等重放返回的 `expires_at` 完全相同。⑤ **进程崩溃后补发离线**（7.3、第 11 章）：v1.4 的已知局限是节点被强杀时不广播 `offline`。现在每个节点每 35 秒（presence TTL 的一半）扫描一次 `presence:u:*`，清掉已过期的连接；谁清掉了某用户最后一条连接，谁就向他的室友广播 `offline`（一次清理只有一个节点能删到，所以只广播一次）。为此 `presence:u:{uid}` 键本身的 TTL 改为 140 秒（成员仍是 70 秒），查询在线状态时不再顺手清理过期成员。Redis 不可用时不扫描。

---

## V1.7 变更说明

对齐 PRD v1.7 与前端 TRD v1.7，补上 AI 信使中最核心、此前只有原则没有规则的部分：MBTI 语气重构。① **新增 10.3 MBTI 语气重构逻辑**：MBTI 四个维度各对应一个语气旋钮（E/I 表达能量、S/N 具体度、T/F 情感温度、J/P 结构感），16 型是四个旋钮的组合，提示词由 8 个维度片段拼成，不为每一型单独写规则；写明能改与不能改的范围、两档润色强度、五种目标语言的礼貌规则（优先于旋钮）、示例、程序校验、提示词结构、评测门槛。② **润色只按接收方 MBTI 调整**【假设】：PRD v1.6 8.1 写的“发送方 MBTI + 关系语境”MVP 不使用，与 10.2 原有的“润色缓存只按接收者 MBTI 分 16 档”一致，PRD 8.1 同步修改。③ **MVP 只开放“轻”档**【假设】，“标准”档由 `app_config` 开关控制、默认关闭；润色缓存键加入档位（10.2）。④ **程序校验不通过即回退基础译文**（10.3.7）：数字、时间、链接等不一致、长度超限或新增 emoji 时丢弃润色结果，`deliveries.polish_status = fallback`，`message.polished` 带 `polish_status`，前端显示“未润色”（第 9 章、7.4）。⑤ 极短文本不调用模型（10.3.1）。⑥ 18.1、18.2 补充对应假设与风险。

---

## V1.6 变更说明

前端 F0 在模拟器上端到端联调时发现的问题，对齐前端 TRD v1.6，PRD 不变，接口行为不变。① **契约修正**（第 8 章）：`api/openapi.yaml` 是 OAS 3.0.3，`nullable: true` 的枚举字段必须把 `null` 写进 `enum` 列表；原先 Profile 的 `native_lang`、`age_band` 没写，未 onboarding 用户的 `GET /me` 返回 `null` 时，按契约生成的前端模型解析失败。现两个字段的枚举值都加上 `null`。② **本机集成测试串行运行**（15.5）：各包的集成测试共用同一个本机测试库，并行跑会互相清数据，`make test-int` 须用 `go test -p 1 ./...`（`Taskfile.yml` 的 `test-int` 已如此）。

---

## V1.5 变更说明

B4 实现后做了安全审查与代码审查，WebSocket 加固如下，对齐前端 TRD v1.5，PRD 不变。① **连接不再比 token 活得久**（7.3、第 9 章）：v1.4 只在升级时校验 token，被盗的 access token 连上后，即使用户登出也能一直收房间消息；现在服务端在该 access token 到期（默认 15 分钟）时以关闭码 **4401** 断开，客户端刷新 token 后立即重连。登出、封号对 WS 的影响因此与 REST 一样，最迟在 access token 到期时生效。② **限流**（7.3、12.1）：升级请求按 IP 每分钟 60 次、按用户每分钟 20 次，超出返回 HTTP 429 `RATE_LIMITED`；每条连接每 10 秒最多 10 次 `room.sub`，超出回 `error{RATE_LIMITED}`；`room_id` 不是 UUID 的直接回 `ROOM_NOT_FOUND`，不查库。③ **其余加固**（7.3）：服务重启开始后新的升级请求返回 HTTP 503 `NOT_READY`；`hello` 保证是第一帧；订阅等待快照期间暂存的事件超过 64 条即以 1008 断开；每个客户端请求背后的数据库与 Redis 操作 5 秒超时；连接的读写心跳协程与 Redis 订阅回调都有 panic 保护，不会拖垮整个进程。

---

## V1.4 变更说明

对齐 PRD v1.6 与前端 TRD v1.4，配合 B4（WebSocket Hub、presence、事件分发）设计定稿，详见 `docs/superpowers/specs/2026-11-17-b4-realtime-design.md`。① **断线恢复改为“每次订阅都下发快照”**（4.5③、7.3）：`room.sub` 一律返回从数据库生成的完整 `room.snapshot`，早于快照 seq 的事件客户端本来就会丢弃，补发没有收益，所以 B4 不写 Redis Stream `room:{rid}:events`，`last_seq` 字段保留但暂不使用，B5 有了 `message.new` 再评估是否需要重放；`resync` 改为“客户端重新发 `room.sub`”，`GET /rooms/{id}` MVP 不实现（第 8 章）。② **第 9 章协议重写**：WS 路径与其他接口一样在 `/api/v1` 下（`GET /api/v1/ws`）；新增 `room.unsub` 与 `error` 帧；只有发给全房在席成员的状态事件（`member.joined`、`member.left`）带 seq，个人事件与瞬时事件不带；`pet.tap` / `pet.action` 负载定稿，动作差异由前端宠物动画内部实现；`member.joined` 带新成员的 presence；`room.kicked` 新增 `reason=left`，`code.invalidated` 的 reason 补上 `dissolved`。③ **presence 只有 online / offline**（7.3、第 11 章）：离线时前端把宠物画成睡觉；`presence:u:{uid}` 改为 ZSET（成员为连接 id、分数为过期时间），最后一条连接关闭才判定离线，每次上下线都实时广播。④ **Redis 故障时本机兜底**（7.3、12.2）：写 Redis 失败的事件由本进程 Hub 直接推送（不带 seq），presence 退化为进程内计数；Redis 订阅重连后向本机所有连接发 `resync`。⑤ **补齐 B3 两处事件**（7.8）：解散时给房主发每个被移出成员的 `member.left{dissolved}`；主动退出时给退出者本人发 `room.kicked{left}`，让其其他设备同步离开。⑥ 新增环境变量 `MIN_APP_VERSION`（15.4），只用于 `hello`；WS 协议参数（心跳 25 秒、presence 70 秒、每用户 3 条连接等）为代码常量。⑦ 优雅重启改为发 `server.restart` 后立即断开（7.3）。

---

## V1.3 变更说明

对齐 PRD v1.5 与前端 TRD v1.3，配合前端 F0（登录与 onboarding）设计定稿，无接口变更。① **Google 登录接入真实校验**（7.1、第 5 章 `pkg/idtoken`）：`pkg/idtoken` 新增 Google 验证器——从 Google 的 JWKS（`https://www.googleapis.com/oauth2/v3/certs`，按 `Cache-Control` 缓存）取公钥，用 `golang-jwt` 校验 RS256 签名、`iss`（`accounts.google.com` 或 `https://accounts.google.com`）、`aud == GOOGLE_CLIENT_ID`、`exp`，返回 `sub`；`GOOGLE_CLIENT_ID` 为空时仍返回 501 `PROVIDER_NOT_CONFIGURED`。`GOOGLE_CLIENT_ID` 明确为 Google Cloud 中 **Web 应用类型** OAuth 客户端的 ID（前端 `google_sign_in` 的 `serverClientId` 用同一个值，Android 端另建 Android 客户端，不需要传给后端）。② **Apple 登录延后**：没有 Mac 与 Apple 开发者账号，Apple 继续使用占位验证器，上架 iOS 前补齐。③ 本地端口统一为 **8090**（与 `.env.example` 一致，15.4、15.5）。④ 4.4 公开路由组补上 `POST /auth/login/dev`（仅 local）。⑤ Go 版本按 `go.mod` 改为 1.26。⑥ 15.5 本地命令以 go-task（`task …`）为准，`make` 写法仅作对照；worker 尚未实现。

---

## （2026-11-14 结构调整，无接口变更）

第 4 章“总体架构”扩写为 4.1～4.6：新增 mermaid 架构总图、分层与依赖方向、路由分组与鉴权、三条关键链路时序图、子系统解耦说明；第 5 章“项目目录结构”改为 `handler / service / repository / model / middleware / task / platform / pkg` 的经典分层（api 与 worker 共用 service、repository、model，仅入口层不同）。原按业务域分包（`internal/auth`、`internal/invite` 等）的结构作废；已实现代码需按新结构迁移。

---

## V1.2 变更说明

对齐 PRD v1.4，并修正 V1.1 的几处设计缺陷。① **新增房主管理**（新增 7.8 节）：房主可移除成员、解散小屋、自助补码，房主不可退出自己的小屋；对应新增 `room_bans` 表、`room_members.left_reason`、`invite_codes.source=owner_regen`，第 8 章新增 3 个接口与 `ROOM_LIMIT`/`NOT_ROOM_OWNER`/`OWNER_CANNOT_LEAVE`/`CODE_ISSUE_LIMIT` 四个错误码，第 9 章新增 `room.kicked` 事件、`member.left` 增加 `reason` 字段。② **入房事务（7.2）补全**：V1.1 只写了规则、没落实到事务步骤——新增用户行锁（否则同一用户并发用两个码入房会突破"最多 2 间房"）、禁用自己的码、`room_bans` 黑名单校验、未成年人双向隔离（成年人也不能进含未成年成员的房间）；并定下全局统一加锁顺序 `users → invite_codes → rooms → room_members`，防止入房与解散并发时死锁。③ 奖励码数量改为 `min(配置值, 自己小屋空位数 − 现有未用有效码数)`，终身上限 20 的口径改为除种子码外所有来源累计，新增环境变量 `OWNER_REGEN_DAILY_LIMIT`。④ **`messages` MVP 不分区**：PostgreSQL 分区表的主键和唯一索引必须包含分区键 `created_at`，V1.1 的"按月分区"会让 `(sender_id, client_msg_id)` 无法全局唯一、重发幂等失效；单库 200 QPS 写入不分区足够，靠 30 天清理任务控制体积，第 1.2、3、6.1、18.3 节同步。⑤ 新增 Widget 刷新用的 data-only 推送 `widget.refresh`，`devices` 表新增 `widget_installed`（7.7）：V1.1 前端依赖静默推送刷新 Widget，后端却未定义。⑥ **纯本地运行说明**（15.1、15.5）：当前没有云端预算，仅本地开发与测试；补充依赖服务的两种运行方式（Docker Desktop / 原生安装）及 Windows 下用 go-task 替代 make。第 16 章测试与第 17 章排期同步。5.x 的整体架构、第 10 章 AI 网关、第 11~12 章 Redis 与稳定性设计不变。**（2026-11-14 补充，无接口变更）** 7.1 新增“账号状态与前后顺序”表：登录只建空 `users` 行，小屋与 signup 码只在 onboarding 事务里创建；并约定未完成 onboarding 的用户入房返回 `ONBOARDING_REQUIRED`（B3 实现，尚未列入第 8 章错误码清单）。

---

## V1.1 变更说明

暂不首发中国大陆；补充强制更新接口（`UPGRADE_REQUIRED`（HTTP 426）、WebSocket `hello.min_app_version`）。
