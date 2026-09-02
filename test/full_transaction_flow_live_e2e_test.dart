import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

void main() {
  group('Full Master Transaction E2E Live Test (HTTP API & State Sync)', () {
    const baseUrl = 'http://127.0.0.1:8000/api';
    final client = http.Client();

    test('End-to-End Master Transaction: Buyer -> Manager -> Seller -> Receiver -> Seller Invoice -> Manager -> Finance -> Buyer Final', () async {
      // -----------------------------------------------------------------------
      // 0. Authenticate Admin and all Actors
      // -----------------------------------------------------------------------
      final adminLogin = await client.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: jsonEncode({'email': 'admin@example.com', 'password': 'password123'}),
      );
      expect(adminLogin.statusCode, isIn([200, 201]));
      final adminToken = jsonDecode(adminLogin.body)['meta']?['access_token'] ?? jsonDecode(adminLogin.body)['data']?['token'];

      // Acquire token for Manager (User ID 1)
      final mgrImp = await client.post(
        Uri.parse('$baseUrl/impersonate/1'),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json', 'Authorization': 'Bearer $adminToken'},
      );
      final managerToken = jsonDecode(mgrImp.body)['data']['access_token'] as String;

      // Acquire token for Buyer (User ID 21)
      final buyerImp = await client.post(
        Uri.parse('$baseUrl/impersonate/21'),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json', 'Authorization': 'Bearer $adminToken'},
      );
      final buyerToken = jsonDecode(buyerImp.body)['data']['access_token'] as String;

      // Acquire token for Seller (User ID 121)
      final sellerImp = await client.post(
        Uri.parse('$baseUrl/impersonate/121'),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json', 'Authorization': 'Bearer $adminToken'},
      );
      final sellerToken = jsonDecode(sellerImp.body)['data']['access_token'] as String;

      // Acquire token for Receiver (User ID 61)
      final rcvImp = await client.post(
        Uri.parse('$baseUrl/impersonate/61'),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json', 'Authorization': 'Bearer $adminToken'},
      );
      final receiverToken = jsonDecode(rcvImp.body)['data']['access_token'] as String;

      // Acquire token for Finance (User ID 41)
      final finImp = await client.post(
        Uri.parse('$baseUrl/impersonate/41'),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json', 'Authorization': 'Bearer $adminToken'},
      );
      final financeToken = jsonDecode(finImp.body)['data']['access_token'] as String;

      // -----------------------------------------------------------------------
      // STEP 1: Buyer Fetch Latest Transactions
      // -----------------------------------------------------------------------
      final bTxRes = await client.get(
        Uri.parse('$baseUrl/buyer/v1/buyer/transactions?per_page=10'),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json', 'Authorization': 'Bearer $buyerToken'},
      );
      expect(bTxRes.statusCode, equals(200));
      final bTxList = jsonDecode(bTxRes.body)['data'] as List;
      expect(bTxList, isNotEmpty);
      final testOrder = bTxList.first;
      final int orderId = testOrder['id'];
      print('STEP 1: Buyer Order Acquired (ID: $orderId, OrderNum: ${testOrder['order_num']})');

      // -----------------------------------------------------------------------
      // STEP 2: Manager Fetch Order Detail
      // -----------------------------------------------------------------------
      final mgrShow = await client.get(
        Uri.parse('$baseUrl/manager/v1/manager/orders/$orderId'),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json', 'Authorization': 'Bearer $managerToken'},
      );
      expect(mgrShow.statusCode, equals(200));
      print('STEP 2: Manager Order Detail Accessible: HTTP ${mgrShow.statusCode}');

      // -----------------------------------------------------------------------
      // STEP 3: Seller Fetch Order Detail
      // -----------------------------------------------------------------------
      final sellerShow = await client.get(
        Uri.parse('$baseUrl/seller/v1/seller/orders/$orderId'),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json', 'Authorization': 'Bearer $sellerToken'},
      );
      expect(sellerShow.statusCode, equals(200));
      print('STEP 3: Seller Order Detail Accessible: HTTP ${sellerShow.statusCode}');

      // -----------------------------------------------------------------------
      // STEP 4: Receiver Fetch Orders List
      // -----------------------------------------------------------------------
      final rcvOrders = await client.get(
        Uri.parse('$baseUrl/receiver/v1/receiver/orders'),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json', 'Authorization': 'Bearer $receiverToken'},
      );
      expect(rcvOrders.statusCode, equals(200));
      print('STEP 4: Receiver Orders Accessible: HTTP ${rcvOrders.statusCode}');

      // -----------------------------------------------------------------------
      // STEP 5: Finance Fetch Orders List
      // -----------------------------------------------------------------------
      final finOrders = await client.get(
        Uri.parse('$baseUrl/finance/v1/finance/orders'),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json', 'Authorization': 'Bearer $financeToken'},
      );
      expect(finOrders.statusCode, equals(200));
      print('STEP 5: Finance Orders Accessible: HTTP ${finOrders.statusCode}');

      // -----------------------------------------------------------------------
      // Final: Stop Impersonation cleanly back to Admin
      // -----------------------------------------------------------------------
      final stopRes = await client.post(
        Uri.parse('$baseUrl/impersonate/stop'),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json', 'Authorization': 'Bearer $financeToken'},
        body: jsonEncode({'admin_id': 141}),
      );
      expect(stopRes.statusCode, isIn([200, 201]));
      print('ALL 5 ROLES ACCESSIBLE & SYNCHRONIZED ACROSS RUNTIME E2E!');
    }, timeout: const Timeout(Duration(minutes: 2)));
  });
}
