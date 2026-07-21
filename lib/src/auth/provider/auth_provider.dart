import 'dart:convert';
import 'dart:developer';
import 'package:mspeed/common/component/custom_navigator.dart';
import 'package:mspeed/src/admin/home/view/admin_main_home.dart';
import 'package:mspeed/src/auth/model/auth_response_model.dart';
import 'package:mspeed/src/auth/model/firebase_token_model.dart';
import 'package:mspeed/src/buyer/home/view/main_home.dart';
import 'package:mspeed/src/keuangan/home/view/main_home_keuangan_view.dart';
import 'package:mspeed/src/penerima/home/view/dashboard_pesanan_view.dart';
import 'package:mspeed/src/seller/home/view/seller_main_home.dart';
import 'package:mspeed/src/seller/profil/view/profile_edit_seller_view.dart';
import 'package:mspeed/utils/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../common/base/base_controller.dart';
import '../../../common/base/base_response.dart';
import '../../../common/helper/constant.dart';
import 'package:flutter/material.dart';

class AuthProvider extends BaseController with ChangeNotifier {
  TextEditingController usernameC = TextEditingController();
  TextEditingController Email = TextEditingController();
  TextEditingController passC = TextEditingController();
  TextEditingController NIKC = TextEditingController();
  TextEditingController namaLengkap = TextEditingController();
  TextEditingController namaIbuKAndung = TextEditingController();
  TextEditingController noTelp = TextEditingController();
  TextEditingController tempatLahir = TextEditingController();
  TextEditingController tanggalLahir = TextEditingController();
  TextEditingController alamat = TextEditingController();
  TextEditingController provinsi = TextEditingController();
  TextEditingController kabupaten = TextEditingController();
  TextEditingController kecamatan = TextEditingController();
  TextEditingController kelurahan = TextEditingController();
  TextEditingController bank = TextEditingController();
  TextEditingController nomorRekening = TextEditingController();
  TextEditingController atasNamaRekening = TextEditingController();
  TextEditingController tanggalUmroh = TextEditingController();
  GlobalKey<FormState> loginKey = GlobalKey<FormState>();
  //forgot
  TextEditingController emailForgotC = TextEditingController();
  TextEditingController tokenC = TextEditingController();
  TextEditingController passForgotC = TextEditingController();
  TextEditingController confirmPassForgotC = TextEditingController();
  GlobalKey<FormState> forgotKey = GlobalKey<FormState>();
  GlobalKey<FormState> tokenKey = GlobalKey<FormState>();
  GlobalKey<FormState> confirmKey = GlobalKey<FormState>();

  DateTime? tanggal;

  get date => tanggal;

  bool _obscurePass = true;

  bool get obscurePass => this._obscurePass;

  toggleObscurePass() {
    this._obscurePass = !obscurePass;
    notifyListeners();
  }

  FirebaseTokenModel _firebaseTokenModel = FirebaseTokenModel();
  get firebaseTokenModel => this._firebaseTokenModel;

  set firebaseTokenModel(value) {
    this._firebaseTokenModel = value;
    notifyListeners();
  }

  Future<void> login(BuildContext context) async {
    try {
      log("LOGIN TARGET : ${usernameC.text}");
      loading(true);
      if (loginKey.currentState!.validate()) {
        FocusManager.instance.primaryFocus?.unfocus();

        // Request body sesuai dengan Laravel LoginRequest
        Map<String, String> param = {
          'login_target': usernameC.text,
          'password': passC.text,
        };

        // Memanggil API Autentikasi Laravel Sanctum: POST /api/v1/auth/token
        final response =
            await post(Constant.BASE_API_FULL + '/v1/auth/token', body: param);

        if (response.statusCode == 200 || response.statusCode == 201) {
          // Parsing response Laravel Sanctum yang benar
          final AuthResponseModel authResponse =
              AuthResponseModel.fromJson(jsonDecode(response.body));

          if (!authResponse.isValid) {
            loading(false);
            Utils.showFailed(msg: 'Token tidak valid dari server');
            return;
          }

          final String token = authResponse.accessToken!;
          log("TOKEN DITERIMA: $token");

          SharedPreferences prefs = await SharedPreferences.getInstance();

          // Simpan token Bearer yang sebenarnya dari Laravel Sanctum
          await prefs.setString(Constant.kSetPrefToken, token);
          await prefs.setString(Constant.kSetPrefEmail, usernameC.text);

          // Fetch data user (role, nama, dll.) menggunakan token yang baru diperoleh
          // untuk menentukan navigasi yang tepat
          await _fetchAndStoreUserProfile(context, prefs, token);

          usernameC.clear();
          passC.clear();
          loading(false);
        } else {
          String message = "Email atau Password Salah";
          try {
            message =
                jsonDecode(response.body)["message"] ?? message;
          } catch (e) {}
          loading(false);
          Utils.showFailed(msg: message);
        }
      } else {
        loading(false);
        Utils.showFailed(msg: 'Harap Lengkapi Form');
      }
    } catch (e) {
      loading(false);
      Utils.showFailed(msg: '$e');
    }
  }

  /// Fetch profil user setelah login untuk mendapatkan role dan data user.
  /// Menggunakan endpoint GET /api/v1/user (jika aktif di backend).
  /// Jika endpoint belum aktif, fallback ke role default BUYER.
  Future<void> _fetchAndStoreUserProfile(
      BuildContext context, SharedPreferences prefs, String token) async {
    try {
      // Coba fetch user profile dari Laravel
      final userResponse = await get(Constant.BASE_API_FULL + '/v1/user');

      if (userResponse.statusCode == 200) {
        final userData = jsonDecode(userResponse.body);

        // Ambil data dari response user profile Laravel
        final String role = userData['role']?.toString() ?? 'BUYER';
        final String userId = userData['id']?.toString() ?? '';
        final String email = userData['email']?.toString() ?? usernameC.text;

        // Data profil (dari relasi userData jika ada)
        final profile = userData['profile'];
        final String firstName = profile?['first_name']?.toString() ?? '';
        final String lastName = profile?['last_name']?.toString() ?? '';
        final String phone = profile?['phone']?.toString() ?? '';

        await prefs.setString(Constant.kSetPrefId, userId);
        await prefs.setString(Constant.kSetPrefRoles, role);
        await prefs.setString(Constant.kSetPrefEmail, email);
        await prefs.setString(Constant.kSetPrefFirstName, firstName);
        await prefs.setString(Constant.kSetPrefLastName, lastName);
        await prefs.setString(Constant.kSetPrefPhone, phone);

        log("ROLE USER: $role");
        _navigateByRole(context, role, userData['completeness']?.toString());
      } else {
        // Endpoint belum aktif — fallback navigasi ke BUYER sebagai default
        log("Endpoint /v1/user belum aktif, fallback ke BUYER");
        await prefs.setString(Constant.kSetPrefRoles, 'BUYER');
        await prefs.setString(Constant.kSetPrefId, '');
        await prefs.setString(Constant.kSetPrefFirstName, '');
        await prefs.setString(Constant.kSetPrefLastName, '');
        _navigateByRole(context, 'BUYER', null);
      }
    } catch (e) {
      // Fallback jika endpoint tidak tersedia
      log("Error fetch user profile: $e — fallback ke BUYER");
      await prefs.setString(Constant.kSetPrefRoles, 'BUYER');
      _navigateByRole(context, 'BUYER', null);
    }
  }

  /// Navigasi berdasarkan role user dari database Laravel.
  void _navigateByRole(BuildContext context, String role, String? completeness) {
    switch (role.toUpperCase()) {
      case 'SELLER':
        CusNav.nPushReplace(context, SellerMainHome());
        // Jika profil belum lengkap, arahkan ke halaman edit profil
        if (completeness == '0') {
          CusNav.nPush(context, ProfileEditSellerView());
        }
        break;
      case 'PENERIMA':
      case 'RECEIVER':
        CusNav.nPushReplace(context, DashboardPesananView());
        break;
      case 'KEUANGAN':
      case 'FINANCE':
        CusNav.nPushReplace(context, MainHomeKeuanganView());
        break;
      case 'ADMIN':
      case 'MANAGER':
      case 'AUDIT':
        CusNav.nPushReplace(context, AdminMainHome());
        break;
      case 'BUYER':
      default:
        CusNav.nPushReplace(context, MainHome());
        break;
    }
  }

  Future<void> updateFirebaseToken(dynamic data) async {
    loading(true);
    final response = await post(
      Constant.BASE_API_FULL + '/firebase/update-token',
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      firebaseTokenModel =
          FirebaseTokenModel.fromJson(jsonDecode(response.body));
      loading(false);
    } else {
      final message = jsonDecode(response.body)["messages"]?["error"] ??
          jsonDecode(response.body)["message"] ??
          'Gagal update token firebase';
      loading(false);
      throw Exception(message);
    }
  }

  Future<void> logout() async {
    loading(true);
    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.remove(Constant.kSetPrefToken);
    await prefs.remove(Constant.kSetPrefId);
    await prefs.remove(Constant.kSetPrefFirstName);
    await prefs.remove(Constant.kSetPrefLastName);
    await prefs.remove(Constant.kSetPrefRoles);
    await prefs.remove(Constant.kSetPrefEmail);
    await prefs.remove(Constant.kSetPrefPhone);
    await prefs.clear();

    loading(false);
  }

  Future<BaseResponse> postForgot() async {
    final param = {'email': emailForgotC.text};
    loading(true);
    final response = BaseResponse.from(
        await post(Constant.BASE_API_FULL + '/forgot', body: param));
    loading(false);

    if (response.success) {
      return response;
    } else {
      final message = response.message;
      throw Exception(message);
    }
  }

  Future<String> postToken() async {
    final param = {
      'email': emailForgotC.text,
      'token': tokenC.text,
    };

    loading(true);
    final response = BaseResponse.from(
        await post(Constant.BASE_API_FULL + '/forgot/verify', body: param));
    loading(false);

    final message = response.message;
    if (response.success) {
      return message;
    } else {
      throw Exception(message);
    }
  }

  Future<String> postPassword() async {
    final param = {
      'email': emailForgotC.text,
      'token': tokenC.text,
      'password': passForgotC.text,
      'c_password': confirmPassForgotC.text
    };

    loading(true);
    final response = BaseResponse.from(await post(
        Constant.BASE_API_FULL + '/forgot/change-password',
        body: param));

    loading(false);

    final message = response.message;
    if (response.success) {
      usernameC.clear();
      emailForgotC.clear();
      passC.clear();
      passForgotC.clear();
      confirmPassForgotC.clear();
      return message;
    } else {
      throw Exception(message);
    }
  }

  setDate(DateTime? date) {
    tanggal = date;
    notifyListeners();
  }
}
