import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../../common/base/base_controller.dart';
import '../../../../common/helper/constant.dart';
import '../model/region_model.dart';

class RegionProvider extends BaseController with ChangeNotifier {
  ProvinceModel _provinceModel = ProvinceModel();

  ProvinceModel get provinceModel => this._provinceModel;

  set provinceModel(ProvinceModel value) {
    this._provinceModel = value;
    notifyListeners();
  }

  CityModel _cityModel = CityModel();

  CityModel get cityModel => this._cityModel;

  set cityModel(CityModel value) {
    this._cityModel = value;
    notifyListeners();
  }

  DistrictModel _districtModel = DistrictModel();
  DistrictModel get districtModel => this._districtModel;

  set districtModel(DistrictModel value) {
    this._districtModel = value;
    notifyListeners();
  }

  SubDistrictModel _subDistrictModel = SubDistrictModel();
  SubDistrictModel get subDistrictModel => this._subDistrictModel;

  set subDistrictModel(SubDistrictModel value) {
    this._subDistrictModel = value;
    notifyListeners();
  }

  Future<void> fetchProvince({bool withLoading = false}) async {
    if (withLoading) loading(true);
    final response = await get(Constant.BASE_API_FULL + '/list-province');

    if (response.statusCode == 200) {
      final model = ProvinceModel.fromJson(jsonDecode(response.body));
      provinceModel = model;
      notifyListeners();
      if (withLoading) loading(false);
    } else {
      final message = jsonDecode(response.body)["messages"]["error"];
      loading(false);
      throw Exception(message);
    }
  }

  Future<void> fetchCity(String provinceId, {bool withLoading = false}) async {
    if (withLoading) loading(true);
    final response = await get(Constant.BASE_API_FULL + '/list-city', body: {
      "province_id": provinceId,
    });

    if (response.statusCode == 200) {
      final model = CityModel.fromJson(jsonDecode(response.body));
      cityModel = model;
      notifyListeners();
      if (withLoading) loading(false);
    } else {
      final message = jsonDecode(response.body)["messages"]["error"];
      loading(false);
      throw Exception(message);
    }
  }

  Future<void> fetchDistrict(String cityId, {bool withLoading = false}) async {
    if (withLoading) loading(true);
    final response = await get(Constant.BASE_API_FULL + '/list-district',
        body: {"city_id": cityId});

    if (response.statusCode == 200) {
      final model = DistrictModel.fromJson(jsonDecode(response.body));
      districtModel = model;
      notifyListeners();
      if (withLoading) loading(false);
    } else {
      final message = jsonDecode(response.body)["messages"]["error"];
      loading(false);
      throw Exception(message);
    }
  }

  Future<void> fetchSubDistrict(String districtId, String cityId,
      {bool withLoading = false}) async {
    if (withLoading) loading(true);
    final response = await get(Constant.BASE_API_FULL + '/list-subdistrict',
        body: {"district_id": districtId, "city_id": cityId});

    if (response.statusCode == 200) {
      final model = SubDistrictModel.fromJson(jsonDecode(response.body));
      subDistrictModel = model;
      notifyListeners();
      if (withLoading) loading(false);
    } else {
      final message = jsonDecode(response.body)["messages"]["error"];
      loading(false);
      throw Exception(message);
    }
  }
}
