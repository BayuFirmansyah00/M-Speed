import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mspeed/src/manager/dashboard/model/manager_dashboard_model.dart';
import 'package:mspeed/src/buyer/home/model/buyer_dashboard_model.dart';

void main() {
  group('Live E2E Manager & Buyer Dashboard Synchronization Tests', () {
    const baseUrl = 'http://127.0.0.1:8000/api';
    final client = http.Client();

    test('Live Manager Dashboard API E2E Verification', () async {
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

      // 3. GET /api/manager/v1/manager/dashboard
      final dashRes = await client.get(
        Uri.parse('$baseUrl/manager/v1/manager/dashboard'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $managerToken',
        },
      );

      expect(dashRes.statusCode, 200);
      final dashJson = jsonDecode(dashRes.body);
      final model = ManagerDashboardModel.fromJson(dashJson);

      // Verify Products
      expect(model.products, isNotNull);
      expect(model.products!.isNotEmpty, isTrue);
      print('2. Manager Products loaded: ${model.products!.length} items in current page');

      final firstProd = model.products!.first;
      expect(firstProd.id, isNotNull);
      expect(firstProd.name, isNotEmpty);
      expect(firstProd.price, greaterThan(0));
      expect(firstProd.seller, isNotNull);
      expect(firstProd.category, isNotNull);
      print('   -> Product #1: "${firstProd.name}"');
      print('   -> Price: Rp ${firstProd.price}');
      print('   -> Seller: "${firstProd.seller?.companyName}" (${firstProd.seller?.cityName ?? 'City'})');
      print('   -> Category: "${firstProd.category?.name}"');
      print('   -> Stock: ${firstProd.qty}');

      // Verify Image Resolution
      if (firstProd.primaryImageUrl != null) {
        expect(firstProd.primaryImageUrl, isNotEmpty);
        expect(firstProd.primaryImageUrl, isNot(contains('/storage/asset_img_backend/')));
        print('   -> Resolved Image URL: ${firstProd.primaryImageUrl}');
      }

      // Verify Parent Orders & KPI Categorization
      expect(model.parentOrders, isNotNull);
      print('3. Manager Parent Orders loaded: ${model.parentOrders!.length} orders');
      expect(model.parentOrders!.length, greaterThan(0));
      for (final order in model.parentOrders!) {
        expect(order.statusCategory, isNotEmpty);
      }

      // 4. Category Filter Test
      if (model.categories != null && model.categories!.isNotEmpty) {
        final catId = model.categories!.first.id;
        final catRes = await client.get(
          Uri.parse('$baseUrl/manager/v1/manager/dashboard?category_id=$catId'),
          headers: {'Accept': 'application/json', 'Authorization': 'Bearer $managerToken'},
        );
        expect(catRes.statusCode, 200);
        final catModel = ManagerDashboardModel.fromJson(jsonDecode(catRes.body));
        expect(catModel.products, isNotNull);
        print('4. Category Filter ($catId) success: ${catModel.products!.length} products loaded');
      }

      // 5. Search Filter Test
      final searchRes = await client.get(
        Uri.parse('$baseUrl/manager/v1/manager/dashboard?search=Hand'),
        headers: {'Accept': 'application/json', 'Authorization': 'Bearer $managerToken'},
      );
      expect(searchRes.statusCode, 200);
      final searchModel = ManagerDashboardModel.fromJson(jsonDecode(searchRes.body));
      expect(searchModel.products, isNotNull);
      print('5. Search Filter ("Hand") success: ${searchModel.products!.length} products loaded');
    });

    test('Live Buyer Dashboard API E2E Verification', () async {
      // 1. Authenticate as Admin
      final loginRes = await client.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: jsonEncode({'email': 'admin@example.com', 'password': 'password123'}),
      );
      final loginJson = jsonDecode(loginRes.body);
      final adminToken = loginJson['meta']?['access_token'] ?? loginJson['data']?['token'];

      // 2. Impersonate Buyer (User ID 21)
      final impRes = await client.post(
        Uri.parse('$baseUrl/aimpersonate/21'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $adminToken',
        },
      );
      expect(impRes.statusCode, isIn([200, 201]));
      final impJson = jsonDecode(impRes.body);
      final buyerToken = impJson['data']?['access_token'];
      expect(buyerToken, isNotEmpty);
      print('1. Buyer Impersonation: SUCCESS (Token acquired)');

      // 3. GET /api/buyer/v1/buyer/dashboard
      final dashRes = await client.get(
        Uri.parse('$baseUrl/buyer/v1/buyer/dashboard'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $buyerToken',
        },
      );

      expect(dashRes.statusCode, 200);
      final dashJson = jsonDecode(dashRes.body);
      final buyerModel = BuyerDashboardModel.fromJson(dashJson['data'] ?? dashJson);

      expect(buyerModel.products, isNotNull);
      expect(buyerModel.products!.isNotEmpty, isTrue);
      print('2. Buyer Products loaded: ${buyerModel.products!.length} items');

      final firstBuyerProd = buyerModel.products!.first;
      expect(firstBuyerProd.name, isNotEmpty);
      expect(firstBuyerProd.price, greaterThan(0));
      print('   -> Buyer Product #1: "${firstBuyerProd.name}" | Price: Rp ${firstBuyerProd.price}');
      if (firstBuyerProd.images != null && firstBuyerProd.images!.isNotEmpty) {
        final img = firstBuyerProd.images!.first.imgUrl;
        expect(img, isNot(contains('/storage/asset_img_backend/')));
        print('   -> Buyer Resolved Image URL: $img');
      }
    });
  });
}
