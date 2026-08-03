import 'dart:async';
import 'dart:convert';

import 'package:mspeed/common/base/base_controller.dart';
import 'package:mspeed/common/base/base_response.dart';
import 'package:mspeed/common/component/custom_navigator.dart';
import 'package:mspeed/common/helper/constant.dart';
import 'package:mspeed/src/admin/home/model/buyer_admin_model.dart';
// import 'package:mspeed/src/admin/home/model/home_admin_model..dart';
import 'package:mspeed/src/admin/master/model/subdit_admin_model.dart';
import 'package:mspeed/src/admin/user/view/user_data_admin_view.dart';
import 'package:flutter/material.dart';
import 'package:mspeed/src/seller/profil/model/kota_model.dart';
import 'package:mspeed/src/seller/profil/model/provinsi_model.dart';
import 'package:mspeed/utils/utils.dart';
import 'package:dio/dio.dart';
import 'package:mspeed/core/network/api_client.dart';

class AdminFormBuyerProvider extends BaseController with ChangeNotifier {
  List<UserData> userData = [];
  final searchC = TextEditingController();

  final TextEditingController firstNameC = TextEditingController();
  final TextEditingController lastNameC = TextEditingController();
  final TextEditingController emailC = TextEditingController();
  final TextEditingController subditC = TextEditingController();
  TextEditingController departmentC = TextEditingController();
  final TextEditingController phoneNumberC = TextEditingController();
  final TextEditingController alamatC = TextEditingController();
  final TextEditingController cityC = TextEditingController();
  final TextEditingController passwordC = TextEditingController();
  String? selectedAddressId;
  String? selectedSubdit;
  String? selectedDepartment;

  // Province & City
  ProvinsiModel? provinsiModel;
  String? selectedProvince;
  String? selectedProvinceId;

  KotaModel? kotaModel;
  String? selectedCity;
  String? selectedCityId;

  List<KotaModelData?> get filteredKotaList {
    if (kotaModel?.data == null) return [];
    if (selectedProvinceId == null) return [];
    return kotaModel!.data!
        .where(
          (e) => e?.provinceId?.toString() == selectedProvinceId?.toString(),
        )
        .toList();
  }

  List<Map<String, dynamic>> allDepartments = [];
  List<Map<String, dynamic>> get filteredDepartments {
    if (selectedSubdit == null) return [];
    return allDepartments
        .where(
          (dept) => dept['sub_direktorate_id'].toString() == selectedSubdit,
        )
        .toList();
  }

  BuyerAdminModel buyerAdminModel = BuyerAdminModel();

  setData(BuyerAdminModelData? buyer) async {
    clearData();
    await fetchSubditAdmin();
    await fetchProvinsi();
    await fetchKota();
    await fetchMasterData();
    final subdit = subditAdminModel.data ?? [];
    if (buyer != null) {
      firstNameC.text = buyer.firstname ?? '';
      lastNameC.text = buyer.lastname ?? '';
      emailC.text = buyer.email ?? '';
      if (subdit.isNotEmpty) {
        selectedSubdit = buyer.subditId ?? '';
        bool exists = subdit.any((e) => e?.id == selectedSubdit);
        if (!exists) selectedSubdit = null;
        subditC.text =
            subdit
                .firstWhere((e) => e?.id == buyer.subditId, orElse: () => null)
                ?.subditName ??
            '';
      }
      phoneNumberC.text = buyer.telp ?? '';
      alamatC.text = buyer.alamat ?? '';

      selectedDepartment = buyer.departmentId;
      bool deptExists = allDepartments.any(
        (e) => e['id'].toString() == selectedDepartment,
      );
      if (!deptExists) selectedDepartment = null;
      if (buyer.addresses != null && buyer.addresses!.isNotEmpty) {
        selectedAddressId = buyer.addresses!.first.id?.toString();

        String? provName = buyer.addresses!.first.province;
        String? cityName = buyer.addresses!.first.city;

        if (provName != null && provinsiModel?.data != null) {
          var matchedProv = provinsiModel!.data!.firstWhere(
            (e) => e?.nama?.toLowerCase() == provName.toLowerCase(),
            orElse: () => null,
          );
          selectedProvinceId = matchedProv?.ID;
        }

        if (cityName != null && kotaModel?.data != null) {
          var matchedCity = kotaModel!.data!.firstWhere(
            (e) => e?.kota?.toLowerCase() == cityName.toLowerCase(),
            orElse: () => null,
          );
          if (matchedCity != null) {
            // Validasi: pastikan kota ini benar-benar ada di dalam provinsi yang terpilih!
            if (matchedCity.provinceId == selectedProvinceId) {
              selectedCityId = matchedCity.ID;
            } else {
              selectedCityId = null;
            }
          } else {
            selectedCityId = null;
          }
        }
      }
      // city mapping is not perfect yet since backend expects city_id
      cityC.text = buyer.kabkota ?? '1';
    }
  }

  clearData() {
    firstNameC.clear();
    lastNameC.clear();
    emailC.clear();
    subditC.clear();
    departmentC.clear();
    allDepartments.clear();
    selectedSubdit = null;
    selectedDepartment = null;
    selectedAddressId = null;
    phoneNumberC.clear();
    passwordC.clear();
    alamatC.clear();
    cityC.clear();
    selectedProvince = null;
    selectedProvinceId = null;
    selectedCity = null;
    selectedCityId = null;
  }

  Future<void> sendBuyer(
    BuildContext context, {
    bool withLoading = false,
    String? buyerId,
  }) async {
    if (withLoading) loading(true);

    // cityC.text should ideally be a mapped city_id from a dropdown.
    // Fallback to '1' if it's empty or cannot be parsed.
    String cityId =
        selectedCityId ?? (cityC.text.isNotEmpty ? cityC.text : '1');

    var param = {
      'email': emailC.text,
      'password': passwordC.text,
      'first_name': firstNameC.text,
      'last_name': lastNameC.text,
      'phone': phoneNumberC.text,
      'active': '1', // default active
      'department_id': selectedDepartment ?? '',
      'address_name': 'Utama',
      'address_phone': phoneNumberC.text,
      'province_id': selectedProvinceId ?? '',
      'city_id': cityId,
      'detail': alamatC.text,
    };

    if (buyerId != null && selectedAddressId != null) {
      param['address_id'] = selectedAddressId!;
    }

    try {
      dynamic response;
      if (buyerId != null) {
        // PUT /api/audit/v1/admin/buyers/{id}
        response = await ApiClient().dio.put(
          '/audit/v1/admin/buyers/$buyerId',
          data: param,
        );
      } else {
        // POST /api/audit/v1/admin/buyers
        response = await ApiClient().dio.post(
          '/audit/v1/admin/buyers',
          data: param,
        );
      }

      if (response.statusCode == 201 || response.statusCode == 200) {
        final message = response.data['message'] ?? 'Berhasil';
        notifyListeners();
        await Utils.showSuccess(msg: message);
        await Future.delayed(Duration(seconds: 2), () {});
        CusNav.nPushReplace(
          context,
          UserDataAdminView(userType: UserDataType.BUYER),
        );

        if (withLoading) loading(false);
      }
    } on DioException catch (e) {
      var decoded = e.response?.data;
      String errorMessage = 'Terjadi kesalahan saat menyimpan data.';

      if (decoded != null && decoded['message'] != null) {
        errorMessage = decoded['message'];
      }
      if (decoded != null && decoded['errors'] != null) {
        final errors = decoded['errors'] as Map<String, dynamic>;
        if (errors.isNotEmpty) {
          errorMessage = errors.values.first[0].toString();
        }
      } else if (decoded != null &&
          decoded['messages'] != null &&
          decoded['messages']['error'] != null) {
        errorMessage = decoded['messages']['error'];
      }

      loading(false);
      Utils.showFailed(msg: errorMessage);
    } catch (e) {
      loading(false);
      Utils.showFailed(msg: 'Terjadi kesalahan: $e');
    }
  }

  Future<void> deleteBuyer(
    BuildContext context, {
    bool withLoading = false,
    String? buyerId,
  }) async {
    if (withLoading) loading(true);

    try {
      // DELETE /api/audit/v1/admin/buyers/{id}
      final response = await ApiClient().dio.delete(
        '/audit/v1/admin/buyers/$buyerId',
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final message = response.data['message'] ?? 'Berhasil';
        notifyListeners();
        await Utils.showSuccess(msg: message);
        await Future.delayed(Duration(seconds: 2), () {});
        CusNav.nPushReplace(
          context,
          UserDataAdminView(userType: UserDataType.BUYER),
        );

        if (withLoading) loading(false);
      }
    } on DioException catch (e) {
      var decoded = e.response?.data;
      String errorMessage = 'Terjadi kesalahan saat menghapus data.';

      if (decoded != null && decoded['message'] != null) {
        errorMessage = decoded['message'];
      }
      if (decoded != null &&
          decoded['messages'] != null &&
          decoded['messages']['error'] != null) {
        errorMessage = decoded['messages']['error'];
      }

      loading(false);
      Utils.showFailed(msg: errorMessage);
    } catch (e) {
      loading(false);
      Utils.showFailed(msg: 'Terjadi kesalahan: $e');
    }
  }

  SubditAdminModel subditAdminModel = SubditAdminModel();
  TextEditingController subditSearchC = TextEditingController();

  Future<void> fetchSubditAdmin({bool withLoading = false}) async {
    if (withLoading) loading(true);
    Map<String, String> param = {};
    if (subditSearchC.text.isNotEmpty)
      param.addAll({'search': subditSearchC.text});

    try {
      final response = await ApiClient().dio.get(
        '/getsubditadmin', // Note: This might still be old API in Laravel, or unmigrated
        queryParameters: param,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        subditAdminModel = SubditAdminModel.fromJson(response.data);
        notifyListeners();

        if (withLoading) loading(false);
      }
    } catch (e) {
      // FALLBACK SEMENTARA: Karena endpoint backend belum tersedia
      subditAdminModel = SubditAdminModel(
        result: 'success',
        data: [
          SubditAdminModelData(
            id: '1',
            subditCode: 'D-101',
            subditName: 'OPERASI',
          ),
          SubditAdminModelData(id: '2', subditCode: 'D-102', subditName: 'SDM'),
          SubditAdminModelData(
            id: '3',
            subditCode: 'D-103',
            subditName: 'SEKRETARIAT PERUSAHAAN',
          ),
          SubditAdminModelData(
            id: '4',
            subditCode: 'D-104',
            subditName: 'PEMASARAN',
          ),
        ],
      );
      notifyListeners();

      if (withLoading) loading(false);
    }
  }

  Future<void> fetchKota({bool withLoading = false}) async {
    if (withLoading) loading(true);
    try {
      final response = await ApiClient().dio.get('/cities?per_page=-1');
      if (response.statusCode == 201 || response.statusCode == 200) {
        kotaModel = KotaModel.fromJson(response.data);
        if (kotaModel?.data != null) {
          int count = kotaModel!.data!.length;
          // Utils.showSuccess(msg: 'Berhasil load $count kota');
        } else {
          Utils.showFailed(msg: 'Data kota kosong (null)');
        }
      } else {
        Utils.showFailed(msg: 'Gagal mengambil data kota dari API');
      }
    } catch (e) {
      Utils.showFailed(msg: 'Error Load Kota: $e');
    }
    notifyListeners();
    if (withLoading) loading(false);
  }

  Future<void> fetchMasterData() async {
    try {
      final response = await ApiClient().dio.get(
        '/audit/v1/admin/buyers/create',
      );
      if (response.data['status'] == 'success') {
        final data = response.data['data'];
        allDepartments = List<Map<String, dynamic>>.from(data['departments']);
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Failed to fetch buyer master data: $e");
    }
  }

  Future<void> fetchProvinsi({bool withLoading = false}) async {
    if (withLoading) loading(true);
    try {
      final response = await ApiClient().dio.get('/provinces');
      if (response.statusCode == 201 || response.statusCode == 200) {
        provinsiModel = ProvinsiModel.fromJson(response.data);
      } else {
        Utils.showFailed(msg: 'Gagal mengambil data provinsi dari API');
      }
    } catch (e) {
      Utils.showFailed(msg: 'Error Load Provinsi: $e');
    }
    notifyListeners();
    if (withLoading) loading(false);
  }
}
