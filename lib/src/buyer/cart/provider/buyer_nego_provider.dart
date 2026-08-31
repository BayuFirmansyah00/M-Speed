import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mspeed/common/base/base_controller.dart';
import 'package:mspeed/common/helper/constant.dart';
import 'package:mspeed/src/buyer/cart/model/buyer_nego_model.dart';

class BuyerNegoProvider extends BaseController with ChangeNotifier {
  bool isSubmitting = false;
  int? processingCartId;
  BuyerNegoModel? latestNego;

  Future<void> submitNego({
    required int cartId,
    required double value,
    String? buyerNote,
    required Function(String message) onSuccess,
    required Function(String message) onError,
  }) async {
    if (isSubmitting) return;

    isSubmitting = true;
    processingCartId = cartId;
    notifyListeners();

    try {
      final url = Constant.BASE_API_FULL + '/buyer/v1/buyer/cart/nego';
      
      final Map<String, dynamic> payload = {
        'cart_id': cartId.toString(),
        'value': value.toString(),
      };
      
      if (buyerNote != null && buyerNote.isNotEmpty) {
        payload['buyer_note'] = buyerNote;
      }

      final response = await post(url, body: payload);
      final decoded = json.decode(response.body);

      if (response.statusCode == 201) {
        if (decoded['data'] != null) {
          latestNego = BuyerNegoModel.fromJson(decoded['data']);
        }
        final msg = decoded['message'] ?? 'Penawaran harga berhasil dikirim.';
        onSuccess(msg);
      } else {
        String errMsg = 'Terjadi kesalahan pada server';
        if (decoded['message'] != null) {
          errMsg = decoded['message'];
        } else if (decoded['errors'] != null) {
          errMsg = decoded['errors'].toString();
        }
        onError(errMsg);
      }
    } catch (e) {
      onError('Terjadi kesalahan jaringan: $e');
    } finally {
      isSubmitting = false;
      processingCartId = null;
      notifyListeners();
    }
  }
}
