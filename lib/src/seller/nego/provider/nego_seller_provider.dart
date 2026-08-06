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
    if (!isLoadMore) {
      negoSellerModel = NegoSellerModel();
      currentPage = 1;
    } else {
      currentPage++;
    }

    if (withLoading) loading(true);

    final userId = await SessionHelper.getSellerId();
    
    // TODO: Remove per_page=${Constant.maxPaginationPerPage} when infinite scroll is fully implemented in UI
    String endpoint = Constant.BASE_API_FULL + '${Constant.epNegos}?seller_id=$userId&page=$currentPage&per_page=${Constant.maxPaginationPerPage}';
    if (searchNegoC.text.isNotEmpty) {
      endpoint += '&search=${searchNegoC.text}';
    }

    try {
      final parsed = await getRest(endpoint);
      final responseModel = NegoSellerModel.fromJson(parsed);

      if (isLoadMore) {
        negoSellerModel.data?.addAll(responseModel.data ?? []);
        negoSellerModel.meta = responseModel.meta;
      } else {
        negoSellerModel = responseModel;
      }

      notifyListeners();
    } catch (e) {
      if (isLoadMore) currentPage--;
      Utils.showFailed(msg: e.toString());
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
      await postRest(
        Constant.BASE_API_FULL + '${Constant.epNegos}/$negoId/${isAccept ? 'accept' : 'reject'}',
        body: body,
      );

      final result = BaseResponse("Berhasil", true, null);
      notifyListeners();
      await Utils.showSuccess(msg: result.message);
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
      await postRest(
        Constant.BASE_API_FULL + '${Constant.epNegos}/$negoId',
        body: {'_method': 'PUT', 'value': body['harga']},
      );

      negoHargaC.clear();
      negoHargaN.unfocus();
      final result = BaseResponse("Berhasil", true, null);
      notifyListeners();
      await Utils.showSuccess(msg: result.message);
      await Future.delayed(Duration(seconds: 2));
    } catch (e) {
      throw Exception(e);
    } finally {
      if (withLoading) loading(false);
    }
  }
}
