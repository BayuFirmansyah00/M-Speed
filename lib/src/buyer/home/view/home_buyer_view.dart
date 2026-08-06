import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

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

// ─── COLOR TOKENS (mapped from Constant.dart) ─────────────────
class _C {
  // Brand
  static Color get primary => Constant.primaryColor;       // #2E7DAB
  static Color get secondary => Constant.secondaryColor;   // #E53935
  static Color get accent => Constant.tertiaryColor;       // #FBC02D
  static Color get primaryBg => Constant.primaryColor.withValues(alpha: 0.08);

  // Background & Surface
  static Color get bg => Constant.backgroundColor;         // #F8F9FB
  static Color get surface => Constant.textColorWhite;
  static Color get surfaceAlt => const Color(0xFFF0F4F8);

  // Text
  static Color get txt1 => Constant.textColorBlack;        // #212121
  static Color get txt2 => Constant.textColor2;            // #757575
  static Color get txt3 => Constant.textHintColor;         // #999999
  static Color get divider => Constant.borderLightColor;   // #E0E0E0

  // Shadow
  static BoxShadow get cardShadow => BoxShadow(
    color: Colors.black.withValues(alpha: 0.04),
    blurRadius: 12,
    offset: const Offset(0, 2),
  );
}

// ─── KATEGORI SOLID COLORS ────────────────────────────────────
const _catColors = [
  Color(0xFFE53935), // Consumable - Red
  Color(0xFF2E7DAB), // APD - Blue (primary)
  Color(0xFF43A047), // Tools - Green
  Color(0xFFFBC02D), // Stationery - Yellow (accent)
  Color(0xFF7B1FA2), // Services - Purple
  Color(0xFF00897B), // Other - Teal
];

// ─── BADGE PRODUK ─────────────────────────────────────────────
class _Badge {
  final String label;
  final Color color;
  final Color bg;
  const _Badge({required this.label, required this.color, required this.bg});
}

_Badge? _getBadge(int index, dynamic item) {
  if (item?.terjual != null &&
      (item.terjual is int
              ? item.terjual
              : int.tryParse('${item.terjual}') ?? 0) >
          50) {
    return const _Badge(
      label: 'TERLARIS',
      color: Color(0xFFE53935),
      bg: Color(0xFFFFEBEE),
    );
  }
  if (index < 3) {
    return const _Badge(
      label: 'BARU',
      color: Color(0xFF2E7DAB),
      bg: Color(0xFFE3F2FD),
    );
  }
  return null;
}

// ─── MAIN VIEW ────────────────────────────────────────────────
class HomeBuyerView extends StatefulWidget {
  @override
  State<HomeBuyerView> createState() => _HomeBuyerViewState();
}

class _HomeBuyerViewState extends BaseState<HomeBuyerView>
    with TickerProviderStateMixin {
  final _scroll = ScrollController();
  late AnimationController _shimmer;
  late AnimationController _entranceAnim;
  String _userName = '';
  String _greeting = '';

  @override
  void initState() {
    super.initState();

    _shimmer = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();

    _entranceAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _updateGreeting();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
      _loadUser();
      _entranceAnim.forward();
    });
  }

  void _updateGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 4 && hour < 11) {
      _greeting = 'Selamat Pagi';
    } else if (hour >= 11 && hour < 15) {
      _greeting = 'Selamat Siang';
    } else if (hour >= 15 && hour < 19) {
      _greeting = 'Selamat Sore';
    } else {
      _greeting = 'Selamat Malam';
    }
  }

  Future<void> _loadUser() async {
    final p = await SharedPreferences.getInstance();
    if (mounted) {
      setState(
        () => _userName = p.getString(Constant.kSetPrefFirstName) ?? 'Pengguna',
      );
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
    _entranceAnim.dispose();
    super.dispose();
  }

  // ── Shimmer placeholder ─────────────────────────────────────
  Widget _shimBox({double? w, double? h, double r = 12}) => AnimatedBuilder(
    animation: _shimmer,
    builder: (_, __) => Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(r),
        color: const Color(0xFFEEF0F3),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final homeP = context.watch<HomeProvider>();
    final products = homeP.buyerHomeProductModel.data ?? [];
    final categories = homeP.kategoriModel?.data ?? [];
    final cartTotal = context.watch<ShoppingCartProvider>().countQtyCartItem();

    return Scaffold(
      backgroundColor: _C.bg,
      body: RefreshIndicator(
        color: _C.primary,
        strokeWidth: 2.5,
        displacement: 40,
        onRefresh: () async {
          await context.read<HomeProvider>().getHomeProducts(
            withLoading: false,
          );
          await context.read<HomeProvider>().fetchKategori(withLoading: false);
          await context.read<ShoppingCartProvider>().fetchShoppingCart(
            context,
            withLoading: false,
          );
        },
        child: CustomScrollView(
          controller: _scroll,
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            // ── Hero Header ──────────────────────────────────
            _buildHeroHeader(cartTotal),

            // ── Banner Carousel ──────────────────────────────
            SliverToBoxAdapter(child: _buildBanner(homeP)),

            // ── Section: Kategori ────────────────────────────
            SliverToBoxAdapter(
              child: _sectionHead(
                'Kategori Pilihan',
                icon: Icons.grid_view_rounded,
                onTap: () {},
              ),
            ),
            SliverToBoxAdapter(child: _buildCategories(categories)),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // ── Section: Produk ──────────────────────────────
            SliverToBoxAdapter(
              child: _sectionHead(
                'Semua Produk',
                icon: Icons.storefront_rounded,
                onTap: () => CusNav.nPush(context, ProductOrSellerSearchView()),
              ),
            ),

            if (products.isEmpty)
              SliverFillRemaining(hasScrollBody: false, child: _buildEmpty())
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) => _buildProductCard(products, i),
                    childCount: products.length < 20 ? products.length : 20,
                  ),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 14,
                    childAspectRatio: 0.52,
                  ),
                ),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 120)),
          ],
        ),
      ),
    );
  }

  // ─── HERO HEADER ──────────────────────────────────────────
  Widget _buildHeroHeader(int cartTotal) {
    return SliverPersistentHeader(
      pinned: false,
      delegate: _HeroHeaderDelegate(
        minHeight: MediaQuery.of(context).padding.top + 72,
        maxHeight: MediaQuery.of(context).padding.top + 172,
        userName: _userName,
        greeting: _greeting,
        cartTotal: cartTotal,
        onChat: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ChatListView()),
        ),
        onCart: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ShoppingCartView()),
        ),
        onSearch: () => CusNav.nPush(context, ProductOrSellerSearchView()),
      ),
    );
  }

  // ─── BANNER CAROUSEL ───────────────────────────────────────
  Widget _buildBanner(HomeProvider p) {
    final banners = [
      Assets.imagesHomeHeader,
      Assets.imagesHomeHeader,
      Assets.imagesHomeHeader,
    ];
    return Column(
      children: [
        const SizedBox(height: 16),
        CarouselSlider.builder(
          itemCount: banners.length,
          options: CarouselOptions(
            autoPlay: true,
            height: 180,
            viewportFraction: 0.92,
            enlargeCenterPage: true,
            enlargeFactor: 0.12,
            autoPlayCurve: Curves.easeOutCubic,
            autoPlayAnimationDuration: const Duration(milliseconds: 800),
            onPageChanged: (i, _) => setState(() => p.currentIndex = i),
          ),
          itemBuilder: (ctx, i, realIdx) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _C.divider, width: 1),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.asset(
                  banners[i],
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 14),
        DotsIndicator(
          dotsCount: banners.length,
          position: p.currentIndex.toDouble(),
          decorator: DotsDecorator(
            color: _C.divider,
            activeColor: _C.primary,
            size: const Size(7, 7),
            activeSize: const Size(24, 7),
            spacing: const EdgeInsets.symmetric(horizontal: 3),
            activeShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  // ─── SECTION HEADER ───────────────────────────────────────
  Widget _sectionHead(
    String title, {
    required VoidCallback onTap,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 16, 14),
      child: Row(
        children: [
          // Solid color icon container
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: _C.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 16, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: _C.txt1,
              letterSpacing: -0.3,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _C.primaryBg,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Text(
                    'Lihat Semua',
                    style: TextStyle(
                      fontSize: 12,
                      color: _C.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 10,
                    color: _C.primary,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── CATEGORY LIST ────────────────────────────────────────
  Widget _buildCategories(List categories) {
    final icons = [
      Assets.iconsIcConsumable,
      Assets.iconsIcApd,
      Assets.assetsIconsIcTools,
      Assets.iconsIcStationery,
      Assets.assetsIconsIcServices,
      Assets.iconsIcOther,
    ];

    if (categories.isEmpty) {
      return SizedBox(
        height: 110,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          physics: const BouncingScrollPhysics(),
          itemCount: 6,
          separatorBuilder: (_, __) => const SizedBox(width: 16),
          itemBuilder: (_, __) => Column(
            children: [
              _shimBox(w: 64, h: 64, r: 16),
              const SizedBox(height: 8),
              _shimBox(w: 50, h: 10, r: 6),
            ],
          ),
        ),
      );
    }

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
          final solidColor = _catColors[i % _catColors.length];
          final softBg = solidColor.withValues(alpha: 0.10);

          return AnimatedBuilder(
            animation: _entranceAnim,
            builder: (_, child) {
              final delay = (0.2 + i * 0.08).clamp(0.0, 1.0);
              final t = CurvedAnimation(
                parent: _entranceAnim,
                curve: Interval(
                  delay,
                  (delay + 0.4).clamp(0.0, 1.0),
                  curve: Curves.easeOutBack,
                ),
              );
              return Transform.translate(
                offset: Offset(0, 30 * (1 - t.value)),
                child: Opacity(opacity: t.value.clamp(0.0, 1.0), child: child),
              );
            },
            child: GestureDetector(
              onTap: () async {
                final map = context.read<HomeProvider>().kategoriMap;
                final name = cat?.nama ?? '';
                if (map.containsKey(name)) {
                  map.updateAll((k, v) => false);
                  map[name] = true;
                }
                await CusNav.nPush(context, ProductOrSellerSearchView());
              },
              child: SizedBox(
                width: 72,
                child: Column(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: softBg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: solidColor.withValues(alpha: 0.15),
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: Image.asset(
                          icon,
                          width: 34,
                          height: 34,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      cat?.nama ?? '',
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        color: _C.txt1,
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ─── PRODUCT CARD ─────────────────────────────────────────
  Widget _buildProductCard(List products, int i) {
    final item = products[i];
    final badge = _getBadge(i, item);

    return GestureDetector(
      onTap: () => CusNav.nPush(context, DetailProductView(id: item?.ID ?? '')),
      child: AnimatedBuilder(
        animation: _entranceAnim,
        builder: (_, child) {
          final delay = (0.3 + (i * 0.04)).clamp(0.0, 0.9);
          final t = CurvedAnimation(
            parent: _entranceAnim,
            curve: Interval(
              delay,
              (delay + 0.4).clamp(0.0, 1.0),
              curve: Curves.easeOut,
            ),
          );
          return Transform.translate(
            offset: Offset(0, 30 * (1 - t.value)),
            child: Opacity(opacity: t.value.clamp(0.0, 1.0), child: child),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: _C.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _C.divider, width: 1),
            boxShadow: [_C.cardShadow],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Image + Badge ──────────────────────────────
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(15),
                    ),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: CachedNetworkImage(
                        imageUrl: item?.foto ?? '',
                        fit: BoxFit.cover,
                        cacheManager: CacheManager(
                          Config(
                            'ms_${item?.ID ?? i}',
                            stalePeriod: const Duration(days: 7),
                          ),
                        ),
                        placeholder: (_, __) =>
                            _shimBox(h: double.infinity, r: 0),
                        errorWidget: (_, __, ___) => Container(
                          color: _C.surfaceAlt,
                          child: Center(
                            child: Icon(
                              Icons.image_not_supported_rounded,
                              color: _C.txt3,
                              size: 32,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (badge != null)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: badge.bg,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          badge.label,
                          style: TextStyle(
                            fontSize: 9,
                            color: badge.color,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ),
                ],
              ),

              // ── Product Info ──────────────────────────────
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product name
                    Text(
                      item?.nama ?? '-',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _C.txt1,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Price
                    Text(
                      Utils.thousandSeparatorFromString(item?.harga ?? '0'),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: _C.secondary,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Category chip
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _C.primaryBg,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        item?.NamaKategori ?? '-',
                        style: TextStyle(
                          fontSize: 9,
                          color: _C.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Store name
                    Row(
                      children: [
                        Icon(
                          Icons.storefront_rounded,
                          size: 11,
                          color: _C.txt3,
                        ),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            item?.SellerNama ?? '-',
                            style: TextStyle(
                              fontSize: 10,
                              color: _C.txt2,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Rating & sold
                    Row(
                      children: [
                        Icon(
                          Icons.star_rounded,
                          size: 11,
                          color: _C.accent,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '4.9',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: _C.txt2,
                          ),
                        ),
                        Text(
                          ' · ',
                          style: TextStyle(fontSize: 10, color: _C.txt3),
                        ),
                        Flexible(
                          child: Text(
                            '${item?.terjual ?? 0} terjual',
                            style: TextStyle(fontSize: 10, color: _C.txt2),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── EMPTY STATE ──────────────────────────────────────────
  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Illustration circle - solid color
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: _C.primaryBg,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.inventory_2_rounded, color: _C.primary, size: 48),
          ),
          const SizedBox(height: 20),
          Text(
            'Belum Ada Produk',
            style: TextStyle(
              color: _C.txt1,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Produk belum tersedia saat ini.\nCoba refresh halaman.',
            textAlign: TextAlign.center,
            style: TextStyle(color: _C.txt2, fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 24),
          // Solid color button
          GestureDetector(
            onTap: _loadData,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: _C.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.refresh_rounded, color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Muat Ulang',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── HERO HEADER DELEGATE ─────────────────────────────────────
class _HeroHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;
  final String userName;
  final String greeting;
  final int cartTotal;
  final VoidCallback onChat;
  final VoidCallback onCart;
  final VoidCallback onSearch;

  _HeroHeaderDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.userName,
    required this.greeting,
    required this.cartTotal,
    required this.onChat,
    required this.onCart,
    required this.onSearch,
  });

  @override
  double get minExtent => minHeight;
  @override
  double get maxExtent => maxHeight;

  String get _initials {
    if (userName.isEmpty) return 'M';
    final parts = userName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return userName[0].toUpperCase();
  }

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final pct = (shrinkOffset / (maxHeight - minHeight)).clamp(0.0, 1.0);

    return Stack(
      children: [
        // ── 1. Solid Header Background ────────────────────
        Positioned.fill(
          child: Container(
            color: Constant.primaryColor, // Solid M-SPEED Blue
          ),
        ),

        // ── 2. Rounded Bottom Clipper ─────────────────────
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            height: 24,
            decoration: BoxDecoration(
              color: Constant.backgroundColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
          ),
        ),

        // ── 3. Greeting + Avatar + Icons ──────────────────
        Positioned(
          top: MediaQuery.of(context).padding.top + 14,
          left: 20,
          right: 20,
          child: Opacity(
            opacity: (1 - pct * 2).clamp(0.0, 1.0),
            child: Row(
              children: [
                // Avatar circle
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.4),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      _initials,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$greeting,',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        userName.isNotEmpty ? userName : 'Pengguna',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // Chat Icon
                _HeaderIconBtn(
                  icon: Icons.chat_bubble_outline_rounded,
                  badge: null,
                  onTap: onChat,
                ),
                const SizedBox(width: 10),
                // Cart Icon
                _HeaderIconBtn(
                  icon: Icons.shopping_bag_outlined,
                  badge: cartTotal > 0 ? '$cartTotal' : null,
                  onTap: onCart,
                ),
              ],
            ),
          ),
        ),

        // ── 4. Search Bar ─────────────────────────────────
        Positioned(
          bottom: 30,
          left: 16,
          right: 16,
          child: GestureDetector(
            onTap: onSearch,
            child: Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(Icons.search_rounded, color: _C.txt3, size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Cari sparepart, tools, APD...',
                      style: TextStyle(
                        color: _C.txt3,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  // Solid "Cari" button
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: _C.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'Cari',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  bool shouldRebuild(covariant _HeroHeaderDelegate old) =>
      old.userName != userName ||
      old.greeting != greeting ||
      old.cartTotal != cartTotal ||
      old.minHeight != minHeight ||
      old.maxHeight != maxHeight;
}

// ─── HEADER ICON BUTTON ───────────────────────────────────────
class _HeaderIconBtn extends StatelessWidget {
  final IconData icon;
  final String? badge;
  final VoidCallback onTap;

  const _HeaderIconBtn({required this.icon, this.badge, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 21),
          ),
          if (badge != null)
            Positioned(
              top: -3,
              right: -3,
              child: Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: Constant.secondaryColor, // Red badge
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    badge!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
