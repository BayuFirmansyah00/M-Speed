// import 'dart:developer';

// import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:mspeed/main.dart';
// import 'package:mspeed/view/auth/auth_view.dart';
// import 'package:mspeed/view/profile/profile_sport_center_view.dart';

// class DynamicLinkHandler {
//   _handleDeepLinks() async {
//     final PendingDynamicLinkData? initialLink =
//         await FirebaseDynamicLinks.instance.getInitialLink();
//     if (initialLink != null) {
//       final Uri deepLink = initialLink.link;
//       log('DYNAMIC LINK TEST uri:${deepLink.path}');
//       log('DYNAMIC LINK TEST uri PARAM :${deepLink.queryParametersAll}');
//       if (deepLink.path.contains('/test')) {
//         mainRouter.navigateWidget(const AuthLogin());
//       }
//     }
//   }

//   FirebaseDynamicLinks dynamicLinks = FirebaseDynamicLinks.instance;
//   Future<void> initDynamicLinks() async {
//     await FirebaseMessaging.instance.getInitialMessage();
//     Future.delayed(Duration(seconds: 1), () async {
//       final initialLink = await dynamicLinks.getInitialLink();
//       print('DYNAMIC LINK TEST urisplash:${initialLink?.link.path}');
//     });
//     dynamicLinks.onLink.listen((dynamicLinkData) async {
//       print("DYNAMIC LISTENING");
//       // Listen and retrieve dynamic links here
//       final String deepLink = dynamicLinkData.link.toString();
//       print("DYNAMIC LINK : $deepLink"); // Get DEEP LINK
//       print(
//           'DYNAMIC LINK TEST uri PARAM :${dynamicLinkData.link.queryParameters}');
//       final String path = dynamicLinkData.link.path;
//       bool isLoggedIn = preferences.isLoggedIn();
//       bool isDefaultScIdExists = preferences.isDefaultScIdExists();
//       log("DYNAMIC IS LOGGED IN : $isLoggedIn");
//       log("DYNAMIC IS DEF SC EXISTS : $isDefaultScIdExists");
//       log("DYNAMIC LINK CONTAIN TESTLINK : ${deepLink.contains("/testlink")}");
//       final initialLink = await dynamicLinks.getInitialLink();
//       log('DYNAMIC LINK TEST uri:${initialLink?.link.path}');
//       if (deepLink.contains("/testlink") ||
//           initialLink!.link.path.contains("/testlink")) {
//         if (isLoggedIn && isDefaultScIdExists) {
//           mainRouter.navigateWidgetReplace(HomeScreen(
//               scId: int.parse(
//                   dynamicLinkData.link.queryParameters['id'] ?? "0")));
//         } else if (isLoggedIn && !(isDefaultScIdExists)) {
//           if ((dynamicLinkData.link.queryParameters['id'] ?? "0") != "0") {
//             mainRouter.navigateWidgetReplace(HomeScreen(
//                 scId: int.parse(
//                     dynamicLinkData.link.queryParameters['id'] ?? "0")));
//           } else {
//             mainRouter.navigateWidgetReplace(ProfileSportCenterView());
//           }
//         } else {
//           mainRouter.navigateWidgetReplace(const AuthLogin());
//         }
//       } else {
//         mainRouter.navigateWidget(HomeScreen()); // Get PATH
//       }
//       // log("DYNAMIC LINK PATH : $path");
//       // if (deepLink.isEmpty) return;
//       // handleDeepLink(dynamicLinkData.link);
//     }).onError((error) {
//       log("DYNAMIC LINK ERROR : " + error.message);
//     });

//     Future.delayed(Duration(seconds: 1), () async {
//       final initialLink = await dynamicLinks.getInitialLink();
//       print('DYNAMIC LINK TEST urisplash:${initialLink?.link.path}');
//     });
//     // await initUniLinks();
//   }

//   Future<void> initUniLinks() async {
//     try {
//       // mainRouter.navigateWidget(const AuthLogin());
//       log("DYNAMIC IS LOGGED IN : ${(preferences.isLoggedIn())}");
//       log("DYNAMIC IS DEF SC EXISTS : ${(preferences.isDefaultScIdExists())}");
//       log("BEFORE DYNAMIC LINK TEST uri");
//       final initialLink = await dynamicLinks.getInitialLink();

//       log('DYNAMIC LINK TEST uri:${initialLink!.link.path}');
//       if (initialLink == null) return;
//       handleDeepLink(initialLink.link);
//     } catch (e) {
//       // Error
//     }
//   }

//   void handleDeepLink(Uri uriLink) {
//     if (uriLink.path.contains("/testlink")) {
//       mainRouter.navigateWidgetReplace(
//         (preferences.isLoggedIn())
//             ? (preferences.isDefaultScIdExists())
//                 ? HomeScreen(
//                     scId: int.parse(uriLink.queryParameters['id'] ?? "0"))
//                 : ProfileSportCenterView()
//             : const AuthLogin(),
//       );
//     }
//     mainRouter.navigateWidget(HomeScreen());
//   }
// }
