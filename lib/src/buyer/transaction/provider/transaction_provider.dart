import 'dart:convert';
import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:mspeed/common/base/base_controller.dart';
import 'package:mspeed/common/helper/constant.dart';
import 'package:mspeed/src/buyer/transaction/model/daftar_transaksi_buyer_model.dart';
import 'package:mspeed/src/buyer/transaction/model/detail_tansaction_buyer_model.dart';
import 'package:mspeed/src/buyer/transaction/model/riwayat_nego_transaksi_model.dart';
import 'package:mspeed/src/buyer/transaction/model/transaction_model.dart';
import 'package:flutter/material.dart';
import 'package:mspeed/utils/utils.dart';

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

  /// Public helper for testing status-to-tab mapping
  static int logStatusToTabIndexForTest(Map item) => _logStatusToTabIndex(item);

  /// Mapping status Laravel → index tab Flutter (1-6)
  /// Tab: 1=Pesanan Baru, 2=Pesanan Diterima, 3=Pesanan Dikirim,
  ///      4=Barang Diterima, 5=Proses Pembayaran, 6=Telah Dibayar
  static int _logStatusToTabIndex(Map item) {
    String status = '';
    if (item['latest_log'] != null && item['latest_log']['status'] != null) {
      status = item['latest_log']['status'].toString().toLowerCase().trim();
    } else if (item['payment_status'] != null) {
      status = item['payment_status'].toString().toLowerCase().trim();
    } else if (item['logs'] is List && (item['logs'] as List).isNotEmpty) {
      status = (item['logs'] as List).first['status']?.toString().toLowerCase().trim() ?? '';
    }

    if (status == 'pesanan dibayar' ||
        status == 'telah dibayar' ||
        status == 'sudah dibayar' ||
        status == 'paid' ||
        status == 'selesai' ||
        status == 'pesanan_selesai') {
      return 6; // Tab 6: Telah Dibayar
    } else if (status == 'tagihan' ||
        status == 'siap tagih by manager' ||
        status == 'tolak tagih by manager' ||
        status == 'penerimaan & verifikasi' ||
        status == 'pembayaran ditolak finance' ||
        status.contains('tagih') ||
        status.contains('pembayaran')) {
      return 5; // Tab 5: Proses Pembayaran
    } else if (status == 'pesanan diterima penerima' ||
        status.contains('diterima penerima') ||
        status.contains('barang diterima') ||
        status == 'barang_diterima') {
      return 4; // Tab 4: Barang Diterima
    } else if (status == 'pesanan dikirim' ||
        status.contains('dikirim') ||
        status == 'pesanan_dikirim') {
      return 3; // Tab 3: Pesanan Dikirim
    } else if (status == 'approve pesanan by manager' ||
        status == 'pesanan diterima penjual' ||
        status.contains('diterima penjual') ||
        status.contains('disetujui') ||
        status == 'pesanan_diterima') {
      return 2; // Tab 2: Pesanan Diterima
    } else {
      // Default: pesanan baru / reject pesanan by manager / not approve pesanan by manager
      return 1; // Tab 1: Pesanan Baru
    }
  }

  Future<void> fetchTransaction(
      {bool withLoading = false, required int status}) async {
    if (withLoading) loading(true);

    try {
      // GET /api/buyer/v1/buyer/transactions?per_page=100
      // Response: { data: [...ParentOrder], links: {}, meta: {} }
      final parsed = await getRest(
          Constant.BASE_API_FULL + '/buyer/v1/buyer/transactions?per_page=100');

      // Laravel returns pagination: { data: [...], meta: {}, links: {} }
      final List dataArray =
          (parsed is Map && parsed.containsKey('data')) ? parsed['data'] : [];

      // Reset semua tab
      final List<List<DaftarTransaksiBuyerModelData>> tabBuckets = [
        [], [], [], [], [], []
      ];

      for (final item in dataArray) {
        if (item is! Map) continue;
        // Tentukan tab berdasarkan status order Laravel
        final int tabIndex = _logStatusToTabIndex(item);

        // Hitung total belanja: sum(items.final_price) + shipping_cost
        double shippingCost = 0;
        if (item['shipping_cost'] != null) {
          shippingCost = (item['shipping_cost'] as num).toDouble();
        }
        double itemsTotal = 0;
        final List itemsList = (item['items'] is List) ? item['items'] : [];
        for (final it in itemsList) {
          itemsTotal += (it['final_price'] as num? ?? 0).toDouble();
        }
        final double grandTotal = itemsTotal + shippingCost;

        // Map items → detail (produk list)
        final List<DaftarTransaksiBuyerModelDataDetail> detailList =
            itemsList.map<DaftarTransaksiBuyerModelDataDetail>((it) {
          return DaftarTransaksiBuyerModelDataDetail(
            nama: it['product_name']?.toString(),
            qty: it['qty']?.toString() ?? '1',
            harga: (it['initial_price'] as num? ?? 0).toStringAsFixed(0),
            hargaAkhir: (it['final_price'] as num? ?? 0).toStringAsFixed(0),
            IDOrder: item['id']?.toString(),
            foto: it['product_image_url']?.toString(), // gambar produk dari backend
          );
        }).toList();

        final String sellerNama = item['seller']?['company_name']?.toString() ?? '-';
        final String sellerID = item['seller']?['id']?.toString() ?? '';

        final mapped = DaftarTransaksiBuyerModelData(
          ID: item['id']?.toString(),
          nomorOrder: item['order_num']?.toString(),
          status: item['latest_log']?['status']?.toString() ?? item['payment_status']?.toString(),
          SellerID: sellerID,
          SellerNama: sellerNama,
          total: grandTotal.toStringAsFixed(0),
          jum: itemsList.length.toString(),
          Created: item['created_at']?.toString(),
          detail: detailList,
        );

        tabBuckets[tabIndex - 1].add(mapped);
      }

      // Update seluruh tab sekaligus agar konsisten saat tab berganti
      for (int i = 0; i < 6; i++) {
        daftarTransaksi[i] = DaftarTransaksiBuyerModel(
            result: 'success', data: tabBuckets[i]);
      }
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
      // GET /api/buyer/v1/buyer/transactions/{id}
      // Response: BuyerTransactionResource { id, order_num, payment_status, seller, items, logs, ... }
      final parsed = await getRest(
          Constant.BASE_API_FULL + '/buyer/v1/buyer/transactions/$transaction_id');

      // Endpoint show() mengembalikan wrapped: { data: {...} } dari JsonResource
      final Map<String, dynamic>? raw =
          (parsed is Map && parsed.containsKey('data'))
              ? (parsed['data'] as Map<String, dynamic>?)
              : (parsed is Map ? parsed.cast<String, dynamic>() : null);

      if (raw != null) {
        // --- Hitung total: sum(items.final_price) + shipping_cost ---
        double shippingCost = (raw['shipping_cost'] as num? ?? 0).toDouble();
        final List itemsList = (raw['items'] is List) ? raw['items'] : [];
        double itemsTotal = 0;
        for (final it in itemsList) {
          itemsTotal += (it['final_price'] as num? ?? 0).toDouble();
        }
        final double grandTotal = itemsTotal + shippingCost;

        // --- Map items → detail list ---
        final List<DetailTransaksiBuyerModelDataDetail> detailList =
            itemsList.map<DetailTransaksiBuyerModelDataDetail>((it) {
          return DetailTransaksiBuyerModelDataDetail(
            ID: it['id']?.toString(),
            nama: it['product_name']?.toString(),
            qty: it['qty']?.toString() ?? '1',
            harga: (it['initial_price'] as num? ?? 0).toStringAsFixed(0),
            hargaAkhir: (it['final_price'] as num? ?? 0).toStringAsFixed(0),
            IDOrder: raw['id']?.toString(),
            foto: it['product_image_url']?.toString(), // gambar produk dari backend
          );
        }).toList();

        // --- Map logs → timeline ---
        final List logs = (raw['logs'] is List) ? raw['logs'] : [];
        final List<DetailTransaksiBuyerModelDataTimeline> timelineList =
            logs.map<DetailTransaksiBuyerModelDataTimeline>((log) {
          return DetailTransaksiBuyerModelDataTimeline(
            label: log['status']?.toString(),
            time: log['created_at']?.toString(),
            desc: log['note']?.toString(),
          );
        }).toList();

        // --- Build parent order model ---
        final parentOrder = DetailTransaksiBuyerModelDataParentOrderModel(
          ID: raw['id']?.toString(),
          nomorOrder: raw['order_num']?.toString(),
          status: raw['payment_status']?.toString(),
          SellerID: raw['seller']?['id']?.toString(),
          SellerNama: raw['seller']?['company_name']?.toString(),
          SellerAlamat: raw['seller']?['address']?.toString(),
          Created: raw['created_at']?.toString(),
          total: grandTotal.toStringAsFixed(0),
          ongkir: shippingCost.toStringAsFixed(0),
          estPengiriman: raw['est_delivery_start']?.toString(),
          estPengiriman2: raw['est_delivery_end']?.toString(),
        );

        setDetailTransaksi = DetailTransaksiBuyerModel(
          result: 'success',
          data: DetailTransaksiBuyerModelData(
            ParentOrderModel: parentOrder,
            detail: detailList,
            timeline: timelineList,
            title: 'Detail Pesanan',
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

  Future<bool> submitRating({
    bool withLoading = false,
    required String transactionId,
    required int star,
    String? note,
  }) async {
    if (withLoading) loading(true);
    try {
      final payload = {
        'ratings': [
          {
            'rating_type_id': 1,
            'star': star,
            if (note != null && note.trim().isNotEmpty) 'note': note.trim(),
          }
        ]
      };

      final response = await post(
        Constant.BASE_API_FULL + '/buyer/v1/buyer/transactions/$transactionId/ratings',
        body: payload,
      );
      final parsed = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        Utils.showSuccess(msg: 'Penilaian dan ulasan berhasil dikirim.');
        return true;
      } else {
        Utils.showFailed(msg: parsed['message'] ?? 'Gagal mengirim penilaian');
      }
    } catch (e) {
      Utils.showFailed(msg: e.toString());
    } finally {
      if (withLoading) loading(false);
    }
    return false;
  }

  Future<String?> fetchSuratTtd(
      {bool withLoading = false, required String transaction_id}) async {
    if (withLoading) loading(true);
    try {
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
      } else {
        loading(false);
        return null;
      }
    } catch (_) {
      if (withLoading) loading(false);
      return null;
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
    Utils.showFailed(msg: 'Fitur TTD Surat Pesanan belum tersedia pada REST API.');
    if (withLoading) loading(false);
    isTtdSuccess = false;
    return false;
  }

  int? resetDate;
  String? reason;

  Future<bool> kembalikanTagihan({
    bool withLoading = false,
    required String parentOrderId,
  }) async {
    if (withLoading) loading(true);
    Utils.showFailed(msg: 'Fitur dispute tagihan belum tersedia pada REST API.');
    if (withLoading) loading(false);
    return false;
  }

  XFile? ematerai;

  Future<bool> uploadEMaterai({
    bool withLoading = false,
    required String parentOrderId,
  }) async {
    if (withLoading) loading(true);
    Utils.showFailed(msg: 'Fitur upload e-materai mandiri belum tersedia pada REST API.');
    if (withLoading) loading(false);
    return false;
  }
}
