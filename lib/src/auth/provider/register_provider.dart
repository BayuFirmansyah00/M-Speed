import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:mspeed/common/component/custom_navigator.dart';
import 'package:mspeed/src/auth/provider/auth_provider.dart';
import 'package:mspeed/src/auth/view/login_view.dart';
import 'package:mspeed/utils/utils.dart';
import 'package:provider/provider.dart';

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

    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Utils.showFailed(msg: 'Harap Nyalakan GPS');
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        final result = await Geolocator.openLocationSettings();
        if (!result) {
          Utils.showFailed(msg: 'Izinkan GPS');
          return;
        }
      }
    }
    if (permission == LocationPermission.deniedForever) {
      final result = await Geolocator.openLocationSettings();
      if (!result) {
        Utils.showFailed(msg: 'Izinkan GPS');
        return;
      }
    }
    loading(true);
    if (registerKey.currentState!.validate()) {
      FocusManager.instance.primaryFocus?.unfocus();
      Map<String, String> param = {
        'nama': companyNameC.text,
        'nama_pemilik': ownerNameC.text,
        'jabatan': roleC.text,
        'alamat': addressC.text,
        'email': emailC.text,
        'password': passwordC.text,
      };
      final response =
          await post(Constant.BASE_API_FULL + '/createaccount', body: param);

      if (response.statusCode == 201) {
        final p = context.read<AuthProvider>();
        p.usernameC.text = emailC.text;
        p.passC.text = passwordC.text;
        await p.login(context);
        companyNameC.clear();
        ownerNameC.clear();
        roleC.clear();
        addressC.clear();
        emailC.clear();
        passwordC.clear();
        confirmPasswordC.clear();
        loading(false);
        CusNav.nPushAndRemoveUntil(context, LoginView());
      } else {
        final message = jsonDecode(response.body)["messages"]["result"];
        loading(false);
        Utils.showFailed(msg: message);
        throw Exception(message);
      }
    } else {
      loading(false);
      Utils.showFailed(msg: 'Harap Lengkapi Form');
    }
  }
}
