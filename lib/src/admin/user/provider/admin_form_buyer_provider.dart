import 'dart:async';
import 'dart:convert';

import 'package:mspeed/common/base/base_controller.dart';
import 'package:mspeed/common/base/base_response.dart';
import 'package:mspeed/common/component/custom_navigator.dart';
import 'package:mspeed/common/helper/constant.dart';
import 'package:mspeed/src/admin/user/model/buyer_admin_model.dart';
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
  final TextEditingController accessC = TextEditingController();
  bool isActive = true;
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
      accessC.text = buyer.userData?.access?.toString() ?? '';
      isActive = buyer.status == 'active' ? true : (buyer.status != null ? false : true);

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
    accessC.clear();
    isActive = true;
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
    if (emailC.text.trim().isEmpty) {
      return Utils.showFailed(msg: 'Email wajib diisi');
    }
    if (buyerId == null && passwordC.text.isEmpty) {
      return Utils.showFailed(msg: 'Password wajib diisi untuk user baru');
    }
    if (firstNameC.text.trim().isEmpty) {
      return Utils.showFailed(msg: 'First Name wajib diisi');
    }
    if (selectedDepartment == null) {
      return Utils.showFailed(msg: 'Departemen wajib dipilih');
    }
    if (selectedCityId == null && cityC.text.isEmpty) {
      return Utils.showFailed(msg: 'Kota wajib dipilih');
    }
    if (alamatC.text.trim().isEmpty) {
      return Utils.showFailed(msg: 'Alamat detail wajib diisi');
    }

    if (withLoading) loading(true);

    String cityId = selectedCityId ?? (cityC.text.isNotEmpty ? cityC.text : '1');

    var param = {
      'email': emailC.text,
      'first_name': firstNameC.text,
      'last_name': lastNameC.text,
      'phone': phoneNumberC.text,
      'active': isActive,
      'access': accessC.text,
      'department_id': selectedDepartment,
      'address_name': 'Utama',
      'address_phone': phoneNumberC.text,
      'city_id': cityId,
      'detail': alamatC.text,
    };

    if (passwordC.text.isNotEmpty) {
      param['password'] = passwordC.text;
    }

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

  Future<void> fetchMasterData() async {
    try {
      final response = await ApiClient().dio.get(
        '/audit/v1/admin/buyers/create',
      );
      if (response.data['status'] == 'success') {
        final data = response.data['data'];
        
        // Populate all master data dropdowns
        allDepartments = List<Map<String, dynamic>>.from(data['departments']);
        provinsiModel = ProvinsiModel.fromJson({'data': data['provinces']});
        kotaModel = KotaModel.fromJson({'data': data['cities']});
        subditAdminModel = SubditAdminModel.fromJson({'data': data['sub_direktorates']});
        
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Failed to fetch buyer master data: $e");
    }
  }


}
