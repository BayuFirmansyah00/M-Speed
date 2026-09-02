import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mspeed/common/base/base_controller.dart';
import 'package:mspeed/common/helper/constant.dart';
import 'package:mspeed/core/network/api_client.dart';
import 'package:mspeed/src/keuangan/pesanan/model/finance_order_model.dart';
import 'package:mspeed/utils/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// KeuanganProvider
/// Handles all Finance API calls and business state:
/// - GET  /finance/v1/finance/orders          → fetchOrders
/// - GET  /finance/v1/finance/orders/{id}      → fetchOrderDetail
/// - POST /finance/v1/finance/orders/{id}/pay  → processPayment (with optional proof & note)
/// - POST /finance/v1/finance/orders/{id}/reject → rejectPayment (with reason/note)
class KeuanganProvider extends BaseController with ChangeNotifier {
  // ─────────────────────────────────────────────────────────────────
  // State: Orders & Detail
  // ─────────────────────────────────────────────────────────────────
  List<FinanceOrderData> _orders = [];
  List<FinanceOrderData> get orders => _orders;

  FinanceOrderData? _selectedOrder;
  FinanceOrderData? get selectedOrder => _selectedOrder;

  FinanceOrderMeta? _meta;
  FinanceOrderMeta? get meta => _meta;

  bool _isLoadingOrders = false;
  bool get isLoadingOrders => _isLoadingOrders;

  bool _isLoadingDetail = false;
  bool get isLoadingDetail => _isLoadingDetail;

  bool _isProcessing = false;
  bool get isProcessing => _isProcessing;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  // ─────────────────────────────────────────────────────────────────
  // State: Filter & Search
  // ─────────────────────────────────────────────────────────────────
  final TextEditingController searchController = TextEditingController();
  String? _selectedStatus;
  String? get selectedStatus => _selectedStatus;

  int? _selectedMonth;
  int? get selectedMonth => _selectedMonth;

  int? _selectedYear;
  int? get selectedYear => _selectedYear;

  // Form Controllers for Actions
  final TextEditingController actionNoteController = TextEditingController();
  File? _paymentProofFile;
  File? get paymentProofFile => _paymentProofFile;
  set paymentProofFile(File? file) {
    _paymentProofFile = file;
    notifyListeners();
  }

  // ─────────────────────────────────────────────────────────────────
  // State: Profile & Impersonate Info
  // ─────────────────────────────────────────────────────────────────
  String _financeName = 'Finance User';
  String get financeName => _financeName;

  String _financeEmail = '';
  String get financeEmail => _financeEmail;

  String _financeRole = 'FINANCE';
  String get financeRole => _financeRole;

  bool _isImpersonated = false;
  bool get isImpersonated => _isImpersonated;

  // ─────────────────────────────────────────────────────────────────
  // Computed KPIs (From Real Backend Orders)
  // ─────────────────────────────────────────────────────────────────
  int get kpiTotalPesanan => _orders.length;

  /// Orders awaiting Finance payment action (status: 'penerimaan & verifikasi')
  int get kpiSiapDibayar =>
      _orders.where((o) => o.canProcessPayment).length;

  /// Orders already paid by Finance (status: 'pesanan dibayar' or 'telah_dibayar')
  int get kpiTelahDibayar =>
      _orders.where((o) => o.isPaid).length;

  /// Orders rejected by Finance
  int get kpiDitolak =>
      _orders.where((o) => o.isRejected).length;

  /// Total nominal of all paid orders
  double get kpiTotalNominalDibayar =>
      _orders.where((o) => o.isPaid).fold(0.0, (sum, o) => sum + o.grandTotal);

  // ─────────────────────────────────────────────────────────────────
  // Profile Loading
  // ─────────────────────────────────────────────────────────────────
  Future<void> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final firstName = prefs.getString(Constant.kSetPrefFirstName) ?? '';
    final lastName = prefs.getString(Constant.kSetPrefLastName) ?? '';
    final email = prefs.getString(Constant.kSetPrefEmail) ?? '';
    final role = prefs.getString(Constant.kSetPrefRoles) ?? 'FINANCE';
    final bool isImp = prefs.getBool('is_impersonated') ?? false;
    final String origToken = prefs.getString('admin_original_token') ?? '';

    final full = '$firstName $lastName'.trim();
    _financeName = full.isNotEmpty ? full : (email.isNotEmpty ? email : 'Finance User');
    _financeEmail = email;
    _financeRole = role.toUpperCase();
    _isImpersonated = isImp || origToken.isNotEmpty;
    notifyListeners();
  }

  // ─────────────────────────────────────────────────────────────────
  // API: Fetch Orders List
  // ─────────────────────────────────────────────────────────────────
  Future<void> fetchOrders({
    bool withLoading = true,
    String? search,
    String? statusLog,
    int? month,
    int? year,
  }) async {
    if (withLoading) {
      _isLoadingOrders = true;
      notifyListeners();
    }
    _errorMessage = '';

    try {
      final queryParams = <String, dynamic>{};
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (statusLog != null && statusLog.isNotEmpty) queryParams['status_log'] = statusLog;
      if (month != null) queryParams['month'] = month;
      if (year != null) queryParams['year'] = year;

      final response = await ApiClient().dio.get(
        '/finance/v1/finance/orders',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final parsed = FinanceOrderListResponse.fromJson(response.data);
        _orders = parsed.data;
        _meta = parsed.meta;
      }
    } on DioException catch (e) {
      log('[KeuanganProvider] fetchOrders DioException: ${e.message}');
      _errorMessage = e.response?.data?['message']?.toString() ?? 'Gagal memuat daftar pesanan.';
    } catch (e) {
      log('[KeuanganProvider] fetchOrders error: $e');
      _errorMessage = 'Terjadi kesalahan saat memuat pesanan.';
    } finally {
      if (withLoading) {
        _isLoadingOrders = false;
      }
      notifyListeners();
    }
  }

  // ─────────────────────────────────────────────────────────────────
  // API: Fetch Order Detail
  // ─────────────────────────────────────────────────────────────────
  Future<void> fetchOrderDetail(int orderId, {bool withLoading = true}) async {
    if (withLoading) {
      _isLoadingDetail = true;
      notifyListeners();
    }
    _errorMessage = '';

    try {
      final response = await ApiClient().dio.get('/finance/v1/finance/orders/$orderId');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final parsed = FinanceOrderDetailResponse.fromJson(response.data);
        _selectedOrder = parsed.data;
      }
    } on DioException catch (e) {
      log('[KeuanganProvider] fetchOrderDetail DioException: ${e.message}');
      _errorMessage = e.response?.data?['message']?.toString() ?? 'Gagal memuat detail pesanan.';
      Utils.showFailed(msg: _errorMessage);
    } catch (e) {
      log('[KeuanganProvider] fetchOrderDetail error: $e');
      _errorMessage = 'Gagal memuat detail pesanan: $e';
      Utils.showFailed(msg: _errorMessage);
    } finally {
      if (withLoading) {
        _isLoadingDetail = false;
      }
      notifyListeners();
    }
  }

  // ─────────────────────────────────────────────────────────────────
  // API: Process Payment (Pay Order)
  // ─────────────────────────────────────────────────────────────────
  Future<bool> processPayment({
    required int orderId,
    String? note,
    File? proofFile,
  }) async {
    _isProcessing = true;
    notifyListeners();

    try {
      dynamic postData;

      if (proofFile != null && await proofFile.exists()) {
        final fileName = proofFile.path.split(Platform.pathSeparator).last;
        postData = FormData.fromMap({
          if (note != null && note.isNotEmpty) 'note': note,
          'payment_proof': await MultipartFile.fromFile(
            proofFile.path,
            filename: fileName,
          ),
        });
      } else {
        postData = {
          if (note != null && note.isNotEmpty) 'note': note,
        };
      }

      final response = await ApiClient().dio.post(
        '/finance/v1/finance/orders/$orderId/pay',
        data: postData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        Utils.showSuccess(msg: 'Pembayaran pesanan berhasil diproses dan dicatat.');
        actionNoteController.clear();
        _paymentProofFile = null;
        // Refresh local detail & list
        await fetchOrderDetail(orderId, withLoading: false);
        fetchOrders(withLoading: false);
        return true;
      }
      return false;
    } on DioException catch (e) {
      log('[KeuanganProvider] processPayment DioException: ${e.response?.data}');
      final msg = e.response?.data?['message']?.toString() ??
          'Gagal memproses pembayaran. Periksa kembali status pesanan.';
      Utils.showFailed(msg: msg);
      return false;
    } catch (e) {
      log('[KeuanganProvider] processPayment error: $e');
      Utils.showFailed(msg: 'Terjadi kesalahan: $e');
      return false;
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  // ─────────────────────────────────────────────────────────────────
  // API: Reject Payment
  // ─────────────────────────────────────────────────────────────────
  Future<bool> rejectPayment({
    required int orderId,
    String? note,
  }) async {
    _isProcessing = true;
    notifyListeners();

    try {
      final response = await ApiClient().dio.post(
        '/finance/v1/finance/orders/$orderId/reject',
        data: {
          'note': (note != null && note.isNotEmpty) ? note : 'Pembayaran ditolak oleh Divisi Finance.',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        Utils.showSuccess(msg: 'Pembayaran pesanan berhasil ditolak.');
        actionNoteController.clear();
        await fetchOrderDetail(orderId, withLoading: false);
        fetchOrders(withLoading: false);
        return true;
      }
      return false;
    } on DioException catch (e) {
      log('[KeuanganProvider] rejectPayment DioException: ${e.response?.data}');
      final msg = e.response?.data?['message']?.toString() ?? 'Gagal menolak pembayaran.';
      Utils.showFailed(msg: msg);
      return false;
    } catch (e) {
      log('[KeuanganProvider] rejectPayment error: $e');
      Utils.showFailed(msg: 'Terjadi kesalahan: $e');
      return false;
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  // ─────────────────────────────────────────────────────────────────
  // Filter Management
  // ─────────────────────────────────────────────────────────────────
  void setFilterStatus(String? status) {
    _selectedStatus = status;
    notifyListeners();
  }

  void setFilterMonth(int? month) {
    _selectedMonth = month;
    notifyListeners();
  }

  void setFilterYear(int? year) {
    _selectedYear = year;
    notifyListeners();
  }

  void resetFilters() {
    _selectedStatus = null;
    _selectedMonth = null;
    _selectedYear = null;
    searchController.clear();
    notifyListeners();
    applyFilters();
  }

  void applyFilters() {
    fetchOrders(
      withLoading: true,
      search: searchController.text.trim(),
      statusLog: _selectedStatus,
      month: _selectedMonth,
      year: _selectedYear,
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // Cleanup
  // ─────────────────────────────────────────────────────────────────
  void clearActionData() {
    actionNoteController.clear();
    _paymentProofFile = null;
  }
}
