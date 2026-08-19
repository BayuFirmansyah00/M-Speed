import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../common/base/base_controller.dart';
import '../../../common/component/custom_navigator.dart';
import '../../../common/helper/constant.dart';
import '../../../utils/utils.dart';
import '../../seller/home/view/seller_main_home.dart';

class RegisterProvider extends BaseController with ChangeNotifier {
  GlobalKey<FormState> formKeyAccount = GlobalKey<FormState>();

  bool acc = false;

  // Fields Basic
  TextEditingController emailC = TextEditingController();
  TextEditingController passwordC = TextEditingController();
  TextEditingController confirmPasswordC = TextEditingController();
  
  // Store
  TextEditingController companyNameC = TextEditingController();
  TextEditingController ownerNameC = TextEditingController();

  // Address
  TextEditingController addressC = TextEditingController();

  // --- WIZARD NAVIGATION ---
  // No longer needed for single step, but we keep it simple.

  // --- SUBMIT ---
  Future<void> submitRegistration(BuildContext context) async {
    bool isValid = formKeyAccount.currentState?.validate() ?? false;
    
    if (!isValid) return;

    if (passwordC.text != confirmPasswordC.text) {
      Utils.showFailed(msg: 'Password dan Konfirmasi Password Tidak Sama');
      return;
    }

    if (!acc) {
      Utils.showFailed(msg: 'Anda harus menyetujui Syarat dan Ketentuan');
      return;
    }

    loading(true);
    
    try {
      final requestPayload = await _buildSellerRegistrationPayload();
      
      final response = await requestPayload.send();
      final responseBody = await response.stream.bytesToString();
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(responseBody);
        
        // Simpan token, role, ID, completeness
        if (data['meta'] != null && data['meta']['access_token'] != null) {
          SharedPreferences pref = await SharedPreferences.getInstance();
          await pref.setString(Constant.kSetPrefToken, data['meta']['access_token']);
          
          if (data['data'] != null) {
             await pref.setString(Constant.kSetPrefId, data['data']['id']?.toString() ?? '');
             await pref.setString(Constant.kSetPrefRole, data['data']['role']?.toString() ?? 'seller');
             
             if (data['data']['seller_profile'] != null) {
                 final completeness = data['data']['seller_profile']['completeness']?.toString() ?? '30';
                 final sellerProfileId = data['data']['seller_profile']['id']?.toString() ?? '';
                 await pref.setString('completeness', completeness);
                 if (sellerProfileId.isNotEmpty) {
                    await pref.setString('seller_data_id', sellerProfileId);
                 }
             }
             if (data['data']['address'] != null) {
                 final addressId = data['data']['address']['id']?.toString() ?? '';
                 if (addressId.isNotEmpty) {
                    await pref.setString('seller_address_id', addressId);
                 }
             }
          }
        }
        
        Utils.showSuccess(msg: 'Registrasi seller berhasil');
        // Arahkan ke SellerMainHome, bukan LoginView
        CusNav.nPushReplace(context, SellerMainHome());
      } else if (response.statusCode == 422) {
        final Map<String, dynamic> data = jsonDecode(responseBody);
        if (data['errors'] != null) {
          final errors = data['errors'] as Map<String, dynamic>;
          final firstErrorKey = errors.keys.first;
          final firstErrorMsg = errors[firstErrorKey][0];
          Utils.showFailed(msg: firstErrorMsg);
        } else {
          Utils.showFailed(msg: 'Validasi gagal, silakan periksa kembali data Anda');
        }
      } else {
        Utils.showFailed(msg: 'Terjadi kesalahan pada server. Silakan coba beberapa saat lagi.');
        debugPrint('[SELLER REGISTER ERROR] Status: ${response.statusCode}, Body: $responseBody');
      }

    } catch (e) {
      Utils.showFailed(msg: 'Gagal terhubung ke server');
      debugPrint('[SELLER REGISTER EXCEPTION] $e');
    }
    loading(false);
  }

  // --- PAYLOAD BUILDER ---
  Future<http.MultipartRequest> _buildSellerRegistrationPayload() async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse(Constant.BASE_API_FULL + '/v1/register/seller'),
    );

    // Fields Basic
    request.fields['email'] = emailC.text;
    request.fields['password'] = passwordC.text;
    request.fields['password_confirmation'] = confirmPasswordC.text;
    
    // Store
    request.fields['company_name'] = companyNameC.text;
    request.fields['owner_name'] = ownerNameC.text;

    // Address
    request.fields['detail'] = addressC.text;

    return request;
  }

  void clearForm() {
    acc = false;
    
    emailC.clear();
    passwordC.clear();
    confirmPasswordC.clear();
    
    companyNameC.clear();
    ownerNameC.clear();
    
    addressC.clear();
    
    notifyListeners();
  }
}
