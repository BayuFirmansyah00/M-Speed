import 'dart:convert';
import 'dart:developer';

import 'package:easy_localization/easy_localization.dart';
import 'package:mspeed/common/component/custom_navigator.dart';
import 'package:mspeed/src/buyer/cart/model/buy_buyer_model.dart';
import 'package:mspeed/src/buyer/checkout/model/checkout_model.dart';
import 'package:mspeed/src/buyer/checkout/model/do_checkout_model.dart';
import 'package:mspeed/src/buyer/transaction/view/detail_transaction_view.dart';
import 'package:provider/provider.dart';
import 'package:mspeed/common/base/base_controller.dart';
import 'package:mspeed/common/helper/constant.dart';
import 'package:mspeed/src/buyer/address/provider/address_provider.dart';
import 'package:flutter/material.dart';
import 'package:mspeed/src/buyer/cart/provider/shopping_cart_provider.dart';
import 'package:mspeed/src/buyer/checkout/model/checkout_option_payment_model.dart';
import 'package:mspeed/src/buyer/checkout/model/checkout_option_shipping_model.dart';
import 'package:mspeed/utils/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CheckOutProvider extends BaseController with ChangeNotifier {
  CheckoutOptionPaymentModel checkoutOptionPaymentModel =
      CheckoutOptionPaymentModel();
  CheckoutOptionShippingModel checkoutOptionShippingModel =
      CheckoutOptionShippingModel();
  CheckoutModel checkoutModel = CheckoutModel();
  BuyBuyerModel buyBuyerModel = BuyBuyerModel();
  DoCheckoutModel doCheckoutModel = DoCheckoutModel();

  CheckoutOptionPaymentModel get getCheckoutOptionPaymentModel =>
      this.checkoutOptionPaymentModel;
  CheckoutModel get getCheckoutModel => this.checkoutModel;
  DoCheckoutModel get getDoCheckoutModel => this.doCheckoutModel;

  CheckoutOptionShippingModel get getCheckoutOptionShippingModel =>
      this.checkoutOptionShippingModel;
  BuyBuyerModel get getBuyBuyerModel => this.buyBuyerModel;

  set setCheckoutOptionPaymentModel(
          CheckoutOptionPaymentModel checkoutOptionPaymentModel) =>
      this.checkoutOptionPaymentModel = checkoutOptionPaymentModel;

  set setCheckoutOptionShippingModel(
          CheckoutOptionShippingModel checkoutOptionShippingModel) =>
      this.checkoutOptionShippingModel = checkoutOptionShippingModel;
  set setCheckoutModel(CheckoutModel checkoutModel) =>
      this.checkoutModel = checkoutModel;
  set setDoCheckoutModel(DoCheckoutModel doCheckoutModel) =>
      this.doCheckoutModel = doCheckoutModel;
  set setBuyBuyer(BuyBuyerModel buyBuyerModel) =>
      this.buyBuyerModel = buyBuyerModel;

  TextEditingController startDateC = TextEditingController();
  TextEditingController endDateC = TextEditingController();

  DateTime? _startDate;

  DateTime? get startDate => _startDate;

  setStartDate(DateTime? date) {
    _startDate = date;
    if (date != null)
      startDateC.text =
          DateFormat("dd-MM-yyyy").format(date ?? DateTime.now()).toString();
    notifyListeners();
  }

  DateTime? _endDate;

  DateTime? get endDate => _endDate;

  setEndDate(DateTime? date) {
    _endDate = date;
    if (date != null)
      endDateC.text =
          DateFormat("dd-MM-yyyy").format(date ?? DateTime.now()).toString();
    notifyListeners();
  }

  Future<void> fetchCheckOutPayment(BuildContext context,
      {bool withLoading = false}) async {
    if (withLoading) loading(true);

    final response = await get(Constant.BASE_API_FULL + '/option-payment');

    if (response.statusCode == 201 || response.statusCode == 200) {
      setCheckoutOptionPaymentModel =
          CheckoutOptionPaymentModel.fromJson(jsonDecode(response.body));
      // for (var item in getCheckoutOptionPaymentModel.data?.item ?? []) {
      //   qtyListC.add(TextEditingController()..text = item.qty.toString());
      //   itemListCheck.add(false);
      // }

      notifyListeners();

      if (withLoading) loading(false);
    } else {
      final message = jsonDecode(response.body)["messages"]["error"];
      loading(false);
      if (message.toString().contains("Unauthorized")) {
        Utils.showFailed(msg: "Unauthorized");
        Future.delayed(Duration(seconds: 1)).then((value) {
          Navigator.pushReplacementNamed(context, '/login');
        });
      }
      throw Exception(message);
    }
  }

  CheckoutOptionShippingModelShippingListTypeList? _selectedShipping;

  CheckoutOptionShippingModelShippingListTypeList? get selectedShipping =>
      this._selectedShipping;

  set selectedShipping(CheckoutOptionShippingModelShippingListTypeList? value) {
    this._selectedShipping = value;
    notifyListeners();
  }

  Future<void> fetchCheckOutShipping(BuildContext context,
      {bool withLoading = false}) async {
    try {
      if (withLoading) loading(true);

      Map<String, String> body = {};
      int id = 0;
      final sCartData =
          context.read<ShoppingCartProvider>().getShoppingCartModel.data;
      final addressData =
          context.read<AddressProvider>().getAddressShippingList.data;
      if (addressData != null && addressData.isNotEmpty) {
        body.addAll({'address_id': '${addressData.first?.id ?? 0}'});

        for (int i = 0; i < (sCartData ?? []).length; i++) {
          for (int j = 0; j < (sCartData?[i]?.detail ?? []).length; j++) {
            final item = sCartData?[i]?.detail?[j];
            body.addAll({'product_id[$j]': '${item?.IDProduk ?? 0}'});
            body.addAll({'qty[$j]': '${item?.qty ?? 0}'});
          }
        }
        log("Sdcaert : ${sCartData!.length}");
        if ((sCartData ?? []).isNotEmpty) {
          id = int.parse(sCartData.first?.SellerID ?? "");
          body.addAll({'store_id': id.toString()});
        }
        final response = await get(
            Constant.BASE_API_FULL + '/checkout/shipping-options',
            body: body);
        log("RESPONSE COY : ${response}");
        if (response.statusCode == 201 || response.statusCode == 200) {
          setCheckoutOptionShippingModel =
              // CheckoutOptionShippingModel.fromJson(b);
              CheckoutOptionShippingModel.fromJson(jsonDecode(response.body));
          // for (var item in getCheckoutOptionPaymentModel.data?.item ?? []) {
          //   qtyListC.add(TextEditingController()..text = item.qty.toString());
          //   itemListCheck.add(false);
          // }

          notifyListeners();

          if (withLoading) loading(false);
        } else {
          final message = jsonDecode(response.body)["messages"]["error"];
          loading(false);
          if (message.toString().contains("Unauthorized")) {
            Utils.showFailed(msg: "Unauthorized");
            Future.delayed(Duration(seconds: 1)).then((value) {
              Navigator.pushReplacementNamed(context, '/login');
            });
          }
          throw Exception(message);
        }
      } else {
        setCheckoutOptionShippingModel = CheckoutOptionShippingModel();
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> fetchCheckout(BuildContext context,
      {bool withLoading = true}) async {
    try {
      if (withLoading) loading(true);

      final prefs = await SharedPreferences.getInstance();
      String? userId = await prefs.getString(Constant.kSetPrefId) ?? "";
      String? tempId = await prefs.getString(Constant.kSetIdTemp) ?? "";

      Map<String, String> param = {
        "user_id": userId,
        "temp_order_id": tempId,
      };

      final response =
          await get(Constant.BASE_API_FULL + '/checkout/summary', body: param);

      if (response.statusCode == 201 || response.statusCode == 200) {
        checkoutModel = CheckoutModel.fromJson(jsonDecode(response.body));
        notifyListeners();
      } else {
        final message = jsonDecode(response.body)["messages"]["error"];
        throw Exception(message);
      }
    } catch (e) {
      throw Exception(e);
    } finally {
      loading(false);
    }
  }

  Future<void> fetchCheckOutBuy(BuildContext context,
      {bool withLoading = false}) async {
    try {
      if (withLoading) loading(true);

      final prefs = await SharedPreferences.getInstance();
      String? tempOrderId = await prefs.getString(Constant.kSetIdTemp) ?? "";

      Map<String, String> body = {};

      final addressData =
          context.read<AddressProvider>().getAddressShippingList.data;
      if (addressData != null && addressData.isNotEmpty) {
        body.addAll({'address_id': '${addressData.first?.id ?? 0}'});
      }

      // final productD =
      //     context.read<ProductProvider>().getProductDetailModel.data;
      // final qty = context.read<ProductProvider>().quantity;
      // body.addAll({'store_id': (productD?.storeId ?? 0).toString()});
      // body.addAll({'product_id[0]': (productD?.id ?? 0).toString()});
      // body.addAll({'qty[0]': qty.toString()});

      final response =
          await get(Constant.BASE_API_FULL + '/checkout/summary', body: body);
      log("RESPONSE COY : ${response}");
      if (response.statusCode == 201 || response.statusCode == 200) {
        setCheckoutOptionShippingModel =
            // CheckoutOptionShippingModel.fromJson(b);
            CheckoutOptionShippingModel.fromJson(jsonDecode(response.body));
        // for (var item in getCheckoutOptionPaymentModel.data?.item ?? []) {
        //   qtyListC.add(TextEditingController()..text = item.qty.toString());
        //   itemListCheck.add(false);
        // }

        notifyListeners();

        if (withLoading) loading(false);
      } else {
        final message = jsonDecode(response.body)["messages"]["error"];
        loading(false);
        if (message.toString().contains("Unauthorized")) {
          Utils.showFailed(msg: "Unauthorized");
          Future.delayed(Duration(seconds: 1)).then((value) {
            Navigator.pushReplacementNamed(context, '/login');
          });
        }
        throw Exception(message);
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  clearDateCheckout() {
    startDateC.clear();
    endDateC.clear();
  }

  Future<void> sendCheckout(BuildContext context,
      {bool withLoading = false, int index = 0}) async {
    if (withLoading) loading(true);
    final cartP = context.read<ShoppingCartProvider>();
    final addressP = context.read<AddressProvider>();

    final prefs = await SharedPreferences.getInstance();
    String? userId = await prefs.getString(Constant.kSetPrefId) ?? "";
    String? tempId = await prefs.getString(Constant.kSetIdTemp) ?? "";

    Map<String, String> param = {
      // "cart_id": "",
      // "address_id": "",
      // "tax_id": noteC.text,
      // "shipping_id": noteC.text,
      // "paymenyt_id": noteC.text,
    };
    param.addAll({'pajak': '${cartP.countPajakCheckOut()}'});
    param.addAll({'ongkir': '${cartP.ongkirC.text}'});
    param.addAll({
      'estPengiriman': DateFormat('yyyy-mm-dd')
          .format(DateFormat("dd-mm-yyyy").parse(startDateC.text))
    });
    param.addAll({
      'estPengiriman2': DateFormat('yyyy-mm-dd')
          .format(DateFormat("dd-mm-yyyy").parse(endDateC.text))
    });
    param.addAll({'buyer_id': userId});
    param.addAll(
        {'seller_id': '${getCheckoutModel.data?.produk?.first?.SellerID}'});
    param.addAll({'temp_order_id': tempId});
    param.addAll({'penerima_id': addressP.selectedPenerimaID ?? ""});
    param.addAll({'keterangan': "a"});

    final response =
        await post(Constant.BASE_API_FULL + '/checkout', body: param);

    if (response.statusCode == 201 || response.statusCode == 200) {
      checkoutModel = CheckoutModel.fromJson(jsonDecode(response.body));
      doCheckoutModel = DoCheckoutModel.fromJson(jsonDecode(response.body));
      clearDateCheckout();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          Constant.kSetParentId, "${doCheckoutModel.parentId ?? 0}");
      log("ISII PARENTID : ${doCheckoutModel.parentId}");
      String? parentId = await prefs.getString(Constant.kSetParentId) ?? "";
      await CusNav.nPop(context);
      await Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => DetailTransactionView(
                  transaction_id: parentId,
                  seller_id:
                      getCheckoutModel.data?.produk?.first?.SellerID ?? "0")));
      // String? parentId = await prefs.getString(Constant.kSetParentId) ?? "";
      // await Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => DetailTransactionView(transaction_id: parentId, seller_id: getCheckoutModel.data?.produk?.first?.SellerID ?? "0")));
      notifyListeners();

      if (withLoading) loading(false);
      // return checkoutModel.data?.invoiceUrl ?? "";
    } else {
      final message = jsonDecode(response.body)["messages"]["error"];
      loading(false);
      throw Exception(message);
    }
  }
}
