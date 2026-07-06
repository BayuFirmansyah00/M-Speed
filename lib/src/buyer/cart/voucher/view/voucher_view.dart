// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:sibima/common/component/custom_appbar.dart';
// import 'package:sibima/common/component/custom_textfield.dart';
// import '../provider/voucher_provider.dart';
//
// import '../../../../common/component/custom_button.dart';
// import '../../../../common/helper/constant.dart';
// import '../../../../common/base/base_state.dart';
//
// class VoucherView extends StatefulWidget {
//   const VoucherView({super.key});
//
//   @override
//   State<VoucherView> createState() => _VoucherViewState();
// }
//
// class _VoucherViewState extends BaseState<VoucherView> {
//   @override
//   Widget build(BuildContext context) {
//     final voucherP = context.watch<VoucherProvider>();
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: CustomAppBar.appBar(
//         "Pilih Voucher",
//         color: Colors.white,
//         foregroundColor: Colors.black,
//         textStyle: TextStyle(
//           color: Constant.textColorBlack,
//           fontWeight: Constant.medium,
//         ),
//       ),
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
//                       "Voucher Diskon",
//                       style: TextStyle(
//                         fontWeight: FontWeight.w500,
//                         color: Constant.tertiaryColor,
//                       ),
//                     ),
//                   ),
//                   SizedBox(height: 8),
//                   ListView.separated(
//                     shrinkWrap: true,
//                     padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
//                     separatorBuilder: (_, __) => SizedBox(height: 8),
//                     itemCount: 2,
//                     itemBuilder: (context, index) {
//                       return InkWell(
//                         onTap: () {
//                           voucherP.setSelectedVoucher =
//                               !voucherP.getSelectedVoucher;
//                         },
//                         child: Stack(
//                           children: [
//                             Container(
//                               color: voucherP.getSelectedVoucher
//                                   ? Constant.primaryColor.withOpacity(0.5)
//                                   : Colors.white,
//                               child: Image.asset(
//                                   'assets/images/shopping_cart/voc1.png'),
//                             ),
//                             Positioned(
//                               right: 20,
//                               bottom: 15,
//                               child: CustomButton.secondaryButton(
//                                   voucherP.getSelectedVoucher
//                                       ? "Terpakai"
//                                       : "Pakai", () async {
//                                 handleTap(() async {});
//                               },
//                                   padding: EdgeInsets.all(0),
//                                   selected: voucherP.getSelectedVoucher),
//                             ),
//                           ],
//                         ),
//                       );
//                     },
//                   ),
//                   Padding(
//                     padding:
//                         const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
//                     child: Text(
//                       "Gratis Ongkir",
//                       style: TextStyle(
//                         fontWeight: FontWeight.w500,
//                         color: Constant.tertiaryColor,
//                       ),
//                     ),
//                   ),
//                   SizedBox(height: 8),
//                   ListView.separated(
//                     shrinkWrap: true,
//                     padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
//                     separatorBuilder: (_, __) => SizedBox(height: 8),
//                     itemCount: 2,
//                     itemBuilder: (context, index) {
//                       return Stack(
//                         children: [
//                           Container(
//                             child: Image.asset(
//                                 'assets/images/shopping_cart/voc2.png'),
//                           ),
//                           Positioned(
//                             right: 20,
//                             bottom: 15,
//                             child:
//                                 CustomButton.secondaryButton("Pakai", () async {
//                               handleTap(() async {});
//                             }, padding: EdgeInsets.all(0)),
//                           ),
//                         ],
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
//                 CustomTextField.borderTextField(
//                   controller: TextEditingController(),
//                   hintText: "Coupon Code",
//                   suffixIcon: InkWell(
//                     onTap: () async {
//                       handleTap(() async {});
//                     },
//                     child: Padding(
//                       padding: const EdgeInsets.fromLTRB(8, 14, 8, 0),
//                       child: Text(
//                         "Apply Coupon",
//                         style: TextStyle(
//                           color: Constant.textColor2,
//                           fontWeight: Constant.semibold,
//                           decoration: TextDecoration.underline,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//                 SizedBox(height: 16),
//                 CustomButton.mainButton('Simpan', () async {
//                   handleTap(() async {
//                     Navigator.pop(context);
//                     // Navigator.push(context,
//                     //     MaterialPageRoute(builder: (context) {
//                     //   return CouponView();
//                     // }));
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
