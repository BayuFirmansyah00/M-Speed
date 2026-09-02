import 'package:flutter/material.dart';
import 'package:mspeed/common/base/base_controller.dart';
import 'package:mspeed/common/helper/constant.dart';
import 'package:mspeed/core/network/api_client.dart';
import 'package:mspeed/src/penerima/pesanan/model/receiver_order_model.dart';
import 'package:mspeed/utils/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PenerimaPesananProvider extends BaseController with ChangeNotifier {
  // ── State Variables ────────────────────────────────────────────────────────
  List<ReceiverOrderData> _orders = [];
  List<ReceiverOrderData> get orders => _orders;

  ReceiverOrderData? _selectedOrder;
  ReceiverOrderData? get selectedOrder => _selectedOrder;

  ReceiverOrderMeta? _meta;
  ReceiverOrderMeta? get meta => _meta;

  bool _isLoadingOrders = false;
  bool get isLoadingOrders => _isLoadingOrders;

  bool _isLoadingDetail = false;
  bool get isLoadingDetail => _isLoadingDetail;

  bool _isProcessing = false;
  bool get isProcessing => _isProcessing;

  // ── Search & Filter State ──────────────────────────────────────────────────
  final TextEditingController searchController = TextEditingController();
  String? _selectedStatus;
  String? get selectedStatus => _selectedStatus;

  int? _selectedMonth;
  int? get selectedMonth => _selectedMonth;

  int? _selectedYear;
  int? get selectedYear => _selectedYear;

  // ── Profile State ──────────────────────────────────────────────────────────
  String _receiverName = 'Penerima';
  String get receiverName => _receiverName;

  String _receiverEmail = '';
  String get receiverEmail => _receiverEmail;

  String _receiverRole = 'RECEIVER';
  String get receiverRole => _receiverRole;

  bool _isImpersonated = false;
  bool get isImpersonated => _isImpersonated;

  // ── Computed KPI Counters ──────────────────────────────────────────────────
  int get kpiTotalPesanan => _orders.length;

  /// Orders ready for physical reception and verification (`pesanan dikirim`)
  int get kpiSiapDiterima =>
      _orders.where((o) => o.canVerifyReception).length;

  /// Orders successfully received and confirmed
  int get kpiTelahDiterima =>
      _orders.where((o) => o.isReceived).length;

  /// Sum of all orders' grand totals
  double get kpiTotalNominal =>
      _orders.fold<double>(0.0, (sum, o) => sum + o.grandTotal);

  // ── Profile Loader ─────────────────────────────────────────────────────────
  Future<void> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    _receiverEmail = prefs.getString(Constant.kSetPrefEmail) ?? '';
    _receiverRole = prefs.getString(Constant.kSetPrefRoles)?.toUpperCase() ?? 'RECEIVER';
    final firstName = prefs.getString(Constant.kSetPrefFirstName) ?? '';
    final lastName = prefs.getString(Constant.kSetPrefLastName) ?? '';

    if (firstName.isNotEmpty || lastName.isNotEmpty) {
      _receiverName = '$firstName $lastName'.trim();
    } else if (_receiverEmail.isNotEmpty) {
      _receiverName = _receiverEmail.split('@').first;
    } else {
      _receiverName = 'Penerima Logistik';
    }

    final bool isImp = prefs.getBool('is_impersonated') ?? false;
    final String origToken = prefs.getString('admin_original_token') ?? '';
    _isImpersonated = isImp || origToken.isNotEmpty;
    notifyListeners();
  }

  // ── Fetch Orders List ──────────────────────────────────────────────────────
  Future<void> fetchOrders({bool withLoading = false}) async {
    if (withLoading) {
      _isLoadingOrders = true;
      notifyListeners();
    }

    try {
      final Map<String, dynamic> queryParams = {};

      if (searchController.text.trim().isNotEmpty) {
        queryParams['search'] = searchController.text.trim();
      }
      if (_selectedStatus != null && _selectedStatus!.isNotEmpty) {
        queryParams['status_log'] = _selectedStatus;
      }
      if (_selectedMonth != null) {
        queryParams['month'] = _selectedMonth;
      }
      if (_selectedYear != null) {
        queryParams['year'] = _selectedYear;
      }

      final response = await ApiClient().dio.get(
        '/receiver/v1/receiver/orders',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data != null) {
        final parsed = ReceiverOrderListResponse.fromJson(response.data);
        _orders = parsed.data;
        _meta = parsed.meta;
      } else {
        _orders = [];
      }
    } catch (e) {
      debugPrint('[PenerimaPesananProvider] Error fetching orders: $e');
      _orders = [];
    } finally {
      _isLoadingOrders = false;
      notifyListeners();
    }
  }

  // ── Fetch Order Detail ─────────────────────────────────────────────────────
  Future<void> fetchOrderDetail(int orderId, {bool withLoading = false}) async {
    if (withLoading) {
      _isLoadingDetail = true;
      notifyListeners();
    }

    try {
      final response = await ApiClient().dio.get(
        '/receiver/v1/receiver/orders/$orderId',
      );

      if (response.statusCode == 200 && response.data != null) {
        final parsed = ReceiverOrderDetailResponse.fromJson(response.data);
        _selectedOrder = parsed.data;
      } else {
        _selectedOrder = null;
      }
    } catch (e) {
      debugPrint('[PenerimaPesananProvider] Error fetching order detail: $e');
      _selectedOrder = null;
    } finally {
      _isLoadingDetail = false;
      notifyListeners();
    }
  }

  // ── Verify & Confirm Order Receipt Action ──────────────────────────────────
  Future<bool> verifyOrderReceipt({
    required int orderId,
    String? note,
    String? title,
  }) async {
    _isProcessing = true;
    notifyListeners();

    try {
      final Map<String, dynamic> payload = {
        'title': (title != null && title.isNotEmpty)
            ? title
            : 'Verifikasi Penerimaan Barang',
        'note': (note != null && note.isNotEmpty)
            ? note
            : 'Pesanan telah diterima dan diverifikasi oleh Penerima (Receiver).',
      };

      final response = await ApiClient().dio.post(
        '/receiver/v1/receiver/orders/$orderId/verify',
        data: payload,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        Utils.showSuccess(msg: 'Verifikasi penerimaan barang berhasil disimpan.');
        // Refresh detail and list
        await fetchOrderDetail(orderId);
        await fetchOrders();
        return true;
      } else {
        final msg = response.data?['message'] ?? 'Gagal memproses verifikasi penerimaan.';
        Utils.showFailed(msg: msg);
        return false;
      }
    } catch (e) {
      debugPrint('[PenerimaPesananProvider] Error verifying receipt: $e');
      Utils.showFailed(msg: 'Terjadi kesalahan: $e');
      return false;
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  // ── Filter Controls ────────────────────────────────────────────────────────
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

  void applyFilters() {
    fetchOrders(withLoading: true);
  }

  void resetFilters() {
    searchController.clear();
    _selectedStatus = null;
    _selectedMonth = null;
    _selectedYear = null;
    fetchOrders(withLoading: true);
  }
}
