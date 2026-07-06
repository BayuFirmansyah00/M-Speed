// import 'package:chatour/common/component/custom_appbar.dart';
// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';

// import 'package:package_info_plus/package_info_plus.dart';

// import '../../../common/base/base_state.dart';
// import '../../../common/helper/constant.dart';

// class AboutView extends StatefulWidget {
//   @override
//   State<StatefulWidget> createState() {
//     return AboutViewState();
//   }
// }

// class AboutViewState extends BaseState<AboutView> {
//   String version = "";

//   @override
//   void initState() {
//     super.initState();
//     getVersion();
//   }

//   void getVersion() async {
//     final package = await PackageInfo.fromPlatform();
//     setState(() {
//       version = package.version;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: CustomAppBar.appBar("Tentang", color: Colors.black),
//       backgroundColor: Constant.backgroundColor,
//       extendBodyBehindAppBar: true,
//       body: Column(
//         mainAxisSize: MainAxisSize.min,
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: [
//           SizedBox(height: 180),
//           Image(
//             image: AssetImage('assets/icons/LOGO CHATOUR ot.png'),
//             fit: BoxFit.contain,
//             width: 60,
//             height: 60,
//           ),
//           SizedBox(
//             height: Constant.paddingSize,
//           ),
//           Text(
//             "Versi " + "$version",
//             style: TextStyle(
//               fontWeight: FontWeight.bold,
//               fontSize: Constant.fontSizeRegular,
//             ),
//             textAlign: TextAlign.center,
//           ),
//           SizedBox(
//             height: Constant.paddingSize + 12,
//           ),
//           Text(
//             "Copyright \u00a9 ${DateFormat("yyyy").format(DateTime.now())} Chatour Travel",
//             style: TextStyle(
//               fontWeight: FontWeight.bold,
//               fontSize: Constant.fontSizeRegular,
//             ),
//             textAlign: TextAlign.center,
//           ),
//         ],
//       ),
//     );
//   }
// }
