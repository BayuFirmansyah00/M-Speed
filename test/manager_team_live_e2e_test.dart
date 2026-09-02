import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mspeed/src/manager/team/model/manager_team_model.dart';

void main() {
  group('Live E2E Manager Team API Verification', () {
    const baseUrl = 'http://127.0.0.1:8000/api';
    final client = http.Client();

    test('Live Manager Team List E2E Verification', () async {
      // 1. Authenticate as Admin
      final loginRes = await client.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: jsonEncode({'email': 'admin@example.com', 'password': 'password123'}),
      );

      expect(loginRes.statusCode, isIn([200, 201]));
      final loginJson = jsonDecode(loginRes.body);
      final adminToken = loginJson['meta']?['access_token'] ?? loginJson['data']?['token'];
      expect(adminToken, isNotEmpty);

      // 2. Impersonate Manager (User ID 4)
      final impRes = await client.post(
        Uri.parse('$baseUrl/aimpersonate/4'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $adminToken',
        },
      );
      expect(impRes.statusCode, isIn([200, 201]));
      final impJson = jsonDecode(impRes.body);
      final managerToken = impJson['data']?['access_token'];
      expect(managerToken, isNotEmpty);
      print('1. Manager Impersonation: SUCCESS (Token acquired)');

      // 3. GET /api/manager/v1/manager/team
      final teamRes = await client.get(
        Uri.parse('$baseUrl/manager/v1/manager/team'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $managerToken',
        },
      );

      expect(teamRes.statusCode, 200);
      final teamJson = jsonDecode(teamRes.body);
      final teamModel = ManagerTeamModel.fromJson(teamJson);

      expect(teamModel.data, isNotNull);
      expect(teamModel.data!.isNotEmpty, isTrue);
      print('2. Manager Team loaded: ${teamModel.data!.length} members found');

      final firstMember = teamModel.data!.first;
      expect(firstMember.id, isNotNull);
      expect(firstMember.fullName, isNotEmpty);
      expect(firstMember.user, isNotNull);
      print('   -> Member #1: "${firstMember.fullName}"');
      print('   -> Email: "${firstMember.user?.email}" | Role: "${firstMember.user?.role}"');
      print('   -> Department: "${firstMember.department?.name}" (${firstMember.department?.subDirektorate ?? '-'})');
    });
  });
}
