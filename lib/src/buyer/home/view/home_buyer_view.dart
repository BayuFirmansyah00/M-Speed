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

  // --- PALET WARNA M-SPEED ---
  final Color mRed = const Color(0xFFE50012); // Merah logo SPEED
  final Color mCyan = const Color(0xFF5AB2D0); // Biru cyan logo M
  final Color mYellow = const Color(0xFFFFCC00); // Kuning petir
  final Color bgLight = const Color(0xFFF5F7FA);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getData();
    });

    scrollController.addListener(() {
      if (scrollController.offset > 220 && !isCollapsed) {
        setState(() => isCollapsed = true);
      } else if (scrollController.offset <= 220 && isCollapsed) {
        setState(() => isCollapsed = false);
      }
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  Future<void> getData() async {
    await context.read<HomeProvider>().getHomeProducts(withLoading: false);
    await context.read<HomeProvider>().fetchKategori(withLoading: false);
    context.read<ShoppingCartProvider>().fetchShoppingCart(
      context,
      withLoading: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final products = context.watch<HomeProvider>().buyerHomeProductModel.data ?? [];
    final p = context.watch<HomeProvider>();
    final categories = context.watch<HomeProvider>().kategoriModel?.data ?? [];
    final cartTotal = context.watch<ShoppingCartProvider>().countQtyCartItem();

    Widget _buildProductItem(int i) {
      return InkWell(
        onTap: () async {
          await CusNav.nPush(context, DetailProductView(id: products[i]?.ID ?? ''));
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: mCyan.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 6),
              )
            ],
            border: Border.all(color: Colors.grey.withOpacity(0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // GAMBAR PRODUK DENGAN BADGE PROMO
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: CachedNetworkImage(
                        imageUrl: products[i]?.foto ?? '',
                        fit: BoxFit.cover,
                        cacheManager: CacheManager(
                          Config('customCacheKey- ${products[i]?.foto ?? ''}', stalePeriod: const Duration(days: 7)),
                        ),
                        placeholder: (context, url) => Container(
                          color: bgLight,
                          child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: bgLight,
                          child: const Center(child: Icon(Icons.image_not_supported, color: Colors.grey)),
                        ),
                      ),
                    ),
                  ),
                  // M-SPEED Flash Tag (Kuning)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [mYellow, const Color(0xFFFF9900)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: [BoxShadow(color: mYellow.withOpacity(0.4), blurRadius: 4, offset: const Offset(0, 2))],
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.bolt_rounded, size: 12, color: Colors.white),
                          const Text(
                            "SPEED",
                            style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              
              // DESKRIPSI PRODUK
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 36,
                      child: Text(
                        products[i]?.nama ?? "-",
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, height: 1.3, color: Colors.black87),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // HARGA (M-Red)
                    Text(
                      "Rp ${Utils.thousandSeparatorFromString(products[i]?.harga ?? '0')}",
                      style: TextStyle(color: mRed, fontWeight: FontWeight.w800, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    // TAG KATEGORI (M-Cyan)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        color: mCyan.withOpacity(0.1),
                        border: Border.all(color: mCyan.withOpacity(0.3)),
                      ),
                      child: Text(
                        products[i]?.NamaKategori ?? '-',
                        style: TextStyle(color: mCyan, fontSize: 10, fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // INFO TOKO & STOK
                    Row(
                      children: [
                        Icon(Icons.storefront_rounded, size: 14, color: mCyan),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            products[i]?.SellerNama ?? '-',
                            style: const TextStyle(color: Colors.black54, fontSize: 11, fontWeight: FontWeight.w500),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Stok: ${products[i]?.qty ?? 0}', style: const TextStyle(color: Colors.black45, fontSize: 10)),
                        Text('${products[i]?.terjual ?? '0'} Terjual', style: const TextStyle(color: Colors.black87, fontSize: 10, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    Widget _buildProductCatalog() {
      final List<String> icons = [
        Assets.iconsIcConsumable, Assets.iconsIcApd, Assets.assetsIconsIcTools,
        Assets.iconsIcStationery, Assets.assetsIconsIcServices, Assets.iconsIcOther,
      ];

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // BAGIAN KATEGORI
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Kategori Pilihan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.black87)),
                TextButton(
                  onPressed: () {}, // Optional: arahkan ke lihat semua kategori
                  child: Text('Lihat Semua', style: TextStyle(color: mCyan, fontSize: 12, fontWeight: FontWeight.bold)),
                )
              ],
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: List.generate(categories.length, (index) {
                  final category = categories[index];
                  final String currentIcon = index < icons.length ? icons[index] : Assets.iconsIcOther;

                  return InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () async {
                      final kategoriMap = context.read<HomeProvider>().kategoriMap;
                      final namaKategori = category?.nama ?? '';
                      if (kategoriMap.isNotEmpty && kategoriMap.containsKey(namaKategori)) {
                        kategoriMap.updateAll((key, value) => false); 
                        kategoriMap[namaKategori] = true;
                      }
                      await CusNav.nPush(context, ProductOrSellerSearchView());
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(right: 16, bottom: 8),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(color: mCyan.withOpacity(0.2), width: 1.5),
                              boxShadow: [
                                BoxShadow(color: mCyan.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 4))
                              ]
                            ),
                            child: Image.asset(currentIcon, width: 28, height: 28),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: 70,
                            child: Text(
                              category?.nama ?? '',
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.black87),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
            
            const SizedBox(height: 24),
            Row(
              children: [
                Icon(Icons.local_fire_department_rounded, color: mRed),
                const SizedBox(width: 8),
                const Text('Rekomendasi Spesial', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.black87)),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: products.isEmpty 
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey.withOpacity(0.5)),
                          const SizedBox(height: 16),
                          const Text("Belum ada produk.", style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w600)),
                        ],
                      )
                    )
                  : DynamicHeightGridView(
                      itemCount: products.length < 20 ? products.length : 20,
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
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
        height: 250,
        decoration: BoxDecoration(
          // Latar belakang gradasi mCyan lembut di belakang banner
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [mCyan.withOpacity(0.2), bgLight],
          )
        ),
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            CarouselSlider(
              options: CarouselOptions(
                autoPlay: true,
                height: 180,
                viewportFraction: 0.9, // Membuat banner tidak full edge-to-edge
                enlargeCenterPage: true, // Animasi membesar di tengah
                onPageChanged: (index, reason) {
                  setState(() => p.currentIndex = index);
                },
              ),
              items: [Assets.imagesHomeHeader, Assets.imagesHomeHeader, Assets.imagesHomeHeader].map((imagePath) {
                return Builder(
                  builder: (BuildContext context) {
                    return Container(
                      margin: const EdgeInsets.only(top: 24, bottom: 24),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(color: mCyan.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 5))
                        ],
                        image: DecorationImage(image: AssetImage(imagePath), fit: BoxFit.cover),
                      ),
                    );
                  },
                );
              }).toList(),
            ),
            Positioned(
              bottom: 12,
              child: DotsIndicator(
                dotsCount: 3,
                position: p.currentIndex,
                decorator: DotsDecorator(
                  color: mCyan.withOpacity(0.3),
                  activeColor: mRed, // Dots aktif menggunakan mRed
                  size: const Size.square(6.0),
                  activeSize: const Size(20.0, 6.0),
                  activeShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: bgLight,
      body: NestedScrollView(
        controller: scrollController,
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              surfaceTintColor: Colors.white,
              backgroundColor: Colors.white,
              expandedHeight: 250.0,
              floating: false,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                background: _buildBanner(),
              ),
              title: Container(
                height: 46,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: mCyan.withOpacity(0.4), width: 1.5), // Border M-Cyan
                  borderRadius: BorderRadius.circular(24.0), // Bentuk Pill-Shape
                  boxShadow: [
                    BoxShadow(color: mCyan.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 4))
                  ],
                ),
                child: TextField(
                  onTap: () => CusNav.nPush(context, ProductOrSellerSearchView()),
                  readOnly: true,
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: 'Cari sparepart, tools, dll...',
                    hintStyle: const TextStyle(color: Colors.black45, fontSize: 13, fontWeight: FontWeight.w500),
                    border: InputBorder.none,
                    icon: Icon(Icons.search_rounded, color: mCyan, size: 22),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12.0),
                  ),
                ),
              ),
              actions: <Widget>[
                IconButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ShoppingCartView())),
                  icon: Badge(
                    isLabelVisible: cartTotal > 0,
                    label: Text('$cartTotal', style: const TextStyle(fontWeight: FontWeight.bold)),
                    offset: const Offset(8, -4),
                    backgroundColor: mRed, // Badge M-Red
                    child: SvgPicture.asset(
                      Assets.svgsIcCart,
                      width: 24,
                      colorFilter: ColorFilter.mode(isCollapsed ? Colors.black87 : mCyan, BlendMode.srcIn),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ChatListView())),
                  icon: Badge(
                    isLabelVisible: true,
                    label: const Text("2", style: TextStyle(fontWeight: FontWeight.bold)),
                    offset: const Offset(8, -4),
                    backgroundColor: mRed,
                    child: SvgPicture.asset(
                      Assets.svgsIcChat,
                      width: 24,
                      colorFilter: ColorFilter.mode(isCollapsed ? Colors.black87 : mCyan, BlendMode.srcIn),
                    ),
                  ),
                ),
              ],
            ),
          ];
        },
        body: Column(
          children: [
            Expanded(child: _buildProductCatalog()),
          ],
        ),
      ),
    );
  }
}

