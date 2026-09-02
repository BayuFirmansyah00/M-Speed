import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

void main() {
  group('Live Admin Impersonate All Roles E2E Test', () {
    const baseUrl = 'http://127.0.0.1:8000/api';
    final client = http.Client();

    test('Admin impersonates Manager, Finance, Receiver, Buyer, Seller, and stops cleanly', () async {
      // 1. Login as Admin
      final loginRes = await client.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: jsonEncode({'email': 'admin@example.com', 'password': 'password123'}),
      );

      expect(loginRes.statusCode, isIn([200, 201]));
      final loginJson = jsonDecode(loginRes.body);
      String adminToken = loginJson['meta']?['access_token'] ?? loginJson['data']?['token'];
      expect(adminToken, isNotEmpty);
      print('1. Admin Login: SUCCESS (Token acquired)');

      final rolesToTest = [
        {'id': 1, 'role': 'manager', 'expectedRoute': '/managerHome'},
        {'id': 41, 'role': 'finance', 'expectedRoute': '/keuanganHome'},
        {'id': 61, 'role': 'receiver', 'expectedRoute': '/penerimaHome'},
        {'id': 21, 'role': 'buyer', 'expectedRoute': '/home'},
        {'id': 121, 'role': 'seller', 'expectedRoute': '/sellerHome'},
      ];

      for (final target in rolesToTest) {
        final targetId = target['id'];
        final roleName = target['role'] as String;

        // A. POST /api/impersonate/{id}
        final impRes = await client.post(
          Uri.parse('$baseUrl/impersonate/$targetId'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $adminToken',
          },
        );

        expect(impRes.statusCode, isIn([200, 201]), reason: 'Failed to impersonate $roleName: ${impRes.body}');
        final impJson = jsonDecode(impRes.body);
        expect(impJson['status'], isTrue);
        
        final impersonatedData = impJson['data'];
        final impersonateToken = impersonatedData['access_token'] as String;
        final returnedRole = impersonatedData['user']['role'].toString().toLowerCase();
        expect(returnedRole, equals(roleName));
        expect(impersonateToken, isNotEmpty);

        print('   ✅ Admin → $roleName (ID $targetId): SUCCESS (Token acquired, target role=$returnedRole)');

        // B. POST /api/impersonate/stop
        final stopRes = await client.post(
          Uri.parse('$baseUrl/impersonate/stop'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $impersonateToken',
          },
          body: jsonEncode({'admin_id': 141}),
        );

        expect(stopRes.statusCode, isIn([200, 201]), reason: 'Failed to stop impersonating $roleName: ${stopRes.body}');
        final stopJson = jsonDecode(stopRes.body);
        expect(stopJson['status'], isTrue);
        final restoredAdminToken = stopJson['data']?['access_token'];
        if (restoredAdminToken != null && restoredAdminToken.toString().isNotEmpty) {
          adminToken = restoredAdminToken.toString();
        }
        print('   ✅ $roleName → Admin: STOP SUCCESS (Admin session restored)');
      }
    }, timeout: const Timeout(Duration(minutes: 2)));
  });
}
