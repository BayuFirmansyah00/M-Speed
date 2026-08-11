import 'dart:convert';
import 'package:dio/dio.dart';
import 'lib/src/seller/profil/model/kota_model.dart';

void main() async {
  var dio = Dio();
  var citiesRes = await dio.get(
    'http://127.0.0.1:8000/api/cities',
    options: Options(headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer 33|zdVQfyXZXZkw73cjsVCfOsUSkVPaPPSnHHpIfv4G95ba3873',
    }),
  );
  
  KotaModel kotaModel = KotaModel.fromJson(citiesRes.data);
  String selectedProvinceId = "15"; // DI Yogyakarta
  
  List<KotaModelData?> filteredKotaList = [];
  if (kotaModel.data != null && selectedProvinceId != null) {
    filteredKotaList = kotaModel.data!
        .where((e) => e?.provinceId?.toString() == selectedProvinceId.toString())
        .toList();
  }
  
  var values = filteredKotaList.map((e) => e?.ID ?? '0').toList();
  var uniqueValues = values.toSet().toList();
  
  print('Total items: ${values.length}');
  print('Unique items: ${uniqueValues.length}');
  
  if (values.length != uniqueValues.length) {
    print('DUPLICATES FOUND!');
  } else {
    print('No duplicates found.');
  }
}
