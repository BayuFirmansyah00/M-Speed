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
    String endpoint = Constant.BASE_API_FULL + '/negos?seller_id=${userId ?? ''}';
    if (searchNegoC.text.isNotEmpty) {
      endpoint += '&search=${searchNegoC.text}';
    }

    try {
      final parsed = await getRest(endpoint);
      
      // Jika responsenya berupa List, bungkus jadi Map
      Map<String, dynamic> dataMap = {};
      if (parsed is List) {
        dataMap = {'result': 'success', 'data': parsed};
      } else if (parsed is Map<String, dynamic> && parsed.containsKey('data')) {
        dataMap = {'result': 'success', 'data': parsed['data']};
      } else {
        dataMap = {'result': 'success', 'data': parsed};
      }

      negoSellerModel = NegoSellerModel.fromJson(dataMap);
      notifyListeners();
    } catch (e) {
      throw Exception(e);
    } finally {
      if (withLoading) loading(false);
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
    try {
      final parsed = await postRest(
        Constant.BASE_API_FULL + '/negos/$negoId/${isAccept ? 'accept' : 'reject'}',
        body: body,
      );

      final result = BaseResponse("Berhasil", true, null);
      notifyListeners();
      await Utils.showSuccess(msg: result.message ?? "Berhasil");
      await Future.delayed(Duration(seconds: 2));
    } catch (e) {
      throw Exception(e);
    } finally {
      if (withLoading) loading(false);
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
    try {
      final parsed = await postRest(
        Constant.BASE_API_FULL + '/negos/$negoId',
        body: {'_method': 'PUT', 'value': body['harga']},
      );

      negoHargaC.clear();
      negoHargaN.unfocus();
      final result = BaseResponse("Berhasil", true, null);
      notifyListeners();
      await Utils.showSuccess(msg: result.message ?? "Berhasil");
      await Future.delayed(Duration(seconds: 2));
    } catch (e) {
      throw Exception(e);
    } finally {
      if (withLoading) loading(false);
    }
  }
}
