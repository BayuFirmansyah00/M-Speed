import 'dart:async';
import 'dart:convert';

import 'package:mspeed/common/base/base_controller.dart';
import 'package:mspeed/common/base/base_response.dart';
import 'package:mspeed/common/component/custom_navigator.dart';
import 'package:mspeed/common/helper/constant.dart';
import 'package:mspeed/src/admin/user/model/keuangan_admin_model.dart';
import 'package:mspeed/src/admin/user/view/user_data_admin_view.dart';
import 'package:flutter/material.dart';
import 'package:mspeed/utils/utils.dart';

class AdminFormKeuanganProvider extends BaseController with ChangeNotifier {
  List<UserData> userData = [];
  final searchC = TextEditingController();

  final TextEditingController firstNameC = TextEditingController();
  final TextEditingController lastNameC = TextEditingController();
  final TextEditingController emailC = TextEditingController();
  final TextEditingController phoneNumberC = TextEditingController();
  final TextEditingController alamatC = TextEditingController();
  final TextEditingController cityC = TextEditingController();
  final TextEditingController passwordC = TextEditingController();

  KeuanganAdminModel keuanganAdminModel = KeuanganAdminModel();

  setData(KeuanganAdminModelData? keuangan) async {
    clearData();
    if (keuangan != null) {
      firstNameC.text = keuangan.firstname ?? '';
      lastNameC.text = keuangan.lastname ?? '';
      emailC.text = keuangan.email ?? '';
      phoneNumberC.text = keuangan.telp ?? '';
      alamatC.text = keuangan.alamat ?? '';
      cityC.text = keuangan.kabkota ?? '';
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
  }

  Future<void> sendKeuangan(BuildContext context,
      {bool withLoading = false, String? keuanganId}) async {
    if (withLoading) loading(true);
    var param = {
      'email': emailC.text,
      'password': passwordC.text,
      'firstname': firstNameC.text,
      'lastname': lastNameC.text,
      'telp': phoneNumberC.text,
      'alamat': alamatC.text,
      'kabkota': cityC.text,
    };
    if (keuanganId != null) param.addAll({'keuangan_id': keuanganId});

    final response = await post(
        Constant.BASE_API_FULL +
            '/${keuanganId != null ? 'edit' : 'create'}keuanganadmin',
        body: param);

    if (response.statusCode == 201 || response.statusCode == 200) {
      final model = BaseResponse.from(response);
      notifyListeners();
      await Utils.showSuccess(msg: model.message);
      await Future.delayed(Duration(seconds: 2), () {});
      CusNav.nPushReplace(
          context, UserDataAdminView(userType: UserDataType.FINANCE));

      if (withLoading) loading(false);
    } else {
      final message = jsonDecode(response.body)["messages"]["error"];
      loading(false);
      throw Exception(message);
    }
  }

  Future<void> deleteKeuangan(BuildContext context,
      {bool withLoading = false, String? keuanganId}) async {
    if (withLoading) loading(true);
    var param = {'keuangan_id': keuanganId};

    final response =
        await post(Constant.BASE_API_FULL + '/hapuskeuanganadmin', body: param);

    if (response.statusCode == 201 || response.statusCode == 200) {
      final model = BaseResponse.from(response);
      notifyListeners();
      await Utils.showSuccess(msg: model.message);
      await Future.delayed(Duration(seconds: 2), () {});
      CusNav.nPushReplace(
          context, UserDataAdminView(userType: UserDataType.BUYER));

      if (withLoading) loading(false);
    } else {
      final message = jsonDecode(response.body)["messages"]["error"];
      loading(false);
      throw Exception(message);
    }
  }
}
