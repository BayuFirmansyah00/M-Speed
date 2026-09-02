import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mspeed/common/base/base_controller.dart';
import 'package:mspeed/common/helper/constant.dart';
import 'package:mspeed/src/buyer/cart/model/buyer_nego_model.dart';

class BuyerNegoProvider extends BaseController with ChangeNotifier {
  bool isSubmitting = false;
  bool isApproving = false;
  int? processingCartId;
  BuyerNegoModel? latestNego;
  BuyerNegoModel? approvedNego;
  String? errorMessage;

  bool isCartProcessing(int cartId) =>
      processingCartId == cartId && (isSubmitting || isApproving);

  Future<void> submitNego({
    required int cartId,
    required double value,
    String? buyerNote,
    required Function(String message) onSuccess,
    required Function(String message) onError,
  }) async {
    if (isSubmitting || isApproving) return;

    isSubmitting = true;
    processingCartId = cartId;
    errorMessage = null;
    notifyListeners();

    try {
      final url = Constant.BASE_API_FULL + '/buyer/v1/buyer/cart/nego';

      final Map<String, dynamic> payload = {
        'cart_id': cartId.toString(),
        'value': value.toString(),
        'buyer_note': (buyerNote != null && buyerNote.trim().isNotEmpty) ? buyerNote.trim() : '',
      };

      final response = await post(url, body: payload);
      final decoded = json.decode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        if (decoded['data'] != null) {
          latestNego = BuyerNegoModel.fromJson(decoded['data']);
        }
        final msg = decoded['message'] ?? 'Penawaran harga berhasil dikirim.';
        onSuccess(msg);
      } else {
        String errMsg = 'Terjadi kesalahan pada server';
        if (decoded['message'] != null) {
          errMsg = decoded['message'].toString();
        } else if (decoded['errors'] != null) {
          if (decoded['errors'] is Map) {
            errMsg = (decoded['errors'] as Map).values.first[0].toString();
          } else {
            errMsg = decoded['errors'].toString();
          }
        }
        errorMessage = errMsg;
        onError(errMsg);
      }
    } catch (e) {
      final errMsg = 'Terjadi kesalahan jaringan: $e';
      errorMessage = errMsg;
      onError(errMsg);
    } finally {
      isSubmitting = false;
      processingCartId = null;
      notifyListeners();
    }
  }

  Future<bool> approveNego({
    required int cartId,
    Function(String message)? onSuccess,
    Function(String message)? onError,
  }) async {
    if (isApproving || isSubmitting) return false;

    isApproving = true;
    processingCartId = cartId;
    errorMessage = null;
    notifyListeners();

    try {
      final url = Constant.BASE_API_FULL + '/buyer/v1/buyer/cart/approve-nego';

      final Map<String, dynamic> payload = {
        'cart_id': cartId.toString(),
      };

      final response = await post(url, body: payload);
      final decoded = json.decode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (decoded['data'] != null) {
          approvedNego = BuyerNegoModel.fromJson(decoded['data']);
          latestNego = approvedNego;
        }
        final msg = decoded['message'] ??
            'Penawaran harga dari penjual berhasil disetujui (Deal).';
        onSuccess?.call(msg);
        return true;
      } else {
        String errMsg = 'Gagal menyetujui penawaran harga.';
        if (decoded['message'] != null) {
          errMsg = decoded['message'].toString();
        } else if (decoded['errors'] != null) {
          if (decoded['errors'] is Map) {
            errMsg = (decoded['errors'] as Map).values.first[0].toString();
          } else {
            errMsg = decoded['errors'].toString();
          }
        }
        errorMessage = errMsg;
        onError?.call(errMsg);
        return false;
      }
    } catch (e) {
      final errMsg = 'Terjadi kesalahan jaringan: $e';
      errorMessage = errMsg;
      onError?.call(errMsg);
      return false;
    } finally {
      isApproving = false;
      processingCartId = null;
      notifyListeners();
    }
  }
}
