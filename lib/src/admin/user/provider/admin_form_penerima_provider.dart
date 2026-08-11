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
  final TextEditingController accessC = TextEditingController();
  bool isActive = true;

  String? selectedManagerId;
  List<Map<String, dynamic>> allManagers = [];

  PenerimaAdminModel penerimaAdminModel = PenerimaAdminModel();

  setData(PenerimaAdminModelData? penerima) async {
    clearData();
    await fetchMasterData();
    if (penerima != null) {
      firstNameC.text = penerima.firstname ?? '';
      lastNameC.text = penerima.lastname ?? '';
      emailC.text = penerima.email ?? '';
      phoneNumberC.text = penerima.telp ?? '';

      if (penerima.ID != null) {
        try {
          final res = await ApiClient().dio.get('/audit/v1/admin/receivers/${penerima.ID}');
          if (res.statusCode == 200 || res.statusCode == 201) {
            final Map<String, dynamic> data = res.data['data'] ?? {};
            final Map<String, dynamic> uData = data['user_data'] ?? {};
            isActive = data['status'] == 'active' ? true : false;
            accessC.text = uData['access']?.toString() ?? '';
            selectedManagerId = (uData['manager'] as Map<String, dynamic>?)?['id']?.toString();
          }
        } catch (e) {
          debugPrint("Failed to fetch detail: $e");
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
    accessC.clear();
    isActive = true;
    allManagers.clear();
    selectedManagerId = null;
  }

  Future<void> sendPenerima(BuildContext context,
      {bool withLoading = false, String? penerimaId}) async {
    if (emailC.text.trim().isEmpty) {
      return Utils.showFailed(msg: 'Email wajib diisi');
    }
    if (penerimaId == null && passwordC.text.isEmpty) {
      return Utils.showFailed(msg: 'Password wajib diisi untuk user baru');
    }
    if (firstNameC.text.trim().isEmpty) {
      return Utils.showFailed(msg: 'First Name wajib diisi');
    }

    if (withLoading) loading(true);
    var param = {
      'email': emailC.text,
      'first_name': firstNameC.text,
      'last_name': lastNameC.text,
      'phone': phoneNumberC.text,
      'access': accessC.text,
      'active': isActive,
    };
    
    if (selectedManagerId != null) {
      param['manager_id'] = selectedManagerId!;
    }
    
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
        CusNav.nPop(context, true);
      }
    } on DioException catch (e) {
      var decoded = e.response?.data;
      String errorMessage = 'Terjadi kesalahan saat menyimpan data.';
      if (decoded != null && decoded['message'] != null) {
        errorMessage = decoded['message'];
      }
      if (decoded != null && decoded['errors'] != null) {
        final errors = decoded['errors'] as Map<String, dynamic>;
        if (errors.isNotEmpty) {
          errorMessage = errors.values.first[0].toString();
        }
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
        allManagers = List<Map<String, dynamic>>.from(data['managers'] ?? []);
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Failed to fetch receiver master data: $e");
      Utils.showFailed(msg: "Maaf, data master belum bisa dimuat (Endpoint Backend belum siap).");
    }
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
        CusNav.nPop(context, true);
      }
    } catch (e) {
      Utils.showFailed(msg: e.toString());
    } finally {
      if (withLoading) loading(false);
    }
  }
}
