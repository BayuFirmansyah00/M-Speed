import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:google_fonts/google_fonts.dart';

import 'package:intl/intl.dart';
// import 'package:string_validator/string_validator.dart';

class Constant {
  /// KEY
  ///
  /// This constant using for default base api url, map key and app name
  /// Please be carefully to change this keys because might affect with all entire project .
  ///
  static const String MAPS_KEY = "AIzaSyDDPvYz8jGLntwWp-Nii2F7bvGADm504Ts";

  // static const String DOMAIN = "mspeed.erdata.id";
  // static const String DOMAIN2 = "mspeed.erdata.id";
  static const String DOMAIN = "mspeed.mitrakaryaprima.com";
  static const String DOMAIN2 = "mspeed.mitrakaryaprima.com";
  static const String DOMAIN_LOCAL = "10.0.2.2:8000"; // Laravel Local Server via Emulator
  
  static const String BASE_API_FULL = "https://${DOMAIN}/api"; // Production
  // static const String BASE_API_FULL = "http://${DOMAIN_LOCAL}/api"; // Local Dev
  static const String BASE_API_FULL2 = "https://${DOMAIN2}/api";
  static const String APP_NAME = "M-Speed";

  /// COlORS
  ///
  /// This constant using for default color theme base of design mockup, so
  /// you can add int as hexcode of color and you can use this constant like this .
  ///
  /// Constant.firstColor;
  ///
  static Color primaryColor = Color(0xFFED1C24);
  static Color secondaryColor = Color(0xFF0B4177);
  static Color tertiaryColor = Color(0xFF8CC6FF);
  static Color quarteryColor = Color(0xFFC5E2FF);
  static Color tableBlueColor = Color(0xFFE9F0FF);
  static Color textHyperlinkColor = Color(0xFF0095FF);
  static Color splashText = Color(0xFF569CB0);
  static Color darkGrayColor = Colors.grey.shade800;
  static Color grayColor = Colors.grey.shade600;
  static Color lightGrayColor = Colors.grey.shade400;
  static Color textHintColor = Color(0xFFE6E8E7);
  static Color textHintColor2 = Color(0xFF949494);
  static Color darkGrayButtonColor = Colors.black;
  static Color bgFieldColor = Color(0xff8CC6FF4D);
  static Color textColor = Color(0xFF100629);
  static Color textColor2 = Color(0xFF6D7588);
  static Color textKomisiColor = Color(0xFFFFCB47);
  static Color textPriceColor = Color(0xFF3DA11A);
  static Color backgroundColor = Color(0xFFF9F9F9);
  static Color textColorBlack = Color(0xff414D55);
  static Color textColorWhite = Colors.white;
  static Color textColorBlue = Color(0xFF041E42);
  static Color timerColor = Color(0xFFE7B641);
  static Color progressColor = Color(0xFFF5C34B);
  // static Color textPriceColor = Color(0xFF3DA11A);
  static Color textOnAuthColor = Color(0xFF21272A);
  static Color greyIndicatorColor = Color(0xFFD9D9D9);
  // static Color backgroundColor = Color(0xFFF9F9F9);
  static Color borderLightColor = Color(0xFFEAEAEA);
  static Color borderRegularColor = Color(0xFF9D9B9B);
  static Color borderSearchColor = Color(0xFF949494);
  static Color greenColor = Color(0xFF1ABC62);
  static Color redColor = Color(0xFFED1C24);
  static Color blueColor = Color(0xFF093CA9);
  static Color blueGreenColor = Color(0xFF5397AA);
  static Color pesananBaruColor = greenColor;
  static Color pesananDiterimaColor = Color(0xff2B64F5);
  static Color pesananDikirimColor = Color(0xffF58B2B);
  static Color barangDiterimaColor = Color(0xffF40BA7);
  static Color prosesPembayaranColor = Color(0xffF40BA7);
  static Color telahDibayarColor = greenColor;
  static Color pesananDitolakColor = primaryColor;

  static Color statusColor(String status) {
    if (status == 'PESANAN_BARU') return Colors.blue;
    if (status == 'PESANAN_DITERIMA') return Colors.indigo;
    if (status == 'PESANAN_DIKIRIM') return Colors.orange;
    if (status == 'PESANAN_TELAH_DITERIMA') return Colors.purple;
    if (status == 'BARANG_DITERIMA') return Colors.pink;
    if (status == 'PROSES_PEMBAYARAN') return Colors.amber;
    if (status == 'TELAH_DIBAYAR') return Colors.teal;
    if (status == 'PESANAN_SELESAI') return Colors.green;
    if (status == 'DIBATALKAN') return Colors.red;
    if (status == 'PESANAN_DITOLAK') return Colors.red;
    return Colors.black;
  }

  static TextStyle primaryTextStyle = TextStyle(
    fontFamily: 'SourceSansPro',
    color: textColor,
  );
  static TextStyle secondaryTextStyle = TextStyle(
    fontFamily: 'SourceSansPro',
    color: textColor2,
  );
  static TextStyle komisiTextStyle = TextStyle(
    fontFamily: 'SourceSansPro',
    color: textKomisiColor,
  );
  static TextStyle priceTextStyle = TextStyle(
    fontFamily: 'SourceSansPro',
    color: textPriceColor,
  );
  static TextStyle s12BoldBlack = TextStyle(
    fontFamily: 'SourceSansPro',
    color: textColor,
    fontWeight: FontWeight.bold,
  );

  static TextStyle primaryTextStyle2 = TextStyle(
    fontFamily: 'SourceSansPro',
    color: textColor,
  );
  static TextStyle secondaryTextStyle2 = TextStyle(
    fontFamily: 'SourceSansPro',
    color: textColor2,
  );
  static TextStyle komisiTextStyle2 = TextStyle(
    fontFamily: 'SourceSansPro',
    color: textKomisiColor,
  );
  static TextStyle priceTextStyle2 = TextStyle(
    fontFamily: 'SourceSansPro',
    color: textPriceColor,
  );
  static TextStyle s12BoldBlack2 = TextStyle(
    fontFamily: 'SourceSansPro',
    color: textColor,
    fontWeight: FontWeight.bold,
  );
  static TextStyle iBlack = TextStyle(fontFamily: 'SourceSansPro');

  static TextStyle iPrimaryMedium8 = TextStyle(
    fontFamily: 'SourceSansPro',
    color: primaryColor,
    fontSize: 8,
    fontWeight: medium,
  );
  static TextStyle iPrimaryMedium12 = TextStyle(
    fontFamily: 'SourceSansPro',
    color: primaryColor,
    fontSize: 12,
    fontWeight: medium,
  );

  static TextStyle iBlackMedium8 = TextStyle(
    fontFamily: 'SourceSansPro',
    color: textColorBlack,
    fontSize: 8,
    fontWeight: medium,
  );
  static TextStyle iBlackMedium10 = TextStyle(
    fontFamily: 'SourceSansPro',
    color: textColorBlack,
    fontSize: 8,
    fontWeight: medium,
  );
  static TextStyle iBlackMedium12 = TextStyle(
    fontFamily: 'SourceSansPro',
    color: textColorBlack,
    fontSize: 12,
    fontWeight: medium,
  );
  static TextStyle iBlackMedium13 = TextStyle(
    fontFamily: 'SourceSansPro',
    color: textColorBlack,
    fontSize: 13,
    fontWeight: medium,
  );
  static TextStyle iBlackMedium = TextStyle(
    fontFamily: 'SourceSansPro',
    color: textColorBlack,
    fontWeight: medium,
  );
  static TextStyle iBlackMedium18 = TextStyle(
    fontFamily: 'SourceSansPro',
    color: textColorBlack,
    fontSize: 18,
    fontWeight: medium,
  );
  static TextStyle iBlackMedium16StrkWhite = TextStyle(
    fontFamily: 'SourceSansPro',
    color: textColorBlack,
    fontSize: 16,
    shadows: [
      Shadow(
        // bottomLeft
        offset: Offset(-1.5, -1.5),
        color: Colors.white,
      ),
      Shadow(
        // bottomRight
        offset: Offset(1.5, -1.5),
        color: Colors.white,
      ),
      Shadow(
        // topRight
        offset: Offset(1.5, 1.5),
        color: Colors.white,
      ),
      Shadow(
        // topLeft
        offset: Offset(-1.5, 1.5),
        color: Colors.white,
      ),
    ],
    fontWeight: medium,
  );
  static TextStyle iBlackMedium16 = TextStyle(
    fontFamily: 'SourceSansPro',
    color: textColorBlack,
    fontSize: 16,
    fontWeight: medium,
  );
  static TextStyle iBlackMedium20 = TextStyle(
    fontFamily: 'SourceSansPro',
    color: textColorBlack,
    fontSize: 20,
    fontWeight: medium,
  );
  static TextStyle iBlackMedium40StrkWhite = TextStyle(
    fontFamily: 'SourceSansPro',
    color: textColorBlack,
    fontSize: 40,
    shadows: [
      Shadow(
        // bottomLeft
        offset: Offset(-1.5, -1.5),
        color: Colors.white,
      ),
      Shadow(
        // bottomRight
        offset: Offset(1.5, -1.5),
        color: Colors.white,
      ),
      Shadow(
        // topRight
        offset: Offset(1.5, 1.5),
        color: Colors.white,
      ),
      Shadow(
        // topLeft
        offset: Offset(-1.5, 1.5),
        color: Colors.white,
      ),
    ],
    fontWeight: medium,
  );

  static TextStyle primaryBold15 = TextStyle(
    fontFamily: 'SourceSansPro',
    color: primaryColor,
    fontSize: 15,
    fontWeight: bold,
  );
  static TextStyle primaryMedium14 = TextStyle(
    fontFamily: 'SF-Pro-Display',
    color: primaryColor,
    fontSize: 14,
    fontWeight: medium,
  );
  static TextStyle primaryBold16 = TextStyle(
    fontFamily: 'SourceSansPro',
    color: primaryColor,
    fontSize: 16,
    fontWeight: bold,
  );
  static TextStyle primaryBold20 = TextStyle(
    fontFamily: 'SourceSansPro',
    color: primaryColor,
    fontSize: 20,
    fontWeight: bold,
  );
  static TextStyle productDark14 = TextStyle(
    fontFamily: 'SourceSansPro',
    color: textColorBlack,
    fontSize: 14,
    fontWeight: medium,
  );
  static TextStyle quartenary = TextStyle(
    fontFamily: 'SourceSansPro',
    color: quarteryColor,
    fontWeight: regular,
  );
  static TextStyle whiteExtraBold18 = TextStyle(
    fontFamily: 'SourceSansPro',
    color: Colors.white,
    fontSize: 18,
    fontWeight: bold,
  );

  static TextStyle purple16 = TextStyle(
    fontFamily: 'SourceSansPro',
    color: Colors.purple,
    fontSize: 16,
    fontWeight: medium,
  );
  static TextStyle dark14 = TextStyle(
    fontFamily: 'SourceSansPro',
    color: textColorBlack,
    fontSize: 14,
    fontWeight: medium,
  );
  static TextStyle dark15 = TextStyle(
    fontFamily: 'SourceSansPro',
    color: textColorBlack,
    fontSize: 15,
    fontWeight: medium,
  );
  static TextStyle dark16 = TextStyle(
    fontFamily: 'SourceSansPro',
    color: textColorBlack,
    fontSize: 15,
    fontWeight: medium,
  );
  static TextStyle darkBold12 = TextStyle(
    fontFamily: 'SourceSansPro',
    color: textColorBlack,
    fontSize: 12,
    fontWeight: bold,
  );
  static TextStyle darkBold14 = TextStyle(
    fontFamily: 'SourceSansPro',
    color: textColorBlack,
    fontSize: 14,
    fontWeight: bold,
  );
  static TextStyle darkBold16 = TextStyle(
    fontFamily: 'SourceSansPro',
    color: textColorBlack,
    fontSize: 16,
    fontWeight: bold,
  );
  static TextStyle darkBold18 = TextStyle(
    fontFamily: 'SourceSansPro',
    color: textColorBlack,
    fontSize: 18,
    fontWeight: bold,
  );
  static TextStyle darkBold20 = TextStyle(
    fontFamily: 'SourceSansPro',
    color: textColorBlack,
    fontSize: 20,
    fontWeight: bold,
  );
  static TextStyle darkBold22 = TextStyle(
    fontFamily: 'SourceSansPro',
    color: textColorBlack,
    fontSize: 22,
    fontWeight: bold,
  );
  static TextStyle darkMedium14 = TextStyle(
    fontFamily: 'SourceSansPro',
    color: textColorBlack,
    fontSize: 14,
    fontWeight: bold,
  );
  static TextStyle darkMedium16 = TextStyle(
    fontFamily: 'SourceSansPro',
    color: textColorBlack,
    fontSize: 16,
    fontWeight: bold,
  );
  static TextStyle darkUnderline14 = TextStyle(
    fontFamily: 'SourceSansPro',
    color: textColorBlack,
    fontSize: 14,
    fontWeight: bold,
  );

  static TextStyle blackBold10 = TextStyle(
    fontFamily: 'SourceSansPro',
    color: textColorBlack,
    fontSize: 10,
    fontWeight: bold,
  );
  static TextStyle blackBold13 = TextStyle(
    fontFamily: 'SourceSansPro',
    color: Colors.black,
    fontSize: 13,
    fontWeight: bold,
  );
  static TextStyle blackBold = TextStyle(
    fontFamily: 'SourceSansPro',
    color: textColorBlack,
    fontWeight: bold,
  );
  static TextStyle blackBold15 = TextStyle(
    fontFamily: 'SourceSansPro',
    color: textColorBlack,
    fontSize: 15,
    fontWeight: bold,
  );
  static TextStyle blackBold16 = TextStyle(
    fontFamily: 'SourceSansPro',
    color: textColorBlack,
    fontSize: 16,
    fontWeight: bold,
  );
  static TextStyle blackBold20 = TextStyle(
    fontFamily: 'SourceSansPro',
    color: textColorBlack,
    fontSize: 20,
    fontWeight: bold,
  );

  static TextStyle grayRegular = TextStyle(
    fontFamily: 'SourceSansPro',
    color: lightGrayColor,
  );
  static TextStyle grayRegular8 = TextStyle(
    fontFamily: 'SourceSansPro',
    color: lightGrayColor,
    fontSize: 8,
  );
  static TextStyle grayRegular12 = TextStyle(
    fontFamily: 'SourceSansPro',
    color: lightGrayColor,
    fontSize: 12,
  );
  static TextStyle greyRegular12 = TextStyle(
    fontFamily: 'SourceSansPro',
    color: lightGrayColor,
    fontSize: 12,
  );
  static TextStyle grayRegular13 = TextStyle(
    fontFamily: 'SourceSansPro',
    color: lightGrayColor,
    fontSize: 13,
  );
  static TextStyle greyThrough12 = TextStyle(
    fontFamily: 'SourceSansPro',
    color: lightGrayColor,
    fontSize: 12,
  );
  static TextStyle greyThrough14 = TextStyle(
    fontFamily: 'SourceSansPro',
    color: lightGrayColor,
    fontSize: 14,
    decoration: TextDecoration.lineThrough,
  );
  static TextStyle greyThrough16 = TextStyle(
    fontFamily: 'SourceSansPro',
    color: lightGrayColor,
    fontSize: 16,
  );
  static TextStyle grayMedium10 = TextStyle(
    fontFamily: 'SourceSansPro',
    color: lightGrayColor,
    fontSize: 10,
    fontWeight: medium,
  );
  static TextStyle grayMedium13 = TextStyle(
    fontFamily: 'SourceSansPro',
    color: lightGrayColor,
    fontSize: 13,
    fontWeight: medium,
  );
  static TextStyle grayMedium = TextStyle(
    fontFamily: 'SourceSansPro',
    color: lightGrayColor,
    fontWeight: medium,
  );
  static TextStyle grayMedium15 = TextStyle(
    fontFamily: 'SourceSansPro',
    color: lightGrayColor,
    fontSize: 15,
    fontWeight: medium,
  );
  static TextStyle grayBold12 = TextStyle(
    fontFamily: 'SourceSansPro',
    color: lightGrayColor,
    fontSize: 12,
    fontWeight: bold,
  );
  static TextStyle grayBold15 = TextStyle(
    fontFamily: 'SourceSansPro',
    color: lightGrayColor,
    fontSize: 15,
    fontWeight: bold,
  );
  static TextStyle grayBold16 = TextStyle(
    fontFamily: 'SourceSansPro',
    color: lightGrayColor,
    fontSize: 16,
    fontWeight: bold,
  );
  static TextStyle whiteRegular12 = TextStyle(
    fontFamily: 'SourceSansPro',
    color: Colors.white,
    fontSize: 12,
  );
  static TextStyle whiteBold = TextStyle(
    fontFamily: 'SourceSansPro',
    color: Colors.white,
    fontWeight: bold,
  );
  static TextStyle whiteBold15 = TextStyle(
    fontFamily: 'SourceSansPro',
    color: Colors.white,
    fontSize: 15,
    fontWeight: bold,
  );
  static TextStyle whiteBold16 = TextStyle(
    fontFamily: 'SourceSansPro',
    color: Colors.white,
    fontSize: 16,
    fontWeight: bold,
  );
  static TextStyle whiteExtraBold = TextStyle(
    fontFamily: 'SourceSansPro',
    color: Colors.white,
    fontWeight: extraBold,
  );

  static TextStyle greenBold12 = TextStyle(
    fontFamily: 'SourceSansPro',
    color: greenColor,
    fontSize: 12,
    fontWeight: bold,
  );
  static TextStyle blueBold12 = TextStyle(
    fontFamily: 'SourceSansPro',
    color: blueColor,
    fontSize: 12,
    fontWeight: bold,
  );
  static TextStyle blueMedium14 = TextStyle(
    fontFamily: 'SourceSansPro',
    color: blueColor,
    fontSize: 14,
    fontWeight: medium,
  );
  static TextStyle blue12 = TextStyle(
    fontFamily: 'SourceSansPro',
    color: blueColor,
    fontSize: 12,
    fontWeight: regular,
  );
  static TextStyle redBold12 = TextStyle(
    fontFamily: 'SourceSansPro',
    color: redColor,
    fontSize: 12,
    fontWeight: bold,
  );
  static TextStyle brandGrey13 = TextStyle(
    fontFamily: 'SourceSansPro',
    color: grayColor,
    fontSize: 13,
    fontWeight: regular,
  );

  static FontWeight light = FontWeight.w300;
  static FontWeight regular = FontWeight.w400;
  static FontWeight medium = FontWeight.w500;
  static FontWeight semibold = FontWeight.w600;
  static FontWeight bold = FontWeight.w700;
  static FontWeight extraBold = FontWeight.w800;
  static FontWeight black = FontWeight.w900;

  static ThemeData mainThemeData = ThemeData(
    useMaterial3: false,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    indicatorColor: Colors.black,
    dividerColor: Colors.transparent,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        backgroundColor: primaryColor,
      ),
    ),
    // colorSchemeSeed: Colors.black,
    appBarTheme: AppBarTheme(
      backgroundColor: primaryColor,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.white, // <-- SEE HERE
        // systemNavigationBarColor: primaryColor,
        // systemNavigationBarIconBrightness: Brightness.dark,
        statusBarIconBrightness:
            Brightness.light, //<-- For Android SEE HERE (dark icons)
        statusBarBrightness:
            Brightness.light, //<-- For iOS SEE HERE (dark icons)
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: ButtonStyle(
        side: WidgetStateProperty.all(BorderSide(color: primaryColor)),
        foregroundColor: WidgetStateProperty.all(primaryColor),
      ),
    ),
    scaffoldBackgroundColor: Constant.backgroundColor,
    primaryColor: primaryColor,
    focusColor: Colors.black,
    fontFamily: 'SourceSansPro',
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      primary: primaryColor, //<-- SEE HERE
    ).copyWith(
      primary: Constant.primaryColor,
      surface: Constant.backgroundColor,
    ),
  );

  // static const Color color4 = Color(0xffc2d5ee);

  /// DEFAULT SIZE
  ///
  /// This constant using for default size for text style, so you can this add or change as you want
  /// Be carefully to change this constant because it might affect with size in entire project
  ///

  /// Font Size
  ///
  /// How to use: Constant.fontSizeSmall;
  ///
  static const double fontSizeSmall = 11;
  static const double fontSizeRegular = 13;
  static const double fontSizeBig = 15;
  static const double fontSizeBigger = 20;

  /// Margin Padding
  ///
  /// How to use: Constant.standardPaddingSize;
  ///
  static const double standartPaddingSize = 12;
  static const double standartMarginSize = 12;

  static const double paddingSize = 12;
  static const double marginSize = 12;

  /// shareprefrence key

  static const String kSetPrefToken = "token";
  static const String kSetPrefId = "id";
  static const String kSetPrefFcmToken = "fcmToken";
  static const String kSetPrefFirstName = "firstName";
  static const String kSetPrefLastName = "lastName";
  static const String kSetPrefCompany = "company";
  static const String kSetPrefRoles = "roles";
  static const String kSetPrefIsAdmin = "is_admin";
  static const String kSetPrefSubditId = "subdit_id";
  static const String kSetPrefEmail = "email";
  static const String kSetPrefPhone = "phone";
  static const String kSetPrefVerified = "verified";
  static const String kSetPrefRole = "role";
  static const String kSetPrefCanAssess = "can_assess";
  static const String kIsBreakPresence = "is_break_presence";

  static const String kSetIdTemp = "temp_order_id";
  static const String kSetParentId = "parent_id";

  static const String kCheckIn = "check_in";
  static const String kCheckOut = "check_out";
  static const String kCheckInBreak = "check_in_break";
  static const String kCheckOutBreak = "check_out_break";
  static const String kBreakStart = "break_start";
  static const String kBreakEnd = "break_end";

  static const String kShowPayrollSlip = "showPayrollSlip";
  static const String kUseFaceDetection = "faceDetection";
  static const String kLockArea = "lockArea";
  static const String kLockOutOfArea = "lockOutOfArea";
  static const String kRequestReviewCount = "requestReviewCount";
  static const String kLoanMargin = "loanMargin";
  static const String kPayRollDate = "payrollDate";
  static const String kFromLogin = "fromLogin";
  static const String kWorkingDays = "workingDays";
  static const String kAllowWFH = "allowWFH";
  static const String kWithoutPhoto = "withoutPhoto";

  final BorderRadius cardRadius = BorderRadius.circular(12);
  final BorderRadius sharpCardRadius = BorderRadius.circular(4);
  static const double cardElevation = 0;

  static const InputDecoration outlinedDecoration = InputDecoration(
    contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 8),
    border: OutlineInputBorder(),
  );

  Color enableDisableColor(bool value) {
    if (value) return primaryColor;
    return textColor2;
  }

  String pathVenueType(String facility) {
    if (facility.toLowerCase().contains("basket")) {
      return "icon-basketball";
    }
    if (facility.toLowerCase().contains("badminton")) {
      return "icon-badminton";
    }
    if (facility.toLowerCase().contains("futsal")) {
      return "icon-futsal";
    }
    if (facility.toLowerCase().contains("sepak")) {
      return "icon-football";
    }
    if (facility.toLowerCase().contains("voli")) {
      return "icon-voli";
    }
    return "icon-basketball";
  }

  String textButton(String status, {bool isRated = false}) {
    if (status == "Selesai" && isRated) {
      return "Pembayaran";
    }
    switch (status) {
      case "Menunggu Pembayaran":
        return "Pembayaran";
      case "Selesai":
        return "Beri Rating dan Review";
      case "Lunas":
        return "Pembayaran";
      case "Kadaluarsa":
        return "Pembayaran";
      case "Menunggu Validasi Pembayaran":
        return "Pembayaran";
      default:
        return "Pembayaran";
    }
  }

  TextStyle statusText(String status) {
    switch (status) {
      case "1":
        return redBold12;
      case "0":
        return greenBold12;
      // case "Kadaluarsa":
      //   return kadaluarsaC;
      // case "Menunggu Validasi Pembayaran":
      //   return menungguPembayaranC;
      default:
        return grayBold12;
    }
  }

  // Color statusTextColor(String status) {
  //   switch (status) {
  //     case "Menunggu Pembayaran":
  //       return menungguPembayaranTextC;
  //     case "Selesai":
  //       return selesaiTextC;
  //     case "Lunas":
  //       return lunasTextC;
  //     case "Kadaluarsa":
  //       return kadaluarsaTextC;
  //     case "Menunggu Validasi Pembayaran":
  //       return menungguPembayaranTextC;
  //     default:
  //       return tidakValidTextC;
  //   }
  // }

  // final MaterialColor primarySwatch = MaterialColor(primaryColor.value, const {
  //   50: Color(0xFFE1F0E1),
  //   100: Color(0xFFB3DAB4),
  //   200: Color(0xFF80C282),
  //   300: Color(0xFF4DA94F),
  //   400: Color(0xFF27962A),
  //   500: primaryColor,
  //   600: Color(0xFF017C03),
  //   700: Color(0xFF017103),
  //   800: Color(0xFF016702),
  //   900: Color(0xFF005401),
  // });

  static Border border = Border.all(color: const Color(0xffdcdde1), width: .5);

  static BoxDecoration containerDecoration = BoxDecoration(
    border: Border.all(color: const Color(0xffdcdde1), width: .5),
    borderRadius: BorderRadius.circular(12),
  );

  // :ignore
  // String? Function(String?) requiredValidator = (value) {
  //   value ??= '';
  //   if (value.isEmpty) {
  //     return "Kolom ini harus diisi";
  //   }
  //   return null;
  // };
  // String? Function(String?) emailValidator = (value) {
  //   value ??= '';
  //   if (value.isEmpty) {
  //     return "Kolom ini harus diisi";
  //   }
  //   if (!isEmail(value)) {
  //     return "Email tidak valid";
  //   }
  //   return null;
  // };

  // String? Function(String?) numberValidator = (value) {
  //   value ??= '';
  //   if (value.isEmpty) {
  //     return "Kolom ini harus diisi";
  //   }
  //   if (!isNumeric(value)) {
  //     return "Kolom harus berupa angka";
  //   }
  //   return null;
  // };

  //SizedBox
  static const SizedBox xSizedBox2 = SizedBox.square(dimension: 2);
  static const SizedBox xSizedBox4 = SizedBox.square(dimension: 4);
  static const SizedBox xSizedBox8 = SizedBox.square(dimension: 8);
  static const SizedBox xSizedBox10 = SizedBox.square(dimension: 10);
  static const SizedBox xSizedBox12 = SizedBox.square(dimension: 12);
  static const SizedBox xSizedBox18 = SizedBox.square(dimension: 18);
  static const SizedBox xSizedBox16 = SizedBox.square(dimension: 16);
  static const SizedBox xSizedBox24 = SizedBox.square(dimension: 24);
  static const SizedBox xSizedBox32 = SizedBox.square(dimension: 32);

  //horizontal Edgeinset
  static const EdgeInsets xHEdgeInsets4 = EdgeInsets.symmetric(horizontal: 4);
  static const EdgeInsets xHEdgeInsets8 = EdgeInsets.symmetric(horizontal: 8);
  static const EdgeInsets xHEdgeInsets12 = EdgeInsets.symmetric(horizontal: 12);
  static const EdgeInsets xHEdgeInsets18 = EdgeInsets.symmetric(horizontal: 18);
  static const EdgeInsets xHEdgeInsets24 = EdgeInsets.symmetric(horizontal: 24);
  static const EdgeInsets xHEdgeInsets32 = EdgeInsets.symmetric(horizontal: 32);

  //vertical Edgeinset
  static const EdgeInsets xVEdgeInsets4 = EdgeInsets.symmetric(vertical: 4);
  static const EdgeInsets xVEdgeInsets8 = EdgeInsets.symmetric(vertical: 8);
  static const EdgeInsets xVEdgeInsets12 = EdgeInsets.symmetric(vertical: 12);
  static const EdgeInsets xVEdgeInsets18 = EdgeInsets.symmetric(vertical: 18);
  static const EdgeInsets xVEdgeInsets24 = EdgeInsets.symmetric(vertical: 24);
  static const EdgeInsets xVEdgeInsets32 = EdgeInsets.symmetric(vertical: 32);

  static const double toolbarHeight = 64;

  //date format
  final DateFormat xDateFormat1 = DateFormat('yyyy-MM-dd');
  final DateFormat xDateTimeFormat1 = DateFormat('d MMM yyyy, HH:mm');
  final DateFormat xDateTimeFormat2 = DateFormat('E, d MMM yyyy');

  //image
  static const String dummyImage1 =
      'https://images.hindustantimes.com/rf/image_size_630x354/HT/p2/2020/11/14/Pictures/_ded48fd4-25fd-11eb-8924-93a7f7a2e27c.jpg';
  static const String dummyImage2 =
      'https://cdn-asset.jawapos.com/wp-content/uploads/2021/11/anak-main-560x390.jpg';
  static const String dummyImage3 =
      'https://res.cloudinary.com/ruparupa-com/image/upload/w_360,h_360,f_auto,q_auto/f_auto,q_auto:eco/v1589259712/Products/10408757_1.jpg';
  static const String dummyImage4 =
      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR6pBqLk0DIVFM0CbRI3nD6vz1Y4vwqaakhyq_VXCHXz-aGRPSI-blnsGytOjjSsJloLxU&usqp=CAU';
  static const String dummyImage5 =
      'https://www.unicef.org/indonesia/sites/unicef.org.indonesia/files/styles/two_column/public/IDN-Children-UN0296085.JPG';
  // static const String dummyImage6 = '';
  static const String dummyImage6 =
      'https://www.news-medical.net/image.axd?picture=2016%2F3%2FChildren_playing_sunset_-_Zurijeta_8c5bdac77e44431bb1bfec67b9c87208-620x480.jpg';

  static const String loremIpsum =
      'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nunc eu cursus ex. Sed vel pulvinar leo, porttitor viverra nulla. Donec vel quam lacinia, gravida mauris vel, sodales velit. ';

  static const String sampleYoutube =
      'https://www.youtube.com/watch?v=1MudGuYglG0&ab_channel=PutraAdin';
  static const String sampleYoutubeId = '1MudGuYglG0';

  static const String photoProfile1 =
      "https://ragasport.com/ragasport/media/avatars/blank.png";
  // "https://media.istockphoto.com/vectors/default-profile-picture-avatar-photo-placeholder-vector-illustration-vector-id1223671392?k=20&m=1223671392&s=612x612&w=0&h=lGpj2vWAI3WUT1JeJWm1PRoHT3V15_1pdcTn2szdwQ0=";

  static const String userGuideUrl = "user-guide-mobile";
  static const String syaratKetentuanUrl = "webview?slug=syarat-dan-ketentuan";
  static const String kebijakanPrivasiUrl = "webview?slug=kebijakan-privasi";
  static const String faqUrl = "webview?slug=faq";
  static const String kontakUrl = "webview?slug=kontak";

  
}
