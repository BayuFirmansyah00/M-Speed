import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:mspeed/common/base/base_controller.dart';
import 'package:flutter/material.dart';
import 'package:mspeed/common/component/custom_navigator.dart';
import 'package:mspeed/common/helper/constant.dart';

import 'package:mspeed/src/buyer/address/view/custom_map_view.dart';
import 'package:mspeed/src/seller/profil/model/kota_model.dart';
import 'package:mspeed/src/seller/profil/model/profile_seller_model.dart';
import 'package:mspeed/src/seller/profil/model/provinsi_model.dart';
import 'package:mspeed/utils/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mspeed/main.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart';

class ProfileSellerProvider extends BaseController with ChangeNotifier {
  late StreamSubscription<Position> geolocatorSubscription;
  late MapController mapController;

  final markerId = 'selected_location'; // Marker ID as a string
  Marker? marker;
  List<LatLng> polylinePoints = []; // To store routing points

  LatLng? locationCoordinate;
  String? locationName;

  void geolocatorListener(Position event) {
    locationCoordinate = LatLng(event.latitude, event.longitude);

    // Create a new marker at the current location
    marker = Marker(
      point: locationCoordinate!,
      child: Icon(Icons.location_on, color: Colors.red),
    );

    notifyListeners();
  }

  Future<void> setMapLocation(PickedData pickedData) async {
    locationName = pickedData.address;
    locationCoordinate = LatLng(
      pickedData.latLong.latitude,
      pickedData.latLong.longitude,
    );

    // Create a new marker for the selected location
    if (locationCoordinate != null) {
      marker = Marker(
        point: locationCoordinate!,
        child: Icon(Icons.location_on, color: Colors.red),
      );

      notifyListeners();
    } else {
      print('LocationCoordinate null.');
    }
  }

  //EDIT PROFILE
  String? profileUrl;
  File? profileFile;
  TextEditingController companyNameC = TextEditingController();
  TextEditingController ownerNameC = TextEditingController();
  TextEditingController emailC = TextEditingController();
  // Contact
  TextEditingController phoneC = TextEditingController();
  TextEditingController roleC = TextEditingController();
  TextEditingController salesNameC = TextEditingController();
  TextEditingController salesPhoneC = TextEditingController();
  TextEditingController kbliC = TextEditingController();
  // Alamat
  TextEditingController addressC = TextEditingController();
  TextEditingController provinceC = TextEditingController();
  TextEditingController cityC = TextEditingController();
  TextEditingController locationC = TextEditingController();
  TextEditingController latC = TextEditingController();
  TextEditingController lngC = TextEditingController();
  // Lain-lain
  TextEditingController npwpC = TextEditingController();
  TextEditingController nibC = TextEditingController();
  TextEditingController ktpNumberC = TextEditingController();
  TextEditingController bankTypeC = TextEditingController();
  TextEditingController bankNumberC = TextEditingController();
  TextEditingController bankNameC = TextEditingController();
  XFile? npwpFile;
  TextEditingController npwpFileC = TextEditingController();
  XFile? ktpFile;
  TextEditingController ktpFileC = TextEditingController();
  XFile? bankNumberFile;
  TextEditingController bankNumberFileC = TextEditingController();
  XFile? spSkpFile;
  TextEditingController spSkpFileC = TextEditingController();
  XFile? nibFile;
  TextEditingController nibFileC = TextEditingController();
  XFile? suratPernyataanFile;
  TextEditingController suratPernyataanFileC = TextEditingController();

  File? ttd;

  int? jenisToko;

  KotaModel? kotaModel;
  String? selectedCity;
  String? selectedCityId;

  String? bankAccountId;

  initEditProfile() async {
    final profile = profileSellerModel.data?.profile;
    if (profile != null) {
      profileUrl = profile.photoUrl ?? '';
      companyNameC.text = profile.companyName ?? profile.name ?? '';
      ownerNameC.text = profile.ownerName ?? '';
      emailC.text = profileSellerModel.data?.email ?? '';
      phoneC.text = profile.phone ?? '';
      roleC.text = profileSellerModel.data?.role ?? '';
      salesNameC.text = profile.cpName ?? '';
      salesPhoneC.text = profile.cpPhone ?? '';
      kbliC.text = profile.kbli ?? '';
      addressC.text = profile.detailAddress ?? '';
      if (profile.provinceName != null) {
        provinceC.text = profile.provinceName ?? '';
        selectedProvince = profile.provinceName ?? '';
        selectedProvinceId = profile.provinceId?.toString();
      }
      if (profile.cityName != null) {
        cityC.text = profile.cityName ?? '';
        selectedCity = profile.cityName ?? '';
        selectedCityId = profile.cityId?.toString();
      }
      if (profile.latitude != null && profile.longitude != null) {
        final lat = double.tryParse(profile.latitude!) ?? 0.0;
        final lon = double.tryParse(profile.longitude!) ?? 0.0;
        if (lat != 0.0 && lon != 0.0) {
          locationCoordinate = LatLng(lat, lon);
          mapController.move(locationCoordinate!, 15);
          setMapLocation(PickedData(LatLng(lat, lon), ''));
          latC.text = profile.latitude!;
          lngC.text = profile.longitude!;
        }
      }
      
      if (profile.completeness != null) {
          jenisToko = int.tryParse(profile.completeness!.toString());
      }
    }

    final banks = profileSellerModel.data?.bankAccounts ?? [];
    if (banks.isNotEmpty) {
      final bank = banks.first;
      bankAccountId = bank.id?.toString();
      bankTypeC.text = bank.bankName ?? '';
      bankNumberC.text = bank.rekNum ?? '';
      bankNameC.text = bank.rekNameOf ?? '';
      if (bank.passbookImgUrl != null && bank.passbookImgUrl!.isNotEmpty) {
        bankNumberFileC.text = 'Lihat File Buku Rekening';
      }
    } else {
      bankAccountId = null;
    }

    final legalities = profileSellerModel.data?.legalities ?? [];
    for (var leg in legalities) {
      final type = leg.type?.toUpperCase() ?? '';
      if (type == 'KTP') {
        ktpNumberC.text = leg.legalityNum ?? '';
        if (leg.fileUrl != null && leg.fileUrl!.isNotEmpty) ktpFileC.text = 'Lihat File KTP';
      } else if (type == 'NPWP') {
        npwpC.text = leg.legalityNum ?? '';
        if (leg.fileUrl != null && leg.fileUrl!.isNotEmpty) npwpFileC.text = 'Lihat File NPWP';
      } else if (type == 'NIB') {
        nibC.text = leg.legalityNum ?? '';
        if (leg.fileUrl != null && leg.fileUrl!.isNotEmpty) nibFileC.text = 'Lihat File NIB';
      }
    }
  }

  void resetProfileState() {
    profileSellerModel = ProfileSellerModel();
    sellerDataId = null;
    bankAccountId = null;

    profileUrl = null;
    profileFile = null;
    ktpFile = null;
    npwpFile = null;
    nibFile = null;
    bankNumberFile = null;
    spSkpFile = null;
    suratPernyataanFile = null;
    ttd = null;

    companyNameC.clear();
    ownerNameC.clear();
    emailC.clear();
    phoneC.clear();
    roleC.clear();
    salesNameC.clear();
    salesPhoneC.clear();
    kbliC.clear();
    addressC.clear();
    provinceC.clear();
    cityC.clear();
    locationC.clear();
    latC.clear();
    lngC.clear();
    
    ktpNumberC.clear();
    npwpC.clear();
    nibC.clear();
    bankTypeC.clear();
    bankNumberC.clear();
    bankNameC.clear();
    
    ktpFileC.clear();
    npwpFileC.clear();
    bankNumberFileC.clear();
    spSkpFileC.clear();
    nibFileC.clear();
    suratPernyataanFileC.clear();

    selectedProvince = null;
    selectedProvinceId = null;
    selectedCity = null;
    selectedCityId = null;
    locationCoordinate = null;
    locationName = null;
  }

  Future<void> fetchKota({bool withLoading = false}) async {
    if (withLoading) loading(true);

    // GET /api/cities — response: { data: [{ id, name, province_id }] }
    final response = await get(Constant.BASE_API_FULL + '/cities');

    if (response.statusCode == 201 || response.statusCode == 200) {
      kotaModel = KotaModel.fromJson(jsonDecode(response.body));
      notifyListeners();
      if (withLoading) loading(false);
    } else {
      final decoded = jsonDecode(response.body);
      final message =
          decoded["message"] ??
          decoded["messages"]?["error"] ??
          'Terjadi kesalahan';
      loading(false);
      throw Exception(message);
    }
  }

  ProvinsiModel? provinsiModel;
  String? selectedProvince;
  String? selectedProvinceId;
  Future<void> fetchProvinsi({bool withLoading = false}) async {
    if (withLoading) loading(true);

    // GET /api/provinces — response: { data: [{ id, name }] }
    final response = await get(Constant.BASE_API_FULL + '/provinces');

    if (response.statusCode == 201 || response.statusCode == 200) {
      provinsiModel = ProvinsiModel.fromJson(jsonDecode(response.body));
      notifyListeners();
      if (withLoading) loading(false);
    } else {
      final decoded = jsonDecode(response.body);
      final message =
          decoded["message"] ??
          decoded["messages"]?["error"] ??
          'Terjadi kesalahan';
      loading(false);
      throw Exception(message);
    }
  }

  ProfileSellerModel profileSellerModel = ProfileSellerModel();
  String? sellerDataId;

  Future<void> fetchProfile(BuildContext context, {bool withLoading = true}) async {
    resetProfileState();
    
    if (withLoading) loading(true);
    var prefs = await SharedPreferences.getInstance();
    
    try {
      final url = Constant.BASE_API_FULL + '/seller/v1/seller/profile';
      final response = await get(url);
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body);
        profileSellerModel = ProfileSellerModel.fromJson(decoded);
        
        final profileId = profileSellerModel.data?.profile?.id;
        if (profileId != null) {
            sellerDataId = profileId.toString();
            await prefs.setString('seller_data_id', sellerDataId!);
        }
        
        final completeness = profileSellerModel.data?.profile?.completeness;
        if (completeness != null) {
            await prefs.setString('completeness', completeness.toString());
        }

      } else {
        debugPrint('[DEBUG PROFILE] fetchProfile FAILED with status ${response.statusCode}');
      }
    } catch (e, stacktrace) {
      debugPrint('Error API profile: $e');
    }

    notifyListeners();
    if (withLoading) loading(false);
  }

  Future<void> fetchAddress() async {
    // Deprecated: Address is now fetched together with profile
  }

  // Fetch bank account data for the logged‑in seller
  Future<void> fetchBankAccounts() async {
    // Deprecated: Bank accounts are now fetched together with profile
  }

  // Fetch legalities (KTP, NPWP, NIB) for the logged‑in seller
  Future<void> fetchLegalities() async {
    // Deprecated: Legalities are now fetched together with profile
  }

  Future<void> editProfileSeller(
    BuildContext context, {
    bool withLoading = true,
  }) async {
    if (withLoading) loading(true);

    try {
      // 1. UPDATE PROFILE
      Map<String, String> body = {
        '_method': 'PUT',
        'email': emailC.text.trim(),
        'company_name': companyNameC.text, 
        'name': companyNameC.text,
        'owner_name': ownerNameC.text, 
        'phone': phoneC.text, 
        'cp_name': salesNameC.text, 
        'cp_phone': salesPhoneC.text, 
        'kbli': kbliC.text, 
        'category_id': '1', 
        'completeness': (jenisToko ?? 100).toString(), 
        'detail_address': addressC.text,
        'city_id': selectedCityId ?? '',
        'latitude': latC.text,
        'longitude': lngC.text,
      };

      List<http.MultipartFile> files = [];
      Future<void> addFile(File file, String fieldName) async {
        final bytes = await file.readAsBytes();
        String extension = p.extension(file.path).toLowerCase();
        MediaType mediaType = MediaType('application', 'octet-stream');
        if (extension == '.jpg' || extension == '.jpeg') mediaType = MediaType('image', 'jpeg');
        if (extension == '.png') mediaType = MediaType('image', 'png');
        if (extension == '.pdf') mediaType = MediaType('application', 'pdf');
        
        files.add(http.MultipartFile.fromBytes(fieldName, bytes, filename: basename(file.path), contentType: mediaType));
      }

      if (profileFile != null) await addFile(profileFile!, 'photo');

      final url = Constant.BASE_API_FULL + '/seller/v1/seller/profile';
      final response = await post(url, body: body, files: files);

      if (response.statusCode == 201 || response.statusCode == 200) {
        
        // 2. UPDATE LEGALITIES BATCH (hanya jika ada yang diisi)
        if (ktpNumberC.text.isNotEmpty || npwpC.text.isNotEmpty || nibC.text.isNotEmpty) {
            Map<String, String> legBody = {};
            List<http.MultipartFile> legFiles = [];
            int index = 0;

            Future<void> addLegalityToBatch(int typeId, String num, XFile? file) async {
            legBody['legalities[$index][legality_type_id]'] = typeId.toString();
            legBody['legalities[$index][legality_num]'] = num;
            
            if (file != null) {
                final f = File(file.path);
                final bytes = await f.readAsBytes();
                String extension = p.extension(f.path).toLowerCase();
                MediaType mediaType = MediaType('application', 'octet-stream');
                if (extension == '.jpg' || extension == '.jpeg') mediaType = MediaType('image', 'jpeg');
                if (extension == '.png') mediaType = MediaType('image', 'png');
                if (extension == '.pdf') mediaType = MediaType('application', 'pdf');
                legFiles.add(http.MultipartFile.fromBytes('legalities[$index][file]', bytes, filename: basename(f.path), contentType: mediaType));
            }
            index++;
            }

            if (ktpNumberC.text.isNotEmpty) await addLegalityToBatch(1, ktpNumberC.text, ktpFile);
            if (npwpC.text.isNotEmpty) await addLegalityToBatch(2, npwpC.text, npwpFile);
            if (nibC.text.isNotEmpty) await addLegalityToBatch(3, nibC.text, nibFile);

            if (index > 0) {
            final resLegality = await post(Constant.BASE_API_FULL + '/seller/v1/seller/profile/legality/batch', body: legBody, files: legFiles);
            if (resLegality.statusCode != 200 && resLegality.statusCode != 201) {
                debugPrint('Data Legalitas gagal disimpan (batch): ' + (jsonDecode(resLegality.body)['message'] ?? ''));
            }
            }
        }

        // 3. UPDATE BANK ACCOUNT
        if (bankTypeC.text.isNotEmpty && bankNumberC.text.isNotEmpty) {
            Map<String, String> bankBody = {
            'bank_name': bankTypeC.text,
            'rek_num': bankNumberC.text,
            'rek_name_of': bankNameC.text,
            };
            
            if (bankAccountId != null) {
                bankBody['_method'] = 'PUT'; // spoofing for PUT
            }

            List<http.MultipartFile> bankFiles = [];
            if (bankNumberFile != null) {
            final f = File(bankNumberFile!.path);
            final bytes = await f.readAsBytes();
            String extension = p.extension(f.path).toLowerCase();
            MediaType mediaType = MediaType('application', 'octet-stream');
            if (extension == '.jpg' || extension == '.jpeg') mediaType = MediaType('image', 'jpeg');
            if (extension == '.png') mediaType = MediaType('image', 'png');
            if (extension == '.pdf') mediaType = MediaType('application', 'pdf');
            
            bankFiles.add(http.MultipartFile.fromBytes('passbook_img', bytes, filename: basename(f.path), contentType: mediaType));
            }

            String bankUrl = Constant.BASE_API_FULL + '/seller/v1/seller/profile/bank-account';
            if (bankAccountId != null) {
                bankUrl += '/$bankAccountId';
            }
            
            final resBank = await post(bankUrl, body: bankBody, files: bankFiles);
            if (resBank.statusCode != 200 && resBank.statusCode != 201) {
                debugPrint('Data Rekening gagal disimpan: ' + (jsonDecode(resBank.body)['message'] ?? ''));
            }
        }

        Utils.showSuccess(msg: 'Profil berhasil disimpan');
        notifyListeners();

        // Refresh seluruh data
        await fetchProfile(context, withLoading: false);
        await initEditProfile();
        
        if (withLoading) loading(false);
        CusNav.nPop(context);
      } else {
        final decoded = jsonDecode(response.body);
        final message = decoded["message"] ?? decoded["messages"]?["error"] ?? 'Terjadi kesalahan';
        if (message.toString().contains("Unauthorized")) {
          Utils.showFailed(msg: "Unauthorized");
          Future.delayed(Duration(seconds: 1)).then((value) {
            Navigator.pushReplacementNamed(context, '/login');
          });
        } else {
            Utils.showFailed(msg: message);
        }
      }
    } catch (e) {
      if (withLoading) loading(false);
      Utils.showFailed(msg: e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<String?> fetchTemplateNonPKPSeller({bool withLoading = false}) async {
    Utils.showFailed(msg: 'Fitur belum tersedia (BACKEND API NOT AVAILABLE)');
    return null;
  }

  Future<bool> addTtdNonPkpSeller({bool withLoading = false}) async {
    if (ttd == null) {
      Utils.showFailed(msg: 'Tanda tangan belum dibuat');
      return false;
    }

    if (withLoading) loading(true);

    try {
      final bytes = await ttd!.readAsBytes();

      Map<String, String> body = {'_method': 'PUT'};

      List<http.MultipartFile> files = [
        http.MultipartFile.fromBytes(
          'signature_file',
          bytes,
          filename: 'signature.png',
          contentType: MediaType('image', 'png'),
        ),
      ];

      debugPrint('[DEBUG TTD] endpoint = ${Constant.BASE_API_FULL}/seller/v1/seller/profile');

      final response = await post(
        Constant.BASE_API_FULL + '/seller/v1/seller/profile',
        body: body,
        files: files,
      );

      debugPrint('[DEBUG TTD] response status = ${response.statusCode}');
      debugPrint('[DEBUG TTD] response body = ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        Utils.showSuccess(msg: 'Tanda tangan berhasil disimpan');
        await fetchProfile(
          NavigationService.navigatorKey.currentContext!,
          withLoading: false,
        );
        if (withLoading) loading(false);
        return true;
      } else {
        throw Exception('Gagal menyimpan tanda tangan');
      }
    } catch (e) {
      debugPrint('Error upload signature: $e');
      Utils.showFailed(msg: 'Gagal menyimpan tanda tangan');
      if (withLoading) loading(false);
      return false;
    }
  }
}
