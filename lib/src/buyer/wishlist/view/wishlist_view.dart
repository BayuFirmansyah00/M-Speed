import 'package:flutter/material.dart';
import 'package:mspeed/common/base/base_state.dart';
import 'package:mspeed/src/buyer/wishlist/view/seller_favorite_view.dart';
import 'package:mspeed/src/buyer/wishlist/view/wishlist_saya_view.dart';

// ─── Palet Warna ─────────────────────────────────────────────
class _C {
  static const primary   = Color(0xFFE50012);
  static const bg        = Color(0xFFF5F5F7);
  static const card      = Color(0xFFFFFFFF);
  static const txt1      = Color(0xFF111827);
  static const txt3      = Color(0xFF9CA3AF);
  static const border    = Color(0xFFEEEEEE);
}

class WishlistView extends StatefulWidget {
  @override
  State<WishlistView> createState() => _WishlistViewState();
}

class _WishlistViewState extends BaseState<WishlistView> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: _C.bg,
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverAppBar(
              expandedHeight: 160,
              pinned: true,
              floating: false,
              snap: false,
              elevation: 0,
              scrolledUnderElevation: 0,
              // Collapsed state: putih bersih
              backgroundColor: _C.card,
              // Collapsed title
              title: AnimatedOpacity(
                opacity: innerBoxIsScrolled ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFE50012), Color(0xFFFF6B6B)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(Icons.favorite_rounded,
                          color: Colors.white, size: 13),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Wishlist Saya',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: _C.txt1,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              centerTitle: true,
              // Hero expanded header
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.parallax,
                background: _WishlistHeroHeader(),
              ),
              // Tab bar di bawah
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(50),
                child: Container(
                  color: _C.card,
                  child: Column(
                    children: [
                      Container(height: 1, color: _C.border),
                      TabBar(
                        indicatorSize: TabBarIndicatorSize.tab,
                        indicator: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: _C.primary, width: 3),
                          ),
                          color: Color(0x0EE50012),
                        ),
                        labelColor: _C.primary,
                        unselectedLabelColor: _C.txt3,
                        labelStyle: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 13),
                        unselectedLabelStyle: const TextStyle(
                            fontWeight: FontWeight.w400, fontSize: 13),
                        dividerColor: Colors.transparent,
                        tabs: const [
                          Tab(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.favorite_rounded, size: 15),
                                SizedBox(width: 6),
                                Text('Produk'),
                              ],
                            ),
                          ),
                          Tab(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.store_rounded, size: 15),
                                SizedBox(width: 6),
                                Text('Seller Favorit'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
          body: const TabBarView(
            children: [
              WishlistSayaView(),
              SellerFavoriteView(),
            ],
          ),
        ),
      ),
    );
  }
}

/// Hero banner untuk Wishlist
class _WishlistHeroHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFB8000E), Color(0xFFE50012), Color(0xFFFF4D5B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          // Dekorasi bulat besar kanan atas
          Positioned(
            top: -40,
            right: -40,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.07),
              ),
            ),
          ),
          // Bulat kecil kiri bawah
          Positioned(
            bottom: 20,
            left: -30,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          // Bulat tengah
          Positioned(
            top: 30,
            right: 100,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
          ),
          // Konten utama
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Wishlist Saya',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Produk & seller pilihanmu ada di sini',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
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
