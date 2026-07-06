import 'dart:async';
import 'dart:convert';
import 'package:mspeed/common/base/base_response.dart';
import 'package:mspeed/src/seller/nego/model/nego_seller_model.dart';
import 'package:mspeed/utils/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  Future<void> fetchNego({bool withLoading = false}) async {
    if (withLoading) loading(true);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userId = await prefs.getString(Constant.kSetPrefId);
    Map<String, String> body = {'seller_id': userId ?? ''};
    if (searchNegoC.text.isNotEmpty) {
      body.addAll({'search': searchNegoC.text});
    }
    final response = await get(
      Constant.BASE_API_FULL + '/getrequestnegoseller',
      body: body,
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      negoSellerModel = NegoSellerModel.fromJson(jsonDecode(response.body));
      notifyListeners();

      if (withLoading) loading(false);
    } else {
      final message = jsonDecode(response.body)["messages"]["error"];
      loading(false);
      throw Exception(message);
    }
  }

  Future<void> acceptOrRejectNego({
    bool withLoading = false,
    required String negoId,
    bool isAccept = true,
  }) async {
    if (withLoading) loading(true);

    Map<String, String> body = {'nego_id': negoId};
    if (isAccept && (negoSellerModel.data ?? []).isNotEmpty) {
      final nego = negoSellerModel.data?.firstWhere((e) => e?.ID == negoId);
      // String finalNego = '';
      // if (nego?.nego3 != null && nego?.nego3?.trim() != '')
      //   finalNego = nego?.nego3 ?? '';
      // else if (nego?.nego2 != null && nego?.nego2?.trim() != '')
      //   finalNego = nego?.nego2 ?? '';
      // else
      //   finalNego = nego?.nego ?? '';
      body.addAll({
        'negoseller1': nego?.nego ?? '',
        'negoseller2': nego?.nego2 ?? '',
        'negoseller3': nego?.nego3 ?? '',
      });
    }
    final response = await post(
      Constant.BASE_API_FULL +
          (isAccept ? '/acceptnegoseller' : '/rejectnegoseller'),
      body: body,
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final result = BaseResponse.from(response);
      notifyListeners();
      await Utils.showSuccess(msg: result.message);
      await Future.delayed(Duration(seconds: 2));
      if (withLoading) loading(false);
    } else {
      final message = jsonDecode(response.body)["messages"]["error"];
      loading(false);
      throw Exception(message);
    }
  }

  Future<void> requestNegoUlang({
    bool withLoading = false,
    required String negoId,
    bool isAccept = true,
  }) async {
    if (withLoading) loading(true);

    Map<String, String> body = {
      'nego_id': negoId,
      'harga': negoHargaC.text.replaceAll('.', ''),
    };
    final response = await post(
      Constant.BASE_API_FULL + '/negoulangseller',
      body: body,
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      negoHargaC.clear();
      negoHargaN.unfocus();
      final result = BaseResponse.from(response);
      notifyListeners();
      await Utils.showSuccess(msg: result.message);
      await Future.delayed(Duration(seconds: 2));
      if (withLoading) loading(false);
    } else {
      final message = jsonDecode(response.body)["messages"]["error"];
      loading(false);
      throw Exception(message);
    }
  }
}
