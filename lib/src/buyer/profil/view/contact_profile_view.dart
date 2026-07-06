// import 'dart:io';
// import 'package:easy_localization/easy_localization.dart';
// import 'package:firebase_crashlytics/firebase_crashlytics.dart';
// import 'package:flutter/material.dart';
// import 'dart:async';
// import 'package:file_picker/file_picker.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../../../common/base/base_state.dart';
// import '../../../common/component/custom_alert.dart';
// import '../../../common/component/custom_appbar.dart';
// import '../../../common/component/custom_button.dart';
// import '../../../common/component/custom_container.dart';
// import '../../../common/component/custom_image_picker.dart';
// import '../../../common/component/custom_textfield.dart';
// import '../../../common/helper/constant.dart';
// import '../../../utils/utils.dart';
// import '../provider/profile_provider_old.dart';
// import 'package:path/path.dart' as p;

// class ContactProfileView extends StatefulWidget {
//   @override
//   State<StatefulWidget> createState() {
//     return ContactProfileViewState();
//   }
// }

// class ContactProfileViewState extends BaseState<ContactProfileView> {
//   FocusNode _focusNode = FocusNode();

//   final picker = ImagePicker();

//   final _formKey = GlobalKey<FormState>();

//   @override
//   void initState() {
//     super.initState();
//     setData();
//   }

//   void setData() async {
//     // SharedPreferences pref = await SharedPreferences.getInstance();
//     setState(() {
//       // _controller.formContact.name.text =
//       //     pref.getString(Constant.kSetPrefFirstName) ?? "";
//       // _controller.formContact.email.text =
//       //     pref.getString(Constant.kSetPrefEmail) ?? "";
//       // _controller.formContact.phone.text =
//       //     pref.getString(Constant.kSetPrefPhone) ?? "";
//     });
//   }

//   Future getImage() async {
//     // final pickedFile = await picker.getImage(
//     //   source: ImageSource.gallery,
//     //   imageQuality: 25,
//     // );
//     //
//     // if (pickedFile != null) {
//     //   setState(() {
//     //     _controller.formContact.attachment = XFile(pickedFile.path);
//     //   });
//     // }
//   }

//   _fileFromDocument() async {}

//   @override
//   Widget build(BuildContext context) {
//     final profileP = context.watch<ProfileProvider>();
//     Widget nameTF() {
//       return CustomTextField.normalTextField(
//         padding: EdgeInsets.zero,
//         controller: profileP.nameContactC,
//         hintText: "Nama",
//       );
//     }

//     Widget emailTF() {
//       return CustomTextField.normalTextField(
//         padding: EdgeInsets.zero,
//         controller: profileP.emailContactC,
//         hintText: "Email",
//       );
//     }

//     Widget phoneTF() {
//       return CustomTextField.normalTextField(
//         padding: EdgeInsets.zero,
//         controller: profileP.phoneContactC,
//         hintText: "No. Telepon",
//         textInputType: TextInputType.number,
//       );
//     }

//     Widget _buildMessage() {
//       return CustomTextField.normalTextArea(
//         _focusNode,
//         controller: profileP.messageContactC,
//         hint: "Pesan",
//       );
//     }

//     Widget _buildAttachment() {
//       return CustomContainer.mainCard(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             Text(
//               "Lampiran",
//               style: TextStyle(fontSize: 15),
//               textAlign: TextAlign.left,
//             ),
//             SizedBox(
//               height: 8,
//             ),
//             CustomButton.secondaryButton(
//               profileP.attachmentFile != null
//                   ? p.basename(profileP.attachmentFile?.path ?? "")
//                   : 'Unggah Lampiran',
//               () async {
//                 var file = await CustomImagePicker.cameraOrGallery(context);
//                 if (file != null) {
//                   profileP.attachmentFile = File(file.path);
//                 }
//               },
//             ),
//           ],
//         ),
//         isShadow: true,
//       );
//     }

//     return Scaffold(
//       appBar: CustomAppBar.appBar("Kontak Kami", color: Colors.black),
//       body: SingleChildScrollView(
//         child: InkWell(
//           onTap: () {
//             FocusScope.of(context).requestFocus(FocusNode());
//           },
//           child: Container(
//             padding: EdgeInsets.all(Constant.paddingSize),
//             child: Column(
//               children: [
//                 Container(
//                   child: CustomContainer.mainCard(
//                     child: Form(
//                       key: profileP.contactKey,
//                       child: Column(
//                         children: [
//                           nameTF(),
//                           SizedBox(height: 5),
//                           emailTF(),
//                           SizedBox(height: 5),
//                           phoneTF(),
//                           SizedBox(height: 5),
//                           _buildMessage(),
//                         ],
//                       ),
//                     ),
//                     isShadow: true,
//                   ),
//                 ),
//                 SizedBox(
//                   height: Constant.paddingSize,
//                 ),
//                 _buildAttachment(),
//                 SizedBox(
//                   height: Constant.paddingSize,
//                 ),
//                 CustomButton.mainButton("Kirim", () async {
//                   FocusScope.of(context).requestFocus(FocusNode());
//                   if (profileP.attachmentFile != null) {
//                     // length in bytes
//                     final length = await profileP.attachmentFile?.length();
//                     print(length);
//                     if ((length ?? 0) > 1000000) {
//                       CustomAlert.showSnackBar(
//                           context, "Maksimal unggah berkas 1000 mb", true);
//                       return;
//                     }
//                   }

//                   // If the form is valid, display a snackbar. In the real world,
//                   // you'd often call a server or save the information in a database.

//                   await context
//                       .read<ProfileProvider>()
//                       .sendContactForm()
//                       .then((value) async {
//                     await Utils.showSuccess(msg: "Sukses");
//                     Future.delayed(
//                         Duration(seconds: 2), () => Navigator.pop(context));
//                   }).onError((error, stackTrace) {
//                     FirebaseCrashlytics.instance
//                         .log("Kontak Kami Error : " + error.toString());
//                     Utils.showFailed(
//                         msg: error.toString().toLowerCase().contains("doctype")
//                             ? "Maaf, Terjadi Galat!"
//                             : error.toString());
//                   });
//                 }),
//                 SizedBox(height: Constant.paddingSize * 2),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
