// import 'dart:convert';

// import 'package:mspeed/common/base/base_controller.dart';
// import 'package:mspeed/common/helper/constant.dart';
// import 'package:mspeed/src/product/model/product_variant_model.dart';
// import 'package:flutter/material.dart';

// import 'package:mspeed/utils/Utils.dart';

// class ProductVariantProvider extends BaseController with ChangeNotifier {
//   ProductVariantModel productVariantModel = ProductVariantModel();

//   ProductVariantModel get getProductVariantModel => productVariantModel;

//   set setProductVariantModel(ProductVariantModel productVariantModel) =>
//       this.productVariantModel = productVariantModel;

//   Future<void> fetchProductVariant(BuildContext context,
//       {required int id,
//       String? color,
//       String? size,
//       bool withLoading = false}) async {
//     if (withLoading) loading(true);

//     final response = await get(
//         Constant.BASE_API_FULL + '/product/${id}/variations',
//         body: {'color': color, 'size': size});

//     if (response.statusCode == 201 || response.statusCode == 200) {
//       setProductVariantModel =
//           ProductVariantModel.fromJson(jsonDecode(response.body));
//       notifyListeners();
//       if (withLoading) loading(false);
//     } else {
//       final message = jsonDecode(response.body)["messages"]["error"];
//       loading(false);
//       throw Exception(message);
//     }
//   }
// }
