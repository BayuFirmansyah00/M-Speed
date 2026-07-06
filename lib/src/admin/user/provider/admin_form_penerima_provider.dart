import 'dart:async';
import 'dart:convert';

import 'package:mspeed/common/base/base_controller.dart';
import 'package:mspeed/common/base/base_response.dart';
import 'package:mspeed/common/component/custom_navigator.dart';
import 'package:mspeed/common/helper/constant.dart';
import 'package:mspeed/src/admin/user/model/penerima_admin_model.dart';
import 'package:mspeed/src/admin/user/view/user_data_admin_view.dart';
import 'package:flutter/material.dart';
import 'package:mspeed/utils/utils.dart';

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

  PenerimaAdminModel penerimaAdminModel = PenerimaAdminModel();

  setData(PenerimaAdminModelData? penerima) async {
    clearData();
    if (penerima != null) {
      firstNameC.text = penerima.firstname ?? '';
      lastNameC.text = penerima.lastname ?? '';
      emailC.text = penerima.email ?? '';
      phoneNumberC.text = penerima.telp ?? '';
      alamatC.text = penerima.alamat ?? '';
      cityC.text = penerima.kabkota ?? '';
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

  Future<void> sendPenerima(BuildContext context,
      {bool withLoading = false, String? penerimaId}) async {
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
    if (penerimaId != null) param.addAll({'penerima_id': penerimaId});

    final response = await post(
        Constant.BASE_API_FULL +
            '/${penerimaId != null ? 'edit' : 'create'}penerimaadmin',
        body: param);

    if (response.statusCode == 201 || response.statusCode == 200) {
      final model = BaseResponse.from(response);
      notifyListeners();
      await Utils.showSuccess(msg: model.message);
      await Future.delayed(Duration(seconds: 2), () {});
      CusNav.nPushReplace(
          context, UserDataAdminView(userType: UserDataType.PENERIMA));

      if (withLoading) loading(false);
    } else {
      final message = jsonDecode(response.body)["messages"]["error"];
      loading(false);
      throw Exception(message);
    }
  }

  Future<void> deletePenerima(BuildContext context,
      {bool withLoading = false, String? penerimaId}) async {
    if (withLoading) loading(true);
    var param = {'penerima_id': penerimaId};

    final response =
        await post(Constant.BASE_API_FULL + '/hapuspenerimaadmin', body: param);

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
