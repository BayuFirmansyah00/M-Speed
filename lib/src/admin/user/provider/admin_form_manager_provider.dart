import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mspeed/common/base/base_controller.dart';
import 'package:mspeed/common/base/base_response.dart';
import 'package:mspeed/common/component/custom_navigator.dart';
import 'package:mspeed/common/helper/constant.dart';
import 'package:mspeed/src/admin/user/model/manager_admin_model.dart';
import 'package:mspeed/src/admin/user/view/user_data_admin_view.dart';
import 'package:mspeed/utils/utils.dart';

class AdminFormManagerProvider extends BaseController with ChangeNotifier {
  final TextEditingController firstNameC = TextEditingController();
  final TextEditingController lastNameC = TextEditingController();
  final TextEditingController emailC = TextEditingController();
  final TextEditingController phoneNumberC = TextEditingController();
  final TextEditingController alamatC = TextEditingController();

  void setData(ManagerAdminModelData? manager) {
    clearData();
    if (manager != null) {
      firstNameC.text = manager.firstname ?? '';
      lastNameC.text = manager.lastname ?? '';
      emailC.text = manager.email ?? '';
      phoneNumberC.text = manager.telp ?? '';
      alamatC.text = manager.alamat ?? '';
    }
  }

  void clearData() {
    firstNameC.clear();
    lastNameC.clear();
    emailC.clear();
    phoneNumberC.clear();
    alamatC.clear();
  }

  /// TODO KONFIRMASI KE BACKEND:
  /// - Nama field param (firstname/lastname/email/telp/alamat) apakah sudah benar
  /// - Path endpoint: 'creatermanageradmin' / 'editmanageradmin' ini ASUMSI
  ///   mengikuti pola 'createselleradmin' / 'editselleradmin'
  Future<void> sendManager(
    BuildContext context, {
    bool withLoading = false,
    String? managerId,
  }) async {
    if (withLoading) loading(true);
    var param = {
      'firstname': firstNameC.text,
      'lastname': lastNameC.text,
      'email': emailC.text,
      'telp': phoneNumberC.text,
      'alamat': alamatC.text,
    };
    if (managerId != null) param.addAll({'manager_id': managerId});

    final response = await post(
      Constant.BASE_API_FULL +
          '/${managerId != null ? 'edit' : 'create'}manageradmin',
      body: param,
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final model = BaseResponse.from(response);
      notifyListeners();
      await Utils.showSuccess(msg: model.message);
      await Future.delayed(Duration(seconds: 2), () {});
      CusNav.nPushReplace(
        context,
        UserDataAdminView(userType: UserDataType.MANAGER),
      );
      if (withLoading) loading(false);
    } else {
      final message = jsonDecode(response.body)["messages"]["error"];
      loading(false);
      throw Exception(message);
    }
  }

  /// TODO KONFIRMASI KE BACKEND: path endpoint 'hapusmanageradmin' ini ASUMSI
  Future<void> deleteManager(
    BuildContext context, {
    bool withLoading = false,
    String? managerId,
  }) async {
    if (withLoading) loading(true);
    var param = {'manager_id': managerId};

    final response = await post(
      Constant.BASE_API_FULL + '/hapusmanageradmin',
      body: param,
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final model = BaseResponse.from(response);
      notifyListeners();
      await Utils.showSuccess(msg: model.message);
      await Future.delayed(Duration(seconds: 2), () {});
      CusNav.nPushReplace(
        context,
        UserDataAdminView(userType: UserDataType.MANAGER),
      );
      if (withLoading) loading(false);
    } else {
      final message = jsonDecode(response.body)["messages"]["error"];
      loading(false);
      throw Exception(message);
    }
  }
}