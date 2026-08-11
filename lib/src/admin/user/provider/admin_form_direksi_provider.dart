import 'dart:async';
import 'dart:convert';

import 'package:mspeed/common/base/base_controller.dart';
import 'package:mspeed/common/base/base_response.dart';
import 'package:mspeed/common/component/custom_navigator.dart';
import 'package:mspeed/core/network/api_client.dart';
import 'package:dio/dio.dart';
import 'package:mspeed/common/helper/constant.dart';
import 'package:mspeed/src/admin/user/model/basic_user_admin_model.dart';
import 'package:mspeed/src/admin/user/view/user_data_admin_view.dart';
import 'package:flutter/material.dart';
import 'package:mspeed/utils/utils.dart';

class AdminFormDireksiProvider extends BaseController with ChangeNotifier {
  List<UserData> userData = [];
  final searchC = TextEditingController();

  final TextEditingController firstNameC = TextEditingController();
  final TextEditingController lastNameC = TextEditingController();
  final TextEditingController emailC = TextEditingController();
  final TextEditingController phoneNumberC = TextEditingController();
  final TextEditingController passwordC = TextEditingController();
  final TextEditingController cityC = TextEditingController();
  final TextEditingController alamatC = TextEditingController();
  bool isActive = true;

  setData(BasicUserAdminModelData? direksi) async {
    clearData();
    if (direksi != null) {
      firstNameC.text = direksi.firstname ?? '';
      lastNameC.text = direksi.lastname ?? '';
      emailC.text = direksi.email ?? '';
      phoneNumberC.text = direksi.telp ?? '';

      if (direksi.ID != null) {
        try {
          final res = await ApiClient().dio.get('/audit/v1/admin/direksi/${direksi.ID}');
          if (res.statusCode == 200 || res.statusCode == 201) {
            isActive = res.data['data']['status'] == 'active' ? true : false;
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
    isActive = true;
  }

  Future<void> sendDireksi(BuildContext context,
      {bool withLoading = false, String? direksiId}) async {
    if (emailC.text.trim().isEmpty) {
      return Utils.showFailed(msg: 'Email wajib diisi');
    }
    if (direksiId == null && passwordC.text.isEmpty) {
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
      'active': isActive,
    };
    if (passwordC.text.isNotEmpty) {
      param['password'] = passwordC.text;
    }

    try {
      final isEdit = direksiId != null;
      final url = isEdit ? '/audit/v1/admin/direksi/$direksiId' : '/audit/v1/admin/direksi';
      
      final response = isEdit 
        ? await ApiClient().dio.put(url, data: param)
        : await ApiClient().dio.post(url, data: param);

      if (response.statusCode == 200 || response.statusCode == 201) {
        notifyListeners();
        await Utils.showSuccess(msg: 'Data direksi berhasil disimpan!');
        await Future.delayed(const Duration(seconds: 2), () {});
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
}
