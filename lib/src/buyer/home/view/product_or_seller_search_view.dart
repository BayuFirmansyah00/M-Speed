import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mspeed/common/component/custom_navigator.dart';
import 'package:mspeed/common/component/custom_container.dart';
import 'package:mspeed/src/buyer/home/view/buyer_product_filter_bottom_sheet.dart';
import 'package:mspeed/src/buyer/home/view/buyer_product_sort_bottom_sheet.dart';
import 'package:mspeed/src/buyer/product/model/buyer_product_filter_model.dart';
import 'package:mspeed/src/buyer/product/provider/buyer_product_filter_provider.dart';
import 'package:mspeed/src/buyer/cart/provider/buyer_cart_provider.dart';
import 'package:mspeed/src/buyer/cart/view/buyer_cart_view.dart';
import 'package:mspeed/src/buyer/product/view/detail_product_view.dart';
import 'package:provider/provider.dart';
import 'package:mspeed/src/buyer/home/model/buyer_dashboard_model.dart';

import '../../../../common/base/base_state.dart';
import '../../../../generated/assets.dart';
import '../../../../utils/utils.dart';

class ProductOrSellerSearchView extends StatefulWidget {
  const ProductOrSellerSearchView({
    super.key,
    this.query = "",
    this.initialCategoryId,
    this.initialCategoryName,
  });

  final String query;
  final int? initialCategoryId;
  final String? initialCategoryName;

  @override
  State<ProductOrSellerSearchView> createState() =>
      _ProductOrSellerSearchViewState();
}

class _ProductOrSellerSearchViewState
    extends BaseState<ProductOrSellerSearchView> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    if (widget.query.isNotEmpty) {
      _searchController.text = widget.query;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      debugPrint('SEARCH INIT: initialCategoryId = ${widget.initialCategoryId}, initialCategoryName = ${widget.initialCategoryName}');
      final p = context.read<BuyerProductFilterProvider>();
      p.initFilters(
        keyword: widget.query,
        categoryId: widget.initialCategoryId,
      );
      context.read<BuyerCartProvider>().fetchCart(withLoading: false);
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  String _getHeaderTitle(BuyerProductFilterProvider p) {
    if (p.keyword.isNotEmpty) {
      return 'Hasil pencarian: "${p.keyword}"';
    }
    if (p.selectedCategoryIds.isNotEmpty) {
      if (widget.initialCategoryName != null && widget.initialCategoryName!.isNotEmpty) {
        return 'Menampilkan ${widget.initialCategoryName}';
      }
      if (p.availableCategories.isNotEmpty) {
        final selectedNames = p.availableCategories
            .where((cat) => p.selectedCategoryIds.contains(cat.id))
            .map((cat) => cat.name ?? '')
            .where((name) => name.isNotEmpty)
            .toList();
        if (selectedNames.isNotEmpty) {
          return 'Menampilkan ${selectedNames.join(", ")}';
        }
      }
      return 'Menampilkan Produk Kategori';
    }
    return 'Menampilkan Semua Produk';
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<BuyerProductFilterProvider>();
    final cartP = context.watch<BuyerCartProvider>();

    Widget _buildProductItem(BuyerProductData product) {
      return GestureDetector(
        onTap: () async {
          final mappedProduct = DashboardProductModel(
            id: product.id,
            name: product.name,
            price: product.price,
            qty: product.qty,
            description: product.description,
            size: product.size,
            productCode: product.productCode,
            images: product.photo != null ? [ProductImageModel(imgUrl: product.photo)] : [],
            category: ProductCategoryModel(name: product.category?.name),
            seller: ProductSellerModel(id: product.seller?.id, companyName: product.seller?.companyName),
          );
          await CusNav.nPush(context, DetailProductView(product: mappedProduct));
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFEEEEEE), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Gambar & Wishlist Icon
              SizedBox(
                height: 125,
                width: double.infinity,
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                      child: SizedBox(
                        width: double.infinity,
                        height: 125,
                        child: CachedNetworkImage(
                          imageUrl: product.photo ?? '',
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(
                            color: Colors.grey.shade100,
                            child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                          ),
                          errorWidget: (_, __, ___) => Container(
                            color: Colors.grey.shade100,
                            child: const Icon(Icons.image_not_supported, color: Colors.grey),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 6,
                      right: 6,
                      child: GestureDetector(
                        onTap: () {
                          if (product.id != null) {
                            p.toggleWishlist(context, product.id!);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.9),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              )
                            ],
                          ),
                          child: (product.id != null && p.isProductWishlistProcessing(product.id!))
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.red),
                                )
                              : Icon(
                                  (product.id != null && p.isProductInWishlist(product.id!))
                                      ? Icons.favorite_rounded
                                      : Icons.favorite_outline_rounded,
                                  size: 16,
                                  color: (product.id != null && p.isProductInWishlist(product.id!))
                                      ? Colors.red
                                      : Colors.grey.shade400,
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // 2. Info Produk (Flexible with zero overflow)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nama Produk
                      Text(
                        product.name ?? "-",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF111827),
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 3),
                      // Harga
                      Text(
                        Utils.thousandSeparator((product.price ?? 0).toInt()),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFE50012),
                        ),
                      ),
                      const SizedBox(height: 3),
                      // Nama Toko / Seller
                      Row(
                        children: [
                          const Icon(Icons.storefront_rounded, size: 12, color: Colors.grey),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              product.seller?.companyName ?? '-',
                              style: const TextStyle(color: Color(0xFF6B7280), fontSize: 10),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      // Kategori & Stok
                      Text(
                        'Stok ${product.qty ?? 0} • ${product.category?.name ?? '-'}',
                        style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 9),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Spacer(),
                      // Tombol + Keranjang
                      SizedBox(
                        width: double.infinity,
                        height: 26,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE50012),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.zero,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                          ),
                          onPressed: (product.id != null && !cartP.isAddingProduct(product.id!))
                              ? () {
                                  context.read<BuyerCartProvider>().addToCart(context, product.id!);
                                }
                              : null,
                          child: (product.id != null && cartP.isAddingProduct(product.id!))
                              ? const SizedBox(
                                  width: 12,
                                  height: 12,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const Text(
                                  '+ Keranjang',
                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        forceMaterialTransparency: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.red),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Container(
          height: 40,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(20),
          ),
          child: TextField(
            controller: _searchController,
            style: const TextStyle(fontSize: 14),
            onChanged: (value) {
              if (_debounce != null) {
                _debounce!.cancel();
              }
              _debounce = Timer(const Duration(milliseconds: 1000), () {
                context.read<BuyerProductFilterProvider>().updateKeyword(value);
              });
            },
            onSubmitted: (value) {
              context.read<BuyerProductFilterProvider>().updateKeyword(value);
            },
            decoration: const InputDecoration(
              hintText: 'Cari produk atau toko...',
              hintStyle: TextStyle(color: Colors.grey, fontSize: 13),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              isDense: true,
            ),
          ),
        ),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined, color: Colors.black87),
                onPressed: () {
                  CusNav.nPush(context, const BuyerCartView());
                },
              ),
              if (cartP.totalCartItems > 0)
                Positioned(
                  right: 4,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${cartP.totalCartItems}',
                      style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
            ],
          ),
          TextButton.icon(
            onPressed: () {
              _showFilterBottomSheet(context);
            },
            icon: SvgPicture.asset(Assets.svgsIcSearchFilter),
            label: const Text(
              'Filter',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _getHeaderTitle(p),
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1F2937)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF0F8),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: SvgPicture.asset(
                      Assets.svgsIcSearchTampilan,
                      height: 16,
                    ),
                  ),
                  onPressed: () {
                    _showSortBottomSheet(context);
                  },
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            height: 8,
            color: const Color(0xFFF6F6F6),
          ),
          Expanded(
            child: NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification scrollInfo) {
                if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
                  p.fetchNextPage();
                }
                return false;
              },
              child: RefreshIndicator(
                onRefresh: () async => p.refreshData(),
                child: p.isLoading 
                  ? const Center(child: CircularProgressIndicator())
                  : p.error != null
                    ? Center(child: Text(p.error!))
                    : p.products.isEmpty
                      ? CustomContainer.mainNotFoundImage()
                      : GridView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          physics: const AlwaysScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 14,
                            mainAxisExtent: 310,
                          ),
                          itemCount: p.products.length + (p.hasNextPage ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == p.products.length) {
                              return const Center(child: CircularProgressIndicator());
                            }
                            final item = p.products[index];
                            return _buildProductItem(item);
                          },
                        ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
      ),
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          maxChildSize: 0.75,
          initialChildSize: 0.5,
          expand: false,
          builder: (BuildContext context, singleController) {
            return Column(
              children: [
                Container(
                  padding:
                      const EdgeInsets.only(left: 16, bottom: 5, right: 16, top: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Filter',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      TextButton(
                        onPressed: () {
                          context.read<BuyerProductFilterProvider>().resetFilters();
                          Navigator.pop(context);
                        },
                        child: const Text('Reset'),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    controller: singleController,
                    child: Column(
                      children: const [
                        BuyerProductFilterBottomSheet(),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showSortBottomSheet(BuildContext context) {
    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(16),
        ),
      ),
      builder: (BuildContext context) {
        return const BuyerProductSortBottomSheet();
      },
    );
  }
}
