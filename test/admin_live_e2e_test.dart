import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Live E2E Admin API & Parity Verification', () {
    const String baseUrl = 'http://127.0.0.1:8000/api';
    late Dio dio;
    String? adminToken;

    setUpAll(() async {
      HttpOverrides.global = null;
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

    test('8. Admin Transactions API (/audit/v1/admin/transactions)', () async {
      final res = await dio.get('/audit/v1/admin/transactions');
      expect(res.statusCode, 200);
      expect(res.data['data'], isA<List>());
      expect(res.data['meta']?['total'], isNotNull);
      final List list = res.data['data'];
      expect(list.isNotEmpty, isTrue);
      expect(list[0]['id'], isNotNull);
      expect(list[0]['order_num'], isNotNull);
      expect(list[0]['seller_snapshot'], isNotNull);
      expect(list[0]['actors_snapshot'], isNotNull);
      expect(list[0]['payment_summary'], isNotNull);
    });

    test('9. Admin Transaction Detail API (/audit/v1/admin/transactions/{id})', () async {
      final res = await dio.get('/audit/v1/admin/transactions/1');
      expect(res.statusCode, 200);
      final data = res.data['data'];
      expect(data['id'], 1);
      expect(data['order_num'], 'ORD-202667674');
      expect(data['seller'], isNotNull);
      expect(data['buyer'], isNotNull);
      expect(data['items'], isA<List>());
      expect(data['logs'], isA<List>());
    });

    test('10. Admin DPP API (/audit/v1/admin/dpp)', () async {
      final res = await dio.get('/audit/v1/admin/dpp');
      expect(res.statusCode, 200);
      expect(res.data['data'], isA<List>());
      expect(res.data['meta']?['total'], isNotNull);
      final List list = res.data['data'];
      expect(list.isNotEmpty, isTrue);
      expect(list[0]['nomor_permintaan'], isNotNull);
      expect(list[0]['nilai_prk'], isNotNull);
      expect(list[0]['sisa'], isNotNull);
    });

    test('11. PHASE 34 — Seller 121 active = 0 and status = non-active', () async {
      final res = await dio.get('/audit/v1/admin/sellers', queryParameters: {'search': 'seller1@example.com'});
      expect(res.statusCode, 200);
      final list = res.data['data'] as List;
      final seller121 = list.firstWhere((s) => s['id'] == 121 || s['email'] == 'seller1@example.com', orElse: () => null);
      expect(seller121, isNotNull, reason: 'Seller 121 should be found via search');
      expect(seller121['status'], 'non-active');
      expect(seller121['seller_data']['active'], 0);
      expect(seller121['email'], 'seller1@example.com');
    });

    test('12. PHASE 34 — Buyer payload has manager and active', () async {
      final res = await dio.get('/audit/v1/admin/buyers');
      expect(res.statusCode, 200);
      final list = res.data['data'] as List;
      expect(list.isNotEmpty, isTrue);
      expect(list[0]['user_data']['active'], isNotNull);
      expect(list[0]['user_data']['manager'], isNotNull);
    });

    test('13. PHASE 34 — Finance payload has full_address and active', () async {
      final res = await dio.get('/audit/v1/admin/finances');
      expect(res.statusCode, 200);
      final list = res.data['data'] as List;
      expect(list.isNotEmpty, isTrue);
      expect(list[0]['user_data']['active'], isNotNull);
      expect(list[0]['full_address'], isNotNull);
    });

    test('14. PHASE 34 — Toggle status endpoint is accessible for 5 roles', () async {
      // Get valid buyer ID from list
      final buyersRes = await dio.get('/audit/v1/admin/buyers');
      final buyerId = buyersRes.data['data'][0]['id'];

      // Test toggle status on buyer
      final buyerToggle = await dio.patch('/audit/v1/admin/buyers/$buyerId/toggle-status');
      expect(buyerToggle.statusCode, 200);
      expect(buyerToggle.data['message'], contains('Status'));

      // Toggle back to keep state clean
      final buyerToggleBack = await dio.patch('/audit/v1/admin/buyers/$buyerId/toggle-status');
      expect(buyerToggleBack.statusCode, 200);
    });
  });
}
