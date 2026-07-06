// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_rating_bar/flutter_rating_bar.dart';
// import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
// import 'package:provider/provider.dart';
// import 'package:mspeed/common/component/custom_button.dart';
// import 'package:mspeed/common/component/custom_container.dart';
// import 'package:mspeed/common/component/custom_searchbar.dart';
// import 'package:mspeed/common/helper/safe_network_image.dart';
// import 'package:mspeed/src/product/model/product_promo_model.dart';
// import 'package:mspeed/src/product/provider/product_provider.dart';
// import 'package:mspeed/src/product/view/product_detail_view.dart';
// import 'package:mspeed/src/cart/model/shopping_cart_model.dart';
// import 'package:mspeed/src/cart/provider/shopping_cart_provider.dart';
// import 'package:mspeed/src/product/view/product_detail_view_not_login.dart';
// import 'package:mspeed/utils/utils.dart';
// import 'package:sizer/sizer.dart';
// import 'package:mspeed/src/product/model/product_list_model.dart';
//
// import '../../../common/component/custom_loading_indicator.dart';
// import '../../../common/component/custom_textField.dart';
// import '../../../common/helper/constant.dart';
// import '../../../common/base/base_state.dart';
// import '../provider/product_filter_provider.dart';
//
// class ProductListViewNotLogin extends StatefulWidget {
//   final String keyword;
//   final String category;
//   final String collection;
//
//   const ProductListViewNotLogin(
//       {super.key, this.keyword = "", this.category = "", this.collection = ""});
//
//   static Widget create(
//           {String keyword = "",
//           String category = "",
//           String collection = ""}) =>
//       MultiProvider(
//         providers: [
//           ChangeNotifierProvider<ProductProvider>(
//               create: (context) => ProductProvider()),
//           ChangeNotifierProvider<ProductFilterProvider>(
//               create: (context) => ProductFilterProvider()),
//           ChangeNotifierProvider<SearchProvider>(
//               create: (context) => SearchProvider()),
//         ],
//         child: ProductListViewNotLogin(
//           keyword: keyword,
//           category: category,
//           collection: collection,
//         ),
//       );
//
//   @override
//   State<ProductListViewNotLogin> createState() =>
//       _ProductListViewNotLoginState();
// }
//
// class _ProductListViewNotLoginState extends BaseState<ProductListViewNotLogin> {
//   TextEditingController _searchController = TextEditingController();
//
//   void initState() {
//     final pP = context.read<ProductProvider>();
//     final searchP = context.read<SearchProvider>();
//     pP.pagingController.addPageRequestListener((pageKey) => pP.fetchProductList(
//         page: pageKey, withLoading: true, key: searchP.searchC.text));
//     context.read<SearchProvider>().searchC.text = widget.keyword;
//     // context.read<ShoppingCartProvider>().fetchShoppingCart(withLoading: true);
//     context.read<ProductProvider>().fetchFilterVendor(withLoading: true);
//     context.read<ProductProvider>().fetchFilterProductAttr(withLoading: true);
//     context.read<ProductProvider>().fetchFilterProductLabel(withLoading: true);
//     context.read<ProductProvider>().fetchFilterProductTag(withLoading: true);
//     context.read<ProductProvider>().fetchFilterProductBrand(withLoading: true);
//     context.read<ProductProvider>().fetchFilterRegion(withLoading: true);
//     context
//         .read<ProductProvider>()
//         .fetchProductCollection(context, withLoading: true);
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     // final cartP = context.watch<ShoppingCartProvider>();
//     final searchP = context.watch<SearchProvider>();
//     final filterP = context.watch<ProductFilterProvider>();
//     final productP = context.watch<ProductProvider>();
//     // final productPromoP =
//     //     context.watch<ProductProvider>().getProductListModel.data;
//     final pagingC = context.watch<ProductProvider>().pagingController;
//     final scrollC = context.watch<ProductProvider>().pageScroll;
//
//     final vendorP = productP.vendorFilterModel.data;
//     final vendorChipP = productP.vendorFilterChip;
//     final productAttrP = productP.productAttributeFilterModel.data;
//     final productAttrChipP = productP.attributeFilterChip;
//     final productLabelP = productP.productLabelFilterModel.data;
//     final productLabelChipP = productP.labelFilterChip;
//     final productTagP = productP.productTagFilterModel.data;
//     final productTagChipP = productP.tagFilterChip;
//     final productBrandP = productP.productBrandFilterModel.data;
//     final productBrandChipP = productP.brandFilterChip;
//     final regionP = productP.regionFilterModel.data;
//     final regionChipP = productP.regionFilterChip;
//     final productFilterP = productP.productFilterParamModel;
//     Widget itemGrid({
//       required String imagePath,
//       required String brand,
//       required String productName,
//       required double rating,
//       required String review,
//       required int normalPrice,
//       required List<String> label,
//       int discountPrice = 0,
//       void Function()? onTap,
//     }) {
//       List<Widget> generateLabel() {
//         List<Widget> list = [];
//         for (int i = 0; i < label.length; i++) {
//           list.add(Container(
//             margin: EdgeInsets.only(right: i == label.length - 1 ? 0 : 4),
//             padding: EdgeInsets.symmetric(horizontal: 2),
//             decoration: BoxDecoration(
//                 border: Border.all(color: Constant.primaryColor),
//                 borderRadius: BorderRadius.circular(5)),
//             child: FittedBox(
//               fit: BoxFit.scaleDown,
//               child: Text(
//                 label[i],
//                 style: Constant.blue12,
//               ),
//             ),
//           ));
//         }
//         return list;
//       }
//
//       return Center(
//         child: Container(
//           padding: EdgeInsets.all(8),
//           decoration: BoxDecoration(
//               color: Colors.white,
//               border: Border.all(
//                 width: 1,
//                 color: Constant.borderLightColor,
//               )),
//           child: InkWell(
//             onTap: onTap,
//             // () async {
//             //   handleTap(() async {
//             //     onTap;
//             //   });
//             // },
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisAlignment: MainAxisAlignment.start,
//               children: [
//                 Center(
//                   child: SafeNetworkImage(
//                     url: imagePath,
//                     width: 140,
//                     height: 140,
//                   ),
//                 ),
//                 Container(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     mainAxisAlignment: MainAxisAlignment.start,
//                     children: [
//                       Text(
//                         brand,
//                         style: Constant.brandGrey13,
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                       Container(
//                         height: 45,
//                         child: Text(
//                           productName,
//                           overflow: TextOverflow.ellipsis,
//                           maxLines: 2,
//                           style: Constant.productDark14,
//                         ),
//                       ),
//                       Row(
//                         children: generateLabel(),
//                       ),
//                       SizedBox(
//                         height: 4,
//                       ),
//                       Row(
//                         children: [
//                           RatingBar(
//                             ignoreGestures: true,
//                             initialRating: rating,
//                             direction: Axis.horizontal,
//                             allowHalfRating: true,
//                             itemCount: 5,
//                             itemSize: 12,
//                             ratingWidget: RatingWidget(
//                               full: Icon(Icons.star_rounded,
//                                   color: Colors.yellow.shade600),
//                               half: Icon(Icons.star_half_rounded,
//                                   color: Colors.yellow.shade600),
//                               empty: Icon(Icons.star_rounded,
//                                   color: Colors.grey.shade300),
//                             ),
//                             itemPadding:
//                                 const EdgeInsets.symmetric(horizontal: 0),
//                             onRatingUpdate: (double value) {},
//                           ),
//                           Flexible(
//                             child: Padding(
//                               padding: const EdgeInsets.only(left: 3),
//                               child: Text(
//                                 review + " reviews",
//                                 overflow: TextOverflow.ellipsis,
//                                 maxLines: 1,
//                                 // "${NumberFormat.compact().format(3014)} reviews",
//                                 style: Constant.grayRegular12,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                       Padding(
//                         padding: const EdgeInsets.only(bottom: 5),
//                         child: Row(
//                           children: [
//                             if (discountPrice != 0)
//                               Padding(
//                                 padding: const EdgeInsets.only(right: 5),
//                                 child: Text(
//                                   Utils.thousandSeparator(discountPrice),
//                                   overflow: TextOverflow.ellipsis,
//                                   maxLines: 2,
//                                   style: Constant.darkBold12,
//                                 ),
//                               ),
//                             if (discountPrice != 0)
//                               Text(
//                                 Utils.thousandSeparator(normalPrice),
//                                 overflow: TextOverflow.ellipsis,
//                                 maxLines: 2,
//                                 style: Constant.greyThrough12,
//                               ),
//                             if (discountPrice == 0)
//                               Padding(
//                                 padding: const EdgeInsets.only(right: 5),
//                                 child: Text(
//                                   Utils.thousandSeparator(normalPrice),
//                                   overflow: TextOverflow.ellipsis,
//                                   maxLines: 2,
//                                   style: Constant.darkBold12,
//                                 ),
//                               ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       );
//     }
//
//     filterChip(
//         {required String title,
//         required bool value,
//         Widget? label,
//         EdgeInsetsGeometry? labelPadding,
//         required void Function(bool)? onSelected}) {
//       return FilterChip(
//         label: label ?? Text(title),
//         onSelected: onSelected,
//         labelPadding: labelPadding,
//         selected: value,
//         selectedColor: Color.fromRGBO(15, 34, 121, 1),
//         backgroundColor: Colors.white,
//         showCheckmark: false,
//         labelStyle: TextStyle(
//             color: !value ? Constant.tertiaryColor : Colors.white,
//             fontWeight: FontWeight.w600),
//         shape: RoundedRectangleBorder(
//           side: BorderSide(color: Color.fromRGBO(157, 156, 156, 1)),
//           borderRadius: BorderRadius.circular(60),
//         ),
//       );
//     }
//
//     filterChipColor(
//         {required String title,
//         required bool value,
//         required Color color,
//         required void Function(bool)? onSelected}) {
//       return FilterChip(
//         avatar: Padding(
//           padding: const EdgeInsets.only(left: 4.0),
//           child: Container(
//             width: 19,
//             height: 19,
//             decoration: BoxDecoration(
//               color: color,
//               borderRadius: BorderRadius.all(
//                 Radius.circular(3.0),
//               ),
//             ),
//           ),
//         ),
//         label: Text(title),
//         onSelected: onSelected,
//         selected: value,
//         selectedColor: Constant.primaryColor,
//         backgroundColor: Colors.white,
//         showCheckmark: false,
//         labelStyle: TextStyle(
//             color: !value ? Constant.tertiaryColor : Colors.white,
//             fontWeight: FontWeight.w500),
//         shape: RoundedRectangleBorder(
//           side: BorderSide(color: Color.fromRGBO(157, 156, 156, 1)),
//           borderRadius: BorderRadius.circular(60),
//         ),
//       );
//     }
//
//     filterChipRating(
//         {required String title,
//         required bool value,
//         required void Function(bool)? onSelected}) {
//       return FilterChip(
//         avatar: Padding(
//           padding: const EdgeInsets.only(left: 4.0),
//           child: Icon(Icons.star, color: Colors.yellow.shade600, size: 19),
//         ),
//         label: Text(title),
//         onSelected: onSelected,
//         selected: value,
//         selectedColor: Constant.primaryColor,
//         backgroundColor: Colors.white,
//         showCheckmark: false,
//         labelStyle: TextStyle(
//             color: !value ? Constant.tertiaryColor : Colors.white,
//             fontWeight: FontWeight.w500),
//         shape: RoundedRectangleBorder(
//           side: BorderSide(color: Color.fromRGBO(157, 156, 156, 1)),
//           borderRadius: BorderRadius.circular(60),
//         ),
//       );
//     }
//
//     List<Widget> attrProduct(StateSetter sheetState) {
//       List<Widget> listW = [];
//       if ((productAttrP ?? []).isNotEmpty) {
//         for (int i = 0; i < (productAttrP ?? []).length; i++) {
//           final item1 = productAttrP?[i];
//           final attrList = productAttrP?[i]?.attributes ?? [];
//           if (attrList.isNotEmpty) {
//             listW.add(Padding(
//                 padding: EdgeInsets.symmetric(vertical: 10),
//                 child: Text(item1?.title ?? "", style: Constant.darkBold18)));
//             listW.add(
//               Wrap(
//                 spacing: 10,
//                 children: List.generate(
//                   attrList.length,
//                   (index) {
//                     final item = attrList[index];
//                     var itemChip = productAttrChipP[i][index];
//                     final attributeId = productFilterP.attributeId;
//                     if (item1?.displayLayout == 'visual')
//                       return filterChipColor(
//                         color: HexColor.fromHex(
//                             (item?.color ?? "-").replaceAll('#', '')),
//                         // color: Color(0xFFDA323F),
//                         title: item?.title ?? "-",
//                         value: itemChip,
//                         onSelected: (selected) => sheetState(() {
//                           productAttrChipP[i][index] = !itemChip;
//                           if (attributeId == "")
//                             productFilterP.attributeId = "${item?.id ?? 0}";
//                           else if (attributeId != "" && selected)
//                             productFilterP.attributeId =
//                                 "${attributeId},${item?.id ?? 0}";
//                           else if (attributeId != "" && !selected)
//                             productFilterP.attributeId = productFilterP
//                                 .attributeId
//                                 .replaceAll(attributeId, "");
//                           else if (!selected) {
//                             productFilterP.attributeId = "";
//                           }
//                         }),
//                       );
//                     return filterChip(
//                       title: item?.title ?? "-",
//                       value: itemChip,
//                       onSelected: (selected) => sheetState(() {
//                         productAttrChipP[i][index] = !itemChip;
//                       }),
//                     );
//                   },
//                 ),
//               ),
//             );
//           }
//           ;
//         }
//       }
//       return listW;
//     }
//
//     Widget filterAllWidget() => StatefulBuilder(
//           builder: (BuildContext context, StateSetter sheetState) {
//             return Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisSize: MainAxisSize.min,
//               children: <Widget>[
//                 SizedBox(height: 20),
//                 Text(
//                   'Filter',
//                   style: Constant.darkBold22,
//                 ),
//                 SizedBox(height: 20),
//                 Container(
//                   height: 1,
//                   decoration: BoxDecoration(color: Color(0xFFE9E9E9)),
//                 ),
//                 SizedBox(height: 10),
//                 Text(
//                   'Category',
//                   style: Constant.darkBold18,
//                 ),
//                 SizedBox(height: 10),
//                 Wrap(
//                   spacing: 10,
//                   children: List.generate(
//                     productTagP?.length ?? 0,
//                     (index) {
//                       final item = productTagP?[index];
//                       var itemChip = productTagChipP[index];
//                       final categoryId = productFilterP.categoryId;
//                       return filterChip(
//                         title: item?.name ?? "",
//                         value: itemChip,
//                         onSelected: (selected) => sheetState(() {
//                           productTagChipP[index] = !itemChip;
//                           if (categoryId == "") {
//                             productFilterP.categoryId = "${item?.id ?? 0}";
//                           } else if (categoryId != "" && selected) {
//                             productFilterP.categoryId =
//                                 "${categoryId},${item?.id ?? 0}";
//                           } else if (categoryId != "" && !selected) {
//                             productFilterP.categoryId = productFilterP
//                                 .categoryId
//                                 .replaceAll(categoryId, "");
//                           } else if (!selected) {
//                             productFilterP.categoryId = "";
//                           }
//                         }),
//                       );
//                     },
//                   ),
//                 ),
//                 SizedBox(height: 10),
//                 Container(
//                   height: 1,
//                   decoration: BoxDecoration(color: Color(0xFFE9E9E9)),
//                 ),
//                 SizedBox(height: 10),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       'Brand',
//                       style: Constant.darkBold18,
//                     ),
//                     InkWell(
//                       onTap: () async {
//                         handleTap(() async {});
//                       },
//                       child: Text(
//                         'View All',
//                         textAlign: TextAlign.center,
//                         style: Constant.blue12,
//                       ),
//                     ),
//                   ],
//                 ),
//                 SizedBox(height: 10),
//                 Wrap(
//                   spacing: 10,
//                   children: List.generate(
//                     productBrandP?.length ?? 0,
//                     (index) {
//                       final item = productBrandP?[index];
//                       var itemChip = productBrandChipP[index];
//                       final brandId = productFilterP.brandId;
//                       return filterChip(
//                         title: item?.name ?? "",
//                         value: itemChip,
//                         onSelected: (selected) => sheetState(() {
//                           productBrandChipP[index] = !itemChip;
//                           if (brandId == "") {
//                             productFilterP.brandId = "${item?.id ?? 0}";
//                           } else if (brandId == "" && selected) {
//                             productFilterP.brandId =
//                                 "${brandId},${item?.id ?? 0}";
//                           } else if (brandId != "" && !selected) {
//                             productFilterP.brandId =
//                                 productFilterP.brandId.replaceAll(brandId, "");
//                           } else if (!selected) {
//                             productFilterP.brandId = "";
//                           }
//                         }),
//                       );
//                     },
//                   ),
//                 ),
//                 SizedBox(height: 10),
//                 Container(
//                   height: 1,
//                   decoration: BoxDecoration(color: Color(0xFFE9E9E9)),
//                 ),
//                 SizedBox(height: 10),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       'Location',
//                       style: Constant.darkBold18,
//                     ),
//                     InkWell(
//                       onTap: () async {
//                         handleTap(() async {});
//                       },
//                       child: Text(
//                         'View All',
//                         textAlign: TextAlign.center,
//                         style: Constant.blue12,
//                       ),
//                     ),
//                   ],
//                 ),
//                 SizedBox(height: 10),
//                 Wrap(
//                   spacing: 10,
//                   children: List.generate(
//                     regionP?.length ?? 0,
//                     (index) {
//                       final item = regionP?[index];
//                       var itemChip = regionChipP[index];
//                       final regionId = productFilterP.regionId;
//                       return filterChip(
//                         title: item?.name ?? "",
//                         value: itemChip,
//                         onSelected: (selected) => sheetState(() {
//                           regionChipP[index] = !itemChip;
//                           if (regionId == "") {
//                             productFilterP.regionId = "${item?.id ?? 0}";
//                           } else if (regionId == "" && selected) {
//                             productFilterP.regionId =
//                                 "${regionId},${item?.id ?? 0}";
//                           } else if (regionId != "" && !selected) {
//                             productFilterP.regionId = productFilterP.regionId
//                                 .replaceAll(regionId, "");
//                           } else if (!selected) {
//                             productFilterP.regionId = "";
//                           }
//                         }),
//                       );
//                     },
//                   ),
//                 ),
//                 SizedBox(height: 10),
//                 Container(
//                   height: 1,
//                   decoration: BoxDecoration(color: Color(0xFFE9E9E9)),
//                 ),
//                 SizedBox(height: 10),
//                 Text('Harga', style: Constant.darkBold18),
//                 SizedBox(height: 10),
//                 Row(
//                   children: [
//                     Expanded(
//                       flex: 5,
//                       child: CustomTextField.borderTextField(
//                         hintText: "Min. Harga",
//                         prefix: Padding(
//                             padding: EdgeInsets.symmetric(horizontal: 8),
//                             child: Text("Rp ")),
//                         controller: productP.minPriceFilterC,
//                         inputFormatters: [
//                           FilteringTextInputFormatter.allow(
//                               RegExp(r'^\d+\.?\d?')),
//                           FilteringTextInputFormatter.digitsOnly
//                         ],
//                         textInputType: TextInputType.number,
//                       ),
//                     ),
//                     Expanded(
//                       flex: 5,
//                       child: CustomTextField.borderTextField(
//                         hintText: "Max. Harga",
//                         prefix: Padding(
//                             padding: EdgeInsets.symmetric(horizontal: 8),
//                             child: Text("Rp ")),
//                         controller: productP.maxPriceFilterC,
//                         inputFormatters: [
//                           FilteringTextInputFormatter.allow(
//                               RegExp(r'^\d+\.?\d?')),
//                           FilteringTextInputFormatter.digitsOnly
//                         ],
//                         textInputType: TextInputType.number,
//                       ),
//                     ),
//                   ],
//                 ),
//                 SizedBox(height: 10),
//                 Container(
//                   height: 1,
//                   decoration: BoxDecoration(color: Color(0xFFE9E9E9)),
//                 ),
//                 Text('Rating', style: Constant.darkBold18),
//                 Wrap(
//                   spacing: 10,
//                   children: List.generate(
//                     productP.ratingChip.length,
//                     (index) {
//                       return filterChipRating(
//                         title: "${index + 1}",
//                         value: productP.ratingChip[index],
//                         onSelected: (selected) => sheetState(() {
//                           for (int i = 0; i < productP.ratingChip.length; i++) {
//                             productP.ratingChip[i] = false;
//                           }
//
//                           productP.ratingChip[index] = selected;
//                         }),
//                       );
//                     },
//                   ),
//                 ),
//                 SizedBox(height: 10),
//                 Container(
//                   height: 1,
//                   decoration: BoxDecoration(color: Color(0xFFE9E9E9)),
//                 ),
//                 SizedBox(height: 10),
//                 Text(
//                   'Promo',
//                   style: Constant.darkBold18,
//                 ),
//                 SizedBox(height: 10),
//                 Wrap(
//                   spacing: 10,
//                   children: List.generate(
//                     productLabelP?.length ?? 0,
//                     (index) {
//                       final item = productLabelP?[index];
//                       var itemChip = productLabelChipP[index];
//                       final labelId = productFilterP.labelId;
//                       return filterChip(
//                         title: item?.name ?? "",
//                         value: itemChip,
//                         onSelected: (selected) => sheetState(() {
//                           productLabelChipP[index] = !itemChip;
//                           if (labelId == "")
//                             productFilterP.labelId = "${item?.id ?? 0}";
//                           else if (labelId != "" && selected)
//                             productFilterP.labelId =
//                                 "${labelId},${item?.id ?? 0}";
//                           else if (labelId != "" && !selected)
//                             productFilterP.labelId =
//                                 productFilterP.labelId.replaceAll(labelId, "");
//                           else if (!selected) {
//                             productFilterP.labelId = "";
//                           }
//                         }),
//                       );
//                     },
//                   ),
//                 ),
//                 SizedBox(height: 10),
//                 Container(
//                   height: 1,
//                   decoration: BoxDecoration(color: Color(0xFFE9E9E9)),
//                 ),
//                 ...attrProduct(sheetState),
//                 SizedBox(height: 10),
//                 Container(
//                   height: 1,
//                   decoration: BoxDecoration(color: Color(0xFFE9E9E9)),
//                 ),
//                 SizedBox(height: 10),
//                 CustomButton.mainButton("View Result", () {
//                   Navigator.pop(context);
//                   pagingC.refresh();
//                   // handleTap(() async {
//                   //   pagingC.refresh();
//                   // });
//                 }),
//                 SizedBox(height: 10),
//               ],
//             );
//           },
//         );
//
//     Widget sortAllWidget() => StatefulBuilder(
//           builder: (BuildContext context, StateSetter sheettState) {
//             return RadioListWidget();
//           },
//         );
//     Widget categoryFilter() {
//       return Row(
//         children: [
//           filterChip(
//             labelPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//             label: Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(
//                   Icons.filter_list_alt,
//                   color:
//                       filterP.allFiter ? Colors.white : Constant.primaryColor,
//                 ),
//                 SizedBox(width: 5),
//                 Text(
//                   'Filter',
//                   style: filterP.allFiter
//                       ? Constant.whiteMedium14
//                       : Constant.blueMedium14,
//                 ),
//               ],
//             ),
//             onSelected: (value) => handleTap(() async {
//               // filterP.allFiter = value;
//               await CustomContainer.showModalBottomScroll2(
//                   context: context, child: filterAllWidget());
//             }),
//             title: 'Filter',
//             value: filterP.allFiter,
//           ),
//           SizedBox(width: 4),
//           filterChip(
//             labelPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//             label: Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(
//                   Icons.sort,
//                   size: 12,
//                   color: Constant.primaryColor,
//                 ),
//                 // SizedBox(width: 5),
//                 // Text(
//                 //   'Sort By',
//                 //   style: TextStyle(
//                 //     fontFamily: 'Open-Sans',
//                 //     color: Constant.primaryColor,
//                 //     fontSize: 10,
//                 //     fontWeight: Constant.semibold,
//                 //   ),
//                 //   // style: filterP.allFiter
//                 //   //     ? Constant.whiteMedium14
//                 //   //     : Constant.blueMedium14,
//                 // ),
//               ],
//             ),
//             onSelected: (value) => handleTap(() async {
//               // filterP.allFiter = value;
//               productFilterP.tagId = "";
//               await CustomContainer.showModalBottomScrollSort(
//                   context: context, child: sortAllWidget());
//               pagingC.refresh();
//             }),
//             title: 'Sort By',
//             value: filterP.hardware,
//           ),
//           SizedBox(width: 4),
//           Expanded(
//             child: SingleChildScrollView(
//               scrollDirection: Axis.horizontal,
//               child: Row(
//                 children:
//                     (context.read<ProductProvider>().productCollections ?? [])
//                         .map((e) {
//                   return Row(
//                     children: [
//                       filterChip(
//                         title: e?.name ?? '',
//                         value: filterP.listFilter[e?.name] ?? false,
//                         onSelected: (value) {
//                           filterP.setListFilterIndex(e?.name ?? '', value);
//                         },
//                       ),
//                       SizedBox(width: 4),
//                     ],
//                   );
//                 }).toList(),
//               ),
//             ),
//           ),
//           // filterChip(
//           //   title: "Hardware",
//           //   labelPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//           //   value: filterP.hardware,
//           //   onSelected: (value) {
//           //     filterP.hardware = value;
//           //     // if (value) {
//           //     //   filterP.allFiter = false;
//           //     // }
//           //   },
//           // ),
//           // SizedBox(width: 8),
//           // filterChip(
//           //   title: "Bearing",
//           //   labelPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//           //   value: filterP.bearing,
//           //   onSelected: (value) {
//           //     filterP.bearing = value;
//           //     // if (value) {
//           //     //   filterP.allFiter = false;
//           //     // }
//           //   },
//           // ),
//           // SizedBox(width: 8),
//           // filterChip(
//           //   title: "Safety Equipment",
//           //   labelPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//           //   value: filterP.safetyEquipment,
//           //   onSelected: (value) {
//           //     filterP.safetyEquipment = value;
//           //     // if (value) {
//           //     //   filterP.allFiter = false;
//           //     // }
//           //   },
//           // ),
//         ],
//       );
//     }
//
//     Widget contentProduct() {
//       return Flexible(
//         child: RefreshIndicator(
//           onRefresh: () => Future.sync(() => pagingC.refresh()),
//           child: Container(
//             // height: 86.h,
//             color: Colors.white,
//             child: PagedGridView<int, ProductListModelData>(
//               scrollController: scrollC,
//               shrinkWrap: true,
//               addAutomaticKeepAlives: true,
//               pagingController: pagingC,
//               physics: AlwaysScrollableScrollPhysics(
//                   parent: AlwaysScrollableScrollPhysics()),
//               builderDelegate: PagedChildBuilderDelegate<ProductListModelData>(
//                 firstPageProgressIndicatorBuilder: (_) => Container(
//                   color: Colors.white,
//                   padding: EdgeInsets.only(top: 32),
//                   child: CustomLoadingIndicator.buildIndicator(),
//                 ),
//                 newPageProgressIndicatorBuilder: (_) => Container(
//                   color: Colors.white,
//                   child: CustomLoadingIndicator.buildIndicator(),
//                 ),
//                 noItemsFoundIndicatorBuilder: (_) => Utils.notFoundImage(),
//                 itemBuilder: (context, item, index) {
//                   final product = item;
//                   return itemGrid(
//                     imagePath: product.image ?? "-",
//                     brand: product.brand ?? "-",
//                     productName: product.name ?? "-",
//                     rating: (product.rating ?? 0).toDouble(),
//                     review: product.review ?? "0",
//                     normalPrice: (product.price ?? 0).toInt(),
//                     discountPrice: (product.priceDiscount ?? 0).toInt(),
//                     label: product.label ?? [],
//                     onTap: () {
//                       handleTap(() async {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) {
//                               return ProductDetailViewNotLogin(
//                                 id: product.id ?? 6,
//                               );
//                             },
//                           ),
//                         );
//                       });
//                     },
//                   );
//                 },
//               ),
//               gridDelegate:
//                   SliverGridDelegateWithFixedCrossAxisCountAndFixedHeight(
//                 crossAxisCount: 2,
//                 crossAxisSpacing: 0,
//                 mainAxisSpacing: 0,
//                 height: 290,
//               ),
//             ),
//           ),
//         ),
//       );
//     }
//
//     return Scaffold(
//       backgroundColor: Constant.primaryColor,
//       appBar: PreferredSize(
//         preferredSize: Size.fromHeight(80),
//         child: Container(
//           margin: EdgeInsets.only(top: 15),
//           child: AppBar(
//             foregroundColor: Colors.white,
//             titleSpacing: 0,
//             title: CustomTextField.normalTextField(
//               required: false,
//               controller: searchP.searchC,
//               hintText: "Search Products...",
//               prefixIcon: Icon(Icons.search),
//               padding: EdgeInsets.zero,
//               textInputAction: TextInputAction.search,
//               onEditingComplete: () {
//                 pagingC.refresh();
//               },
//             ),
//             actions: [
//               Container(
//                 width: 40,
//                 margin: EdgeInsets.fromLTRB(10, 10, 20, 10),
//                 decoration: BoxDecoration(
//                   color:
//                       Color.fromRGBO(255, 255, 255, 0.1), //.withOpacity(0.2),
//                   borderRadius: BorderRadius.circular(6),
//                 ),
//                 child: Badge(
//                   label: Text(""),
//                   textColor: Color.fromRGBO(11, 30, 64, 0),
//                   backgroundColor: Color.fromRGBO(245, 195, 75, 0),
//                   child: InkWell(
//                     onTap: () async {
//                       handleTap(() async {
//                         Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                                 builder: (context) => SignInView()));
//                       });
//                     },
//                     child: Container(
//                       child: Center(
//                         child: ImageIcon(
//                           AssetImage("assets/icons/ic_cart.png"),
//                           size: 15,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//               // Container(
//               //   width: 40,
//               //   margin: EdgeInsets.fromLTRB(10, 10, 20, 10),
//               //   child: InkWell(
//               //       onTap: () {
//               //         // Navigator.push(context, MaterialPageRoute(builder: (context) => PengelolaanReturView()));
//               //       },
//               //       child: Container(
//               //         // margin: EdgeInsets.only(right: 10),
//               //           decoration: BoxDecoration(
//               //             color: Colors.white.withOpacity(0.15),
//               //             borderRadius: BorderRadius.circular(7)
//               //           ),
//               //           child: Icon(Icons.shopping_cart_outlined, size: 15))),
//               // ),
//             ],
//           ),
//         ),
//       ),
//       body: Container(
//         color: Colors.white,
//         padding: EdgeInsets.all(20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Text('Filter', style: Constant.blueBold20),
//             // SizedBox(height: 20),
//             categoryFilter(),
//             SizedBox(height: 20),
//             contentProduct(),
//           ],
//         ),
//       ),
//     );
//   }
// }
