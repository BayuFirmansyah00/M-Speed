import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dynamic_height_grid_view/dynamic_height_grid_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mspeed/common/component/custom_navigator.dart';
import 'package:mspeed/common/helper/Constant.dart';
import 'package:mspeed/src/buyer/home/provider/home_provider.dart';
import 'package:mspeed/src/buyer/home/view/filter_bottom_sheet.dart';
import 'package:mspeed/src/buyer/home/view/search_toko_lainnya_view.dart';
import 'package:mspeed/src/buyer/home/view/sort_bottom_sheet.dart';
import 'package:mspeed/src/buyer/product/view/detail_product_view.dart';
import 'package:mspeed/src/buyer/seller/view/seller_home_product_view.dart';
import 'package:provider/provider.dart';

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
  @override
  void initState() {
    getData();
    super.initState();
  }

  Future<void> getData() async {
    Utils.showLoading();
    await context.read<HomeProvider>().searchProduct();
    await context.read<HomeProvider>().fetchKategori();
    await context.read<HomeProvider>().fetchKategoriLokasi();
    Utils.dismissLoading();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<HomeProvider>();
    final products = context.watch<HomeProvider>().buyerProductModel.data ?? [];
    final searchController = context.watch<HomeProvider>().searchController;

    Widget _buildProductItem(int i) {
      final product = products[i];
      if (product == null) return const SizedBox();
      return GestureDetector(
        onTap: () async {
          await CusNav.nPush(context, DetailProductView(id: product.ID ?? ''));
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
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: CachedNetworkImage(
                    imageUrl: product.foto ?? '',
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
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.nama ?? "-",
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
                      'Rp ${Utils.thousandSeparator(int.tryParse(product.harga ?? "0") ?? 0)}',
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
                            product.SellerNama ?? '-',
                            style: const TextStyle(color: Colors.grey, fontSize: 11),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Stok ${product.qty} • ${product.NamaKategori}',
                      style: const TextStyle(color: Colors.grey, fontSize: 10),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
          icon: Icon(Icons.arrow_back, color: Colors.red),
          onPressed: () {
            Navigator.pop(context);
            context.read<HomeProvider>().searchController.clear();
          },
        ),
        title: Container(
          height: 40,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(20),
          ),
          child: TextField(
            controller: searchController,
            style: const TextStyle(fontSize: 14),
            onChanged: (value) {
              if (p.searchOnStoppedTyping != null) {
                p.searchOnStoppedTyping!.cancel();
              }
              p.searchOnStoppedTyping = Timer(p.duration, () {
                context.read<HomeProvider>().searchProduct(withLoading: true);
              });
            },
            onSubmitted: (value) {
              context.read<HomeProvider>().searchProduct(withLoading: true);
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
          TextButton.icon(
            onPressed: () async {
              _showFilterBottomSheet(context);
            },
            icon: SvgPicture.asset(Assets.svgsIcSearchFilter),
            label: Text(
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
                  "Menampilkan Semua Produk / Seller",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
                )),
                IconButton(
                  icon: Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                      decoration: BoxDecoration(
                        color: Color(0xFFEEF0F8),
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
            color: Color(0xFFF6F6F6),
          ),

          // Text('a'),
          Expanded(
            child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: DynamicHeightGridView(
                    itemCount: products.length,
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    builder: (ctx, index) {
                      return _buildProductItem(index);
                    })),
          ),
        ],
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
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
                      EdgeInsets.only(left: 16, bottom: 5, right: 16, top: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Filter',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      TextButton(
                        onPressed: () {
                          context.read<HomeProvider>().resetFilters();
                        },
                        child: Text('Reset'),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    controller: singleController,
                    child: Column(
                      children: [
                        FilterBottomSheet(),
                      ],
                    ),
                  ),
                ),
              ],
            );
            // return FilterBottomSheet();
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(16), // Adjust this value as needed
        ),
      ),
      builder: (BuildContext context) {
        return SortBottomSheet();
      },
    );
  }
}
