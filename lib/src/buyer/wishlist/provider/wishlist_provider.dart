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

    // GET /api/wishlists — Auth via Bearer token (tidak perlu kirim user_id)
    // Response: { data: [{ id, user_data, product: { id, name, price, qty } }] }
    final response = await get(Constant.BASE_API_FULL + '/wishlists');

    if (response.statusCode == 201 || response.statusCode == 200) {
      wishlistModel = BuyerWishlistModel.fromJson(jsonDecode(response.body));
      notifyListeners();
      if (withLoading) loading(false);
    } else {
      final decoded = jsonDecode(response.body);
      final message = decoded["message"] ?? decoded["messages"]?["error"] ?? 'Terjadi kesalahan';
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

    // GET /api/follows — seller yang diikuti oleh user login
    // Response: { data: [{ id, user_data, seller_data: { id, name } }] }
    Map<String, String> body = {};
    if (sellerFavoritSearchController.text.isNotEmpty) {
      body['search'] = sellerFavoritSearchController.text;
    }

    final response = await get(Constant.BASE_API_FULL + '/follows', body: body);

    if (response.statusCode == 201 || response.statusCode == 200) {
      sellerFavorite = BuyerSellerFavoritModel.fromJson(jsonDecode(response.body));
      notifyListeners();
      if (withLoading) loading(false);
    } else {
      final decoded = jsonDecode(response.body);
      final message = decoded["message"] ?? decoded["messages"]?["error"] ?? 'Terjadi kesalahan';
      loading(false);
      throw Exception(message);
    }
  }

  Future<void> fetchDetailSeller(
      {bool withLoading = false, required String sellerId}) async {
    if (withLoading) loading(true);

    // GET /api/seller-datas/{id} — detail seller berdasarkan ID
    final response = await get(Constant.BASE_API_FULL + '/seller-datas/$sellerId');

    if (response.statusCode == 201 || response.statusCode == 200) {
      detailSellerBuyer = DetailSellerBuyer.fromJson(jsonDecode(response.body));
      notifyListeners();
      if (withLoading) loading(false);
    } else {
      final decoded = jsonDecode(response.body);
      final message = decoded["message"] ?? decoded["messages"]?["error"] ?? 'Terjadi kesalahan';
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

    // POST /api/follows — follow seller (auth via token, tidak perlu buyer_id)
    final response = await post(Constant.BASE_API_FULL + '/follows',
        body: {'seller_data_id': sellerId});

    if (response.statusCode == 201 || response.statusCode == 200) {
      followSellerSuccess = true;
      notifyListeners();
      if (withLoading) loading(false);
    } else {
      followSellerSuccess = false;
      final decoded = jsonDecode(response.body);
      final message = decoded["message"] ?? decoded["messages"]?["error"] ?? 'Terjadi kesalahan';
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

    // DELETE /api/follows/{id} — unfollow seller (auth via token)
    final response = await delete(Constant.BASE_API_FULL + '/follows/$sellerId');

    if (response.statusCode == 201 || response.statusCode == 200 ||
        response.statusCode == 204) {
      unfollowSellerSuccess = true;
      notifyListeners();
      if (withLoading) loading(false);
    } else {
      unfollowSellerSuccess = false;
      final decoded = jsonDecode(response.body);
      final message = decoded["message"] ?? decoded["messages"]?["error"] ?? 'Terjadi kesalahan';
      loading(false);
      throw Exception(message);
    }
  }

  Future<void> deleteWishlist({
    required String wishlistId,
    bool withLoading = true,
  }) async {
    if (withLoading) loading(true);

    // DELETE /api/wishlists/{id} — hapus item dari wishlist
    final response = await delete(Constant.BASE_API_FULL + '/wishlists/$wishlistId');

    if (response.statusCode == 200 || response.statusCode == 204) {
      fetchWishlist();
    } else {
      final decoded = jsonDecode(response.body);
      final message = decoded["message"] ?? decoded["messages"]?["error"] ?? 'Terjadi kesalahan';
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

    // PUT /api/wishlists/{id} — update nama wishlist
    // (endpoint lama /product-whishlist-update sudah tidak digunakan)
    final response = await post(
        Constant.BASE_API_FULL + '/wishlists/$id',
        body: {
          '_method': 'PUT',
          'name': name.toString(),
        });

    if (response.statusCode == 201 || response.statusCode == 200) {
      // fetchWishlist();
      if (withLoading) loading(false);
    } else {
      final decoded = jsonDecode(response.body);
      final message = decoded["message"] ?? decoded["messages"]?["error"] ?? 'Terjadi kesalahan';
      loading(false);
      throw Exception(message);
    }
  }

  Future<void> addProductWishlist({
    required String productId,
    bool withLoading = false,
  }) async {
    if (withLoading) loading(true);

    // POST /api/wishlists — tambah produk ke wishlist (auth via token)
    final response = await post(
      Constant.BASE_API_FULL + '/wishlists',
      body: {'product_id': productId},
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      fetchWishlist();
      if (withLoading) loading(false);
    } else {
      final decoded = jsonDecode(response.body);
      final message = decoded["message"] ?? decoded["messages"]?["error"] ?? 'Terjadi kesalahan';
      loading(false);
      throw Exception(message);
    }
  }

  // create new folder wishlist
  Future<void> createWishlist({
    bool withLoading = false,
  }) async {
    if (withLoading) loading(true);

    // POST /api/wishlists — buat koleksi wishlist baru
    // (endpoint lama /product-whishlis sudah tidak digunakan)
    final response = await post(
        Constant.BASE_API_FULL + '/wishlists',
        body: {'name': namaKoleksiC.text});

    if (response.statusCode == 201 || response.statusCode == 200) {
      // fetchWishlist();
      if (withLoading) loading(false);
    } else {
      final decoded = jsonDecode(response.body);
      final message = decoded["message"] ?? decoded["messages"]?["error"] ?? 'Terjadi kesalahan';
      loading(false);
      throw Exception(message);
    }
  }

  Future<void> addAllToCart({
    bool withLoading = true,
    required String sellerId,
  }) async {
    if (withLoading) loading(true);

    // POST /api/carts dengan from_wishlist flag
    // Semua wishlist item dari seller ini dimasukkan ke cart
    final response = await post(
      Constant.BASE_API_FULL + '/carts',
      body: {
        'seller_id': sellerId,
        'from_wishlist': '1',
        'qty': '1',
      },
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      await fetchWishlist(withLoading: true);
      notifyListeners();
      if (withLoading) loading(false);
    } else {
      final decoded = jsonDecode(response.body);
      final message = decoded["message"] ?? decoded["messages"]?["error"] ?? 'Terjadi kesalahan';
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

    // POST /api/carts — tambah dari wishlist ke keranjang
    // Menggunakan endpoint baru sesuai StoreCartRequest Laravel
    // (endpoint lama /addtocartbuyer sudah tidak digunakan)
    final response = await post(
      Constant.BASE_API_FULL + '/carts',
      body: {
        'product_id': produkId,
        'qty': '1',
      },
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      await fetchWishlist(withLoading: true);
      notifyListeners();

      if (withLoading) loading(false);
    } else {
      final decoded = jsonDecode(response.body);
      final message = decoded["message"] ?? decoded["messages"]?["error"] ?? 'Terjadi kesalahan';
      loading(false);
      CustomAlert.showSnackBar(
        context,
        message,
        true,
      );
      throw Exception(message);
    }
  }
}
