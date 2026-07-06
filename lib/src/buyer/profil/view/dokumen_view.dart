// import 'package:chatour/common/base/base_state.dart';
// import 'package:flutter/material.dart';
// import 'package:chatour/common/helper/constant.dart';
// import 'package:chatour/src/profil/provider/profile_provider_old.dart';
// import 'package:provider/provider.dart';
// import 'package:url_launcher/url_launcher.dart';

// import '../../../common/component/custom_appbar.dart';

// class DokumenView extends StatefulWidget {
//   const DokumenView({super.key});

//   @override
//   State<DokumenView> createState() => _DokumenViewState();
// }

// class _DokumenViewState extends BaseState<DokumenView> {
//   List<String> documentType = [
//     "MoU",
//     "Sertifikat",
//     "ID Card",
//     "Surat Keputusan",
//   ];

//   @override
//   void initState() {
//     getData();
//     super.initState();
//   }

//   getData() async {
//     loading(true);
//     await context.read<ProfileProvider>()
//       ..fetchDokumen(type: 1)
//       ..fetchDokumen(type: 2)
//       ..fetchDokumen(type: 3)
//       ..fetchDokumen(type: 4);
//     loading(false);
//   }

//   @override
//   Widget build(BuildContext context) {
//     final mouP = context.watch<ProfileProvider>().mouModel.data;
//     final sertifikatP = context.watch<ProfileProvider>().sertifikatModel.data;
//     final idCardP = context.watch<ProfileProvider>().idCardModel.data;
//     final skP = context.watch<ProfileProvider>().skModel.data;

//     PreferredSizeWidget header() =>
//         CustomAppBar.appBar('Dokumen', color: Colors.black, isCenter: true);

//     Widget wDocumentType({required String title, required Function()? onTap}) {
//       return InkWell(
//         onTap: onTap,
//         child: Row(
//           children: [
//             Expanded(
//               child: Text(
//                 title,
//                 style: Constant.primaryTextStyle
//                     .copyWith(fontSize: 14, fontWeight: Constant.semibold),
//               ),
//             ),
//             Icon(Icons.arrow_forward_ios, size: 16)
//           ],
//         ),
//       );
//     }

//     return Scaffold(
//       appBar: header(),
//       body: ListView.separated(
//         padding: EdgeInsets.all(20),
//         shrinkWrap: true,
//         itemCount: documentType.length,
//         separatorBuilder: (_, __) =>
//             Divider(thickness: 1, color: Colors.grey.shade200),
//         itemBuilder: (_, __) {
//           final item = documentType[__];
//           return wDocumentType(
//             title: item,
//             onTap: () {
//               if (__ == 0) {
//                 launchUrl(Uri.parse(mouP?.url ?? ""));
//               } else if (__ == 1) {
//                 launchUrl(Uri.parse(sertifikatP?.url ?? ""));
//               } else if (__ == 2) {
//                 launchUrl(Uri.parse(idCardP?.url ?? ""));
//               } else {
//                 launchUrl(Uri.parse(skP?.url ?? ""));
//               }
//             },
//           );
//         },
//       ),
//     );
//   }
// }
