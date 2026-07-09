import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mspeed/common/base/base_controller.dart';
import 'package:mspeed/common/base/base_response.dart';
import 'package:mspeed/common/component/custom_navigator.dart';
import 'package:mspeed/common/helper/constant.dart';
import 'package:mspeed/src/admin/user/model/audit_admin_model.dart';
import 'package:mspeed/src/admin/user/view/user_data_admin_view.dart';
import 'package:mspeed/utils/utils.dart';

class AdminFormAuditProvider extends BaseController with ChangeNotifier {
  final TextEditingController usernameC = TextEditingController();
  final TextEditingController fullnameC = TextEditingController();
  final TextEditingController passwordC = TextEditingController();

  void setData(AuditAdminModelData? audit) {
    clearData();
    if (audit != null) {
      usernameC.text = audit.username ?? '';
      fullnameC.text = audit.fullname ?? '';
      // password sengaja tidak di-prefill, wajib diisi ulang kalau mau diganti
    }
  }

  void clearData() {
    usernameC.clear();
    fullnameC.clear();
    passwordC.clear();
  }

  /// TODO KONFIRMASI KE BACKEND:
  /// - Apakah field 'password' wajib diisi setiap edit, atau boleh kosong
  ///   kalau tidak ingin mengubah password
  /// - Nama field param persis (username/fullname/password)
  /// - Path endpoint: 'createauditadmin' / 'editauditadmin' ini ASUMSI
  ///   mengikuti pola 'createmanageradmin' / 'editmanageradmin'
  Future<void> sendAudit(
    BuildContext context, {
    bool withLoading = false,
    String? auditId,
  }) async {
    if (withLoading) loading(true);
    var param = {
      'username': usernameC.text,
      'fullname': fullnameC.text,
    };
    if (passwordC.text.isNotEmpty) {
      param.addAll({'password': passwordC.text});
    }
    if (auditId != null) param.addAll({'audit_id': auditId});

    final response = await post(
      Constant.BASE_API_FULL +
          '/${auditId != null ? 'edit' : 'create'}auditadmin',
      body: param,
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final model = BaseResponse.from(response);
      notifyListeners();
      await Utils.showSuccess(msg: model.message);
      await Future.delayed(Duration(seconds: 2), () {});
      CusNav.nPushReplace(
        context,
        UserDataAdminView(userType: UserDataType.AUDIT),
      );
      if (withLoading) loading(false);
    } else {
      final message = jsonDecode(response.body)["messages"]["error"];
      loading(false);
      throw Exception(message);
    }
  }

  // NOTE: Tidak ada method deleteAudit -- di web admin, baris Audit
  // hanya punya tombol Edit, tidak ada tombol Hapus atau Ganti Sesi.
  // Kalau ternyata backend punya endpoint hapus, tinggal tambahkan
  // method serupa deleteManager() di sini.
}