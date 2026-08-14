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
import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';

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
          'email': usernameC.text,
          'password': passC.text,
        };

        // Memanggil API Autentikasi Laravel Sanctum: POST /api/login
        final response = await ApiClient().dio.post('/login', data: param);

        if (response.statusCode == 200 || response.statusCode == 201) {
          debugPrint('LOGIN RESPONSE: ${response.data}');
          debugPrint('RAW ROLE: ${response.data['data']?['role']}');

          // Parsing response Laravel Sanctum yang benar
          final AuthResponseModel authResponse =
              AuthResponseModel.fromJson(response.data);

          if (!authResponse.isValid) {
            loading(false);
            Utils.showFailed(msg: 'Token tidak valid dari server');
            return;
          }

          final String token = authResponse.accessToken!;
          log("TOKEN DITERIMA: $token");

          SharedPreferences prefs = await SharedPreferences.getInstance();

          // Simpan data ke SharedPreferences
          await prefs.setString(Constant.kSetPrefToken, token);
          
          final String email = authResponse.email ?? usernameC.text;
          final String role = authResponse.role ?? 'BUYER';
          final String userId = authResponse.id ?? '';
          
          debugPrint('PARSED ROLE: ${authResponse.role}');

          final bool isAdmin = ['ADMIN', 'MANAGER', 'AUDIT'].contains(role.toUpperCase());

          await prefs.setString(Constant.kSetPrefId, userId);
          await prefs.setString(Constant.kSetPrefRoles, role);
          await prefs.setBool(Constant.kSetPrefIsAdmin, isAdmin);
          await prefs.setString(Constant.kSetPrefEmail, email);
          
          // Data fallback agar aman (karena response login backend belum mengembalikan profil lengkap)
          await prefs.setString(Constant.kSetPrefFirstName, '');
          await prefs.setString(Constant.kSetPrefLastName, '');
          await prefs.setString(Constant.kSetPrefPhone, '');

          log("ROLE USER: $role, IS_ADMIN: $isAdmin");

          // Default completeness aman ke '100' agar seller baru bisa masuk beranda tanpa force-edit.
          final completeness = '100'; 
          
          usernameC.clear();
          passC.clear();
          loading(false);
          
          debugPrint('NAVIGATE ROLE: $role');
          _navigateByRole(context, role, completeness);
        }
      } else {
        loading(false);
        Utils.showFailed(msg: 'Harap Lengkapi Form');
      }
    } on DioException catch (e) {
      String message = "Email atau Password Salah";
      if (e.response != null && e.response?.data != null) {
        message = e.response?.data["message"] ?? message;
      }
      loading(false);
      Utils.showFailed(msg: message);
    } catch (e) {
      loading(false);
      Utils.showFailed(msg: '$e');
    }
  }

  /// Navigasi berdasarkan role user dari database Laravel.
  void _navigateByRole(BuildContext context, String role, String? completeness) {
    switch (role.toUpperCase()) {
      case 'SELLER':
        debugPrint('NAVIGATING TO SELLER');
        CusNav.nPushReplace(context, SellerMainHome());
        // Jika profil belum lengkap, arahkan ke halaman edit profil
        if (completeness == '0') {
          CusNav.nPush(context, ProfileEditSellerView());
        }
        break;
      case 'PENERIMA':
      case 'RECEIVER':
        debugPrint('NAVIGATING TO PENERIMA');
        CusNav.nPushReplace(context, DashboardPesananView());
        break;
      case 'KEUANGAN':
      case 'FINANCE':
        debugPrint('NAVIGATING TO KEUANGAN');
        CusNav.nPushReplace(context, MainHomeKeuanganView());
        break;
      case 'ADMIN':
      case 'MANAGER':
      case 'AUDIT':
        debugPrint('NAVIGATING TO ADMIN');
        CusNav.nPushReplace(context, AdminMainHome());
        break;
      case 'BUYER':
      default:
        debugPrint('NAVIGATING TO BUYER');
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
    throw Exception('Fitur ini belum tersedia pada API backend.');
  }

  Future<String> postToken() async {
    throw Exception('Fitur ini belum tersedia pada API backend.');
  }

  Future<String> postPassword() async {
    throw Exception('Fitur ini belum tersedia pada API backend.');
  }

  setDate(DateTime? date) {
    tanggal = date;
    notifyListeners();
  }
}
