import 'dart:convert';
import 'dart:io';

import 'package:mspeed/common/base/base_controller.dart';
import 'package:mspeed/common/helper/constant.dart';
import 'package:flutter/material.dart';
import 'package:mspeed/src/penerima/pesanan/model/detail_pesanan_penerima_model.dart';
import 'package:mspeed/src/penerima/pesanan/model/pesanan_penerima_model.dart';
import 'package:mspeed/src/seller/pesanan/model/detail_pesanan_seller_model.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class PenerimaPesananProvider extends BaseController with ChangeNotifier {
  PesananPenerimaModel pesananPenerimaModel = PesananPenerimaModel();
  final searchC = TextEditingController();

  Future<void> fetchTransaction({
    bool withLoading = false,
    String search = '',
  }) async {
    if (withLoading) loading(true);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString(Constant.kSetPrefId) ?? '1';
    Map<String, String> param = {};
    // if (searchC.text.isNotEmpty)
    //   param.addAll({'search': searchC.text});
    param.addAll({'penerima_id': userId});

    try {
      final parsed = await getRest(
        Constant.BASE_API_FULL + '/parent-orders?penerima_id=$userId',
      );
      
      // Usually Laravel returns a collection inside "data", but the old code expected "result" and "data".
      // Let's assume the old model handles {"data": [...]} via fromJson if adapted.
      pesananPenerimaModel = PesananPenerimaModel.fromJson(parsed);
      notifyListeners();
    } catch (e) {
      throw Exception(e);
    } finally {
      if (withLoading) loading(false);
    }
  }

  DetailPesananPenerimaModel detailPesanan = DetailPesananPenerimaModel();

  Future<void> fetchDetailTransaction({
    bool withLoading = false,
    required String transaction_id,
  }) async {
    if (withLoading) loading(true);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString(Constant.kSetPrefId) ?? '1';
    // userId = "124";

    try {
      final parsed = await getRest(
        Constant.BASE_API_FULL + '/parent-orders/$transaction_id?penerima_id=$userId',
      );
      
      detailPesanan = DetailPesananPenerimaModel.fromJson(parsed);
      notifyListeners();
    } catch (e) {
      throw Exception(e);
    } finally {
      if (withLoading) loading(false);
    }
  }

  Future<String?> fetchSuratTtd({
    bool withLoading = false,
    required String transaction_id,
  }) async {
    if (withLoading) loading(true);
    final response = await get(
      Constant.BASE_API_FULL + '/cetaksuratpesananbuyer',
      body: {"parent_order_id": transaction_id},
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      if (withLoading) loading(false);

      if (jsonDecode(response.body)["result"] == "success") {
        return jsonDecode(response.body)["data"];
      } else {
        return null;
      }
      // return model;
    } else {
      final message = jsonDecode(response.body)["messages"]["error"];
      loading(false);
      return null;
      throw Exception(message);
    }
  }

  bool? _isTtdSuccess = null;

  bool? get isTtdSuccess => _isTtdSuccess;

  set isTtdSuccess(bool? value) {
    _isTtdSuccess = value;
  }

  Future<bool> addTtdSuratJalan({
    bool withLoading = false,
    required String transaction_id,
    required String nomor_order,
    required File image,
  }) async {
    if (withLoading) loading(true);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString(Constant.kSetPrefId) ?? '1';
    // userId = "124";

    final file = await http.MultipartFile.fromPath(
      'signature',
      image.path,
      filename: basename(image.path), // Use the file name of the image
    );

    final response = await post(
      Constant.BASE_API_FULL + '/addsuratjalanpenerima',
      body: {
        "nomor_order": nomor_order,
        "parent_order_id": transaction_id,
        "penerima_id": userId,
      },
      files: [file],
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      if (withLoading) loading(false);
      if (jsonDecode(response.body)["status"] == "success") {
        isTtdSuccess = true;
        return true;
      } else {
        isTtdSuccess = false;
        return false;
      }
    } else {
      isTtdSuccess = false;
      return false;
      final message = jsonDecode(response.body)["messages"]["error"];
      loading(false);
      throw Exception(message);
    }
  }

  DetailPesananSellerModel detailPesananNew = DetailPesananSellerModel();

  bool showMore = false;
  Future<void> fetchDetailPesananNew({
    bool withLoading = false,
    String seller_id = '196',
    required String parent_id,
  }) async {
    if (withLoading) loading(true);

    final response = await get(
      Constant.BASE_API_FULL + '/getdetailpesananseller',
      body: {"seller_id": seller_id, "parent_order_id": parent_id},
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      detailPesananNew = DetailPesananSellerModel.fromJson(
        jsonDecode(response.body),
      );
      notifyListeners();

      if (withLoading) loading(false);
    } else {
      final message = jsonDecode(response.body)["messages"]["error"];
      loading(false);
      throw Exception(message);
    }
  }

  Future<String?> getPdf({
    bool withLoading = false,
    required String parent_id,
  }) async {
    if (withLoading) loading(true);
    final response = await get(
      Constant.BASE_API_FULL + '/cetaksuratjalanpenerima',
      body: {"parent_order_id": parent_id},
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      if (withLoading) loading(false);

      if (jsonDecode(response.body)["result"] == "success") {
        return jsonDecode(response.body)["data"];
      } else {
        return null;
      }
    } else {
      final message = jsonDecode(response.body)["messages"]["error"];
      loading(false);
      return null;
    }
  }
}
