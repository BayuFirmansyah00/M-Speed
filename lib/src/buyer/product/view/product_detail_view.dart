// import 'package:carousel_slider/carousel_slider.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_html/flutter_html.dart';
// import 'package:flutter_rating_bar/flutter_rating_bar.dart';
// import 'package:intl/intl.dart';
// import 'package:mspeed/src/wishlist/provider/wishlist_provider.dart';
// import 'package:mspeed/src/wishlist/view/wishlist_view.dart';
// import 'package:provider/provider.dart';
// import 'package:share_plus/share_plus.dart';
// import 'package:mspeed/common/component/custom_button.dart';
// import 'package:mspeed/common/component/custom_container.dart';
// import 'package:mspeed/common/component/custom_textField.dart';
// import 'package:mspeed/src/product/provider/product_provider.dart';
// import 'package:mspeed/src/product/view/product_faq_view.dart';
// import 'package:mspeed/src/product/view/product_review_view.dart';
// import 'package:mspeed/src/cart/provider/shopping_cart_provider.dart';
// import 'package:mspeed/utils/utils.dart';
// import 'package:url_launcher/url_launcher.dart';
//
// import '../../../common/helper/constant.dart';
// import '../../../common/base/base_state.dart';
// import '../../../common/helper/safe_network_image.dart';
// import '../../cart/view/shopping_cart_view.dart';
// import '../../checkout/provider/checkout_provider.dart';
//
// /// This is the [ProductDetailView] class which represents the view for displaying product details.
// /// It is a [StatefulWidget] that manages its own state using [_ProductDetailViewState].
// /// It includes various widgets such as product preview, dots indicator, header, rating and sharing buttons, and product details.
// class ProductDetailView extends StatefulWidget {
//   final int id;
//
//   const ProductDetailView({super.key, required this.id});
//
//   @override
//   State<ProductDetailView> createState() => _ProductDetailViewState();
// }
//
// /// This is the private state class [_ProductDetailViewState] for [ProductDetailView].
// /// It extends [BaseState] and implements [TickerProviderStateMixin].
// /// It manages the current index, quantity, and controller for the quantity input field.
//
// class _ProductDetailViewState extends BaseState<ProductDetailView>
//     with TickerProviderStateMixin {
//   int _currentIndex = 0;
//
//   @override
//   void initState() {
//     super.initState();
//     // context.read<ProductProvider>().productDetailColorChip.clear();
//     // context.read<ProductProvider>().productDetailSizeChip.clear();
//     context
//         .read<ProductProvider>()
//         .fetchProductDetail(withLoading: true, id: widget.id);
//
//     context.read<ProductProvider>().controllerQuantity.text = "1";
//     context.read<ProductProvider>().quantity = 1;
//
//     context
//         .read<ShoppingCartProvider>()
//         .fetchShoppingCart(context, withLoading: true);
//   }
//
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final detailP = context.watch<ProductProvider>();
//     final qP = context
//             .watch<ProductProvider>()
//             .getProductVariantModel
//             .data
//             ?.quantity ??
//         0;
//     final cartP = context.watch<ShoppingCartProvider>();
//     final wishP = context.watch<WishlistProvider>();
//     // final savedCartP = context.watch<SavedShoppingCartProvider>();
//     Widget productPreview(int index) {
//       return Container(
//         height: 330,
//         width: double.infinity,
//         decoration: BoxDecoration(
//           color: Color(0xffF2F2F2),
//           borderRadius: BorderRadius.circular(10),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.grey.withOpacity(0.5),
//               blurRadius: 7,
//               offset: Offset(0, 1),
//             ),
//           ],
//         ),
//         child: SafeNetworkImage(
//           url: ((detailP.productDetailModel.data?.images?[index]) ?? ""),
//           errorBuilder: Image.asset(
//             'assets/icons/ic_cordless.png',
//             width: double.infinity,
//           ),
//           height: 220,
//           width: double.infinity,
//         ),
//       );
//     }
//
//     Widget _buildDotsIndicator({required int numberOfDots}) {
//       return Container(
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: List.generate(
//             numberOfDots,
//             (index) => Container(
//               width: _currentIndex == index ? 16 : 8.0,
//               height: 8.0,
//               margin: EdgeInsets.symmetric(horizontal: 2),
//               decoration: BoxDecoration(
//                 borderRadius:
//                     _currentIndex == index ? BorderRadius.circular(10) : null,
//                 shape: _currentIndex == index
//                     ? BoxShape.rectangle
//                     : BoxShape.circle,
//                 color: _currentIndex == index
//                     ? Constant.primaryColor // Dot color for the current index
//                     : Color(0xffD9D9D9),
//               ),
//             ),
//           ),
//         ),
//       );
//     }
//
//     Widget headerProductDetail() {
//       return Stack(
//         children: [
//           // Container(
//           //   color: Constant.primaryColor,
//           //   width: double.infinity,
//           //   height: 50,
//           // ),
//           CarouselSlider(
//             items: List.generate(
//                 detailP.productDetailModel.data?.images?.length ?? 1,
//                 (index) => productPreview(index)),
//             options: CarouselOptions(
//                 height: 330,
//                 viewportFraction: 1,
//                 pageSnapping: true,
//                 autoPlayCurve: Curves.fastLinearToSlowEaseIn,
//                 enableInfiniteScroll: true,
//                 aspectRatio: 16 / 9,
//                 onPageChanged: (index, reason) {
//                   setState(() {
//                     _currentIndex = index;
//                   });
//                 }),
//           ),
//         ],
//       );
//     }
//
//     Widget koleksiBaruWishlish() {
//       return CustomContainer.showModalBottomScroll(
//           context: context,
//           child: StatefulBuilder(
//               builder: (BuildContext context, StateSetter state) {
//             return Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text("Buat Koleksi Baru"),
//                 SizedBox(
//                   height: 10,
//                 ),
//                 CustomTextField.borderTextField(
//                     controller: wishP.namaKoleksiC,
//                     textInputType: TextInputType.name,
//                     hintText: "Nama Koleksi"),
//                 SizedBox(
//                   height: 10,
//                 ),
//                 CustomButton.mainButton("Buat Koleksi", () async {
//                   // if (wishP.namaKoleksiC != wishP?.wishlistModel?.data)
//                   await wishP.createWishlist().then((value) async {
//                     Utils.showToast("Berhasil menambahkan Koleksi Baru");
//                     Navigator.pop(context);
//                     Navigator.pop(context);
//                     // wishP.namaKoleksiC.clear();
//                   }).onError((error, stackTrace) async {
//                     Utils.showToast("Gagal menambah Koleksi Baru");
//                     Navigator.pop(context);
//                     Navigator.pop(context);
//                   });
//                 }),
//                 SizedBox(
//                   height: 10,
//                 ),
//               ],
//             );
//           }));
//     }
//
//     // Widget koleksiBaruSavedCart() {
//     //   return CustomContainer.showModalBottomScroll(
//     //       context: context,
//     //       child: Column(
//     //         crossAxisAlignment: CrossAxisAlignment.start,
//     //         children: [
//     //           Text("Buat Koleksi Baru"),
//     //           SizedBox(
//     //             height: 10,
//     //           ),
//     //           CustomTextField.borderTextField(
//     //               controller: savedCartP.namaSavedCartC,
//     //               textInputType: TextInputType.name,
//     //               hintText: "Nama Koleksi"),
//     //           SizedBox(
//     //             height: 10,
//     //           ),
//     //           CustomButton.mainButton("Buat Koleksi", () async {
//     //             await savedCartP.createSavedShoppingCart().then((value) async {
//     //               Utils.showToast("Berhasil menambahkan Koleksi Baru");
//     //               Navigator.pop(context);
//     //               Navigator.pop(context);
//     //               savedCartP.namaSavedCartC.clear();
//     //             }).onError((error, stackTrace) async {
//     //               Utils.showToast("Gagal menambah Koleksi Baru");
//     //               Navigator.pop(context);
//     //               Navigator.pop(context);
//     //             });
//     //           }),
//     //           SizedBox(
//     //             height: 10,
//     //           ),
//     //         ],
//     //       ));
//     // }
//
//     Widget wishlistButton(String productId) {
//       return CustomContainer.showModalBottomScroll(
//           context: context,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     "Tersimpan di Wishlist!",
//                     style: Constant.primaryTextStyle,
//                   ),
//                   InkWell(
//                     onTap: () {
//                       Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                               builder: (context) => WishlistView()));
//                     },
//                     child: Text(
//                       "Cek Wishlist",
//                       style: Constant.primaryTextStyle
//                           .copyWith(color: Constant.primaryColor),
//                     ),
//                   ),
//                 ],
//               ),
//               SizedBox(height: 10),
//               Text("Simpan juga ke Koleksi? (Opsional)"),
//               SizedBox(height: 5),
//               ListView.separated(
//                   shrinkWrap: true,
//                   separatorBuilder: (BuildContext context, int index) {
//                     return SizedBox(height: 5);
//                   },
//                   itemCount: (wishP.getWishListModel.data ?? []).length,
//                   itemBuilder: (BuildContext context, int index) {
//                     return InkWell(
//                       onTap: () async {
//                         await wishP
//                             .addProductWishlist(
//                                 productId: productId,
//                                 id: ((wishP.getWishListModel.data ?? [])[index]
//                                             ?.id ??
//                                         0)
//                                     .toString())
//                             .then((value) async {
//                           Utils.showToast("Berhasil menambahkan Koleksi Baru");
//                           Navigator.pop(context);
//                           // Navigator.pop(context);
//                           wishP.namaKoleksiC.clear();
//                         }).onError((error, stackTrace) async {
//                           Utils.showToast("Gagal menambah Koleksi Baru");
//                           // Navigator.pop(context);
//                           Navigator.pop(context);
//                         });
//                       },
//                       child: Row(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Image.network(
//                             wishP.getWishListModel.data?[index]?.image?.first ??
//                                 "",
//                             scale: 8,
//                           ),
//                           SizedBox(width: 10),
//                           Expanded(
//                             flex: 8,
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               mainAxisAlignment: MainAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   wishP.getWishListModel.data?[index]?.name ??
//                                       "",
//                                   maxLines: 1,
//                                   overflow: TextOverflow.ellipsis,
//                                 ),
//                                 Text((wishP.getWishListModel.data?[index]
//                                             ?.countItems ??
//                                         0)
//                                     .toString()),
//                               ],
//                             ),
//                           )
//                         ],
//                       ),
//                     );
//                   }),
//               SizedBox(height: 10),
//               Row(
//                 children: [
//                   Container(
//                     width: 40,
//                     height: 40,
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(10),
//                       color: Colors.grey,
//                     ),
//                   ),
//                   SizedBox(width: 10),
//                   InkWell(
//                       onTap: () {
//                         wishP.namaKoleksiC.clear();
//                         koleksiBaruWishlish();
//                       },
//                       child: Text(
//                         "+ Koleksi Baru",
//                         style: Constant.primaryTextStyle
//                             .copyWith(color: Constant.primaryColor),
//                       ))
//                 ],
//               ),
//               SizedBox(
//                 height: 20,
//               ),
//             ],
//           ));
//     }
//
//     // Widget savedCartButton(String productId) {
//     //   return CustomContainer.showModalBottomScroll(
//     //       context: context,
//     //       child: Column(
//     //         crossAxisAlignment: CrossAxisAlignment.start,
//     //         children: [
//     //           Row(
//     //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//     //             children: [
//     //               Text(
//     //                 "Tersimpan di Saved Cart!",
//     //                 style: Constant.primaryTextStyle,
//     //               ),
//     //               InkWell(
//     //                 onTap: () {
//     //                   // Navigator.push(
//     //                   //     context,
//     //                   //     MaterialPageRoute(
//     //                   //         builder: (context) => SavedShoppingCartView()));
//     //                 },
//     //                 child: Text(
//     //                   "Cek Saved Cart",
//     //                   style: Constant.primaryTextStyle
//     //                       .copyWith(color: Constant.primaryColor),
//     //                 ),
//     //               ),
//     //             ],
//     //           ),
//     //           SizedBox(height: 10),
//     //           Text("Simpan juga ke Koleksi? (Opsional)"),
//     //           SizedBox(height: 5),
//     //           ListView.separated(
//     //               shrinkWrap: true,
//     //               separatorBuilder: (BuildContext context, int index) {
//     //                 return SizedBox(height: 5);
//     //               },
//     //               itemCount:
//     //                   (savedCartP.getSavedShoppingCartModel.data ?? []).length,
//     //               itemBuilder: (BuildContext context, int index) {
//     //                 return InkWell(
//     //                   onTap: () async {
//     //                     await wishP
//     //                         .addProductWishlist(
//     //                             productId: productId,
//     //                             id: ((savedCartP.getSavedShoppingCartModel
//     //                                                 .data ??
//     //                                             [])[index]
//     //                                         ?.id ??
//     //                                     0)
//     //                                 .toString())
//     //                         .then((value) async {
//     //                       Utils.showToast("Berhasil menambahkan Koleksi Baru");
//     //                       Navigator.pop(context);
//     //                       Navigator.pop(context);
//     //                       savedCartP.namaSavedCartC.clear();
//     //                     }).onError((error, stackTrace) async {
//     //                       Utils.showToast("Gagal menambah Koleksi Baru");
//     //                       Navigator.pop(context);
//     //                       Navigator.pop(context);
//     //                     });
//     //                   },
//     //                   child: Row(
//     //                     crossAxisAlignment: CrossAxisAlignment.start,
//     //                     children: [
//     //                       Image.network(
//     //                         savedCartP.getSavedShoppingCartModel.data?[index]
//     //                                 ?.image?.first ??
//     //                             "",
//     //                         scale: 8,
//     //                       ),
//     //                       SizedBox(width: 10),
//     //                       Expanded(
//     //                         flex: 8,
//     //                         child: Column(
//     //                           crossAxisAlignment: CrossAxisAlignment.start,
//     //                           mainAxisAlignment: MainAxisAlignment.start,
//     //                           children: [
//     //                             Text(
//     //                               savedCartP.getSavedShoppingCartModel
//     //                                       .data?[index]?.name ??
//     //                                   "",
//     //                               maxLines: 1,
//     //                               overflow: TextOverflow.ellipsis,
//     //                             ),
//     //                             Text((savedCartP.getSavedShoppingCartModel
//     //                                         .data?[index]?.countItems ??
//     //                                     0)
//     //                                 .toString()),
//     //                           ],
//     //                         ),
//     //                       )
//     //                     ],
//     //                   ),
//     //                 );
//     //               }),
//     //           SizedBox(height: 10),
//     //           Row(
//     //             children: [
//     //               Container(
//     //                 width: 40,
//     //                 height: 40,
//     //                 decoration: BoxDecoration(
//     //                   borderRadius: BorderRadius.circular(10),
//     //                   color: Colors.grey,
//     //                 ),
//     //               ),
//     //               SizedBox(width: 10),
//     //               InkWell(
//     //                   onTap: () {
//     //                     koleksiBaruSavedCart();
//     //                   },
//     //                   child: Text(
//     //                     "+ Koleksi Baru",
//     //                     style: Constant.primaryTextStyle
//     //                         .copyWith(color: Constant.primaryColor),
//     //                   ))
//     //             ],
//     //           ),
//     //           SizedBox(
//     //             height: 20,
//     //           ),
//     //         ],
//     //       ));
//     // }
//
//     Widget ratingShareFavSave(String productId) {
//       final String _url = detailP.getProductDetailModel.data?.link ?? "";
//       return Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Wrap(
//             crossAxisAlignment: WrapCrossAlignment.center,
//             children: [
//               Text(detailP.getProductDetailModel.data?.brand?.name ?? ""),
//               SizedBox(width: 10),
//               Container(
//                 width: 1,
//                 height: 20,
//                 decoration:
//                     BoxDecoration(color: Color.fromRGBO(233, 233, 233, 1)),
//               ),
//               SizedBox(width: 10),
//               Column(
//                 children: [
//                   RatingBar(
//                     ignoreGestures: true,
//                     initialRating:
//                         ((detailP.getProductDetailModel.data?.rating) ?? 5)
//                             .toDouble(),
//                     minRating: 0,
//                     direction: Axis.horizontal,
//                     allowHalfRating: true,
//                     itemCount: 5,
//                     itemSize: 15,
//                     ratingWidget: RatingWidget(
//                       full: Icon(Icons.star_rounded,
//                           color: Colors.yellow.shade600),
//                       half: Icon(Icons.star_half_rounded,
//                           color: Colors.yellow.shade600),
//                       empty:
//                           Icon(Icons.star_rounded, color: Colors.grey.shade300),
//                     ),
//                     itemPadding: const EdgeInsets.symmetric(horizontal: 0),
//                     onRatingUpdate: (double value) {},
//                   ),
//                   Text(detailP.getProductDetailModel.data == null
//                       ? ""
//                       : "${NumberFormat.compact().format(detailP.getProductDetailModel.data?.detailReviews?.length)} reviews"),
//                 ],
//               ),
//               SizedBox(width: 10),
//             ],
//           ),
//           Wrap(
//             children: [
//               InkWell(
//                 onTap: () async {
//                   handleTap(() async {});
//                   _shareLink(_url);
//                 },
//                 child: Container(
//                   padding: EdgeInsets.all(8),
//                   decoration: BoxDecoration(
//                     color: Color(0xffF2F2F2),
//                     borderRadius: BorderRadius.circular(6),
//                   ),
//                   child: Icon(Icons.share_outlined),
//                 ),
//               ),
//               SizedBox(width: 5),
//               InkWell(
//                 onTap: () async {
//                   handleTap(() async {
//                     showDialog(
//                       context: context,
//                       builder: (BuildContext context) {
//                         // return object of type Dialog
//                         return AlertDialog(
//                           title: new Text("Title"),
//                           content:
//                               new Text("This is the content of the dialog"),
//                           actions: <Widget>[
//                             // usually buttons at the bottom of the dialog
//                             new TextButton(
//                               child: new Text("Close"),
//                               onPressed: () {
//                                 Navigator.of(context).pop();
//                               },
//                             ),
//                           ],
//                         );
//                       },
//                     );
//                   });
//                 },
//                 child: InkWell(
//                   onTap: () {
//                     wishlistButton(productId);
//                   },
//                   child: Container(
//                       padding: EdgeInsets.all(8),
//                       decoration: BoxDecoration(
//                         color: Color(0xffF2F2F2),
//                         borderRadius: BorderRadius.circular(6),
//                       ),
//                       child: Icon(Icons.favorite_outline_sharp)),
//                 ),
//               ),
//               // SizedBox(width: 5),
//               // InkWell(
//               //   onTap: () async {
//               //     handleTap(() async {
//               //       savedCartButton(productId);
//               //     });
//               //   },
//               //   child: Container(
//               //       padding: EdgeInsets.all(8),
//               //       decoration: BoxDecoration(
//               //         color: Color(0xffF2F2F2),
//               //         borderRadius: BorderRadius.circular(6),
//               //       ),
//               //       child: Icon(Icons.add_shopping_cart_rounded)),
//               // ),
//             ],
//           ),
//         ],
//       );
//     }
//
//     String getThumbnailUrl() {
//       if ((detailP.productDetailModel.data?.mediaDesc ?? []).isEmpty) {
//         return "";
//       }
//
//       final mediaDesc =
//           (detailP.productDetailModel.data?.mediaDesc?.first ?? "").toString();
//       final Uri uri = Uri.parse(mediaDesc);
//       String videoId = '';
//       if (uri.host.contains('youtube.com')) {
//         videoId = uri.queryParameters['v'] ?? '';
//       } else if (uri.host.contains('youtu.be')) {
//         videoId = uri.pathSegments.first;
//       }
//       return 'https://img.youtube.com/vi/$videoId/maxresdefault.jpg';
//     }
//
//     Widget productDetailMain() {
//       return Column(
//         mainAxisAlignment: MainAxisAlignment.start,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             detailP.productDetailModel.data?.name ??
//                 "CORDLESS BRUSHLESS ANGLE GRINDER",
//             style: Constant.darkBold16,
//           ),
//           SizedBox(height: 10),
//           Container(
//             height: 1,
//             decoration: BoxDecoration(color: Color(0xFFE9E9E9)),
//           ),
//           SizedBox(height: 10),
//           Row(
//             children: [
//               if (detailP.productDetailModel.data?.salePrice != 0)
//                 Text(
//                     Utils.thousandSeparator(
//                         (detailP.productDetailModel.data?.salePrice ?? 0)
//                             .toInt()),
//                     overflow: TextOverflow.ellipsis,
//                     maxLines: 2,
//                     style: Constant.darkBold16),
//               SizedBox(width: 5),
//               if (detailP.productDetailModel.data?.salePrice != 0)
//                 Text(
//                     Utils.thousandSeparator(
//                         (detailP.productDetailModel.data?.price ?? 0).toInt()),
//                     overflow: TextOverflow.ellipsis,
//                     maxLines: 2,
//                     style: Constant.greyThrough16),
//               if (detailP.productDetailModel.data?.salePrice == 0)
//                 Text(
//                     Utils.thousandSeparator(
//                         (detailP.productDetailModel.data?.price ?? 0).toInt()),
//                     overflow: TextOverflow.ellipsis,
//                     maxLines: 2,
//                     style: Constant.darkBold16),
//               SizedBox(width: 5),
//             ],
//           ),
//           SizedBox(height: 10),
//           Container(
//             height: 80,
//             width: double.infinity,
//             child: ListView.separated(
//               shrinkWrap: true,
//               scrollDirection: Axis.horizontal,
//               itemCount:
//                   (detailP.productDetailModel.data?.images?.length ?? 0) + 1,
//               separatorBuilder: (context, index) => SizedBox(
//                 width: 16,
//               ),
//               itemBuilder: (context, index) {
//                 if (index == detailP.productDetailModel.data?.images?.length) {
//                   if ((detailP.productDetailModel.data?.mediaDesc ?? [])
//                       .isEmpty) {
//                     return SizedBox();
//                   }
//                   return InkWell(
//                     onTap: () async {
//                       await launchUrl(Uri.parse(
//                           (detailP.productDetailModel.data?.mediaDesc?.first ??
//                                   "")
//                               .toString()));
//                     },
//                     child: Stack(children: [
//                       Container(
//                         width: 80,
//                         height: 80,
//                         padding: EdgeInsets.all(2),
//                         child: Image.network(
//                           getThumbnailUrl(),
//                           fit: BoxFit.cover,
//                         ),
//                       ),
//                       Container(
//                         color: Colors.black.withOpacity(0.5),
//                         width: 80,
//                         height: 80,
//                       ),
//                       IconButton(
//                         alignment: Alignment.center,
//                         icon: Icon(
//                           Icons.play_circle_outline,
//                           color: Colors.white,
//                           size: 64,
//                         ),
//                         onPressed: () async {
//                           await launchUrl(Uri.parse((detailP.productDetailModel
//                                       .data?.mediaDesc?.first ??
//                                   "")
//                               .toString()));
//                         },
//                       ),
//                     ]),
//                   );
//                 }
//                 return Container(
//                   width: 80,
//                   height: 80,
//                   padding: EdgeInsets.all(2),
//                   // decoration: BoxDecoration(
//                   //   color: Colors.transparent,
//                   //   borderRadius: BorderRadius.circular(10),
//                   //   border: Border.all(color: Color(0xffEAEAEA)),
//                   //   image: DecorationImage(
//                   //     image: AssetImage('assets/icons/ic_cordless.png'),
//                   //     fit: BoxFit.contain,
//                   //   ),
//                   // ),
//                   child: SafeNetworkImage(
//                     url: ((detailP.productDetailModel.data?.images?[index]) ??
//                         ""),
//                     errorBuilder: Image.asset(
//                       'assets/icons/ic_cordless.png',
//                       width: double.infinity,
//                     ),
//                     height: double.infinity,
//                     width: double.infinity,
//                   ),
//                 );
//               },
//             ),
//           ),
//           SizedBox(height: 20),
//           Container(
//             height: 1,
//             decoration: BoxDecoration(color: Color(0xFFE9E9E9)),
//           ),
//           SizedBox(height: 20),
//           Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               ImageIcon(
//                 AssetImage("assets/icons/ic_shipping_truck.png"),
//               ),
//               SizedBox(width: 10),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     RichText(
//                       text: TextSpan(
//                         children: [
//                           TextSpan(
//                             text: "Free shipping, ",
//                             style: Constant.dark14,
//                           ),
//                           TextSpan(
//                               text: "arrives by Thu, Jun 2 ",
//                               style: Constant.darkBold14),
//                           TextSpan(
//                             text: "Scaramentom 95829",
//                             style: Constant.dark14,
//                           ),
//                         ],
//                       ),
//                     ),
//                     SizedBox(height: 10),
//                     RichText(
//                       text: TextSpan(
//                         children: [
//                           TextSpan(
//                             text: "Want it faster? ",
//                             style: Constant.darkBold14,
//                           ),
//                           TextSpan(
//                             text: "Add an address",
//                             style: Constant.darkUnderline14
//                                 .copyWith(decoration: TextDecoration.underline),
//                           ),
//                           TextSpan(
//                             text: " to see options ",
//                             style: Constant.dark14,
//                           ),
//                           TextSpan(
//                               text: "More Options",
//                               style: Constant.darkUnderline14),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               )
//             ],
//           ),
//           SizedBox(height: 20),
//           Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // ImageIcon(
//               //   NetworkImage(
//               //       detailP.getProductDetailModel.data?.store?.logo ?? ""),
//               // ),
//               SafeNetworkImage(
//                   width: 22,
//                   height: 22,
//                   errorBuilder: CircleAvatar(),
//                   url: detailP.getProductDetailModel.data?.store?.logo ?? ""),
//               SizedBox(width: 10),
//               Expanded(
//                 child: InkWell(
//                   onTap: () {
//                     // Navigator.push(
//                     //     context,
//                     //     MaterialPageRoute(
//                     //         builder: (context) => VendorView.create()));
//                   },
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Dijual dan dikirim oleh',
//                         style: Constant.dark14,
//                       ),
//                       SizedBox(height: 5),
//                       Row(
//                         children: [
//                           Text(
//                             detailP.getProductDetailModel.data?.store
//                                     ?.storeSlug ??
//                                 "-",
//                             style: Constant.darkBold14,
//                           ),
//                           Text(
//                             " | ",
//                             style: Constant.darkBold14,
//                           ),
//                           Text(
//                             detailP.getProductDetailModel.data?.store?.name ??
//                                 "",
//                             style: Constant.darkBold14,
//                           ),
//                         ],
//                       ),
//                       Row(
//                         children: [
//                           RatingBar(
//                             ignoreGestures: true,
//                             initialRating: 5,
//                             minRating: 1,
//                             direction: Axis.horizontal,
//                             allowHalfRating: true,
//                             itemCount: 5,
//                             itemSize: 15,
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
//                           SizedBox(width: 10),
//                           Text(
//                             "965 seller reviews",
//                             style: Constant.dark14,
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(height: 20),
//           Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               ImageIcon(
//                 AssetImage("assets/icons/ic_return_product.png"),
//               ),
//               SizedBox(width: 10),
//               Text(
//                 'Free 15-Day returns',
//                 style: Constant.dark14,
//               ),
//               SizedBox(width: 10),
//               Text(
//                 'Details',
//                 style: Constant.darkUnderline14,
//               ),
//             ],
//           ),
//           SizedBox(height: 20),
//           Container(
//             height: 1,
//             decoration: BoxDecoration(
//               color: Constant.borderLightColor,
//             ),
//           ),
//           // ExpansionPanelList(
//           //   children: [
//           //     ExpansionPanel(
//           //       headerBuilder: (context, isOpen) {
//           //         return Text("Detail & Specs");
//           //       },
//           //       body: Text(
//           //           "The first notebook of its kind, this Apple MacBook Pro is a beast. With the blazing-fast M1 Pro chip - the first Apple silicon designed for pros."),
//           //       isExpanded: _isOpen[0],
//           //     ),
//           //   ],
//           //   expansionCallback: (i, isOpen) =>
//           //       setState(() => _isOpen[i] = !isOpen),
//           // ),
//           ExpansionTile(
//             title: Text(
//               "Detail dan Spesifikasi",
//               style: Constant.darkBold16,
//             ),
//             children: [
//               Text("inidesc"),
//               // (Html(
//               //   data: detailP.productDetailModel.data?.descriptionV2 ?? "",
//               //   style: {
//               //     "body": Style(
//               //       fontFamily: 'Open-Sans',
//               //       color: Constant.tertiaryColor,
//               //       fontSize: FontSize(16),
//               //       fontWeight: FontWeight.w400,
//               //     )
//               //   },
//               // )),
//               // ListTile(
//               //   title:
//               //   Html(data: detailP.productDetailModel.data?.description ?? ""),
//               //   // Text(
//               //   //   (htmlparser.parse(detailP.productDetailModel.data?.name))
//               //   //           .toString() ??
//               //   //       "The first notebook of its kind, this Apple MacBook Pro is a beast. With the blazing-fast M1 Pro chip - the first Apple silicon designed for pros.",
//               //   //   style: Constant.dark16,
//               //   // ),
//               // ),
//               if (detailP.productDetailModel.data?.content != "")
//                 ExpansionTile(
//                   title: Text(
//                     "Lihat Semua",
//                     style: Constant.purple16,
//                   ),
//                   children: [
//                     Text("ini html"),
//                     (Html(
//                       data: detailP.productDetailModel.data?.content ?? "",
//                       style: {
//                         "body": Style(
//                           fontFamily: 'Open-Sans',
//                           color: Constant.tertiaryColor,
//                           fontSize: FontSize(16),
//                           fontWeight: FontWeight.w400,
//                         )
//                       },
//                     )),
//                   ],
//                 ),
//             ],
//           ),
//           Container(
//             height: 1,
//             decoration: BoxDecoration(color: Color(0xFFE9E9E9)),
//           ),
//           // ExpansionTile(
//           //   title: Text(
//           //     "Toko",
//           //     style: Constant.darkBold16,
//           //   ),
//           //   children: [
//           //     ListTile(
//           //       title: Text(
//           //         "The first notebook of its kind, this Apple MacBook Pro is a beast. With the blazing-fast M1 Pro chip - the first Apple silicon designed for pros.",
//           //         style: Constant.dark16,
//           //       ),
//           //     ),
//           //     ListTile(
//           //       title: Text(
//           //         "Lihat Semua",
//           //         style: Constant.purple16,
//           //       ),
//           //     ),
//           //   ],
//           // ),
//           // Container(
//           //   height: 1,
//           //   decoration: BoxDecoration(color: Color(0xFFE9E9E9)),
//           // ),
//           // ExpansionTile(
//           //   title: Text(
//           //     "Pengiriman Dan Pengembalian",
//           //     style: Constant.darkBold16,
//           //   ),
//           //   children: [
//           //     ListTile(
//           //       title: Text(
//           //         "The first notebook of its kind, this Apple MacBook Pro is a beast. With the blazing-fast M1 Pro chip - the first Apple silicon designed for pros.",
//           //         style: Constant.dark16,
//           //       ),
//           //     ),
//           //     ListTile(
//           //       title: Text(
//           //         "Lihat Semua",
//           //         style: Constant.purple16,
//           //       ),
//           //     ),
//           //   ],
//           // ),
//           // Container(
//           //   height: 1,
//           //   decoration: BoxDecoration(color: Color(0xFFE9E9E9)),
//           // ),
//           ExpansionTile(
//             title: Text(
//               "Pertanyaan dan Jawaban",
//               style: Constant.darkBold16,
//             ),
//             children: [
//               ...List.generate(
//                   detailP.getProductDetailModel.data?.faq?.length ?? 1,
//                   (index) {
//                 return ExpansionTile(
//                   title: Text(
//                     ((detailP.getProductDetailModel.data?.faq?[index])
//                                 ?.question ??
//                             "")
//                         .toString(),
//                     style: Constant.dark16,
//                   ),
//                   children: [
//                     ListTile(
//                       contentPadding: EdgeInsets.only(left: 30, right: 20),
//                       title: Text(
//                         ((detailP.getProductDetailModel.data?.faq?[index])
//                                     ?.answer ??
//                                 "")
//                             .toString(),
//                         style: Constant.dark14,
//                       ),
//                     ),
//                   ],
//                 );
//               }),
//               if (detailP.getProductDetailModel.data?.faq?.length != 0)
//                 ListTile(
//                   title: InkWell(
//                     onTap: () async {
//                       handleTap(() async {
//                         Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                                 builder: (context) => ProductFaqView()));
//                       });
//                     },
//                     child: Text(
//                       "Lihat Semua",
//                       style: Constant.purple16,
//                     ),
//                   ),
//                 ),
//             ],
//           ),
//           Container(
//             height: 1,
//             decoration: BoxDecoration(color: Color(0xFFE9E9E9)),
//           ),
//           SizedBox(height: 30),
//           Text(
//             "Ulasan Pelanggan",
//             style: Constant.primaryBold16.copyWith(fontSize: 16),
//           ),
//           SizedBox(height: 20),
//           Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 ((detailP.getProductDetailModel.data?.rating) ?? "4.9")
//                     .toString(),
//                 // style: Constant.bigRatingNumber,
//               ),
//               SizedBox(width: 15),
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisAlignment: MainAxisAlignment.spaceAround,
//                 children: [
//                   SizedBox(height: 20),
//                   RatingBar(
//                     ignoreGestures: true,
//                     initialRating:
//                         ((detailP.getProductDetailModel.data?.rating) ?? 5)
//                             .toDouble(),
//                     minRating: 0,
//                     direction: Axis.horizontal,
//                     allowHalfRating: true,
//                     itemCount: 5,
//                     itemSize: 20,
//                     ratingWidget: RatingWidget(
//                       full: Icon(Icons.star_rounded,
//                           color: Colors.yellow.shade600),
//                       half: Icon(Icons.star_half_rounded,
//                           color: Colors.yellow.shade600),
//                       empty:
//                           Icon(Icons.star_rounded, color: Colors.grey.shade300),
//                     ),
//                     itemPadding: const EdgeInsets.symmetric(horizontal: 0),
//                     onRatingUpdate: (double value) {},
//                   ),
//                   SizedBox(height: 5),
//                   Text(
//                     (detailP.getProductDetailModel.data?.detailReviews?.length)
//                             .toString() +
//                         " reviews",
//                   ),
//                 ],
//               ),
//               SizedBox(height: 10),
//             ],
//           ),
//           Container(
//             height: 1,
//             decoration: BoxDecoration(color: Constant.borderLightColor),
//           ),
//           // SizedBox(height: 5),
//           // InkWell(
//           //   onTap: () {
//           //     Navigator.push(
//           //       context,
//           //       MaterialPageRoute(
//           //         builder: (context) {
//           //           return ProductReviewView();
//           //         },
//           //       ),
//           //     );
//           //   },
//           //   child: Padding(
//           //     padding: const EdgeInsets.symmetric(horizontal: 25.0),
//           //     child: Row(
//           //       mainAxisAlignment: MainAxisAlignment.end,
//           //       children: [
//           //         Text("View All"),
//           //       ],
//           //     ),
//           //   ),
//           // ),
//           SizedBox(height: 20),
//           if (detailP.getProductDetailModel.data?.detailReviews?.length != 0)
//             InkWell(
//               onTap: () async {
//                 handleTap(() async {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) {
//                         return ProductReviewView(id: widget.id);
//                       },
//                     ),
//                   );
//                 });
//               },
//               child: Row(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Container(
//                     width: 40,
//                     height: 40,
//                     child: SafeNetworkImage.circle(
//                       url: (detailP.getProductDetailModel.data
//                               ?.detailReviews?[0]?.photo ??
//                           ""),
//                       radius: 50,
//                       errorBuilder: CircleAvatar(),
//                     ),
//                   ),
//                   SizedBox(width: 10),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         RatingBar(
//                           ignoreGestures: true,
//                           initialRating: ((detailP.getProductDetailModel.data
//                                       ?.detailReviews?[0]?.star) ??
//                                   5)
//                               .toDouble(),
//                           minRating: 1,
//                           direction: Axis.horizontal,
//                           allowHalfRating: true,
//                           itemCount: 5,
//                           itemSize: 15,
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
//                         SizedBox(height: 15),
//                         // Text(
//                         //   ((detailP.getProductDetailModel.data?.detailReviews?[0]
//                         //           ?.customerName) ??
//                         //       "Reviewed by Ali Tufan - April 27, 2022"),
//                         //   style: Constant.reviewedBy,
//                         // ),
//                         RichText(
//                           text: TextSpan(
//                               text: "Reviewed by ",
//                               style:
//                                   Constant.grayRegular13.copyWith(fontSize: 14),
//                               children: [
//                                 TextSpan(
//                                     text: (detailP.getProductDetailModel.data
//                                         ?.detailReviews?[0]?.customerName),
//                                     style: TextStyle(fontSize: 14)),
//                                 TextSpan(text: " - "),
//                                 TextSpan(
//                                     text: detailP.getProductDetailModel.data ==
//                                             null
//                                         ? ""
//                                         : "${DateFormat('dd MMMM yyyy').format(DateTime.parse((detailP.getProductDetailModel.data?.detailReviews?[0]?.createdAt).toString()))}",
//                                     style: TextStyle(fontSize: 14)),
//                               ]),
//                         ),
//                         SizedBox(height: 15),
//                         Text(
//                           (detailP.getProductDetailModel.data?.detailReviews?[0]
//                                   ?.comment) ??
//                               "This Amazon listing has two different processors, the M1 Pro (listed as 16-Core GPU 'style') and the M1 Max (32-Core GPU). I'll call one the Pro, the other the Max. I got the base Pro, but much of what I'll say applies to both, and I'll have some comments specifically about the Max too. (MBP below = MacBook Pro.)",
//                           style: Constant.dark14,
//                         ),
//                         SizedBox(height: 15),
//                         Container(
//                           height: 80,
//                           width: double.infinity,
//                           child: ListView.separated(
//                             shrinkWrap: true,
//                             scrollDirection: Axis.horizontal,
//                             itemCount: (detailP.getProductDetailModel.data
//                                     ?.detailReviews?[0]?.images?.length) ??
//                                 0,
//                             separatorBuilder: (context, index) => SizedBox(
//                               width: 1,
//                             ),
//                             itemBuilder: (context, index) {
//                               return Container(
//                                 width: 80,
//                                 height: 80,
//                                 padding: EdgeInsets.all(8),
//                                 child: SafeNetworkImage(
//                                   width: 80,
//                                   height: 80,
//                                   url: (detailP.getProductDetailModel.data
//                                           ?.detailReviews?[0]?.images?[index] ??
//                                       ""),
//                                 ),
//                                 // decoration: BoxDecoration(
//                                 //   color: Colors.transparent,
//                                 //   borderRadius: BorderRadius.circular(10),
//                                 //   border: Border.all(color: Color(0xffEAEAEA)),
//                                 //   image: DecorationImage(
//                                 //     image: AssetImage(
//                                 //         'assets/icons/ic_cordless.png'),
//                                 //     fit: BoxFit.contain,
//                                 //   ),
//                                 // ),
//                               );
//                             },
//                           ),
//                         ),
//                         SizedBox(height: 15),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           SizedBox(height: 5),
//           if (detailP.getProductDetailModel.data?.detailReviews?.length != 0)
//             Container(
//               height: 1,
//               decoration: BoxDecoration(color: Constant.borderLightColor),
//             ),
//           SizedBox(height: 30),
//         ],
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
//     Widget buyCartButton() {
//       return Container(
//         padding: EdgeInsets.all(10),
//         color: Colors.white,
//         child: Container(
//           child: Row(
//             children: [
//               // Ini keranjang
//               CustomButton.secondaryButton(" + Keranjang ", () async {
//                 if (detailP.getProductDetailModel.data?.productAttributeSets
//                         ?.isEmpty ??
//                     false) {
//                   // context.read<ShoppingCartProvider>().addToCart(context,
//                   //     productId: detailP.getProductDetailModel.data?.id ?? 0,
//                   //     qty: 1,
//                   //     note: "");
//                   detailP.cartClickNoVariant(context);
//                   // Utils.showSuccess(msg: "Berhasil Menambahkan Ke Keranjang!");
//                 } else {
//                   await detailP.cartClick(context);
//                 }
//               }),
//               SizedBox(width: 10),
//               Expanded(
//                 child: CustomButton.mainButton(("Beli Sekarang"), () async {
//                   final checkoutP = context.read<CheckOutProvider>();
//                   if (detailP.getProductDetailModel.data?.productAttributeSets
//                           ?.isEmpty ??
//                       false) {
//                     // Navigator.push(
//                     //     context,
//                     //     MaterialPageRoute(
//                     //         builder: (context) => CheckOutBuyNowView()));
//                     checkoutP.selectedShipping = null;
//                     // context
//                     //     .read<ShoppingCartProvider>()
//                     //     .fetchBuyNowCartConfirm(context)
//                     //     .then((value) {
//                     //   Navigator.push(
//                     //       context,
//                     //       MaterialPageRoute(
//                     //           builder: (context) => CheckOutBuyNowView()));
//                     // });
//                     await detailP.cartClickNoVariant(context);
//                   } else {
//                     await detailP.cartClick(context);
//                   }
//                 }),
//               ),
//             ],
//           ),
//         ),
//       );
//     }
//
//     return Scaffold(
//       appBar: AppBar(
//         systemOverlayStyle:
//             SystemUiOverlayStyle(statusBarColor: Constant.primaryColor),
//         title: const Text("Detail"),
//         actions: [
//           Container(
//             width: 40,
//             margin: EdgeInsets.fromLTRB(10, 10, 20, 10),
//             decoration: BoxDecoration(
//               color: Color.fromRGBO(157, 156, 156, 0.2),
//               borderRadius: BorderRadius.circular(6),
//             ),
//             child: Badge(
//               label: Text(
//                 "1"
//                   // (cartP.getShoppingCartModel.data?.countItem ?? 0).toString()
//               ),
//               // textColor: (cartP.getShoppingCartModel.data?.countItem != 0)
//               //     ? Color.fromRGBO(11, 30, 64, 1)
//               //     : Color.fromRGBO(11, 30, 64, 0),
//               // backgroundColor: (cartP.getShoppingCartModel.data?.countItem != 0)
//               //     ? Color.fromRGBO(245, 195, 75, 1)
//               //     : Color.fromRGBO(11, 30, 64, 0),
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
//       body: RefreshIndicator(
//         onRefresh: () async {
//           // context.read<ProductProvider>().productDetailColorChip.clear();
//           // context.read<ProductProvider>().productDetailSizeChip.clear();
//           await context
//               .read<ProductProvider>()
//               .fetchProductDetail(withLoading: true, id: widget.id);
//
//           context.read<ProductProvider>().controllerQuantity.text = "1";
//           await context
//               .read<ShoppingCartProvider>()
//               .fetchShoppingCart(context, withLoading: true);
//           super.initState();
//         },
//         child: Column(
//           children: [
//             Expanded(
//               child: SingleChildScrollView(
//                 child: Container(
//                   padding: EdgeInsets.only(top: 20, left: 20, right: 20),
//                   color: Colors.white,
//                   child: Column(
//                     children: [
//                       headerProductDetail(),
//                       // SizedBox(height: 10),
//                       Container(
//                           padding: EdgeInsets.only(bottom: 16),
//                           decoration: BoxDecoration(
//                               color: Colors.white,
//                               borderRadius: BorderRadius.circular(10)),
//                           child: _buildDotsIndicator(
//                               numberOfDots: detailP.productDetailModel.data
//                                       ?.images?.length ??
//                                   1)),
//                       SizedBox(height: 10),
//                       ratingShareFavSave(widget.id.toString()),
//                       SizedBox(height: 10),
//                       productDetailMain(),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//             buyCartButton(),
//           ],
//         ),
//       ),
//     );
//   }
//
//   void _shareLink(String url) {
//     Share.share(url, subject: 'Check out this link!');
//   }
// }
