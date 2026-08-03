import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../common/helper/constant.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  late Dio dio;

  factory ApiClient() {
    return _instance;
  }

  ApiClient._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: Constant.BASE_API_FULL,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Attach Bearer token on every request
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString(Constant.kSetPrefToken);
          
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          
          return handler.next(options); // continue
        },
        onResponse: (response, handler) {
          // We can centralize generic response parsing or logging here if needed
          return handler.next(response); // continue
        },
        onError: (DioException e, handler) async {
          // Handle 401 Unauthorized globally
          if (e.response?.statusCode == 401) {
            // Token expired or invalid
            final prefs = await SharedPreferences.getInstance();
            await prefs.remove(Constant.kSetPrefToken);
            // TODO: Navigate to Login Screen using a global navigator key or event bus
          }
          return handler.next(e); // continue
        },
      ),
    );
  }
}
