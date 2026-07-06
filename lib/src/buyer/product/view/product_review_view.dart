// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:provider/provider.dart';
// import 'package:flutter_rating_bar/flutter_rating_bar.dart';
// import 'package:mspeed/common/helper/safe_network_image.dart';
// import 'package:mspeed/src/cart/view/shopping_cart_view.dart';
// import 'package:mspeed/src/cart/model/shopping_cart_model.dart';
// import 'package:mspeed/src/cart/provider/shopping_cart_provider.dart';
// import 'package:mspeed/src/product/provider/product_provider.dart';

// import '../../../common/helper/constant.dart';
// import '../../../common/base/base_state.dart';

// class ProductReviewView extends StatefulWidget {
//   final int id;

//   const ProductReviewView({Key? key, required this.id}) : super(key: key);

//   @override
//   State<ProductReviewView> createState() => _ProductReviewViewState();
// }

// class _ProductReviewViewState extends BaseState<ProductReviewView> {
//   @override
//   void initState() {
//     super.initState();
//     context.read<ShoppingCartProvider>().fetchShoppingCart(context, withLoading: true);
//     context
//         .read<ProductProvider>()
//         .fetchProductDetail(id: widget.id, withLoading: true);
//   }

//   @override
//   Widget build(BuildContext context) {
//     final detailP = context.watch<ProductProvider>().getProductDetailModel.data;
//     final cartP = context.watch<ShoppingCartProvider>();
//     Widget reviewStar() {
//       return Container(
//         padding: EdgeInsets.all(10.0),
//         width: double.infinity,
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Column(
//               children: [
//                 Text(
//                   ((detailP?.rating.toString()) ?? "4.9"),
//                   // style: Constant.bigRatingNumber,
//                 ),
//                 RatingBar(
//                   ignoreGestures: true,
//                   initialRating: ((detailP?.rating) ?? 4.9).toDouble(),
//                   minRating: 1,
//                   direction: Axis.horizontal,
//                   allowHalfRating: true,
//                   itemCount: 5,
//                   itemSize: 15,
//                   ratingWidget: RatingWidget(
//                     full:
//                         Icon(Icons.star_rounded, color: Colors.yellow.shade600),
//                     half: Icon(Icons.star_half_rounded,
//                         color: Colors.yellow.shade600),
//                     empty:
//                         Icon(Icons.star_rounded, color: Colors.grey.shade300),
//                   ),
//                   itemPadding: const EdgeInsets.symmetric(horizontal: 0),
//                   onRatingUpdate: (double value) {},
//                 ),
//                 Text((detailP?.detailReviews?.length).toString() + " reviews"),
//               ],
//             ),
//             SizedBox(width: 10),
//             Container(
//               width: 1,
//               height: 100,
//               decoration: BoxDecoration(color: Color(0xFFE9E9E9)),
//             ),
//             SizedBox(width: 10),
//             Expanded(
//               flex: 7,
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.start,
//                 children: [
//                   Row(
//                     children: [
//                       Text("5 Star"),
//                       SizedBox(width: 10),
//                       Container(
//                         width: 160,
//                         child: ClipRRect(
//                           borderRadius: BorderRadius.circular(10),
//                           child: LinearProgressIndicator(
//                             value: 0.89,
//                             minHeight: 10,
//                             color: Colors.yellow[700],
//                             backgroundColor: Colors.black12,
//                           ),
//                         ),
//                       ),
//                       SizedBox(width: 10),
//                       Text("89%"),
//                     ],
//                   ),
//                   Row(
//                     children: [
//                       Text("4 Star"),
//                       SizedBox(width: 10),
//                       Container(
//                         width: 160,
//                         child: ClipRRect(
//                           borderRadius: BorderRadius.circular(10),
//                           child: LinearProgressIndicator(
//                             value: 0.7,
//                             minHeight: 10,
//                             color: Colors.yellow[700],
//                             backgroundColor: Colors.black12,
//                           ),
//                         ),
//                       ),
//                       SizedBox(width: 10),
//                       Text("70%"),
//                     ],
//                   ),
//                   Row(
//                     children: [
//                       Text("3 Star"),
//                       SizedBox(width: 10),
//                       Container(
//                         width: 160,
//                         child: ClipRRect(
//                           borderRadius: BorderRadius.circular(10),
//                           child: LinearProgressIndicator(
//                             value: 0.4,
//                             minHeight: 10,
//                             color: Colors.yellow[700],
//                             backgroundColor: Colors.black12,
//                           ),
//                         ),
//                       ),
//                       SizedBox(width: 10),
//                       Text("40%"),
//                     ],
//                   ),
//                   Row(
//                     children: [
//                       Text("2 Star"),
//                       SizedBox(width: 10),
//                       Container(
//                         width: 160,
//                         child: ClipRRect(
//                           borderRadius: BorderRadius.circular(10),
//                           child: LinearProgressIndicator(
//                             value: 0.25,
//                             minHeight: 10,
//                             color: Colors.yellow[700],
//                             backgroundColor: Colors.black12,
//                           ),
//                         ),
//                       ),
//                       SizedBox(width: 10),
//                       Text("25%"),
//                     ],
//                   ),
//                   Row(
//                     children: [
//                       Text("1 Star"),
//                       SizedBox(width: 10),
//                       Container(
//                         width: 160,
//                         child: ClipRRect(
//                           borderRadius: BorderRadius.circular(10),
//                           child: LinearProgressIndicator(
//                             value: 0.1,
//                             minHeight: 10,
//                             color: Colors.yellow[700],
//                             backgroundColor: Colors.black12,
//                           ),
//                         ),
//                       ),
//                       SizedBox(width: 10),
//                       Text("10%"),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       );
//     }

//     Widget viewReview() {
//       return Column(
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceAround,
//             children: [
//               Container(
//                 width: 140,
//                 height: 41,
//                 decoration: ShapeDecoration(
//                   color: Color(0xFF1F3291),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(50),
//                   ),
//                 ),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     SizedBox(width: 5),
//                     Text(
//                       'All Reviews',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 15,
//                         fontFamily: 'Open-Sans',
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               Container(
//                 height: 41,
//                 width: 125,
//                 padding: EdgeInsets.symmetric(horizontal: 10),
//                 // constraints: BoxConstraints(
//                 //   maxWidth: 200
//                 // ),
//                 decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(20),
//                     color: Colors.white,
//                     border: Border.all(
//                       color: Constant.primaryColor,
//                       width: 0.5,
//                     )),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Text(
//                       'Photo & Video',
//                       style: Constant.darkMedium14,
//                     ),
//                   ],
//                 ),
//               ),
//               Container(
//                 height: 41,
//                 width: 100,
//                 // constraints: BoxConstraints(
//                 //   maxWidth: 200
//                 // ),
//                 decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(20),
//                     color: Colors.white,
//                     border: Border.all(
//                       color: Constant.primaryColor,
//                       width: 0.5,
//                     )),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Text(
//                       'Rating',
//                       style: Constant.darkMedium14,
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(height: 20),
//           Container(
//             padding: EdgeInsets.symmetric(horizontal: 20),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text((detailP?.detailReviews?.length).toString() + " reviews"),
//                 Text("Write Your Review"),
//               ],
//             ),
//           ),
//           SizedBox(height: 15),
//           Container(
//             height: 1,
//             decoration: BoxDecoration(
//               color: Color(0xFFE9E9E9),
//             ),
//           ),
//           SizedBox(height: 20),
//           // ListView.separated(
//           //   shrinkWrap: true,
//           //   scrollDirection: Axis.horizontal,
//           //   itemCount: (detailP?.detailReviews?.length) ?? 0,
//           //   separatorBuilder: (context, index) => SizedBox(width: 0),
//           //   itemBuilder: (context, index) {},
//           // ),
//           Container(
//             child: ListView.separated(
//               shrinkWrap: true,
//               scrollDirection: Axis.vertical,
//               physics: NeverScrollableScrollPhysics(),
//               itemCount: (detailP?.detailReviews?.length) ?? 0,
//               separatorBuilder: (context, index) => Column(
//                 children: [
//                   Container(
//                     height: 1,
//                     decoration: BoxDecoration(
//                       color: Color(0xFFE9E9E9),
//                     ),
//                   ),
//                   SizedBox(height: 20),
//                 ],
//               ),
//               itemBuilder: (context, index) {
//                 return Row(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     //CircleAvatar(),
//                     Container(
//                       width: 40,
//                       height: 40,
//                       child: SafeNetworkImage.circle(
//                         url: (detailP?.detailReviews?[index]?.photo ?? ""),
//                         radius: 50,
//                         errorBuilder: CircleAvatar(),
//                       ),
//                     ),
//                     SizedBox(width: 10),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           RatingBar(
//                             ignoreGestures: true,
//                             initialRating:
//                                 ((detailP?.detailReviews?[index]?.star) ?? 5)
//                                     .toDouble(),
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
//                           SizedBox(height: 15),
//                           RichText(
//                             text: TextSpan(
//                                 text: "Reviewed by ",
//                                 style: Constant.grayRegular13,
//                                 children: [
//                                   TextSpan(
//                                     text: (detailP
//                                         ?.detailReviews?[index]?.customerName),
//                                   ),
//                                   TextSpan(text: " - "),
//                                   TextSpan(
//                                     text:
//                                         "${DateFormat('dd MMMM yyyy').format(DateTime.parse((detailP?.detailReviews?[index]?.createdAt).toString()))}",
//                                   ),
//                                 ]),
//                           ),
//                           SizedBox(height: 15),
//                           Text(
//                             (detailP?.detailReviews?[index]?.comment) ??
//                                 "This Amazon listing has two different processors, the M1 Pro (listed as 16-Core GPU 'style') and the M1 Max (32-Core GPU). I'll call one the Pro, the other the Max. I got the base Pro, but much of what I'll say applies to both, and I'll have some comments specifically about the Max too. (MBP below = MacBook Pro.)",
//                             style: Constant.dark16,
//                           ),
//                           SizedBox(height: 15),
//                           Container(
//                             height: 80,
//                             width: double.infinity,
//                             child: ListView.separated(
//                               shrinkWrap: true,
//                               scrollDirection: Axis.horizontal,
//                               itemCount: (detailP?.detailReviews?[index]?.images
//                                       ?.length) ??
//                                   0,
//                               separatorBuilder: (context, index) => SizedBox(
//                                 width: 1,
//                               ),
//                               itemBuilder: (context, index1) {
//                                 return Container(
//                                   width: 80,
//                                   height: 80,
//                                   padding: EdgeInsets.all(8),
//                                   child: SafeNetworkImage(
//                                     width: 80,
//                                     height: 80,
//                                     url: (detailP?.detailReviews?[index]
//                                             ?.images?[index1] ??
//                                         ""),
//                                   ),
//                                   // decoration: BoxDecoration(
//                                   //   color: Colors.transparent,
//                                   //   borderRadius: BorderRadius.circular(10),
//                                   //   border: Border.all(color: Color(0xffEAEAEA)),
//                                   //   image: DecorationImage(
//                                   //     image: AssetImage(
//                                   //         'assets/icons/ic_cordless.png'),
//                                   //     fit: BoxFit.contain,
//                                   //   ),
//                                   // ),
//                                 );
//                               },
//                             ),
//                           ),
//                           SizedBox(height: 15),
//                         ],
//                       ),
//                     ),
//                   ],
//                 );
//               },
//             ),
//           ),
//         ],
//       );
//     }

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Review"),
//         actions: [
//           Container(
//             width: 40,
//             margin: EdgeInsets.fromLTRB(10, 10, 20, 10),
//             decoration: BoxDecoration(
//               color: Color.fromRGBO(255, 255, 255, 0.1), //.withOpacity(0.2),
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
//       body: Column(
//         children: [
//           Expanded(
//             child: SingleChildScrollView(
//               physics: AlwaysScrollableScrollPhysics(),
//               child: Container(
//                 margin: EdgeInsets.only(top: 20, left: 20, right: 20),
//                 child: Column(
//                   children: [
//                     reviewStar(),
//                     SizedBox(height: 20),
//                     viewReview(),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
