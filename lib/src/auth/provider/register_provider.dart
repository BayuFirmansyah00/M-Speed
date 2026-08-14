import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../common/base/base_controller.dart';
import '../../../common/component/custom_navigator.dart';
import '../../../common/helper/constant.dart';
import '../../../utils/utils.dart';
import '../../auth/view/login_view.dart';
import '../../buyer/address/view/custom_map_view.dart';
import '../../seller/profil/model/kota_model.dart';
import '../../seller/profil/model/provinsi_model.dart';

class RegisterProvider extends BaseController with ChangeNotifier {
  GlobalKey<FormState> formKeyAccount = GlobalKey<FormState>();
  GlobalKey<FormState> formKeyStore = GlobalKey<FormState>();
  GlobalKey<FormState> formKeyContact = GlobalKey<FormState>();
  GlobalKey<FormState> formKeyAddress = GlobalKey<FormState>();
  GlobalKey<FormState> formKeyBank = GlobalKey<FormState>();
  GlobalKey<FormState> formKeyLegality = GlobalKey<FormState>();

  bool acc = false;
  int currentStep = 0;

  // STEP 1: ACCOUNT
  TextEditingController emailC = TextEditingController();
  TextEditingController passwordC = TextEditingController();
  TextEditingController confirmPasswordC = TextEditingController();

  // STEP 2: STORE
  TextEditingController companyNameC = TextEditingController();
  TextEditingController ownerNameC = TextEditingController();
  TextEditingController roleC = TextEditingController();
  TextEditingController kbliC = TextEditingController();
  int? jenisToko; // 1 = PKP, 2 = Non PKP NPWP, 3 = Non PKP Non NPWP

  // STEP 3: CONTACT
  TextEditingController phoneC = TextEditingController();
  TextEditingController salesNameC = TextEditingController();
  TextEditingController salesPhoneC = TextEditingController();

  // STEP 4: ADDRESS
  TextEditingController addressC = TextEditingController();
  TextEditingController provinceC = TextEditingController();
  TextEditingController cityC = TextEditingController();
  TextEditingController latC = TextEditingController();
  TextEditingController lngC = TextEditingController();

  ProvinsiModel? provinsiModel;
  String? selectedProvince;
  String? selectedProvinceId;

  KotaModel? kotaModel;
  String? selectedCity;
  String? selectedCityId;

  // Map
  late MapController mapController;
  LatLng? locationCoordinate;
  String? locationName;
  Marker? marker;

  // STEP 5: BANK
  TextEditingController bankTypeC = TextEditingController();
  TextEditingController bankNumberC = TextEditingController();
  TextEditingController bankNameC = TextEditingController();
  XFile? bankNumberFile;
  TextEditingController bankNumberFileC = TextEditingController();

  // STEP 6: LEGALITY
  TextEditingController ktpNumberC = TextEditingController();
  TextEditingController npwpC = TextEditingController();
  TextEditingController nibC = TextEditingController();
  
  XFile? ktpFile;
  TextEditingController ktpFileC = TextEditingController();
  XFile? npwpFile;
  TextEditingController npwpFileC = TextEditingController();
  XFile? nibFile;
  TextEditingController nibFileC = TextEditingController();
  XFile? spSkpFile;
  TextEditingController spSkpFileC = TextEditingController();
  XFile? suratPernyataanFile;
  TextEditingController suratPernyataanFileC = TextEditingController();
  File? ttd;

  RegisterProvider() {
    mapController = MapController();
  }

  // --- LOCATION LOGIC ---
  Future<void> setMapLocation(PickedData pickedData) async {
    locationName = pickedData.address;
    locationCoordinate = LatLng(pickedData.latLong.latitude, pickedData.latLong.longitude);
    if (locationCoordinate != null) {
      marker = Marker(
        point: locationCoordinate!,
        child: const Icon(Icons.location_on, color: Colors.red),
      );
      latC.text = locationCoordinate!.latitude.toString();
      lngC.text = locationCoordinate!.longitude.toString();
      notifyListeners();
    }
  }

  // --- API DATA ---
  Future<void> fetchProvinsi({bool withLoading = false}) async {
    if (withLoading) loading(true);
    try {
      final response = await get(Constant.BASE_API_FULL + '/provinces');
      if (response.statusCode == 201 || response.statusCode == 200) {
        provinsiModel = ProvinsiModel.fromJson(jsonDecode(response.body));
        notifyListeners();
      }
    } catch (e) {
      // Ignore for now
    }
    if (withLoading) loading(false);
  }

  Future<void> fetchKota({bool withLoading = false}) async {
    if (withLoading) loading(true);
    try {
      final response = await get(Constant.BASE_API_FULL + '/cities');
      if (response.statusCode == 201 || response.statusCode == 200) {
        kotaModel = KotaModel.fromJson(jsonDecode(response.body));
        notifyListeners();
      }
    } catch (e) {
      // Ignore for now
    }
    if (withLoading) loading(false);
  }

  // --- WIZARD NAVIGATION ---
  void nextStep() {
    bool isValid = false;
    if (currentStep == 0) {
      isValid = formKeyAccount.currentState?.validate() ?? false;
      if (isValid && passwordC.text != confirmPasswordC.text) {
        Utils.showFailed(msg: 'Password dan Konfirmasi Password Tidak Sama');
        isValid = false;
      }
    } else if (currentStep == 1) {
      isValid = formKeyStore.currentState?.validate() ?? false;
      if (isValid && jenisToko == null) {
        Utils.showFailed(msg: 'Pilih Jenis Toko terlebih dahulu');
        isValid = false;
      }
    } else if (currentStep == 2) {
      isValid = formKeyContact.currentState?.validate() ?? false;
    } else if (currentStep == 3) {
      isValid = formKeyAddress.currentState?.validate() ?? false;
      if (isValid && selectedProvinceId == null) {
        Utils.showFailed(msg: 'Pilih Provinsi');
        isValid = false;
      } else if (isValid && selectedCityId == null) {
        Utils.showFailed(msg: 'Pilih Kota');
        isValid = false;
      }
    } else if (currentStep == 4) {
      isValid = formKeyBank.currentState?.validate() ?? false;
      if (isValid && bankNumberFile == null) {
        Utils.showFailed(msg: 'Buku Rekening wajib diupload');
        isValid = false;
      }
    } else if (currentStep == 5) {
      isValid = formKeyLegality.currentState?.validate() ?? false;
      if (isValid) {
        if (ktpFile == null) {
          Utils.showFailed(msg: 'KTP wajib diupload');
          isValid = false;
        } else if (jenisToko != 2 && npwpFile == null) {
          Utils.showFailed(msg: 'NPWP wajib diupload');
          isValid = false;
        } else if (nibFile == null) {
          Utils.showFailed(msg: 'NIB wajib diupload');
          isValid = false;
        } else if (jenisToko == 1 && spSkpFile == null) {
          Utils.showFailed(msg: 'SP SKP wajib diupload');
          isValid = false;
        } else if (suratPernyataanFile == null) {
          Utils.showFailed(msg: 'Surat Pernyataan wajib diupload');
          isValid = false;
        } else if (ttd == null) {
          Utils.showFailed(msg: 'Tanda tangan wajib diisi');
          isValid = false;
        }
      }
    }

    if (isValid) {
      currentStep++;
      notifyListeners();
    }
  }

  void previousStep() {
    if (currentStep > 0) {
      currentStep--;
      notifyListeners();
    }
  }

  // --- SUBMIT ---
  Future<void> submitRegistration(BuildContext context) async {
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
        
        // Simpan token
        if (data['meta'] != null && data['meta']['access_token'] != null) {
          SharedPreferences pref = await SharedPreferences.getInstance();
          await pref.setString(Constant.kSetPrefToken, data['meta']['access_token']);
        }
        
        Utils.showSuccess(msg: 'Registrasi seller berhasil');
        CusNav.nPushReplace(context, LoginView());
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

    // NOTE: Semua field lain (KBLI, phone, cp_name, kota, bank, dokumen, dll) 
    // saat ini tidak dikirimkan karena API Backend (RegisterSellerRequest.php) 
    // belum memiliki rules validasi dan mekanisme penyimpanan untuk field tersebut.
    // Jika dikirimkan, Laravel hanya akan membuangnya (ignored by request->validated()).

    return request;
  }

  void clearForm() {
    acc = false;
    currentStep = 0;
    
    emailC.clear();
    passwordC.clear();
    confirmPasswordC.clear();
    
    companyNameC.clear();
    ownerNameC.clear();
    roleC.clear();
    kbliC.clear();
    jenisToko = null;
    
    phoneC.clear();
    salesNameC.clear();
    salesPhoneC.clear();
    
    addressC.clear();
    provinceC.clear();
    cityC.clear();
    latC.clear();
    lngC.clear();
    selectedProvince = null;
    selectedProvinceId = null;
    selectedCity = null;
    selectedCityId = null;
    locationCoordinate = null;
    locationName = null;
    marker = null;
    
    bankTypeC.clear();
    bankNumberC.clear();
    bankNameC.clear();
    bankNumberFile = null;
    bankNumberFileC.clear();
    
    ktpNumberC.clear();
    npwpC.clear();
    nibC.clear();
    ktpFile = null;
    ktpFileC.clear();
    npwpFile = null;
    npwpFileC.clear();
    nibFile = null;
    nibFileC.clear();
    spSkpFile = null;
    spSkpFileC.clear();
    suratPernyataanFile = null;
    suratPernyataanFileC.clear();
    ttd = null;
    
    notifyListeners();
  }

  Future<String?> fetchTemplateNonPKPSeller({bool withLoading = false}) async {
    Utils.showFailed(msg: 'Fitur belum tersedia (BACKEND API NOT AVAILABLE)');
    return null;
  }
}
