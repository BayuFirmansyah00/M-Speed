import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:latlong2/latlong.dart';
import 'package:mspeed/common/base/base_controller.dart';
import 'package:mspeed/common/base/base_response.dart';
import 'package:mspeed/common/component/custom_navigator.dart';
import 'package:mspeed/core/network/api_client.dart';
import 'package:dio/dio.dart';
import 'package:mspeed/common/helper/constant.dart';
import 'package:mspeed/src/admin/user/model/seller_admin_model.dart';
import 'package:mspeed/src/admin/master/model/subdit_admin_model.dart';
import 'package:mspeed/src/admin/user/view/user_data_admin_view.dart';
import 'package:flutter/material.dart';
import 'package:mspeed/src/buyer/address/view/custom_map_view.dart';
import 'package:mspeed/utils/utils.dart';

class AdminFormSellerProvider extends BaseController with ChangeNotifier {
  List<UserData> userData = [];
  final searchC = TextEditingController();

  final TextEditingController companyNameC = TextEditingController();
  final TextEditingController emailC = TextEditingController();
  final TextEditingController ownerNameC = TextEditingController();
  final TextEditingController cpNameC = TextEditingController();
  final TextEditingController cpPhoneNumberC = TextEditingController();
  final TextEditingController phoneNumberC = TextEditingController();
  final TextEditingController kbliC = TextEditingController();
  final TextEditingController alamatC = TextEditingController();
  final TextEditingController cityC = TextEditingController();
  final TextEditingController latC = TextEditingController();
  final TextEditingController lonC = TextEditingController();
  final TextEditingController npwpC = TextEditingController();
  final TextEditingController ktpC = TextEditingController();
  final TextEditingController bankNameC = TextEditingController();
  final TextEditingController bankNumberC = TextEditingController();
  final TextEditingController bankAccountC = TextEditingController();
  final TextEditingController passwordC = TextEditingController();
  
  String? addressId;

  LatLng? locationCoordinate;
  String? locationName;

  void updateLocation(LatLng newLocation) {
    locationCoordinate = newLocation;
    locationName = "";
    notifyListeners();
  }

  Future<void> setMapLocation(PickedData pickedData) async {
    locationName = pickedData.address;
    locationCoordinate = LatLng(
      pickedData.latLong.latitude,
      pickedData.latLong.longitude,
    );
    notifyListeners();
  }

  void setData(SellerAdminModelData? seller) {
    clearData();
    if (seller != null) {
      emailC.text = seller.email ?? '';
      
      final data = seller.sellerData;
      if (data != null) {
        companyNameC.text = data.companyName ?? '';
        ownerNameC.text = data.ownerName ?? '';
        cpNameC.text = data.cpName ?? '';
        cpPhoneNumberC.text = data.cpPhone ?? '';
        phoneNumberC.text = data.phone ?? '';
        kbliC.text = data.kbli ?? '';
      }

      final address = seller.sellerAddress;
      if (address != null) {
        addressId = address.id?.toString();
        alamatC.text = address.detail ?? '';
        cityC.text = address.cityId?.toString() ?? '';
        
        if (address.latitude != null && address.longitude != null) {
          final lat = double.tryParse(address.latitude!);
          final lon = double.tryParse(address.longitude!);
          if (lat != null && lon != null) {
            locationCoordinate = LatLng(lat, lon);
          }
        }
      }
    }
  }

  void clearData() {
    emailC.clear();
    companyNameC.clear();
    ownerNameC.clear();
    cpNameC.clear();
    cpPhoneNumberC.clear();
    phoneNumberC.clear();
    kbliC.clear();
    alamatC.clear();
    cityC.clear();
    passwordC.clear();
    addressId = null;
    locationCoordinate = null;
    locationName = null;
  }

  Future<void> sendSeller(
    BuildContext context, {
    bool withLoading = false,
    String? sellerId,
  }) async {
    if (withLoading) loading(true);

    final cityIdInt = int.tryParse(cityC.text);
    if (cityIdInt == null) {
      Utils.showFailed(msg: 'Pembuatan Seller gagal. Fitur ini memiliki dependency Backend API Province/City yang belum tersedia untuk mendapatkan City ID secara valid.');
      if (withLoading) loading(false);
      return;
    }
    
    try {
      FormData formData = FormData.fromMap({
        'email': emailC.text,
        'company_name': companyNameC.text,
        'owner_name': ownerNameC.text,
        'cp_name': cpNameC.text,
        'cp_phone': cpPhoneNumberC.text,
        'phone': phoneNumberC.text,
        'kbli': kbliC.text,
        'detail': alamatC.text.isNotEmpty ? alamatC.text : '-',
        'city_id': cityIdInt.toString(),
      });

      // NOTE: category_id tidak dimasukkan ke dalam formData karena di Laravel
      // validationnya bersifat nullable. Tidak ada UI dropdown kategori saat ini, 
      // sehingga pengirimannya di-skip agar tetap aman.

      if (passwordC.text.isNotEmpty) {
        formData.fields.add(MapEntry('password', passwordC.text));
      } else if (sellerId == null) {
        // Create requires password
        formData.fields.add(MapEntry('password', 'password123')); 
      }

      if (locationCoordinate != null) {
        formData.fields.add(MapEntry('latitude', locationCoordinate!.latitude.toString()));
        formData.fields.add(MapEntry('longitude', locationCoordinate!.longitude.toString()));
      }

      if (sellerId != null) {
        formData.fields.add(MapEntry('_method', 'PUT'));
        if (addressId != null) {
          formData.fields.add(MapEntry('address_id', addressId!));
        }
      }

      Response response;
      if (sellerId != null) {
        response = await ApiClient().dio.post(
          '/audit/v1/admin/sellers/$sellerId',
          data: formData,
        );
      } else {
        response = await ApiClient().dio.post(
          '/audit/v1/admin/sellers',
          data: formData,
        );
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        Utils.showSuccess(msg: 'Berhasil menyimpan data seller');
        Navigator.pop(context, true); // Return true to refresh list
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 422) {
        final errors = e.response?.data['errors'];
        String errorMsg = 'Validasi gagal:\n';
        if (errors is Map) {
          errors.forEach((key, value) {
            errorMsg += '- ${(value as List).join(", ")}\n';
          });
        }
        Utils.showFailed(msg: errorMsg);
      } else {
        final message = e.response?.data["message"] ?? e.message;
        Utils.showFailed(msg: message);
      }
    } catch (e) {
      Utils.showFailed(msg: e.toString());
    } finally {
      if (withLoading) loading(false);
    }
  }
}
