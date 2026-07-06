// import 'package:adaptive_dialog/adaptive_dialog.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_rating_bar/flutter_rating_bar.dart';
// import 'package:intl/intl.dart';
// import 'package:provider/provider.dart';
// import 'package:share_plus/share_plus.dart';
// import 'package:mspeed/common/component/custom_button.dart';
// import 'package:mspeed/common/component/custom_container.dart';
// import 'package:mspeed/common/component/custom_textfield.dart';
// import 'package:mspeed/src/checkout/view/check_out_view.dart';
// import 'package:mspeed/src/product/provider/product_provider.dart';
// import 'package:mspeed/src/product/view/product_review_view.dart';
// import 'package:mspeed/src/cart/model/shopping_cart_model.dart';
// import 'package:mspeed/src/cart/provider/shopping_cart_provider.dart';
// import 'package:mspeed/utils/utils.dart';
//
// import '../../../common/helper/constant.dart';
// import '../../../common/base/base_state.dart';
// import '../../../common/helper/safe_network_image.dart';
//
// /// This is the [ProductDetailViewNotLogin] class which represents the view for displaying product details.
// /// It is a [StatefulWidget] that manages its own state using [_ProductDetailViewNotLoginState].
// /// It includes various widgets such as product preview, dots indicator, header, rating and sharing buttons, and product details.
// class ProductDetailViewNotLogin extends StatefulWidget {
//   final int id;
//
//   const ProductDetailViewNotLogin({super.key, required this.id});
//   @override
//   State<ProductDetailViewNotLogin> createState() =>
//       _ProductDetailViewNotLoginState();
// }
//
// /// This is the private state class [_ProductDetailViewNotLoginState] for [ProductDetailViewNotLogin].
// /// It extends [BaseState] and implements [TickerProviderStateMixin].
// /// It manages the current index, quantity, and controller for the quantity input field.
//
// class _ProductDetailViewNotLoginState
//     extends BaseState<ProductDetailViewNotLogin> with TickerProviderStateMixin {
//   int _currentIndex = 0;
//   int _quantity = 1;
//   TextEditingController controllerQuantity = TextEditingController();
//
//   @override
//   void initState() {
//     context
//         .read<ProductProvider>()
//         .fetchProductDetail(withLoading: true, id: widget.id);
//     controllerQuantity.text = _quantity.toString();
//     super.initState();
//     //context.read<ShoppingCartProvider>().fetchShoppingCart(withLoading: true);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final detailP = context.watch<ProductProvider>();
//     final cartP = context.watch<ShoppingCartProvider>();
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
//         color: Colors.white,
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: List.generate(
//             numberOfDots,
//                 (index) => Container(
//               width: _currentIndex == index ? 16 : 8.0,
//               height: 8.0,
//               margin: EdgeInsets.symmetric(horizontal: 2),
//               decoration: BoxDecoration(
//                 borderRadius:
//                 _currentIndex == index ? BorderRadius.circular(10) : null,
//                 shape:
//                 _currentIndex == index ? BoxShape.rectangle : BoxShape.circle,
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
//                     (index) => productPreview(index)),
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
//                 BoxDecoration(color: Color.fromRGBO(233, 233, 233, 1)),
//               ),
//               SizedBox(width: 10),
//               RatingBar(
//                 ignoreGestures: true,
//                 initialRating:
//                 ((detailP.getProductDetailModel.data?.rating) ?? 5)
//                     .toDouble(),
//                 minRating: 0,
//                 direction: Axis.horizontal,
//                 allowHalfRating: true,
//                 itemCount: 5,
//                 itemSize: 15,
//                 ratingWidget: RatingWidget(
//                   full: Icon(Icons.star_rounded, color: Colors.yellow.shade600),
//                   half: Icon(Icons.star_half_rounded,
//                       color: Colors.yellow.shade600),
//                   empty: Icon(Icons.star_rounded, color: Colors.grey.shade300),
//                 ),
//                 itemPadding: const EdgeInsets.symmetric(horizontal: 0),
//                 onRatingUpdate: (double value) {},
//               ),
//               SizedBox(width: 10),
//               Text(
//                   "${NumberFormat.compact().format(detailP.getProductDetailModel.data?.detailReviews?.length)} reviews"),
//             ],
//           ),
//           Wrap(
//             children: [
//               InkWell(
//                 onTap: () async {
//                   handleTap(() async {});
//                   Navigator.push(context, MaterialPageRoute(builder: (context)=> SignInView()));
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
//                           new Text("This is the content of the dialog"),
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
//                     Navigator.push(context, MaterialPageRoute(builder: (context)=> SignInView()));
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
//               itemCount: detailP.productDetailModel.data?.images?.length ?? 0,
//               separatorBuilder: (context, index) => SizedBox(
//                 width: 16,
//               ),
//               itemBuilder: (context, index) {
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
//               SafeNetworkImage(
//                   width: 22,
//                   height: 22,
//                   errorBuilder: CircleAvatar(),
//                   url: detailP.getProductDetailModel.data?.store?.logo ?? ""),
//               SizedBox(width: 10),
//               Expanded(
//                 child: InkWell(
//                   onTap: () => Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                           builder: (context) => VendorView.create())),
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
//                             detailP.getProductDetailModel.data?.store?.storeSlug ?? "-",
//                             style: Constant.darkBold14,
//                           ),
//                           Text(
//                             " | ",
//                             style: Constant.darkBold14,
//                           ),
//                           Text(
//                             detailP.getProductDetailModel.data?.store?.name ?? "",
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
//                             const EdgeInsets.symmetric(horizontal: 0),
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
//               "Detail Dan Spesifikasi",
//               style: Constant.darkBold16,
//             ),
//             children: [
//               (Html(
//                 data: detailP.productDetailModel.data?.description ?? "",
//                 style: {
//                   "body": Style(
//                     fontFamily: 'Open-Sans',
//                     color: Constant.tertiaryColor,
//                     fontSize: FontSize(16),
//                     fontWeight: FontWeight.w400,
//                   )
//                 },
//               )),
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
//               ExpansionTile(
//                 title: Text(
//                   "Lihat Semua",
//                   style: Constant.purple16,
//                 ),
//                 children: [
//                   (Html(
//                     data: detailP.productDetailModel.data?.content ?? "",
//                     style: {
//                       "body": Style(
//                         fontFamily: 'Open-Sans',
//                         color: Constant.tertiaryColor,
//                         fontSize: FontSize(16),
//                         fontWeight: FontWeight.w400,
//                       )
//                     },
//                   )),
//                 ],
//               ),
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
//               "Pertanyaan Dan Jawaban",
//               style: Constant.darkBold16,
//             ),
//             children: [
//               ...List.generate(
//                   detailP.getProductDetailModel.data?.faq?.length ?? 1,
//                       (index) {
//                     return ExpansionTile(
//                       title: Text(
//                         ((detailP.getProductDetailModel.data?.faq?[index])?.question ??
//                             "")
//                             .toString(),
//                         style: Constant.dark16,
//                       ),
//                       children: [
//                         ListTile(
//                           contentPadding: EdgeInsets.only(left: 30, right: 20),
//                           title: Text(
//                             ((detailP.getProductDetailModel.data?.faq?[index])
//                                 ?.answer ??
//                                 "")
//                                 .toString(),
//                             style: Constant.dark14,
//                           ),
//                         ),
//                       ],
//                     );
//                   }
//               ),
//               ListTile(
//                 title: InkWell(
//                   onTap: ()async {
//                     handleTap(()async {
//                       Navigator.push(context, MaterialPageRoute(builder: (context)=>SignInView()));
//                     } );
//                   },
//                   child: Text(
//                     "Lihat Semua",
//                     style: Constant.purple16,
//                   ),
//                 ),
//               ),
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
//                     ((detailP.getProductDetailModel.data?.rating) ?? 5)
//                         .toDouble(),
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
//                       Icon(Icons.star_rounded, color: Colors.grey.shade300),
//                     ),
//                     itemPadding: const EdgeInsets.symmetric(horizontal: 0),
//                     onRatingUpdate: (double value) {},
//                   ),
//                   SizedBox(height: 5),
//                   Text(
//                     (detailP.getProductDetailModel.data?.detailReviews?.length)
//                         .toString() +
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
//                           ?.detailReviews?[0]?.photo ??
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
//                               ?.detailReviews?[0]?.star) ??
//                               5)
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
//                           const EdgeInsets.symmetric(horizontal: 0),
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
//                               style: Constant.reviewedBy.copyWith(fontSize: 14),
//                               children: [
//                                 TextSpan(
//                                     text: (detailP.getProductDetailModel.data
//                                         ?.detailReviews?[0]?.customerName), style: TextStyle(fontSize: 14)
//                                 ),
//                                 TextSpan(text: " - "),
//                                 TextSpan(
//                                     text:
//                                     "${DateFormat('dd MMMM yyyy').format(DateTime.parse((detailP.getProductDetailModel.data?.detailReviews?[0]?.createdAt).toString()))}", style: TextStyle(fontSize: 14)
//                                 ),
//                               ]),
//                         ),
//                         SizedBox(height: 15),
//                         Text(
//                           (detailP.getProductDetailModel.data?.detailReviews?[0]
//                               ?.comment) ??
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
//                                 ?.detailReviews?[0]?.images?.length) ??
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
//                                       ?.detailReviews?[0]?.images?[index] ??
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
//           required bool value,
//           Widget? label,
//           EdgeInsetsGeometry? labelPadding,
//           required void Function(bool)? onSelected}) {
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
//           required bool value,
//           required Color color,
//           required void Function(bool)? onSelected}) {
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
//               CustomButton.cartButton(
//                 "",
//                   () async {
//                     handleTap(() async {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) {
//                             return SignInView();
//                           },
//                         ),
//                       );
//                     });
//                   }
//               ),
//               SizedBox(width: 10),
//               Expanded(
//                 child: CustomButton.mainButton(
//                   ("Buy Now"),
//                       () async {
//                     handleTap(() async {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) {
//                             return SignInView();
//                           },
//                         ),
//                       );
//                     });
//                   },
//                 ),
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
//         SystemUiOverlayStyle(statusBarColor: Constant.primaryColor),
//         title: const Text("Detail"),
//         actions: [
//           Container(
//             width: 40,
//             margin: EdgeInsets.fromLTRB(10, 10, 20, 10),
//             decoration: BoxDecoration(
//               color: Color.fromRGBO(157, 156, 156, 0.2),
//               borderRadius: BorderRadius.circular(6),
//             ),
//             child: InkWell(
//                 onTap: () async {
//                   handleTap(() async {
//                     Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                             builder: (context) => SignInView()));
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
//         ],
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: SingleChildScrollView(
//               child: Container(
//                 margin: EdgeInsets.only(top: 20, left: 20, right: 20),
//                 child: Column(
//                   children: [
//                     headerProductDetail(),
//                     // SizedBox(height: 10),
//                     Container(
//                         padding: EdgeInsets.only(bottom: 16),
//                         decoration: BoxDecoration(
//                             color: Colors.white,
//                             borderRadius: BorderRadius.circular(10)),
//                         child: _buildDotsIndicator(
//                             numberOfDots: detailP
//                                 .productDetailModel.data?.images?.length ??
//                                 1)),
//                     SizedBox(height: 10),
//                     ratingShareFavSave(widget.id.toString()),
//                     SizedBox(height: 10),
//                     productDetailMain(),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//           buyCartButton(),
//         ],
//       ),
//     );
//
//   }
// }
