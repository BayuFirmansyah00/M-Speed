import 'dart:async';
import 'dart:convert';
import 'package:mspeed/common/base/base_response.dart';
import 'package:mspeed/src/seller/nego/model/nego_seller_model.dart';
import 'package:mspeed/utils/utils.dart';
import 'package:mspeed/common/helper/session_helper.dart';
import '../../../../common/base/base_controller.dart';
import '../../../../common/helper/constant.dart';
import 'package:flutter/material.dart';

class NegoSellerProvider extends BaseController with ChangeNotifier {
  NegoSellerModel _negoSellerModel = NegoSellerModel();
  NegoSellerModel get negoSellerModel => this._negoSellerModel;
  set negoSellerModel(NegoSellerModel value) => this._negoSellerModel = value;

  Duration duration = const Duration(seconds: 2);
  Timer? _searchOnStoppedTyping;
  Timer? get searchOnStoppedTyping => this._searchOnStoppedTyping;
  set searchOnStoppedTyping(Timer? value) {
    this._searchOnStoppedTyping = value;
    notifyListeners();
  }

  TextEditingController negoHargaC = TextEditingController();
  FocusNode negoHargaN = FocusNode();
  TextEditingController searchNegoC = TextEditingController();

  int currentPage = 1;

  Future<void> fetchNego({bool withLoading = false, bool isLoadMore = false}) async {
    if (withLoading) loading(true);
    Utils.showFailed(msg: 'Fitur ini belum tersedia pada API backend.');
    if (withLoading) loading(false);
  }

  Future<void> acceptOrRejectNego({
    bool withLoading = false,
    required String negoId,
    bool isAccept = true,
  }) async {
    Utils.showFailed(msg: 'Fitur ini belum tersedia pada API backend.');
    throw Exception('Fitur ini belum tersedia pada API backend.');
  }

  Future<void> requestNegoUlang({
    bool withLoading = false,
    required String negoId,
    bool isAccept = true,
  }) async {
    Utils.showFailed(msg: 'Fitur ini belum tersedia pada API backend.');
    throw Exception('Fitur ini belum tersedia pada API backend.');
  }
}
