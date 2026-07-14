import 'dart:convert';

import 'package:mspeed/common/base/base_controller.dart';
import 'package:mspeed/common/component/custom_alert.dart';
import 'package:mspeed/common/helper/constant.dart';
import 'package:mspeed/src/buyer/wishlist/model/buyer_seller_favorit_model.dart';
import 'package:mspeed/src/buyer/wishlist/model/buyer_wishlist_model.dart';
import 'package:mspeed/src/buyer/wishlist/model/detail_seller_buyer.dart';
import 'package:mspeed/src/buyer/wishlist/model/wishlist_detail_model.dart';
import 'dart:async';

// import 'package:mspeed/src/savedcart/model/saved_shopping_cart_model.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WishlistProvider extends BaseController with ChangeNotifier {
  // WishlistModel wishlistModel = WishlistModel();
  WishlistDetailModel wishlistDetailModel = WishlistDetailModel();

  DetailSellerBuyer _detailSellerBuyer = DetailSellerBuyer();
  DetailSellerBuyer get detailSellerBuyer => this._detailSellerBuyer;
  set detailSellerBuyer(DetailSellerBuyer value) =>
      this._detailSellerBuyer = value;

  TextEditingController namaKoleksiC = TextEditingController();

  TextEditingController wishlistSearchController = TextEditingController();
  TextEditingController sellerFavoritSearchController = TextEditingController();
  Duration duration = const Duration(seconds: 2);
  Timer? _searchOnStoppedTyping;

  Timer? get searchOnStoppedTyping => this._searchOnStoppedTyping;

  set searchOnStoppedTyping(Timer? value) {
    this._searchOnStoppedTyping = value;
    notifyListeners();
  }

  // WishlistModel get getWishListModel => this.wishlistModel;
  // WishlistDetailModel get getWishListDetailModel => this.wishlistDetailModel;
  //
  // set setWishlistModel(WishlistModel wishlistModel) =>
  //     this.wishlistModel = wishlistModel;
  // set setWishlistDetailModel(WishlistDetailModel wishlistDetailModel) =>
  //     this.wishlistDetailModel = wishlistDetailModel;

  BuyerWishlistModel _wishlistModel = BuyerWishlistModel();

  BuyerWishlistModel get wishlistModel => _wishlistModel;

  set wishlistModel(BuyerWishlistModel value) {
    _wishlistModel = value;
    notifyListeners();
  }

  Future<void> fetchWishlist({bool withLoading = false}) async {
    if (withLoading) loading(true);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString(Constant.kSetPrefId) ?? '';
    Map<String, String> body = {'user_id': userId};

    // if (wishlistSearchController.text.isNotEmpty)
    //   body.addAll({'search': wishlistSearchController.text});
    final response =
        await get(Constant.BASE_API_FULL + '/wishlists', body: body);

    if (response.statusCode == 201 || response.statusCode == 200) {
      // setWishlistModel = WishlistModel.fromJson(jsonDecode(response.body));
      wishlistModel = BuyerWishlistModel.fromJson(jsonDecode(response.body));
      notifyListeners();

      if (withLoading) loading(false);
    } else {
      final message = jsonDecode(response.body)["messages"]["error"];
      loading(false);
      throw Exception(message);
    }
  }

  BuyerSellerFavoritModel _sellerFavorite = BuyerSellerFavoritModel();

  BuyerSellerFavoritModel get sellerFavorite => _sellerFavorite;

  set sellerFavorite(BuyerSellerFavoritModel value) {
    _sellerFavorite = value;
  }

  Future<void> fetchSellerWishlist({bool withLoading = false}) async {
    if (withLoading) loading(true);

    final prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString(Constant.kSetPrefId) ?? '';

    Map<String, String> body = {'user_id': userId};
    if (sellerFavoritSearchController.text.isNotEmpty)
      body.addAll({'search': sellerFavoritSearchController.text});
    final response = await get(
        Constant.BASE_API_FULL + '/getbuyersellerfavorit',
        body: body);

    if (response.statusCode == 201 || response.statusCode == 200) {
      // setWishlistModel = WishlistModel.fromJson(jsonDecode(response.body));
      sellerFavorite =
          BuyerSellerFavoritModel.fromJson(jsonDecode(response.body));
      notifyListeners();

      if (withLoading) loading(false);
    } else {
      final message = jsonDecode(response.body)["messages"]["error"];
      loading(false);
      throw Exception(message);
    }
  }

  Future<void> fetchDetailSeller(
      {bool withLoading = false, required String sellerId}) async {
    if (withLoading) loading(true);

    final prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString(Constant.kSetPrefId) ?? '';

    Map<String, String> param = {'seller_id': sellerId, 'buyer_id': userId};
    final response =
        await get(Constant.BASE_API_FULL + '/getdetailseller', body: param);

    if (response.statusCode == 201 || response.statusCode == 200) {
      // setWishlistModel = WishlistModel.fromJson(jsonDecode(response.body));
      detailSellerBuyer = DetailSellerBuyer.fromJson(jsonDecode(response.body));
      notifyListeners();

      if (withLoading) loading(false);
    } else {
      final message = jsonDecode(response.body)["messages"]["error"];
      loading(false);
      throw Exception(message);
    }
  }

  bool? _followSellerSuccess = null;

  bool? get followSellerSuccess => _followSellerSuccess;

  set followSellerSuccess(bool? value) {
    _followSellerSuccess = value;
  }

  Future<void> addSellerWishlist({
    bool withLoading = false,
    required String sellerId,
  }) async {
    if (withLoading) loading(true);

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString(Constant.kSetPrefId) ?? '';

    final response = await post(Constant.BASE_API_FULL + '/follows',
        body: {'buyer_id': userId, 'seller_id': sellerId});

    if (response.statusCode == 201 || response.statusCode == 200) {
      // setWishlistModel = WishlistModel.fromJson(jsonDecode(response.body));
      followSellerSuccess = true;
      notifyListeners();

      if (withLoading) loading(false);
    } else {
      followSellerSuccess = false;
      final message = jsonDecode(response.body)["messages"]["error"];
      loading(false);
      throw Exception(message);
    }
  }

  bool? _unfollowSellerSuccess = null;

  bool? get unfollowSellerSuccess => _unfollowSellerSuccess;

  set unfollowSellerSuccess(bool? value) {
    _unfollowSellerSuccess = value;
  }

  Future<void> removeSellerWishlist({
    bool withLoading = false,
    required String sellerId,
  }) async {
    if (withLoading) loading(true);

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString(Constant.kSetPrefId) ?? '';

    final response = await delete(Constant.BASE_API_FULL + '/follows/$sellerId',
        body: {'buyer_id': userId});

    if (response.statusCode == 201 || response.statusCode == 200) {
      // setWishlistModel = WishlistModel.fromJson(jsonDecode(response.body));
      unfollowSellerSuccess = true;
      notifyListeners();

      if (withLoading) loading(false);
    } else {
      unfollowSellerSuccess = false;
      final message = jsonDecode(response.body)["messages"]["error"];
      loading(false);
      throw Exception(message);
    }
  }

  // Delete folder wishlist
  Future<void> deleteWishlist({
    required String idProduk,
    bool withLoading = true,
  }) async {
    if (withLoading) loading(true);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString(Constant.kSetPrefId) ?? '';

    Map<String, dynamic> param = {
      "produk_id": idProduk,
      "user_id": userId,
    };

    final response = await post(
        Constant.BASE_API_FULL + '/removefromwishlistbuyer',
        body: param);

    if (response.statusCode == 201 || response.statusCode == 200) {
      // if (withLoading) loading(false);
      fetchWishlist();
    } else {
      final message = jsonDecode(response.body)["messages"]["error"];
      loading(false);
      throw Exception(message);
    }
  }

  // Delete item from wishlist folder

  // Change wishlist name
  Future<void> updateWishlist(
      {required String id,
      required String name,
      bool withLoading = false}) async {
    if (withLoading) loading(true);

    Map<String, dynamic> param = {
      "id": id.toString(),
      "name": name.toString(),
    };

    final response = await post(
        Constant.BASE_API_FULL + '/product-whishlist-update',
        body: param);

    if (response.statusCode == 201 || response.statusCode == 200) {
      // fetchWishlist();
      if (withLoading) loading(false);
    } else {
      final message = jsonDecode(response.body)["messages"]["error"];
      loading(false);
      throw Exception(message);
    }
  }

  // add product to one of the wishlist folder
  Future<void> addProductWishlist({
    required String productId,
    bool withLoading = false,
  }) async {
    if (withLoading) loading(true);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString(Constant.kSetPrefId) ?? '';

    Map<String, dynamic> param = {
      "produk_id": productId,
      "user_id": userId,
    };

    final response = await post(
      Constant.BASE_API_FULL + '/addtowishlistbuyer',
      body: param,
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      fetchWishlist();
      if (withLoading) loading(false);
    } else {
      final message = jsonDecode(response.body)["messages"]["error"];
      loading(false);
      throw Exception(message);
    }
  }

  // create new folder wishlist
  Future<void> createWishlist({
    bool withLoading = false,
  }) async {
    if (withLoading) loading(true);

    Map<String, dynamic> param = {
      "name": namaKoleksiC.text,
    };

    final response =
        await post(Constant.BASE_API_FULL + '/product-whishlis', body: param);

    if (response.statusCode == 201 || response.statusCode == 200) {
      // fetchWishlist();
      if (withLoading) loading(false);
    } else {
      final message = jsonDecode(response.body)["messages"]["error"];
      loading(false);
      throw Exception(message);
    }
  }

  Future<void> addAllToCart({
    bool withLoading = true,
    required String sellerId,
  }) async {
    if (withLoading) loading(true);

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString(Constant.kSetPrefId) ?? '';

    final response = await post(
      Constant.BASE_API_FULL + '/addalltocartbuyer',
      body: {
        'buyer_id': userId,
        'seller_id': sellerId,
        "qty": "1",
        "catatan": "",
        "wishlist": "1",
      },
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      await fetchWishlist(withLoading: true);
      notifyListeners();

      if (withLoading) loading(false);
    } else {
      final message = jsonDecode(response.body)["message"];
      loading(false);
      throw Exception(message);
    }
  }

  Future<void> addToCart(
    BuildContext context, {
    bool withLoading = true,
    required String produkId,
  }) async {
    if (withLoading) loading(true);

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString(Constant.kSetPrefId) ?? '';

    final response = await post(
      Constant.BASE_API_FULL + '/addtocartbuyer',
      body: {
        'buyer_id': userId,
        'produk_id': produkId,
        "qty": "1",
        "catatan": "",
        "wishlist": '1',
      },
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      await fetchWishlist(withLoading: true);
      notifyListeners();

      if (withLoading) loading(false);
    } else {
      final message = jsonDecode(response.body)["message"];
      loading(false);
      CustomAlert.showSnackBar(
        context,
        "Terjadi Galat!",
        true,
      );
      throw Exception(message);
    }
  }
}
