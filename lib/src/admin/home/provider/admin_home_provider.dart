import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:mspeed/common/base/base_controller.dart';
import 'package:mspeed/common/helper/constant.dart';
import 'package:mspeed/src/admin/home/model/buyer_admin_model.dart';
import 'package:mspeed/src/admin/home/model/home_admin_model.dart';
import 'package:mspeed/src/admin/home/model/seller_admin_model.dart';
import 'package:mspeed/src/admin/user/view/user_data_admin_view.dart';
import 'package:mspeed/src/buyer/home/model/buyer_product_model.dart';
import 'package:mspeed/src/buyer/home/model/home_model.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/kategori_model.dart';

class AdminHomeProvider extends BaseController with ChangeNotifier {
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
    var userId = await prefs.getString(Constant.kSetPrefId);
    var firstName = await prefs.getString(Constant.kSetPrefFirstName);
    var lastName = await prefs.getString(Constant.kSetPrefLastName);
    name = ((firstName ?? '') + ' ' + (lastName ?? '')).trim();
    email = await prefs.getString(Constant.kSetPrefEmail);
    Map<String, String> body = {'status': selectedPeriodeData ?? '0'};
    if (selectedPeriodeData == '1' && selectedDate != null)
      body.addAll({
        'date': DateFormat('yyyy-MM-dd').format(selectedDate!),
      });

    if (selectedPeriodeData == '2' &&
        selectedMonth != null &&
        selectedYear != null)
      body.addAll({
        'month': selectedMonth!,
        'year': selectedYear!,
      });

    if (selectedPeriodeData == '3' && selectedYear != null)
      body.addAll({'year': selectedYear!});

    if (filterType == 0 && selectedSellerBuyerId != null)
      body.addAll({'seller': selectedSellerBuyerId ?? ''});
    else if (filterType == 1 && selectedSellerBuyerId != null)
      body.addAll({'buyer': selectedSellerBuyerId ?? ''});

    final response = await get(
      Constant.BASE_API_FULL + '/dashboardadmin',
      body: body,
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      homeAdminModel = HomeAdminModel.fromJson(jsonDecode(response.body));
      final chart = homeAdminModel.data?.pembelian;
      final transactionChart = homeAdminModel.data?.transaksi;
      for (int i = 0; i < (chart?.length ?? 0); i++) {
        var val = chart?[i] ?? 0;
        if (val >= biggestGraphVal) biggestGraphVal = val;
        graphList.add(FlSpot(i.toDouble(), val.toDouble()));
      }
      for (int i = 0; i < (transactionChart?.length ?? 0); i++) {
        var val = transactionChart?[i] ?? 0;
        if (val >= biggestTransactionGraphVal) biggestTransactionGraphVal = val;
      }
      notifyListeners();

      if (withLoading) loading(false);
    } else {
      final message = jsonDecode(response.body)["messages"]["error"];
      loading(false);
      throw Exception(message);
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
    String? userId = await prefs.getString(Constant.kSetPrefId) ?? "";

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
    Map<String, String> body = {/*'ID': userId*/};
    if (searchController.text.isNotEmpty)
      body.addAll({'search': searchController.text});
    if (minPrice.text.isNotEmpty && maxPrice.text.isNotEmpty) {
      body.addAll({'min_price': minPrice.text});
      body.addAll({'max_price': maxPrice.text});
    }

    if (sort != 0 && sort > 0) body.addAll({'sort': '$sort'});
    for (int i = 0; i < selectedCategoryID.length; i++)
      body.addAll({'kategori[$i]': selectedCategoryID[i]});

    final response =
        await get(Constant.BASE_API_FULL + '/getbuyerproduk', body: body);
    if (response.statusCode == 201 || response.statusCode == 200) {
      buyerProductModel = BuyerProductModel.fromJson(jsonDecode(response.body));
      notifyListeners();

      if (withLoading) loading(false);
    } else {
      final message = jsonDecode(response.body)["messages"]["error"];
      loading(false);
      throw Exception(message);
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
    Map<String, String> body = {/*'ID': userId*/};
    if (searchController.text.isNotEmpty)
      body.addAll({'search': searchController.text});
    if (minPrice.text.isNotEmpty && maxPrice.text.isNotEmpty) {
      body.addAll({'min_price': minPrice.text});
      body.addAll({'max_price': maxPrice.text});
    }

    if (sort != 0 && sort > 0) body.addAll({'sort': '$sort'});
    for (int i = 0; i < selectedCategoryID.length; i++)
      body.addAll({'kategori[$i]': selectedCategoryID[i]});

    final response =
        await get(Constant.BASE_API_FULL + '/getbuyerproduk', body: body);
    if (response.statusCode == 201 || response.statusCode == 200) {
      buyerHomeProductModel =
          BuyerProductModel.fromJson(jsonDecode(response.body));
      notifyListeners();

      if (withLoading) loading(false);
    } else {
      final message = jsonDecode(response.body)["messages"]["error"];
      loading(false);
      throw Exception(message);
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

    final response = await get(Constant.BASE_API_FULL + '/getallkategori');

    if (response.statusCode == 201 || response.statusCode == 200) {
      kategoriModel = KategoriModel.fromJson(jsonDecode(response.body));
      kategoriMap = Map.fromIterable(
        kategoriModel?.data ?? [],
        key: (k) => k.nama,
        value: (v) => false,
      );
      notifyListeners();
      if (withLoading) loading(false);
    } else {
      final message = jsonDecode(response.body)["messages"]["error"];
      loading(false);
      throw Exception(message);
    }
  }

  // filter buyer and seller
  List<UserData> userData = [];
  /////////////
  BuyerAdminModel buyerAdminModel = BuyerAdminModel();
  Future<void> fetchBuyers(
      {bool withLoading = false, String search = ''}) async {
    if (withLoading) loading(true);

    final response =
        await get(Constant.BASE_API_FULL + '/getbuyeradmin', body: {});

    if (response.statusCode == 201 || response.statusCode == 200) {
      userData.clear();
      buyerAdminModel = BuyerAdminModel.fromJson(jsonDecode(response.body));
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
    } else {
      final message = jsonDecode(response.body)["messages"]["error"];
      loading(false);
      throw Exception(message);
    }
  }

  SellerAdminModel sellerAdminModel = SellerAdminModel();
  Future<void> fetchSellers(
      {bool withLoading = false, String search = ''}) async {
    if (withLoading) loading(true);

    final response =
        await get(Constant.BASE_API_FULL + '/getselleradmin', body: {});

    if (response.statusCode == 201 || response.statusCode == 200) {
      userData.clear();
      sellerAdminModel = SellerAdminModel.fromJson(jsonDecode(response.body));
      notifyListeners();
      sellerAdminModel.data?.forEach((v) {
        userData.add(UserData(
            name1: v?.nama,
            name2: v?.namaPemilik,
            email: v?.email,
            id: v?.ID,
            alamat: v?.alamat,
            status: v?.status));
      });

      notifyListeners();

      if (withLoading) loading(false);
    } else {
      final message = jsonDecode(response.body)["messages"]["error"];
      loading(false);
      throw Exception(message);
    }
  }
}
