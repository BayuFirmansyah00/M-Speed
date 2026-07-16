import 'dart:convert';
import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:mspeed/common/base/base_controller.dart';
import 'package:mspeed/common/helper/constant.dart';
import 'package:mspeed/common/helper/multipart.dart';
import 'package:mspeed/src/buyer/transaction/model/daftar_transaksi_buyer_model.dart';
import 'package:mspeed/src/buyer/transaction/model/detail_tansaction_buyer_model.dart';
import 'package:mspeed/src/buyer/transaction/model/riwayat_nego_transaksi_model.dart';
import 'package:mspeed/src/buyer/transaction/model/transaction_model.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class TransactionProvider extends BaseController with ChangeNotifier {
  String isSubAgent = "agen";

  String get getIsSubAgent => this.isSubAgent;
  TransactionModel transactionModel = TransactionModel();

  TransactionModel get getTransactionModel => this.transactionModel;

  set setTransactionModel(TransactionModel transactionModel) =>
      this.transactionModel = transactionModel;

  RiwayatNegoTransaksiModel riwayatNegoTransaksiModel =
      RiwayatNegoTransaksiModel();

  RiwayatNegoTransaksiModel get getRiwayatNegoTransaksiModel =>
      this.riwayatNegoTransaksiModel;

  set setRiwayatNegoTransaksiModel(
          RiwayatNegoTransaksiModel riwayatNegoTransaksiModel) =>
      this.riwayatNegoTransaksiModel = riwayatNegoTransaksiModel;

  DetailTransaksiBuyerModel _detailTransaksi = DetailTransaksiBuyerModel();

  DetailTransaksiBuyerModel get getDetailTransaksi => _detailTransaksi;

  set setDetailTransaksi(DetailTransaksiBuyerModel value) {
    _detailTransaksi = value;
  }

  set setIsSubAgent(String isSubAgent) => this.isSubAgent = isSubAgent;

  List<DaftarTransaksiBuyerModel> daftarTransaksi = [
    DaftarTransaksiBuyerModel(),
    DaftarTransaksiBuyerModel(),
    DaftarTransaksiBuyerModel(),
    DaftarTransaksiBuyerModel(),
    DaftarTransaksiBuyerModel(),
    DaftarTransaksiBuyerModel(),
  ];

  bool showMore = false;

  Future<void> fetchTransaction(
      {bool withLoading = false, required int status}) async {
    if (withLoading) loading(true);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setIsSubAgent = prefs.getString(Constant.kSetPrefId) ?? "1";
    String userId = prefs.getString(Constant.kSetPrefId) ?? '1';

    final response = await get(
        Constant.BASE_API_FULL + '/getdaftartransksibuyer',
        body: {"buyer_id": userId, "status": status.toString()});

    if (response.statusCode == 201 || response.statusCode == 200) {
      // SharedPreferences prefs = await SharedPreferences.getInstance();
      final model =
          DaftarTransaksiBuyerModel.fromJson(jsonDecode(response.body));

      daftarTransaksi[status - 1] = model;
      if (withLoading) loading(false);
      notifyListeners(); // return model;
    } else {
      final message = jsonDecode(response.body)["messages"]["error"];
      loading(false);
      throw Exception(message);
    }
  }

  Future<void> fetchRiwayatNegoTransaksi(BuildContext context,
      {bool withLoading = true,
      required String tempOrderId,
      required String productId}) async {
    if (withLoading) loading(true);

    // final prefs = await SharedPreferences.getInstance();
    // String? userId = await prefs.getString(Constant.kSetPrefId) ?? "";

    final response = await get(
        Constant.BASE_API_FULL + '/getriwayatnegotransaksibuyer',
        body: {'TempOrderID': tempOrderId, 'produk_id': productId});

    if (response.statusCode == 201 || response.statusCode == 200) {
      riwayatNegoTransaksiModel =
          RiwayatNegoTransaksiModel.fromJson(jsonDecode(response.body));

      // chatBuyerModel.data?.seller?.forEach((element) {
      //   element?.Buat = formatDate(element.Buat ?? "");
      // });

      notifyListeners();
      if (withLoading) loading(false);
    } else {
      final message = jsonDecode(response.body)["messages"]["error"];
      loading(false);
      // if (message.toString().contains("Unauthorized")) {
      //   Utils.showFailed(msg: "Unauthorized");
      //   Future.delayed(Duration(seconds: 1)).then((value) {
      //     Navigator.pushReplacementNamed(context, '/login');
      //   });
      // }
      throw Exception(message);
    }
  }

  Future<void> fetchDetailTransaction(
      {bool withLoading = false, required String transaction_id}) async {
    if (withLoading) loading(true);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setIsSubAgent = prefs.getString(Constant.kSetPrefId) ?? "1";
    String userId = prefs.getString(Constant.kSetPrefId) ?? '1';
    // userId = "148";

    final response = await get(
        Constant.BASE_API_FULL + '/getdetailtransksibuyer',
        body: {"user_id": userId, "parent_id": transaction_id});

    if (response.statusCode == 201 || response.statusCode == 200) {
      // SharedPreferences prefs = await SharedPreferences.getInstance();
      setDetailTransaksi =
          DetailTransaksiBuyerModel.fromJson(jsonDecode(response.body));
      notifyListeners();

      if (withLoading) loading(false);
      // return model;
    } else {
      final message = jsonDecode(response.body)["messages"]["error"];
      loading(false);
      throw Exception(message);
    }
  }

  Future<String?> fetchSuratTtd(
      {bool withLoading = false, required String transaction_id}) async {
    if (withLoading) loading(true);
    final response = await get(
        Constant.BASE_API_FULL + '/cetaksuratpesananbuyer',
        body: {"parent_order_id": transaction_id});

    if (response.statusCode == 201 || response.statusCode == 200) {
      if (withLoading) loading(false);

      if (jsonDecode(response.body)["result"] == "success") {
        return jsonDecode(response.body)["data"];
      } else {
        return null;
      }
      // return model;
    } else {
      // final message = jsonDecode(response.body)["messages"]["error"];
      loading(false);
      return null;
      // throw Exception(message);
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
      // final message = jsonDecode(response.body)["messages"]["error"];
      // loading(false);
      // throw Exception(message);
    }
  }

  int? resetDate;
  String? reason;

  Future<bool> kembalikanTagihan({
    bool withLoading = false,
    required String parentOrderId,
  }) async {
    if (withLoading) loading(true);
    final prefs = await SharedPreferences.getInstance();
    String? buyerId = await prefs.getString(Constant.kSetPrefId) ?? "";

    final response = await post(
      Constant.BASE_API_FULL + '/kembalikantagihan',
      body: {
        "buyer_id": buyerId,
        "parent_order_id": parentOrderId,
        "reset": '$resetDate',
        "desc": reason,
      },
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      if (withLoading) loading(false);
      if (jsonDecode(response.body)["status"] == "success") {
        return true;
      } else {
        return false;
      }
      // notifyListeners();

      // return model;
    } else {
      return false;
      // final message = jsonDecode(response.body)["messages"]["error"];
      // loading(false);
      // throw Exception(message);
    }
  }

  XFile? ematerai;

  Future<bool> uploadEMaterai({
    bool withLoading = false,
    required String parentOrderId,
  }) async {
    if (withLoading) loading(true);
    final prefs = await SharedPreferences.getInstance();
    String? buyerId = await prefs.getString(Constant.kSetPrefId) ?? "";

    var file = await getMultipart('ematerai', File(ematerai!.path));
    final response = await post(
      Constant.BASE_API_FULL + '/uploademateraibuyer',
      body: {
        "buyer_id": buyerId,
        "parent_order_id": parentOrderId,
      },
      files: [file],
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      if (withLoading) loading(false);
      if (jsonDecode(response.body)["status"] == "success") {
        return true;
      } else {
        return false;
      }
      // notifyListeners();

      // return model;
    } else {
      return false;
      // final message = jsonDecode(response.body)["messages"]["error"];
      // loading(false);
      // throw Exception(message);
    }
  }
}
