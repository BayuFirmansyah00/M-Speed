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
  print('Total cities loaded: ${kotaModel.data?.length}');
  
  String selectedProvinceId = "15"; // DI Yogyakarta
  
  List<KotaModelData?> filteredKotaList = [];
  if (kotaModel.data != null && selectedProvinceId != null) {
    filteredKotaList = kotaModel.data!
        .where((e) => e?.provinceId?.toString() == selectedProvinceId.toString())
        .toList();
  }
  
  print('Filtered cities for province $selectedProvinceId: ${filteredKotaList.length}');
  for(var kota in filteredKotaList) {
    print('- ${kota?.kota} (ID: ${kota?.ID}, Prov: ${kota?.provinceId})');
  }
}
