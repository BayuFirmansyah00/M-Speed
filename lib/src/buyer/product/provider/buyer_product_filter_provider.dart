import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mspeed/common/base/base_controller.dart';
import 'package:mspeed/common/component/custom_alert.dart';
import 'package:mspeed/common/helper/constant.dart';
import 'package:mspeed/src/buyer/product/model/buyer_product_filter_model.dart';

class BuyerProductFilterProvider extends BaseController with ChangeNotifier {
  // State
  bool isLoading = false;
  bool isFetchingNextPage = false;
  bool hasNextPage = true;
  int currentPage = 1;
  String? error;
  List<BuyerProductData> products = [];

  // Filters
  String keyword = '';
  List<int> selectedCategoryIds = [];
  List<String> selectedCities = [];
  String minPrice = '';
  String maxPrice = '';
  int sort = 0;

  // Metadata from response
  List<BuyerProductCategory> availableCategories = [];
  List<String> availableCities = [];
  List<int> wishlistProductIds = [];

  BuyerProductFilterProvider() {
    refreshData();
  }

  Future<void> refreshData() async {
    currentPage = 1;
    hasNextPage = true;
    error = null;
    products.clear();
    isLoading = true;
    notifyListeners();

    await _fetchProducts(currentPage);
  }

  Future<void> fetchNextPage() async {
    if (isLoading || isFetchingNextPage || !hasNextPage) return;

    isFetchingNextPage = true;
    notifyListeners();

    await _fetchProducts(currentPage + 1);
  }

  void updateKeyword(String newKeyword) {
    keyword = newKeyword;
    refreshData();
  }

  void toggleCategory(int categoryId) {
    if (selectedCategoryIds.contains(categoryId)) {
      selectedCategoryIds.remove(categoryId);
    } else {
      selectedCategoryIds.add(categoryId);
    }
    refreshData();
  }

  void toggleCity(String city) {
    if (selectedCities.contains(city)) {
      selectedCities.remove(city);
    } else {
      selectedCities.add(city);
    }
    refreshData();
  }

  void applyPriceFilter(String min, String max) {
    minPrice = min;
    maxPrice = max;
    refreshData();
  }

  void applySort(int sortValue) {
    sort = sortValue;
    refreshData();
  }

  void resetFilters() {
    keyword = '';
    selectedCategoryIds.clear();
    selectedCities.clear();
    minPrice = '';
    maxPrice = '';
    sort = 0;
    refreshData();
  }

  Future<void> _fetchProducts(int pageKey) async {
    final token = await getToken();
    try {
      Map<String, String> queryParams = {
        'page': pageKey.toString(),
        'per_page': '10',
      };

      if (keyword.isNotEmpty) {
        queryParams['keyword'] = keyword;
      }

      for (var i = 0; i < selectedCategoryIds.length; i++) {
        queryParams['IDKategori[$i]'] = selectedCategoryIds[i].toString();
      }

      for (var i = 0; i < selectedCities.length; i++) {
        queryParams['kota[$i]'] = selectedCities[i];
      }

      if (minPrice.isNotEmpty) {
        queryParams['min_price'] = minPrice;
      }
      if (maxPrice.isNotEmpty) {
        queryParams['max_price'] = maxPrice;
      }

      if (sort != 0) {
        queryParams['sort'] = sort.toString();
      }

      String baseUrl = Constant.BASE_API_FULL + '/buyer/products/filter';
      String queryString = Uri(queryParameters: queryParams).query;
      final url = '$baseUrl?$queryString';

      final response = await get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final model = BuyerProductFilterModel.fromJson(decoded);

        if (model.data != null) {
          if (pageKey == 1) {
            products = model.data!.products ?? [];
            if (model.data!.categories != null) {
              availableCategories = model.data!.categories!;
            }
            if (model.data!.cities != null) {
              availableCities = model.data!.cities!;
            }
            if (model.data!.wishlistProductIds != null) {
              wishlistProductIds = model.data!.wishlistProductIds!;
            }
          } else {
            products.addAll(model.data!.products ?? []);
          }

          currentPage = pageKey;

          if (model.data!.pagination != null) {
            hasNextPage =
                model.data!.pagination!.currentPage! <
                (model.data!.pagination!.lastPage ?? 1);
          } else {
            final newItems = model.data!.products ?? [];
            hasNextPage = newItems.length >= 10;
          }
        }
      } else {
        final decoded = json.decode(response.body);
        final message = decoded['message'] ?? 'Failed to load products';
        if (pageKey == 1) error = message;
      }
    } catch (e) {
      if (pageKey == 1) error = e.toString();
    } finally {
      isLoading = false;
      isFetchingNextPage = false;
      notifyListeners();
    }
  }

  Set<int> processingWishlistIds = {};

  bool isProductInWishlist(int productId) {
    return wishlistProductIds.contains(productId);
  }

  bool isProductWishlistProcessing(int productId) {
    return processingWishlistIds.contains(productId);
  }

  Future<void> toggleWishlist(BuildContext context, int productId) async {
    if (processingWishlistIds.contains(productId)) return;

    processingWishlistIds.add(productId);
    notifyListeners();

    final token = await getToken();
    final isAlreadyWishlisted = isProductInWishlist(productId);

    try {
      if (isAlreadyWishlisted) {
        // DELETE request
        final url =
            Constant.BASE_API_FULL + '/buyer/v1/buyer/wishlist/$productId';
        final response = await delete(url);
        if (response.statusCode == 200) {
          wishlistProductIds.remove(productId);
        } else {
          _handleError(context, response);
        }
      } else {
        // POST request
        final url = Constant.BASE_API_FULL + '/buyer/v1/buyer/wishlist';
        final response = await post(
          url,
          body: {'product_id': productId.toString()},
        );
        if (response.statusCode == 201) {
          wishlistProductIds.add(productId);
        } else {
          _handleError(context, response);
        }
      }
    } catch (e) {
      CustomAlert.showSnackBar(context, "Terjadi kesalahan jaringan: $e", true);
    } finally {
      processingWishlistIds.remove(productId);
      notifyListeners();
    }
  }

  void _handleError(BuildContext context, dynamic response) {
    try {
      final decoded = json.decode(response.body);
      String errMsg = 'Terjadi kesalahan pada server';
      if (decoded['errors'] != null) {
        errMsg = decoded['errors'].toString();
      } else if (decoded['message'] != null) {
        errMsg = decoded['message'];
      }
      CustomAlert.showSnackBar(context, errMsg, true);
    } catch (e) {
      CustomAlert.showSnackBar(context, "Gagal memperbarui wishlist", true);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}
