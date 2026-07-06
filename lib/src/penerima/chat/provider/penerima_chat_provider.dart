import 'dart:convert';
import 'dart:io';

import 'package:mspeed/common/base/base_controller.dart';
import 'package:mspeed/common/helper/constant.dart';
import 'package:flutter/material.dart';
import 'package:mspeed/src/penerima/chat/model/riwayat_komplain_penerima_model.dart';
import 'package:mspeed/src/seller/pesanan/model/detail_pesanan_seller_model.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class PenerimaChatProvider extends BaseController with ChangeNotifier {
  RiwayatKomplainPenerimaModel riwayat = RiwayatKomplainPenerimaModel();

  Future<void> fetchRiwayat(
      {bool withLoading = false, required String order_id}) async {
    if (withLoading) loading(true);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString(Constant.kSetPrefId) ?? '1';
    // userId = "124";

    final response = await get(
        Constant.BASE_API_FULL + '/getriwayatkomplainpenerima',
        body: {"penerima_id": userId, "order_id": order_id.toString()});

    if (response.statusCode == 201 || response.statusCode == 200) {
      riwayat =
          RiwayatKomplainPenerimaModel.fromJson(jsonDecode(response.body));
      notifyListeners();

      if (withLoading) loading(false);
      // return model;
    } else {
      final message = jsonDecode(response.body)["messages"]["error"];
      loading(false);
      throw Exception(message);
    }
  }

  Future<void> sendComplain(
      {bool withLoading = false,
      required String keterangan,
      required String seller_id,
      required String nomor_order,
      File? file}) async {
    if (withLoading) loading(true);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString(Constant.kSetPrefId) ?? '1';
    // userId = "124";

    final http.MultipartFile? _file = (file == null)
        ? null
        : await http.MultipartFile.fromPath(
            'attachment',
            file.path,
            filename: basename(file.path),
          );

    final response =
        await post(Constant.BASE_API_FULL + '/komplainbarangpenerima',
            body: {
              "order_id": nomor_order,
              "keterangan": keterangan,
              "seller_id": seller_id,
              "penerima_id": userId
            },
            files: _file == null ? null : [_file]);

    if (response.statusCode == 201 || response.statusCode == 200) {
      notifyListeners();
      await fetchRiwayat(order_id: nomor_order, withLoading: true);
      if (withLoading) loading(false);
    } else {
      final message = jsonDecode(response.body)["messages"]["error"];
      loading(false);
      throw Exception(message);
    }
  }

  bool? _isTtdSuccess = null;

  bool? get isTtdSuccess => _isTtdSuccess;

  set isTtdSuccess(bool? value) {
    _isTtdSuccess = value;
  }

  Future<bool> addTtdPemesanan(
      {bool withLoading = false,
      required String transaction_id,
      required String nomor_order,
      required File image}) async {
    if (withLoading) loading(true);
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // setIsSubAgent = prefs.getString(Constant.kSetPrefId) ?? "1";
    // String userId = prefs.getString(Constant.kSetPrefId) ?? '1';
    // userId = "148";

    final file = await http.MultipartFile.fromPath(
      'signature',
      image.path,
      filename: basename(image.path), // Use the file name of the image
    );

    final response = await post(
        Constant.BASE_API_FULL + '/addsuratpesananbuyer',
        body: {"nomor_order": nomor_order, "parent_order_id": transaction_id},
        files: [file]);

    if (response.statusCode == 201 || response.statusCode == 200) {
      // SharedPreferences prefs = await SharedPreferences.getInstance();
      // detailTransaksi =
      //     DetailTransaksiBuyerModel.fromJson(jsonDecode(response.body));
      if (withLoading) loading(false);
      if (jsonDecode(response.body)["status"] == "success") {
        isTtdSuccess = true;
        return true;
      } else {
        isTtdSuccess = false;
        return false;
      }
      // notifyListeners();

      // return model;
    } else {
      isTtdSuccess = false;
      return false;
      final message = jsonDecode(response.body)["messages"]["error"];
      loading(false);
      throw Exception(message);
    }
  }

  DetailPesananSellerModel detailPesananNew = DetailPesananSellerModel();

  Future<void> fetchDetailPesananNew(
      {bool withLoading = false,
      String seller_id = '196',
      required String parent_id}) async {
    if (withLoading) loading(true);

    final response = await get(
        Constant.BASE_API_FULL + '/getdetailpesananseller',
        body: {"seller_id": seller_id, "parent_order_id": parent_id});

    if (response.statusCode == 201 || response.statusCode == 200) {
      detailPesananNew =
          DetailPesananSellerModel.fromJson(jsonDecode(response.body));
      notifyListeners();

      if (withLoading) loading(false);
    } else {
      final message = jsonDecode(response.body)["messages"]["error"];
      loading(false);
      throw Exception(message);
    }
  }
}
