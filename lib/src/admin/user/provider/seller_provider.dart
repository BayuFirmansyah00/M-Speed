import 'dart:async';
import 'dart:convert';

import 'package:mspeed/common/base/base_controller.dart';
import 'package:mspeed/common/helper/constant.dart';
import 'package:mspeed/src/admin/home/model/buyer_admin_model.dart';
// import 'package:mspeed/src/admin/home/model/home_admin_model..dart';
import 'package:mspeed/src/admin/user/view/user_data_admin_view.dart';
import 'package:flutter/material.dart';

class SellerProvider extends BaseController with ChangeNotifier {
  List<UserData> userData = [];
  final searchC = TextEditingController();


  BuyerAdminModel buyerAdminModel = BuyerAdminModel();
  Future<void> editSeller(
      {bool withLoading = false,
      }) async {
    if (withLoading) loading(true);

    final response = await post(Constant.BASE_API_FULL + '/editselleradmin');

    if (response.statusCode == 201 || response.statusCode == 200) {
      buyerAdminModel =
          BuyerAdminModel.fromJson(jsonDecode(response.body));
      buyerAdminModel.data?.forEach((v) {
        userData.add(UserData(
            name1: v?.firstname,
            name2: v?.lastname,
            email: v?.email,
            id: v?.ID,
            alamat: v?.alamat));
      });

      notifyListeners();

      if (withLoading) loading(false);
    } else {
      final message = jsonDecode(response.body)["messages"]["error"];
      loading(false);
      throw Exception(message);
    }
  }
}
