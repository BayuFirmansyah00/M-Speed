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

  initEditProfile() async {
    debugPrint('[TRACE PROVIDER INSTANCE] providerHash = ${identityHashCode(this)}');
    debugPrint('[TRACE INIT BEFORE]');
    debugPrint('KTP = ${ktpNumberC.text}');
    debugPrint('NPWP = ${npwpC.text}');
    debugPrint('NIB = ${nibC.text}');
    debugPrint('Bank = ${bankTypeC.text}');
    debugPrint('No Rek = ${bankNumberC.text}');
    debugPrint('Atas Nama = ${bankNameC.text}');
    
    debugPrint('[DEBUG PROFILE] initEditProfile START');
    final data = profileSellerModel.data?.getSeller;
    if (data != null) {
      profileUrl = profileSellerModel.data?.fotoUrl ?? '';
      companyNameC.text = data.nama ?? '';
      ownerNameC.text = data.namaPemilik ?? '';
      emailC.text = data.email ?? '';
      phoneC.text = data.telp ?? '';
      roleC.text = data.jabatan ?? '';
      salesNameC.text = data.namaCp ?? '';
      salesPhoneC.text = data.telpCp ?? '';
      kbliC.text = data.kbli ?? '';
      addressC.text = data.alamat ?? '';
      if (data.prov != null) {
        provinceC.text = data.prov ?? '';
        selectedProvince = data.prov ?? '';
        var index =
            provinsiModel?.data?.indexWhere(
              (e) => e?.nama?.toLowerCase() == data.prov?.toLowerCase(),
            ) ??
            -1;
        if (index != -1 && provinsiModel?.data?[index]?.nama != null) {
          selectedProvinceId = provinsiModel?.data?[index]?.ID ?? '';
        }
      }
      if (data.kota != null) {
        selectedCity = data.kota ?? '';
        cityC.text = data.kota ?? '';
        var index =
            kotaModel?.data?.indexWhere(
              (e) => e?.kota?.toLowerCase() == data.kota?.toLowerCase(),
            ) ??
            -1;
        if (index != -1 && kotaModel?.data?[index]?.kota != null) {
          selectedCityId = kotaModel?.data?[index]?.ID ?? '';
        }
      }
      if (data.lattitude != null &&
          data.lattitude?.trim() != '' &&
          data.longitude != null &&
          data.longitude?.trim() != '') {
        final lat = double.parse(data.lattitude!);
        final lon = double.parse(data.longitude!);
        locationCoordinate = LatLng(lat, lon);
        mapController.move(locationCoordinate!, 15);
        setMapLocation(PickedData(LatLng(lat, lon), ''));
        latC.text = data.lattitude ?? '';
        lngC.text = data.longitude ?? '';
      }

      if (data.kelengkapanNpwp != null && data.kelengkapanNpwp?.trim() != '') {
        jenisToko = int.tryParse(data.kelengkapanNpwp!);
      }
      // KTP, NPWP, NIB, dan Bank tidak di-fallback ke string kosong dari data profile utama.
      // Data-data tersebut diisi secara asinkron dari endpoint masing-masing (fetchLegalities & fetchBankAccounts).
    }
    
    debugPrint('[TRACE INIT AFTER]');
    debugPrint('KTP = ${ktpNumberC.text}');
    debugPrint('NPWP = ${npwpC.text}');
    debugPrint('NIB = ${nibC.text}');
    debugPrint('Bank = ${bankTypeC.text}');
    debugPrint('No Rek = ${bankNumberC.text}');
    debugPrint('Atas Nama = ${bankNameC.text}');
    
    debugPrint('\n================================');
    debugPrint('[REOPEN MODEL]');
    debugPrint('company_name = ${profileSellerModel.data?.getSeller?.nama}');
    debugPrint('owner_name = ${profileSellerModel.data?.getSeller?.namaPemilik}');
    debugPrint('kbli = ${profileSellerModel.data?.getSeller?.kbli}');
    debugPrint('ktp = ${profileSellerModel.data?.getSeller?.noKtp}');
    debugPrint('npwp = ${profileSellerModel.data?.getSeller?.noNpwp}');
    debugPrint('nib = ${profileSellerModel.data?.getSeller?.noNib}');
    debugPrint('bank = ${profileSellerModel.data?.getSeller?.bank}');
    debugPrint('rek_num = ${profileSellerModel.data?.getSeller?.noRek}');
    debugPrint('rek_name_of = ${profileSellerModel.data?.getSeller?.anRek}');
    debugPrint('================================\n');

    debugPrint('\n================================');
    debugPrint('[REOPEN CONTROLLER]');
    debugPrint('companyNameC = ${companyNameC.text}');
    debugPrint('ownerNameC = ${ownerNameC.text}');
    debugPrint('kbliC = ${kbliC.text}');
    debugPrint('ktpNumberC = ${ktpNumberC.text}');
    debugPrint('npwpC = ${npwpC.text}');
    debugPrint('nibC = ${nibC.text}');
    debugPrint('bankTypeC = ${bankTypeC.text}');
    debugPrint('bankNumberC = ${bankNumberC.text}');
    debugPrint('bankNameC = ${bankNameC.text}');
    debugPrint('================================\n');
    debugPrint('city = $selectedCity');
    debugPrint('address = ${profileSellerModel.data?.getSeller?.alamat}');
    debugPrint('================================\n');

    debugPrint('\n================================');
    debugPrint('[CONTROLLER]');
    debugPrint('companyNameC = ${companyNameC.text}');
    debugPrint('ownerNameC = ${ownerNameC.text}');
    debugPrint('kbliC = ${kbliC.text}');
    debugPrint('ktpNumberC = ${ktpNumberC.text}');
    debugPrint('npwpC = ${npwpC.text}');
    debugPrint('nibC = ${nibC.text}');
    debugPrint('bankTypeC = ${bankTypeC.text}');
    debugPrint('bankNumberC = ${bankNumberC.text}');
    debugPrint('bankNameC = ${bankNameC.text}');
    debugPrint('provinceC = ${provinceC.text}');
    debugPrint('cityC = ${cityC.text}');
    debugPrint('addressC = ${addressC.text}');
    debugPrint('================================\n');
  }

  void resetProfileState() {
    profileSellerModel = ProfileSellerModel();
    sellerDataId = null;

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
    debugPrint('[TRACE PROVIDER INSTANCE] providerHash = ${identityHashCode(this)}');
    resetProfileState();
    
    if (withLoading) loading(true);
    var prefs = await SharedPreferences.getInstance();
    var userId = await prefs.getString('id');
    
    final storedSellerDataId = await prefs.getString('seller_data_id');
    
    if (storedSellerDataId == null || storedSellerDataId.isEmpty) {
      debugPrint('[DEBUG PROFILE] seller_data_id TIDAK DITEMUKAN');
      this.sellerDataId = null;
      if (withLoading) loading(false);
      return;
    }
    
    this.sellerDataId = storedSellerDataId;
    final token = await getToken();

    debugPrint('\n================================');
    debugPrint('[EDIT PROFILE DEBUG]');
    debugPrint('sellerDataId = ${this.sellerDataId}');
    debugPrint('token exists = ${token != null}');
    debugPrint('userId = $userId');
    debugPrint('================================\n');

    try {
      final url = Constant.BASE_API_FULL + '/seller-datas/${this.sellerDataId}';
      
      debugPrint('\n================================');
      debugPrint('[REOPEN DEBUG]');
      debugPrint('sellerDataId from SharedPreferences = $storedSellerDataId');
      debugPrint('class sellerDataId = ${this.sellerDataId}');
      debugPrint('userId = $userId');
      debugPrint('GET seller-datas URL = $url');
      
      final response = await get(
        url,
        // headers: {'Authorization': 'Bearer $token'},
      );
      
      debugPrint('STATUS = ${response.statusCode}');
      debugPrint('BODY = ${response.body}');
      debugPrint('================================\n');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body);
        final sellerData = decoded['data'] ?? {};
        
        debugPrint('\n================================');
        debugPrint('[REOPEN PROFILE]');
        debugPrint('STATUS = ${response.statusCode}');
        debugPrint('BODY = ${response.body}');
        debugPrint('company_name = ${sellerData['company_name']}');
        debugPrint('owner_name = ${sellerData['owner_name']}');
        debugPrint('kbli = ${sellerData['kbli']}');
        debugPrint('signature_file = ${sellerData['signature_file']}');
        debugPrint('================================\n');

        // Map response to model
        String buildUrl(dynamic path) {
          if (path == null) return "";
          String url = path.toString();
          if (url.trim().isEmpty) return "";
          if (url.startsWith('http')) return url;
          if (!url.startsWith('/')) url = '/' + url;
          return Constant.BASE_API_FULL.replaceAll('/api', '/storage') + url;
        }

        profileSellerModel = ProfileSellerModel.fromJson({
          "data": {
            "getSeller": {
              "id": sellerData['id']?.toString() ?? userId,
              "name": sellerData['company_name'],
              "owner_name": sellerData['owner_name'],
              "email": sellerData['user']?['email'],
              "phone": sellerData['phone'],
              "nama_cp": sellerData['cp_name'] ?? '',
              "telp_cp": sellerData['cp_phone'] ?? '',
              "kbli": sellerData['kbli'] ?? '',
              "alamat": '', // Diisi terpisah lewat fetchAddress
              "lattitude": sellerData['latitude']?.toString() ?? '',
              "longitude": sellerData['longitude']?.toString() ?? '',
              "no_ktp": sellerData['ktp_number'] ?? sellerData['no_ktp'] ?? "",
              "no_npwp":
                  sellerData['npwp_number'] ?? sellerData['no_npwp'] ?? "",
              "no_nib": sellerData['nib_number'] ?? sellerData['no_nib'] ?? "",
              "no_rek":
                  sellerData['bank_account_number'] ??
                  sellerData['no_rek'] ??
                  "",
              "an_rek":
                  sellerData['bank_account_name'] ?? sellerData['an_rek'] ?? "",
              "bank": sellerData['bank_name'] ?? sellerData['bank'] ?? "",
              "jabatan":
                  sellerData['role_position'] ?? sellerData['jabatan'] ?? "",
              "kelengkapan_npwp": sellerData['completeness']?.toString() ?? "0",
              "category": sellerData['category'] != null
                  ? {"nama": sellerData['category']['name']}
                  : {"nama": "Umum"},
            },
            "fotoUrl": buildUrl(sellerData['photo']),
            "signatureUrl": buildUrl(sellerData['signature_file']),
            "ktpUrl": "",
            "npwpUrl": "",
            "nibUrl": "",
            "bukuRekeningUrl": "",
            "spPkpUrl": "",
          },
        });

        await prefs.setString(
          'completeness',
          sellerData['completeness']?.toString() ?? "0",
        );
      } else {
        debugPrint('[DEBUG PROFILE] fetchProfile FAILED with status ${response.statusCode}');
      }
    } catch (e, stacktrace) {
      debugPrint('Error API profile: $e');
      debugPrint('Stacktrace: $stacktrace');
    }

    await fetchBankAccounts();
    await fetchLegalities();
    await fetchAddress();

    debugPrint('[TRACE 2 BEFORE INIT]');
    debugPrint('ktpNumberC.text = ${ktpNumberC.text}');
    debugPrint('npwpC.text = ${npwpC.text}');
    debugPrint('nibC.text = ${nibC.text}');
    debugPrint('bankTypeC.text = ${bankTypeC.text}');
    debugPrint('bankNumberC.text = ${bankNumberC.text}');
    debugPrint('bankNameC.text = ${bankNameC.text}');

    notifyListeners();
    if (withLoading) loading(false);
  }

  Future<void> fetchAddress() async {
    try {
      final url = Constant.BASE_API_FULL + '/seller-addresses';
      final addrResponse = await get(url);
      
      debugPrint('\n================================');
      debugPrint('[ADDRESS API]');
      debugPrint('URL = $url');
      debugPrint('STATUS = ${addrResponse.statusCode}');
      debugPrint('BODY = ${addrResponse.body}');
      debugPrint('================================\n');

      if (addrResponse.statusCode == 200 || addrResponse.statusCode == 201) {
        final addrDecoded = jsonDecode(addrResponse.body);
        if (addrDecoded['data'] != null && addrDecoded['data'] is List) {
          final addresses = addrDecoded['data'] as List;
          Map<String, dynamic>? addr;
          for (var a in addresses) {
            if (a is Map && a['seller']?['id']?.toString() == this.sellerDataId?.toString()) {
              addr = a as Map<String, dynamic>;
              break;
            }
          }
          if (addr != null && profileSellerModel.data?.getSeller != null) {
            profileSellerModel.data!.getSeller!.alamat = addr['detail'] ?? '';
          }
        }
      }
    } catch (e) {
      debugPrint('Error fetch address: $e');
    }
  }

  // Fetch bank account data for the logged‑in seller
  Future<void> fetchBankAccounts() async {
    debugPrint('[TRACE PROVIDER INSTANCE] providerHash = ${identityHashCode(this)}');
    try {
      final token = await getToken();
      final url = Constant.BASE_API_FULL + '/seller-bank-accounts';
      final response = await get(url);
      
      debugPrint('\n================================');
      debugPrint('[REOPEN BANK]');
      debugPrint('STATUS = ${response.statusCode}');
      debugPrint('BODY = ${response.body}');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body);
        debugPrint('[FETCH BANKS] Decoded data: ${decoded['data']}');
        if (decoded['data'] != null &&
            decoded['data'] is List &&
            decoded['data'].isNotEmpty) {
          final account = decoded['data'][0];
          
          bankTypeC.text = account['bank_name']?.toString() ?? '';
          bankNumberC.text = account['rek_num']?.toString() ?? '';
          bankNameC.text = account['rek_name_of']?.toString() ?? '';
          
          debugPrint('[TRACE 1 API BANK]');
          debugPrint('sellerDataId = ${this.sellerDataId}');
          debugPrint('bank_name = ${account['bank_name']}');
          debugPrint('rek_num = ${account['rek_num']}');
          debugPrint('rek_name_of = ${account['rek_name_of']}');
          
          debugPrint('[DEBUG BANK] bank_name = ${account['bank_name']}');
          debugPrint('[DEBUG BANK] rek_num = ${account['rek_num']}');
          debugPrint('[DEBUG BANK] rek_name_of = ${account['rek_name_of']}');
          debugPrint('[DEBUG BANK] bankTypeC = ${bankTypeC.text}');
          debugPrint('[DEBUG BANK] bankNumberC = ${bankNumberC.text}');
          debugPrint('[DEBUG BANK] bankNameC = ${bankNameC.text}');
          
          final bukuRekeningUrl = account['bank_passbook_img']?.toString();
          if (bukuRekeningUrl != null && bukuRekeningUrl.isNotEmpty) {
            bankNumberFileC.text = 'Lihat File Buku Rekening';
          }
      } else {
          debugPrint('================================\n');
      }
      }
    } catch (e) {
      debugPrint('Error fetching bank accounts: $e');
    }
  }

  // Fetch legalities (KTP, NPWP, NIB) for the logged‑in seller
  Future<void> fetchLegalities() async {
    debugPrint('[TRACE PROVIDER INSTANCE] providerHash = ${identityHashCode(this)}');
      debugPrint('[TRACE PROVIDER INSTANCE] providerHash = ${identityHashCode(this)}');
    try {
      final token = await getToken();
      final url = Constant.BASE_API_FULL + '/seller-legalities';
      final response = await get(url);
      
      debugPrint('\n================================');
      debugPrint('[REOPEN LEGALITY]');
      debugPrint('STATUS = ${response.statusCode}');
      debugPrint('BODY = ${response.body}');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body);
        debugPrint('[FETCH LEGALITIES] Decoded data: ${decoded['data']}');
        if (decoded['data'] != null && decoded['data'] is List) {
          for (var item in decoded['data']) {
            final typeId = item['legality_type']?['id'] ?? item['legality_type_id'];
            final number = item['legality_num']?.toString() ?? '';
            final url = item['file_path']?.toString() ?? '';
            
            debugPrint('[TRACE 1 API LEGALITY]');
            debugPrint('sellerDataId = ${this.sellerDataId}');
            debugPrint('typeId = $typeId');
            debugPrint('legality_num = $number');
            debugPrint('file_path = $url');
            
            debugPrint('[FETCH LEGALITIES] typeId: $typeId, number: $number, url: $url');
            
            switch (typeId) {
              case 1:
                ktpNumberC.text = number;
                profileSellerModel.data?.ktpUrl = url;
                debugPrint('[FETCH LEGALITIES] KTP Set: $number');
                break;
              case 2:
                npwpC.text = number;
                profileSellerModel.data?.npwpUrl = url;
                debugPrint('[FETCH LEGALITIES] NPWP Set: $number');
                break;
              case 3:
                nibC.text = number;
                profileSellerModel.data?.nibUrl = url;
                debugPrint('[FETCH LEGALITIES] NIB Set: $number');
                break;
              case 4:
                // SP PKP not displayed currently
                break;
            }
          }
          
          final ktpUrl = profileSellerModel.data?.ktpUrl;
          if (ktpUrl != null && ktpUrl.isNotEmpty) {
            ktpFileC.text = 'Lihat File KTP';
          }
          final npwpUrl = profileSellerModel.data?.npwpUrl;
          if (npwpUrl != null && npwpUrl.isNotEmpty) {
            npwpFileC.text = 'Lihat File NPWP';
          }
          final nibUrl = profileSellerModel.data?.nibUrl;
          if (nibUrl != null && nibUrl.isNotEmpty) {
            nibFileC.text = 'Lihat File NIB';
          }
          debugPrint('[DEBUG LEGALITY] KTP = ${ktpNumberC.text}');
          debugPrint('[DEBUG LEGALITY] NPWP = ${npwpC.text}');
          debugPrint('[DEBUG LEGALITY] NIB = ${nibC.text}');
        } else {
          debugPrint('[FETCH LEGALITIES] No data or not a list');
        }
      } else {
        debugPrint('[FETCH LEGALITIES] Error status: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('[FETCH LEGALITIES] Exception: $e');
    }
  }

  Future<void> editProfileSeller(
    BuildContext context, {
    bool withLoading = true,
  }) async {
    if (profileFile == null) {
      loading(false);
      Utils.showFailed(msg: 'Foto Profile Harus Diisi');
      return;
    }
    if (ktpFile == null) {
      loading(false);
      Utils.showFailed(msg: 'File KTP Harus Diisi');
      return;
    }
    if (bankNumberFile == null) {
      loading(false);
      Utils.showFailed(msg: 'File Buku Rekening Harus Diisi');
      return;
    }
    if (withLoading) loading(true);

    try {
      // Body sesuai UpdateSellerDataRequest Laravel
      // Fields yang diterima: name, owner_name, phone, cp_name, cp_phone, kbli,
      //                       category_id, dan file fields: foto, ktp, npwp, nib,
      //                       buku_rekening, sp_pkp
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('id');

      Map<String, String> body = {
        '_method': 'PUT', // Laravel Method Spoofing untuk multipart
        'company_name': companyNameC.text, 
        'name': companyNameC.text, 
        'owner_name': ownerNameC.text, 
        'phone': phoneC.text, 
        'cp_name': salesNameC.text, 
        'cp_phone': salesPhoneC.text, 
        'kbli': kbliC.text, 
        'category_id': '1', 
        'completeness': '100', 
      };

      if (this.sellerDataId == null) {
        if (userId == null) {
          if (withLoading) loading(false);
          Utils.showFailed(msg: 'User ID tidak ditemukan, silakan login ulang.');
          return;
        }
        body.remove('_method'); // Remove spoofing because it's POST
        body['user_id'] = userId;
      }

      List<http.MultipartFile> files = [];
      Future<void> addFile(File file, String fieldName) async {
        final bytes = await file.readAsBytes();
        String extension = p.extension(file.path).toLowerCase();

        // Menentukan contentType berdasarkan ekstensi
        MediaType mediaType;
        switch (extension) {
          case '.jpg':
          case '.jpeg':
            mediaType = MediaType('image', 'jpeg');
            break;
          case '.png':
            mediaType = MediaType('image', 'png');
            break;
          default:
            throw Exception('Tipe file tidak didukung: $extension');
        }

        files.add(
          http.MultipartFile.fromBytes(
            fieldName,
            bytes,
            filename: basename(file.path),
            contentType: mediaType,
          ),
        );
      }

      if (profileFile != null) await addFile(profileFile!, 'foto');
      // KTP, NPWP, NIB, Bank, SP_PKP akan diproses melalui endpoint terpisah setelah request profil sukses.

      final isNewProfile = this.sellerDataId == null;
      final url = isNewProfile
          ? Constant.BASE_API_FULL + '/seller-datas'
          : Constant.BASE_API_FULL + '/seller-datas/${this.sellerDataId}';

      debugPrint('[DEBUG SAVE] sellerDataId = ${this.sellerDataId}');
      debugPrint('[DEBUG SAVE] endpoint = $url');
      debugPrint('[DEBUG SAVE] method = ${isNewProfile ? 'POST' : 'PUT (spoofed)'}');
      debugPrint('[DEBUG SAVE] request fields = $body');

      final response = await post(
        url,
        body: body,
        files: files,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        debugPrint('[DEBUG SAVE] SELLER DATA STATUS = ${response.statusCode}');
        debugPrint('[DEBUG SAVE] SELLER DATA BODY = ${response.body}');

        if (isNewProfile) {
          final decoded = jsonDecode(response.body);
          final newId = decoded['data']?['id']?.toString();
          if (newId != null) {
            this.sellerDataId = newId;
            await prefs.setString('seller_data_id', newId);
            debugPrint('[DEBUG SAVE] NEW sellerDataId saved: $newId');
          } else {
             throw Exception('Gagal mendapatkan ID Seller Data baru dari response API.');
          }
        }

        // Fungsi helper untuk Legalitas
        Future<void> sendLegality(int typeId, String num, XFile? file) async {
          Map<String, String> legBody = {
            'legality_type_id': typeId.toString(),
            'legality_num': num,
          };
          List<http.MultipartFile> legFiles = [];
          if (file != null) {
            final f = File(file.path);
            final bytes = await f.readAsBytes();
            String extension = p.extension(f.path).toLowerCase();
            MediaType mediaType = MediaType('application', 'octet-stream');
            if (extension == '.jpg' || extension == '.jpeg') mediaType = MediaType('image', 'jpeg');
            if (extension == '.png') mediaType = MediaType('image', 'png');
            if (extension == '.pdf') mediaType = MediaType('application', 'pdf');
            
            legFiles.add(http.MultipartFile.fromBytes('file_path', bytes, filename: basename(f.path), contentType: mediaType));
          }
          final res = await post(Constant.BASE_API_FULL + '/seller-legalities', body: legBody, files: legFiles);
          
          String typeName = typeId == 1 ? "KTP" : (typeId == 2 ? "NPWP" : "NIB");
          debugPrint('[DEBUG SAVE] $typeName STATUS = ${res.statusCode}');
          debugPrint('[DEBUG SAVE] $typeName BODY = ${res.body}');
          
          if (res.statusCode != 200 && res.statusCode != 201) {
            throw Exception('Data $typeName gagal disimpan: ' + (jsonDecode(res.body)['message'] ?? ''));
          }
        }

        // Upload KTP, NPWP, NIB
        if (ktpNumberC.text.isNotEmpty) await sendLegality(1, ktpNumberC.text, ktpFile);
        if (npwpC.text.isNotEmpty) await sendLegality(2, npwpC.text, npwpFile);
        if (nibC.text.isNotEmpty) await sendLegality(3, nibC.text, nibFile);

        // Upload Bank
        Map<String, String> bankBody = {
          'bank_name': bankTypeC.text,
          'rek_num': bankNumberC.text,
          'rek_name_of': bankNameC.text,
        };
        List<http.MultipartFile> bankFiles = [];
        if (bankNumberFile != null) {
          final f = File(bankNumberFile!.path);
          final bytes = await f.readAsBytes();
          String extension = p.extension(f.path).toLowerCase();
          MediaType mediaType = MediaType('application', 'octet-stream');
          if (extension == '.jpg' || extension == '.jpeg') mediaType = MediaType('image', 'jpeg');
          if (extension == '.png') mediaType = MediaType('image', 'png');
          if (extension == '.pdf') mediaType = MediaType('application', 'pdf');
          
          bankFiles.add(http.MultipartFile.fromBytes('bank_passbook_img', bytes, filename: basename(f.path), contentType: mediaType));
        }
        final resBank = await post(Constant.BASE_API_FULL + '/seller-bank-accounts', body: bankBody, files: bankFiles);
        debugPrint('[DEBUG SAVE] BANK STATUS = ${resBank.statusCode}');
        debugPrint('[DEBUG SAVE] BANK BODY = ${resBank.body}');
        if (resBank.statusCode != 200 && resBank.statusCode != 201) {
          throw Exception('Data Rekening gagal disimpan: ' + (jsonDecode(resBank.body)['message'] ?? ''));
        }

        // Update completeness dari response API (jika tersedia)
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        String newCompleteness = '0';
        // prefs already initialized
        if (responseData['data'] != null && responseData['data']['completeness'] != null) {
          newCompleteness = responseData['data']['completeness'].toString();
        } else {
          newCompleteness = '100';
        }
        await prefs.setString('completeness', newCompleteness);

        Utils.showSuccess(msg: 'Profil berhasil disimpan');
        notifyListeners();

        // Refresh seluruh data
        await fetchProfile(context, withLoading: false);
        await fetchBankAccounts();
        await fetchLegalities();
        await fetchAddress();
        await initEditProfile();
        
        if (withLoading) loading(false);
        CusNav.nPop(context);
      } else {
        final decoded = jsonDecode(response.body);
        final message =
            decoded["message"] ??
            decoded["messages"]?["error"] ??
            'Terjadi kesalahan';
        if (message.toString().contains("Unauthorized")) {
          Utils.showFailed(msg: "Unauthorized");
          Future.delayed(Duration(seconds: 1)).then((value) {
            Navigator.pushReplacementNamed(context, '/login');
          });
        }
        throw Exception(message);
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
    if (this.sellerDataId == null) {
      Utils.showFailed(msg: 'ID Profil Seller tidak ditemukan');
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

      debugPrint('[DEBUG TTD] sellerDataId = ${this.sellerDataId}');
      debugPrint('[DEBUG TTD] endpoint = ${Constant.BASE_API_FULL}/seller-datas/${this.sellerDataId}');

      final response = await post(
        Constant.BASE_API_FULL + '/seller-datas/${this.sellerDataId}',
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
