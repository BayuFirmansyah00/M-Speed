import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:mspeed/common/base/base_controller.dart';
import 'package:mspeed/common/helper/constant.dart';
import 'package:mspeed/src/admin/home/model/buyer_admin_model.dart';
import 'package:mspeed/src/admin/home/model/home_admin_model.dart';
import 'package:mspeed/src/admin/user/model/seller_admin_model.dart';
import 'package:mspeed/src/admin/user/view/user_data_admin_view.dart';
import 'package:mspeed/src/buyer/home/model/buyer_product_model.dart';
import 'package:mspeed/src/buyer/home/model/home_model.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:mspeed/core/network/api_client.dart';

import '../model/kategori_model.dart';

class AdminHomeProvider extends BaseController with ChangeNotifier {
  bool filterActiveOnly = false;

  void toggleFilterActiveOnly() {
    filterActiveOnly = !filterActiveOnly;
    notifyListeners();
  }
  String isSubAgent = "agen";
  Duration duration = const Duration(seconds: 2);
  int _currentIndex = 0;
  int get currentIndex => this._currentIndex;

  set currentIndex(int value) => this._currentIndex = value;
  Timer? _searchOnStoppedTyping;
  Timer? get searchOnStoppedTyping => this._searchOnStoppedTyping;

  set searchOnStoppedTyping(Timer? value) {
    this._searchOnStoppedTyping = value;
    notifyListeners();
  }

  TextEditingController searchController = TextEditingController();
  TextEditingController minPrice = TextEditingController();
  TextEditingController maxPrice = TextEditingController();
  int sort = 0;

  String get getIsSubAgent => this.isSubAgent;
  HomeModel homeModel = HomeModel();

  HomeModel get getHomeModel => this.homeModel;

  set setHomeModel(HomeModel homeModel) => this.homeModel = homeModel;

  set setIsSubAgent(String isSubAgent) => this.isSubAgent = isSubAgent;

  HomeAdminModel _homeAdminModel = HomeAdminModel();

  HomeAdminModel get homeAdminModel => _homeAdminModel;

  set homeAdminModel(HomeAdminModel value) {
    _homeAdminModel = value;
  }

  String? profilePic;
  String? name;
  String? email;

  List<FlSpot> graphList = [];

  int biggestGraphVal = 0;
  int biggestTransactionGraphVal = 0;

  String? selectedPeriodeData = '0';
  Map<String, String> periodeData = {
    'Hari ini': '0',
    'Periode Data Harian': '1',
    'Periode Data Bulanan': '2',
    'Periode Data Tahunan': '3',
  };

  int filterType = 0;

  String? selectedSellerBuyer;
  String? selectedSellerBuyerId;

  DateTime? _selectedDate;
  DateTime? get selectedDate => this._selectedDate;
  set selectedDate(DateTime? value) => this._selectedDate = value;

  String? _selectedMonth;
  String? get selectedMonth => this._selectedMonth;
  set selectedMonth(String? value) => this._selectedMonth = value;

  String? _selectedYear;
  String? get selectedYear => this._selectedYear;
  set selectedYear(String? value) => this._selectedYear = value;

  List<String>? timeList = [];

  Future<void> fetchHome({bool withLoading = false}) async {
    if (withLoading) loading(true);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    var firstName = await prefs.getString(Constant.kSetPrefFirstName);
    var lastName = await prefs.getString(Constant.kSetPrefLastName);
    name = ((firstName ?? '') + ' ' + (lastName ?? '')).trim();
    email = await prefs.getString(Constant.kSetPrefEmail);

    // Filter parameter sesuai AdminDashboardFilterRequest Laravel
    Map<String, String> body = {};
    if (selectedPeriodeData == '1' && selectedDate != null)
      body['period'] = 'daily';
    else if (selectedPeriodeData == '2' && selectedMonth != null)
      body['period'] = 'monthly';
    else if (selectedPeriodeData == '3' && selectedYear != null)
      body['period'] = 'yearly';

    if (selectedDate != null)
      body['start_date'] = DateFormat('yyyy-MM-dd').format(selectedDate!);

    // GET /api/audit/v1/admin/dashboard
    try {
      final response = await ApiClient().dio.get(
        '/audit/v1/admin/dashboard',
        queryParameters: body,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        homeAdminModel = HomeAdminModel.fromJson(response.data);
        log("DASHBOARD RESPONSE: ${response.data}");

        // Fetch detailed counts for all roles to populate missing backend metric fields
        await _fetchRoleCounts(homeAdminModel);

        // Rebuild graph dari purchase_statistics
        graphList.clear();
        biggestGraphVal = 0;

        notifyListeners();
        if (withLoading) loading(false);
      }
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? 'Terjadi kesalahan pada dashboard';
      loading(false);
      throw Exception(message);
    } catch (e) {
      loading(false);
      throw Exception(e.toString());
    }
  }

  Future<void> _fetchRoleCounts(HomeAdminModel model) async {
    final endpoints = {
      'seller': '/audit/v1/admin/sellers',
      'buyer': '/audit/v1/admin/buyers',
      'receiver': '/audit/v1/admin/receivers',
      'finance': '/audit/v1/admin/finances',
      'manager': '/audit/v1/admin/managers',
      'audit': '/audit/v1/admin/audits',
      'direksi': '/audit/v1/admin/direksi',
    };

    for (var entry in endpoints.entries) {
      try {
        final res = await ApiClient().dio.get(
          entry.value,
          queryParameters: {'per_page': 100},
        );
        if (res.statusCode == 200 || res.statusCode == 201) {
          final List list = (res.data['data'] is List) ? res.data['data'] : [];
          int activeCount = 0;
          int inactiveCount = 0;

          for (var item in list) {
            final status = item['status']?.toString().toLowerCase() ?? '';
            final isAct = item['active'] ?? item['is_active'] ?? item['user_data']?['active'] ?? item['seller_data']?['active'];

            if (status == 'active' || status == 'aktif' || isAct == 1 || isAct == true || isAct == '1') {
              activeCount++;
            } else {
              inactiveCount++;
            }
          }

          log("ROLE COUNT [${entry.key}]: active=$activeCount, inactive=$inactiveCount, total=${list.length}");

          switch (entry.key) {
            case 'seller':
              if (activeCount > 0 || model.userStatistics.activeUsers.seller == 0) {
                model.userStatistics.activeUsers.seller = activeCount;
              }
              model.userStatistics.inactiveUsers.seller = inactiveCount;
              break;
            case 'buyer':
              if (activeCount > 0 || model.userStatistics.activeUsers.buyer == 0) {
                model.userStatistics.activeUsers.buyer = activeCount;
              }
              model.userStatistics.inactiveUsers.buyer = inactiveCount;
              break;
            case 'receiver':
              if (activeCount > 0 || model.userStatistics.activeUsers.receiver == 0) {
                model.userStatistics.activeUsers.receiver = activeCount;
              }
              model.userStatistics.inactiveUsers.receiver = inactiveCount;
              break;
            case 'finance':
              model.userStatistics.activeUsers.finance = activeCount;
              model.userStatistics.inactiveUsers.finance = inactiveCount;
              break;
            case 'manager':
              model.userStatistics.activeUsers.manager = activeCount;
              model.userStatistics.inactiveUsers.manager = inactiveCount;
              break;
            case 'audit':
              model.userStatistics.activeUsers.audit = activeCount;
              model.userStatistics.inactiveUsers.audit = inactiveCount;
              break;
            case 'direksi':
              model.userStatistics.activeUsers.direksi = activeCount;
              model.userStatistics.inactiveUsers.direksi = inactiveCount;
              break;
          }
        }
      } catch (e) {
        log("FETCH ROLE COUNT ERROR (${entry.key}): $e");
      }
    }
  }

  BuyerProductModel _buyerProductModel = BuyerProductModel();

  BuyerProductModel get buyerProductModel => _buyerProductModel;

  set buyerProductModel(BuyerProductModel value) {
    _buyerProductModel = value;
  }

  List<String> selectedCategoryID = [];
  List<String> selectedCategory = [];

  Future<void> searchProduct({bool withLoading = false}) async {
    if (withLoading) loading(true);
    buyerProductModel = BuyerProductModel();

    final prefs = await SharedPreferences.getInstance();

    final categoryData = kategoriModel?.data ?? [];
    // selectedCategoryID = [];
    selectedCategory =
        kategoriMap.keys.where((e) => kategoriMap[e] == true).toList();
    log("KATEGORI SELECTED $selectedCategory");
    log("KATEGORI SELECTED $selectedCategoryID");
    selectedCategoryID = categoryData
        .where((item) => selectedCategory.contains(item?.nama))
        .map((item2) => item2?.ID ?? '0')
        .toList();
    // GET /api/products
    Map<String, String> body = {};
    if (searchController.text.isNotEmpty)
      body['search'] = searchController.text;
    if (minPrice.text.isNotEmpty && maxPrice.text.isNotEmpty) {
      body['min_price'] = minPrice.text;
      body['max_price'] = maxPrice.text;
    }
    if (sort != 0 && sort > 0) body['sort'] = '$sort';
    for (int i = 0; i < selectedCategoryID.length; i++)
      body['category_id[$i]'] = selectedCategoryID[i];

    try {
      final response = await ApiClient().dio.get('/products', queryParameters: body);
      if (response.statusCode == 201 || response.statusCode == 200) {
        buyerProductModel = BuyerProductModel.fromJson(response.data);
        notifyListeners();
        if (withLoading) loading(false);
      }
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? e.response?.data['messages']?['error'] ?? 'Terjadi kesalahan';
      loading(false);
      throw Exception(message);
    } catch (e) {
      loading(false);
      throw Exception(e.toString());
    }
  }

  BuyerProductModel _buyerHomeProductModel = BuyerProductModel();

  BuyerProductModel get buyerHomeProductModel => _buyerHomeProductModel;

  set buyerHomeProductModel(BuyerProductModel value) {
    _buyerHomeProductModel = value;
  }

  Future<void> getHomeProducts({bool withLoading = false}) async {
    if (withLoading) loading(true);
    buyerProductModel = BuyerProductModel();

    final prefs = await SharedPreferences.getInstance();
    String? userId = await prefs.getString(Constant.kSetPrefId) ?? "";

    final categoryData = kategoriModel?.data ?? [];
    // selectedCategoryID = [];
    selectedCategory =
        kategoriMap.keys.where((e) => kategoriMap[e] == true).toList();
    log("KATEGORI SELECTED $selectedCategory");
    selectedCategoryID = categoryData
        .where((item) => selectedCategory.contains(item?.nama))
        .map((item2) => item2?.ID ?? '0')
        .toList();
    // GET /api/products
    Map<String, String> body = {};
    if (searchController.text.isNotEmpty)
      body['search'] = searchController.text;
    if (minPrice.text.isNotEmpty && maxPrice.text.isNotEmpty) {
      body['min_price'] = minPrice.text;
      body['max_price'] = maxPrice.text;
    }
    if (sort != 0 && sort > 0) body['sort'] = '$sort';
    for (int i = 0; i < selectedCategoryID.length; i++)
      body['category_id[$i]'] = selectedCategoryID[i];

    try {
      final response = await ApiClient().dio.get('/products', queryParameters: body);
      if (response.statusCode == 201 || response.statusCode == 200) {
        buyerHomeProductModel = BuyerProductModel.fromJson(response.data);
        notifyListeners();
        if (withLoading) loading(false);
      }
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? e.response?.data['messages']?['error'] ?? 'Terjadi kesalahan';
      loading(false);
      throw Exception(message);
    } catch (e) {
      loading(false);
      throw Exception(e.toString());
    }
  }

  // KATEGORI
  KategoriModel? _kategoriModel;
  KategoriModel? get kategoriModel => this._kategoriModel;
  set kategoriModel(KategoriModel? value) => this._kategoriModel = value;

  Map<String, bool> _kategoriMap = {};
  Map<String, bool> get kategoriMap => this._kategoriMap;
  set kategoriMap(Map<String, bool> value) => this._kategoriMap = value;

  Future<void> fetchKategori({bool withLoading = false}) async {
    if (withLoading) loading(true);

    try {
      final response = await ApiClient().dio.get('/categories');

      if (response.statusCode == 201 || response.statusCode == 200) {
        kategoriModel = KategoriModel.fromJson(response.data);
        kategoriMap = Map.fromIterable(
          kategoriModel?.data ?? [],
          key: (k) => k.nama,
          value: (v) => false,
        );
        notifyListeners();
        if (withLoading) loading(false);
      }
    } on DioException catch (e) {
      final message = e.response?.data["message"] ?? e.message;
      loading(false);
      throw Exception(message);
    } catch (e) {
      loading(false);
      throw Exception(e.toString());
    }
  }

  // filter buyer and seller
  List<UserData> userData = [];
  /////////////
  BuyerAdminModel buyerAdminModel = BuyerAdminModel();
  Future<void> fetchBuyers(
      {bool withLoading = false, String search = ''}) async {
    if (withLoading) loading(true);

    Map<String, String> body = {};
    if (search.isNotEmpty) body['search'] = search;

    try {
      // GET /api/audit/v1/admin/buyers
      final response = await ApiClient().dio.get('/audit/v1/admin/buyers', queryParameters: body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        userData.clear();
        buyerAdminModel = BuyerAdminModel.fromJson(response.data);
        buyerAdminModel.data?.forEach((v) {
          userData.add(UserData(
              name1: v?.firstname,
              name2: v?.lastname,
              email: v?.email,
              id: v?.ID,
              alamat: v?.alamat));
        });

        notifyListeners();
        if (withLoading) loading(false);
      }
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? 'Terjadi kesalahan';
      loading(false);
      throw Exception(message);
    } catch (e) {
      loading(false);
      throw Exception(e.toString());
    }
  }

  SellerAdminModel sellerAdminModel = SellerAdminModel();
  Future<void> fetchSellers(
      {bool withLoading = false, String search = ''}) async {
    if (withLoading) loading(true);

    Map<String, dynamic> param = {};
    if (search.isNotEmpty) param['search'] = search;

    try {
      final response = await ApiClient().dio.get(
        '/audit/v1/admin/sellers',
        queryParameters: param,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        userData.clear();
        final parsed = SellerAdminModel.fromJson(response.data as Map<String, dynamic>);
        sellerAdminModel = parsed;
        final dataList = parsed.data ?? [];
    
        final rawDataList = response.data['data'] as List<dynamic>? ?? [];
        for (var i = 0; i < dataList.length; i++) {
          final item = dataList[i];
          final sellerData = item.sellerData;
          final sellerAddress = item.sellerAddress;

          Map<String, dynamic> rawItem = {};
          if (i < rawDataList.length && rawDataList[i] is Map<String, dynamic>) {
            rawItem = rawDataList[i] as Map<String, dynamic>;
          }
          final rawSellerData = (rawItem['seller_data'] is Map<String, dynamic>)
              ? rawItem['seller_data'] as Map<String, dynamic>
              : <String, dynamic>{};

          final dynamic activeVal = rawItem['status'] ??
              rawItem['active'] ??
              rawSellerData['status'] ??
              rawSellerData['active'] ??
              item.status ??
              item.active ??
              sellerData?.status ??
              sellerData?.active;

          bool isActive = false;
          if (activeVal != null) {
            final strVal = activeVal.toString().toLowerCase().trim();
            isActive = (strVal == '1' || strVal == 'active' || strVal == 'true' || strVal == 'aktif');
          }

          userData.add(
            UserData(
              name1: sellerData?.companyName ?? sellerData?.name ?? '',
              name2: sellerData?.ownerName ?? '',
              email: item.email ?? '',
              id: item.id?.toString() ?? '',
              alamat: sellerAddress?.fullAddress ?? sellerAddress?.cityName ?? '',
              status: isActive ? 'Aktif' : 'Tidak Aktif',
              rawModel: item,
            ),
          );
        }

        notifyListeners();
        if (withLoading) loading(false);
      } else {
        throw Exception("Gagal memuat data seller");
      }
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? 'Terjadi kesalahan';
      loading(false);
      throw Exception(message);
    } catch (e) {
      loading(false);
      throw Exception(e.toString());
    }
  }
}
