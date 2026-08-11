import 'dart:async';
import 'dart:convert';

import 'package:mspeed/common/base/base_controller.dart';
import 'package:mspeed/common/helper/constant.dart';
// import 'package:mspeed/src/admin/home/model/dashboard_admin_model.dart';
import 'package:mspeed/src/admin/transaksi/model/dpp_admin_model.dart';
import 'package:mspeed/src/admin/transaksi/model/order_admin_model.dart';
import 'package:flutter/material.dart';

class TransactionAdminProvider extends BaseController with ChangeNotifier {
  final searchC = TextEditingController();
  DppAdminModel dpp = DppAdminModel();

  Future<void> fetchList(
      {bool withLoading = false,
      String sellerId = "148",
      String search = ''}) async {
    if (withLoading) loading(true);

    try {
      // API endpoint /admin/dpp TIDAK TERSEDIA DI LARAVEL
      throw Exception('BACKEND API NOT AVAILABLE');
    } catch (e) {
      loading(false);
      throw Exception(e.toString());
    }
  }

  final searchOrderC = TextEditingController();
  OrderAdminModel order = OrderAdminModel();

  Future<void> fetchList2(
      {bool withLoading = false,
      String search = ''}) async {
    if (withLoading) loading(true);

    try {
      // API endpoint /admin/orders TIDAK TERSEDIA DI LARAVEL
      throw Exception('BACKEND API NOT AVAILABLE');
    } catch (e) {
      loading(false);
      throw Exception(e.toString());
    }
  }
}
