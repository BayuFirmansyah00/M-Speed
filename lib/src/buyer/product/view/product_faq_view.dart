// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:mspeed/common/component/custom_appbar.dart';
// import 'package:mspeed/common/helper/constant.dart';
// import 'package:mspeed/src/product/provider/product_provider.dart';

// class ProductFaqView extends StatefulWidget {
//   const ProductFaqView({super.key});

//   @override
//   State<ProductFaqView> createState() => _ProductFaqViewState();
// }

// class _ProductFaqViewState extends State<ProductFaqView> {
//   @override
//   Widget build(BuildContext context) {
//     final faqP = context.watch<ProductProvider>();
//     return Scaffold(
//       appBar: CustomAppBar.appBar(context, "FAQ",
//           titleSpacing: 16,
//           color: Colors.white,
//           textStyle: TextStyle(color: Constant.primaryColor),
//           foregroundColor: Constant.primaryColor),
//       body: SingleChildScrollView(
//         child: Column(
//           children: List.generate(
//                 faqP.getProductDetailModel.data?.faq?.length ?? 0,
//                     (index) {
//                   return ExpansionTile(
//                     title: Text(
//                       ((faqP.getProductDetailModel.data?.faq?[index])?.question ??
//                           "")
//                           .toString(),
//                       style: Constant.dark16,
//                     ),
//                     children: [
//                       ListTile(
//                         contentPadding: EdgeInsets.only(left: 30, right: 20),
//                         title: Text(
//                           ((faqP.getProductDetailModel.data?.faq?[index])
//                               ?.answer ??
//                               "")
//                               .toString(),
//                           style: Constant.dark14,
//                         ),
//                       ),
//                     ],
//                   );
//                 }
//             ),
//           ),
//         ),
//     );
//   }
// }
