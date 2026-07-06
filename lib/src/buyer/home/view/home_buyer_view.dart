import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:dynamic_height_grid_view/dynamic_height_grid_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mspeed/common/base/base_state.dart';
import 'package:mspeed/common/component/custom_navigator.dart';
import 'package:mspeed/common/helper/constant.dart';
import 'package:mspeed/generated/assets.dart';
import 'package:mspeed/src/buyer/cart/view/shopping_cart_view.dart';
import 'package:mspeed/src/buyer/chat/view/chat_list_view.dart';
import 'package:mspeed/src/buyer/product/view/detail_product_view.dart';
import 'package:mspeed/utils/utils.dart';
import 'package:provider/provider.dart';

import '../../cart/provider/shopping_cart_provider.dart';
import '../provider/home_provider.dart';
import 'product_or_seller_search_view.dart';

class HomeBuyerView extends StatefulWidget {
  @override
  State<HomeBuyerView> createState() => _HomeBuyerViewState();
}

class _HomeBuyerViewState extends BaseState<HomeBuyerView> {
  final scrollController = ScrollController();
  bool isCollapsed = false;

  @override
  void initState() {
    getData();
    super.initState();
    scrollController.addListener(() {
      if (scrollController.offset > 200 && !isCollapsed) {
        setState(() {
          isCollapsed = true;
        });
      } else if (scrollController.offset <= 200 && isCollapsed) {
        setState(() {
          isCollapsed = false;
        });
      }
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  Future<void> getData() async {
    Utils.showLoading();
    await context.read<HomeProvider>().getHomeProducts(withLoading: false);
    await context.read<HomeProvider>().fetchKategori(withLoading: false);
    context.read<ShoppingCartProvider>().fetchShoppingCart(
      context,
      withLoading: false,
    );
    Utils.dismissLoading();
  }

  @override
  Widget build(BuildContext context) {
    final products =
        context.watch<HomeProvider>().buyerHomeProductModel.data ?? [];
    final p = context.watch<HomeProvider>();
    final categories = context.watch<HomeProvider>().kategoriModel?.data ?? [];

    final cartTotal = context.watch<ShoppingCartProvider>().countQtyCartItem();
    Widget _buildProductItem(int i) {
      return InkWell(
        onTap: () async {
          await CusNav.nPush(
            context,
            DetailProductView(id: products[i]?.ID ?? ''),
          );
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
                    cacheManager: CacheManager(
                      Config(
                        'customCacheKey- ${products[i]?.foto ?? ''}',
                        stalePeriod: Duration(days: 7),
                      ),
                    ),
                    placeholder:
                        (context, url) => AspectRatio(
                          aspectRatio: 1,
                          child: Container(
                            width: double.infinity,
                            // height: 200.0,
                            color: Colors.grey[200],
                            child: Center(child: CircularProgressIndicator()),
                          ),
                        ),
                    errorWidget:
                        (context, url, error) => AspectRatio(
                          aspectRatio: 1,
                          child: Container(
                            width: double.infinity,
                            // height: 200.0,
                            color: Colors.grey[200],
                            child: Center(
                              child: Icon(Icons.error, color: Colors.red),
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
                      height: 40,
                      child: Text(
                        products[i]?.nama ?? "-",
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      "${Utils.thousandSeparatorFromString(products[i]?.harga ?? '0')}",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 4),
                    Container(
                      padding: EdgeInsets.fromLTRB(5, 6, 5, 6),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: Color.fromRGBO(209, 73, 91, 0.15),
                      ),
                      child: Text(
                        products[i]?.NamaKategori ?? '-',
                        style: TextStyle(
                          color: Color.fromRGBO(209, 73, 91, 1),
                          fontSize: 10,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 40,
                      child: Row(
                        children: [
                          Image.asset(
                            Assets.iconsIcStoreSeller,
                            width: 14,
                            height: 14,
                          ),
                          SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              products[i]?.SellerNama ?? '-',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'Stok ${products[i]?.qty} • ${products[i]?.terjual ?? '0'} Terjual',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    Widget _buildProductCatalog() {
      // final categories = [
      //   'Consumable',
      //   'APD',
      //   'Tools',
      //   'Stationery',
      //   'Services',
      //   'Other'
      // ];
      final icons = [
        Assets.iconsIcConsumable,
        Assets.iconsIcApd,
        Assets.assetsIconsIcTools,
        Assets.iconsIcStationery,
        Assets.assetsIconsIcServices,
        Assets.iconsIcOther,
        Assets.iconsIcOther,
      ];
      return Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 36),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Kategori Utama',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(categories.length, (index) {
                  return InkWell(
                    onTap: () async {
                      if (index != categories.length) {
                        final kategori =
                            context.read<HomeProvider>().kategoriMap;
                        final namaKategori = categories[index]?.nama ?? '';
                        if (kategori.isNotEmpty &&
                            kategori.containsKey(namaKategori))
                          kategori[categories[index]?.nama ?? ''] = true;
                        await CusNav.nPush(
                          context,
                          ProductOrSellerSearchView(),
                        );
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Color(0xFFDBDFE9)),
                            ),
                            child: Image.asset(
                              icons[index],
                              width: 36,
                              height: 36,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            categories[index]?.nama ?? '',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Katalog Produk',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 16),
            Expanded(
              child: DynamicHeightGridView(
                itemCount: products.length < 20 ? products.length : 20,
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                builder: (ctx, index) {
                  return _buildProductItem(index);
                },
              ),
            ),
          ],
        ),
      );
    }

    Widget _buildBanner() {
      return Container(
        height: 280,
        child: Stack(
          children: [
            CarouselSlider(
              options: CarouselOptions(
                autoPlay: true,
                height: 280,
                viewportFraction: 1,
                onPageChanged: (index, reason) {
                  setState(() {
                    p.currentIndex = index;
                  });
                },
              ),
              items: [
                Container(
                  width: double.infinity,
                  child: Image.asset(
                    Assets.imagesHomeHeader,
                    fit: BoxFit.cover,
                  ),
                ),
                Container(
                  width: double.infinity,
                  child: Image.asset(
                    Assets.imagesHomeHeader,
                    fit: BoxFit.cover,
                  ),
                ),
                Container(
                  width: double.infinity,
                  child: Image.asset(
                    Assets.imagesHomeHeader,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 20,
              child: DotsIndicator(
                dotsCount: 3,
                position: p.currentIndex,
                decorator: DotsDecorator(
                  color: Colors.white.withOpacity(0.5),
                  activeColor: Colors.white,
                  size: const Size.square(8.0),
                  activeSize: const Size(20.0, 8.0),
                  activeShape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // List<Widget> _buildProductGrid(int count) {
    //   final rows = <Widget>[];
    //   int total = 0;

    //   while (total < count) {
    //     if (total + 2 > count) {
    //       rows.add(Row(
    //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //         children: [_buildProductItem()],
    //       ));
    //     } else {
    //       rows.add(Row(
    //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //         children: [_buildProductItem(), _buildProductItem()],
    //       ));
    //     }
    //     total += 2;
    //   }

    //   return rows;
    // }
    return Scaffold(
      backgroundColor: Colors.white,
      body: NestedScrollView(
        controller: scrollController,
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              surfaceTintColor: Colors.white,
              backgroundColor: Colors.white,
              expandedHeight: 280.0,
              floating: false,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                background: _buildBanner(),
              ),
              title: Container(
                height: 40,
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Constant.textHintColor),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: TextField(
                  onTap: () {
                    CusNav.nPush(context, ProductOrSellerSearchView());
                  },
                  // onSubmitted: (value) {
                  //   Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //         builder: (context) => ProductOrSellerSearchView(
                  //               query: value,
                  //             )),
                  //   );
                  //   p.searchController.clear();
                  // },
                  // controller: p.searchController,
                  readOnly: true,
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: 'Cari disini',
                    border: InputBorder.none,
                    icon: Icon(Icons.search),
                    contentPadding: EdgeInsets.symmetric(vertical: 10.0),
                  ),
                ),
              ),
              actions: <Widget>[
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ShoppingCartView(),
                      ),
                    );
                  },
                  icon: Badge(
                    isLabelVisible: cartTotal == 0 ? false : true,
                    label: Text('$cartTotal'),
                    offset: Offset(8, -4),
                    backgroundColor: Colors.redAccent,
                    child: SvgPicture.asset(
                      Assets.svgsIcCart,
                      width: 24,
                      color: isCollapsed ? Colors.black : Colors.white,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ChatListView()),
                    );
                    // Navigator.pushNamed(context, '/chat_list');
                  },
                  icon: Badge(
                    isLabelVisible: true,
                    label: const Text("2"),
                    offset: const Offset(8, -4),
                    backgroundColor: Colors.redAccent,
                    child: SvgPicture.asset(
                      Assets.svgsIcChat,
                      width: 24,
                      color: isCollapsed ? Colors.black : Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ];
        },
        body: Column(
          children: [
            // _buildMainCategories(),
            Expanded(child: _buildProductCatalog()),
          ],
        ),
      ),
    );
  }
}
