import 'package:flutter/material.dart';
import 'package:mspeed/common/component/buyer_product_card.dart';
import 'package:mspeed/common/base/base_state.dart';
import 'package:mspeed/common/component/custom_navigator.dart';
import 'package:mspeed/common/helper/constant.dart';
import 'package:mspeed/src/buyer/cart/provider/shopping_cart_provider.dart';
import 'package:mspeed/src/buyer/product/view/detail_product_view.dart';
import 'package:mspeed/src/buyer/seller/view/seller_home_product_view.dart';
import 'package:mspeed/src/buyer/wishlist/model/buyer_wishlist_model.dart';
import 'package:mspeed/src/buyer/wishlist/provider/wishlist_provider.dart';
import 'package:mspeed/utils/utils.dart';
import 'package:provider/provider.dart';

class WishlistSayaView extends StatefulWidget {
  const WishlistSayaView({super.key});

  @override
  State<WishlistSayaView> createState() => _WishlistSayaViewState();
}

class _WishlistSayaViewState extends BaseState<WishlistSayaView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final searchController = TextEditingController();
  List<BuyerWishlistModelData?> wishlists = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    initData();
  }

  Future<void> initData() async {
    await context.read<WishlistProvider>().fetchWishlist();
  }

  @override
  void dispose() {
    _tabController.dispose();
    searchController.dispose();
    super.dispose();
  }

  Widget _buildEmptyState(String title, String subtitle) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Constant.dsPrimary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.favorite_border_rounded, size: 36, color: Constant.dsPrimary),
          ),
          const SizedBox(height: Constant.space16),
          Text(
            title,
            style: TextStyle(
              fontFamily: Constant.primaryTextStyle.fontFamily,
              color: Constant.dsTextPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: Constant.space8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: Constant.primaryTextStyle.fontFamily,
              color: Constant.dsTextSecondary,
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductGrid(List<BuyerWishlistModelDataDetail?> products) {
    if (products.isEmpty) {
      return _buildEmptyState('Wishlist kosong', 'Tambahkan produk yang kamu suka\nke dalam wishlist');
    }
    return GridView.builder(
      padding: const EdgeInsets.all(Constant.space16),
      physics: const AlwaysScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 14,
        childAspectRatio: 0.85,
      ),
      itemCount: products.length,
      itemBuilder: (ctx, i) {
        final e = products[i];
        return BuyerProductCard(
          imageUrl: e?.foto ?? "",
          title: e?.nama ?? "-",
          sellerName: "", // Optional since we are in products view
          category: e?.IDKategori ?? "-",
          rating: 5.0,
          soldCount: 0,
          price: double.tryParse(e?.harga ?? "0") ?? 0,
          isNew: false,
          isWishlisted: true,
          onTap: () async {
            await CusNav.nPush(context, DetailProductView(id: e?.ID ?? ''));
          },
          onWishlistTap: () {
            context.read<WishlistProvider>().deleteWishlist(
                  wishlistId: e?.IDWishlist?.toString() ?? e?.ID?.toString() ?? "",
                ).then((_) {
              context.read<WishlistProvider>().fetchWishlist(withLoading: true);
            });
          },
          onAddToCartTap: () {
            context.read<ShoppingCartProvider>().addToCart(
                  context,
                  produkId: e?.ID ?? "0",
                  qty: 1,
                ).then((_) {
              Utils.showSuccess(msg: "Produk berhasil ditambahkan ke cart");
            });
          },
        );
      },
    );
  }

  Widget _buildSellerCard(BuyerWishlistModelData seller) {
    return Container(
      margin: const EdgeInsets.only(bottom: Constant.space12),
      padding: const EdgeInsets.all(Constant.space12),
      decoration: BoxDecoration(
        color: Constant.dsSurface,
        borderRadius: BorderRadius.circular(Constant.radiusLg),
        border: Border.all(color: Constant.dsBorder, width: 1),
        boxShadow: [Constant.shadowSmall],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Constant.dsBackground,
              borderRadius: BorderRadius.circular(Constant.radiusMd),
            ),
            child: const Icon(Icons.storefront_rounded, color: Constant.dsPrimary, size: 24),
          ),
          const SizedBox(width: Constant.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  seller.namaseller ?? "-",
                  style: TextStyle(
                    fontFamily: Constant.primaryTextStyle.fontFamily,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Constant.dsTextPrimary,
                  ),
                ),
                const SizedBox(height: Constant.space4),
                Row(
                  children: [
                    const Icon(Icons.star_rounded, color: Constant.dsAccent, size: 14),
                    const SizedBox(width: Constant.space4),
                    Text(
                      '5.0', // Dummy rating
                      style: TextStyle(
                        fontFamily: Constant.primaryTextStyle.fontFamily,
                        fontSize: 11,
                        color: Constant.dsTextSecondary,
                      ),
                    ),
                    const SizedBox(width: Constant.space8),
                    const Icon(Icons.location_on_rounded, color: Constant.dsTextSecondary, size: 12),
                    const SizedBox(width: Constant.space4),
                    Text(
                      'Kota', // Dummy location
                      style: TextStyle(
                        fontFamily: Constant.primaryTextStyle.fontFamily,
                        fontSize: 11,
                        color: Constant.dsTextSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: () {
              CusNav.nPush(context, SellerHomeProductView(id: seller.SellerID ?? "0"));
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Constant.dsPrimary),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Constant.radiusSm)),
              padding: const EdgeInsets.symmetric(horizontal: Constant.space12, vertical: 0),
              minimumSize: const Size(0, 32),
            ),
            child: const Text(
              'Kunjungi',
              style: TextStyle(
                color: Constant.dsPrimary,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSellerList(List<BuyerWishlistModelData?> sellers) {
    if (sellers.isEmpty) {
      return _buildEmptyState('Toko favorit kosong', 'Belum ada toko yang kamu ikuti');
    }
    return ListView.builder(
      padding: const EdgeInsets.all(Constant.space16),
      itemCount: sellers.length,
      itemBuilder: (ctx, i) {
        if (sellers[i] == null) return const SizedBox();
        return _buildSellerCard(sellers[i]!);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<WishlistProvider>();
    if (wishlists.isEmpty && searchController.text.isEmpty) {
      wishlists = p.wishlistModel.data ?? [];
    }

    // Flatten all products for the Product tab
    List<BuyerWishlistModelDataDetail?> allProducts = [];
    for (var seller in wishlists) {
      if (seller?.detail != null) {
        allProducts.addAll(seller!.detail!);
      }
    }

    return Scaffold(
      backgroundColor: Constant.dsBackground,
      appBar: AppBar(
        backgroundColor: Constant.dsSurface,
        elevation: 0,
        titleSpacing: Constant.space16,
        centerTitle: false,
        title: const Text(
          'Wishlist',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Constant.dsTextPrimary,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(110),
          child: Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Constant.space16, vertical: Constant.space8),
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: Constant.dsSurface,
                    borderRadius: BorderRadius.circular(Constant.radiusLg),
                    boxShadow: [Constant.shadowSmall],
                  ),
                  child: TextField(
                    controller: searchController,
                    onChanged: (val) {
                      setState(() {
                        wishlists = p.wishlistModel.data?.where((element) =>
                            element?.namaseller?.toLowerCase().contains(val.toLowerCase()) ?? false).toList() ?? [];
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Cari produk wishlist...',
                      hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                      prefixIcon: Icon(Icons.search_rounded, color: Colors.grey.shade500, size: 20),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ),
              // TabBar
              TabBar(
                controller: _tabController,
                labelColor: Constant.dsPrimary,
                unselectedLabelColor: Constant.dsTextSecondary,
                indicatorColor: Constant.dsPrimary,
                indicatorWeight: 3,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                tabs: const [
                  Tab(text: 'Produk'),
                  Tab(text: 'Toko Favorit'),
                ],
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          RefreshIndicator(
            color: Constant.dsPrimary,
            onRefresh: () async {
              context.read<WishlistProvider>().fetchWishlist(withLoading: true);
            },
            child: _buildProductGrid(allProducts),
          ),
          RefreshIndicator(
            color: Constant.dsPrimary,
            onRefresh: () async {
              context.read<WishlistProvider>().fetchWishlist(withLoading: true);
            },
            child: _buildSellerList(wishlists),
          ),
        ],
      ),
    );
  }
}
