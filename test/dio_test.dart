import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';

void main() {
  test('Dio interceptor path normalization with trailing slash baseUrl', () async {
    const baseUrl = 'http://10.0.2.2:8000/api';
    final normalizedBaseUrl = baseUrl.endsWith('/') ? baseUrl : '$baseUrl/';
    
    final dio = Dio(BaseOptions(baseUrl: normalizedBaseUrl));
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (!options.path.startsWith('http://') && !options.path.startsWith('https://')) {
            if (options.path.startsWith('/')) {
              options.path = options.path.substring(1);
            }
          }
          return handler.next(options);
        },
      ),
    );

    // Test 1: path with leading slash
    final req1 = RequestOptions(path: '/manager/v1/manager/dashboard', baseUrl: dio.options.baseUrl);
    dio.interceptors.first.onRequest(req1, RequestInterceptorHandler());
    expect(req1.uri.toString(), 'http://10.0.2.2:8000/api/manager/v1/manager/dashboard');

    // Test 2: path without leading slash
    final req2 = RequestOptions(path: 'manager/v1/manager/orders', baseUrl: dio.options.baseUrl);
    dio.interceptors.first.onRequest(req2, RequestInterceptorHandler());
    expect(req2.uri.toString(), 'http://10.0.2.2:8000/api/manager/v1/manager/orders');

    // Test 3: full url
    final req3 = RequestOptions(path: 'http://10.0.2.2:8000/api/custom', baseUrl: dio.options.baseUrl);
    dio.interceptors.first.onRequest(req3, RequestInterceptorHandler());
    expect(req3.uri.toString(), 'http://10.0.2.2:8000/api/custom');
  });
}
