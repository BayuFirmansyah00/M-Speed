// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_rating_bar/flutter_rating_bar.dart';
// import 'package:intl/intl.dart';
// import 'package:mspeed/common/helper/safe_network_image.dart';
// import 'package:mspeed/src/wishlist/model/wishlist_detail_model.dart';
// import 'package:mspeed/utils/utils.dart';
// import 'package:provider/provider.dart';
//
// import '../../../common/component/custom_container.dart';
// import '../../../common/helper/constant.dart';
// import '../../../common/base/base_state.dart';
// import '../../cart/view/shopping_cart_view.dart';
// import '../../product/view/product_detail_view.dart';
//
// import 'package:mspeed/src/cart/provider/shopping_cart_provider.dart';
//
// import '../provider/wishlist_provider.dart';
//
// class WishlistDetailView extends StatefulWidget {
//   final String id;
//   const WishlistDetailView({super.key, required this.id});
//
//   @override
//   State<WishlistDetailView> createState() => _WishlistDetailViewState();
// }
//
// class _WishlistDetailViewState extends BaseState<WishlistDetailView>
//     with TickerProviderStateMixin {
//   @override
//   void initState() {
//     context
//         .read<WishlistProvider>()
//         .fetchWishlistDetail(id: widget.id, withLoading: false);
//     context.read<ShoppingCartProvider>().fetchShoppingCart(context, withLoading: true);
//     super.initState();
//   }
//
//   refresh() async {
//     await context
//         .read<WishlistProvider>()
//         .fetchWishlistDetail(id: widget.id);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final cartP = context.watch<ShoppingCartProvider>();
//     final wDetailP = WishlistDetailModel().data;
//         // context.watch<WishlistProvider>().getWishListDetailModel.data;
//     final wishP = context.watch<WishlistProvider>();
//
//     Widget deleteProdukKoleksi(String id, String productId) {
//       return CustomContainer.showModalBottomScroll(
//           context: context, child: Column(
//         children: [
//           SizedBox(height: 20,),
//           InkWell(
//             onTap: () async {
//               await Utils.showYesNoDialog(context: context,
//                   title: ('Hapus product ?'),
//                   desc: 'Apakah Anda yakin ingin menghapus produk ini dari keranjang?',
//                   yesCallback: () async {
//                     await wishP.deleteProductWishlist(id: id, productId: productId).then((value) async {
//                       Utils.showToast("Berhasil menghapus Product");
//                       Navigator.pop(context);
//                       Navigator.pop(context);
//                     }).onError((error, stackTrace) async {
//                       Utils.showToast("Gagal menghapus Koleksi");
//                       Navigator.pop(context);
//                       Navigator.pop(context);
//                     });
//                   },
//                   noCallback: () {
//                     Navigator.pop(context);
//                     Navigator.pop(context);
//                   });
//             },
//             child: Row(
//               children: [
//                 Icon(Icons.delete, color: Constant.primaryColor,),
//                 SizedBox(width: 5,),
//                 Text("Hapus Koleksi", style: Constant.primaryTextStyle.copyWith(
//                     color: Constant.primaryColor)),
//
//               ],
//             ),
//           ),
//           SizedBox(height: 20,),
//
//         ],
//       ));
//     }
//
//     Widget itemGrid({
//       required String productId,
//       required String imagePath,
//       required String brand,
//       required String productName,
//       required double rating,
//       required int review,
//       required String normalPrice,
//       String discountPrice = "",
//       void Function()? onTap,
//     }) {
//       return Center(
//         child: Container(
//           padding: EdgeInsets.all(8),
//           decoration: BoxDecoration(
//               border: Border.all(
//             width: 1,
//             color: Constant.borderLightColor,
//           )),
//           child: InkWell(
//             onTap: onTap,
//             // () async {
//             //   handleTap(() async {
//             //     onTap;
//             //   });
//             // },
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Center(
//                   child:
//                       SafeNetworkImage(width: 100, height: 100, url: imagePath),
//                 ),
//                 Text(
//                   brand,
//                   style: Constant.brandGrey13,
//                 ),
//                 Text(
//                   productName,
//                   overflow: TextOverflow.ellipsis,
//                   maxLines: 2,
//                   style: Constant.productDark14,
//                 ),
//                 Row(
//                   children: [
//                     RatingBar(
//                       ignoreGestures: true,
//                       initialRating: rating,
//                       direction: Axis.horizontal,
//                       allowHalfRating: true,
//                       itemCount: 5,
//                       itemSize: 12,
//                       ratingWidget: RatingWidget(
//                         full: Icon(Icons.star_rounded,
//                             color: Colors.yellow.shade600),
//                         half: Icon(Icons.star_half_rounded,
//                             color: Colors.yellow.shade600),
//                         empty: Icon(Icons.star_rounded,
//                             color: Colors.grey.shade300),
//                       ),
//                       itemPadding: const EdgeInsets.symmetric(horizontal: 0),
//                       onRatingUpdate: (double value) {},
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.only(left: 3),
//                       child: Text(
//                         review > 999 ?
//                         "${review.toString()[0]}rb reviews"
//                             : "${review.toString()} reviews"
//                         ,
//                         overflow: TextOverflow.ellipsis,
//                         maxLines: 1,
//                         // "${NumberFormat.compact().format(3014)} reviews",
//                         style: Constant.grayRegular13,
//                       ),
//                     ),
//                   ],
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.only(bottom: 5),
//                   child: Row(
//                     children: [
//                       if (discountPrice != 0)
//                         Padding(
//                           padding: const EdgeInsets.only(right: 5),
//                           child: Text(
//                             discountPrice,
//                             // Utils.thousandSeparator(discountPrice),
//                             overflow: TextOverflow.ellipsis,
//                             maxLines: 1,
//                             style: Constant.darkBold12,
//                           ),
//                         ),
//                       if (discountPrice != 0)
//                         Expanded(
//                           flex: 5,
//                           child: Text(
//                             normalPrice,
//                             // Utils.thousandSeparator(normalPrice),
//                             overflow: TextOverflow.ellipsis,
//                             maxLines: 1,
//                             style: Constant.greyThrough12,
//                           ),
//                         ),
//                       if (discountPrice == 0)
//                         Expanded(
//                           flex: 5,
//                           child: Padding(
//                             padding: const EdgeInsets.only(right: 5),
//                             child: Text(
//                               normalPrice,
//                               // Utils.thousandSeparator(),
//                               overflow: TextOverflow.ellipsis,
//                               maxLines: 1,
//                               style: Constant.darkBold12,
//                             ),
//                           ),
//                         ),
//                     ],
//                   ),
//                 ),
//                 InkWell(
//                   onTap: () async {
//                     deleteProdukKoleksi(widget.id, productId);
//                   },
//                   child: Container(
//                       decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(10),
//                           border: Border.all(
//                               width: 1,
//                               color: Constant.borderLightColor
//                           )
//                       ),
//                       child: Icon(
//                         Icons.more_horiz,
//                         color: Colors.grey,
//                       )),
//                 )
//               ],
//             ),
//           ),
//         ),
//       );
//     }
//
//     /// This is the [contentSavedShoppingCartProducts] method.
//     /// It returns a [CustomContainer] widget that contains a grid view of saved shopping cart products.
//     /// The grid view is built using the [itemGrid] method.
//     Widget contentSavedShoppingCartProducts() {
//       // List<String> imagePathList = [
//       //   "ic_krisbow1.png",
//       //   "ic_combination_pliers.png",
//       //   "ic_kent_safety.png",
//       //   "ic_doublehook.png",
//       //   "ic_cordless.png",
//       //   "ic_combination_pliers.png",
//       // ];
//       if ((wDetailP?.items ?? []).isEmpty) {
//         return Utils.notFoundImage();
//       }
//       return CustomContainer.mainGridView2(
//         context: context,
//         itemCount: wDetailP?.items?.length ?? 0,
//         // childAspectRatio: 0.66,
//         itemBuilder: (context, index) {
//           final item = wDetailP?.items?[index];
//           return itemGrid(
//             imagePath: item?.image ?? "image wishlist",
//             brand: item?.option ?? "",
//             productName: item?.name ?? "-",
//             rating: (wDetailP?.items?[index]?.rating ?? 0).toDouble(),
//             review: 3010,
//             normalPrice: item?.pricePromo == 0 ? "" : item?.priceDesc ?? "0",
//             discountPrice: item?.pricePromo != 0
//                 ? item?.pricePromoDesc ?? "Rp 0"
//                 : item?.priceDesc ?? "",
//             productId: (item?.productId ?? "").toString(),
//             onTap: () {
//               handleTap(() async {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) {
//                       return ProductDetailView(id: item?.productId ?? 0);
//                     },
//                   ),
//                 );
//               });
//             },
//           );
//         },
//       );
//     }
//
//     return Scaffold(
//       appBar: AppBar(
//         systemOverlayStyle:
//             SystemUiOverlayStyle(statusBarColor: Constant.primaryColor),
//         title: const Text("Wishlist"),
//         actions: [
//           Container(
//             width: 40,
//             margin: EdgeInsets.fromLTRB(10, 10, 20, 10),
//             decoration: BoxDecoration(
//               color: Color.fromRGBO(255, 255, 255, 0.1),
//               borderRadius: BorderRadius.circular(6),
//             ),
//             child: Badge(
//               label: Text(
//                 "1"
//                   // (cartP.getShoppingCartModel.data?.countItem ?? 0)
//                   //     .toString()
//               ),
//                   // textColor: (cartP.getShoppingCartModel.data?.countItem != 0)
//                   //     ? Color.fromRGBO(11, 30, 64, 1)
//                   //     : Color.fromRGBO(11, 30, 64, 0),
//                   // backgroundColor:
//                   //     (cartP.getShoppingCartModel.data?.countItem != 0)
//                   //         ? Color.fromRGBO(245, 195, 75, 1)
//                   //         : Color.fromRGBO(11, 30, 64, 0),
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
//       body: RefreshIndicator(child:  SingleChildScrollView(
//         child: Container(
//           color: Colors.white,
//           padding: EdgeInsets.symmetric(horizontal: 20),
//           child: Column(
//             //crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               SizedBox(height: 20),
//               Row(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   Text(
//                     "Nama Wishlist",
//                     style: TextStyle(
//                         color: Constant.textColorBlue,
//                         fontWeight: Constant.semibold),
//                   ),
//                   Expanded(
//                       child: Text(
//                         "Jumlah Wishlist: ${wDetailP?.items?.length ?? 0} Barang",
//                         textAlign: TextAlign.right,
//                         style: TextStyle(
//                             color: Constant.textColor2,
//                             fontWeight: Constant.semibold),
//                       )),
//                 ],
//               ),
//               SizedBox(height: 20),
//               contentSavedShoppingCartProducts(),
//               SizedBox(height: 20),
//             ],
//           ),
//         ),
//       ), onRefresh: () async {
//         refresh();
//       })
//     );
//   }
// }
