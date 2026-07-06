// import 'dart:convert';
// import 'dart:developer';
// import 'dart:io';

// import 'package:chatour/common/base/base_response.dart';
// import 'package:chatour/src/profil/model/bank_model.dart';
// import 'package:chatour/src/profil/model/dokumen_model.dart';
// import 'package:device_info_plus/device_info_plus.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:url_launcher/url_launcher.dart';

// import 'package:http/http.dart' as http;
// import '../../../common/base/base_controller.dart';
// import '../../../common/helper/constant.dart';
// import '../../../common/helper/multipart.dart';
// import '../../../main.dart';
// import '../../../utils/utils.dart';
// import '../../region/model/region_model.dart';
// import '../../region/provider/region_provider.dart';
// import '../model/profile_model.dart';
// import '../model/sosmed_model.dart';

// class ProfileProvider extends BaseController with ChangeNotifier {
//   ProfileModel _profileModel = ProfileModel();

//   ProfileModel get profileModel => this._profileModel;

//   set profileModel(ProfileModel value) => this._profileModel = value;

//   SosmedModel _sosmedModel = SosmedModel();

//   SosmedModel get sosmedModel => this._sosmedModel;

//   set sosmedModel(SosmedModel value) => this._sosmedModel = value;

//   BankModel _bankModel = BankModel();

//   BankModel get bankModel => this._bankModel;

//   set bankModel(BankModel value) => this._bankModel = value;

//   DokumenModel _mouModel = DokumenModel();

//   DokumenModel get mouModel => this._mouModel;

//   set mouModel(DokumenModel value) => this._mouModel = value;

//   DokumenModel _sertifikatModel = DokumenModel();

//   DokumenModel get sertifikatModel => this._sertifikatModel;

//   set sertifikatModel(DokumenModel value) => this._sertifikatModel = value;

//   DokumenModel _idCardModel = DokumenModel();

//   DokumenModel get idCardModel => this._idCardModel;

//   set idCardModel(DokumenModel value) => this._idCardModel = value;

//   DokumenModel _skModel = DokumenModel();

//   DokumenModel get skModel => this._skModel;

//   set skModel(DokumenModel value) => this._skModel = value;

//   TextEditingController NIKC = TextEditingController();
//   TextEditingController namaLengkapC = TextEditingController();
//   TextEditingController emailC = TextEditingController();
//   TextEditingController noTelpC = TextEditingController();
//   TextEditingController tempatLahirC = TextEditingController();
//   TextEditingController tanggalLahirC = TextEditingController();
//   TextEditingController alamatC = TextEditingController();
//   TextEditingController noRekC = TextEditingController();
//   TextEditingController atasNamaRekC = TextEditingController();
//   TextEditingController provinceC = TextEditingController();
//   TextEditingController kotaC = TextEditingController();
//   TextEditingController kecamatanC = TextEditingController();
//   TextEditingController bankC = TextEditingController();

//   String? _provinsiIdV;
//   String? _provinsiNameV;

//   String? get provinsiNameV => this._provinsiNameV;

//   set provinsiNameV(String? value) => this._provinsiNameV = value;

//   String? _kotaIdV;
//   String? _kotaNameV;
//   String? get kotaNameV => this._kotaNameV;

//   set kotaNameV(String? value) => this._kotaNameV = value;
//   String? _kecamatanIdV;
//   String? _kecamatanNameV;
//   String? get kecamatanNameV => this._kecamatanNameV;

//   set kecamatanNameV(String? value) => this._kecamatanNameV = value;
//   String? _desaNameV;
//   String? _desaIdV;
//   String? get desaIdV => this._desaIdV;

//   set desaIdV(String? value) => this._desaIdV = value;
//   String? _bankRekV = "BANK BRI";
//   String? get provinsiIdV => this._provinsiIdV;

//   set provinsiIdV(String? value) => this._provinsiIdV = value;

//   get kotaIdV => this._kotaIdV;

//   set kotaIdV(value) => this._kotaIdV = value;

//   get kecamatanIdV => this._kecamatanIdV;

//   set kecamatanIdV(value) => this._kecamatanIdV = value;

//   get desaNameV => this._desaNameV;

//   set desaNameV(value) => this._desaNameV = value;

//   get bankRekV => this._bankRekV;

//   set bankRekV(value) => this._bankRekV = value;

//   bool _gender = true;

//   get gender => _gender;

//   set gender(value) {
//     this._gender = value;
//     notifyListeners();
//   }

//   GlobalKey<FormState> profileKey = GlobalKey<FormState>();
//   GlobalKey<FormState> contactKey = GlobalKey<FormState>();

//   DateTime? _tanggalLahir;

//   get tanggalLahir => _tanggalLahir;

//   setTanggalLahir(DateTime? date) {
//     _tanggalLahir = date;
//     tanggalLahirC.text =
//         DateFormat("dd MMMM yyyy").format(date ?? DateTime.now()).toString();

//     notifyListeners();
//   }

//   bool isSubAgent = true;
//   bool get getIsSubAgent => this.isSubAgent;

//   set setIsSubAgent(bool isSubAgent) => this.isSubAgent = isSubAgent;

//   File? _profilePic;
//   File? get profilePic => _profilePic;

//   set profilePic(File? profilePic) {
//     _profilePic = profilePic;
//     notifyListeners();
//   }

//   Future<void> goToUrl(String url) async {
//     final Uri uri = Uri.parse(url);
//     if (!await launchUrl(uri)) {
//       throw Exception('Could not launch $url');
//     }
//   }

//   Future<void> fetchProfile({
//     bool withLoading = false,
//     required BuildContext context,
//     List<ProvinceModelData?>? provinceList,
//     List<CityModelData?>? cityList,
//     List<DistrictModelData?>? districtList,
//   }) async {
//     if (withLoading) loading(true);
//     final response = await get(Constant.BASE_API_FULL + '/profile');

//     if (response.statusCode == 200) {
//       final model = ProfileModel.fromJson(jsonDecode(response.body));
//       profileModel = model;
//       if (profileModel.data != null) {
//         loadProfile(
//           context,
//           profileModel.data!,
//           provinceList,
//           cityList,
//           districtList,
//         );
//       }
//       if (withLoading) loading(false);
//     } else {
//       final message = jsonDecode(response.body)["messages"]["error"];
//       loading(false);
//       throw Exception(message);
//     }
//   }

//   Future<void> loadProfile(
//     BuildContext context,
//     ProfileModelData profile,
//     List<ProvinceModelData?>? provinceList,
//     List<CityModelData?>? cityList,
//     List<DistrictModelData?>? districtList,
//   ) async {
//     // loading(true);
//     if (profile != null) {
//       if (profile.province.toString() != "null") {
//         await context
//             .read<RegionProvider>()
//             .fetchCity(profile.provinceId ?? "");
//       }
//       if (profile.city.toString() != "null") {
//         await context
//             .read<RegionProvider>()
//             .fetchDistrict(profile.cityId ?? "");
//       }
//       NIKC.text = profile.nik ?? "";
//       namaLengkapC.text = profile.name ?? "";
//       emailC.text = profile.email ?? "";
//       noTelpC.text = profile.phone ?? "";
//       tempatLahirC.text = profile.birthPlace ?? "";
//       _tanggalLahir = DateFormat('yyyy-MM-dd')
//           .parse(profile.birthDate ?? "${DateTime.now()}");
//       tanggalLahirC.text = DateFormat("dd MMMM yyyy")
//           .format(_tanggalLahir ?? DateTime.now())
//           .toString();
//       gender = profile.gender == 1 ? true : false;
//       alamatC.text = profile.address ?? "";
//       log("PROVINSI : $provinsiNameV");
//       provinceC.text = profile.province ?? "";
//       provinsiNameV = profile.province ?? "";
//       // provinsiIdV = profile.province ?? "";
//       kotaC.text = profile.city ?? "";
//       kotaNameV = profile.city ?? "";
//       // kotaIdV = profile.city ?? "";
//       kecamatanC.text = profile.subdistrict ?? "";
//       kecamatanNameV = profile.city ?? "";
//       // kecamatanIdV = profile.country ?? "";
//       // desaNameV = profile.subdistrict ?? "";
//       bankC.text = profile.bankName ?? "";
//       bankRekV = profile.bankName ?? "";
//       noRekC.text = profile.bankAccount ?? "";
//       atasNamaRekC.text = profile.bankAccountName ?? "";

//       log("PROVINCE LIST : ${provinceList}");
//       log("PROVINCE LIST : ${profile.province}");
//       if ((provinceList ?? []).isNotEmpty) {
//         provinsiNameV = (provinceList)
//             ?.firstWhere((element) => element?.province == profile.province)
//             ?.province;
//       }
//       if ((cityList ?? []).isNotEmpty) {
//         kotaNameV = (cityList)
//             ?.firstWhere((element) => element?.cityName == profile.city)
//             ?.cityName;
//       }
//       if ((districtList ?? []).isNotEmpty) {
//         // langsung ambil subdistrict
//         kecamatanNameV = (districtList)
//             ?.firstWhere(
//                 (element) => element?.districtName == profile.subdistrict)
//             ?.districtName;
//       }
//       loading(false);
//     }
//     notifyListeners();
//   }

//   Future<void> updateProfile() async {
//     loading(true);
//     // if (profileKey.currentState!.validate()) {
//       Map<String, String> param = {
//         'nik': NIKC.text,
//         'name': namaLengkapC.text,
//         'email': emailC.text,
//         'phone': noTelpC.text,
//         'birth_place': tempatLahirC.text,
//         'birth_date': tanggalLahir.toString(),
//         'gender': "${gender ? 1 : 0}",
//         'address': alamatC.text,
//         'province': provinsiNameV.toString(),
//         'city': kotaNameV.toString(),
//         'district': kecamatanNameV.toString(),
//         'sub_district': kecamatanNameV.toString(),
//         'bank_name': bankRekV.toString(),
//         'bank_account': noRekC.text,
//         "account_name": atasNamaRekC.text,
//       };
//       List<http.MultipartFile> files = [];
//       if (profilePic != null) {
//         files.add(await getMultipart('photo', File(profilePic!.path)));
//       } else {
//         // throw 'Harap Isi Foto';
//       }
//       final response = BaseResponse.from(await post(
//         Constant.BASE_API_FULL + '/profile-update',
//         body: {},
//         files: files,
//       ));

//       if (response.success) {
//         // provinsiIdV = null;
//         // provinsiNameV = null;
//         // kotaIdV = null;
//         // kotaNameV = null;
//         // kecamatanIdV = null;
//         // kecamatanNameV = null;
//         // desaIdV = null;
//         // desaNameV = null;
//         // bankRekV = null;
//         // profilePic = null;
//         // clearEditProfile();
//         loading(false);
//       } else {
//         loading(false);
//         throw Exception(response.message);
//       }
//     // } else {
//     //   loading(false);
//     //   throw 'Harap Lengkapi Form';
//     // }
//   }

//   Future<void> clearEditProfile({bool deleteAll = false}) async {
//     NIKC.clear();
//     namaLengkapC.clear();
//     emailC.clear();
//     noTelpC.clear();
//     tempatLahirC.clear();
//     _tanggalLahir = null;
//     tanggalLahirC.clear();
//     gender = true;
//     alamatC.clear();
//     provinsiIdV = null;
//     provinsiNameV = null;
//     kotaIdV = null;
//     kotaNameV = null;
//     kecamatanIdV = null;
//     kecamatanNameV = null;
//     noRekC.clear();
//     atasNamaRekC.clear();
//     bankRekV = null;
//     bankC.clear();
//     profilePic = null;
//   }

//   Future<void> sendContactForm() async {
//     loading(true);
//     if (contactKey.currentState!.validate()) {
//       final androidInfo = await DeviceInfoPlugin().androidInfo;
//       Map<String, String> param = {
//         'name': nameContactC.text,
//         'email': emailContactC.text,
//         'message': messageContactC.text,
//         'phone': phoneContactC.text,
//         'device_type': Platform.operatingSystem,
//         'brand': androidInfo.brand,
//         'os_version': Platform.operatingSystemVersion,
//         'app_version': Platform.version,
//       };
//       List<http.MultipartFile> files = [];
//       if (attachmentFile != null) {
//         files.add(await getMultipart('photo', File(attachmentFile!.path)));
//       }
//       final response = BaseResponse.from(await post(
//           Constant.BASE_API_FULL + '/contact-form',
//           body: param));

//       if (response.success) {
//         nameContactC.clear();
//         emailContactC.clear();
//         messageContactC.clear();
//         phoneContactC.clear();
//         attachmentFile = null;
//         loading(false);
//       } else {
//         loading(false);
//         throw Exception(response.message);
//       }
//     } else {
//       loading(false);
//       throw 'Harap Lengkapi Form';
//     }
//   }

//   Future<void> fetchSosmed() async {
//     // loading(true);
//     final response = await get(Constant.BASE_API_FULL + '/sosmed');

//     if (response.statusCode == 200) {
//       final model = SosmedModel.fromJson(jsonDecode(response.body));
//       sosmedModel = model;
//       notifyListeners();
//       // loading(false);
//     } else {
//       final message = jsonDecode(response.body)["messages"]["error"];
//       loading(false);
//       throw Exception(message);
//     }
//   }

//   Future<void> fetchBank() async {
//     // loading(true);
//     final response = await get(Constant.BASE_API_FULL + '/list-bank');

//     if (response.statusCode == 200) {
//       final model = BankModel.fromJson(jsonDecode(response.body));
//       bankModel = model;
//       notifyListeners();
//       // loading(false);
//     } else {
//       final message = jsonDecode(response.body)["messages"]["error"];
//       loading(false);
//       throw Exception(message);
//     }
//   }

//   Future<void> fetchDokumen({required int type}) async {
//     loading(true);
//     String typeUrl = "";
//     if (type == 1) {
//       typeUrl = "mou";
//     } else if (type == 2) {
//       typeUrl = "certificate";
//     } else if (type == 3) {
//       typeUrl = "ID-card";
//     } else {
//       typeUrl = "sk";
//     }
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     final id = prefs.get(Constant.kSetPrefId);
//     final response =
//         await get(Constant.BASE_API_FULL + '/download-$typeUrl/$id');

//     if (response.statusCode == 200) {
//       final model = DokumenModel.fromJson(jsonDecode(response.body));
//       if (type == 1) {
//         mouModel = model;
//       } else if (type == 2) {
//         sertifikatModel = model;
//       } else if (type == 3) {
//         idCardModel = model;
//       } else {
//         skModel = model;
//       }
//       notifyListeners();
//       loading(false);
//     } else {
//       final message = jsonDecode(response.body)["messages"]["error"];
//       loading(false);
//       throw Exception(message);
//     }
//   }

//   Future<void> sendProfile() async {
//     Utils.showLoading();
//     await Utils.dismissLoading();
//   }

//   /////contact profile

//   TextEditingController nameContactC = TextEditingController();
//   TextEditingController emailContactC = TextEditingController();
//   TextEditingController phoneContactC = TextEditingController();
//   TextEditingController messageContactC = TextEditingController();

//   File? attachmentFile;

//   File? get getAttachmentFile => this.attachmentFile;

//   set setAttachmentFile(File? attachmentFile) =>
//       this.attachmentFile = attachmentFile;
// }
