// import 'package:chatour/src/auth/provider/change_password_provider.dart';
// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/material.dart';
// import 'package:chatour/common/helper/constant.dart';
// import 'package:provider/provider.dart';
// import 'dart:async';

// import '../../../common/base/base_state.dart';
// import '../../../common/component/custom_alert.dart';
// import '../../../common/component/custom_appbar.dart';
// import '../../../common/component/custom_button.dart';
// import '../../../common/component/custom_textfield.dart';
// import '../../../utils/utils.dart';

// class ChangePasswordView extends StatefulWidget {
//   final String email;
//   ChangePasswordView({super.key, required this.email});
//   @override
//   State<StatefulWidget> createState() {
//     return ChangePasswordViewState();
//   }
// }

// class ChangePasswordViewState extends BaseState<ChangePasswordView> {
//   // ProfileController _controller = ProfileController();

//   @override
//   Widget build(BuildContext context) {
//     final changePassP = context.watch<ChangePasswordProvider>();
//     Widget oldPassTF() {
//       return CustomTextField.normalTextField(
//         controller: changePassP.oldPassC,
//         hintText: "Kata Sandi Lama",
//         obscureText: changePassP.obscureOldPass,
//         suffixIcon: InkWell(
//           onTap: () => changePassP.toggleObscureOldPass(),
//           child: Icon(
//             changePassP.obscureOldPass
//                 ? Icons.visibility_off
//                 : Icons.visibility,
//             color: Constant.primaryColor,
//           ),
//         ),
//       );
//     }

//     Widget newPassTF() {
//       return CustomTextField.normalTextField(
//         controller: changePassP.newPassC,
//         hintText: "Kata Sandi Baru",
//         obscureText: changePassP.obscureNewPass,
//         suffixIcon: InkWell(
//           onTap: () => changePassP.togegleObscureNewPass(),
//           child: Icon(
//             changePassP.obscureNewPass
//                 ? Icons.visibility_off
//                 : Icons.visibility,
//             color: Constant.primaryColor,
//           ),
//         ),
//       );
//     }

//     Widget confPassTF() {
//       return CustomTextField.normalTextField(
//         controller: changePassP.confirmNewPassC,
//         hintText: "Konfirmasi Kata Sandi",
//         obscureText: changePassP.obscureConfirmNewPass,
//         suffixIcon: InkWell(
//           onTap: () => changePassP.toggleObscureConfirmNewPass(),
//           child: Icon(
//             changePassP.obscureConfirmNewPass
//                 ? Icons.visibility_off
//                 : Icons.visibility,
//             color: Constant.primaryColor,
//           ),
//         ),
//       );
//     }

//     return Scaffold(
//       appBar: CustomAppBar.appBar("Ubah Password", color: Colors.black),
//       body: InkWell(
//         onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
//         child: SingleChildScrollView(
//           child: Stack(
//             children: [
//               Container(
//                 padding: EdgeInsets.all(Constant.paddingSize),
//                 child: Column(
//                   children: [
//                     Container(
//                       child: Card(
//                         margin: EdgeInsets.zero,
//                         shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(10.0)),
//                         child: Container(
//                           padding: EdgeInsets.only(top: 12, bottom: 22),
//                           child: Form(
//                             key: changePassP.changePassKey,
//                             child: Column(
//                               children: [
//                                 oldPassTF(),
//                                 SizedBox(height: 5),
//                                 newPassTF(),
//                                 SizedBox(height: 5),
//                                 confPassTF(),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                     SizedBox(height: 12),
//                     Padding(
//                       padding: EdgeInsets.only(
//                         right: 3,
//                         left: 3,
//                       ),
//                       child: CustomButton.mainButton(
//                         "Simpan",
//                         () async {
//                           try {
//                             final result = await context
//                                 .read<ChangePasswordProvider>()
//                                 .changePassword();
//                             if (result.result == 'success') {
//                               await Utils.showSuccess(
//                                   msg: "Sukses Mengubah Password");
//                               Navigator.pop(context);
//                             } else {
//                               Utils.showFailed(msg: result.message);
//                             }
//                           } catch (e) {
//                             Utils.showFailed(
//                                 msg: e
//                                         .toString()
//                                         .toLowerCase()
//                                         .contains("doctype")
//                                     ? "Maaf, Terjadi Galat!"
//                                     : "$e");
//                           }
//                         },
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
