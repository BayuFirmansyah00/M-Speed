part of '../main.dart';

Map<String, WidgetBuilder> get _routes => <String, WidgetBuilder>{
      '/': (context) => SplashView(),
      '/login': (context) => LoginView(),
      '/home': (context) => MainHome(),
      '/sellerHome': (context) => SellerMainHome(),
      '/penerimaHome': (context) => DashboardPesananView(),
      '/keuanganHome': (context) => MainHomeKeuanganView(),
      '/adminHome': (context) => AdminMainHome(),

      // '/forgot': (context) => ForgotView(),
      '/showImage': (context) => ImagePreview(),
      '/token': (context) => TokenView(),
      '/confirm': (context) => ConfirmationView(),
      '/transaction': (context) => TransactionListView(),
      '/assetMeter': (context) => ConfirmationView(),
      '/shipping': (context) => AddressView(),
      '/notification': (context) => NotificationView(),
      '/akun_saya': (context) => AkunSayaView(),
      // '/chat_person': (context) => ChatPersonView(),
      '/chat_list': (context) => ChatListView(),
      '/search': (context) => ProductOrSellerSearchView(),
      // '/detail_product': (context) => DetailProductView(),
      '/view_product': (context) => ProductViewer(),
      '/search_toko_lainnya': (context) => SearchTokoLainnyaView(),
      // '/seller_home_product': (context) => SellerHomeProductView(),
    };
