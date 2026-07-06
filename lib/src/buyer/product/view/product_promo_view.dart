// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_rating_bar/flutter_rating_bar.dart';
// import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
// import 'package:provider/provider.dart';
// import 'package:mspeed/common/component/custom_appbar.dart';
// import 'package:mspeed/common/component/custom_button.dart';
// import 'package:mspeed/common/component/custom_container.dart';
// import 'package:mspeed/common/component/custom_searchbar.dart';
// import 'package:mspeed/common/helper/safe_network_image.dart';
// import 'package:mspeed/src/product/model/product_promo_model.dart';
// import 'package:mspeed/src/product/provider/product_provider.dart';
// import 'package:mspeed/src/product/view/product_detail_view.dart';
// import 'package:mspeed/src/product/view/product_list_view.dart';
// import 'package:mspeed/src/cart/provider/shopping_cart_provider.dart';
// import 'package:mspeed/utils/utils.dart';
// import 'package:sizer/sizer.dart';
//
// import '../../../common/component/custom_loading_indicator.dart';
// import '../../../common/helper/constant.dart';
// import '../../../common/base/base_state.dart';
// import '../../cart/view/shopping_cart_view.dart';
// import '../provider/product_filter_provider.dart';
//
// class ProductPromoView extends StatefulWidget {
//   final String keyword;
//
//   const ProductPromoView({super.key, required this.keyword});
//
//   static Widget create({String keyword = ""}) => MultiProvider(providers: [
//         ChangeNotifierProvider<ProductFilterProvider>(
//             create: (context) => ProductFilterProvider()),
//         ChangeNotifierProvider<SearchProvider>(
//             create: (context) => SearchProvider()),
//       ], child: ProductPromoView(keyword: keyword));
//
//   @override
//   State<ProductPromoView> createState() => _ProductPromoViewState();
// }
//
// class _ProductPromoViewState extends BaseState<ProductPromoView> {
//   TextEditingController _searchController = TextEditingController();
//   late ScrollController sC1;
//   late ScrollController sC2;
//   bool scrollDown = false;
//   bool scrollDown2 = false;
//
//   @override
//   void initState() {
//     context
//         .read<ShoppingCartProvider>()
//         .fetchShoppingCart(context, withLoading: true);
//     sC1 = ScrollController()
//       ..addListener(() {
//         if (sC1.position.userScrollDirection == ScrollDirection.forward) {
//           debugPrint("SCROLL UP");
//           setState(() {
//             scrollDown2 = true;
//           });
//         }
//         if (sC1.position.userScrollDirection == ScrollDirection.reverse) {
//           debugPrint("SCROLL DOWN");
//           setState(() {
//             scrollDown2 = false;
//           });
//         }
//         // if (sC1.offset >= sC1.position.maxScrollExtent &&
//         //     !sC1.position.outOfRange) {
//         //   setState(() {
//         //     debugPrint("reach the bottom");
//         //   });
//         // }
//         if (sC1.offset <= sC1.position.minScrollExtent &&
//             !sC1.position.outOfRange) {
//           setState(() {
//             scrollDown2 = true;
//             debugPrint("reach the top");
//           });
//         }
//       });
//     sC2 = ScrollController()
//       ..addListener(() {
//         if (sC2.position.userScrollDirection == ScrollDirection.forward) {
//           debugPrint("SCROLL UP 2");
//           setState(() {
//             scrollDown2 = true;
//           });
//         }
//         if (sC2.position.userScrollDirection == ScrollDirection.reverse) {
//           debugPrint("SCROLL DOWN 2");
//           setState(() {
//             scrollDown2 = false;
//           });
//         }
//         // if (sC2.offset >= sC2.position.maxScrollExtent &&
//         //     !sC2.position.outOfRange) {
//         //   setState(() {
//         //     debugPrint("reach the bottom");
//         //   });
//         // }
//         // if (sC2.offset <= sC2.position.minScrollExtent &&
//         //     !sC2.position.outOfRange) {
//         //   setState(() {
//         //     debugPrint("reach the top");
//         //   });
//         // }
//       });
//     final pP = context.read<ProductProvider>();
//     pP.pagingControllerPromo.addPageRequestListener(
//         (pageKey) => pP.fetchProductPromo(page: pageKey, withLoading: false));
//     context.read<SearchProvider>().searchC.text = widget.keyword;
//     context
//         .read<ShoppingCartProvider>()
//         .fetchShoppingCart(context, withLoading: false);
//     context.read<ProductProvider>().fetchFilterVendor(withLoading: false);
//     context.read<ProductProvider>().fetchFilterProductAttr(withLoading: false);
//     context.read<ProductProvider>().fetchFilterProductLabel(withLoading: false);
//     context.read<ProductProvider>().fetchFilterProductTag(withLoading: false);
//     context.read<ProductProvider>().fetchFilterProductBrand(withLoading: false);
//     context.read<ProductProvider>().fetchFilterRegion(withLoading: false);
//
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final cartP = context.watch<ShoppingCartProvider>();
//
//     final searchP = context.watch<SearchProvider>();
//     final filterP = context.watch<ProductFilterProvider>();
//     final productP = context.watch<ProductProvider>();
//     final productPromoP =
//         context.watch<ProductProvider>().getProductPromoModel.data;
//     final pagingC = context.watch<ProductProvider>().pagingControllerPromo;
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
//
//     Widget itemGrid({
//       required String imagePath,
//       required String brand,
//       required String productName,
//       required double rating,
//       required int review,
//       required int normalPrice,
//       int discountPrice = 0,
//       void Function()? onTap,
//     }) {
//       return Container(
//         padding: EdgeInsets.all(8),
//         decoration: BoxDecoration(
//             color: Colors.white,
//             border: Border.all(
//               width: 1,
//               color: Constant.borderLightColor,
//             )),
//         child: InkWell(
//           onTap: onTap,
//           // () async {
//           //   handleTap(() async {
//           //     onTap;
//           //   });
//           // },
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             mainAxisAlignment: MainAxisAlignment.start,
//             children: [
//               Center(
//                 child: SafeNetworkImage(
//                   url: imagePath,
//                   width: 140,
//                   height: 140,
//                   errorBuilder: Image.asset("assets/images/img_card1.png"),
//                 ),
//               ),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   mainAxisAlignment: MainAxisAlignment.start,
//                   children: [
//                     Text(
//                       brand,
//                       // style: Constant.brandGrey13,
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                     Container(
//                       height: 45,
//                       child: Text(
//                         productName,
//                         overflow: TextOverflow.ellipsis,
//                         maxLines: 2,
//                         style: Constant.productDark14.copyWith(fontSize: 12),
//                       ),
//                     ),
//                     Row(
//                       children: [
//                         RatingBar(
//                           ignoreGestures: true,
//                           initialRating: rating,
//                           direction: Axis.horizontal,
//                           allowHalfRating: true,
//                           itemCount: 5,
//                           itemSize: 12,
//                           ratingWidget: RatingWidget(
//                             full: Icon(Icons.star_rounded,
//                                 color: Colors.yellow.shade600),
//                             half: Icon(Icons.star_half_rounded,
//                                 color: Colors.yellow.shade600),
//                             empty: Icon(Icons.star_rounded,
//                                 color: Colors.grey.shade300),
//                           ),
//                           itemPadding:
//                               const EdgeInsets.symmetric(horizontal: 0),
//                           onRatingUpdate: (double value) {},
//                         ),
//                         Padding(
//                           padding: const EdgeInsets.only(left: 3),
//                           child: Text(
//                             review > 999
//                                 ? "${review.toString()[0]}rb reviews"
//                                 : "${review.toString()} reviews",
//                             overflow: TextOverflow.ellipsis,
//                             maxLines: 1,
//                             // "${NumberFormat.compact().format(3014)} reviews",
//                             style: Constant.greyRegular12.copyWith(fontSize: 11),
//                           ),
//                         ),
//                       ],
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.only(bottom: 5),
//                       child: Row(
//                         children: [
//                           if (discountPrice != 0)
//                             Padding(
//                               padding: const EdgeInsets.only(right: 5),
//                               child: Text(
//                                 Utils.thousandSeparator(discountPrice),
//                                 overflow: TextOverflow.ellipsis,
//                                 maxLines: 2,
//                                 style: Constant.darkBold12,
//                               ),
//                             ),
//                           if (discountPrice != 0)
//                             Text(
//                               Utils.thousandSeparator(normalPrice),
//                               overflow: TextOverflow.ellipsis,
//                               maxLines: 2,
//                               style: Constant.greyThrough12,
//                             ),
//                           if (discountPrice == 0)
//                             Padding(
//                               padding: const EdgeInsets.only(right: 5),
//                               child: Text(
//                                 Utils.thousandSeparator(normalPrice),
//                                 overflow: TextOverflow.ellipsis,
//                                 maxLines: 2,
//                                 style: Constant.darkBold12,
//                               ),
//                             ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
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
//         selectedColor: Color.fromRGBO(15, 34, 121, 1),
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
//                         color: HexColor.fromHex(item?.color ?? "-"),
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
//                         // style: Constant.blueColor,
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
//                         // style: Constant.blue12,
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
//     Widget categoryFilter() {
//       return SingleChildScrollView(
//         scrollDirection: Axis.horizontal,
//         child: Row(
//           children: [
//             filterChip(
//               labelPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//               label: Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(
//                     Icons.filter_alt_outlined,
//                     color:
//                         filterP.allFiter ? Colors.white : Constant.primaryColor,
//                   ),
//                   SizedBox(width: 5),
//                   Text(
//                     'Semua Filter',
//                     style: filterP.allFiter
//                         ? Constant.whiteRegular12
//                         : Constant.blueBold12,
//                   ),
//                 ],
//               ),
//               onSelected: (value) => handleTap(() async {
//                 // filterP.allFiter = value;
//                 await CustomContainer.showModalBottomScroll2(
//                     context: context, child: filterAllWidget());
//               }),
//               title: 'Semua Filter',
//               value: filterP.allFiter,
//             ),
//             SizedBox(width: 8),
//             filterChip(
//               title: "Hardware",
//               labelPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//               value: filterP.hardware,
//               onSelected: (value) {
//                 filterP.hardware = value;
//                 // if (value) {
//                 //   filterP.allFiter = false;
//                 // }
//               },
//             ),
//             SizedBox(width: 8),
//             filterChip(
//               title: "Bearing",
//               labelPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//               value: filterP.bearing,
//               onSelected: (value) {
//                 filterP.bearing = value;
//                 // if (value) {
//                 //   filterP.allFiter = false;
//                 // }
//               },
//             ),
//             SizedBox(width: 8),
//             filterChip(
//               title: "Safety Equipment",
//               labelPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//               value: filterP.safetyEquipment,
//               onSelected: (value) {
//                 filterP.safetyEquipment = value;
//                 // if (value) {
//                 //   filterP.allFiter = false;
//                 // }
//               },
//             ),
//           ],
//         ),
//       );
//     }
//
//     Widget contentTopSellingProducts() {
//       return Flexible(
//         // flex: 9,
//         child: RefreshIndicator(
//           onRefresh: () => Future.sync(() => pagingC.refresh()),
//           child: Container(
//             padding: EdgeInsets.only(bottom: kBottomNavigationBarHeight + 121),
//             // height: 810,
//             color: Colors.white,
//             child: PagedGridView<int, ProductPromoModelData>(
//               padding: EdgeInsets.fromLTRB(15, 18, 15, 20),
//               scrollController: sC2,
//               shrinkWrap: true,
//               addAutomaticKeepAlives: true,
//               pagingController: pagingC,
//               physics: AlwaysScrollableScrollPhysics(),
//               // scrollDown2
//               //     ? NeverScrollableScrollPhysics()
//               //     : NeverScrollableScrollPhysics(),
//               builderDelegate: PagedChildBuilderDelegate<ProductPromoModelData>(
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
//                     review: int.parse(product.review ?? ""),
//                     normalPrice: (product.price ?? 0).toInt(),
//                     discountPrice: (product.priceDiscount ?? 0).toInt(),
//                     onTap: () {
//                       handleTap(() async {
//                         Navigator.push(context,
//                             MaterialPageRoute(builder: (context) {
//                           return ProductDetailView(id: product.id ?? 0);
//                         }));
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
//                 // childAspectRatio: 0.6,
//                 height: 260.0,
//               ),
//             ),
//           ),
//         ),
//       );
//     }
//
//     return Scaffold(
//       backgroundColor: Constant.primaryColor,
//       // appBar: PreferredSize(
//       //   preferredSize: Size.fromHeight(60),
//       //   child: Container(
//       //     margin: EdgeInsets.only(top: 15),
//       //     child: AppBar(
//       //       foregroundColor: Colors.white,
//       //       titleSpacing: 16,
//       //       title: Text('Product Promo'),
//       //       // title: CustomSearchBar.searchBarProduct(
//       //       //   controller: searchP.searchC,
//       //       //   onTap: () => Navigator.push(context,
//       //       //       MaterialPageRoute(builder: (context) => SearchView())),
//       //       // ),
//       //       actions: [
//       //         Container(
//       //           width: 40,
//       //           margin: EdgeInsets.fromLTRB(10, 10, 20, 10),
//       //           decoration: BoxDecoration(
//       //             color:
//       //                 Color.fromRGBO(255, 255, 255, 0.1), //.withOpacity(0.2),
//       //             borderRadius: BorderRadius.circular(6),
//       //           ),
//       //           child: Badge(
//       //             label: Text((cartP.getShoppingCartModel.data?.countItem ?? 0)
//       //                 .toString()),
//       //             textColor: (cartP.getShoppingCartModel.data?.countItem != 0)
//       //                 ? Color.fromRGBO(11, 30, 64, 1)
//       //                 : Color.fromRGBO(11, 30, 64, 0),
//       //             backgroundColor:
//       //                 (cartP.getShoppingCartModel.data?.countItem != 0)
//       //                     ? Color.fromRGBO(245, 195, 75, 1)
//       //                     : Color.fromRGBO(11, 30, 64, 0),
//       //             child: InkWell(
//       //               onTap: () async {
//       //                 handleTap(() async {
//       //                   Navigator.push(
//       //                       context,
//       //                       MaterialPageRoute(
//       //                           builder: (context) => ShoppingCartView()));
//       //                 });
//       //               },
//       //               child: Container(
//       //                 child: Center(
//       //                   child: ImageIcon(
//       //                     AssetImage("assets/icons/ic_cart.png"),
//       //                     size: 15,
//       //                   ),
//       //                 ),
//       //               ),
//       //             ),
//       //           ),
//       //         ),
//       //       ],
//       //     ),
//       //   ),
//       // ),
//       // appBar: CustomAppBar.appBar(
//       //   'Product Promo',
//       //   color: Constant.primaryColor,
//       //   foregroundColor: Colors.white,
//       //   titleSpacing: 24,
//       // ),
//       appBar: AppBar(
//         title: const Text("Product Promo"),
//         systemOverlayStyle:
//         SystemUiOverlayStyle(statusBarColor: Constant.primaryColor),
//         actions: [
//           Container(
//             width: 40,
//             margin: EdgeInsets.fromLTRB(10, 10, 20, 10),
//             decoration: BoxDecoration(
//               color: Color.fromRGBO(255, 255, 255, 0.1), //.withOpacity(0.2),
//               borderRadius: BorderRadius.circular(6),
//             ),
//             child: Badge(
//               label: Text((cartP.getShoppingCartModel.data?.countItem ?? 0)
//                   .toString()),
//               textColor: (cartP.getShoppingCartModel.data?.countItem != 0)
//                   ? Color.fromRGBO(11, 30, 64, 1)
//                   : Color.fromRGBO(11, 30, 64, 0),
//               backgroundColor:
//               (cartP.getShoppingCartModel.data?.countItem != 0)
//                   ? Color.fromRGBO(245, 195, 75, 1)
//                   : Color.fromRGBO(11, 30, 64, 0),
//               child: InkWell(
//                 onTap: () async {
//                   handleTap(() async {
//                     Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                             builder: (context) => ShoppingCartView()));
//                   });
//                 },
//                 child: Container(
//                   child: Center(
//                     child: ImageIcon(
//                       AssetImage("assets/icons/ic_cart.png"),
//                       size: 15,
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//       body: Container(
//         color: Colors.white,
//         padding: EdgeInsets.symmetric(horizontal: 20),
//         child: SingleChildScrollView(
//           controller: sC1,
//           child: Container(
//             height: 100.h,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // SizedBox(height: 20),
//                     // Text('Shop by Category', style: Constant.blueBold20.copyWith(fontSize: 16)),
//                     // SizedBox(height: 20),
//                     // categoryFilter(),
//                     SizedBox(height: 20),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text(
//                           'Produk Promo',
//                           style: Constant.primaryBold16.copyWith(fontSize: 16),
//                         ),
//                         InkWell(
//                           onTap: () {
//                             Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                     builder: (context) => ProductListView()));
//                           },
//                           child: Text('Lihat Semua',
//                               style: Constant.grayRegular13
//                                   .copyWith(fontSize: 14)),
//                         ),
//                       ],
//                     ),
//                     SizedBox(height: 16),
//                   ],
//                 ),
//                 contentTopSellingProducts(),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
