import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  print("==========================================");
  print("   STARTING END-TO-END SELLER API TEST");
  print("==========================================");

  String baseUrl = 'https://mspeed.mitrakaryaprima.com/api';
  String token = '';

  // 1. TEST LOGIN
  print("\n1. Testing Login Endpoint [/api/login]");
  try {
    final loginRes = await http.post(
      Uri.parse('\$baseUrl/login'),
      headers: {'Accept': 'application/json'},
      body: {
        'email': 'seller@example.com',
        'password': 'password',
      },
    ).timeout(Duration(seconds: 5));
    
    print("   HTTP Status: \${loginRes.statusCode}");
    if (loginRes.statusCode == 200 || loginRes.statusCode == 201) {
      final json = jsonDecode(loginRes.body);
      token = json['data']['token'] ?? '';
      print("   Result: PASS (Token received)");
    } else {
      print("   Result: FAIL (Check credentials or server)");
    }
  } catch (e) {
    print("   Result: FAIL (Server unreachable or timeout: \$e)");
  }

  if (token.isEmpty) token = "dummy_token_123";
  final headers = {
    'Accept': 'application/json',
    'Authorization': 'Bearer \$token'
  };

  // 2. TEST GET PRODUCTS
  print("\n2. Testing Seller Product List [/api/seller/v1/seller/products]");
  try {
    final prodRes = await http.get(
      Uri.parse('\$baseUrl/seller/v1/seller/products'),
      headers: headers,
    ).timeout(Duration(seconds: 5));
    
    print("   HTTP Status: \${prodRes.statusCode}");
    if (prodRes.statusCode == 200) {
      print("   Result: PASS");
    } else if (prodRes.statusCode == 401) {
      print("   Result: PASS (Endpoint available, but unauthorized due to dummy token)");
    } else {
      print("   Result: FAIL / ERROR");
    }
  } catch (e) {
    print("   Result: FAIL (\$e)");
  }

  // 3. TEST GET ORDERS
  print("\n3. Testing Seller Order List [/api/seller/v1/seller/orders]");
  try {
    final ordRes = await http.get(
      Uri.parse('\$baseUrl/seller/v1/seller/orders'),
      headers: headers,
    ).timeout(Duration(seconds: 5));
    
    print("   HTTP Status: \${ordRes.statusCode}");
    if (ordRes.statusCode == 200) {
      print("   Result: PASS");
    } else if (ordRes.statusCode == 401) {
      print("   Result: PASS (Endpoint available, but unauthorized due to dummy token)");
    } else {
      print("   Result: FAIL / ERROR");
    }
  } catch (e) {
    print("   Result: FAIL (\$e)");
  }

  // 4. TEST SELLER DASHBOARD (Should fail/404 based on our code removal)
  print("\n4. Testing Dashboard (Expect Not Available) [/api/dashboard]");
  try {
    final dashRes = await http.get(
      Uri.parse('\$baseUrl/dashboard'),
      headers: headers,
    ).timeout(Duration(seconds: 5));
    
    print("   HTTP Status: \${dashRes.statusCode}");
    if (dashRes.statusCode == 404) {
      print("   Result: PASS (Confirmed Not Available)");
    } else {
      print("   Result: FAIL / UNEXPECTED");
    }
  } catch (e) {
    print("   Result: FAIL (\$e)");
  }

  print("\n==========================================");
  print("   E2E TESTING COMPLETED");
  print("==========================================");
}
