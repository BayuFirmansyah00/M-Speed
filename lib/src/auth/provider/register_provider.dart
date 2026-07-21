import 'dart:convert';
import 'package:mspeed/common/component/custom_navigator.dart';
import 'package:mspeed/src/auth/model/register_response_model.dart';
import 'package:mspeed/src/auth/view/login_view.dart';
import 'package:mspeed/src/seller/home/view/seller_main_home.dart';
import 'package:mspeed/src/seller/profil/view/profile_edit_seller_view.dart';
import 'package:mspeed/utils/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../common/base/base_controller.dart';
import '../../../common/helper/constant.dart';
import 'package:flutter/material.dart';

class RegisterProvider extends BaseController with ChangeNotifier {
  GlobalKey<FormState> registerKey = GlobalKey<FormState>();
  bool acc = false;
  TextEditingController companyNameC = TextEditingController(),
      ownerNameC = TextEditingController(),
      roleC = TextEditingController(),
      addressC = TextEditingController(),
      emailC = TextEditingController(),
      passwordC = TextEditingController(),
      confirmPasswordC = TextEditingController();

  Future<void> register(BuildContext context) async {
    if (passwordC.text != confirmPasswordC.text) {
      Utils.showFailed(msg: 'Password dan Konfirmasi Password Tidak Sama');
      return;
    }

    loading(true);
    if (registerKey.currentState!.validate()) {
      FocusManager.instance.primaryFocus?.unfocus();

      // Request body sesuai dengan Laravel RegisterSellerRequest
      Map<String, String> param = {
        'name': companyNameC.text,
        'email': emailC.text,
        'password': passwordC.text,
        'password_confirmation': confirmPasswordC.text,
      };

      try {
        // POST /api/v1/merchant/register
        final response = await post(
            Constant.BASE_API_FULL + '/v1/merchant/register',
            body: param);

        if (response.statusCode == 201 || response.statusCode == 200) {
          // Parsing response Laravel SellerDataResource dengan meta token
          final RegisterResponseModel registerResponse =
              RegisterResponseModel.fromJson(jsonDecode(response.body));

          final String? token = registerResponse.meta?.accessToken;
          final RegisterResponseUser? user = registerResponse.data?.user;
          final int? completeness = registerResponse.data?.completeness;

          if (token != null && token.isNotEmpty) {
            // Simpan token Bearer yang diperoleh dari response registrasi
            // tanpa perlu login ulang
            SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.setString(Constant.kSetPrefToken, token);
            await prefs.setString(
                Constant.kSetPrefId, user?.id?.toString() ?? '');
            await prefs.setString(
                Constant.kSetPrefEmail, user?.email ?? emailC.text);
            await prefs.setString(
                Constant.kSetPrefRoles, user?.role ?? 'SELLER');
            await prefs.setString(Constant.kSetPrefFirstName,
                registerResponse.data?.name ?? companyNameC.text);
            await prefs.setString(Constant.kSetPrefLastName, '');

            Utils.showSuccess(
                msg: registerResponse.meta?.message ??
                    'Registrasi berhasil. Silakan lengkapi profil.');

            _clearForm();

            // Navigasi langsung ke seller home, karena token sudah tersimpan
            CusNav.nPushAndRemoveUntil(context, SellerMainHome());

            // Jika profil belum lengkap (completeness == 0), arahkan ke edit profil
            if ((completeness ?? 0) == 0) {
              CusNav.nPush(context, ProfileEditSellerView());
            }
          } else {
            // Token tidak ada di response — fallback: arahkan ke login
            Utils.showSuccess(
                msg: 'Registrasi berhasil! Silakan login untuk melanjutkan.');
            _clearForm();
            CusNav.nPushAndRemoveUntil(context, LoginView());
          }
        } else {
          String message = "Gagal mendaftar";
          try {
            final decoded = jsonDecode(response.body);
            message = decoded["message"] ?? decoded["error"] ?? message;
          } catch (e) {}
          Utils.showFailed(msg: message);
        }
      } catch (e) {
        Utils.showFailed(msg: '$e');
      }
      loading(false);
    } else {
      loading(false);
      Utils.showFailed(msg: 'Harap Lengkapi Form');
    }
  }

  void _clearForm() {
    companyNameC.clear();
    ownerNameC.clear();
    roleC.clear();
    addressC.clear();
    emailC.clear();
    passwordC.clear();
    confirmPasswordC.clear();
  }
}
