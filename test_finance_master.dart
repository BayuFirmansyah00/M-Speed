import 'dart:convert';
import 'package:dio/dio.dart';

void main() async {
  var dio = Dio();
  try {
    var financeRes = await dio.get(
      'http://127.0.0.1:8000/api/v1/admin/finances/create',
      options: Options(
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer 33|zdVQfyXZXZkw73cjsVCfOsUSkVPaPPSnHHpIfv4G95ba3873',
        },
        validateStatus: (status) => true,
      ),
    );
    print(financeRes.data);
  } catch(e) {
    print(e);
  }
}
