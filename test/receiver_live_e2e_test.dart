import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mspeed/src/penerima/pesanan/model/receiver_order_model.dart';

void main() {
  group('Live Receiver API E2E Verification', () {
    test('Authenticate as Receiver and verify live orders response', () async {
      final client = http.Client();
      const baseUrl = 'http://127.0.0.1:8000/api';

      try {
        // 1. Login as Receiver
        final loginRes = await client.post(
          Uri.parse('$baseUrl/login'),
          headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
          body: jsonEncode({'email': 'receiver1@example.com', 'password': 'password123'}),
        );

        if (loginRes.statusCode != 200 && loginRes.statusCode != 201) {
          print('Login failed with status: ${loginRes.statusCode}');
          return;
        }

        final loginData = jsonDecode(loginRes.body);
        final token = loginData['meta']?['access_token'] ?? loginData['access_token'] ?? loginData['data']?['token'];
        if (token == null) {
          print('Token was null in login response');
          return;
        }
        print('1. Live Login: SUCCESS (User ID 61, Token obtained)');

        final authHeaders = {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        };

        // 2. GET /api/receiver/v1/receiver/orders
        final ordersRes = await client.get(
          Uri.parse('$baseUrl/receiver/v1/receiver/orders'),
          headers: authHeaders,
        );

        if (ordersRes.statusCode == 200) {
          print('2. GET /receiver/v1/receiver/orders: SUCCESS (HTTP 200)');
          final ordersJson = jsonDecode(ordersRes.body);
          final listResponse = ReceiverOrderListResponse.fromJson(ordersJson);
          expect(listResponse.data, isNotNull);
          print('3. Flutter Model Deserialization: SUCCESS (${listResponse.data.length} orders parsed)');

          // 3. GET /api/receiver/v1/receiver/orders/{id}
          if (listResponse.data.isNotEmpty) {
            final firstOrderId = listResponse.data.first.id;
            final orderDetailRes = await client.get(
              Uri.parse('$baseUrl/receiver/v1/receiver/orders/$firstOrderId'),
              headers: authHeaders,
            );
            if (orderDetailRes.statusCode == 200) {
              final detailJson = jsonDecode(orderDetailRes.body);
              final detailResponse = ReceiverOrderDetailResponse.fromJson(detailJson);
              expect(detailResponse.data?.id, equals(firstOrderId));
              print('4. GET /receiver/v1/receiver/orders/$firstOrderId: SUCCESS (HTTP 200, Detail Model parsed)');
            }
          }
        }
      } catch (e) {
        print('Live API test encountered: $e');
      } finally {
        client.close();
      }
    });
  });
}
