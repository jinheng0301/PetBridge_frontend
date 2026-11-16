import 'package:flutter_test/flutter_test.dart';
import 'package:petbridge/config/env.dart';

void main() {
  test('defaults point at local backend on 8090', () {
    expect(Env.apiBaseUrl, 'http://10.0.2.2:8090/api/v1');
    expect(Env.devLogin, isFalse);
  });
}
