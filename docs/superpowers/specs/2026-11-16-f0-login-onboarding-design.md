# F0 前端骨架、登录与 Onboarding 设计

> 日期：2026-11-16 · 对应前端 TRD v1.2 第 20 章 W1–4 的 F0 与 F1 前半 · 状态：待确认

## 1. 目的

让一个新用户能在 Android 上**登录并完成 onboarding**，在后端得到资料、宠物、自己的小屋和第一个 signup 验证码。之后的入房、背包、小屋都建立在“已 onboarding 的账号”之上（后端对未完成 onboarding 的用户一律返回 `ONBOARDING_REQUIRED`），所以这一步必须先做。

同时把前端骨架搭好：状态管理、路由、网络层、契约生成、多语言、测试，后续阶段只往上加。

## 2. 范围

**做**

- 项目骨架（Android 为主；iOS 目录保留但不编译、不测试，因为目前没有 Mac）。
- 登录页：Google 登录（真实接通）、Apple 登录（按钮与接口层写好，但暂不开放）、开发登录（仅 dev 构建）。
- Onboarding 五步：语言 → MBTI（16 型直选，或进入 4 题测试）→ 宠物揭晓 → 昵称与年龄 → 提交。
- 启动页与会话判定：未登录 → 登录页；已登录未 onboarding → onboarding；已完成 → 首页。
- 首页空壳：底部导航四个 Tab（小屋 / 聊天 / 背包 / 我的），前三个先放占位，“我的”放退出登录。
- **后端配套**：把 Google ID Token 的占位验证器换成真实验证器（见第 9 节）。

**不做**

- iOS 编译与真实 Apple 登录、推送、Sentry、Firebase、WebSocket、入房、背包、小屋场景、Rive 动画、staging / prod 环境。

**反目标**（技术上能跑但算失败）

- 客户端自己推断业务结论（服务端是真相来源；客户端只做格式预校验）。
- 手写接口模型与路径（必须从 `openapi.yaml` 生成）。
- 显示服务端的 `error.message`（只认 `code`，文案走本地化）。

## 3. 做法选择

| 做法 | 内容 | 取舍 |
| :-- | :-- | :-- |
| A. 完全照 TRD 一次搭齐 | dev / staging / prod 三套 flavor 与入口；`openapi-generator`（dart-dio）；现在接 Sentry、Firebase | 后两套环境目前不存在，配置白维护；openapi-generator 依赖 Java，Windows 上配置麻烦 |
| **B. 精简骨架（已选）** | TRD 技术栈不变；只建 dev 一套环境；用 `swagger_parser`（纯 Dart）从 `openapi.yaml` 生成客户端；Sentry / Firebase 等需要时再接；feature 只建有内容的层 | 保留契约驱动与分层，以后只需“加”，不需要推翻 |
| C. 先手写接口 | 不做代码生成 | 违背“契约驱动”，一人两端最容易字段对不上，不采用 |

用户选择 B。

## 4. 技术栈

Flutter 3.50.0 / Dart 3.14.0（已升级）。

| 用途 | 选型 |
| :-- | :-- |
| 状态管理 | `flutter_riverpod` + `riverpod_annotation` / `riverpod_generator` |
| 路由 | `go_router`（redirect 只读 `sessionProvider`） |
| 网络 | `dio`；接口客户端与 DTO 由 `swagger_parser` 生成到 `lib/gen/` |
| 模型 | `freezed` + `json_serializable` |
| 令牌 | `flutter_secure_storage` |
| 轻量存储 | `shared_preferences`（界面语言） |
| 时区 | `flutter_timezone`（取 IANA 名，如 `Asia/Tokyo`，提交给 onboarding 的 `tz`） |
| Google 登录 | `google_sign_in`（v7 API：`initialize(serverClientId:)` → `authenticate()` → `idToken`） |
| 多语言 | `flutter_localizations` + `intl`（ARB，gen-l10n） |
| 静态检查 | `very_good_analysis` |
| 测试 | `flutter_test`、`mocktail` |

Android：`applicationId = io.github.jinheng0301.petbridge`，`minSdk 26`（Android 8），竖屏锁定。

## 5. 目录（按需建层）

```
lib/
├── main.dart                     # 只调用 bootstrap
├── app/
│   ├── app.dart                  # MaterialApp.router、主题、locale
│   ├── bootstrap.dart            # ProviderScope
│   ├── router/                   # app_router.dart、routes.dart
│   └── theme/
├── config/
│   ├── env.dart                  # 唯一读取 --dart-define 的地方
│   └── error_codes.dart          # 后端 code → 本地化 key
├── core/
│   ├── network/                  # dio_client、interceptors/(auth、error_map、log)、app_failure
│   ├── storage/                  # secure_store、prefs_store
│   └── l10n/                     # gen-l10n 生成
├── shared/
│   └── widgets/                  # app_button、loading、error_view
├── features/
│   ├── auth/       data/ application/ presentation/      # 登录、令牌、会话
│   ├── onboarding/ data/ application/ presentation/      # 五步 + 测试题 + 提交
│   ├── pet/        presentation/                          # PetView（占位）、pet_catalog（MBTI → pet_type）
│   └── home/       presentation/                          # 底部导航空壳
└── gen/                          # swagger_parser 生成，不手改
```

`models/` 不单独建目录：本阶段的本地模型很少，放在用到它的 `application/` 里，等出现跨 feature 共用的模型再建 `shared/models/`。

## 6. 会话与路由

`sessionProvider` 由令牌与 `GET /me` 派生，本阶段四种状态：

| 状态 | 条件 | 路由去向 |
| :-- | :-- | :-- |
| `unknown` | 启动中，正在读令牌、拉 `/me` | `/splash` |
| `unauthenticated` | 没有令牌，或刷新失败 | `/login` |
| `needsOnboarding` | `/me.onboarded == false` | `/onboarding/*` |
| `ready` | `/me.onboarded == true` | `/home` |

`solo` / `inRoom` 的区分留到小屋阶段（届时再从 `ready` 细分）。

路由：`/splash`、`/login`、`/onboarding/lang`、`/onboarding/mbti`、`/onboarding/quiz`、`/onboarding/reveal`、`/onboarding/profile`、`/onboarding/too-young`、`/home`。

## 7. 页面

**登录页**

```
┌──────────────────────────┐
│        [ 占位宠物 ]       │
│        PetBridge         │
│  [ G  使用 Google 登录 ]  │
│  [   使用 Apple 登录  ]   │  APPLE_LOGIN_ENABLED=false 时点击提示“即将开放”
│  ── 开发登录（仅 dev）──   │
│  [ dev-a@local    ][登录] │
└──────────────────────────┘
```

**Onboarding**（顶部进度条 + 返回；草稿保存在内存里的 `OnboardingController`，App 被杀后从第一步重来）

1. **语言**：五选一，默认取系统语言；选中即切换界面语言，同时作为 `native_lang`。
2. **MBTI**：16 型网格直选；底部“我不确定，做个小测试”。
3. **测试**（4 题，每题二选一，每题决定一个维度，客户端计分）→ 结果页显示 4 个字母，每个维度可点击翻转后确认 → 回到 MBTI 页并选中结果。题目草案：

   | 维度 | 题目 | A | B |
   | :-- | :-- | :-- | :-- |
   | E / I | 忙了一周，周末你更想… | 约朋友出去热闹一下（E） | 自己待着充电（I） |
   | S / N | 朋友跟你讲一部新电影，你更想知道… | 讲了什么、谁演的（S） | 它想表达什么（N） |
   | T / F | 朋友做了个不太好的决定来问你，你会… | 直接分析哪里有问题（T） | 先照顾他的感受（F） |
   | J / P | 出去旅行，你通常… | 提前排好行程（J） | 到了再看心情（P） |

4. **宠物揭晓**：根据 MBTI 在本地查 `pet_type`（与后端 `internal/service/pet.go` 的映射一致，单测核对 16 个 slug 与 openapi 枚举相同），显示占位宠物、宠物名与一段性格介绍。
5. **昵称与年龄**：昵称去首尾空格后 1–20 字、无控制字符；年龄三选一：未满 13 岁 / 13–17 岁 / 18 岁以上。选“未满 13 岁”进入 `/onboarding/too-young`：友好说明无法使用，只提供“退出登录”，不提交。
6. **提交**：`POST /me/onboarding`（`native_lang`、`mbti`、`nickname`、`age_band`、`tz`）。按钮进入加载态；网络错误可原样重试（接口幂等）；`VALIDATION_FAILED` 按 `details.fields` 标出对应字段；成功后刷新 `/me`，会话变 `ready`，跳 `/home`。

**首页空壳**：底部导航 小屋 / 聊天 / 背包 / 我的。前三个显示“即将开放”占位；“我的”显示昵称、MBTI、宠物与“退出登录”。

## 8. 网络与鉴权

- **base URL** 与开关都来自 `config/env.dart`。
- **拦截器**（本阶段三个，按顺序）：
  1. `AuthInterceptor`：附加 access token；收到 401 时单飞刷新（多个并发请求共享同一次 `POST /auth/refresh`），成功后重放；`REFRESH_INVALID` / `REFRESH_REUSED` 或刷新失败 → 清令牌、会话变 `unauthenticated`。
  2. `ErrorMapInterceptor`：`{error:{code, request_id, details}}` → `AppFailure(code, requestId, details)`；网络错误映射为 `NETWORK`。
  3. `LogInterceptor`：仅 debug，不打印令牌与请求体。
- 重试拦截器与幂等键拦截器留到入房 / 发消息阶段。
- **退出登录**：`POST /auth/logout`（失败也继续），清空 secure storage 与 prefs，Google 端调用 `signOut()`。

## 9. Google 登录（前后端）

**前端**：`GoogleSignIn.instance.initialize(serverClientId: Env.googleServerClientId)` → `authenticate()` → 取 `idToken` → `POST /auth/login/google {id_token}` → 保存令牌 → 拉 `/me` 决定去向。用户取消不报错，留在登录页。

**Google Cloud 配置**（用户操作）：

- Web 客户端已建，Client ID 为 `234594731344-fkbbq90jse9giqlmlkrn3qgjn3om9c8r.apps.googleusercontent.com`（非机密），同时用于前端 `serverClientId` 与后端 `GOOGLE_CLIENT_ID`。
- Android 客户端待建：包名 `io.github.jinheng0301.petbridge` + debug keystore 的 SHA-1；项目首次编译后取得 SHA-1，再由用户在控制台创建。
- 同意屏幕保持 Testing，测试账号加入 Test users。

**后端**：在 `pkg/idtoken` 新增 Google 验证器：从 `https://www.googleapis.com/oauth2/v3/certs` 拉 JWKS（按 `Cache-Control` 缓存），用现有的 `golang-jwt` 校验 RS256 签名、`iss ∈ {accounts.google.com, https://accounts.google.com}`、`aud == GOOGLE_CLIENT_ID`、`exp`，返回 `sub`。`main.go` 在 `GOOGLE_CLIENT_ID` 非空时使用它，否则保持 `NotConfiguredVerifier`（501）。单测用本地生成的 RSA 密钥和假 JWKS 服务器，不依赖网络。Apple 维持占位。

**开发登录**：`DEV_LOGIN=true` 时登录页显示邮箱输入框 → `POST /auth/login/dev {email}`；发布包里由常量开关剔除。

## 10. 环境配置

`env/dev_android.json`（入库）：

```json
{
  "ENV": "dev",
  "API_BASE_URL": "http://10.0.2.2:8090/api/v1",
  "GOOGLE_SERVER_CLIENT_ID": "234594731344-fkbbq90jse9giqlmlkrn3qgjn3om9c8r.apps.googleusercontent.com",
  "DEV_LOGIN": true,
  "APPLE_LOGIN_ENABLED": false
}
```

`env/local.json`（真机连电脑局域网 IP，不入库）。Android 仅 debug manifest 允许明文流量。后端端口以后端 `.env` 的 `APP_PORT=8090` 为准。

## 11. 多语言

ARB 五种语言（`en` 为源、`zh-Hans`、`zh-Hant`、`ja`、`ko`）。本阶段的文案：登录、onboarding、测试题、16 只宠物的名字与性格介绍、错误码、首页占位。`en` 与 `zh-Hans` 由我写；`ja`、`ko`、`zh-Hant` 先用 AI 初译，标记待校对。

## 12. 测试

- **单元**：测试题计分与翻转、MBTI → pet_type 映射（16 项与 openapi 枚举一致）、昵称校验、会话派生与 redirect、`AuthInterceptor` 单飞刷新（并发 401 只刷新一次、刷新失败登出）、错误映射。
- **Widget**：每个 onboarding 页的主要状态（未选不可继续、未满 13 岁分支、提交失败可重试、`VALIDATION_FAILED` 标字段）。
- **手动端到端**：Android 模拟器 + 本地后端，分别用开发登录与 Google 登录走完 onboarding，后端 `/me` 显示 `onboarded: true`。

## 13. 三份文档的同步修改

确认本设计后，在两个仓库的 PRD、前端 TRD、后端 TRD 中同步修改并写入变更记录：

- **前端 TRD**：第 3 章契约生成改为 `swagger_parser`；第 5 章目录按需建层；19.4 环境先只有 dev（端口 8090，新增 `GOOGLE_SERVER_CLIENT_ID`、`APPLE_LOGIN_ENABLED`）；19.5 联调命令改为 go-task、去掉 docker compose 与 worker；首页底部导航改为四个 Tab（小屋 / 聊天 / 背包 / 我的），11.0 线框图同步；11.1 写入 4 道测试题与“未满 13 岁”分支；第 20 章标注 Apple 登录延后；包名写入。
- **后端 TRD**：7.1 / 第 8 章补 Google 验证器做法与 `GOOGLE_CLIENT_ID` 含义（Web 客户端 ID）；15.4 / 15.5 端口改为 8090；Apple 维持占位。
- **PRD**：F1.3 写入测试题设计原则（4 题二选一、可手动翻转确认）；首页导航改为四个 Tab；第 63 行“不做多房间自由切换”改为与“最多 2 间房”一致的说法；注明开发期 Apple 登录延后，但上架 iOS 前必须提供（App Store 规定：提供第三方登录时必须同时提供 Apple 登录）。

## 14. 留给实现者

- 主题视觉：先用 Material 3 默认配色加一个主色，视觉稿出来后替换。
- 占位宠物：一个带 `pet_type` 名字的圆形色块，颜色按 pet_type 固定。
- ARB key 命名按 TRD 13 章的分组（`onb.*`、`err.*`、`pet.*`）。
- 前端仓库已初始化（远端 `jinheng`），沿用现有 `main` 分支。
