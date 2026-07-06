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
    Map<String, String> body = {'ID': productId};
    final response =
        await get(Constant.BASE_API_FULL + '/getbuyerproduk', body: body);

    if (response.statusCode == 201 || response.statusCode == 200) {
      productModel = ProductModel.fromJson(jsonDecode(response.body));
      notifyListeners();
      if (withLoading) loading(false);
    } else {
      final message = jsonDecode(response.body)["messages"]["error"];
      loading(false);
      throw Exception(message);
    }
  }
}
