import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petbridge/core/storage/secure_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const storage = FlutterSecureStorage();

  test('write then read round-trips both tokens under one key', () async {
    FlutterSecureStorage.setMockInitialValues({});
    final store = FlutterSecureStore();

    await store.write(const TokenPair(access: 'a1', refresh: 'r1'));
    final t = await store.read();

    expect(t?.access, 'a1');
    expect(t?.refresh, 'r1');
    expect((await storage.readAll()).keys, ['auth_tokens']);
  });

  test('clear removes the tokens', () async {
    FlutterSecureStorage.setMockInitialValues({});
    final store = FlutterSecureStore();
    await store.write(const TokenPair(access: 'a1', refresh: 'r1'));

    await store.clear();

    expect(await store.read(), isNull);
    expect(await storage.readAll(), isEmpty);
  });

  test('tokens saved by older versions are migrated on first read', () async {
    FlutterSecureStorage.setMockInitialValues({
      'access_token': 'old-a',
      'refresh_token': 'old-r',
    });
    final store = FlutterSecureStore();

    final t = await store.read();

    expect(t?.access, 'old-a');
    expect(t?.refresh, 'old-r');
    expect((await storage.readAll()).keys, ['auth_tokens']);
  });

  test('a half-written legacy pair reads as signed out', () async {
    FlutterSecureStorage.setMockInitialValues({'access_token': 'only-a'});

    expect(await FlutterSecureStore().read(), isNull);
  });

  test('a corrupt value reads as signed out', () async {
    FlutterSecureStorage.setMockInitialValues({'auth_tokens': 'not json'});

    expect(await FlutterSecureStore().read(), isNull);
  });
}
