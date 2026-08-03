import 'dart:async';
import 'dart:convert';

import 'package:mspeed/common/base/base_controller.dart';
import 'package:mspeed/common/base/base_response.dart';
import 'package:mspeed/common/component/custom_navigator.dart';
import 'package:mspeed/core/network/api_client.dart';
import 'package:dio/dio.dart';
import 'package:mspeed/common/helper/constant.dart';
import 'package:mspeed/src/admin/user/model/penerima_admin_model.dart';
import 'package:mspeed/src/admin/user/view/user_data_admin_view.dart';
import 'package:flutter/material.dart';
import 'package:mspeed/utils/utils.dart';
import 'package:mspeed/src/seller/profil/model/kota_model.dart';
import 'package:mspeed/src/seller/profil/model/provinsi_model.dart';

class AdminFormPenerimaProvider extends BaseController with ChangeNotifier {
  List<UserData> userData = [];
  final searchC = TextEditingController();

  final TextEditingController firstNameC = TextEditingController();
  final TextEditingController lastNameC = TextEditingController();
  final TextEditingController emailC = TextEditingController();
  final TextEditingController phoneNumberC = TextEditingController();
  final TextEditingController alamatC = TextEditingController();
  final TextEditingController cityC = TextEditingController();
  final TextEditingController passwordC = TextEditingController();
  final TextEditingController departmentC = TextEditingController();

  String? selectedDepartmentId;
  List<Map<String, dynamic>> allDepartments = [];

  ProvinsiModel? provinsiModel;
  String? selectedProvince;
  String? selectedProvinceId;

  KotaModel? kotaModel;
  String? selectedCity;
  String? selectedCityId;

  List<KotaModelData?> get filteredKotaList {
    if (kotaModel?.data == null) return [];
    if (selectedProvinceId == null) return [];
    return kotaModel!.data!
        .where((e) => e?.provinceId?.toString() == selectedProvinceId?.toString())
        .toList();
  }

  PenerimaAdminModel penerimaAdminModel = PenerimaAdminModel();

  setData(PenerimaAdminModelData? penerima) async {
    clearData();
    await fetchMasterData();
    await fetchProvinsi();
    await fetchKota();
    if (penerima != null) {
      firstNameC.text = penerima.firstname ?? '';
      lastNameC.text = penerima.lastname ?? '';
      emailC.text = penerima.email ?? '';
      phoneNumberC.text = penerima.telp ?? '';
      alamatC.text = penerima.alamat ?? '';
      selectedDepartmentId = penerima.subditId;

      // Set City
      String? cityName = penerima.kabkota;
      if (cityName != null && kotaModel?.data != null) {
        var matchedCity = kotaModel!.data!.firstWhere(
          (e) => e?.kota?.toLowerCase() == cityName.toLowerCase(),
          orElse: () => null,
        );
        if (matchedCity != null) {
          selectedCityId = matchedCity.ID;
          selectedProvinceId = matchedCity.provinceId;

          // Find Province name
          if (provinsiModel?.data != null) {
            var matchedProv = provinsiModel!.data!.firstWhere(
              (e) => e?.ID == selectedProvinceId,
              orElse: () => null,
            );
            selectedProvince = matchedProv?.nama;
          }
        }
      }
    }
  }

  clearData() {
    firstNameC.clear();
    lastNameC.clear();
    emailC.clear();
    phoneNumberC.clear();
    passwordC.clear();
    alamatC.clear();
    cityC.clear();
    departmentC.clear();
    allDepartments.clear();
    selectedDepartmentId = null;
    selectedProvince = null;
    selectedProvinceId = null;
    selectedCity = null;
    selectedCityId = null;
  }

  Future<void> sendPenerima(BuildContext context,
      {bool withLoading = false, String? penerimaId}) async {
    if (withLoading) loading(true);
    var param = {
      'email': emailC.text,
      'first_name': firstNameC.text,
      'last_name': lastNameC.text,
      'phone': phoneNumberC.text,
      'department_id': selectedDepartmentId ?? '1',
      'address_name': 'Utama',
      'address_phone': phoneNumberC.text,
      'city_id': selectedCityId ?? '1',
      'detail': alamatC.text,
    };
    if (passwordC.text.isNotEmpty) {
      param['password'] = passwordC.text;
    }

    try {
      final isEdit = penerimaId != null;
      final url = isEdit ? '/audit/v1/admin/receivers/$penerimaId' : '/audit/v1/admin/receivers';
      
      final response = isEdit 
        ? await ApiClient().dio.put(url, data: param)
        : await ApiClient().dio.post(url, data: param);

      if (response.statusCode == 200 || response.statusCode == 201) {
        notifyListeners();
        await Utils.showSuccess(msg: 'Data penerima berhasil disimpan!');
        await Future.delayed(Duration(seconds: 2), () {});
        CusNav.nPushReplace(
            context, UserDataAdminView(userType: UserDataType.PENERIMA));
      }
    } on DioException catch (e) {
      var decoded = e.response?.data;
      String errorMessage = 'Terjadi kesalahan saat menyimpan data.';
      if (decoded != null && decoded['message'] != null) {
        errorMessage = decoded['message'];
      }
      Utils.showFailed(msg: errorMessage);
    } catch (e) {
      Utils.showFailed(msg: e.toString());
    } finally {
      if (withLoading) loading(false);
    }
  }

  Future<void> fetchMasterData() async {
    try {
      final response = await ApiClient().dio.get('/audit/v1/admin/receivers/create');
      if (response.data['status'] == 'success') {
        final data = response.data['data'];
        allDepartments = List<Map<String, dynamic>>.from(data['departments'] ?? []);
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Failed to fetch receiver master data: $e");
    }
  }

  Future<void> fetchProvinsi({bool withLoading = false}) async {
    if (withLoading) loading(true);
    try {
      final response = await ApiClient().dio.get('/provinces');
      if (response.statusCode == 201 || response.statusCode == 200) {
        provinsiModel = ProvinsiModel.fromJson(response.data);
      }
    } catch (e) {
      debugPrint("Error Load Provinsi: $e");
    }
    notifyListeners();
    if (withLoading) loading(false);
  }

  Future<void> fetchKota({bool withLoading = false}) async {
    if (withLoading) loading(true);
    try {
      final response = await ApiClient().dio.get('/cities?per_page=-1');
      if (response.statusCode == 201 || response.statusCode == 200) {
        kotaModel = KotaModel.fromJson(response.data);
      }
    } catch (e) {
      debugPrint("Error Load Kota: $e");
    }
    notifyListeners();
    if (withLoading) loading(false);
  }

  Future<void> deletePenerima(BuildContext context,
      {bool withLoading = false, String? penerimaId}) async {
    if (penerimaId == null) return;
    if (withLoading) loading(true);

    try {
      final response = await ApiClient().dio.delete('/audit/v1/admin/receivers/$penerimaId');

      if (response.statusCode == 200 || response.statusCode == 201) {
        notifyListeners();
        await Utils.showSuccess(msg: 'Data penerima berhasil dihapus!');
        await Future.delayed(Duration(seconds: 2), () {});
        CusNav.nPushReplace(
            context, UserDataAdminView(userType: UserDataType.PENERIMA));
      }
    } catch (e) {
      Utils.showFailed(msg: e.toString());
    } finally {
      if (withLoading) loading(false);
    }
  }
}
