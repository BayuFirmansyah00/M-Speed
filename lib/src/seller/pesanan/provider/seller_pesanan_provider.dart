import 'dart:convert';
import 'dart:io';

import 'package:mspeed/common/base/base_controller.dart';
import 'package:mspeed/common/helper/constant.dart';
import 'package:flutter/material.dart';
import 'package:mspeed/common/helper/multipart.dart';
import 'package:mspeed/src/seller/pesanan/model/detail_pesanan_seller_model.dart';
import 'package:mspeed/src/seller/pesanan/model/pesanan_seller_model.dart';
import 'package:mspeed/src/seller/pesanan/view/pesanan_buat_surat_view.dart';
import 'package:mspeed/src/seller/pesanan/view/upload_lampiran_view.dart';
import 'package:path/path.dart';
import 'package:http/http.dart' as http;
import 'package:mspeed/common/helper/session_helper.dart';
import 'package:mspeed/utils/utils.dart';

class SellerPesananProvider extends BaseController with ChangeNotifier {
  var pesananSellerModel = PesananSellerModel();
  int currentPage = 1;
  Future<void> fetchListPesanan({
    bool withLoading = false,
    bool isLoadMore = false,
  }) async {
    if (!isLoadMore) {
      pesananSellerModel = PesananSellerModel();
      currentPage = 1;
    } else {
      currentPage++;
    }

    if (withLoading) loading(true);
    
    try {
      throw Exception('Fitur ini belum tersedia pada API backend.');
    } catch (e) {
      if (isLoadMore) currentPage--;
      Utils.showFailed(msg: e.toString());
    } finally {
      if (withLoading) loading(false);
    }
  }

  var detailPesananSellerModel = DetailPesananSellerModel();

  void reset() {
    detailPesananSellerModel = DetailPesananSellerModel();
    notifyListeners();
  }

  bool showMore = false;

  Future<void> fetchDetailPesanan({
    bool withLoading = false,
    required String parent_id,
  }) async {
    if (withLoading) loading(true);

    try {
      throw Exception('Fitur ini belum tersedia pada API backend.');
    } catch (e) {
      // throw Exception(e);
    } finally {
      if (withLoading) loading(false);
    }
  }

  String? rejectOrderReason;

  Future<bool> fetchActionPesananBaru({
    bool withLoading = false,
    required String parent_id,
    required bool terima,
  }) async {
    if (withLoading) loading(true);
    Utils.showFailed(msg: 'Fitur ini belum tersedia pada API backend.');
    if (withLoading) loading(false);
    return false;
  }

  Future<bool> kirimBarang({
    bool withLoading = false,
    required String parent_id,
  }) async {
    if (withLoading) loading(true);
    Utils.showFailed(msg: 'Fitur ini belum tersedia pada API backend.');
    if (withLoading) loading(false);
    return false;
  }

  bool? _isTtdSuccess = null;

  bool? get isTtdSuccess => _isTtdSuccess;

  set isTtdSuccess(bool? value) {
    _isTtdSuccess = value;
  }

  Future<bool> addTtdPemesanan({
    bool withLoading = false,
    required String transaction_id,
    required String nomor_order,
    required SuratType suratType,
    required File image,
  }) async {
    if (withLoading) loading(true);
    Utils.showFailed(msg: 'Fitur ini belum tersedia pada API backend.');
    if (withLoading) loading(false);
    isTtdSuccess = false;
    return false;
  }

  Future<bool> uploadLampiran({
    bool withLoading = false,
    required String transaction_id,
    required File faktur,
    required File eNota,
    required List<OtherFile> lainnya,
  }) async {
    if (withLoading) loading(true);
    Utils.showFailed(msg: 'Fitur ini belum tersedia pada API backend.');
    if (withLoading) loading(false);
    return false;
  }

  Future<bool> buatSuratJalan({
    bool withLoading = false,
    required String transaction_id,
    required List<ProductCatatan> productCatatan,
    required String catatan,
  }) async {
    if (withLoading) loading(true);
    Utils.showFailed(msg: 'Fitur ini belum tersedia pada API backend.');
    if (withLoading) loading(false);
    return false;
  }

  Future<String?> getPdf({
    bool withLoading = false,
    required PDF_LINK pdf,
    required String transaction_id,
  }) async {
    if (withLoading) loading(true);
    Utils.showFailed(msg: 'Fitur ini belum tersedia pada API backend.');
    if (withLoading) loading(false);
    return null;
  }
}

enum PDF_LINK {
  SURAT_PESANAN("cetaksuratpesananseller"),
  SURAT_JALAN("cetaksuratjalanseller");

  final String pdf;

  const PDF_LINK(this.pdf);
}

class ProductCatatan {
  final String id;
  String? ket;

  ProductCatatan({required this.id, this.ket});
}
