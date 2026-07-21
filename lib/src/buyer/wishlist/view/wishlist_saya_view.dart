import 'package:cached_network_image/cached_network_image.dart';
import 'package:dynamic_height_grid_view/dynamic_height_grid_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mspeed/common/base/base_state.dart';
import 'package:mspeed/common/component/custom_navigator.dart';
import 'package:mspeed/generated/assets.dart';
import 'package:mspeed/src/buyer/product/view/detail_product_view.dart';
import 'package:mspeed/src/buyer/seller/view/seller_home_product_view.dart';
import 'package:mspeed/src/buyer/wishlist/model/buyer_wishlist_model.dart';
import 'package:mspeed/src/buyer/wishlist/provider/wishlist_provider.dart';
import 'package:mspeed/utils/Utils.dart';
import 'package:provider/provider.dart';
import 'dart:developer';

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
  static const green     = Color(0xFF10B981);

  static const shadow = BoxShadow(
    color: Color(0x0D000000),
    blurRadius: 10,
    offset: Offset(0, 3),
  );
}

class WishlistSayaView extends StatefulWidget {
  const WishlistSayaView({super.key});

  @override
  State<WishlistSayaView> createState() => _WishlistSayaViewState();
}

class _WishlistSayaViewState extends BaseState<WishlistSayaView> {
  @override
  void initState() {
    initData();
    super.initState();
  }

  Future<void> initData() async {
    await context.read<WishlistProvider>().fetchWishlist();
  }

  List<BuyerWishlistModelData?> wishlists = [];
  final searchController = TextEditingController();

  void _showItemBottomSheet(
      BuildContext context, BuyerWishlistModelDataDetail data) {
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
                // Handle bar
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
                  'Opsi Produk',
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
                      Assets.svgsIcSheetLihatSeller,
                      width: 20,
                      colorFilter: const ColorFilter.mode(
                          _C.secondary, BlendMode.srcIn),
                    ),
                  ),
                  title: const Text(
                    'Lihat Seller',
                    style: TextStyle(
                        fontWeight: FontWeight.w600, color: _C.txt1),
                  ),
                  subtitle: const Text('Kunjungi toko seller ini',
                      style: TextStyle(fontSize: 12, color: _C.txt2)),
                  onTap: () {
                    Navigator.pop(ctx);
                    CusNav.nPush(
                        context,
                        SellerHomeProductView(
                            id: data.SellerID ?? "0"));
                  },
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
                    'Hapus dari Wishlist',
                    style: TextStyle(
                        fontWeight: FontWeight.w600, color: _C.primary),
                  ),
                  subtitle: const Text('Produk tidak akan tersimpan lagi',
                      style: TextStyle(fontSize: 12, color: _C.txt2)),
                  onTap: () {
                    context
                        .read<WishlistProvider>()
                        .deleteWishlist(wishlistId: data.IDWishlist?.toString() ?? data.ID.toString());
                    Navigator.pop(ctx);
                  },
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProductItem(BuyerWishlistModelDataDetail? e) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: _C.card,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [_C.shadow],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Gambar produk
              InkWell(
                onTap: () async {
                  await CusNav.nPush(
                      context, DetailProductView(id: e?.ID ?? ''));
                },
                child: Stack(
                  children: [
                    AspectRatio(
                      aspectRatio: 1,
                      child: CachedNetworkImage(
                        imageUrl: e?.foto ?? '',
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: _C.bg,
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: _C.primary,
                              strokeWidth: 2,
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: _C.bg,
                          child: const Center(
                            child: Icon(Icons.image_not_supported_rounded,
                                color: _C.txt3, size: 28),
                          ),
                        ),
                      ),
                    ),
                    // Heart badge
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: const Icon(Icons.favorite_rounded,
                            color: _C.primary, size: 14),
                      ),
                    ),
                  ],
                ),
              ),
              // Info produk
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      e?.nama ?? "-",
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                        color: _C.txt2,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      Utils.thousandSeparator(
                          int.parse(e?.harga ?? "0")),
                      style: const TextStyle(
                        color: _C.txt1,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.store_rounded,
                            size: 12, color: _C.txt3),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            e?.SellerID ?? '-',
                            style: const TextStyle(
                                color: _C.txt3, fontSize: 11),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Stok ${e?.qty} • ${e?.IDKategori}',
                      style: const TextStyle(
                          color: _C.txt3, fontSize: 11),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),
                    // Tombol aksi
                    Row(
                      children: [
                        InkWell(
                          onTap: () => _showItemBottomSheet(context, e!),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              border: Border.all(color: _C.border),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.more_horiz_rounded,
                                color: _C.txt2, size: 18),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: SizedBox(
                            height: 32,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                context
                                    .read<WishlistProvider>()
                                    .addToCart(
                                      context,
                                      produkId: e?.ID ?? "0",
                                    )
                                    .then((_) {
                                  Utils.showSuccess(
                                      msg:
                                          "Produk berhasil ditambahkan ke cart");
                                });
                              },
                              icon: const Icon(Icons.add_shopping_cart_rounded,
                                  color: Colors.white, size: 13),
                              label: const Text(
                                "Keranjang",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _C.primary,
                                elevation: 0,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 6),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
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

  @override
  Widget build(BuildContext context) {
    final p = context.watch<WishlistProvider>();
    if (wishlists.isEmpty && searchController.text.isEmpty) {
      wishlists = p.wishlistModel.data ?? [];
    }

    log("WISHLISTS : $wishlists");

    return Scaffold(
      backgroundColor: _C.bg,
      body: RefreshIndicator(
        color: _C.primary,
        backgroundColor: _C.card,
        onRefresh: () async {
          context.read<WishlistProvider>().fetchWishlist(withLoading: true);
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
                    onChanged: (val) {
                      setState(() {
                        wishlists = p.wishlistModel.data
                                ?.where((element) =>
                                    element?.namaseller
                                        ?.toLowerCase()
                                        .contains(val.toLowerCase()) ??
                                    false)
                                .toList() ??
                            [];
                      });
                    },
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: 'Cari produk wishlist...',
                      hintStyle: const TextStyle(
                          color: _C.txt3, fontSize: 13),
                      border: InputBorder.none,
                      prefixIcon: const Icon(Icons.search_rounded,
                          color: _C.txt3, size: 20),
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ),
            ),

            // Kosong state
            if (wishlists.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: _C.primary.withValues(alpha: 0.08),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.favorite_border_rounded,
                            size: 36, color: _C.primary),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Wishlist kosong',
                        style: TextStyle(
                          color: _C.txt1,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Tambahkan produk yang kamu suka\nke dalam wishlist',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: _C.txt2, fontSize: 13, height: 1.5),
                      ),
                    ],
                  ),
                ),
              )
            else
              // Daftar wishlist per seller
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 32),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header seller
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: _C.card,
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: const [_C.shadow],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: _C.secondary
                                          .withValues(alpha: 0.1),
                                      borderRadius:
                                          BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                      Icons.store_rounded,
                                      size: 18,
                                      color: _C.secondary,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      wishlists[i]?.namaseller ?? "-",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                        color: _C.txt1,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  SizedBox(
                                    height: 36,
                                    child: ElevatedButton.icon(
                                      onPressed: () {
                                        context
                                            .read<WishlistProvider>()
                                            .addAllToCart(
                                              sellerId: wishlists[i]
                                                      ?.SellerID ??
                                                  '',
                                            );
                                      },
                                      icon: const Icon(
                                        Icons.add_shopping_cart_rounded,
                                        color: Colors.white,
                                        size: 13,
                                      ),
                                      label: const Text(
                                        'Semua',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: _C.primary,
                                        elevation: 0,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            // Grid produk
                            DynamicHeightGridView(
                              builder: (context, index) {
                                return _buildProductItem(
                                    wishlists[i]?.detail?[index]);
                              },
                              shrinkWrap: true,
                              physics:
                                  const NeverScrollableScrollPhysics(),
                              itemCount:
                                  wishlists[i]?.detail?.length ?? 0,
                              crossAxisCount: 2,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                            ),
                          ],
                        ),
                      );
                    },
                    childCount: wishlists.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
