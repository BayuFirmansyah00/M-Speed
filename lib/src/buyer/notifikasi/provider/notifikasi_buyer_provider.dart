
import 'package:mspeed/utils/utils.dart';

import 'package:mspeed/common/base/base_controller.dart';
import 'package:flutter/material.dart';

import 'package:mspeed/src/buyer/notifikasi/model/notifikasi_model.dart';


class NotifikasiBuyerProvider extends BaseController with ChangeNotifier {
  NotifikasiModel _notifikasiModel = NotifikasiModel();
  NotifikasiModel get notifikasiModel => this._notifikasiModel;
  set notifikasiModel(NotifikasiModel value) => this._notifikasiModel = value;

  int _unreadCount = 0;
  int get unreadCount => _unreadCount;

  // GET NOTIFICATIONS
  Future<void> fetchNotification({bool withLoading = false}) async {
    if (withLoading) loading(true);
    Utils.showFailed(msg: 'Fitur ini belum tersedia pada API backend.');
    if (withLoading) loading(false);
  }

  // POST MARK READ NOTIFICATION
  Future<void> postMarkReadNotif(BuildContext context,
      {bool withLoading = false, required parentOrderId}) async {
    if (withLoading) loading(true);
    Utils.showFailed(msg: 'Fitur ini belum tersedia pada API backend.');
    if (withLoading) loading(false);
  }

  // POST MARK ALL READ NOTIFICATIONS
  Future<void> postMarkAllReadNotif(BuildContext context,
      {bool withLoading = false}) async {
    if (withLoading) loading(true);
    Utils.showFailed(msg: 'Fitur ini belum tersedia pada API backend.');
    if (withLoading) loading(false);
  }
}
