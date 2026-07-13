import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mspeed/common/base/base_state.dart';
import 'package:mspeed/common/component/custom_navigator.dart';
import 'package:mspeed/common/helper/safe_network_image.dart';
import 'package:mspeed/generated/assets.dart';
import 'package:mspeed/src/buyer/seller/view/seller_home_product_view.dart';
import 'package:mspeed/src/buyer/wishlist/model/buyer_seller_favorit_model.dart';
import 'package:mspeed/src/buyer/wishlist/provider/wishlist_provider.dart';
import 'package:provider/provider.dart';

// ─── Palet Warna ─────────────────────────────────────────────
class _C {
  static const primary   = Color(0xFFE50012);
  static const secondary = Color(0xFF0B4177);
  static const bg        = Color(0xFFF5F5F7);
  static const card      = Color(0xFFFFFFFF);
  static const txt1      = Color(0xFF111827);
  static const txt2      = Color(0xFF6B7280);
  static const txt3      = Color(0xFF9CA3AF);
  static const border    = Color(0xFFEEEEEE);

  static const shadow = BoxShadow(
    color: Color(0x0D000000),
    blurRadius: 10,
    offset: Offset(0, 3),
  );
}

class SellerFavoriteView extends StatefulWidget {
  const SellerFavoriteView({super.key});

  @override
  State<SellerFavoriteView> createState() => _SellerFavoriteViewState();
}

class _SellerFavoriteViewState extends BaseState<SellerFavoriteView> {
  @override
  void initState() {
    initData();
    super.initState();
  }

  Future<void> initData() async {
    await context.read<WishlistProvider>().fetchSellerWishlist();
  }

  List<BuyerSellerFavoritModelData?> sellerFav = [];
  final searchController = TextEditingController();

  void _showBottomSheet(BuildContext context, BuyerSellerFavoritModelData? item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: _C.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: _C.border,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Opsi Seller',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: _C.txt1,
                  ),
                ),
                const SizedBox(height: 8),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _C.secondary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: SvgPicture.asset(
                      Assets.svgsIcSheetShare,
                      width: 20,
                      colorFilter: const ColorFilter.mode(
                          _C.secondary, BlendMode.srcIn),
                    ),
                  ),
                  title: const Text(
                    'Bagikan Link Seller',
                    style: TextStyle(
                        fontWeight: FontWeight.w600, color: _C.txt1),
                  ),
                  subtitle: const Text('Salin & bagikan ke teman',
                      style: TextStyle(fontSize: 12, color: _C.txt2)),
                  onTap: () => Navigator.pop(ctx),
                ),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _C.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: SvgPicture.asset(
                      Assets.svgsIcSheetBuang,
                      width: 20,
                      colorFilter: const ColorFilter.mode(
                          _C.primary, BlendMode.srcIn),
                    ),
                  ),
                  title: const Text(
                    'Hapus dari Favorit',
                    style: TextStyle(
                        fontWeight: FontWeight.w600, color: _C.primary),
                  ),
                  subtitle: const Text('Seller tidak akan tersimpan lagi',
                      style: TextStyle(fontSize: 12, color: _C.txt2)),
                  onTap: () => Navigator.pop(ctx),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSellerCard(BuildContext context, int index) {
    final item = sellerFav[index];
    return GestureDetector(
      onTap: () {
        CusNav.nPush(context,
            SellerHomeProductView(id: item?.SellerID ?? "0", isFav: true));
      },
      child: Container(
        decoration: BoxDecoration(
          color: _C.card,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [_C.shadow],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            children: [
              // Banner / header gradient
              Container(
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _C.secondary.withValues(alpha: 0.8),
                      _C.secondary.withValues(alpha: 0.5),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    // Dekorasi latar
                    Positioned(
                      top: -15,
                      right: -15,
                      child: Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                    ),
                    // More options button
                    Positioned(
                      top: 6,
                      right: 6,
                      child: GestureDetector(
                        onTap: () => _showBottomSheet(context, item),
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.more_horiz_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Konten seller
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                child: Column(
                  children: [
                    // Avatar (overlap ke banner)
                    Transform.translate(
                      offset: const Offset(0, -24),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: SafeNetworkImage(
                          width: 48,
                          height: 48,
                          url: item?.foto ?? '',
                          borderRadius: 40,
                          errorBuilder:
                              Image.asset(Assets.imagesMainImageNotFound),
                        ),
                      ),
                    ),
                    // Info (di bawah avatar, dengan negative margin)
                    Transform.translate(
                      offset: const Offset(0, -16),
                      child: Column(
                        children: [
                          Text(
                            item?.SellerName.toString() ?? '-',
                            style: const TextStyle(
                              color: _C.txt1,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.location_on_rounded,
                                  size: 11, color: _C.txt3),
                              const SizedBox(width: 2),
                              Flexible(
                                child: Text(
                                  item?.alamat.toString() ?? '-',
                                  style: const TextStyle(
                                      color: _C.txt3, fontSize: 10),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          // Tombol kunjungi toko
                          SizedBox(
                            width: double.infinity,
                            height: 30,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                CusNav.nPush(
                                  context,
                                  SellerHomeProductView(
                                      id: item?.SellerID ?? "0",
                                      isFav: true),
                                );
                              },
                              icon: const Icon(Icons.store_rounded,
                                  size: 12, color: Colors.white),
                              label: const Text(
                                'Kunjungi Toko',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _C.secondary,
                                elevation: 0,
                                padding: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
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

  @override
  Widget build(BuildContext context) {
    final p = context.watch<WishlistProvider>();
    if (sellerFav.isEmpty && searchController.text.isEmpty) {
      sellerFav = p.sellerFavorite.data ?? [];
    }

    return Scaffold(
      backgroundColor: _C.bg,
      body: RefreshIndicator(
        color: _C.primary,
        backgroundColor: _C.card,
        onRefresh: () async {
          context.read<WishlistProvider>().fetchSellerWishlist(withLoading: true);
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // Search bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Container(
                  decoration: BoxDecoration(
                    color: _C.card,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: const [_C.shadow],
                  ),
                  child: TextField(
                    controller: searchController,
                    onChanged: (value) {
                      setState(() {
                        sellerFav = p.sellerFavorite.data
                                ?.where((element) =>
                                    element?.SellerName?.toLowerCase()
                                        .contains(value.toLowerCase()) ??
                                    false)
                                .toList() ??
                            [];
                      });
                    },
                    textInputAction: TextInputAction.search,
                    decoration: const InputDecoration(
                      hintText: 'Cari seller favorit...',
                      hintStyle: TextStyle(color: _C.txt3, fontSize: 13),
                      border: InputBorder.none,
                      prefixIcon: Icon(Icons.search_rounded,
                          color: _C.txt3, size: 20),
                      contentPadding: EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ),
            ),

            // Empty state
            if (sellerFav.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: _C.secondary.withValues(alpha: 0.08),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.store_rounded,
                            size: 36, color: _C.secondary),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Belum ada seller favorit',
                        style: TextStyle(
                          color: _C.txt1,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Tandai seller pilihanmu\nsupaya mudah ditemukan',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: _C.txt2, fontSize: 13, height: 1.5),
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 32),
                sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, index) => _buildSellerCard(ctx, index),
                    childCount: sellerFav.length,
                  ),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.78,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
