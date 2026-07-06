import 'dart:convert';

import 'package:mspeed/common/base/base_controller.dart';
import 'package:flutter/material.dart';
import 'package:mspeed/common/helper/constant.dart';
import 'package:mspeed/src/seller/notifikasi/model/notifikasi_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotifikasiSellerProvider extends BaseController with ChangeNotifier {
  NotifikasiModel _notifikasiModel = NotifikasiModel();
  NotifikasiModel get notifikasiModel => this._notifikasiModel;
  set notifikasiModel(NotifikasiModel value) => this._notifikasiModel = value;

  int _unreadCount = 0;
  int get unreadCount => _unreadCount;

  // GET NOTIFICATIONS
  Future<void> fetchNotification({bool withLoading = false}) async {
    if (withLoading) loading(true);

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String sellerId = prefs.getString(Constant.kSetPrefId) ?? '';

    Map<String, String> body = {'seller_id': sellerId};
    final response =
        await get(Constant.BASE_API_FULL + '/getnotifseller', body: body);

    if (response.statusCode == 201 || response.statusCode == 200) {
      notifikasiModel = NotifikasiModel.fromJson(jsonDecode(response.body));

      _unreadCount = notifikasiModel.data
              ?.where((notif) => notif?.isRead != "Terbaca")
              .length ??
          0;

      notifyListeners();
      if (withLoading) loading(false);
    } else {
      final message = jsonDecode(response.body)["messages"]["error"];
      loading(false);
      throw Exception(message);
    }
  }

  // POST MARK READ NOTIFICATION
  Future<void> postMarkReadNotif(BuildContext context,
      {bool withLoading = false, required parentOrderId}) async {
    if (withLoading) loading(true);

    Map<String, String> param = {};

    param.addAll({'parent_order_id': parentOrderId});

    final response = await post(
      Constant.BASE_API_FULL + '/markreadnotifseller',
      body: param,
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      notifyListeners();
      if (withLoading) loading(false);
    } else {
      final message = jsonDecode(response.body)["messages"]["error"];
      loading(false);
      throw Exception(message);
    }
  }

  // POST MARK ALL READ NOTIFICATIONS
  Future<void> postMarkAllReadNotif(BuildContext context,
      {bool withLoading = false}) async {
    if (withLoading) loading(true);

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String sellerId = prefs.getString(Constant.kSetPrefId) ?? '';

    Map<String, String> param = {};

    param.addAll({'seller_id': sellerId});

    final response = await post(
      Constant.BASE_API_FULL + '/markallreadnotifseller',
      body: param,
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      notifyListeners();
      if (withLoading) loading(false);
    } else {
      final message = jsonDecode(response.body)["messages"]["error"];
      loading(false);
      throw Exception(message);
    }
  }
}
