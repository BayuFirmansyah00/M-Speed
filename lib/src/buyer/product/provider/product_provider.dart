import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mspeed/common/base/base_controller.dart';
import '../../../../common/helper/constant.dart';
import '../model/product_model.dart';

class ProductProvider extends BaseController with ChangeNotifier {
  ProductModel _productModel = ProductModel();
  ProductModel get productModel => this._productModel;
  set productModel(ProductModel value) => this._productModel = value;

  Future<void> fetchDetailProduct(
      {bool withLoading = false, required String productId}) async {
    if (withLoading) loading(true);

    // GET /api/products/{id} — detail produk berdasarkan ID
    // Response: ProductResource { id, name, product_code, qty, price, size,
    //           description, seller: {id, name}, category: {id, name} }
    final response =
        await get(Constant.BASE_API_FULL + '/products/$productId');

    if (response.statusCode == 201 || response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      // Jika response membungkus dalam { data: {...} }
      final item = decoded['data'] ?? decoded;
      productModel = ProductModel.fromJson({'data': [item], 'meta': null});
      notifyListeners();
      if (withLoading) loading(false);
    } else {
      final decoded = jsonDecode(response.body);
      final message = decoded['message'] ?? decoded['messages']?['error'] ?? 'Terjadi kesalahan';
      loading(false);
      throw Exception(message);
    }
  }
}
