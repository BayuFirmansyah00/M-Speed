import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mspeed/common/base/base_controller.dart';
import 'package:mspeed/common/component/custom_alert.dart';
import 'package:mspeed/common/helper/constant.dart';
import 'package:mspeed/src/buyer/checkout/model/buyer_checkout_model.dart';

class BuyerCheckoutProvider extends BaseController with ChangeNotifier {
  BuyerCheckoutResponse? _checkoutResponse;
  BuyerCheckoutResponse? get checkoutResponse => _checkoutResponse;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isUpdatingShipping = false;
  bool get isUpdatingShipping => _isUpdatingShipping;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Untuk update shipping per TempOrder
  Future<bool> updateShipping(BuildContext context, int tempOrderId, double cost) async {
    _isUpdatingShipping = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final Map<String, String> body = {
        'shipping_cost': cost.toString(),
      };

      final response = await put('${Constant.BASE_API_FULL}/buyer/v1/buyer/cart/$tempOrderId/shipping', body: body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        throw Exception(response.body);
      }
    } catch (e) {
      String errMsg = 'Gagal menyimpan ongkir';
      if (e.toString().contains('{')) {
        try {
          final errorObj = jsonDecode(e.toString().substring(e.toString().indexOf('{')));
          if (errorObj['message'] != null) {
            errMsg = errorObj['message'].toString();
          }
        } catch (_) {}
      } else {
        errMsg = e.toString().replaceAll('Exception: ', '');
      }
      
      if (context.mounted) {
        CustomAlert.showSnackBar(context, errMsg, true);
      }
      return false;
    } finally {
      _isUpdatingShipping = false;
      notifyListeners();
    }
  }

  Future<bool> checkout(
    BuildContext context, {
    required List<int> tempOrderIds,
    required int addressId,
    required DateTime estDeliveryStart,
    required DateTime estDeliveryEnd,
    int? taxId,
    int? prkSubmissionId,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Format YYYY-MM-DD
      String startFormat = "${estDeliveryStart.year}-${estDeliveryStart.month.toString().padLeft(2, '0')}-${estDeliveryStart.day.toString().padLeft(2, '0')}";
      String endFormat = "${estDeliveryEnd.year}-${estDeliveryEnd.month.toString().padLeft(2, '0')}-${estDeliveryEnd.day.toString().padLeft(2, '0')}";

      final Map<String, String> body = {
        'buyer_address_id': addressId.toString(),
        'est_delivery_start': startFormat,
        'est_delivery_end': endFormat,
      };

      if (taxId != null) {
        body['tax_id'] = taxId.toString();
      }
      if (prkSubmissionId != null) {
        body['prk_submission_id'] = prkSubmissionId.toString();
      }

      // Format array temp_order_ids untuk Laravel x-www-form-urlencoded
      for (int i = 0; i < tempOrderIds.length; i++) {
        body['temp_order_ids[$i]'] = tempOrderIds[i].toString();
      }

      if (kDebugMode) {
        debugPrint('==== FINAL CHECKOUT PAYLOAD ====');
        body.forEach((k, v) => debugPrint('  $k (${k.runtimeType}) => $v (${v.runtimeType})'));
        debugPrint('=================================');
      }

      final response = await postRest('${Constant.BASE_API_FULL}/buyer/v1/buyer/cart/checkout', body: body);
      _checkoutResponse = BuyerCheckoutResponse.fromJson(response);
      return true;
    } catch (e) {
      String errMsg = 'Gagal melakukan checkout';
      if (e.toString().contains('{')) {
        try {
          final errorObj = jsonDecode(e.toString().substring(e.toString().indexOf('{')));
          if (errorObj['message'] != null) {
            errMsg = errorObj['message'].toString();
          }
        } catch (_) {}
      } else {
        errMsg = e.toString().replaceAll('Exception: ', '');
      }

      _errorMessage = errMsg;
      if (context.mounted) {
        CustomAlert.showSnackBar(context, errMsg, true);
      }
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
