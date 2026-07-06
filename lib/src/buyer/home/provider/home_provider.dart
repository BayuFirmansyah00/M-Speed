import 'dart:async';
import 'dart:convert';

import 'package:mspeed/common/base/base_controller.dart';
import 'package:mspeed/common/helper/constant.dart';
import 'package:mspeed/src/buyer/home/model/buyer_product_model.dart';
import 'package:mspeed/src/buyer/home/model/home_model.dart';
import 'package:flutter/material.dart';
import 'package:mspeed/src/buyer/home/model/kategori_lokasi_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/kategori_model.dart';

class HomeProvider extends BaseController with ChangeNotifier {
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

  Future<void> fetchHome({bool withLoading = false}) async {
    if (withLoading) loading(true);

    final response =
        await post(Constant.BASE_API_FULL + '/dashboard/dashboard/get');

    if (response.statusCode == 201 || response.statusCode == 200) {
      setHomeModel = HomeModel.fromJson(jsonDecode(response.body));
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
  List<String> selectedLocationCategory = [];

  Future<void> searchProduct({bool withLoading = false}) async {
    if (withLoading) loading(true);
    buyerProductModel = BuyerProductModel();

    final prefs = await SharedPreferences.getInstance();
    String? userId = await prefs.getString(Constant.kSetPrefId) ?? "";

    final categoryData = kategoriModel?.data ?? [];
    // selectedCategoryID = [];
    selectedCategory =
        kategoriMap.keys.where((e) => kategoriMap[e] == true).toList();

    selectedLocationCategory = kategoriLokasiMap.keys
        .where((e) => kategoriLokasiMap[e] == true)
        .toList();

    // log("KATEGORI SELECTED $selectedCategory");
    // log("KATEGORI SELECTED $selectedCategoryID");
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

    for (var i = 0; i < selectedLocationCategory.length; i++) {
      body.addAll({'kota[$i]': selectedLocationCategory[i]});
    }

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
    // log("KATEGORI SELECTED $selectedCategory");
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

  KategoriLokasiModel? _kategoriLokasiModel;
  KategoriLokasiModel? get kategoriLokasiModel => this._kategoriLokasiModel;
  set kategoriLokasiModel(KategoriLokasiModel? value) =>
      this._kategoriLokasiModel = value;

  Map<String, bool> _kategoriLokasiMap = {};
  Map<String, bool> get kategoriLokasiMap => this._kategoriLokasiMap;
  set kategoriLokasiMap(Map<String, bool> value) =>
      this._kategoriLokasiMap = value;

  Future<void> fetchKategoriLokasi({bool withLoading = false}) async {
    if (withLoading) loading(true);

    final response = await get(Constant.BASE_API_FULL + '/getallkota');

    if (response.statusCode == 201 || response.statusCode == 200) {
      kategoriLokasiModel =
          KategoriLokasiModel.fromJson(jsonDecode(response.body));
      kategoriLokasiMap = Map.fromIterable(
        kategoriLokasiModel?.data ?? [],
        key: (k) => k.kota ?? 'Unknown',
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

  void resetFilters() {
    _kategoriMap.updateAll((key, value) => false);
    _kategoriLokasiMap.updateAll((key, value) => false);
    maxPrice.clear();
    minPrice.clear();
    notifyListeners();
  }

  Function(List<String>) _onSelected = (p0) {};
  Function(List<String>) get onSelected => _onSelected;

  set selectLocation(Function(List<String>) newValue) {
    _onSelected = newValue;
    notifyListeners();
  }

  set updateLocation(List<String> selectedItems) {
    _onSelected(selectedItems);
    notifyListeners();
  }

  void updateSelectedLocations() {
    final filter = _kategoriLokasiMap;
    final selectedKeys =
        filter.keys.where((key) => filter[key] == true).toList();
    updateLocation = selectedKeys;
  }
}
