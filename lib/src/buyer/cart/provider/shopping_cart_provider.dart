import 'dart:convert';
import 'dart:developer';

import 'package:mspeed/common/base/base_response.dart';
import 'package:mspeed/common/component/custom_alert.dart';
import 'package:mspeed/common/component/custom_navigator.dart';
import 'package:mspeed/src/buyer/cart/model/buy_buyer_model.dart';
import 'package:mspeed/src/buyer/cart/model/riwayat_nego_model.dart';
import 'package:mspeed/src/buyer/cart/model/subdit_model.dart';
import 'package:mspeed/src/buyer/checkout/provider/checkout_provider.dart';
import 'package:mspeed/src/buyer/checkout/view/check_out_view.dart';
import 'package:provider/provider.dart';
import 'package:mspeed/common/base/base_controller.dart';
import 'package:mspeed/common/helper/constant.dart';
import 'package:mspeed/src/buyer/cart/model/checkout_model.dart';
import 'package:mspeed/src/buyer/cart/model/shopping_cart_confirm_model.dart';
import 'package:mspeed/src/buyer/cart/model/shopping_cart_model.dart';
import 'package:flutter/material.dart';
import 'package:mspeed/utils/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:string_validator/string_validator.dart';

class ShoppingCartProvider extends BaseController with ChangeNotifier {
  ShoppingCartModel shoppingCartModel = ShoppingCartModel();
  SubditModel subditModel = SubditModel();
  SubditModelData? selectedSubditModel = SubditModelData();
  RiwayatNegoModel riwayatNegoModel = RiwayatNegoModel();
  ShoppingCartConfirmModel shoppingCartConfirmModel =
      ShoppingCartConfirmModel();

  ShoppingCartModel get getShoppingCartModel => this.shoppingCartModel;
  SubditModel get getSubditModel => this.subditModel;
  SubditModelData? get getSelectedSubditModel => this.selectedSubditModel;
  RiwayatNegoModel get getRiwayatNegoModel => this.riwayatNegoModel;
  ShoppingCartConfirmModel get getShoppingCartConfirmModel =>
      this.shoppingCartConfirmModel;

  set setShoppingCartModel(ShoppingCartModel shoppingCartModel) =>
      this.shoppingCartModel = shoppingCartModel;
  set setSubditModel(SubditModel subditModel) => this.subditModel = subditModel;
  set setRiwayatNegoModel(RiwayatNegoModel riwayatNegoModel) =>
      this.riwayatNegoModel = riwayatNegoModel;
  set setSelectedSubditModel(SubditModelData? selectedSubditModel) {
    this.selectedSubditModel = selectedSubditModel;
    notifyListeners();
  }

  set setShoppingCartConfirmModel(
          ShoppingCartConfirmModel shoppingCartConfirmModel) =>
      this.shoppingCartConfirmModel = shoppingCartConfirmModel;

  ShoppingCartConfirmModelDataAddress? _selectedAddress =
      ShoppingCartConfirmModelDataAddress();
  ShoppingCartConfirmModelDataAddress? get selectedAddress =>
      this._selectedAddress;

  set selectedAddress(ShoppingCartConfirmModelDataAddress? value) {
    this._selectedAddress = value;
    notifyListeners();
  }

  TextEditingController catatanC = TextEditingController();
  TextEditingController negoC = TextEditingController();
  TextEditingController ongkirC = TextEditingController();

  FocusNode catatanNode = FocusNode();
  FocusNode negoNode = FocusNode();
  FocusNode ongkirNode = FocusNode();

  bool _isExpanded = false;
  bool get isExpanded => this._isExpanded;
  set isExpanded(bool value) {
    this._isExpanded = value;
    notifyListeners();
  }

  bool isChecked = false;
  double isPajak = 0;

  String? selectedStoreId;
  List<List<TextEditingController>> qtyListC = [];
  List<List<TextEditingController>> descListC = [];
  List<List<TextEditingController>> negoListC = [];
  List<List<TextEditingController>> catatanListC = [];
  List<List<bool>> itemListCheck = [];
  List<bool> storeListCheck = [];
  TextEditingController noteC = TextEditingController();

  setCheckItem(int index, int index2, bool val) {
    if (index >= 0 &&
        index < itemListCheck.length &&
        index2 >= 0 &&
        index2 < itemListCheck[index].length) {
      itemListCheck[index][index2] = val;
    } else {
      log("Index out of bounds");
      return; // Keluar dari fungsi jika indeks tidak valid
    }

    // Update status store berdasarkan kondisi item
    if (itemListCheck[index].every((e) => e)) {
      storeListCheck[index] = true;
    } else {
      storeListCheck[index] = false;
    }

    // Notify listeners untuk update UI
    notifyListeners();
  }

  setCheckItem1(BuildContext context, int index, int index2, bool val) {
    // log("INDEX CHECK : $index");
    bool change = true;
    for (int i = 0; i < itemListCheck.length; i++) {
      final item = itemListCheck[i];
      if (i != index) {
        for (int j = 0; j < item.length; i++) {
          final item2 = item[j];
          if (item2) {
            itemListCheck[i][j] = false;
            // change = true;
          }
        }
      }
    }
    if (!itemListCheck.any((e) => e == true) && val == false ||
        itemListCheck[index].contains(false)) {
      storeListCheck[index] = false;
    } else if (!itemListCheck.any((e) => e == false) && val == true ||
        itemListCheck[index].contains(true)) {
      storeListCheck[index] = true;
    }
    if (!itemListCheck.any((e) => e == true) &&
        itemListCheck[index] == false) if (change) {
      itemListCheck[index][index2] = val;
      notifyListeners();
    }
  }

  void clearListCheck() {
    for (int i = 0; i < itemListCheck.length; i++) {
      final item = itemListCheck[i];
      for (int j = 0; j < item.length; j++) {
        itemListCheck[i][j] = false;
      }
    }
  }

  void clearStoreListCheck() {
    for (int i = 0; i < storeListCheck.length; i++) {
      storeListCheck[i] = false;
    }
  }

  clearAllCart() {
    clearStoreListCheck();
    clearListCheck();
    clearSubditSelected();
    double total = countTotalCheckout();
    total = 0;
    ongkirC.text = "0";
    isPajak = 0;
    isExpanded = false;
  }

  double countShoppingCart() {
    double total = 0;
    final data = getShoppingCartModel.data ?? [];
    for (int i = 0; i < data.length; i++) {
      final cartData = data[i]?.detail ?? [];
      for (int j = 0; j < cartData.length; j++) {
        final item = cartData[j];
        if (itemListCheck[i][j]) {
          // total = total +
          //     (int.parse((item?.hargaAwal ?? "0")) *
          //         (int.parse(item?.qty ?? "0")));
          // if(item?.nego2 != null && item?.statusNego == null) {
          //   total = total +
          //       (int.parse((item?.nego2 ?? "0")) *
          //           (int.parse(item?.qty ?? "0")));
          // }else{
          total = total + (item?.hargaAkhir ?? 0);
          // }
        }
      }
      if (total >= 50000000) {
        Utils.showFailed(
            msg: "Nilai total tidak boleh lebih dari Rp 50.000.000");
      }
    }
    return total;
  }

  double countPajakCheckOut() {
    double pajak = 0;
    double pajakP = isPajak.toDouble();
    final ongkir = ongkirC.text != "" ? ongkirC.text : "0";

    final subtotal = countShoppingCart();
    pajak = (subtotal + ongkir.toDouble()) * (pajakP / 100);

    return pajak;
  }

  double countDpp() {
    final subtotal = countShoppingCart();
    final ongkir = (ongkirC.text != "" ? ongkirC.text : "0").toDouble();
    return (subtotal * (11 / 12)) + ongkir;
  }

  double _lastTotalCheckout = 0;

  double countTotalCheckout() {
    double total = 0;
    final pajak = countPajakCheckOut();
    final subtotal = countShoppingCart();
    final ongkir = ongkirC.text != "" ? ongkirC.text : "0";
    total = pajak + subtotal + ongkir.toDouble();
    // sementara tambah dpp (gak jadi)
    // + (int.tryParse(selectedSubditModel?.sisa ?? '0') ?? 0)
    log("TOTAL LAST : $total");

    // Hanya panggil notifyListeners jika nilai total berubah
    if (total != _lastTotalCheckout) {
      _lastTotalCheckout = total;
      notifyListeners();
    }

    return total;
  }

  int countQtyShoppingCart() {
    int totalQty = 0;
    for (int i = 0; i < (getShoppingCartModel.data ?? []).length; i++) {
      for (int j = 0;
          j < (getShoppingCartModel.data?[i]?.detail ?? []).length;
          j++) {
        if (itemListCheck[i][j]) {
          totalQty++;
        }
      }
    }
    return totalQty;
  }

  int countQtyCartItem() {
    int totalQty = 0;
    for (int i = 0; i < (getShoppingCartModel.data ?? []).length; i++) {
      totalQty =
          totalQty + (getShoppingCartModel.data?[i]?.detail ?? []).length;
    }
    return totalQty;
  }

  Future<void> fetchShoppingCart(BuildContext context,
      {bool withLoading = false}) async {
    try {
      if (withLoading) loading(true);

      // Mendapatkan userId dari SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString(Constant.kSetPrefId) ?? "";

      if (userId.isEmpty) {
        throw Exception("User ID tidak ditemukan. Silakan login ulang.");
      }

      // Mengatur parameter
      Map<String, String> param = {
        "user_id": userId,
      };

      // Melakukan request ke API
      final parsed = await getRest(Constant.BASE_API_FULL + '/carts');

      // Mengubah response JSON menjadi model ShoppingCartModel
      setShoppingCartModel = ShoppingCartModel.fromJson(parsed);
      notifyListeners();

      // Membersihkan list sebelum digunakan kembali
      qtyListC.clear();
      itemListCheck.clear();
      storeListCheck.clear();
      descListC.clear();
      negoListC.clear();
      catatanListC.clear();

      // Iterasi melalui toko
      for (int i = 0; i < (getShoppingCartModel.data ?? []).length; i++) {
        // Inisialisasi list untuk toko
        itemListCheck.add([]);
        storeListCheck.add(false);
        qtyListC.add([]);
        descListC.add([]);
        negoListC.add([]);
        catatanListC.add([]);

        // Iterasi melalui produk di setiap toko
        for (var item in getShoppingCartModel.data?[i]?.detail ?? []) {
          qtyListC[i].add(
            TextEditingController()
              ..text = item.qty.toString()
              ..selection = TextSelection.fromPosition(
                  TextPosition(offset: item.qty.toString().length)),
          );

          descListC[i].add(TextEditingController()..text = "");
          negoListC[i].add(TextEditingController()..text = "");
          catatanListC[i].add(TextEditingController()..text = "");
          itemListCheck[i].add(false); // Tambahkan produk ke checklist
        }
      }

      // Memanggil function untuk menghitung total item dalam cart
      countShoppingCart();
      notifyListeners();
    } catch (e) {
      throw Exception(e);
    } finally {
      if (withLoading) loading(false);
    }
  }

  Future<void> addToCart(BuildContext context,
      {required String produkId,
      required int qty,
      bool withLoading = false}) async {
    if (withLoading) loading(true);

    // Request body sesuai StoreCartRequest Laravel
    // Field: product_id, qty (catatan opsional)
    Map<String, dynamic> param = {
      "product_id": produkId.toString(), // Laravel menggunakan product_id (snake_case)
      "qty": qty.toString(),
    };

    try {
      final parsed = await postRest(Constant.BASE_API_FULL + '/carts', body: param);
      await Utils.showSuccess(msg: "Produk berhasil ditambahkan ke cart");
      await Future.delayed(Duration(seconds: 2));
    } catch (e) {
      CustomAlert.showSnackBar(
        context,
        e.toString().replaceAll('Exception: ', ''),
        true,
      );
      throw Exception(e);
    } finally {
      if (withLoading) loading(false);
    }
  }

  Future<void> updateProductCart(BuildContext context,
      {required int cartId,
      required int qty,
      required String note,
      bool withLoading = false}) async {
    if (withLoading) loading(true);

    try {
      // PUT /api/carts/{id} — UpdateCartRequest Laravel
      final parsed = await postRest(
        Constant.BASE_API_FULL + '/carts/$cartId',
        body: {'_method': 'PUT', 'qty': qty.toString()}
      );
      fetchShoppingCart(context);
    } catch (e) {
      throw Exception(e);
    } finally {
      if (withLoading) loading(false);
    }
  }

  Future<void> deleteProductCart(BuildContext context,
      {required String cartId, bool withLoading = false}) async {
    if (withLoading) loading(true);

    try {
      final parsed = await deleteRest(Constant.BASE_API_FULL + '/carts/$cartId');
      fetchShoppingCart(context);
    } catch (e) {
      throw Exception(e);
    } finally {
      if (withLoading) loading(false);
    }
  }

  Future<void> fetchBuyNowCartConfirm(BuildContext context,
      {bool withLoading = false, int index = 0}) async {
    // API /cart/confirm sudah tidak digunakan di backend Laravel yang baru.
    // Perhitungan pajak dan subtotal sudah berjalan di lokal Flutter (countTotalCheckout).
    // Alamat default juga akan dipilih secara lokal dari addressProvider.
    
    if (withLoading) loading(true);
    await Future.delayed(Duration(milliseconds: 300));
    
    // Mock successful model state
    final model = ShoppingCartConfirmModel(
      success: true,
      data: ShoppingCartConfirmModelData(),
    );
    setShoppingCartConfirmModel = model;
    
    if (withLoading) loading(false);
  }

  Future<void> fetchSubdit(BuildContext context,
      {bool withLoading = true}) async {
    if (withLoading) loading(true);

    final prefs = await SharedPreferences.getInstance();
    String? subditId = await prefs.getString(Constant.kSetPrefSubditId) ?? "";

    final response = await get(Constant.BASE_API_FULL + '/sub-direktorates',
        body: {'subdit_id': subditId});

    if (response.statusCode == 201 || response.statusCode == 200) {
      subditModel = SubditModel.fromJson(jsonDecode(response.body));

      notifyListeners();
      if (withLoading) loading(false);
    } else {
      final message = jsonDecode(response.body)["messages"]["error"];
      loading(false);
      throw Exception(message);
    }
  }

  clearSubditSelected() {
    selectedSubditModel = null;
  }

  Future<void> fetchRiwayatNego(BuildContext context,
      {bool withLoading = true, required String productId}) async {
    if (withLoading) loading(true);

    // GET /api/negos?product_id={productId} — endpoint baru Laravel
    // Filter nego berdasarkan product_id milik user yang sedang login
    final response = await get(
      Constant.BASE_API_FULL + '/negos',
      body: {'product_id': productId},
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      riwayatNegoModel = RiwayatNegoModel.fromJson(jsonDecode(response.body));
      notifyListeners();
      if (withLoading) loading(false);
    } else {
      final decoded = jsonDecode(response.body);
      final message = decoded["message"] ?? decoded["messages"]?["error"] ?? 'Terjadi kesalahan';
      loading(false);
      throw Exception(message);
    }
  }

  CheckoutModel _checkoutModel = CheckoutModel();
  BuyBuyerModel _buyBuyerModel = BuyBuyerModel();
  CheckoutModel get checkoutModel => this._checkoutModel;
  BuyBuyerModel get buyBuyerModel => this._buyBuyerModel;

  set checkoutModel(CheckoutModel value) => this._checkoutModel = value;
  set buyBuyerModel(BuyBuyerModel value) => this._buyBuyerModel = value;

  Future<BaseResponse> sendNego(BuildContext context,
      {bool withLoading = false,
      required int index,
      required int indexx,
      required String productId}) async {
    // POST /api/negos — StoreNegoRequest Laravel
    // Fields: product_id, price (harga nego yang diajukan buyer)
    Map<String, String> param = {
      "product_id": productId,
      "price": negoListC[index][indexx].text.replaceAll(".", ""),
    };

    loading(true);
    // POST /api/negos sesuai kontrak baru Laravel
    final response = BaseResponse.from(
        await post(Constant.BASE_API_FULL + '/negos', body: param));
    loading(false);

    await Utils.showSuccess(msg: "Berhasil mengajukan nego");

    if (response.success) {
      return response;
    } else {
      final message = response.message;
      throw Exception(message);
    }
  }

  Future<BaseResponse> setSubditDpp(BuildContext context,
      {bool withLoading = false, required String dppId}) async {
    final prefs = await SharedPreferences.getInstance();
    String? userId = await prefs.getString(Constant.kSetPrefId) ?? "";
    // parameters
    Map<String, String> param = {
      "dpp_id": dppId,
      "buyer_id": userId,
    };
    loading(true);
    // response
    final response = BaseResponse.from(
        await post(Constant.BASE_API_FULL + '/setdppbuyer', body: param));
    loading(false);

    if (response.success) {
      await Utils.showSuccess(msg: "Berhasil memilih DPP!");
      Future.delayed(Duration(seconds: 2));
      return response;
    } else {
      final message = response.message;
      await Utils.showFailed(msg: message);
      Future.delayed(Duration(seconds: 2));
      throw Exception(message);
    }
  }

  Future<BaseResponse> sendCatatan(BuildContext context,
      {bool withLoading = false,
      required int index,
      required int indexx,
      required String cartId}) async {
    // PUT /api/carts/{cartId} — UpdateCartRequest Laravel
    // Mengirim catatan/note melalui update cart item
    Map<String, String> param = {
      "_method": "PUT",
      "note": catatanListC[index][indexx].text,
    };
    loading(true);
    // PUT /api/carts/{cartId} sesuai kontrak baru Laravel
    final response = BaseResponse.from(await post(
        Constant.BASE_API_FULL + '/carts/$cartId',
        body: param));
    loading(false);

    await Utils.showSuccess(msg: "Berhasil menambah catatan");

    if (response.success) {
      return response;
    } else {
      final message = response.message;
      throw Exception(message);
    }
  }

  Future<void> sendBuyBuyer(BuildContext context,
      {bool withLoading = false, required String sellerId}) async {
    if (withLoading) loading(true);

    // POST /api/parent-orders dipindahkan ke halaman CheckOut (saat menekan tombol Bayar).
    // Di sini kita cukup memvalidasi secara lokal dan lanjut ke CheckoutView.
    
    // Asumsi: cart_ids atau item yang dipilih sudah tersimpan di state provider ini.
    // Kita hanya perlu delay sejenak untuk mensimulasikan proses, lalu pindah halaman.
    await Future.delayed(Duration(milliseconds: 300));
    
    if (withLoading) loading(false);

    // Navigasi ke Checkout
    await CusNav.nPush(context, CheckOutView());
    notifyListeners();
  }
}
