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

class AdminFormAuditProvider extends BaseController with ChangeNotifier {
  List<UserData> userData = [];
  final searchC = TextEditingController();

  final TextEditingController firstNameC = TextEditingController();
  final TextEditingController lastNameC = TextEditingController();
  final TextEditingController emailC = TextEditingController();
  final TextEditingController phoneNumberC = TextEditingController();
  final TextEditingController alamatC = TextEditingController();
  final TextEditingController cityC = TextEditingController();
  final TextEditingController passwordC = TextEditingController();

  setData(KeuanganAdminModelData? audit) async {
    clearData();
    if (audit != null) {
      firstNameC.text = audit.firstname ?? '';
      lastNameC.text = audit.lastname ?? '';
      emailC.text = audit.email ?? '';
      phoneNumberC.text = audit.telp ?? '';
      alamatC.text = audit.alamat ?? '';
      cityC.text = audit.kabkota ?? '';
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

  Future<void> sendAudit(BuildContext context,
      {bool withLoading = false, String? auditId}) async {
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
    if (auditId != null) param.addAll({'audit_id': auditId});

    final response = await post(
        Constant.BASE_API_FULL +
            '/${auditId != null ? 'edit' : 'create'}auditadmin',
        body: param);

    if (response.statusCode == 201 || response.statusCode == 200) {
      final model = BaseResponse.from(response);
      notifyListeners();
      await Utils.showSuccess(msg: model.message);
      await Future.delayed(const Duration(seconds: 2), () {});
      CusNav.nPushReplace(
          context, const UserDataAdminView(userType: UserDataType.AUDIT));

      if (withLoading) loading(false);
    } else {
      final message = jsonDecode(response.body)["messages"]["error"];
      loading(false);
      throw Exception(message);
    }
  }
}
