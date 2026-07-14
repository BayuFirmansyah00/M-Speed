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
import 'package:mspeed/common/helper/multipart.dart';
import 'package:mspeed/src/buyer/address/view/custom_map_view.dart';
import 'package:mspeed/src/seller/profil/model/kota_model.dart';
import 'package:mspeed/src/seller/profil/model/profile_seller_model.dart';
import 'package:mspeed/src/seller/profil/model/provinsi_model.dart';
import 'package:mspeed/utils/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
    locationCoordinate =
        LatLng(pickedData.latLong.latitude, pickedData.latLong.longitude);

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

  initEditProfile() {
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
            provinsiModel?.data?.indexWhere((e) => e == data.prov) ?? -1;
        if (index != -1 && provinsiModel?.data?[index]?.nama != null) {
          selectedProvinceId = provinsiModel?.data?[index]?.ID ?? '';
        }
      }
      if (data.kota != null) {
        selectedCity = data.kota ?? '';
        cityC.text = data.kota ?? '';
        var index = kotaModel?.data?.indexWhere((e) => e == data.kota) ?? -1;
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
        jenisToko = int.parse(data.kelengkapanNpwp!);
      }
      ktpNumberC.text = data.noKtp ?? '';
      npwpC.text = data.noNpwp ?? '';
      nibC.text = data.noNib ?? '';
      bankTypeC.text = data.bank ?? '';
      bankNumberC.text = data.noRek ?? '';
      bankNameC.text = data.anRek ?? '';

      // if (data.ktp != null && data.ktp?.trim() != '')
      //   ktpFileC.text = 'Lihat File KTP';
      // if (data.npwp != null && data.npwp?.trim() != '')
      //   npwpFileC.text = 'Lihat File NPWP';
      // if (data.bukuRekening != null && data.bukuRekening?.trim() != '')
      //   bankNumberFileC.text = 'Lihat File Buku Rekening';
      // if (data.spPkp != null && data.spPkp?.trim() != '')
      //   spSkpFileC.text = 'Lihat File SP SKP';
      // if (data.nib != null && data.nib?.trim() != '')
      //   nibFileC.text = 'Lihat File NIB';
    }
  }

  disposeEditProfile() {
    final data = profileSellerModel.data?.getSeller;
    profileUrl = null;
    profileFile = null;
    ktpFile = null;
    npwpFile = null;
    nibFile = null;
    bankNumberFile = null;
    spSkpFile = null;
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
    selectedProvince = null;
    selectedProvinceId = null;
    selectedCity = null;
    cityC.clear();
    selectedCityId = null;
    // locationCoordinate = null;
    if (data != null &&
        data.lattitude != null &&
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
  }

  Future<void> fetchKota({bool withLoading = false}) async {
    if (withLoading) loading(true);

    final response = await get(Constant.BASE_API_FULL + '/cities');

    if (response.statusCode == 201 || response.statusCode == 200) {
      kotaModel = KotaModel.fromJson(jsonDecode(response.body));
      notifyListeners();
      if (withLoading) loading(false);
    } else {
      final message = jsonDecode(response.body)["messages"]["error"];
      loading(false);
      throw Exception(message);
    }
  }

  ProvinsiModel? provinsiModel;
  String? selectedProvince;
  String? selectedProvinceId;
  Future<void> fetchProvinsi({bool withLoading = false}) async {
    if (withLoading) loading(true);

    final response = await get(Constant.BASE_API_FULL + '/provinces');

    if (response.statusCode == 201 || response.statusCode == 200) {
      provinsiModel = ProvinsiModel.fromJson(jsonDecode(response.body));
      notifyListeners();
      if (withLoading) loading(false);
    } else {
      final message = jsonDecode(response.body)["messages"]["error"];
      loading(false);
      throw Exception(message);
    }
  }

  ProfileSellerModel profileSellerModel = ProfileSellerModel();

  Future<void> fetchProfile(BuildContext context,
      {bool withLoading = true}) async {
    if (withLoading) loading(true);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userId = await prefs.getString(Constant.kSetPrefId);

    final response = await get(
      Constant.BASE_API_FULL + '/seller-datas/$userId',
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      profileSellerModel =
          ProfileSellerModel.fromJson(jsonDecode(response.body));
      notifyListeners();
      if (withLoading) loading(false);
    } else {
      final message = jsonDecode(response.body)["messages"]["error"];
      loading(false);
      if (message.toString().contains("Unauthorized")) {
        Utils.showFailed(msg: "Unauthorized");
        Future.delayed(Duration(seconds: 1)).then((value) {
          Navigator.pushReplacementNamed(context, '/login');
        });
      }
      throw Exception(message);
    }
  }

  Future<bool> addTtdNonPkpSeller({bool withLoading = false}) async {
    if (withLoading) loading(true);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString(Constant.kSetPrefId) ?? '1';

    final file = await getMultipart('signature', ttd!);

    final response = await post(
      Constant.BASE_API_FULL + '/ttdnonpkpseller',
      body: {"sellerID": userId},
      files: [file],
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      if (withLoading) loading(false);
      if (jsonDecode(response.body)["status"] == "success") return true;
    } else {
      final message = jsonDecode(response.body)["messages"]["error"];
      loading(false);
      throw Exception(message);
    }
    return false;
  }

  Future<String?> fetchTemplateNonPKPSeller({bool withLoading = true}) async {
    if (withLoading) loading(true);

    final response = await get(
      Constant.BASE_API_FULL + '/templatenonpkpseller',
      body: {
        'nama': companyNameC.text,
        'nama_pemilik': ownerNameC.text,
        'alamat': addressC.text,
        'jabatan': roleC.text,
        'kota': selectedCity ?? '',
      },
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final result = jsonDecode(response.body);
      notifyListeners();
      if (withLoading) loading(false);
      if (result['data'] != null && result['data'] != '') return result['data'];
    } else {
      final message = jsonDecode(response.body)["messages"]["error"];
      loading(false);
      throw Exception(message);
    }
    return null;
  }

  Future<void> editProfileSeller(BuildContext context,
      {bool withLoading = true}) async {
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

    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userId = await prefs.getString(Constant.kSetPrefId);

    Map<String, String> body = {
      '_method': 'PUT', // For Laravel Multipart Update
      'nama': companyNameC.text,
      'nama_pemilik': ownerNameC.text,
      'email': emailC.text,
      'telp': phoneC.text,
      'jabatan': roleC.text,
      'nama_cp': salesNameC.text,
      'telp_cp': salesPhoneC.text,
      'kbli': kbliC.text,
      'alamat': addressC.text,
      'prov': selectedProvince ?? '',
      'prov_id': selectedProvinceId ?? '',
      'kota': selectedCity ?? '',
      'kota_id': selectedCityId ?? '',
      'lokasi': locationName ?? '',
      'lattitude': '${locationCoordinate?.latitude ?? 0}',
      'longitude': '${locationCoordinate?.longitude ?? 0}',
      'kelengkapan_npwp': '${jenisToko ?? 0}',
      'no_ktp': ktpNumberC.text,
      'no_nib': nibC.text,
      'bank': bankTypeC.text,
      'no_rek': bankNumberC.text,
      'an_rek': bankNameC.text,
    };
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

      files.add(http.MultipartFile.fromBytes(
        fieldName,
        bytes,
        filename: basename(file.path),
        contentType: mediaType,
      ));
    }

    if (profileFile != null) await addFile(profileFile!, 'foto');

    if (ktpFile != null) await addFile(File(ktpFile!.path), 'ktp');

    if (npwpFile != null) {
      await addFile(File(npwpFile!.path), 'npwp');
      body.addAll({'no_npwp': npwpC.text});
    }

    if (nibFile != null) await addFile(File(nibFile!.path), 'nib');

    if (bankNumberFile != null)
      await addFile(File(bankNumberFile!.path), 'buku_rekening');

    if (spSkpFile != null) await addFile(File(spSkpFile!.path), 'sp_pkp');

    final response = await post(
      Constant.BASE_API_FULL + '/seller-datas/$userId',
      body: body,
      files: files,
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      // var result = BaseResponse.from(response);
      Utils.showFailed(msg: 'Sukses Edit Profile Seller');
      notifyListeners();
      if (withLoading) loading(false);

      await disposeEditProfile();
      await fetchProfile(context, withLoading: true);
      CusNav.nPop(context);
    } else {
      final message = jsonDecode(response.body)["messages"]["error"];
      loading(false);
      if (message.toString().contains("Unauthorized")) {
        Utils.showFailed(msg: "Unauthorized");
        Future.delayed(Duration(seconds: 1)).then((value) {
          Navigator.pushReplacementNamed(context, '/login');
        });
      }
      throw Exception(message);
    }
  }
}
