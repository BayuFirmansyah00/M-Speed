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
  final TextEditingController subditC = TextEditingController();
  final TextEditingController cpPhoneNumberC = TextEditingController();
  final TextEditingController phoneNumberC = TextEditingController();
  final TextEditingController kbliC = TextEditingController();
  final TextEditingController alamatC = TextEditingController();
  final TextEditingController cityC = TextEditingController();
  final TextEditingController locationC = TextEditingController();
  final TextEditingController latC = TextEditingController();
  final TextEditingController lonC = TextEditingController();
  final TextEditingController npwpC = TextEditingController();
  final TextEditingController ktpC = TextEditingController();
  final TextEditingController bankNameC = TextEditingController();
  final TextEditingController bankNumberC = TextEditingController();
  final TextEditingController bankAccountC = TextEditingController();
  final TextEditingController npwpFileC = TextEditingController();
  final TextEditingController ktpFileC = TextEditingController();
  final TextEditingController bankBookC = TextEditingController();
  final TextEditingController spSkpC = TextEditingController();
  final TextEditingController passwordC = TextEditingController();

  File? npwpFile;
  File? ktpFile;
  File? bankBookFile;
  File? spSkpFile;

  LatLng? locationCoordinate;
  String? locationName;

  // Update the method signature to remove GoogleMapController
  void updateLocation(LatLng newLocation) {
    locationCoordinate = newLocation;
    locationName = ""; // Use reverse geocoding if necessary
    notifyListeners();
  }

  Future<void> setMapLocation(PickedData pickedData) async {
    locationName = pickedData.address;
    locationCoordinate = LatLng(
      pickedData.latLong.latitude,
      pickedData.latLong.longitude,
    );

    // Notify listeners to update UI
    notifyListeners();
  }

  SellerAdminModel sellerAdminModel = SellerAdminModel();

  void setData(SellerAdminModelData? seller) async {
    clearData();
    await fetchSubditAdmin();
    if (seller != null) {
      companyNameC.text = seller.nama ?? '';
      emailC.text = seller.email ?? '';
      ownerNameC.text = seller.namaPemilik ?? '';
      cpNameC.text = seller.namaCp ?? '';
      cpPhoneNumberC.text = seller.telpCp ?? '';
      phoneNumberC.text = seller.telp ?? '';
      kbliC.text = seller.kbli ?? '';
      alamatC.text = seller.alamat ?? '';
      cityC.text = seller.kota ?? '';
      latC.text = seller.lattitude ?? '';
      lonC.text = seller.longitude ?? '';
      locationCoordinate = LatLng(
        double.parse(seller.lattitude ?? '0'),
        double.parse(seller.longitude ?? '0'),
      );
      npwpC.text = seller.npwp ?? '';
      ktpC.text = seller.ktp ?? '';
      bankNameC.text = seller.bank ?? '';
      bankNumberC.text = seller.noRek ?? '';
      bankAccountC.text = seller.anRek ?? '';
    }
  }

  void clearData() {
    emailC.clear();
    subditC.clear();
    phoneNumberC.clear();
    alamatC.clear();
    cityC.clear();
    passwordC.clear();
  }

  Future<void> sendSeller(
    BuildContext context, {
    bool withLoading = false,
    String? sellerId,
  }) async {
    if (withLoading) loading(true);
    var param = {
      'email': emailC.text,
      'first_name': ownerNameC.text.isNotEmpty
          ? ownerNameC.text
          : companyNameC.text,
      'last_name': cpNameC.text,
      'phone': phoneNumberC.text.isNotEmpty
          ? phoneNumberC.text
          : cpPhoneNumberC.text,
    };
    if (passwordC.text.isNotEmpty) {
      param['password'] = passwordC.text;
    }

    try {
      // API endpoint CRUD Seller untuk Admin TIDAK TERSEDIA DI LARAVEL
      throw Exception('BACKEND API NOT AVAILABLE');
    } catch (e) {
      Utils.showFailed(msg: e.toString());
    } finally {
      if (withLoading) loading(false);
    }
  }

  Future<void> deleteSeller(
    BuildContext context, {
    bool withLoading = false,
    String? sellerId,
  }) async {
    if (sellerId == null) return;
    if (withLoading) loading(true);

    try {
      // API endpoint CRUD Seller untuk Admin TIDAK TERSEDIA DI LARAVEL
      throw Exception('BACKEND API NOT AVAILABLE');
    } catch (e) {
      Utils.showFailed(msg: e.toString());
    } finally {
      if (withLoading) loading(false);
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
        '/audit/v1/admin/sub-direktorates',
        queryParameters: param,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        subditAdminModel = SubditAdminModel.fromJson(response.data);
        notifyListeners();
        if (withLoading) loading(false);
      }
    } on DioException catch (e) {
      final message = e.response?.data["message"] ?? e.message;
      loading(false);
      debugPrint('Error fetchSubditAdmin: $message');
    } catch (e) {
      loading(false);
      debugPrint('Error fetchSubditAdmin: $e');
    }
  }
}
