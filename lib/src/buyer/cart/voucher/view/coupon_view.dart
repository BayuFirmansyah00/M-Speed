// import 'package:flutter/material.dart';
// import 'package:sibima/common/component/custom_appbar.dart';
// import 'package:sibima/src/checkout/view/check_out_view.dart';
// import 'package:sibima/utils/utils.dart';
// import 'package:sizer/sizer.dart';
//
// import '../../../../common/component/custom_button.dart';
// import '../../../../common/helper/constant.dart';
// import '../../../../common/base/base_state.dart';
//
// class CouponView extends StatefulWidget {
//   const CouponView({super.key});
//
//   @override
//   State<CouponView> createState() => _CouponViewState();
// }
//
// class _CouponViewState extends BaseState<CouponView> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: CustomAppBar.appBar("Pilih Kupon",
//           color: Colors.white,
//           foregroundColor: Colors.black,
//           textStyle: TextStyle(
//               color: Constant.textColorBlack, fontWeight: Constant.medium)),
//       body: Column(
//         children: [
//           Expanded(
//             child: SingleChildScrollView(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Padding(
//                     padding:
//                         const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
//                     child: Text(
//                       "Kode Kupon",
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         color: Constant.primaryColor,
//                       ),
//                     ),
//                   ),
//                   SizedBox(height: 8),
//                   ListView.separated(
//                     shrinkWrap: true,
//                     padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
//                     separatorBuilder: (_, __) => SizedBox(height: 16),
//                     itemCount: 2,
//                     itemBuilder: (context, index) {
//                       return Container(
//                         decoration: BoxDecoration(
//                             color: Color(0xffF6F8FB),
//                             borderRadius: BorderRadius.circular(16)),
//                         child: Row(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Expanded(
//                               child: Padding(
//                                 padding:
//                                     const EdgeInsets.fromLTRB(16, 8, 16, 12),
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text(
//                                       "Dapatkan kupon 150rb untuk pembelian produk Krisbow",
//                                       style: TextStyle(
//                                         fontSize: 14,
//                                         color: Constant.tertiaryColor,
//                                       ),
//                                     ),
//                                     SizedBox(height: 16),
//                                     RichText(
//                                       maxLines: 2,
//                                       overflow: TextOverflow.ellipsis,
//                                       text: TextSpan(
//                                         children: [
//                                           TextSpan(text: "Minim Belanja: "),
//                                           TextSpan(
//                                             text:
//                                                 Utils.thousandSeparator(650000),
//                                             style: TextStyle(
//                                               fontSize: 12,
//                                               fontWeight: Constant.bold,
//                                               fontFamily: 'Open-Sans',
//                                               color: Constant.primaryColor,
//                                             ),
//                                           ),
//                                         ],
//                                         style: TextStyle(
//                                           fontFamily: 'Open-Sans',
//                                           fontSize: 12,
//                                           color: Constant.tertiaryColor,
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                             InkWell(
//                               onTap: () async {
//                                 handleTap(() async {});
//                               },
//                               child: Container(
//                                 width: 30.w,
//                                 // height: 30.w,
//                                 child: Image.asset(
//                                   'assets/images/shopping_cart/kodekupon.png',
//                                   fit: BoxFit.fitWidth,
//                                 ),
//                               ),
//                             ),
//                             // Positioned(
//                             //   right: 20,
//                             //   bottom: 15,
//                             //   child: CustomButton.secondaryButton("Pakai", () {},
//                             //       padding: EdgeInsets.all(0)),
//                             // ),
//                           ],
//                         ),
//                       );
//                     },
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           SizedBox(height: 4),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//             child: Column(
//               children: [
//                 SizedBox(height: 20),
//                 CustomButton.mainButton('Pilih', () async {
//                   handleTap(() async {
//                     Navigator.push(context,
//                         MaterialPageRoute(builder: (context) {
//                       return CheckOutView();
//                     }));
//                   });
//                 }),
//               ],
//             ),
//           ),
//           SizedBox(height: 8),
//         ],
//       ),
//     );
//   }
// }
