// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:sibima/common/base/base_state.dart';
// import 'package:sibima/common/helper/safe_network_image.dart';
// import 'package:sibima/src/product/provider/product_provider.dart';
// import 'package:sibima/src/product/view/product_list_view.dart';
//
// import '../../../common/component/custom_appbar.dart';
// import '../../../common/helper/constant.dart';
//
// /// This is the [ProductCategoryView] class, which is a stateful widget that represents the view for displaying product categories.
// /// It extends [StatefulWidget] and overrides the [createState] method to return an instance of [_ProductCategoryViewState].
// /// The [_ProductCategoryViewState] class is a private state class that extends [BaseState] and contains the logic for initializing the state and building the widget tree.
// class ProductCategoryView extends StatefulWidget {
//   const ProductCategoryView({super.key});
//
//   @override
//   State<ProductCategoryView> createState() => _ProductCategoryViewState();
// }
//
// /// This is the private state class [_ProductCategoryViewState] for the [ProductCategoryView] widget.
// /// It extends [BaseState] and contains the logic for initializing the state and building the widget tree.
// class _ProductCategoryViewState extends BaseState<ProductCategoryView> {
//   /// This method is called when the state is initialized.
//   /// It fetches the product categories using the [ProductProvider] and sets the state.
//   @override
//   void initState() {
//     context.read<ProductProvider>().fetchProductCategories(withLoading: true);
//     super.initState();
//   }
//
//   /// This method builds the widget tree for the [ProductCategoryView].
//   /// It uses the [ProductProvider] to get the product categories and displays them in a grid view.
//   @override
//   Widget build(BuildContext context) {
//     final categoryP = context.watch<ProductProvider>();
//
//     /// This method returns the widget tree for displaying all the product categories in a grid view.
//     Widget kontenAllCategories() {
//       return GridView.count(
//         physics: NeverScrollableScrollPhysics(),
//         crossAxisCount: 4,
//         mainAxisSpacing: 1,
//         shrinkWrap: true,
//         children: List.generate(
//           categoryP.productCategoryModel.data?.length ?? 0,
//           (index) => Container(
//             margin: EdgeInsets.all(5),
//             child: InkWell(
//               onTap: () async {
//                 handleTap(
//                   () async {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) {
//                           return ProductListView(
//                             category: ((categoryP.productCategoryModel.data ??
//                                             [])[index]
//                                         ?.id ??
//                                     "-")
//                                 .toString(),
//                             keyword: "",
//                           );
//                         },
//                       ),
//                     );
//                   },
//                 );
//               },
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.start,
//                 children: [
//                   Expanded(
//                     child: SafeNetworkImage.circle(
//                       url: (categoryP.productCategoryModel.data ?? [])[index]
//                               ?.imagePath ??
//                           "-",
//                       radius: 40,
//                     ),
//                   ),
//                   Expanded(
//                     child: Text(
//                       (categoryP.productCategoryModel.data ?? [])[index]
//                               ?.name ??
//                           "-",
//                       textAlign: TextAlign.center,
//                       style: TextStyle(fontSize: 12.0),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       );
//     }
//
//     return Scaffold(
//       appBar: CustomAppBar.appBar(context, "All Categories",
//           color: Colors.white,
//           textStyle: TextStyle(
//             color: Constant.primaryColor,
//             fontFamily: 'Open-Sans',
//             fontWeight: FontWeight.w400,
//           ),
//           foregroundColor: Constant.primaryColor),
//       body: Container(
//         margin: EdgeInsets.fromLTRB(20, 30, 20, 20),
//         child: SingleChildScrollView(
//           child: kontenAllCategories(),
//         ),
//       ),
//     );
//   }
// }
