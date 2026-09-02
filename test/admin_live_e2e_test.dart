import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Live E2E Admin API & Parity Verification', () {
    const String baseUrl = 'http://127.0.0.1:8000/api';
    late Dio dio;
    String? adminToken;

    setUpAll(() async {
      dio = Dio(BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ));

      // Login as Admin
      final loginResp = await dio.post('/login', data: {
        'email': 'admin@example.com',
        'password': 'password123',
      });
      expect(loginResp.statusCode, 200);
      final token = loginResp.data['meta']?['access_token'] ?? loginResp.data['data']?['token'];
      expect(token, isNotNull);
      adminToken = token;
      dio.options.headers['Authorization'] = 'Bearer $adminToken';
    });

    test('1. Admin Dashboard API (/audit/v1/admin/dashboard)', () async {
      final res = await dio.get('/audit/v1/admin/dashboard');
      expect(res.statusCode, 200);
      final data = res.data['data'] ?? res.data;
      expect(data['user_statistics'], isNotNull);
      expect(data['purchase_statistics'], isNotNull);
      expect(data['order_status_monitoring'], isNotNull);
    });

    test('2. Admin User Management APIs', () async {
      final buyers = await dio.get('/audit/v1/admin/buyers');
      expect(buyers.statusCode, 200);
      expect(buyers.data['data'], isA<List>());

      final sellers = await dio.get('/audit/v1/admin/sellers');
      expect(sellers.statusCode, 200);
      expect(sellers.data['data'], isA<List>());

      final finances = await dio.get('/audit/v1/admin/finances');
      expect(finances.statusCode, 200);
      expect(finances.data['data'], isA<List>());

      final receivers = await dio.get('/audit/v1/admin/receivers');
      expect(receivers.statusCode, 200);
      expect(receivers.data['data'], isA<List>());

      final managers = await dio.get('/audit/v1/admin/managers');
      expect(managers.statusCode, 200);
      expect(managers.data['data'], isA<List>());

      final direksis = await dio.get('/audit/v1/admin/direksi');
      expect(direksis.statusCode, 200);
      expect(direksis.data['data'], isA<List>());

      final audits = await dio.get('/audit/v1/admin/audits');
      expect(audits.statusCode, 200);
      expect(audits.data['data'], isA<List>());
    });

    test('3. Admin Master Data: Sub-Direktorates (/audit/v1/admin/sub-direktorates)', () async {
      final subdit = await dio.get('/audit/v1/admin/sub-direktorates');
      expect(subdit.statusCode, 200);
      expect(subdit.data['data'], isA<List>());
    });

    test('4. Admin Master Data: Categories (/categories)', () async {
      final categories = await dio.get('/categories');
      expect(categories.statusCode, 200);
    });

    test('5. Admin Master Data: Taxes (/taxs)', () async {
      final taxes = await dio.get('/taxs');
      expect(taxes.statusCode, 200);
    });

    test('6. Admin Master Data: Materai (/materais)', () async {
      final materais = await dio.get('/materais');
      expect(materais.statusCode, 200);
    });

    test('7. Admin Master Data: Provinces & Cities (/provinces & /cities)', () async {
      final prov = await dio.get('/provinces');
      expect(prov.statusCode, 200);

      final cities = await dio.get('/cities');
      expect(cities.statusCode, 200);
    });
  });
}
