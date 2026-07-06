import 'dart:async';
import 'dart:convert';

import 'package:mspeed/common/base/base_controller.dart';
import 'package:mspeed/common/base/base_response.dart';
import 'package:mspeed/common/component/custom_navigator.dart';
import 'package:mspeed/common/helper/constant.dart';
import 'package:mspeed/src/admin/home/model/buyer_admin_model.dart';
// import 'package:mspeed/src/admin/home/model/home_admin_model..dart';
import 'package:mspeed/src/admin/master/model/subdit_admin_model.dart';
import 'package:mspeed/src/admin/user/view/user_data_admin_view.dart';
import 'package:flutter/material.dart';
import 'package:mspeed/utils/utils.dart';

class AdminFormBuyerProvider extends BaseController with ChangeNotifier {
  List<UserData> userData = [];
  final searchC = TextEditingController();

  final TextEditingController firstNameC = TextEditingController();
  final TextEditingController lastNameC = TextEditingController();
  final TextEditingController emailC = TextEditingController();
  final TextEditingController subditC = TextEditingController();
  final TextEditingController phoneNumberC = TextEditingController();
  final TextEditingController alamatC = TextEditingController();
  final TextEditingController cityC = TextEditingController();
  final TextEditingController passwordC = TextEditingController();
  String? selectedSubdit;

  BuyerAdminModel buyerAdminModel = BuyerAdminModel();

  setData(BuyerAdminModelData? buyer) async {
    clearData();
    await fetchSubditAdmin();
    final subdit = subditAdminModel.data ?? [];
    if (buyer != null) {
      firstNameC.text = buyer.firstname ?? '';
      lastNameC.text = buyer.lastname ?? '';
      emailC.text = buyer.email ?? '';
      if (subdit.isNotEmpty) {
        selectedSubdit = buyer.subditId ?? '';
        subditC.text =
            subdit.firstWhere((e) => e?.id == buyer.subditId)?.subditName ?? '';
      }
      phoneNumberC.text = buyer.telp ?? '';
      alamatC.text = buyer.alamat ?? '';
      cityC.text = buyer.kabkota ?? '';
    }
  }

  clearData() {
    firstNameC.clear();
    lastNameC.clear();
    emailC.clear();
    subditC.clear();
    selectedSubdit = null;
    phoneNumberC.clear();
    passwordC.clear();
    alamatC.clear();
    cityC.clear();
  }

  Future<void> sendBuyer(BuildContext context,
      {bool withLoading = false, String? buyerId}) async {
    if (withLoading) loading(true);
    var param = {
      'email': emailC.text,
      'password': passwordC.text,
      'firstname': firstNameC.text,
      'lastname': lastNameC.text,
      'telp': phoneNumberC.text,
      'alamat': alamatC.text,
      'kabkota': cityC.text,
      'subdit_id': selectedSubdit ?? '',
    };
    if (buyerId != null) param.addAll({'buyer_id': buyerId});

    final response = await post(
        Constant.BASE_API_FULL +
            '/${buyerId != null ? 'edit' : 'create'}buyeradmin',
        body: param);

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

  Future<void> deleteBuyer(BuildContext context,
      {bool withLoading = false, String? buyerId}) async {
    if (withLoading) loading(true);
    var param = {'buyer_id': buyerId};

    final response =
        await post(Constant.BASE_API_FULL + '/hapusbuyeradmin', body: param);

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

  SubditAdminModel subditAdminModel = SubditAdminModel();
  TextEditingController subditSearchC = TextEditingController();

  Future<void> fetchSubditAdmin({bool withLoading = false}) async {
    if (withLoading) loading(true);
    Map<String, String> param = {};
    if (subditSearchC.text.isNotEmpty)
      param.addAll({'search': subditSearchC.text});
    final response =
        await get(Constant.BASE_API_FULL + '/getsubditadmin', body: param);

    if (response.statusCode == 201 || response.statusCode == 200) {
      subditAdminModel = SubditAdminModel.fromJson(jsonDecode(response.body));
      notifyListeners();

      if (withLoading) loading(false);
    } else {
      final message = jsonDecode(response.body)["messages"]["error"];
      loading(false);
      throw Exception(message);
    }
  }
}
