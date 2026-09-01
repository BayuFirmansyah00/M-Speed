import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mspeed/common/base/base_controller.dart';
import 'package:mspeed/common/component/custom_alert.dart';
import 'package:mspeed/common/helper/constant.dart';
import 'package:mspeed/src/buyer/cart/model/buyer_cart_model.dart';
import 'package:mspeed/utils/utils.dart';
import 'package:dio/dio.dart'; // Just in case we need it for error parsing, but we use BaseController

class BuyerCartProvider extends BaseController with ChangeNotifier {
  BuyerCartResponse? _cartResponse;
  BuyerCartResponse? get cartResponse => _cartResponse;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Track mana saja item yang sedang ditambahkan ke keranjang (untuk loading button)
  final Set<int> _addingProductIds = {};

  bool isAddingProduct(int productId) => _addingProductIds.contains(productId);

  // Track mana cart item yang sedang di-delete
  final Set<int> _deletingCartIds = {};
  bool isDeletingCart(int cartId) => _deletingCartIds.contains(cartId);

  int get totalCartItems {
    int total = 0;
    if (_cartResponse?.data?.tempOrders != null) {
      for (var order in _cartResponse!.data!.tempOrders) {
        total += order.carts.length;
      }
    }
    return total;
  }

  Future<void> fetchCart({bool withLoading = true}) async {
    if (withLoading) {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
    }

    try {
      final response = await getRest('${Constant.BASE_API_FULL}/buyer/v1/buyer/cart');
      _cartResponse = BuyerCartResponse.fromJson(response);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Gagal memuat keranjang: $e';
    } finally {
      if (withLoading) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> addToCart(BuildContext context, int productId, {int qty = 1}) async {
    _addingProductIds.add(productId);
    notifyListeners();

    try {
      final body = {
        'product_id': productId.toString(),
        'qty': qty.toString(),
      };

      await postRest('${Constant.BASE_API_FULL}/buyer/v1/buyer/cart', body: body);
      
      // Jika berhasil, refresh keranjang background
      await fetchCart(withLoading: false);
      
      if (context.mounted) {
        Utils.showSuccess(msg: 'Berhasil ditambahkan ke keranjang');
      }
    } catch (e) {
      String errMsg = 'Terjadi kesalahan jaringan';
      if (e.toString().contains('{')) {
        try {
          final errorObj = jsonDecode(e.toString().substring(e.toString().indexOf('{')));
          if (errorObj['errors'] != null && errorObj['errors'] is Map) {
             errMsg = errorObj['errors'].values.first[0].toString();
          } else if (errorObj['message'] != null) {
             errMsg = errorObj['message'].toString();
          }
        } catch (_) {}
      } else {
        errMsg = e.toString().replaceAll('Exception: ', '');
      }

      if (context.mounted) {
        CustomAlert.showSnackBar(context, errMsg, true);
      }
    } finally {
      _addingProductIds.remove(productId);
      notifyListeners();
    }
  }

  Future<void> removeFromCart(BuildContext context, int cartId) async {
    _deletingCartIds.add(cartId);
    notifyListeners();

    try {
      // BaseController deleteRest format
      await deleteRest('${Constant.BASE_API_FULL}/buyer/v1/buyer/cart/$cartId');
      
      // Jika berhasil, refresh keranjang background
      await fetchCart(withLoading: false);
      
      if (context.mounted) {
        Utils.showSuccess(msg: 'Produk dihapus dari keranjang');
      }
    } catch (e) {
      String errMsg = 'Gagal menghapus produk';
      if (context.mounted) {
        CustomAlert.showSnackBar(context, errMsg, true);
      }
    } finally {
      _deletingCartIds.remove(cartId);
      notifyListeners();
    }
  }
}
