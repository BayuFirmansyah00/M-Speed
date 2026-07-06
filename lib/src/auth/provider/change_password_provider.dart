import 'dart:developer';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../common/base/base_controller.dart';
import '../../../common/base/base_response.dart';
import '../../../common/helper/constant.dart';
import 'package:flutter/material.dart';

class ChangePasswordProvider extends BaseController with ChangeNotifier {
  TextEditingController oldPassC = TextEditingController();
  TextEditingController newPassC = TextEditingController();
  TextEditingController confirmNewPassC = TextEditingController();
  GlobalKey<FormState> changePassKey = GlobalKey<FormState>();

  bool _obscureOldPass = true;
  bool _obscureNewPass = true;
  bool _obscureConfirmNewPass = true;

  get obscureOldPass => this._obscureOldPass;

  toggleObscureOldPass() {
    this._obscureOldPass = !obscureOldPass;
    notifyListeners();
  }

  get obscureNewPass => this._obscureNewPass;

  togegleObscureNewPass() {
    this._obscureNewPass = !obscureNewPass;
    notifyListeners();
  }

  get obscureConfirmNewPass => this._obscureConfirmNewPass;

  toggleObscureConfirmNewPass() {
    this._obscureConfirmNewPass = !obscureConfirmNewPass;
    notifyListeners();
  }

  Future<BaseResponse> changePassword() async {
    log("OLD PASS : ${oldPassC.text}");
    log("NEW PASS : ${newPassC.text}");
    log("CONFIRM NEW PASS : ${confirmNewPassC.text}");
    loading(true);
    if (changePassKey.currentState!.validate()) {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      final token = prefs.getString(Constant.kSetPrefToken);

      if (newPassC.text.length < 8) {
        // throw "Minimal kata sandi 8 karakter";
      }

      if (newPassC.text != confirmNewPassC.text) {
        throw "Kata sandi baru dan Konfirmasi kata sandi tidak sama";
      }

      Map<String, String> param = {
        'old_password': oldPassC.text,
        'password': newPassC.text,
        'c_password': confirmNewPassC.text,
      };
      // Map<String, String> param = {
      //   'email': email,
      //   'token': token ?? "",
      //   'password': newPassC.text,
      //   'c_password': confirmNewPassC.text,
      // };
      final response = BaseResponse.from(await post(
          Constant.BASE_API_FULL + '/profile-password',
          body: param));

      if (response.success) {
        loading(false);
        return response;
      } else {
        final message = response.message;
        loading(false);
        throw Exception(message);
      }
    } else {
      loading(false);
      throw 'Harap Lengkapi Form';
    }
  }

  Future<BaseResponse> logout() async {
    loading(true);
    final response =
        BaseResponse.from(await post(Constant.BASE_API_FULL + '/logout'));

    if (response.success) {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      // set to shared preferences
      await prefs.remove(Constant.kSetPrefToken);
      await prefs.remove(Constant.kSetPrefFirstName);

      loading(false);
      return response;
    } else {
      final message = response.message;
      loading(false);
      throw Exception(message);
    }
  }
}
