import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:mspeed/common/base/base_controller.dart';
import 'package:mspeed/common/helper/constant.dart';
import 'package:mspeed/core/network/api_client.dart';
import 'package:mspeed/src/manager/dashboard/model/manager_dashboard_model.dart';
import 'package:mspeed/src/manager/pesanan/model/manager_order_model.dart';
import 'package:mspeed/src/manager/team/model/manager_team_model.dart';
import 'package:mspeed/utils/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ManagerProvider
/// Handles all Manager API calls:
/// - GET /manager/v1/manager/dashboard         → fetchDashboard
/// - GET /manager/v1/manager/orders            → fetchOrders
/// - GET /manager/v1/manager/orders/{id}       → fetchOrderDetail
/// - POST /manager/v1/manager/orders/{id}/approve       → approveOrder
/// - POST /manager/v1/manager/orders/{id}/reject        → rejectOrder
/// - POST /manager/v1/manager/orders/{id}/approve-invoice → approveInvoice
/// - POST /manager/v1/manager/orders/{id}/reject-invoice  → rejectInvoice
/// - GET /manager/v1/manager/team              → fetchTeam
class ManagerProvider extends BaseController with ChangeNotifier {
  // ─────────────────────────────────────────────────────────────────
  // State: Dashboard
  // ─────────────────────────────────────────────────────────────────
  ManagerDashboardModel _dashboard = ManagerDashboardModel();
  ManagerDashboardModel get dashboard => _dashboard;

  bool _isLoadingDashboard = false;
  bool get isLoadingDashboard => _isLoadingDashboard;

  int? _selectedCategoryId;
  int? get selectedCategoryId => _selectedCategoryId;

  final dashboardSearchController = TextEditingController();

  // ─────────────────────────────────────────────────────────────────
  // Computed Dashboard KPIs (Mapped from parent_orders, exact logic as ManagerDashboard.blade.php)
  // ─────────────────────────────────────────────────────────────────
  int get kpiTotalPesanan => _dashboard.parentOrders?.length ?? 0;

  int get kpiPesananDitolak =>
      _dashboard.parentOrders?.where((o) => o.statusCategory == 'pesanan_ditolak').length ?? 0;

  int get kpiPesananBaru =>
      _dashboard.parentOrders?.where((o) => o.statusCategory == 'pesanan_baru').length ?? 0;

  int get kpiPesananDiterima =>
      _dashboard.parentOrders?.where((o) => o.statusCategory == 'pesanan_diterima').length ?? 0;

  int get kpiPesananDikirim =>
      _dashboard.parentOrders?.where((o) => o.statusCategory == 'pesanan_dikirim').length ?? 0;

  int get kpiBarangDiterima =>
      _dashboard.parentOrders?.where((o) => o.statusCategory == 'barang_diterima').length ?? 0;

  int get kpiTagihan =>
      _dashboard.parentOrders?.where((o) => o.statusCategory == 'tagihan').length ?? 0;

  int get kpiSiapTagih =>
      _dashboard.parentOrders?.where((o) => o.statusCategory == 'siap_tagih').length ?? 0;

  int get kpiProsesPembayaran =>
      _dashboard.parentOrders?.where((o) => o.statusCategory == 'proses_pembayaran').length ?? 0;

  int get kpiTelahDibayar =>
      _dashboard.parentOrders?.where((o) => o.statusCategory == 'telah_dibayar').length ?? 0;

  // ─────────────────────────────────────────────────────────────────
  // State: Orders
  // ─────────────────────────────────────────────────────────────────
  ManagerOrderModel _orders = ManagerOrderModel();
  ManagerOrderModel get orders => _orders;

  ManagerOrderData _selectedOrder = ManagerOrderData();
  ManagerOrderData get selectedOrder => _selectedOrder;

  bool _isLoadingOrders = false;
  bool get isLoadingOrders => _isLoadingOrders;

  bool _isLoadingDetail = false;
  bool get isLoadingDetail => _isLoadingDetail;

  // ─────────────────────────────────────────────────────────────────
  // State: Team
  // ─────────────────────────────────────────────────────────────────
  ManagerTeamModel _team = ManagerTeamModel();
  ManagerTeamModel get team => _team;

  bool _isLoadingTeam = false;
  bool get isLoadingTeam => _isLoadingTeam;

  // ─────────────────────────────────────────────────────────────────
  // State: Profile & Impersonation
  // ─────────────────────────────────────────────────────────────────
  String _managerName = '';
  String get managerName => _managerName;

  String _managerEmail = '';
  String get managerEmail => _managerEmail;

  String _managerPhone = '';
  String get managerPhone => _managerPhone;

  String _managerRole = 'MANAGER';
  String get managerRole => _managerRole;

  bool _isImpersonated = false;
  bool get isImpersonated => _isImpersonated;

  // ─────────────────────────────────────────────────────────────────
  // Search / Filter State
  // ─────────────────────────────────────────────────────────────────
  String? filterStatus;
  final searchController = TextEditingController();
  final teamSearchController = TextEditingController();
  final noteController = TextEditingController();

  // ─────────────────────────────────────────────────────────────────
  // Computed: Filtered Orders
  // ─────────────────────────────────────────────────────────────────
  List<ManagerOrderData> get filteredOrders {
    final all = _orders.data ?? [];
    final q = searchController.text.trim().toLowerCase();
    return all.where((o) {
      // Status filter
      if (filterStatus != null && filterStatus!.isNotEmpty) {
        final status = o.latestLogFromHistory?.status ?? o.paymentStatus ?? '';
        if (status != filterStatus) return false;
      }
      // Search filter
      if (q.isNotEmpty) {
        final matchOrderNum = o.orderNum?.toLowerCase().contains(q) ?? false;
        final matchBuyer = o.buyer?.buyerName?.toLowerCase().contains(q) ?? false;
        final matchSeller = o.seller?.companyName?.toLowerCase().contains(q) ?? false;
        if (!matchOrderNum && !matchBuyer && !matchSeller) return false;
      }
      return true;
    }).toList();
  }

  // ─────────────────────────────────────────────────────────────────
  // Fetch Dashboard
  // GET /manager/v1/manager/dashboard
  // Parameters: category_id, search, per_page
  // ─────────────────────────────────────────────────────────────────
  Future<void> fetchDashboard({
    int? categoryId,
    String? search,
    bool withLoading = true,
  }) async {
    _isLoadingDashboard = true;
    if (withLoading) loading(true);
    notifyListeners();

    try {
      Map<String, dynamic> queryParams = {};
      if (categoryId != null) {
        queryParams['category_id'] = categoryId;
        _selectedCategoryId = categoryId;
      } else {
        _selectedCategoryId = null;
      }

      if (search != null && search.trim().isNotEmpty) {
        queryParams['search'] = search.trim();
      }

      final response = await ApiClient().dio.get(
        '/manager/v1/manager/dashboard',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        _dashboard = ManagerDashboardModel.fromJson(response.data);
        log('[ManagerProvider] fetchDashboard success: ${_dashboard.products?.length ?? 0} products');
      } else {
        throw Exception('Gagal memuat data dashboard');
      }
    } catch (e) {
      log('[ManagerProvider] fetchDashboard error: $e');
      Utils.showFailed(msg: 'Gagal memuat dashboard: ${e.toString()}');
    } finally {
      _isLoadingDashboard = false;
      if (withLoading) loading(false);
      notifyListeners();
    }
  }

  void selectCategoryFilter(int? catId) {
    _selectedCategoryId = catId;
    fetchDashboard(
      categoryId: catId,
      search: dashboardSearchController.text,
      withLoading: true,
    );
  }

  void searchDashboard(String query) {
    fetchDashboard(
      categoryId: _selectedCategoryId,
      search: query,
      withLoading: false,
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // Fetch Orders
  // GET /manager/v1/manager/orders
  // ─────────────────────────────────────────────────────────────────
  Future<void> fetchOrders({bool withLoading = true}) async {
    _isLoadingOrders = true;
    if (withLoading) loading(true);
    notifyListeners();

    try {
      final response = await ApiClient().dio.get('/manager/v1/manager/orders');
      if (response.statusCode == 200 || response.statusCode == 201) {
        _orders = ManagerOrderModel.fromJson(response.data);
        log('[ManagerProvider] fetchOrders: ${_orders.data?.length ?? 0} orders');
      } else {
        throw Exception('Gagal memuat daftar pesanan');
      }
    } catch (e) {
      log('[ManagerProvider] fetchOrders error: $e');
      Utils.showFailed(msg: 'Gagal memuat pesanan: ${e.toString()}');
    } finally {
      _isLoadingOrders = false;
      if (withLoading) loading(false);
      notifyListeners();
    }
  }

  // ─────────────────────────────────────────────────────────────────
  // Fetch Order Detail
  // GET /manager/v1/manager/orders/{id}
  // ─────────────────────────────────────────────────────────────────
  Future<void> fetchOrderDetail({required int orderId, bool withLoading = true}) async {
    _isLoadingDetail = true;
    if (withLoading) loading(true);
    _selectedOrder = ManagerOrderData();
    notifyListeners();

    try {
      final response = await ApiClient().dio.get('/manager/v1/manager/orders/$orderId');
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data['data'] ?? response.data;
        _selectedOrder = ManagerOrderData.fromJson(data);
        log('[ManagerProvider] fetchOrderDetail: ${_selectedOrder.orderNum}');
      } else {
        throw Exception(response.data['message'] ?? 'Gagal memuat detail pesanan');
      }
    } catch (e) {
      log('[ManagerProvider] fetchOrderDetail error: $e');
      Utils.showFailed(msg: 'Gagal memuat detail pesanan: ${e.toString()}');
    } finally {
      _isLoadingDetail = false;
      if (withLoading) loading(false);
      notifyListeners();
    }
  }

  // ─────────────────────────────────────────────────────────────────
  // Approve Order (Pesanan Baru → Approve Pesanan by Manager)
  // POST /manager/v1/manager/orders/{id}/approve
  // Syarat: latestLog.status == 'pesanan baru'
  // ─────────────────────────────────────────────────────────────────
  Future<bool> approveOrder({required int orderId, String? note}) async {
    loading(true);
    try {
      final response = await ApiClient().dio.post(
        '/manager/v1/manager/orders/$orderId/approve',
        data: {'note': note ?? 'Pesanan telah disetujui oleh Manager.'},
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data['data'] ?? response.data;
        _selectedOrder = ManagerOrderData.fromJson(data);
        await fetchOrders(withLoading: false);
        loading(false);
        notifyListeners();
        Utils.showSuccess(msg: 'Pesanan berhasil disetujui oleh Manager.');
        return true;
      } else {
        throw Exception(response.data['message'] ?? 'Gagal menyetujui pesanan');
      }
    } catch (e) {
      log('[ManagerProvider] approveOrder error: $e');
      loading(false);
      Utils.showFailed(msg: 'Gagal menyetujui pesanan: ${e.toString()}');
      return false;
    }
  }

  // ─────────────────────────────────────────────────────────────────
  // Reject Order (Pesanan Baru → Reject Pesanan by Manager)
  // POST /manager/v1/manager/orders/{id}/reject
  // Syarat: latestLog.status == 'pesanan baru'
  // ─────────────────────────────────────────────────────────────────
  Future<bool> rejectOrder({required int orderId, String? note}) async {
    loading(true);
    try {
      final response = await ApiClient().dio.post(
        '/manager/v1/manager/orders/$orderId/reject',
        data: {'note': note ?? 'Pesanan ditolak oleh Manager.'},
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data['data'] ?? response.data;
        _selectedOrder = ManagerOrderData.fromJson(data);
        await fetchOrders(withLoading: false);
        loading(false);
        notifyListeners();
        Utils.showSuccess(msg: 'Pesanan telah ditolak oleh Manager.');
        return true;
      } else {
        throw Exception(response.data['message'] ?? 'Gagal menolak pesanan');
      }
    } catch (e) {
      log('[ManagerProvider] rejectOrder error: $e');
      loading(false);
      Utils.showFailed(msg: 'Gagal menolak pesanan: ${e.toString()}');
      return false;
    }
  }

  // ─────────────────────────────────────────────────────────────────
  // Approve Invoice (Tagihan → Siap Tagih by Manager)
  // POST /manager/v1/manager/orders/{id}/approve-invoice
  // Syarat: latestLog.status == 'tagihan'
  // ─────────────────────────────────────────────────────────────────
  Future<bool> approveInvoice({required int orderId, String? note}) async {
    loading(true);
    try {
      final response = await ApiClient().dio.post(
        '/manager/v1/manager/orders/$orderId/approve-invoice',
        data: {'note': note ?? 'Tagihan pesanan disetujui oleh Manager (Siap Tagih).'},
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data['data'] ?? response.data;
        _selectedOrder = ManagerOrderData.fromJson(data);
        await fetchOrders(withLoading: false);
        loading(false);
        notifyListeners();
        Utils.showSuccess(msg: 'Tagihan pesanan berhasil disetujui oleh Manager (Siap Tagih).');
        return true;
      } else {
        throw Exception(response.data['message'] ?? 'Gagal menyetujui tagihan');
      }
    } catch (e) {
      log('[ManagerProvider] approveInvoice error: $e');
      loading(false);
      Utils.showFailed(msg: 'Gagal menyetujui tagihan: ${e.toString()}');
      return false;
    }
  }

  // ─────────────────────────────────────────────────────────────────
  // Reject Invoice (Tagihan → Tolak Tagih by Manager)
  // POST /manager/v1/manager/orders/{id}/reject-invoice
  // Syarat: latestLog.status == 'tagihan'
  // ─────────────────────────────────────────────────────────────────
  Future<bool> rejectInvoice({required int orderId, String? note}) async {
    loading(true);
    try {
      final response = await ApiClient().dio.post(
        '/manager/v1/manager/orders/$orderId/reject-invoice',
        data: {'note': note ?? 'Tagihan pesanan ditolak oleh Manager.'},
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data['data'] ?? response.data;
        _selectedOrder = ManagerOrderData.fromJson(data);
        await fetchOrders(withLoading: false);
        loading(false);
        notifyListeners();
        Utils.showSuccess(msg: 'Tagihan pesanan telah ditolak oleh Manager.');
        return true;
      } else {
        throw Exception(response.data['message'] ?? 'Gagal menolak tagihan');
      }
    } catch (e) {
      log('[ManagerProvider] rejectInvoice error: $e');
      loading(false);
      Utils.showFailed(msg: 'Gagal menolak tagihan: ${e.toString()}');
      return false;
    }
  }

  // ─────────────────────────────────────────────────────────────────
  // Fetch Team
  // GET /manager/v1/manager/team
  // ─────────────────────────────────────────────────────────────────
  Future<void> fetchTeam({bool withLoading = true}) async {
    _isLoadingTeam = true;
    if (withLoading) loading(true);
    notifyListeners();

    try {
      final response = await ApiClient().dio.get('/manager/v1/manager/team');
      if (response.statusCode == 200 || response.statusCode == 201) {
        _team = ManagerTeamModel.fromJson(response.data);
        log('[ManagerProvider] fetchTeam: ${_team.data?.length ?? 0} members');
      } else {
        throw Exception('Gagal memuat data tim');
      }
    } catch (e) {
      log('[ManagerProvider] fetchTeam error: $e');
      Utils.showFailed(msg: 'Gagal memuat data tim: ${e.toString()}');
    } finally {
      _isLoadingTeam = false;
      if (withLoading) loading(false);
      notifyListeners();
    }
  }

  // ─────────────────────────────────────────────────────────────────
  // Manager Info & Profile from SharedPreferences
  // ─────────────────────────────────────────────────────────────────
  Future<void> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final first = prefs.getString(Constant.kSetPrefFirstName) ?? '';
    final last = prefs.getString(Constant.kSetPrefLastName) ?? '';
    final name = '$first $last'.trim();
    _managerName = name.isNotEmpty ? name : 'Manager';
    _managerEmail = prefs.getString(Constant.kSetPrefEmail) ?? '';
    _managerPhone = prefs.getString(Constant.kSetPrefPhone) ?? '';
    _managerRole = prefs.getString(Constant.kSetPrefRoles) ?? 'MANAGER';
    _isImpersonated = prefs.getString('admin_original_token') != null &&
        prefs.getString('admin_original_token')!.isNotEmpty;
    notifyListeners();
  }

  // ─────────────────────────────────────────────────────────────────
  // Reset
  // ─────────────────────────────────────────────────────────────────
  void resetDashboard() {
    _dashboard = ManagerDashboardModel();
    _selectedCategoryId = null;
    dashboardSearchController.clear();
    notifyListeners();
  }

  void resetOrders() {
    _orders = ManagerOrderModel();
    _selectedOrder = ManagerOrderData();
    filterStatus = null;
    searchController.clear();
    noteController.clear();
    notifyListeners();
  }

  void resetTeam() {
    _team = ManagerTeamModel();
    teamSearchController.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    dashboardSearchController.dispose();
    searchController.dispose();
    teamSearchController.dispose();
    noteController.dispose();
    super.dispose();
  }
}
