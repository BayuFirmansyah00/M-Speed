// import 'dart:developer';
// import 'dart:io';

// import 'package:chatour/common/component/custom_appbar.dart';
// import 'package:chatour/common/component/custom_button.dart';
// import 'package:chatour/common/component/custom_date_picker.dart';
// import 'package:chatour/common/component/custom_dropdown.dart';
// import 'package:chatour/common/component/custom_image_picker.dart';
// import 'package:chatour/common/component/custom_textfield.dart';
// import 'package:chatour/common/helper/constant.dart';
// import 'package:chatour/src/profil/provider/profile_provider_old.dart';
// import 'package:chatour/src/region/model/region_model.dart';
// import 'package:chatour/src/region/provider/region_provider.dart';
// import 'package:chatour/utils/utils.dart';
// import 'package:easy_localization/easy_localization.dart';
// import 'package:firebase_crashlytics/firebase_crashlytics.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:provider/provider.dart';

// import '../../../common/helper/safe_network_image.dart';

// class EditProfileView extends StatefulWidget {
//   @override
//   State<EditProfileView> createState() => _EditProfileViewState();
// }

// class _EditProfileViewState extends State<EditProfileView> {
//   @override
//   void initState() {
//     getData();
//     super.initState();
//   }

//   getData() async {
//     await Utils.showLoading();
//     await context.read<ProfileProvider>().fetchBank();
//     // setState(() {});
//     await context.read<RegionProvider>().fetchProvince();

//     final listProvince = context.read<RegionProvider>().provinceModel.data;
//     final listCity = context.read<RegionProvider>().cityModel.data;
//     final listDistrict = context.read<RegionProvider>().districtModel.data;

//     await context.read<ProfileProvider>().fetchProfile(
//           context: context,
//           withLoading: false,
//           provinceList: listProvince,
//           cityList: listCity,
//           districtList: listDistrict,
//         );
//     await Utils.dismissLoading();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final profileP = context.watch<ProfileProvider>();
//     final listBank =
//         context.watch<ProfileProvider>().bankModel.data?.banks ?? [];

//     final listProvince = context.watch<RegionProvider>().provinceModel.data;
//     final listCity = context.watch<RegionProvider>().cityModel.data;
//     final listDistrict = context.watch<RegionProvider>().districtModel.data;

//     FocusManager.instance.primaryFocus?.unfocus();
//     Widget header() {
//       return CustomAppBar.appBar('Edit Profile',
//           isCenter: true, isLeading: true, color: Colors.black);
//     }

//     Widget avatar() {
//       return InkWell(
//         onTap: () async {
//           var file = await CustomImagePicker.selectImageFromGallery();
//           if (file != null) {
//             profileP.profilePic = File(file.path);
//           }
//         },
//         child: Container(
//           margin: EdgeInsets.only(top: 24),
//           height: 115,
//           width: 115,
//           child: Center(
//             child: Stack(
//               children: [
//                 profileP.profilePic != null
//                     ? CircleAvatar(
//                         radius: 46,
//                         foregroundColor: Constant.primaryColor,
//                         backgroundImage:
//                             FileImage(File(profileP.profilePic!.path)),
//                       )
//                     : profileP.profileModel.data?.photoPath != null
//                         ? SafeNetworkImage.circle(
//                             url: profileP.profileModel.data?.photoPath ?? "",
//                             radius: 92,
//                             errorBuilder: CircleAvatar(
//                               radius: 46,
//                               backgroundImage:
//                                   AssetImage('assets/images/avatar.png'),
//                             ),
//                           )
//                         : CircleAvatar(
//                             radius: 46,
//                             foregroundColor: Constant.primaryColor,
//                             backgroundImage:
//                                 AssetImage('assets/images/avatar.png'),
//                           ),
//                 Positioned(
//                   right: 1,
//                   bottom: -2,
//                   child: Container(
//                     height: 38,
//                     width: 38,
//                     child: Image.asset(
//                       'assets/icons/edit_icon.png',
//                       fit: BoxFit.cover,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       );
//     }

//     Widget form() {
//       return Form(
//         key: profileP.profileKey,
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             SizedBox(height: 30),
//             CustomTextField.normalTextField(
//                 readOnly: true,
//                 controller: profileP.NIKC,
//                 labelText: "NIK",
//                 hintText: "NIK",
//                 textInputType: TextInputType.number),
//             SizedBox(height: 10),
//             CustomTextField.normalTextField(
//                 readOnly: true,
//                 controller: profileP.namaLengkapC,
//                 labelText: "Nama Lengkap",
//                 hintText: "Nama Lengkap"),
//             SizedBox(height: 10),
//             CustomTextField.normalTextField(
//                 readOnly: true,
//                 controller: profileP.emailC,
//                 labelText: "Email",
//                 hintText: "Email"),
//             SizedBox(height: 10),
//             CustomTextField.normalTextField(
//                 readOnly: true,
//                 controller: profileP.noTelpC,
//                 labelText: "No. Telp",
//                 hintText: "No. Telp",
//                 textInputType: TextInputType.number),
//             SizedBox(height: 10),
//             CustomTextField.normalTextField(
//                 readOnly: true,
//                 controller: profileP.tempatLahirC,
//                 labelText: "Tempat Lahir",
//                 hintText: "Tempat Lahir"),
//             SizedBox(height: 10),
//             CustomTextField.normalTextField(
//               controller: profileP.tanggalLahirC,
//               labelText: "Tanggal Lahir",
//               hintText: "Tanggal Lahir",
//               readOnly: true,
//               // onTap: () async {
//               //   await profileP.setTanggalLahir(
//               //       await CustomDatePicker.pickDateAndTime(context, DateTime.now()));
//               //   FocusManager.instance.primaryFocus?.unfocus();
//               // },
//               suffixIcon: Icon(Icons.calendar_month),
//               suffixIconColor: Colors.black,
//             ),
//             SizedBox(height: 10),
//             Padding(
//               padding: const EdgeInsets.only(left: 20, right: 20, bottom: 10),
//               child: Row(
//                 children: [
//                   Text(
//                     "Jenis Kelamin",
//                     style: Constant.primaryTextStyle.copyWith(
//                       fontSize: 14,
//                       fontWeight: Constant.medium,
//                     ),
//                   ),
//                   Text(
//                     '*',
//                     style: Constant.primaryTextStyle.copyWith(
//                       fontSize: 14,
//                       fontWeight: Constant.medium,
//                       color: Colors.red,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 8),
//               child: Row(
//                 children: [
//                   Radio(
//                     value: true,
//                     groupValue: profileP.gender,
//                     activeColor: Constant.primaryColor,
//                     onChanged: null,
//                     // onChanged: (value) =>
//                     //     context.read<ProfileProvider>().gender = value,
//                   ),
//                   Text(
//                     'Laki-laki',
//                     style: Constant.primaryTextStyle,
//                   ),
//                   Radio(
//                     value: false,
//                     groupValue: profileP.gender,
//                     activeColor: Constant.primaryColor,
//                     onChanged: null,
//                     // onChanged: (value) =>
//                     //     context.read<ProfileProvider>().gender = value,
//                   ),
//                   Text(
//                     'Perempuan',
//                     style: Constant.primaryTextStyle,
//                   ),
//                 ],
//               ),
//             ),
//             CustomTextField.normalTextField(
//                 readOnly: true,
//                 controller: profileP.alamatC,
//                 labelText: "Alamat",
//                 hintText: "Alamat"),
//             SizedBox(height: 10),
//             CustomTextField.normalTextField(
//               readOnly: true,
//               controller: profileP.provinceC,
//               labelText: "Provinsi",
//               hintText: "Pilih Provinsi",
//               suffixIcon: Padding(
//                 padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
//                 child: const Icon(Icons.arrow_forward_ios,
//                     color: Colors.black87, size: 18),
//               ),
//             ),
//             // CustomDropdown.normalDropdown(
//             //   readOnly: true,
//             //   labelText: "Provinsi",
//             //   hintText: "Pilih Provinsi",
//             //   selectedItem: profileP.provinsiNameV,
//             //   list: (listProvince ?? [])
//             //       .map((e) => DropdownMenuItem(
//             //           value: e?.province, child: Text(e?.province ?? "")))
//             //       .toList(),
//             //   onChanged: (val) {
//             //     profileP.kotaNameV = null;
//             //     profileP.kotaIdV = null;
//             //     profileP.provinsiNameV = val;
//             //     profileP.kecamatanIdV = null;
//             //     profileP.kecamatanNameV = null;
//             //     profileP.desaIdV = null;
//             //     profileP.desaNameV = null;
//             //     profileP.provinsiIdV = (listProvince ?? [])
//             //         .firstWhere((element) => element?.province == val)
//             //         ?.provinceId;
//             //     setState(() {});
//             //     context.read<RegionProvider>().cityModel = CityModel();
//             //     context
//             //         .read<RegionProvider>()
//             //         .fetchCity(profileP.provinsiIdV ?? "", withLoading: true);
//             //   },
//             //   required: true,
//             // ),
//             SizedBox(height: 10),
//             (listProvince ?? []).isEmpty ||
//                     (listCity ?? []).isEmpty ||
//                     (listDistrict ?? []).isEmpty
//                 ? SizedBox()
//                 : CustomTextField.normalTextField(
//                     readOnly: true,
//                     controller: profileP.kotaC,
//                     labelText: "Kabupaten / Kota",
//                     hintText: "Pilih Kabupaten / Kota",
//                     suffixIcon: Padding(
//                       padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
//                       child: const Icon(Icons.arrow_forward_ios,
//                           color: Colors.black87, size: 18),
//                     ),
//                   ),
//             // : CustomDropdown.normalDropdown(
//             //     readOnly: true,
//             //     labelText: "Kabupaten / Kota",
//             //     // selectedItem:
//             //     //     (listCity ?? []).isEmpty ? null : profileP.kotaNameV,
//             //     hintText: "Pilih Kabupaten / Kota",
//             //     list: (listCity ?? [])
//             //         .map((e) => DropdownMenuItem(
//             //             value: e?.cityName, child: Text(e?.cityName ?? "")))
//             //         .toList(),
//             //     onChanged: (val) {
//             //       profileP.kecamatanIdV = null;
//             //       profileP.kecamatanNameV = null;
//             //       profileP.kotaNameV = val;
//             //       profileP.kotaIdV = (listCity ?? [])
//             //           .firstWhere((element) => element?.cityName == val)
//             //           ?.cityId;
//             //       setState(() {});

//             //       context.read<RegionProvider>().districtModel =
//             //           DistrictModel();
//             //       context.read<RegionProvider>().fetchDistrict(
//             //           profileP.kotaIdV ?? "",
//             //           withLoading: true);
//             //     },
//             //     required: true,
//             //   ),
//             SizedBox(height: 10),

//             (listProvince ?? []).isEmpty ||
//                     (listCity ?? []).isEmpty ||
//                     (listDistrict ?? []).isEmpty
//                 ? SizedBox()
//                 : CustomTextField.normalTextField(
//                     readOnly: true,
//                     controller: profileP.kecamatanC,
//                     labelText: "Kecamatan",
//                     hintText: "Pilih Kecamatan",
//                     suffixIcon: Padding(
//                       padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
//                       child: const Icon(Icons.arrow_forward_ios,
//                           color: Colors.black87, size: 18),
//                     ),
//                   ),

//             // : CustomDropdown.normalDropdown(
//             //     readOnly: true,
//             //     labelText: "Kecamatan",
//             //     // selectedItem: (listDistrict ?? []).isEmpty
//             //     //     ? null
//             //     //     : profileP.kecamatanNameV,
//             //     hintText: "Pilih Kecamatan",
//             //     list: (listDistrict ?? [])
//             //         .map((e) => DropdownMenuItem(
//             //             value: e?.districtName,
//             //             child: Text(e?.districtName ?? "")))
//             //         .toList(),
//             //     onChanged: (val) {
//             //       profileP.desaIdV = null;
//             //       profileP.desaNameV = null;
//             //       profileP.kecamatanNameV = val;
//             //       profileP.kecamatanIdV = (listDistrict ?? [])
//             //           .firstWhere((element) => element?.districtName == val)
//             //           ?.districtId;
//             //       setState(() {});

//             //       context.read<RegionProvider>().subDistrictModel =
//             //           SubDistrictModel();
//             //       // context.read<RegionProvider>().fetchSubDistrict(
//             //       //     profileP.kecamatanIdV ?? "", profileP.kecamatanIdV ?? "");
//             //     },
//             //     required: true,
//             //   ),
//             // SizedBox(height: 10),
//             // CustomDropdown.normalDropdown(
//             //   labelText: "Kelurahan / Desa",
//             //   // selectedItem: profileP.desaNameV,
//             //   hintText: "Pilih Kelurahan / Desa",
//             //   list: (listSubDistrict ?? [])
//             //       .map((e) => DropdownMenuItem(
//             //           value: e?.subdistrictName,
//             //           child: Text(e!.subdistrictName!)))
//             //       .toList(),
//             //   onChanged: (val) {
//             //     profileP.desaNameV = val;
//             //     profileP.desaIdV = (listSubDistrict ?? [])
//             //         .firstWhere((element) => element?.subdistrictName == val)
//             //         ?.subdistrictId;
//             //     setState(() {});
//             //   },
//             // ),
//             SizedBox(height: 10),
//             CustomTextField.normalTextField(
//               readOnly: true,
//               controller: profileP.bankC,
//               labelText: "Bank Rekening",
//               hintText: "Pilih Bank Rekening",
//               suffixIcon: Padding(
//                 padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
//                 child: const Icon(Icons.arrow_forward_ios,
//                     color: Colors.black87, size: 18),
//               ),
//             ),
//             // CustomDropdown.normalDropdown(
//             //   readOnly: true,
//             //   labelText: "Bank Rekening",
//             //   hintText: "Pilih Bank Rekening",
//             //   controller: profileP.bankC,
//             //   list: listBank
//             //       .map((e) => DropdownMenuItem<String>(
//             //             value: e,
//             //             child: Text(e ?? ""),
//             //           ))
//             //       .toList(),
//             //   // selectedItem:
//             //   //     profileP.profileModel.data?.bankName.toString() == "null"
//             //   //         ? null
//             //   //         : profileP.bankRekV,
//             //   onChanged: (val) {
//             //     profileP.bankRekV = val;
//             //     setState(() {});
//             //   },
//             //   required: true,
//             // ),
//             SizedBox(height: 10),
//             CustomTextField.normalTextField(
//               readOnly: true,
//               controller: profileP.noRekC,
//               labelText: "Nomor Rekening",
//               hintText: "Nomor Rekening",
//               textInputType: TextInputType.number,
//               inputFormatters: [
//                 FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d?')),
//                 FilteringTextInputFormatter.digitsOnly
//               ],
//               required: true,
//             ),
//             SizedBox(height: 10),
//             CustomTextField.normalTextField(
//               readOnly: true,
//               controller: profileP.atasNamaRekC,
//               labelText: "Atas Nama Rekening",
//               hintText: "Atas Nama Rekening",
//               textCapitalization: TextCapitalization.words,
//               required: true,
//             ),
//             SizedBox(height: 10),
//           ],
//         ),
//       );
//     }

//     return Scaffold(
//       body: WillPopScope(
//         onWillPop: () async {
//           await Utils.showYesNoDialog(
//             context: context,
//             title: "Batalkan Edit Profil",
//             desc: 'Apakah Anda yakin ingin membatalkan edit profil?',
//             yesCallback: () async {
//               await context
//                   .read<ProfileProvider>()
//                   .clearEditProfile(deleteAll: false)
//                   .then((value) {
//                 Navigator.of(context)
//                   ..pop()
//                   ..pop();
//                 return true;
//               }).onError((error, stackTrace) {
//                 FirebaseCrashlytics.instance
//                     .log("Gagal Edit Profile Error : " + error.toString());
//                 Utils.showFailed(
//                     msg: error.toString().toLowerCase().contains("doctype")
//                         ? "Gagal Batalkan Edit Profile!"
//                         : "$error");
//                 return false;
//               });
//             },
//             noCallback: () {
//               Navigator.pop(context);
//             },
//           );
//           return false;
//         },
//         child: InkWell(
//           onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
//           child: Column(
//             children: [
//               Expanded(child: ListView(children: [header(), avatar(), form()])),
//               Padding(
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//                 child: CustomButton.mainButton('Simpan', () async {
//                   await context.read<ProfileProvider>().updateProfile().then(
//                       (value) async {
//                     await context
//                         .read<ProfileProvider>()
//                         .clearEditProfile(deleteAll: false);
//                     await Utils.showSuccess(msg: "Sukses Update Profil");
//                     Future.delayed(Duration(seconds: 3),
//                         () => Navigator.pop(context, true));
//                   }).onError((error, stackTrace) => Utils.showFailed(
//                       msg: error.toString().toLowerCase().contains("doctype")
//                           ? "Gagal Update Profil!"
//                           : "$error"));
//                 }),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
