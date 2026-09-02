import 'package:mspeed/common/component/buyer_product_card.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

import 'package:mspeed/common/base/base_state.dart';
import 'package:mspeed/common/component/custom_navigator.dart';
import 'package:mspeed/generated/assets.dart';

import 'package:mspeed/src/buyer/cart/view/buyer_cart_view.dart';
import 'package:mspeed/src/buyer/chat/view/chat_list_view.dart';
import 'package:mspeed/src/buyer/product/view/detail_product_view.dart';
import 'package:mspeed/src/buyer/wishlist/provider/wishlist_provider.dart';
import 'package:provider/provider.dart';

import '../../cart/provider/buyer_cart_provider.dart';
import 'package:mspeed/common/helper/app_colors.dart';
import '../provider/home_provider.dart';
import 'product_or_seller_search_view.dart';

// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
// COLOR TOKENS â€” Buyer Blue B2B Theme
// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
class _C {
  // Brand
  static Color get primary    => AppColors.buyerPrimary;       // #1565C0
  static Color get dark       => AppColors.buyerDark;          // #0D47A1
  static Color get light      => AppColors.buyerLight;         // #E3F2FD
  static Color get veryLight  => AppColors.buyerVeryLight;     // #F5F9FF

  // Background & Surface
  static Color get bg      => const Color(0xFFF5F7FA);

  // Text
  static Color get txt1    => const Color(0xFF1A1D26);
  static Color get txt2    => const Color(0xFF6B7280);
  static Color get txt3    => const Color(0xFF9CA3AF);
  static Color get divider => const Color(0xFFE5E7EB);
}

// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
// KATEGORI PASTEL COLORS (visual variety, not monotone blue)
// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
const _catPastelBg = [
  Color(0xFFDBEAFE), // Blue pastel  (Consumable)
  Color(0xFFDCFCE7), // Green pastel (APD)
  Color(0xFFFEF3C7), // Yellow pastel (Tools)
  Color(0xFFEDE9FE), // Purple pastel (Stationery)
  Color(0xFFFFE4E6), // Rose pastel   (Services)
  Color(0xFFE0F2FE), // Cyan pastel   (Other)
];
const _catIconColor = [
  Color(0xFF2563EB), // Blue
  Color(0xFF16A34A), // Green
  Color(0xFFF59E0B), // Amber
  Color(0xFF7C3AED), // Purple
  Color(0xFFE11D48), // Rose
  Color(0xFF0EA5E9), // Cyan
];

// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
// MAIN VIEW
// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
class HomeBuyerView extends StatefulWidget {
  @override
  State<HomeBuyerView> createState() => _HomeBuyerViewState();
}

class _HomeBuyerViewState extends BaseState<HomeBuyerView>
    with TickerProviderStateMixin {
  final _scroll = ScrollController();
  late AnimationController _shimmer;
  late AnimationController _entranceAnim;

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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
      _entranceAnim.forward();
    });
  }


  Future<void> _loadData() async {
    await context.read<HomeProvider>().fetchBuyerDashboard(withLoading: false);
    context.read<BuyerCartProvider>().fetchCart(
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

  // â”€â”€ Shimmer placeholder â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
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
    final products = homeP.buyerDashboardModel?.products ?? [];
    final categories = homeP.buyerDashboardModel?.categories ?? [];
    final cartTotal = context.watch<BuyerCartProvider>().totalCartItems;

    return Scaffold(
      backgroundColor: _C.bg,
      body: RefreshIndicator(
        color: _C.primary,
        strokeWidth: 2.5,
        displacement: 40,
        onRefresh: () async {
          await context.read<HomeProvider>().fetchBuyerDashboard(
            withLoading: false,
          );
          await context.read<BuyerCartProvider>().fetchCart(
            withLoading: false,
          );
        },
        child: CustomScrollView(
          controller: _scroll,
          physics: const BouncingScrollPhysics(),
          slivers: [
            // â”€â”€ Hero Header â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            _buildHeroHeader(cartTotal),

            // â”€â”€ Banner Carousel â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            SliverToBoxAdapter(child: _buildBanner(homeP)),

            // â”€â”€ Section: Kategori â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            SliverToBoxAdapter(
              child: _sectionHead(
                'Kategori Pilihan',
                icon: Icons.grid_view_rounded,
                onTap: () {},
              ),
            ),
            SliverToBoxAdapter(child: _buildCategories(categories)),

            // â”€â”€ Section: Produk â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
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
                    childAspectRatio: 0.85,
                  ),
                ),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 120)),
          ],
        ),
      ),
    );
  }

  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  // HERO HEADER â€” Gradient + Logo + Floating Search
  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  Widget _buildHeroHeader(int cartTotal) {
    return SliverToBoxAdapter(
      child: Stack(
        children: [
          // 1. Background (White left, Image right)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: 24, // Stop above half the search bar
            child: Container(
              color: _C.veryLight, // very light blue/white for the left area
              child: Stack(
                children: [
                  // Image on the right with diagonal clip
                  Positioned.fill(
                    child: ClipPath(
                      clipper: _HeaderImageClipper(),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.asset(
                            Assets.imagesImgTotalAlat, // using existing asset
                            fit: BoxFit.cover,
                          ),
                          // Blue overlay for readability
                          Container(
                            color: _C.primary.withValues(alpha: 0.25),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Red accent stripe along the diagonal edge
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _DiagonalStripePainter(),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. Foreground Content
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),

                  // â”€â”€ Top Row: Logo + Text + Icons â”€â”€
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left: Logo and text
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Image.asset(
                              Assets.imagesImgSplashLogo,
                              width: 120,
                              fit: BoxFit.contain,
                            ),
                          ],
                        ),
                      ),
                      
                      // Right: Icons
                      Row(
                        children: [
                          _HeaderIconBtn(
                            icon: Icons.notifications_none_rounded,
                            badge: null,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => ChatListView()),
                            ),
                          ),
                          const SizedBox(width: 10),
                          _HeaderIconBtn(
                            icon: Icons.shopping_cart_outlined,
                            badge: cartTotal > 0 ? '$cartTotal' : null,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => BuyerCartView()),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // â”€â”€ Floating Search Bar â”€â”€
                  Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18), // 16-20 radius
                      border: Border.all(color: const Color(0xFFDDE5F0), width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(18),
                        onTap: () => CusNav.nPush(context, ProductOrSellerSearchView()),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              Icon(Icons.search_rounded, color: _C.dark, size: 22),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Cari sparepart, tools, APD...',
                                  style: TextStyle(
                                    color: _C.txt3,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Container(width: 1, height: 24, color: const Color(0xFFDDE5F0)),
                              const SizedBox(width: 10),
                              Icon(Icons.qr_code_scanner_rounded, color: _C.dark, size: 20),
                              const SizedBox(width: 6),
                              Icon(Icons.arrow_drop_down_rounded, color: _C.txt2, size: 20),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  // BANNER CAROUSEL â€” Modern rounded with overlay
  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  Widget _buildBanner(HomeProvider p) {
    final banners = p.buyerDashboardModel?.banners ?? [];
    
    if (banners.isEmpty) {
      return const SizedBox(height: 16);
    }

    return Column(
      children: [
        const SizedBox(height: 16),
        CarouselSlider.builder(
          itemCount: banners.length,
          options: CarouselOptions(
            autoPlay: true,
            aspectRatio: 2.2,
            viewportFraction: 0.9,
            enlargeCenterPage: true,
            enlargeFactor: 0.14,
            autoPlayCurve: Curves.easeOutCubic,
            autoPlayAnimationDuration: const Duration(milliseconds: 800),
            onPageChanged: (i, _) => setState(() => p.currentIndex = i),
          ),
          itemBuilder: (ctx, i, realIdx) {
            final bannerUrl = banners[i].imgUrl;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.10),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    bannerUrl != null && bannerUrl.isNotEmpty
                        ? Image.network(
                            bannerUrl,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            errorBuilder: (context, error, stackTrace) =>
                                Image.asset(Assets.imagesHomeHeader, fit: BoxFit.cover),
                          )
                        : Image.asset(Assets.imagesHomeHeader, fit: BoxFit.cover),
                    // Gradient overlay for text readability
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      height: 60,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.45),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 14),
        // Pill-style dot indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(banners.length, (i) {
            final isActive = i == p.currentIndex;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: isActive ? 24 : 8,
              height: 8,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: isActive ? _C.primary : _C.divider,
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  // SECTION HEADER
  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  Widget _sectionHead(
    String title, {
    required VoidCallback onTap,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
      child: Row(
        children: [
          // Icon container
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: _C.primary,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: _C.primary.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(icon, size: 17, color: Colors.white),
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
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: _C.light,
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

  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  // CATEGORY LIST â€” Pastel circles with shadow
  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
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
        height: 108,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          physics: const BouncingScrollPhysics(),
          itemCount: 6,
          separatorBuilder: (_, __) => const SizedBox(width: 14),
          itemBuilder: (_, __) => Column(
            children: [
              _shimBox(w: 60, h: 60, r: 18),
              const SizedBox(height: 8),
              _shimBox(w: 48, h: 10, r: 6),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      height: 108,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        physics: const BouncingScrollPhysics(),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (ctx, i) {
          final cat = categories[i];
          final icon = i < icons.length ? icons[i] : Assets.iconsIcOther;
          final bgColor = _catPastelBg[i % _catPastelBg.length];
          final iconColor = _catIconColor[i % _catIconColor.length];

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
                offset: Offset(0, 24 * (1 - t.value)),
                child: Opacity(opacity: t.value.clamp(0.0, 1.0), child: child),
              );
            },
              child: GestureDetector(
              onTap: () async {
                debugPrint('CATEGORY CLICK: id = ${cat.id}, name = ${cat.name}');
                await CusNav.nPush(
                  context,
                  ProductOrSellerSearchView(
                    initialCategoryId: cat.id,
                    initialCategoryName: cat.name,
                  ),
                );
              },
              child: SizedBox(
                width: 72,
                child: Column(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: iconColor.withValues(alpha: 0.15),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Image.asset(
                          icon,
                          width: 30,
                          height: 30,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      cat.name ?? '',
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

  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  // PRODUCT CARD
  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  Widget _buildProductCard(List products, int i) {
    final item = products[i];

    return AnimatedBuilder(
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
      child: BuyerProductCard(
        imageUrl: item.images != null && item.images!.isNotEmpty ? item.images![0].imgUrl ?? '' : '',
        title: item.name ?? '-',
        sellerName: item.seller?.name?.trim().isNotEmpty == true ? item.seller!.name! : item.seller?.companyName ?? '-',
        category: item.category?.name ?? '-',
        rating: 4.9,
        soldCount: item.soldQty ?? 0,
        price: item.price ?? 0,
        isNew: i < 3,
        isWishlisted: item.isInWishlist ?? false,
        onTap: () async {
          await CusNav.nPush(context, DetailProductView(product: item));
          _loadData();
        },
        onWishlistTap: () async {
          final wishlistP = context.read<WishlistProvider>();
          final isCurrentlyFav = item.isInWishlist ?? false;
          final productId = item.id?.toString() ?? '';
          if (productId.isEmpty) return;
          setState(() { item.isInWishlist = !isCurrentlyFav; });
          try {
            if (isCurrentlyFav) {
              await wishlistP.deleteWishlist(productId: productId);
            } else {
              await wishlistP.addProductWishlist(productId: productId, productData: item);
            }
          } catch (_) {
            setState(() { item.isInWishlist = isCurrentlyFav; });
          }
        },
        onAddToCartTap: () {
          context.read<BuyerCartProvider>().addToCart(context, item.id ?? 0, qty: 1);
        },
      ),
    );
  }

  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  // EMPTY STATE â€” Friendly, not error-like
  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Multi-layered illustration
            Stack(
              alignment: Alignment.center,
              children: [
                // Outer ring
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _C.light,
                  ),
                ),
                // Inner circle
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _C.primary.withValues(alpha: 0.12),
                  ),
                  child: Icon(
                    Icons.inventory_2_rounded,
                    color: _C.primary,
                    size: 40,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Belum Ada Produk',
              style: TextStyle(
                color: _C.txt1,
                fontSize: 20,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Produk akan segera tersedia.\nCoba cek kategori lain atau refresh halaman.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _C.txt2,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),
            // Primary CTA button
            GestureDetector(
              onTap: _loadData,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                decoration: BoxDecoration(
                  color: _C.primary,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: _C.primary.withValues(alpha: 0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.refresh_rounded, color: Colors.white, size: 18),
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
            const SizedBox(height: 14),
            // Secondary CTA
            GestureDetector(
              onTap: () => CusNav.nPush(context, ProductOrSellerSearchView()),
              child: Text(
                'Jelajahi Kategori',
                style: TextStyle(
                  color: _C.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.underline,
                  decorationColor: _C.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
// HEADER ICON BUTTON â€” Pill/Circle with elevation + badge
// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
class _HeaderImageClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    // Diagonal clip from 35% at the top to 65% at the bottom
    path.moveTo(size.width * 0.35, 0); 
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width * 0.65, size.height); 
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
// DIAGONAL RED ACCENT STRIPE
// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
class _DiagonalStripePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary // M-Speed Red
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Same diagonal line as the clipper edge (35% top â†’ 65% bottom)
    // Offset slightly left so the stripe sits right on the edge
    final start = Offset(size.width * 0.35 - 2, 0);
    final end = Offset(size.width * 0.65 - 2, size.height);
    canvas.drawLine(start, end, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
// HEADER ICON BUTTON â€” Pill/Circle with elevation + badge
// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
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
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                )
              ],
            ),
            child: Icon(icon, color: AppColors.buyerDark, size: 22),
          ),
          if (badge != null && badge != '0')
            Positioned(
              top: -2,
              right: -2,
              child: Container(
                padding: const EdgeInsets.all(4),
                constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444), // Red badge
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFEF4444).withValues(alpha: 0.4),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    badge!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      height: 1,
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
