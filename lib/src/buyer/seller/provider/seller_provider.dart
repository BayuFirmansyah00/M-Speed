import 'dart:async';
import 'dart:convert';

import 'package:mspeed/src/buyer/seller/model/detail_seller_model.dart';
import 'package:mspeed/common/base/base_controller.dart';
import 'package:mspeed/common/helper/constant.dart';
import 'package:flutter/material.dart';
import 'package:mspeed/src/buyer/transaction/model/daftar_transaksi_buyer_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

// import '../../cart/model/shopping_cart_confirm_model.dart';
// import '../../cart/provider/shopping_cart_provider.dart';
import '../model/seller_home_model.dart';

class SellerProvider extends BaseController with ChangeNotifier {
  SellerHomeModel? _sellerHomeModel = SellerHomeModel();
  SellerHomeModel? get sellerHomeModel => this._sellerHomeModel;
  set sellerHomeModel(SellerHomeModel? value) => this._sellerHomeModel = value;

  TextEditingController searchC = TextEditingController();
  Duration duration = const Duration(seconds: 2);
  Timer? _searchOnStoppedTyping;
  Timer? get searchOnStoppedTyping => this._searchOnStoppedTyping;

  set searchOnStoppedTyping(Timer? value) {
    this._searchOnStoppedTyping = value;
    notifyListeners();
  }

  DetailSellerModel _sellerModel = DetailSellerModel();

  DetailSellerModel get sellerModel => _sellerModel;

  set sellerModel(DetailSellerModel value) {
    _sellerModel = value;
  }

  Future<void> fetchSellerHome(
      {bool withLoading = false, required String id}) async {
    if (withLoading) loading(true);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userId = await prefs.getString(Constant.kSetPrefId);
    Map<String, String> body = {'seller_id': id};
    final response =
        await get(Constant.BASE_API_FULL + '/dashboardseller', body: body);

    if (response.statusCode == 201 || response.statusCode == 200) {
      sellerModel = DetailSellerModel.fromJson(jsonDecode(response.body));
      notifyListeners();

      if (withLoading) loading(false);
    } else {
      final message = jsonDecode(response.body)["messages"]["error"];
      loading(false);
      throw Exception(message);
    }
  }


  DaftarTransaksiBuyerModel daftarTransaksi = DaftarTransaksiBuyerModel();
  Future<void> fetchTransaction(
      {bool withLoading = false, required String seller_id}) async {
    if (withLoading) loading(true);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString(Constant.kSetPrefId) ?? '1';

    final response = await get(
        Constant.BASE_API_FULL + '/getdaftartransksibuyer',
        body: {"buyer_id": userId, "seller_id": seller_id, "status": '1'});

    if (response.statusCode == 201 || response.statusCode == 200) {
      daftarTransaksi =
      DaftarTransaksiBuyerModel.fromJson(jsonDecode(response.body));

      if (withLoading) loading(false);
      notifyListeners(); // return model;
    } else {
      final message = jsonDecode(response.body)["messages"]["error"];
      loading(false);
      throw Exception(message);
    }
  }
}
