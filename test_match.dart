import 'dart:convert';
import 'package:dio/dio.dart';
import 'lib/src/seller/profil/model/provinsi_model.dart';
import 'lib/src/seller/profil/model/kota_model.dart';

void main() async {
  var dio = Dio();
  var provRes = await dio.get(
    'http://127.0.0.1:8000/api/provinces',
    options: Options(headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer 33|zdVQfyXZXZkw73cjsVCfOsUSkVPaPPSnHHpIfv4G95ba3873',
    }),
  );
  
  ProvinsiModel provinsiModel = ProvinsiModel.fromJson(provRes.data);
  
  String value = "Banten";
  
  var matchedProvince = provinsiModel.data?.firstWhere(
    (e) => e?.nama == value,
    orElse: () => null,
  );
  
  print('Matched Province: ${matchedProvince?.nama}');
  print('Matched ID: ${matchedProvince?.ID}');
  
  if (matchedProvince == null) {
    print('Failed to match! Let\'s print all provinces:');
    for (var p in provinsiModel.data!) {
      print('"${p?.nama}"');
    }
  }
}
