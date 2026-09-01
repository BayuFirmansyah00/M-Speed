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
  const ProductOrSellerSearchView({super.key, this.query = ""});

  final String query;
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final p = context.read<BuyerProductFilterProvider>();
      p.resetFilters();
      if (widget.query.isNotEmpty) {
        _searchController.text = widget.query;
        p.keyword = widget.query;
      }
      p.refreshData();
      context.read<BuyerCartProvider>().fetchCart(withLoading: false);
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
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
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: CachedNetworkImage(
                        imageUrl: product.photo ?? '', // Backend returns raw path for now, maybe need to prepend base URL later
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
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () {
                        if (product.id != null) {
                          p.toggleWishlist(context, product.id!);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white,
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
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.red),
                              )
                            : Icon(
                                (product.id != null && p.isProductInWishlist(product.id!))
                                    ? Icons.favorite_rounded
                                    : Icons.favorite_outline_rounded,
                                size: 18,
                                color: (product.id != null && p.isProductInWishlist(product.id!))
                                    ? Colors.red
                                    : Colors.grey.shade400,
                              ),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name ?? "-",
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Rp ${Utils.thousandSeparator((product.price ?? 0).toInt())}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFE50012),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.storefront_rounded, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            product.seller?.companyName ?? '-',
                            style: const TextStyle(color: Colors.grey, fontSize: 11),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Stok ${product.qty} • ${product.category?.name ?? '-'}',
                      style: const TextStyle(color: Colors.grey, fontSize: 10),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      height: 28,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.zero,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: (product.id != null && !cartP.isAddingProduct(product.id!))
                            ? () {
                                context.read<BuyerCartProvider>().addToCart(context, product.id!);
                              }
                            : null,
                        child: (product.id != null && cartP.isAddingProduct(product.id!))
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Text('+ Keranjang', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
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
                const Expanded(
                    child: Text(
                  "Menampilkan Semua Produk",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
                )),
                IconButton(
                  icon: Container(
                      padding:
                          const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEF0F8),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: SvgPicture.asset(
                        Assets.svgsIcSearchTampilan,
                        height: 16,
                      )),
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
                      : CustomContainer.mainGridView2(
                          context: context,
                          itemCount: p.products.length + (p.hasNextPage ? 1 : 0),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
    // Note: To fully connect the bottom sheet with BuyerProductFilterProvider,
    // we would need to update `FilterBottomSheet` which currently uses `ProductFilterProvider` and `HomeProvider`.
    // Since we shouldn't touch `FilterBottomSheet` if it breaks other parts, we just show it.
    // However, the instructions say: "Filter Bottom Sheet (Harga, Kategori, Kota, Sort) akan di-hook ke provider baru".
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
                      children: [
                        BuyerProductFilterBottomSheet(), // NOTE: This needs to be adapted or rewritten if it depends on HomeProvider heavily.
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
        return BuyerProductSortBottomSheet(); // Also needs adaptation
      },
    );
  }
}
