import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

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
  
  // static const String BASE_API_FULL = "https://${DOMAIN}/api"; // Production
  static const String BASE_API_FULL = "http://${DOMAIN_LOCAL}/api"; // Local Dev
  static const String BASE_API_FULL2 = "https://${DOMAIN2}/api";
  static const String APP_NAME = "M-Speed";
  static const int maxPaginationPerPage = 1000;
  static const String epProducts = "/products";
  static const String epParentOrders = "/parent-orders";
  static const String epNegos = "/negos";
  static const String epChats = "/chats";

  /// COlORS
  ///
  /// This constant using for default color theme base of design mockup, so
  /// you can add int as hexcode of color and you can use this constant like this .
  ///
  /// Constant.firstColor;
  ///
  static Color primaryColor = const Color(0xFF1565C0); // M-SPEED Primary Blue
  static Color secondaryColor = const Color(0xFF1E88E5); // M-SPEED Secondary Blue
  static Color tertiaryColor = const Color(0xFFF57C00); // M-SPEED Accent Orange
  static Color quarteryColor = const Color(0xFFC5E2FF);
  static Color tableBlueColor = const Color(0xFFE9F0FF);
  static Color textHyperlinkColor = const Color(0xFF0095FF);
  static Color splashText = const Color(0xFF569CB0);
  static Color darkGrayColor = Colors.grey.shade800;
  static Color grayColor = Colors.grey.shade600;
  static Color lightGrayColor = Colors.grey.shade400;
  static Color textHintColor = const Color(0xFF999999);
  static Color textHintColor2 = const Color(0xFF949494);
  static Color darkGrayButtonColor = Colors.black;
  static Color bgFieldColor = const Color(0xff8CC6FF).withValues(alpha: 0.3);
  static Color textColor = const Color(0xFF212121); // Primary Text
  static Color textColor2 = const Color(0xFF757575); // Secondary Text
  static Color textKomisiColor = const Color(0xFFFFCB47);
  static Color textPriceColor = const Color(0xFFE53935); // Danger / Price
  static Color backgroundColor = const Color(0xFFF8F9FB); // Background
  static Color textColorBlack = const Color(0xFF212121);
  static Color textColorWhite = Colors.white;
  static Color textColorBlue = const Color(0xFF1565C0);
  static Color timerColor = const Color(0xFFE7B641);
  static Color progressColor = const Color(0xFFFBC02D);
  static Color textOnAuthColor = const Color(0xFF21272A);
  static Color greyIndicatorColor = const Color(0xFFD9D9D9);
  static Color borderLightColor = const Color(0xFFE8EAF0); // Border Light
  static Color borderRegularColor = const Color(0xFF9D9B9B);
  static Color borderSearchColor = const Color(0xFF949494);
  static Color greenColor = const Color(0xFF43A047); // Success
  static Color redColor = const Color(0xFFE53935); // Danger
  static Color blueColor = const Color(0xFF1565C0);
  static Color blueGreenColor = const Color(0xFF5397AA);
  static Color pesananBaruColor = greenColor;
  static Color pesananDiterimaColor = const Color(0xff2B64F5);

  // --- NEW DESIGN SYSTEM TOKENS (MARKETPLACE MODERN UX) ---
  // A. Color Palette (Solid Colors Only)
  static const Color dsPrimary = Color(0xFF1565C0);
  static const Color dsSecondary = Color(0xFFE53935);
  static const Color dsAccent = Color(0xFFF9A825);
  static const Color dsBackground = Color(0xFFF8F9FB);
  static const Color dsSurface = Color(0xFFFFFFFF);
  static const Color dsTextPrimary = Color(0xFF111827);
  static const Color dsTextSecondary = Color(0xFF6B7280);
  static const Color dsBorder = Color(0xFFE5E7EB);
  static const Color dsDivider = Color(0xFFF3F4F6);

  // B. Spacing System
  static const double space2 = 2.0;
  static const double space4 = 4.0;
  static const double space8 = 8.0;
  static const double space12 = 12.0;
  static const double space16 = 16.0;
  static const double space20 = 20.0;
  static const double space24 = 24.0;
  static const double space32 = 32.0;
  static const double space40 = 40.0;

  // C. Radius System
  static const double radiusXs = 4.0;
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 24.0;

  // D. Shadow System
  static BoxShadow shadowSmall = BoxShadow(
    color: Colors.black.withValues(alpha: 0.04),
    blurRadius: 8,
    spreadRadius: 0,
    offset: const Offset(0, 4),
  );
  static BoxShadow shadowMedium = BoxShadow(
    color: Colors.black.withValues(alpha: 0.05),
    blurRadius: 18,
    spreadRadius: 0,
    offset: const Offset(0, 4),
  );
  static BoxShadow shadowLarge = BoxShadow(
    color: Colors.black.withValues(alpha: 0.08),
    blurRadius: 24,
    spreadRadius: 0,
    offset: const Offset(0, 8),
  );
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
    fontFamily: GoogleFonts.poppins().fontFamily,
    color: textColor,
  );
  static TextStyle secondaryTextStyle = TextStyle(
    fontFamily: GoogleFonts.poppins().fontFamily,
    color: textColor2,
  );
  static TextStyle komisiTextStyle = TextStyle(
    fontFamily: GoogleFonts.poppins().fontFamily,
    color: textKomisiColor,
  );
  static TextStyle priceTextStyle = TextStyle(
    fontFamily: GoogleFonts.poppins().fontFamily,
    color: textPriceColor,
  );
  static TextStyle s12BoldBlack = TextStyle(
    fontFamily: GoogleFonts.poppins().fontFamily,
    color: textColor,
    fontWeight: FontWeight.bold,
  );

  static TextStyle primaryTextStyle2 = TextStyle(
    fontFamily: GoogleFonts.poppins().fontFamily,
    color: textColor,
  );
  static TextStyle secondaryTextStyle2 = TextStyle(
    fontFamily: GoogleFonts.poppins().fontFamily,
    color: textColor2,
  );
  static TextStyle komisiTextStyle2 = TextStyle(
    fontFamily: GoogleFonts.poppins().fontFamily,
    color: textKomisiColor,
  );
  static TextStyle priceTextStyle2 = TextStyle(
    fontFamily: GoogleFonts.poppins().fontFamily,
    color: textPriceColor,
  );
  static TextStyle s12BoldBlack2 = TextStyle(
    fontFamily: GoogleFonts.poppins().fontFamily,
    color: textColor,
    fontWeight: FontWeight.bold,
  );
  static TextStyle iBlack = TextStyle(fontFamily: GoogleFonts.poppins().fontFamily);

  static TextStyle iPrimaryMedium8 = TextStyle(
    fontFamily: GoogleFonts.poppins().fontFamily,
    color: primaryColor,
    fontSize: 8,
    fontWeight: medium,
  );
  static TextStyle iPrimaryMedium12 = TextStyle(
    fontFamily: GoogleFonts.poppins().fontFamily,
    color: primaryColor,
    fontSize: 12,
    fontWeight: medium,
  );

  static TextStyle iBlackMedium8 = TextStyle(
    fontFamily: GoogleFonts.poppins().fontFamily,
    color: textColorBlack,
    fontSize: 8,
    fontWeight: medium,
  );
  static TextStyle iBlackMedium10 = TextStyle(
    fontFamily: GoogleFonts.poppins().fontFamily,
    color: textColorBlack,
    fontSize: 8,
    fontWeight: medium,
  );
  static TextStyle iBlackMedium12 = TextStyle(
    fontFamily: GoogleFonts.poppins().fontFamily,
    color: textColorBlack,
    fontSize: 12,
    fontWeight: medium,
  );
  static TextStyle iBlackMedium13 = TextStyle(
    fontFamily: GoogleFonts.poppins().fontFamily,
    color: textColorBlack,
    fontSize: 13,
    fontWeight: medium,
  );
  static TextStyle iBlackMedium = TextStyle(
    fontFamily: GoogleFonts.poppins().fontFamily,
    color: textColorBlack,
    fontWeight: medium,
  );
  static TextStyle iBlackMedium18 = TextStyle(
    fontFamily: GoogleFonts.poppins().fontFamily,
    color: textColorBlack,
    fontSize: 18,
    fontWeight: medium,
  );
  static TextStyle iBlackMedium16StrkWhite = TextStyle(
    fontFamily: GoogleFonts.poppins().fontFamily,
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
    fontFamily: GoogleFonts.poppins().fontFamily,
    color: textColorBlack,
    fontSize: 16,
    fontWeight: medium,
  );
  static TextStyle iBlackMedium20 = TextStyle(
    fontFamily: GoogleFonts.poppins().fontFamily,
    color: textColorBlack,
    fontSize: 20,
    fontWeight: medium,
  );
  static TextStyle iBlackMedium40StrkWhite = TextStyle(
    fontFamily: GoogleFonts.poppins().fontFamily,
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
    fontFamily: GoogleFonts.poppins().fontFamily,
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
    fontFamily: GoogleFonts.poppins().fontFamily,
    color: primaryColor,
    fontSize: 16,
    fontWeight: bold,
  );
  static TextStyle primaryBold20 = TextStyle(
    fontFamily: GoogleFonts.poppins().fontFamily,
    color: primaryColor,
    fontSize: 20,
    fontWeight: bold,
  );
  static TextStyle productDark14 = TextStyle(
    fontFamily: GoogleFonts.poppins().fontFamily,
    color: textColorBlack,
    fontSize: 14,
    fontWeight: medium,
  );
  static TextStyle quartenary = TextStyle(
    fontFamily: GoogleFonts.poppins().fontFamily,
    color: quarteryColor,
    fontWeight: regular,
  );
  static TextStyle whiteExtraBold18 = TextStyle(
    fontFamily: GoogleFonts.poppins().fontFamily,
    color: Colors.white,
    fontSize: 18,
    fontWeight: bold,
  );

  static TextStyle purple16 = TextStyle(
    fontFamily: GoogleFonts.poppins().fontFamily,
    color: Colors.purple,
    fontSize: 16,
    fontWeight: medium,
  );
  static TextStyle dark14 = TextStyle(
    fontFamily: GoogleFonts.poppins().fontFamily,
    color: textColorBlack,
    fontSize: 14,
    fontWeight: medium,
  );
  static TextStyle dark15 = TextStyle(
    fontFamily: GoogleFonts.poppins().fontFamily,
    color: textColorBlack,
    fontSize: 15,
    fontWeight: medium,
  );
  static TextStyle dark16 = TextStyle(
    fontFamily: GoogleFonts.poppins().fontFamily,
    color: textColorBlack,
    fontSize: 15,
    fontWeight: medium,
  );
  static TextStyle darkBold12 = TextStyle(
    fontFamily: GoogleFonts.poppins().fontFamily,
    color: textColorBlack,
    fontSize: 12,
    fontWeight: bold,
  );
  static TextStyle darkBold14 = TextStyle(
    fontFamily: GoogleFonts.poppins().fontFamily,
    color: textColorBlack,
    fontSize: 14,
    fontWeight: bold,
  );
  static TextStyle darkBold16 = TextStyle(
    fontFamily: GoogleFonts.poppins().fontFamily,
    color: textColorBlack,
    fontSize: 16,
    fontWeight: bold,
  );
  static TextStyle darkBold18 = TextStyle(
    fontFamily: GoogleFonts.poppins().fontFamily,
    color: textColorBlack,
    fontSize: 18,
    fontWeight: bold,
  );
  static TextStyle darkBold20 = TextStyle(
    fontFamily: GoogleFonts.poppins().fontFamily,
    color: textColorBlack,
    fontSize: 20,
    fontWeight: bold,
  );
  static TextStyle darkBold22 = TextStyle(
    fontFamily: GoogleFonts.poppins().fontFamily,
    color: textColorBlack,
    fontSize: 22,
    fontWeight: bold,
  );
  static TextStyle darkMedium14 = TextStyle(
    fontFamily: GoogleFonts.poppins().fontFamily,
    color: textColorBlack,
    fontSize: 14,
    fontWeight: bold,
  );
  static TextStyle darkMedium16 = TextStyle(
    fontFamily: GoogleFonts.poppins().fontFamily,
    color: textColorBlack,
    fontSize: 16,
    fontWeight: bold,
  );
  static TextStyle darkUnderline14 = TextStyle(
    fontFamily: GoogleFonts.poppins().fontFamily,
    color: textColorBlack,
    fontSize: 14,
    fontWeight: bold,
  );

  static TextStyle blackBold10 = TextStyle(
    fontFamily: GoogleFonts.poppins().fontFamily,
    color: textColorBlack,
    fontSize: 10,
    fontWeight: bold,
  );
  static TextStyle blackBold13 = TextStyle(
    fontFamily: GoogleFonts.poppins().fontFamily,
    color: Colors.black,
    fontSize: 13,
    fontWeight: bold,
  );
  static TextStyle blackBold = TextStyle(
    fontFamily: GoogleFonts.poppins().fontFamily,
    color: textColorBlack,
    fontWeight: bold,
  );
  static TextStyle blackBold15 = TextStyle(
    fontFamily: GoogleFonts.poppins().fontFamily,
    color: textColorBlack,
    fontSize: 15,
    fontWeight: bold,
  );
  static TextStyle blackBold16 = TextStyle(
    fontFamily: GoogleFonts.poppins().fontFamily,
    color: textColorBlack,
    fontSize: 16,
    fontWeight: bold,
  );
  static TextStyle blackBold20 = TextStyle(
    fontFamily: GoogleFonts.poppins().fontFamily,
    color: textColorBlack,
    fontSize: 20,
    fontWeight: bold,
  );

  static TextStyle grayRegular = TextStyle(
    fontFamily: GoogleFonts.poppins().fontFamily,
    color: lightGrayColor,
  );
  static TextStyle grayRegular8 = TextStyle(
    fontFamily: GoogleFonts.poppins().fontFamily,
    color: lightGrayColor,
    fontSize: 8,
  );
  static TextStyle grayRegular12 = TextStyle(
    fontFamily: GoogleFonts.poppins().fontFamily,
    color: lightGrayColor,
    fontSize: 12,
  );
  static TextStyle greyRegular12 = TextStyle(
    fontFamily: GoogleFonts.poppins().fontFamily,
    color: lightGrayColor,
    fontSize: 12,
  );
  static TextStyle grayRegular13 = TextStyle(
    fontFamily: GoogleFonts.poppins().fontFamily,
    color: lightGrayColor,
    fontSize: 13,
  );
  static TextStyle greyThrough12 = TextStyle(
    fontFamily: GoogleFonts.poppins().fontFamily,
    color: lightGrayColor,
    fontSize: 12,
  );
  static TextStyle greyThrough14 = TextStyle(
    fontFamily: GoogleFonts.poppins().fontFamily,
    color: lightGrayColor,
    fontSize: 14,
    decoration: TextDecoration.lineThrough,
  );
  static TextStyle greyThrough16 = TextStyle(
    fontFamily: GoogleFonts.poppins().fontFamily,
    color: lightGrayColor,
    fontSize: 16,
  );
  static TextStyle grayMedium10 = TextStyle(
    fontFamily: GoogleFonts.poppins().fontFamily,
    color: lightGrayColor,
    fontSize: 10,
    fontWeight: medium,
  );
  static TextStyle grayMedium13 = TextStyle(
    fontFamily: GoogleFonts.poppins().fontFamily,
    color: lightGrayColor,
    fontSize: 13,
    fontWeight: medium,
  );
  static TextStyle grayMedium = TextStyle(
    fontFamily: GoogleFonts.poppins().fontFamily,
    color: lightGrayColor,
    fontWeight: medium,
  );
  static TextStyle grayMedium15 = TextStyle(
    fontFamily: GoogleFonts.poppins().fontFamily,
    color: lightGrayColor,
    fontSize: 15,
    fontWeight: medium,
  );
  static TextStyle grayBold12 = TextStyle(
    fontFamily: GoogleFonts.poppins().fontFamily,
    color: lightGrayColor,
    fontSize: 12,
    fontWeight: bold,
  );
  static TextStyle grayBold15 = TextStyle(
    fontFamily: GoogleFonts.poppins().fontFamily,
    color: lightGrayColor,
    fontSize: 15,
    fontWeight: bold,
  );
  static TextStyle grayBold16 = TextStyle(
    fontFamily: GoogleFonts.poppins().fontFamily,
    color: lightGrayColor,
    fontSize: 16,
    fontWeight: bold,
  );
  static TextStyle whiteRegular12 = TextStyle(
    fontFamily: GoogleFonts.poppins().fontFamily,
    color: Colors.white,
    fontSize: 12,
  );
  static TextStyle whiteBold = TextStyle(
    fontFamily: GoogleFonts.poppins().fontFamily,
    color: Colors.white,
    fontWeight: bold,
  );
  static TextStyle whiteBold15 = TextStyle(
    fontFamily: GoogleFonts.poppins().fontFamily,
    color: Colors.white,
    fontSize: 15,
    fontWeight: bold,
  );
  static TextStyle whiteBold16 = TextStyle(
    fontFamily: GoogleFonts.poppins().fontFamily,
    color: Colors.white,
    fontSize: 16,
    fontWeight: bold,
  );
  static TextStyle whiteExtraBold = TextStyle(
    fontFamily: GoogleFonts.poppins().fontFamily,
    color: Colors.white,
    fontWeight: extraBold,
  );

  static TextStyle greenBold12 = TextStyle(
    fontFamily: GoogleFonts.poppins().fontFamily,
    color: greenColor,
    fontSize: 12,
    fontWeight: bold,
  );
  static TextStyle blueBold12 = TextStyle(
    fontFamily: GoogleFonts.poppins().fontFamily,
    color: blueColor,
    fontSize: 12,
    fontWeight: bold,
  );
  static TextStyle blueMedium14 = TextStyle(
    fontFamily: GoogleFonts.poppins().fontFamily,
    color: blueColor,
    fontSize: 14,
    fontWeight: medium,
  );
  static TextStyle blue12 = TextStyle(
    fontFamily: GoogleFonts.poppins().fontFamily,
    color: blueColor,
    fontSize: 12,
    fontWeight: regular,
  );
  static TextStyle redBold12 = TextStyle(
    fontFamily: GoogleFonts.poppins().fontFamily,
    color: redColor,
    fontSize: 12,
    fontWeight: bold,
  );
  static TextStyle brandGrey13 = TextStyle(
    fontFamily: GoogleFonts.poppins().fontFamily,
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
    useMaterial3: true,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    indicatorColor: primaryColor,
    dividerColor: borderLightColor,
    scaffoldBackgroundColor: backgroundColor,
    primaryColor: primaryColor,
    focusColor: primaryColor,
    fontFamily: GoogleFonts.poppins().fontFamily,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      primary: primaryColor,
      secondary: secondaryColor,
      surface: Colors.white,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: textColorBlack,
      elevation: 0,
      centerTitle: true,
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: borderLightColor, width: 1),
      ),
      margin: EdgeInsets.zero,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: borderLightColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: borderLightColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: primaryColor, width: 1.5),
      ),
      hintStyle: TextStyle(color: textHintColor, fontSize: 14),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        foregroundColor: primaryColor,
        side: BorderSide(color: primaryColor),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: primaryColor,
      unselectedItemColor: textHintColor,
      elevation: 8,
      type: BottomNavigationBarType.fixed,
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
