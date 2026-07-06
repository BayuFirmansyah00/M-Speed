import 'dart:async';

import 'package:flutter/services.dart';
import 'package:mspeed/common/page/image_preview.dart';
import 'package:mspeed/src/admin/home/provider/admin_home_provider.dart';
import 'package:mspeed/src/admin/home/view/admin_main_home.dart';
import 'package:mspeed/src/admin/master/provider/master_provider.dart';
import 'package:mspeed/src/admin/transaksi/provider/transaction_admin_provider.dart';
import 'package:mspeed/src/admin/user/provider/admin_form_buyer_provider.dart';
import 'package:mspeed/src/admin/user/provider/admin_form_keuangan_provider.dart';
import 'package:mspeed/src/admin/user/provider/admin_form_penerima_provider.dart';
import 'package:mspeed/src/admin/user/provider/admin_form_seller_provider.dart';
import 'package:mspeed/src/admin/user/provider/admin_user_provider.dart';
import 'package:mspeed/src/auth/provider/register_provider.dart';
import 'package:mspeed/src/auth/view/confirmation_view.dart';
import 'package:mspeed/src/auth/view/login_view.dart';
import 'package:mspeed/src/auth/view/token_view.dart';
import 'package:mspeed/src/buyer/address/provider/address_provider.dart';
import 'package:mspeed/src/buyer/address/provider/custom_map_provider.dart';
import 'package:mspeed/src/buyer/address/view/address_view.dart';
import 'package:mspeed/src/buyer/cart/provider/shopping_cart_provider.dart';
import 'package:mspeed/src/buyer/chat/provider/chat_provider.dart';
import 'package:mspeed/src/buyer/chat/view/chat_list_view.dart';
import 'package:mspeed/src/buyer/checkout/provider/checkout_provider.dart';
import 'package:mspeed/src/buyer/home/view/product_or_seller_search_view.dart';
import 'package:mspeed/src/buyer/home/view/search_toko_lainnya_view.dart';
import 'package:mspeed/src/buyer/notifikasi/provider/notifikasi_buyer_provider.dart';
import 'package:mspeed/src/buyer/notifikasi/view/notifikasi_view.dart';
import 'package:mspeed/src/buyer/product/provider/product_provider.dart';
import 'package:mspeed/src/buyer/product/view/product_viewer.dart';
import 'package:mspeed/src/buyer/profil/provider/profile_provider.dart';
import 'package:mspeed/src/buyer/profil/view/akun_saya_view.dart';
import 'package:mspeed/src/buyer/seller/provider/seller_provider.dart';
import 'package:mspeed/src/buyer/transaction/provider/transaction_provider.dart';
import 'package:mspeed/src/buyer/wishlist/provider/wishlist_provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'dart:developer';

import 'package:mspeed/common/helper/constant.dart';
import 'package:mspeed/src/buyer/home/provider/home_provider.dart';
import 'package:mspeed/src/buyer/home/view/main_home.dart';

import 'package:mspeed/src/buyer/region/provider/region_provider.dart';
import 'package:mspeed/src/keuangan/home/view/main_home_keuangan_view.dart';
import 'package:mspeed/src/keuangan/notifikasi/provider/notifikasi_keuangan_provider.dart';
import 'package:mspeed/src/keuangan/pesanan/provider/keuangan_provider.dart';
import 'package:mspeed/src/penerima/chat/provider/penerima_chat_provider.dart';
import 'package:mspeed/src/penerima/home/view/dashboard_pesanan_view.dart';
import 'package:mspeed/src/penerima/notifikasi/provider/notifikasi_penerima_provider.dart';
import 'package:mspeed/src/seller/chat/provider/chat_seller_provider.dart';
import 'package:mspeed/src/seller/nego/provider/nego_seller_provider.dart';
import 'package:mspeed/src/seller/notifikasi/provider/notifikasi_seller_provider.dart';
import 'package:mspeed/src/seller/pesanan/provider/seller_pesanan_provider.dart';
import 'package:mspeed/src/seller/produk/provider/produk_seller_provider.dart';
import 'package:mspeed/src/seller/profil/provider/profile_seller_provider.dart';
import 'package:mspeed/src/splash_view.dart';
import 'package:mspeed/src/buyer/transaction/view/transaction_list_view.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:timeago/timeago.dart' as TIMEAGO;
import 'common/component/timezone.dart';

import 'src/auth/provider/auth_provider.dart';
import 'src/auth/provider/change_password_provider.dart';
import 'src/penerima/pesanan/provider/penerima_pesanan_provider.dart';
import 'src/seller/home/provider/seller_home_provider.dart';
import 'src/seller/home/view/seller_main_home.dart';
import 'utils/nav_observer.dart';
import 'dart:io';
import 'package:google_maps_flutter_android/google_maps_flutter_android.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

import 'package:firebase_messaging/firebase_messaging.dart';

part 'common/routes.dart';

void main() async {
  runZonedGuarded(() async {
    await WidgetsFlutterBinding.ensureInitialized();

    await requestPermission(Permission.notification);

    // await requestPermission(Permission.storage);
    // await requestPermission(Permission.location);
    // await requestPermission(Permission.accessMediaLocation);
    // await requestPermission(Permission.manageExternalStorage);
    // await requestPermission(Permission.photos);
    if (Platform.isIOS) {
      await requestPermission(Permission.photos);
    }

    /// [START] initialize Firebase
    // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

    /// [START] Google maps config for reduce crash event while using Google Maps SDK
    final GoogleMapsFlutterPlatform mapsImplementation =
        GoogleMapsFlutterPlatform.instance;
    if (mapsImplementation is GoogleMapsFlutterAndroid) {
      mapsImplementation.useAndroidViewSurface = true;
    }

    /// [END]

    /// [START] initialize locale
    // init lib easy localization
    await EasyLocalization.ensureInitialized();
    // localized indonesian time ago
    TIMEAGO.setLocaleMessages("id", TIMEAGO.IdMessages());
    if (kDebugMode) {
      log(getTimezone());
    }

    /// [END] initialize locale

    // initialize crashlytics
    // await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
    // FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
    // FirebaseManager().initNotification();

    // FirebaseMessaging.instance.getToken().then((value) async {
    //   SharedPreferences prefs = await SharedPreferences.getInstance();
    //   prefs.setString(Constant.kSetPrefFcmToken, "${value ?? ""}");
    //   log("FCM token : $value");
    // });

    // await FirebaseMessaging.instance.setAutoInitEnabled(true);

    /// [END] initialize Firebase

    // check current device is emulator
    // if (Platform.isAndroid) {
    //   // if (await MethodChannel(Constant.APP_NAME).invokeMethod('is_emulator')) {
    //   final deviceInfo = await DeviceInfoPlugin().androidInfo;
    //   final data = {
    //     "board": deviceInfo.board,
    //     "brand": deviceInfo.brand,
    //     "product": deviceInfo.product,
    //     "full": deviceInfo.toString(),
    //     "timestamp": DateTime.now().millisecond
    //   };

    //   // await FirebaseCrashlytics.instance
    //   //     .log("Emulated user, data: ${jsonEncode(data)}");
    //   // await FirebaseCrashlytics.instance
    //   //     .recordError(Exception("Emulated Device Detected"), StackTrace.current);

    //   runApp(
    //     EasyLocalization(
    //       supportedLocales: [
    //         Locale('id', 'ID'),
    //         Locale('en'),
    //       ],
    //       path: 'assets/translations',
    //       // <-- change the path of the translation files
    //       fallbackLocale: Locale('id', 'ID'),
    //       child: Builder(
    //         builder: (context) {
    //           return MaterialApp(
    //             localizationsDelegates: context.localizationDelegates,
    //             supportedLocales: context.supportedLocales,
    //             locale: context.locale,
    //             transaction: EmulatorDetectedView(),
    //           );
    //         },
    //       ),
    //     ),
    //   );
    //   return;
    //   // }
    // }

    // initialize flutter downloader
    await FlutterDownloader.initialize(
      debug: false, // optional: set false to disable loging logs to console
    );
    // FlutterAppBadger.removeBadge();

    /// [START] Cache directory system management for storing Face Recognition Tflite Model & maintain lost image from state restoration
    /// Bersihkan directory cache
    getTemporaryDirectory().then((value) {
      Directory dir = Directory(value.path + '/download');
      if (dir.existsSync()) {
        dir.listSync().forEach((file) {
          file.deleteSync(recursive: true);
        });
      }
    });

    /// Buat temp directory untuk open only
    getTemporaryDirectory().then((value) {
      Directory dir = Directory(value.path + '/download');
      if (!dir.existsSync()) {
        dir.createSync(recursive: true);
      }
    });

    /// [END] Handle state restoration

    /// [START] initialRoute definition
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String initialRoute;

    if (kDebugMode) {
      log("[Bearer Token]");
      log(prefs.getString(Constant.kSetPrefToken) ?? "");
      log("[/Bearer Token]");

      log("[FCM Registration Token]");
      // log(await FirebaseMessaging.instance.getToken() ?? "");
      log("[/FCM Registration Token]");
    }

    if (prefs.getString(Constant.kSetPrefToken) == null) {
      //not signed in
      initialRoute = '/';
      // initialRoute = '/splash';
    } else {
      //signed in
      initialRoute = '/';
    }

    log("INITIAL ROUTE : $initialRoute");

    /// [END] initialRoute definition
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.white,
      systemNavigationBarColor: Colors.black,
      systemNavigationBarDividerColor: Colors.white,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ));
    runApp(
      //   MyApp(
      //   initialRoute: initialRoute,
      // )
      EasyLocalization(
        supportedLocales: [
          Locale('id', 'ID'),
          Locale('en'),
        ],
        path: 'assets/translations',
        fallbackLocale: Locale('id', 'ID'),
        child: MyApp(),
      ),

      // MyApp())
    );
  }, (error, stack) {});
}

class NavigationService {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
}

Future<bool> requestPermission(Permission permission) async {
  PermissionStatus status = await permission.request();
  return [PermissionStatus.granted, PermissionStatus.limited].contains(status);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    checkLang(context);
    return Sizer(
      builder: (context, orientation, deviceType) {
        return MultiProvider(
            providers: [
              ChangeNotifierProvider<AdminFormBuyerProvider>(
                  create: (context) => AdminFormBuyerProvider()),
              ChangeNotifierProvider<AdminFormSellerProvider>(
                  create: (context) => AdminFormSellerProvider()),
              ChangeNotifierProvider<AdminFormKeuanganProvider>(
                  create: (context) => AdminFormKeuanganProvider()),
              ChangeNotifierProvider<AdminFormPenerimaProvider>(
                  create: (context) => AdminFormPenerimaProvider()),
              ChangeNotifierProvider<NegoSellerProvider>(
                  create: (context) => NegoSellerProvider()),
              ChangeNotifierProvider<ProductProvider>(
                  create: (context) => ProductProvider()),
              ChangeNotifierProvider<ProdukSellerProvider>(
                  create: (context) => ProdukSellerProvider()),
              ChangeNotifierProvider<SellerProvider>(
                  create: (context) => SellerProvider()),
              ChangeNotifierProvider<AuthProvider>(
                  create: (context) => AuthProvider()),
              ChangeNotifierProvider<RegisterProvider>(
                  create: (context) => RegisterProvider()),
              ChangeNotifierProvider<HomeProvider>(
                  create: (context) => HomeProvider()),
              ChangeNotifierProvider<SellerHomeProvider>(
                  create: (context) => SellerHomeProvider()),
              ChangeNotifierProvider<AdminHomeProvider>(
                  create: (context) => AdminHomeProvider()),
              ChangeNotifierProvider<ChangePasswordProvider>(
                  create: (context) => ChangePasswordProvider()),
              ChangeNotifierProvider<RegionProvider>(
                  create: (context) => RegionProvider()),
              ChangeNotifierProvider<NotifikasiBuyerProvider>(
                  create: (context) => NotifikasiBuyerProvider()),
              ChangeNotifierProvider<NotifikasiSellerProvider>(
                  create: (context) => NotifikasiSellerProvider()),
              ChangeNotifierProvider<NotifikasiPenerimaProvider>(
                  create: (context) => NotifikasiPenerimaProvider()),
              ChangeNotifierProvider<NotifikasiKeuanganProvider>(
                  create: (context) => NotifikasiKeuanganProvider()),
              ChangeNotifierProvider<AddressProvider>(
                  create: (context) => AddressProvider()),
              ChangeNotifierProvider<AddressProvider>(
                  create: (context) => AddressProvider()),
              ChangeNotifierProvider<ShoppingCartProvider>(
                  create: (context) => ShoppingCartProvider()),
              ChangeNotifierProvider<CheckOutProvider>(
                  create: (context) => CheckOutProvider()),
              ChangeNotifierProvider<ChatProvider>(
                  create: (context) => ChatProvider()),
              ChangeNotifierProvider<ChatSellerProvider>(
                  create: (context) => ChatSellerProvider()),
              ChangeNotifierProvider<ProfileProvider>(
                  create: (context) => ProfileProvider()),
              ChangeNotifierProvider<ProfileSellerProvider>(
                  create: (context) => ProfileSellerProvider()),
              ChangeNotifierProvider<WishlistProvider>(
                  create: (context) => WishlistProvider()),
              ChangeNotifierProvider<PenerimaPesananProvider>(
                  create: (context) => PenerimaPesananProvider()),
              ChangeNotifierProvider<KeuanganProvider>(
                  create: (context) => KeuanganProvider()),
              ChangeNotifierProvider<TransactionProvider>(
                  create: (context) => TransactionProvider()),
              ChangeNotifierProvider<AdminHomeProvider>(
                  create: (context) => AdminHomeProvider()),
              ChangeNotifierProvider<AdminUserProvider>(
                  create: (context) => AdminUserProvider()),
              ChangeNotifierProvider<SellerPesananProvider>(
                  create: (context) => SellerPesananProvider()),
              ChangeNotifierProvider<PenerimaChatProvider>(
                  create: (context) => PenerimaChatProvider()),
              ChangeNotifierProvider<MasterProvider>(
                  create: (context) => MasterProvider()),
              ChangeNotifierProvider<TransactionAdminProvider>(
                  create: (context) => TransactionAdminProvider()),
              ChangeNotifierProvider<CustomMapProvider>(
                  create: (context) => CustomMapProvider()),
            ],
            child: MaterialApp(
              title: 'M-Speed',
              restorationScopeId: 'root',
              localizationsDelegates: context.localizationDelegates,
              supportedLocales: context.supportedLocales,
              locale: context.locale,
              navigatorObservers: [XNObsever()],
              navigatorKey: NavigationService.navigatorKey,
              theme: Constant.mainThemeData,
              color: Constant.primaryColor,
              initialRoute: '/',
              routes: _routes,
              builder: (context, child) {
                child = EasyLoading.init()(
                    context, child); // assuming this is returning a widget
                log(MediaQuery.of(context).size.toString());
                return MediaQuery(
                  child: child,
                  data: MediaQuery.of(context)
                      .copyWith(textScaler: TextScaler.linear(1)),
                );
              },
              debugShowCheckedModeBanner: false,
            ));
      },
    );
  }
}

Future checkLang(BuildContext context) async {
  try {
    final lang = Localizations.localeOf(context).languageCode;
    Intl.defaultLocale = lang;
  } catch (exception) {}
}

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // await Firebase.initializeApp();
  log("Handling a background message");
  log(message.data.toString());
}

// Future<Response> WrapLoading<Response>(Future<Response> future) async {
//   try {
//     Utils.showLoading();
//     Response data = await future;
//     Utils.dismissLoading();
//     return data;
//   } catch (e) {
//     Utils.dismissLoading();
//     rethrow;
//   }
// }

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
