import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:dynamic_height_grid_view/dynamic_height_grid_view.dart';
import 'package:mspeed/common/base/base_state.dart';
import 'package:mspeed/common/component/custom_navigator.dart';
import 'package:mspeed/common/helper/constant.dart';
import 'package:mspeed/generated/assets.dart';
import 'package:mspeed/src/buyer/cart/view/shopping_cart_view.dart';
import 'package:mspeed/src/buyer/chat/view/chat_list_view.dart';
import 'package:mspeed/src/buyer/product/view/detail_product_view.dart';
import 'package:mspeed/utils/utils.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../cart/provider/shopping_cart_provider.dart';
import '../provider/home_provider.dart';
import 'product_or_seller_search_view.dart';

// ─── PALET : Ultra-Modern Clean ───────────────────────────
class _C {
  static const primary = Color(0xFFE50012);
  static const primaryLight = Color(0xFFFFEBEE);
  static const bg = Color(0xFFF9FAFB); // Lebih putih dan bersih (Off-white)
  static const card = Color(0xFFFFFFFF);
  static const txt1 = Color(0xFF0F172A); // Slate dark
  static const txt2 = Color(0xFF64748B); // Slate medium
  static const txt3 = Color(0xFF94A3B8); // Slate light
  
  static const shadowSoft = BoxShadow(
    color: Color(0x08000000),
    blurRadius: 15,
    offset: Offset(0, 5),
  );
  
  static const shadowHover = BoxShadow(
    color: Color(0x12000000),
    blurRadius: 20,
    offset: Offset(0, 8),
  );
}

class HomeBuyerView extends StatefulWidget {
  @override
  State<HomeBuyerView> createState() => _HomeBuyerViewState();
}

class _HomeBuyerViewState extends BaseState<HomeBuyerView>
    with SingleTickerProviderStateMixin {
  final _scroll = ScrollController();
  late AnimationController _shimmer;
  String _userName = '';

  @override
  void initState() {
    super.initState();
    _shimmer = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
      _loadUser();
    });
  }

  Future<void> _loadUser() async {
    final p = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() => _userName = p.getString(Constant.kSetPrefFirstName) ?? 'Pengguna');
    }
  }

  Future<void> _loadData() async {
    await context.read<HomeProvider>().getHomeProducts(withLoading: false);
    await context.read<HomeProvider>().fetchKategori(withLoading: false);
    context.read<ShoppingCartProvider>().fetchShoppingCart(
      context,
      withLoading: false,
    );
  }

  @override
  void dispose() {
    _scroll.dispose();
    _shimmer.dispose();
    super.dispose();
  }

  Widget _shimBox({double? w, double? h, double r = 16}) => AnimatedBuilder(
    animation: _shimmer,
    builder: (_, __) => Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(r),
        gradient: LinearGradient(
          colors: const [Color(0xFFF1F5F9), Color(0xFFF8FAFC), Color(0xFFF1F5F9)],
          stops: [
            (_shimmer.value - 0.3).clamp(0.0, 1.0),
            _shimmer.value.clamp(0.0, 1.0),
            (_shimmer.value + 0.3).clamp(0.0, 1.0),
          ],
        ),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final products = context.watch<HomeProvider>().buyerHomeProductModel.data ?? [];
    final p = context.watch<HomeProvider>();
    final categories = context.watch<HomeProvider>().kategoriModel?.data ?? [];
    final cartTotal = context.watch<ShoppingCartProvider>().countQtyCartItem();

    return Scaffold(
      backgroundColor: _C.bg,
      body: CustomScrollView(
        controller: _scroll,
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        slivers: [
          _buildHeroHeader(cartTotal),
          SliverToBoxAdapter(child: const SizedBox(height: 16)),
          SliverToBoxAdapter(child: _banner(p)),
          SliverToBoxAdapter(child: const SizedBox(height: 24)),
          SliverToBoxAdapter(child: _sectionHead('Kategori Pilihan', onTap: () {})),
          SliverToBoxAdapter(child: _categories(categories)),
          SliverToBoxAdapter(child: const SizedBox(height: 24)),
          SliverToBoxAdapter(
            child: _sectionHead(
              'Rekomendasi Untukmu',
              onTap: () => CusNav.nPush(context, ProductOrSellerSearchView()),
            ),
          ),
          products.isEmpty
              ? SliverFillRemaining(child: _empty())
              : SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    child: DynamicHeightGridView(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: products.length < 20 ? products.length : 20,
                      crossAxisCount: 2,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 16,
                      builder: (ctx, i) => _productCard(products, i),
                    ),
                  ),
                ),
          const SliverToBoxAdapter(child: SizedBox(height: 110)),
        ],
      ),
    );
  }

  // ─── HERO HEADER + SEARCH BAR ─────────────────────────────
  Widget _buildHeroHeader(int cartTotal) {
    return SliverPersistentHeader(
      pinned: false,
      delegate: _HeroHeaderDelegate(
        minHeight: MediaQuery.of(context).padding.top + 70, // Fixed overflow by ensuring minHeight is large enough for collapsed state
        maxHeight: MediaQuery.of(context).padding.top + 160,
        userName: _userName,
        cartTotal: cartTotal,
        onChat: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ChatListView())),
        onCart: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ShoppingCartView())),
        onSearch: () => CusNav.nPush(context, ProductOrSellerSearchView()),
      ),
    );
  }

  // ─── BANNER ───────────────────────────────────────────────
  Widget _banner(HomeProvider p) {
    return Column(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            autoPlay: true,
            height: 160,
            viewportFraction: 0.88,
            enlargeCenterPage: true,
            enlargeFactor: 0.18,
            autoPlayCurve: Curves.easeOutExpo,
            onPageChanged: (i, _) => setState(() => p.currentIndex = i),
          ),
          items: [
            Assets.imagesHomeHeader,
            Assets.imagesHomeHeader,
            Assets.imagesHomeHeader,
          ].map((img) {
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [_C.shadowHover],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.asset(img, fit: BoxFit.cover, width: double.infinity),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 14),
        DotsIndicator(
          dotsCount: 3,
          position: p.currentIndex.toDouble(),
          decorator: DotsDecorator(
            color: _C.txt3.withValues(alpha: 0.3),
            activeColor: _C.primary,
            size: const Size(6, 6),
            activeSize: const Size(22, 6),
            activeShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      ],
    );
  }

  // ─── SECTION HEADER ───────────────────────────────────────
  Widget _sectionHead(String title, {required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 16, 14),
      child: Row(
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: _C.txt1, letterSpacing: -0.5)),
          const Spacer(),
          GestureDetector(
            onTap: onTap,
            child: Row(
              children: [
                const Text('Lihat', style: TextStyle(fontSize: 13, color: _C.primary, fontWeight: FontWeight.w600)),
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(color: _C.primary.withValues(alpha: 0.1), shape: BoxShape.circle),
                  child: const Icon(Icons.arrow_forward_ios_rounded, size: 10, color: _C.primary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── KATEGORI ─────────────────────────────────────────────
  Widget _categories(List categories) {
    final icons = [
      Assets.iconsIcConsumable,
      Assets.iconsIcApd,
      Assets.assetsIconsIcTools,
      Assets.iconsIcStationery,
      Assets.assetsIconsIcServices,
      Assets.iconsIcOther,
    ];

    return SizedBox(
      height: 110,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        physics: const BouncingScrollPhysics(),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (ctx, i) {
          final cat = categories[i];
          final icon = i < icons.length ? icons[i] : Assets.iconsIcOther;
          
          return GestureDetector(
            onTap: () async {
              final map = context.read<HomeProvider>().kategoriMap;
              final name = cat?.nama ?? '';
              if (map.containsKey(name)) {
                map.updateAll((k, v) => false);
                map[name] = true;
              }
              await CusNav.nPush(context, ProductOrSellerSearchView());
            },
            child: Column(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: _C.card,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [_C.shadowSoft],
                  ),
                  child: Center(
                    child: Image.asset(icon, width: 32, height: 32),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: 74,
                  child: Text(
                    cat?.nama ?? '',
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11, color: _C.txt2, fontWeight: FontWeight.w600, height: 1.2),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ─── PRODUCT CARD ─────────────────────────────────────────
  Widget _productCard(List products, int i) {
    final item = products[i];
    return GestureDetector(
      onTap: () => CusNav.nPush(context, DetailProductView(id: item?.ID ?? '')),
      child: Container(
        decoration: BoxDecoration(
          color: _C.card,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [_C.shadowSoft],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Gambar
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: AspectRatio(
                aspectRatio: 1,
                child: CachedNetworkImage(
                  imageUrl: item?.foto ?? '',
                  fit: BoxFit.cover,
                  cacheManager: CacheManager(Config('ms_${item?.ID ?? i}', stalePeriod: const Duration(days: 7))),
                  placeholder: (_, __) => _shimBox(h: double.infinity, r: 0),
                  errorWidget: (_, __, ___) => Container(
                    color: _C.bg,
                    child: const Center(child: Icon(Icons.image_not_supported_rounded, color: _C.txt3, size: 28)),
                  ),
                ),
              ),
            ),
            // Info
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item?.nama ?? '-',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _C.txt1, height: 1.3),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Rp ${Utils.thousandSeparatorFromString(item?.harga ?? '0')}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: _C.primary),
                  ),
                  const SizedBox(height: 10),
                  // Kategori & Store
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: _C.primaryLight, borderRadius: BorderRadius.circular(6)),
                        child: Text(
                          item?.NamaKategori ?? '-',
                          style: const TextStyle(fontSize: 9, color: _C.primary, fontWeight: FontWeight.w800),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.storefront_rounded, size: 14, color: _C.txt3),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          item?.SellerNama ?? '-',
                          style: const TextStyle(fontSize: 11, color: _C.txt2, fontWeight: FontWeight.w500),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, size: 12, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text('4.9', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _C.txt2)),
                      const Text(' • ', style: TextStyle(fontSize: 11, color: _C.txt3)),
                      Text('${item?.terjual ?? 0} terjual', style: const TextStyle(fontSize: 11, color: _C.txt2)),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── EMPTY STATE ──────────────────────────────────────────
  Widget _empty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: _C.primary.withValues(alpha: 0.05), shape: BoxShape.circle),
            child: const Icon(Icons.inventory_2_rounded, color: _C.primary, size: 48),
          ),
          const SizedBox(height: 16),
          const Text('Belum ada produk', style: TextStyle(color: _C.txt1, fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          const Text('Silakan cek kembali nanti', style: TextStyle(color: _C.txt2, fontSize: 14)),
        ],
      ),
    );
  }
}


// ─── HERO HEADER DELEGATE ─────────────────────────────────
class _HeroHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;
  final String userName;
  final int cartTotal;
  final VoidCallback onChat;
  final VoidCallback onCart;
  final VoidCallback onSearch;

  _HeroHeaderDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.userName,
    required this.cartTotal,
    required this.onChat,
    required this.onCart,
    required this.onSearch,
  });

  @override
  double get minExtent => minHeight;
  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    // 0.0 -> fully expanded, 1.0 -> fully collapsed
    final percent = shrinkOffset / (maxHeight - minHeight);
    final clampedPercent = percent.clamp(0.0, 1.0);

    return Stack(
      children: [
        // 1. Red Base (Top part)
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          // Shrink the red background as we scroll, but keep enough for the app bar
          height: maxHeight - (shrinkOffset * 0.8).clamp(0.0, maxHeight - minHeight),
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFE50012), Color(0xFFFF4D5B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
          ),
        ),

        // 2. Greeting & Icons (Fade out as we collapse)
        Positioned(
          top: MediaQuery.of(context).padding.top + 16,
          left: 20,
          right: 20,
          child: Opacity(
            opacity: 1 - clampedPercent,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Halo, $userName 👋',
                        style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: -0.5),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Penuhi kebutuhan alatmu',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                _buildHeaderIcon(Icons.chat_bubble_outline_rounded, '2', onChat),
                const SizedBox(width: 12),
                _buildHeaderIcon(Icons.shopping_cart_outlined, cartTotal > 0 ? '$cartTotal' : null, onCart),
              ],
            ),
          ),
        ),
        
        // 3. Search Bar (Glides and morphs)
        // Saat expanded, search bar ada di bawah.
        // Saat collapsed, search bar naik dan menggantikan posisi greeting.
        Positioned(
          bottom: 24 - (clampedPercent * 8), // Sedikit naik saat collapsed
          left: 20,
          right: 20,
          child: GestureDetector(
            onTap: onSearch,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    // Saat expanded: putih polos dengan shadow
                    // Saat collapsed: kaca semi transparan putih
                    color: Color.lerp(
                      Colors.white, 
                      Colors.white.withValues(alpha: 0.95), 
                      clampedPercent
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      )
                    ],
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.5),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search_rounded, color: _C.txt3, size: 24),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Cari sparepart, tools, APD...',
                          style: TextStyle(color: _C.txt3, fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(color: _C.primary, borderRadius: BorderRadius.circular(12)),
                        child: const Text('Cari', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderIcon(IconData icon, String? badge, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 1.5),
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          if (badge != null)
            Positioned(
              top: -2,
              right: -2,
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 4, offset: const Offset(0, 2))
                  ]
                ),
                child: Text(
                  badge,
                  style: const TextStyle(color: _C.primary, fontSize: 10, fontWeight: FontWeight.w800),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _HeroHeaderDelegate oldDelegate) {
    return oldDelegate.userName != userName || 
           oldDelegate.cartTotal != cartTotal ||
           oldDelegate.minHeight != minHeight ||
           oldDelegate.maxHeight != maxHeight;
  }
}
