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

    // GET /api/admin/dpp
    final response = await get(Constant.BASE_API_FULL + '/admin/dpp',
        body: search.isNotEmpty ? {"search": search} : {});

    if (response.statusCode == 201 || response.statusCode == 200) {
      dpp = DppAdminModel.fromJson(jsonDecode(response.body));
      notifyListeners();
      if (withLoading) loading(false);
    } else {
      final decoded = jsonDecode(response.body);
      final message = decoded['message'] ?? decoded['messages']?['error'] ?? 'Terjadi kesalahan';
      loading(false);
      throw Exception(message);
    }
  }

  final searchOrderC = TextEditingController();
  OrderAdminModel order = OrderAdminModel();

  Future<void> fetchList2(
      {bool withLoading = false,
      String search = ''}) async {
    if (withLoading) loading(true);

    // GET /api/admin/orders
    final response = await get(Constant.BASE_API_FULL + '/admin/orders',
        body: search.isNotEmpty ? {"search": search} : {});

    if (response.statusCode == 201 || response.statusCode == 200) {
      order = OrderAdminModel.fromJson(jsonDecode(response.body));
      notifyListeners();
      if (withLoading) loading(false);
    } else {
      final decoded = jsonDecode(response.body);
      final message = decoded['message'] ?? decoded['messages']?['error'] ?? 'Terjadi kesalahan';
      loading(false);
      throw Exception(message);
    }
  }
}
