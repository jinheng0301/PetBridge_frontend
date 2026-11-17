import 'package:flutter_test/flutter_test.dart';
import 'package:petbridge/core/network/dio_client.dart';

void main() {
  test('base url is the API origin because generated paths carry /api/v1', () {
    expect(apiOrigin('http://10.0.2.2:8090/api/v1'), 'http://10.0.2.2:8090');
    expect(
      apiOrigin('https://api.example.com/api/v1/'),
      'https://api.example.com',
    );
  });
}
