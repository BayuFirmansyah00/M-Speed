import 'dart:convert';
import 'dart:io';

import 'package:mspeed/common/base/base_controller.dart';
import 'package:mspeed/common/helper/constant.dart';
import 'package:flutter/material.dart';
import 'package:mspeed/common/helper/multipart.dart';
import 'package:mspeed/src/seller/pesanan/model/detail_pesanan_seller_model.dart';
import 'package:mspeed/src/seller/pesanan/model/pesanan_seller_model.dart';
import 'package:mspeed/src/seller/pesanan/view/pesanan_buat_surat_view.dart';
import 'package:path/path.dart';
import 'package:http/http.dart' as http;
import 'package:mspeed/common/helper/session_helper.dart';
import 'package:mspeed/utils/utils.dart';

class SellerPesananProvider extends BaseController with ChangeNotifier {
  var pesananSellerModel = SellerOrderModel();
  var detailPesananSellerModel = DetailPesananSellerModel(); // Legacy for Buyer

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  int currentPage = 1;
  Future<void> fetchListPesanan({
    bool withLoading = false,
    bool isLoadMore = false,
  }) async {
    if (!isLoadMore) {
      pesananSellerModel = SellerOrderModel();
      currentPage = 1;
    } else {
      currentPage++;
    }

    if (withLoading) {
      _isLoading = true;
      notifyListeners();
    }

    try {
      final response = await get(
        Constant.BASE_API_FULL +
            '${Constant.epSellerOrders}?page=$currentPage&per_page=${Constant.maxPaginationPerPage}',
      );
      final parsed = jsonDecode(response.body);
      if (response.statusCode == 200) {
        if (!isLoadMore) {
          pesananSellerModel = SellerOrderModel.fromJson(parsed);
        } else {
          var moreData = SellerOrderModel.fromJson(parsed);
          pesananSellerModel.data?.addAll(moreData.data ?? []);
          pesananSellerModel.meta = moreData.meta;
        }
      } else {
        throw Exception(parsed['message'] ?? 'Failed to load orders');
      }
    } catch (e) {
      if (isLoadMore) currentPage--;
      Utils.showFailed(msg: e.toString());
    } finally {
      if (withLoading) {
        _isLoading = false;
      }
      notifyListeners();
    }
  }

  var detailPesanan = SellerOrderData();

  void reset() {
    detailPesanan = SellerOrderData();
    notifyListeners();
  }

  bool showMore = false;

  Future<void> fetchDetailPesanan({
    bool withLoading = false,
    required String parent_id,
  }) async {
    if (withLoading) loading(true);

    try {
      final response = await get(
        Constant.BASE_API_FULL + '${Constant.epSellerOrders}/$parent_id',
      );
      final parsed = jsonDecode(response.body);
      if (response.statusCode == 200) {
        detailPesanan = SellerOrderData.fromJson(parsed['data']);
      } else {
        throw Exception(parsed['message'] ?? 'Failed to load detail');
      }
    } catch (e) {
      Utils.showFailed(msg: e.toString());
    } finally {
      if (withLoading) loading(false);
      notifyListeners();
    }
  }

  String? rejectOrderReason;

  Future<bool> fetchActionPesananBaru({
    bool withLoading = false,
    required String parent_id,
    required bool terima,
    String? note,
  }) async {
    if (withLoading) loading(true);
    try {
      // Laravel endpoint: /seller/v1/seller/orders/{order}/accept
      final Map<String, dynamic> payload = {};
      final finalNote = note ?? rejectOrderReason;
      if (finalNote != null && finalNote.trim().isNotEmpty) {
        payload['note'] = finalNote.trim();
      }

      final response = await post(
        Constant.BASE_API_FULL + '${Constant.epSellerOrders}/$parent_id/accept',
        body: payload,
      );
      final parsed = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        Utils.showSuccess(msg: 'Pesanan berhasil diterima');
        return true;
      } else {
        Utils.showFailed(msg: parsed['message'] ?? 'Gagal menerima pesanan');
      }
    } catch (e) {
      Utils.showFailed(msg: e.toString());
    } finally {
      if (withLoading) loading(false);
    }
    return false;
  }

  Future<bool> kirimBarang({
    bool withLoading = false,
    required String parent_id,
    String? receiptNum,
    String? note,
  }) async {
    if (withLoading) loading(true);
    try {
      // Laravel endpoint: /seller/v1/seller/orders/{order}/ship
      final Map<String, dynamic> payload = {};
      if (receiptNum != null && receiptNum.trim().isNotEmpty) {
        payload['receipt_num'] = receiptNum.trim();
      }
      if (note != null && note.trim().isNotEmpty) {
        payload['note'] = note.trim();
      }

      final response = await post(
        Constant.BASE_API_FULL + '${Constant.epSellerOrders}/$parent_id/ship',
        body: payload,
      );
      final parsed = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        Utils.showSuccess(msg: 'Barang berhasil dikirim');
        return true;
      } else {
        Utils.showFailed(msg: parsed['message'] ?? 'Gagal mengirim barang');
      }
    } catch (e) {
      Utils.showFailed(msg: e.toString());
    } finally {
      if (withLoading) loading(false);
    }
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
