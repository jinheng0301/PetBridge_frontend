# F0 前端骨架、登录与 Onboarding Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 新用户能在 Android 上用 Google 或开发登录进入 App，走完 onboarding，后端生成资料、宠物、小屋与 signup 码，然后进入四个 Tab 的首页空壳。

**Architecture:** Flutter，feature-first，feature 内按需分 `data / application / presentation`（MVVM，Riverpod 单向数据流）；`go_router` 的 redirect 只读 `sessionProvider`；接口代码由 `swagger_parser` 从后端 `api/openapi.yaml` 生成到 `lib/gen/`，只有 Repository 接触生成代码。后端配套一个真实的 Google ID Token 验证器。

**Tech Stack:** Flutter 3.50.0 / Dart 3.14.0、flutter_riverpod + riverpod_generator、go_router、dio + retrofit（swagger_parser 生成）、freezed + json_serializable、flutter_secure_storage、shared_preferences、flutter_timezone、google_sign_in v7、gen-l10n、very_good_analysis、mocktail；后端 Go 1.26 + golang-jwt/v5。

**Spec:** `docs/superpowers/specs/2026-11-16-f0-login-onboarding-design.md`（另见前端 TRD 2026-11-16 补充、后端 TRD 7.1）

## Global Constraints

- Android `applicationId` = `io.github.jinheng0301.petbridge`，`minSdk 26`，竖屏锁定；iOS 目录保留但不编译、不测试。
- 只有 dev 一套环境：`env/dev_android.json`（入库）、`env/local.json`（不入库）；业务代码只能经 `lib/config/env.dart` 读配置。
- 本地后端 `http://10.0.2.2:8090/api/v1`；明文流量只在 debug manifest 允许。
- Google `serverClientId` = `234594731344-fkbbq90jse9giqlmlkrn3qgjn3om9c8r.apps.googleusercontent.com`（Web 客户端 ID，非机密）。
- `lib/gen/` 与 `lib/core/l10n/` 下是生成代码，不手改；生成代码只在各 feature 的 `data/` 里使用。
- UI 只认 `error.code`，**不显示服务端 `message`**；每个 code 对应 ARB 的 `err_<CODE>`，缺失时回落 `err_UNKNOWN`。
- 客户端只做格式预校验，业务结论以服务端为准。
- 五种语言 `en`（源）、`zh_Hans`、`zh_Hant`、`ja`、`ko`；`ja`、`ko`、`zh_Hant` 为 AI 初译，ARB 中 `@@x-reviewed: false`。
- **不自动提交**：每个任务末尾只给出建议提交信息，由用户审阅后自己提交（两个仓库都一样）。
- 后端改动遵守后端仓库现有风格（手写 pgx、`go test ./...`、`task` 命令）。

## Review Focus

1. **onboarding 中途返回**：从“昵称与年龄”返回“宠物揭晓”再前进，已填的昵称与年龄仍在 → Task 7 `draft survives back navigation`。
2. **用户取消 Google 登录或设备没有 Google 账号**：留在登录页，不弹错误 → Task 6 `google cancel stays on login without error`。
3. **提交 onboarding 时 access token 恰好过期**：自动刷新后重放提交，用户无感；刷新也失败则回登录页 → Task 3 的单飞刷新测试 + `refresh failure clears tokens and expires session`。
4. **系统语言不在五种之内或是地区变体**（`fr`、`zh_HK`、`zh_TW`、`zh_CN`）：`fr` → `en`，`zh_HK`/`zh_TW` → `zh_Hant`，`zh_CN` → `zh_Hans` → Task 5 `locale_resolver_test`。
5. **重复点击“完成”**：提交中按钮禁用，只发一次请求 → Task 7 `submit button disabled while submitting` 与 `submit is ignored while submitting`。

---

## 文件结构

```
PetBridge_frontend/
├── pubspec.yaml · analysis_options.yaml · l10n.yaml · swagger_parser.yaml · .gitignore
├── env/dev_android.json
├── tool/gen_api.ps1                          # 生成接口代码
├── android/app/src/debug/AndroidManifest.xml # 明文流量（debug）
├── lib/
│   ├── main.dart
│   ├── app/{app.dart, bootstrap.dart, theme/app_theme.dart, router/{routes.dart, app_router.dart}}
│   ├── config/{env.dart, error_codes.dart}
│   ├── core/
│   │   ├── network/{app_failure.dart, dio_client.dart, interceptors/{auth_interceptor.dart, error_map_interceptor.dart}}
│   │   ├── storage/{secure_store.dart, prefs_store.dart}
│   │   └── l10n/                              # gen-l10n 输出
│   ├── shared/widgets/{app_button.dart, error_text.dart}
│   ├── features/
│   │   ├── auth/data/auth_repository.dart
│   │   ├── auth/data/google_auth.dart
│   │   ├── auth/application/{session.dart, session_controller.dart}
│   │   ├── auth/presentation/{splash_page.dart, login_page.dart}
│   │   ├── onboarding/application/{quiz.dart, nickname.dart, locale_resolver.dart, onboarding_controller.dart}
│   │   ├── onboarding/data/onboarding_repository.dart
│   │   ├── onboarding/presentation/pages/{lang_page, mbti_page, quiz_page, quiz_result_page, reveal_page, profile_page, too_young_page}.dart
│   │   ├── pet/presentation/{pet_catalog.dart, pet_view.dart}
│   │   └── home/presentation/{home_shell.dart, me_tab.dart}
│   └── gen/                                   # swagger_parser 输出
├── assets/l10n/app_{en,zh_Hans,zh_Hant,ja,ko}.arb
└── test/                                       # 与 lib/ 同构
```

后端（`PetBridge_backend`）：`pkg/idtoken/google.go`、`pkg/idtoken/google_test.go`、`cmd/api/main.go`、`api/openapi.yaml`（加 `operationId`）。

---

### Task 1: 项目骨架、环境配置与多语言基础

**Files:**
- Create: Flutter 工程（`flutter create`）、`pubspec.yaml` 依赖、`analysis_options.yaml`、`l10n.yaml`、`.gitignore` 追加、`env/dev_android.json`、`android/app/src/debug/AndroidManifest.xml`、`lib/main.dart`、`lib/app/{app.dart,bootstrap.dart,theme/app_theme.dart}`、`lib/config/env.dart`、`assets/l10n/app_*.arb`
- Modify: `android/app/build.gradle(.kts)`（`minSdk = 26`）、`android/app/src/main/AndroidManifest.xml`（`screenOrientation="portrait"`）
- Test: `test/config/env_test.dart`、`test/app/app_smoke_test.dart`

**Interfaces:**
- Produces: `abstract final class Env { static const String env; static const String apiBaseUrl; static const String googleServerClientId; static const bool devLogin; static const bool appleLoginEnabled; }`（全部 `String/bool.fromEnvironment`，默认值：`'dev'`、`'http://10.0.2.2:8090/api/v1'`、`''`、`false`、`false`）；`class PetBridgeApp extends StatelessWidget`（Task 6 前先渲染一个占位首页）；`AppLocalizations`（gen-l10n，`output-dir: lib/core/l10n`，`synthetic-package: false`）。

- [ ] **Step 1: 初始化工程** — 仓库已存在（远端 `jinheng`，分支 `main`）；在 `PetBridge_frontend` 根目录执行 `flutter create --org io.github.jinheng0301 --project-name petbridge --platforms android,ios .`；确认 `android/app/build.gradle*` 中 `applicationId` 为 `io.github.jinheng0301.petbridge`，改 `minSdk = 26`。`.gitignore` 追加 `env/local.json`。
- [ ] **Step 2: 依赖** — `flutter pub add flutter_riverpod riverpod_annotation go_router dio retrofit freezed_annotation json_annotation flutter_secure_storage shared_preferences flutter_timezone google_sign_in intl flutter_localizations:{sdk: flutter}`；`flutter pub add -d build_runner riverpod_generator freezed json_serializable retrofit_generator swagger_parser very_good_analysis mocktail`。`analysis_options.yaml` 引入 `package:very_good_analysis/analysis_options.yaml`，排除 `lib/gen/**`、`lib/core/l10n/**`、`**/*.g.dart`、`**/*.freezed.dart`。
- [ ] **Step 3: 环境与明文流量** — 写 `env/dev_android.json`（内容见 spec 第 10 节）；debug manifest 加 `android:usesCleartextTraffic="true"`（main manifest 不加）。
- [ ] **Step 4: 写失败的测试** — `env_test.dart`：`test('defaults point at local backend on 8090', () { expect(Env.apiBaseUrl, 'http://10.0.2.2:8090/api/v1'); expect(Env.devLogin, isFalse); })`；`app_smoke_test.dart`：`testWidgets('app boots with en locale', ...)` 断言找到 `AppLocalizations.of(context).appTitle` 的文字 `PetBridge`。
- [ ] **Step 5: 运行确认失败** — `flutter test test/config test/app`，预期编译失败。
- [ ] **Step 6: 实现** `env.dart`、`app.dart`（`MaterialApp`，`localizationsDelegates`/`supportedLocales` 来自 gen-l10n，`Locale.fromSubtags` 区分 `zh_Hans` / `zh_Hant`，系统字号缩放夹在 0.8–1.3）、`bootstrap.dart`（`ProviderScope`）、`app_theme.dart`（Material 3，单一主色）、五个 ARB（先只有 `appTitle`）。
- [ ] **Step 7: 运行确认通过** — `flutter gen-l10n && flutter analyze && flutter test`，预期 PASS、无 analyze 问题；`flutter run --dart-define-from-file=env/dev_android.json` 在 Android 模拟器显示占位页。
- [ ] **Step 8: 取 debug SHA-1 交给用户** — 首次编译后运行 `cd android && ./gradlew signingReport`，把 `debug` 变体的 SHA1 告诉用户，由用户在 Google Cloud 建 Android 客户端（包名 + SHA-1）。
- [ ] **Step 9: 建议提交信息** `chore: scaffold Flutter app with env config, theme and l10n`（不执行提交）

---

### Task 2: 契约生成（含后端 operationId）

**Files:**
- Modify（后端）: `PetBridge_backend/api/openapi.yaml`（每个操作加 `operationId`）
- Create: `swagger_parser.yaml`、`tool/gen_api.ps1`、`lib/gen/**`（生成）
- Test: `test/gen/contract_decode_test.dart`

**Interfaces:**
- Produces: 生成的 `PetBridgeApi`（retrofit，构造 `PetBridgeApi(Dio dio, {String? baseUrl})`），方法名即 operationId：`loginDev`、`loginApple`、`loginGoogle`、`refreshToken`、`logout`、`getMe`、`completeOnboarding`（其余操作也加 id，但本阶段不用）；DTO `Profile`、`OnboardingRequest`、`OnboardingResult`、`LoginData`。后续任务只经 Repository 使用它们。

- [ ] **Step 1: 后端加 operationId** — 在 `api/openapi.yaml` 为全部操作加：`healthz`、`readyz`、`loginDev`、`loginApple`、`loginGoogle`、`refreshToken`、`logout`、`getMe`、`completeOnboarding`、`joinRoom`、`listMyRooms`、`removeMember`、`dissolveRoom`、`regenCode`、`leaveRoom`、`listCodes`。运行 `go test ./internal/server -run TestOpenAPI -v`（后端仓库），预期 PASS（契约测试只比路由，不受 operationId 影响）。
- [ ] **Step 2: 配置生成** — `swagger_parser.yaml`：`schema_path: ../PetBridge_backend/api/openapi.yaml`、`output_directory: lib/gen`、`language: dart`、`json_serializer: freezed`、`merge_clients: true`、`merged_client_name: PetBridgeApi`、`put_clients_in_folder: true`。`tool/gen_api.ps1`：依次 `dart run swagger_parser`、`dart run build_runner build --delete-conflicting-outputs`。
- [ ] **Step 3: 写失败的测试** — `contract_decode_test.dart`：`test('Profile decodes the onboarded user', ...)` 用 `{"id":"…uuid…","onboarded":true,"nickname":"Aki","mbti":"ENFP","pet_type":"happy_shiba","native_lang":"ja","age_band":"18_plus","tz":"Asia/Tokyo"}` 解码，断言 `onboarded == true`、`petType == 'happy_shiba'`；`test('OnboardingRequest encodes snake_case', ...)` 断言 JSON 含 `native_lang`、`age_band`、`tz` 键。
- [ ] **Step 4: 运行确认失败** — `flutter test test/gen`，预期编译失败。
- [ ] **Step 5: 生成** — `pwsh tool/gen_api.ps1`。若生成器对 `nullable`、枚举（如 `13_17`）或内联 `{data: …}` 响应的命名有问题，用 `swagger_parser.yaml` 的选项解决，不手改 `lib/gen`。
- [ ] **Step 6: 运行确认通过** — `flutter analyze && flutter test test/gen`，预期 PASS。
- [ ] **Step 7: 建议提交信息** — 前端：`build: generate API client from backend openapi.yaml`；后端：`docs(api): add operationId to every operation`（不执行提交）

---

### Task 3: 网络层、令牌存储与单飞刷新

**Files:**
- Create: `lib/core/network/{app_failure.dart,dio_client.dart,interceptors/auth_interceptor.dart,interceptors/error_map_interceptor.dart}`、`lib/core/storage/{secure_store.dart,prefs_store.dart}`、`lib/config/error_codes.dart`
- Test: `test/core/network/{error_map_interceptor_test.dart,auth_interceptor_test.dart}`、`test/config/error_codes_test.dart`

**Interfaces:**
- Produces:
  - `class AppFailure implements Exception { final String code; final int? status; final String? requestId; final Map<String, Object?> details; }`；网络不可达 → `code: 'NETWORK'`，无法解析的错误 → `'UNKNOWN'`。
  - `class TokenPair { final String access; final String refresh; }`；`abstract interface class SecureStore { Future<TokenPair?> read(); Future<void> write(TokenPair t); Future<void> clear(); }`，实现 `FlutterSecureStore`。
  - `class PrefsStore { Future<String?> uiLocale(); Future<void> setUiLocale(String tag); Future<void> clear(); }`
  - `typedef RefreshFn = Future<TokenPair> Function(String refreshToken);`
  - `class AuthInterceptor extends Interceptor { AuthInterceptor({required SecureStore store, required RefreshFn refresh, required void Function() onSessionExpired, required Dio retryDio}); }`
  - `Dio buildDio({required SecureStore store, required RefreshFn refresh, required void Function() onSessionExpired})`：baseUrl `Env.apiBaseUrl`，连接 5 秒、接收 10 秒；拦截器顺序 Auth → ErrorMap → `LogInterceptor`（仅 `kDebugMode`，`requestBody/responseBody: false`）。
  - `String errorL10nKey(String code)` → `'err_$code'`；`String localizedError(AppLocalizations l, AppFailure f)` 未知 code 回落 `err_UNKNOWN`。
  - Riverpod：`secureStoreProvider`、`prefsStoreProvider`、`dioProvider`。

- [ ] **Step 1: 写失败的测试**
  - `error_map_interceptor_test.dart`：`maps backend error body to AppFailure`（409 + `{"error":{"code":"ROOM_LIMIT","message":"x","request_id":"r1"}}` → `code=='ROOM_LIMIT'`、`requestId=='r1'`、`status==409`）；`keeps details`（`VALIDATION_FAILED` 的 `details.fields == ['nickname']`）；`connection error becomes NETWORK`；`non-json 500 becomes UNKNOWN`。
  - `auth_interceptor_test.dart`（用 mocktail 的假 `SecureStore` 和计数的 `RefreshFn`，`retryDio` 用自定义 `HttpClientAdapter` 返回预设响应）：`attaches bearer token`；`two concurrent 401s refresh once and both replay`（断言 refresh 调用次数 == 1，两个请求都拿到 200，且重放时带新 token）；`refresh failure clears tokens and expires session`（refresh 抛 `AppFailure('REFRESH_REUSED')` → `store.clear()` 被调用、`onSessionExpired` 被调用一次、原请求以 401 失败）；`does not refresh for /auth/refresh itself`。
  - `error_codes_test.dart`：`unknown code falls back to err_UNKNOWN`。
- [ ] **Step 2: 运行确认失败** — `flutter test test/core test/config`，预期编译失败。
- [ ] **Step 3: 实现** 上述类型。单飞刷新用一个共享的 `Future<TokenPair>?`（进行中时后来的 401 等待同一个 Future，完成后置空）。`/auth/*` 登录与刷新请求不带也不刷新 token。ARB 加入 `err_UNKNOWN`、`err_NETWORK`、`err_VALIDATION_FAILED`、`err_PROVIDER_NOT_CONFIGURED`、`err_ACCOUNT_DISABLED`、`err_RATE_LIMITED` 文案。
- [ ] **Step 4: 运行确认通过** — `flutter test test/core test/config && flutter analyze`，预期 PASS。
- [ ] **Step 5: 建议提交信息** `feat(core): add dio client, error mapping and single-flight token refresh`（不执行提交）

---

### Task 4: 后端 Google ID Token 验证器

**Files（后端仓库）:**
- Create: `pkg/idtoken/google.go`、`pkg/idtoken/google_test.go`
- Modify: `cmd/api/main.go:98`（按配置选择验证器）

**Interfaces:**
- Produces: `func NewGoogleVerifier(clientID string, opts ...GoogleOption) *GoogleVerifier`；`func (v *GoogleVerifier) Verify(ctx context.Context, idToken string) (string, error)`（实现现有 `Verifier`）；`func WithJWKSURL(url string) GoogleOption`、`func WithHTTPClient(c *http.Client) GoogleOption`、`func WithClock(now func() time.Time) GoogleOption`（测试用）。默认 JWKS `https://www.googleapis.com/oauth2/v3/certs`。
- 错误：校验失败返回 `ErrInvalidToken`（新增，handler 现有映射若不认识它，按 `UNAUTHORIZED` 处理——先读 `auth_handler.go` 的 `loginWith` 确认映射，必要时补一行）。

- [ ] **Step 1: 写失败的测试**（`httptest.Server` 提供 JWKS，测试内生成 RSA 密钥并用 `golang-jwt` 签发）：`TestGoogle_ValidToken`（返回 `sub`）、`TestGoogle_WrongAudience`、`TestGoogle_WrongIssuer`、`TestGoogle_Expired`、`TestGoogle_UnknownKidRefetchesOnce`（第一次 JWKS 不含 kid，第二次含 → 成功，JWKS 请求次数 == 2）、`TestGoogle_BothIssuerForms`（`accounts.google.com` 与 `https://accounts.google.com` 都通过）、`TestGoogle_RejectsHS256`。
- [ ] **Step 2: 运行确认失败** — `go test ./pkg/idtoken -run TestGoogle -v`，预期编译失败。
- [ ] **Step 3: 实现** — 只接受 `RS256`；JWKS 按 `Cache-Control: max-age` 缓存（缺省 1 小时），遇未知 `kid` 刷新一次；HTTP 调用设 5 秒超时；`main.go` 中 `cfg.GoogleClientID != ""` 时用 `idtoken.NewGoogleVerifier(cfg.GoogleClientID)`，否则保持 `NotConfiguredVerifier{}`（先确认 config 中字段名）。
- [ ] **Step 4: 运行确认通过** — `go vet ./... && go test ./pkg/idtoken ./internal/handler -v`，预期 PASS。
- [ ] **Step 5: 建议提交信息** `feat(idtoken): verify Google ID tokens against Google JWKS`（不执行提交）

---

### Task 5: 宠物目录、测试题计分、昵称校验、语言解析

**Files:**
- Create: `lib/features/pet/presentation/{pet_catalog.dart,pet_view.dart}`、`lib/features/onboarding/application/{quiz.dart,nickname.dart,locale_resolver.dart}`
- Test: `test/features/pet/pet_catalog_test.dart`、`test/features/onboarding/{quiz_test.dart,nickname_test.dart,locale_resolver_test.dart}`

**Interfaces:**
- Produces:
  - `const Map<String, String> kPetTypeByMbti`（16 项，与后端 `internal/service/pet.go` 完全一致）；`String petTypeFor(String mbti)`（非法 MBTI 抛 `ArgumentError`）。
  - `class PetView extends StatelessWidget { const PetView({required String petType, double size = 160}); }`：占位圆形，颜色由 `petType` 的稳定哈希决定，中间显示本地化宠物名 `pet_<petType>_name`。
  - `enum Dimension { ei, sn, tf, jp }`；`class QuizQuestion { final Dimension dimension; final String promptKey, aKey, bKey; final String aLetter, bLetter; }`；`const List<QuizQuestion> kQuizQuestions`（顺序 EI、SN、TF、JP，A 分别为 E、S、T、J）；`enum QuizChoice { a, b }`；`String scoreQuiz(List<QuizChoice> answers)`（长度必须为 4）；`String flipDimension(String mbti, Dimension d)`。
  - `enum NicknameError { empty, tooLong, invalidChars }`；`NicknameError? validateNickname(String raw)`：trim 后为空 → `empty`；`runes.length > 20` → `tooLong`；含 C0/C1 控制字符 → `invalidChars`；其余交给服务端。
  - `Locale resolveAppLocale(Locale system)`。

- [ ] **Step 1: 写失败的测试**
  - `pet_catalog_test`：`maps all 16 types`（断言 16 个 key 与 16 个 value 都不重复，且 value 集合等于 `{lone_leopard, leader_lion, thinker_owl, clever_fox, guardian_deer, guide_dolphin, healing_rabbit, happy_shiba, steady_beaver, order_sheepdog, guardian_penguin, warm_otter, calm_blackcat, daring_falcon, easygoing_alpaca, party_parrot}`）；`ENFP is happy_shiba`；`INTJ is lone_leopard`；`rejects lowercase or bogus`。
  - `quiz_test`：`all A gives ESTJ`；`all B gives INFP`；`mixed a,b,a,b gives ENTP`；`flip TF of ENTP gives ENFP`；`rejects 3 answers`。
  - `nickname_test`：`'  Aki  ' ok`；`'' and '   ' empty`；`21 CJK chars tooLong, 20 ok`；`emoji counts by rune`（20 个 `😀` ok）；`'\u0007a' invalidChars`。
  - `locale_resolver_test`：`fr -> en`；`zh_TW -> zh_Hant`；`zh_HK -> zh_Hant`；`zh_CN -> zh_Hans`；`zh (no region, no script) -> zh_Hans`；`ja_JP -> ja`；`ko_KR -> ko`；`zh_Hant_TW -> zh_Hant`。
- [ ] **Step 2: 运行确认失败** — `flutter test test/features/pet test/features/onboarding`。
- [ ] **Step 3: 实现**，并在 ARB 中加 16 个宠物名 `pet_<slug>_name`、16 段性格介绍 `pet_<slug>_intro`（en 与 zh_Hans 由实现者写，其余 AI 初译）、4 道题的题干与选项（文案取自 spec 第 7 节）。
- [ ] **Step 4: 运行确认通过** — `flutter gen-l10n && flutter test && flutter analyze`。
- [ ] **Step 5: 建议提交信息** `feat(onboarding): add pet catalog, quiz scoring, nickname and locale rules`（不执行提交）

---

### Task 6: 会话、路由与登录（开发登录 / Google / Apple 占位）

**Files:**
- Create: `lib/features/auth/data/{auth_repository.dart,google_auth.dart}`、`lib/features/auth/application/{session.dart,session_controller.dart}`、`lib/features/auth/presentation/{splash_page.dart,login_page.dart}`、`lib/app/router/{routes.dart,app_router.dart}`、`lib/shared/widgets/{app_button.dart,error_text.dart}`
- Test: `test/features/auth/{session_controller_test.dart,login_page_test.dart}`、`test/app/router/redirect_test.dart`

**Interfaces:**
- Consumes: `PetBridgeApi`（Task 2）、`SecureStore` / `dioProvider` / `AppFailure`（Task 3）。
- Produces:
  - `class Me { final String id; final bool onboarded; final String? nickname, mbti, petType, nativeLang, ageBand; }`
  - `abstract interface class AuthRepository { Future<void> loginDev(String email); Future<void> loginGoogle(String idToken); Future<void> loginApple(String idToken); Future<Me> me(); Future<TokenPair> refresh(String refreshToken); Future<void> logout(); }`（登录成功即写入 `SecureStore`；`logout` 调 `POST /auth/logout`，失败也清本地）。
  - `abstract interface class GoogleAuth { Future<String?> signIn(); Future<void> signOut(); }`（返回 idToken；用户取消返回 `null`）；实现用 `GoogleSignIn.instance.initialize(serverClientId: Env.googleServerClientId)` + `authenticate()`，`GoogleSignInException` 的取消类错误映射为 `null`。
  - `sealed class Session`：`SessionUnknown`、`SessionUnauthenticated`、`SessionNeedsOnboarding(Me me)`、`SessionReady(Me me)`。
  - `@riverpod class SessionController`：`build()` 读令牌 → 无则 `Unauthenticated`，有则 `me()` 决定；方法 `loginDev(String)`、`loginGoogle()`、`loginApple()`（`Env.appleLoginEnabled == false` 时抛 `AppFailure('APPLE_LOGIN_UNAVAILABLE')`）、`refreshMe()`、`logout()`、`expire()`（供 `onSessionExpired` 调用）。
  - `abstract final class Routes { splash='/splash', login='/login', onbLang='/onboarding/lang', onbMbti='/onboarding/mbti', onbQuiz='/onboarding/quiz', onbQuizResult='/onboarding/quiz/result', onbReveal='/onboarding/reveal', onbProfile='/onboarding/profile', onbTooYoung='/onboarding/too-young', home='/home' }`
  - `String? redirectFor(Session s, String location)`（纯函数，供 `GoRouter.redirect` 与测试使用）。

- [ ] **Step 1: 写失败的测试**
  - `redirect_test`：`unknown -> /splash`；`unauthenticated on /home -> /login`；`unauthenticated on /login -> null`；`needsOnboarding on /home -> /onboarding/lang`；`needsOnboarding on /onboarding/profile -> null`（允许停留在任一 onboarding 子页）；`ready on /login or /onboarding/* -> /home`；`ready on /home -> null`。
  - `session_controller_test`（假 `AuthRepository`、假 `GoogleAuth`、假 `SecureStore`）：`no token -> Unauthenticated`；`token + onboarded=false -> NeedsOnboarding`；`token + onboarded=true -> Ready`；`me() 401 after failed refresh -> Unauthenticated`；`google cancel stays on login without error`（`signIn()` 返回 null → 状态仍为 `Unauthenticated`，不抛错、不调 `loginGoogle`）；`logout clears store and signs out of Google`。
  - `login_page_test`：`dev login hidden when DEV_LOGIN false`（通过注入的 `devLoginEnabled` 参数测试，不依赖编译期常量）；`apple button shows coming-soon snackbar when disabled`；`PROVIDER_NOT_CONFIGURED shows localized text, not server message`。
- [ ] **Step 2: 运行确认失败** — `flutter test test/features/auth test/app/router`。
- [ ] **Step 3: 实现** — `GoRouter` 的 `refreshListenable` 监听 `sessionControllerProvider`；`dioProvider` 的 `onSessionExpired` 调 `SessionController.expire()`；splash 只显示 logo + 进度；登录页按 spec 第 7 节线框；开发登录邮箱默认 `dev-a@local`。`LoginPage` 构造参数 `devLoginEnabled`（默认 `Env.devLogin`）、`appleEnabled`（默认 `Env.appleLoginEnabled`）。新增 ARB：登录页文案、`err_APPLE_LOGIN_UNAVAILABLE`。
- [ ] **Step 4: 运行确认通过** — `flutter test && flutter analyze`。
- [ ] **Step 5: 手动验证** — 本地后端 `task dev` 运行中，`flutter run --dart-define-from-file=env/dev_android.json`，开发登录 `dev-a@local`（已 onboarding 的种子用户）→ 进 `/home` 占位；新邮箱 `dev-new1@local` → 进 `/onboarding/lang` 占位。
- [ ] **Step 6: 建议提交信息** `feat(auth): add session state, router guard and dev/Google/Apple login`（不执行提交）

---

### Task 7: Onboarding 页面与提交

**Files:**
- Create: `lib/features/onboarding/application/onboarding_controller.dart`、`lib/features/onboarding/data/onboarding_repository.dart`、`lib/features/onboarding/presentation/pages/*.dart`
- Modify: `lib/app/router/app_router.dart`（挂上 onboarding 路由）、`lib/app/app.dart`（界面语言来自 `uiLocaleProvider`）
- Test: `test/features/onboarding/{onboarding_controller_test.dart,pages_test.dart}`

**Interfaces:**
- Consumes: Task 5 的 `kQuizQuestions`、`scoreQuiz`、`flipDimension`、`petTypeFor`、`validateNickname`、`resolveAppLocale`、`PetView`；Task 6 的 `SessionController.refreshMe()`；`PrefsStore`。
- Produces:
  - `enum AgeChoice { under13, teen, adult }`（`teen` → `13_17`，`adult` → `18_plus`）
  - `@freezed class OnboardingDraft { String? nativeLang; String? mbti; String nickname; AgeChoice? age; }`
  - `@riverpod class OnboardingController`：`setLanguage(String tag)`（同时 `PrefsStore.setUiLocale`）、`setMbti(String)`、`setNickname(String)`、`setAge(AgeChoice)`、`Future<void> submit()`；状态 `({OnboardingDraft draft, bool submitting, AppFailure? failure, Set<String> badFields})`。
  - `abstract interface class OnboardingRepository { Future<void> complete({required String nativeLang, required String mbti, required String nickname, required String ageBand, required String tz}); }`
  - `Future<String> deviceTimeZone()`：`flutter_timezone` 结果不含 `/` 且不是 `UTC` 时回落 `'UTC'`。
  - `@riverpod Locale uiLocale`：prefs 有值用之，否则 `resolveAppLocale(系统 locale)`。

- [ ] **Step 1: 写失败的测试**
  - `onboarding_controller_test`：`submit sends mapped age band and tz`（`teen` → `'13_17'`，`tz` 来自注入的假 `deviceTimeZone`）；`submit success refreshes session`（`refreshMe` 被调用一次）；`VALIDATION_FAILED marks fields`（`details.fields == ['nickname']` → `badFields == {'nickname'}`）；`network failure keeps draft and allows retry`；`draft survives back navigation`（设置昵称与年龄后，controller 状态在离开 profile 路由再返回时仍保留——controller 不随页面 dispose，用 `keepAlive: true`）；`submit is ignored while submitting`。
  - `pages_test`：`lang page preselects resolved system language`；`mbti page continue disabled until a type is picked`；`quiz result flips a dimension and confirms`（`ESTJ` 点 T/F 后为 `ESFJ`，确认后回 MBTI 页并选中）；`reveal shows pet for chosen MBTI`（ENFP → `pet_happy_shiba_name` 的文字）；`under13 routes to too-young page and does not submit`；`submit button disabled while submitting`；`nickname error shown inline`。
- [ ] **Step 2: 运行确认失败** — `flutter test test/features/onboarding`。
- [ ] **Step 3: 实现** 七个页面（按 spec 第 7 节；顶部进度条 1–5，quiz 与 quiz_result 计为第 2 步内的子页）、controller 与 repository（`completeOnboarding` 调用，接口幂等，失败原样重试）。too-young 页只有说明与“退出登录”。新增全部 onboarding ARB 文案。
- [ ] **Step 4: 运行确认通过** — `flutter gen-l10n && flutter test && flutter analyze`。
- [ ] **Step 5: 建议提交信息** `feat(onboarding): add language, MBTI, quiz, reveal and profile steps`（不执行提交）

---

### Task 8: 首页空壳（四个 Tab）

**Files:**
- Create: `lib/features/home/presentation/{home_shell.dart,me_tab.dart}`
- Modify: `lib/app/router/app_router.dart`（`/home` 用 `StatefulShellRoute.indexedStack`，四个分支）
- Test: `test/features/home/home_shell_test.dart`

**Interfaces:**
- Consumes: `SessionReady.me`、`SessionController.logout()`、`PetView`。
- Produces: `/home` 下四个 Tab：小屋、聊天、背包、我的（顺序固定，图标 `home / chat_bubble / backpack / person`）。

- [ ] **Step 1: 写失败的测试** — `shows four tabs in order`（小屋、聊天、背包、我的 的本地化文字）；`first three tabs show coming soon`；`me tab shows nickname, MBTI and pet`；`logout returns to login`。
- [ ] **Step 2: 运行确认失败** — `flutter test test/features/home`。
- [ ] **Step 3: 实现**。
- [ ] **Step 4: 运行确认通过** — `flutter test && flutter analyze`。
- [ ] **Step 5: 建议提交信息** `feat(home): add four-tab home shell with profile and logout`（不执行提交）

---

### Task 9: 端到端联调与收尾

- [ ] **Step 1: 前置** — 用户已在 Google Cloud 建好 Android 客户端（Task 1 Step 8 的 SHA-1）；后端 `.env` 已有 `GOOGLE_CLIENT_ID`，`task up && task dev` 运行中。
- [ ] **Step 2: 开发登录全流程** — 新邮箱 `dev-f0-1@local` → 语言（日本語）→ “我不确定” → 测试 → 翻转一个维度 → 揭晓 → 昵称 + 18 岁以上 → 完成 → 首页；“我的”显示资料。后端核对：`GET /me` 为 `onboarded: true`，`GET /codes` 有 1 个 `signup` 码，`GET /rooms/mine` 有 1 间房。
- [ ] **Step 3: Google 登录全流程** — 模拟器（需带 Google Play 的系统镜像并登录测试账号）点 Google 登录 → onboarding → 首页；再冷启动直接进首页。
- [ ] **Step 4: 异常路径** — 停后端时登录显示 `err_NETWORK` 文案；选“未满 13 岁”进入说明页且后端没有收到 onboarding 请求；退出登录回登录页、再进需要重新登录。
- [ ] **Step 5: 全量检查** — 前端 `flutter analyze && flutter test`；后端 `go vet ./... && go test ./... -count=1`。
- [ ] **Step 6: 文档同步核对** — 若实现中改了任何设计（例如生成器限制导致的调整），按规则同步更新两个仓库的 PRD、前端 TRD、后端 TRD 并写变更记录，`md5sum` 核对两边一致。
- [ ] **Step 7: 建议提交信息** — 无代码改动则无需提交；文档有改动：`docs: sync F0 implementation notes across PRD and TRDs`（不执行提交）

---

## Self-Review

- **Spec 覆盖**：骨架（T1）、契约生成（T2）、网络与鉴权 + 单飞刷新（T3）、后端 Google 验证器（T4）、测试题 / 宠物映射 / 昵称（T5）、会话四态 + 路由 + 三种登录（T6）、onboarding 五步 + 未满 13 岁 + 提交（T7）、首页四 Tab（T8）、手动端到端与 SHA-1 步骤（T1、T9）、多语言（T1 起逐任务加 ARB）、文档同步（T9）。
- **类型一致**：`TokenPair`、`AppFailure`、`SecureStore`、`Session*`、`OnboardingDraft`、`AgeChoice`、`petTypeFor`、`scoreQuiz`、`flipDimension`、`Routes.*` 在各任务的 Interfaces 中同名使用。
- **待实现时确认**：swagger_parser 对内联 `{data: …}` 响应与枚举值 `13_17` 的生成命名（T2 Step 5 已写明只用配置解决）；后端 config 中 Google 字段名与 handler 对验证错误的映射（T4 已写明先读再改）。
