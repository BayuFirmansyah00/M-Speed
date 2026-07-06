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
      return InkWell(
        onTap: () async {
          await CusNav.nPush(
              context, DetailProductView(id: products[i]?.ID ?? ''));
        },
        child: Card(
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: CachedNetworkImage(
                    imageUrl: products[i]?.foto ?? '',
                    fit: BoxFit.cover,
                    placeholder: (context, url) => AspectRatio(
                      aspectRatio: 1,
                      child: Container(
                        width: double.infinity,
                        // height: 200.0,
                        color: Colors.grey[200],
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => AspectRatio(
                      aspectRatio: 1,
                      child: Container(
                        width: double.infinity,
                        // height: 200.0,
                        color: Colors.grey[200],
                        child: Center(
                          child: Icon(
                            Icons.error,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 8),
                    SizedBox(
                      height: 80,
                      child: Text(
                        products[i]?.nama ?? "-",
                        style: TextStyle(
                            fontWeight: FontWeight.w400, fontSize: 12),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                        Utils.thousandSeparator(
                            int.parse(products[i]?.harga ?? "0")),
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w700,
                            fontSize: 16)),
                    Row(
                      children: [
                        Image.asset(Assets.iconsIcStoreSeller,
                            width: 14, height: 14),
                        SizedBox(width: 4),
                        Expanded(
                          child: Text(products[i]?.SellerNama ?? '-',
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400)),
                        ),
                      ],
                    ),
                    Text(
                        'Stok ${products[i]?.qty} • ${products[i]?.NamaKategori}',
                        style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                            fontWeight: FontWeight.w400)),
                    SizedBox(
                      height: 16,
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
          width: double.infinity,
          height: 40,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.red),
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            onChanged: (value) {
              if (value.length < 3) {
                if (p.searchOnStoppedTyping != null) {
                  p.searchOnStoppedTyping!.cancel();
                }
                p.searchOnStoppedTyping = Timer(p.duration, () {
                  context.read<HomeProvider>().searchProduct(withLoading: true);
                });
              }
              if (value.length >= 3) {
                // debounce(() {
                //   searchP.fetchSearchProduct(withLoading: true);
                // });
                // await Future.delayed(
                //   Duration(milliseconds: 2000),
                //   () {
                //     searchP.fetchSearchProduct(withLoading: true);
                //   },
                // ); // Add a delay of 500 milliseconds
                if (p.searchOnStoppedTyping != null) {
                  p.searchOnStoppedTyping!.cancel();
                }
                p.searchOnStoppedTyping = Timer(p.duration, () {
                  context.read<HomeProvider>().searchProduct(withLoading: true);
                });
              }
            },
            onSubmitted: (value) {
              context.read<HomeProvider>().searchProduct(withLoading: true);
            },
            controller: searchController,
            decoration: InputDecoration(
              hintText: 'Cari di sini',
              hintStyle: TextStyle(color: Colors.grey),
              border: InputBorder.none,
              contentPadding: EdgeInsets.fromLTRB(16, 0, 16, 10),
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
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SellerHomeProductView(id: "123")),
                );
              },
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(36),
                    child: Image.network(
                      'https://via.placeholder.com/150.jpg',
                      width: 64,
                      height: 64,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 64,
                          height: 64,
                          color: Colors.grey,
                        );
                      },
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Three Band",
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.black)),
                        Text(
                          "Seller Aam",
                          style: TextStyle(
                              color: Constant.grayColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w400),
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SearchTokoLainnyaView()),
                      );
                    },
                    child: Row(
                      children: [
                        Container(
                          color: Colors.red,
                          width: 1,
                          height: 48,
                        ),
                        SizedBox(
                          width: 12,
                        ),
                        Text(
                          "Toko\nLainnya",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                              fontWeight: FontWeight.w400),
                        ),
                        SizedBox(
                          width: 12,
                        ),
                        Icon(
                          Icons.navigate_next,
                          color: Colors.red,
                        ),
                      ],
                    ),
                  )
                ],
              ),
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
