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

    try {
      // GET /api/parent-orders?status={status} — auth via token (tanpa buyer_id)
      // ParentOrderResource: { id, order_number, payment_status, seller_snapshot, shipping, actors_snapshot }
      final parsed = await getRest(
          Constant.BASE_API_FULL + '/parent-orders?status=$status');

      List<DaftarTransaksiBuyerModelData> mappedData = (parsed as List).map((item) {
        return DaftarTransaksiBuyerModelData(
          ID: item['id']?.toString(),
          nomorOrder: item['order_number']?.toString(),
          status: item['payment_status']?.toString(),
          SellerNama: item['seller_snapshot']?['name']?.toString(),
          total: item['shipping']?['cost']?.toString() ?? '0',
          Created: item['created_at']?.toString(),
          detail: [],
        );
      }).toList();

      daftarTransaksi[status - 1] = DaftarTransaksiBuyerModel(
          result: 'success', data: mappedData);
      notifyListeners();
    } catch (e) {
      throw Exception('Gagal memuat transaksi: $e');
    } finally {
      if (withLoading) loading(false);
    }
  }

  Future<void> fetchRiwayatNegoTransaksi(BuildContext context,
      {bool withLoading = true,
      required String tempOrderId,
      required String productId}) async {
    if (withLoading) loading(true);

    // GET /api/negos?product_id={productId} — riwayat nego produk di transaksi
    final response = await get(
        Constant.BASE_API_FULL + '/negos',
        body: {'product_id': productId});

    if (response.statusCode == 201 || response.statusCode == 200) {
      riwayatNegoTransaksiModel =
          RiwayatNegoTransaksiModel.fromJson(jsonDecode(response.body));
      notifyListeners();
      if (withLoading) loading(false);
    } else {
      final decoded = jsonDecode(response.body);
      final message = decoded['message'] ?? decoded['messages']?['error'] ?? 'Terjadi kesalahan';
      loading(false);
      throw Exception(message);
    }
  }

  Future<void> fetchDetailTransaction(
      {bool withLoading = false, required String transaction_id}) async {
    if (withLoading) loading(true);

    try {
      // GET /api/parent-orders/{id} — auth via token (tanpa user_id di query)
      final parsed = await getRest(
          Constant.BASE_API_FULL + '/parent-orders/$transaction_id');

      Map<String, dynamic>? dataItem = parsed;

      if (dataItem != null) {
        var parentOrder = DetailTransaksiBuyerModelDataParentOrderModel(
          ID: dataItem['id']?.toString(),
          nomorOrder: dataItem['order_number']?.toString(),
          status: dataItem['payment_status']?.toString(),
          SellerNama: dataItem['seller_snapshot']?['name']?.toString(),
          total: dataItem['shipping']?['cost']?.toString() ?? '0',
          Created: dataItem['created_at']?.toString(),
        );

        setDetailTransaksi = DetailTransaksiBuyerModel(
          result: 'success',
          data: DetailTransaksiBuyerModelData(
            ParentOrderModel: parentOrder,
            detail: [],
            timeline: [],
            title: 'Detail Order',
          ),
        );
      }
      notifyListeners();
    } catch (e) {
      throw Exception('Gagal memuat detail transaksi: $e');
    } finally {
      if (withLoading) loading(false);
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

    final file = await http.MultipartFile.fromPath(
      'file',
      image.path,
      filename: basename(image.path),
    );

    // POST /api/order-documents — upload dokumen/TTD pesanan
    final response = await post(
        Constant.BASE_API_FULL + '/order-documents',
        body: {
          'parent_order_id': transaction_id,
          'document_type_id': '1', // TTD buyer
        },
        files: [file]);

    if (response.statusCode == 201 || response.statusCode == 200) {
      if (withLoading) loading(false);
      isTtdSuccess = true;
      return true;
    } else {
      isTtdSuccess = false;
      return false;
    }
  }

  int? resetDate;
  String? reason;

  Future<bool> kembalikanTagihan({
    bool withLoading = false,
    required String parentOrderId,
  }) async {
    if (withLoading) loading(true);

    // POST /api/parent-orders/{id}/dispute — kembalikan/dispute tagihan
    final response = await post(
      Constant.BASE_API_FULL + '/parent-orders/$parentOrderId/dispute',
      body: {
        'reset': '$resetDate',
        'desc': reason ?? '',
      },
    );

    if (withLoading) loading(false);
    return response.statusCode == 200 || response.statusCode == 201;
  }

  XFile? ematerai;

  Future<bool> uploadEMaterai({
    bool withLoading = false,
    required String parentOrderId,
  }) async {
    if (withLoading) loading(true);

    var file = await getMultipart('file', File(ematerai!.path));

    // POST /api/materais — upload e-meterai untuk pesanan
    final response = await post(
      Constant.BASE_API_FULL + '/materais',
      body: {'parent_order_id': parentOrderId},
      files: [file],
    );

    if (withLoading) loading(false);
    return response.statusCode == 200 || response.statusCode == 201;
  }
}
