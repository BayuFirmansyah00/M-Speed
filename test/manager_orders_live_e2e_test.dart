import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mspeed/src/manager/pesanan/model/manager_order_model.dart';

void main() {
  group('Live E2E Manager Orders API & Action Verification', () {
    const baseUrl = 'http://127.0.0.1:8000/api';
    final client = http.Client();

    test('Live Manager Orders List & Detail E2E Verification', () async {
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

      // 3. GET /api/manager/v1/manager/orders
      final ordersRes = await client.get(
        Uri.parse('$baseUrl/manager/v1/manager/orders'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $managerToken',
        },
      );

      expect(ordersRes.statusCode, 200);
      final ordersJson = jsonDecode(ordersRes.body);
      final ordersModel = ManagerOrderModel.fromJson(ordersJson);

      expect(ordersModel.data, isNotNull);
      expect(ordersModel.data!.isNotEmpty, isTrue);
      print('2. Manager Orders loaded: ${ordersModel.data!.length} orders found');

      final firstOrder = ordersModel.data!.first;
      expect(firstOrder.id, isNotNull);
      expect(firstOrder.orderNum, isNotEmpty);
      expect(firstOrder.buyer, isNotNull);
      expect(firstOrder.seller, isNotNull);
      print('   -> Order #1: "${firstOrder.orderNum}"');
      print('   -> Buyer: "${firstOrder.buyer?.buyerName}" (Recipient: ${firstOrder.buyer?.recipientName})');
      print('   -> Seller: "${firstOrder.seller?.companyName}"');
      print('   -> Latest Log Status: "${firstOrder.latestLog?.status ?? firstOrder.paymentStatus}"');

      // 4. GET /api/manager/v1/manager/orders/{id}
      final detailRes = await client.get(
        Uri.parse('$baseUrl/manager/v1/manager/orders/${firstOrder.id}'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $managerToken',
        },
      );

      expect(detailRes.statusCode, 200);
      final detailJson = jsonDecode(detailRes.body);
      final detailData = ManagerOrderData.fromJson(detailJson['data'] ?? detailJson);

      expect(detailData.id, firstOrder.id);
      expect(detailData.orderNum, firstOrder.orderNum);
      expect(detailData.orderItems, isNotNull);
      expect(detailData.orderLogs, isNotNull);
      expect(detailData.orderItems!.isNotEmpty, isTrue);
      print('3. Order Detail loaded: ${detailData.orderItems!.length} items, ${detailData.orderLogs!.length} logs');
      print('   -> Subtotal: Rp ${detailData.subtotal} | Grand Total: Rp ${detailData.grandTotal}');
      print('   -> canApproveOrder: ${detailData.canApproveOrder} | canApproveInvoice: ${detailData.canApproveInvoice}');

      // 5. Search Filter Test
      final searchRes = await client.get(
        Uri.parse('$baseUrl/manager/v1/manager/orders?search=${firstOrder.orderNum}'),
        headers: {'Accept': 'application/json', 'Authorization': 'Bearer $managerToken'},
      );
      expect(searchRes.statusCode, 200);
      final searchModel = ManagerOrderModel.fromJson(jsonDecode(searchRes.body));
      expect(searchModel.data, isNotNull);
      expect(searchModel.data!.any((o) => o.id == firstOrder.id), isTrue);
      print('4. Orders Search Filter success');
    });
  });
}
