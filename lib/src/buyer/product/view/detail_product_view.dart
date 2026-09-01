import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mspeed/common/component/custom_navigator.dart';
import 'package:mspeed/generated/assets.dart';
import 'package:mspeed/src/buyer/cart/provider/buyer_cart_provider.dart';
import 'package:mspeed/src/buyer/cart/view/buyer_cart_view.dart';
import 'package:mspeed/src/buyer/chat/view/chat_person_view.dart';
import 'package:mspeed/src/buyer/wishlist/provider/wishlist_provider.dart';
import 'package:mspeed/utils/utils.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import 'package:mspeed/common/helper/constant.dart';
import '../../../../common/component/image_carousel.dart';
import '../../home/model/buyer_dashboard_model.dart';

class DetailProductView extends StatefulWidget {
  final DashboardProductModel product;

  DetailProductView({Key? key, required this.product}) : super(key: key);

  @override
  State<DetailProductView> createState() => _DetailProductViewState();
}

class _DetailProductViewState extends State<DetailProductView> {
  bool isFav = false;
  
  @override
  void initState() {
    super.initState();
    isFav = widget.product.isInWishlist ?? false;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BuyerCartProvider>().fetchCart();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cartTotal = context.watch<BuyerCartProvider>().totalCartItems;
    final product = widget.product;

    Widget buildProductDetailRow(String label, String value,
        {Color textColor = const Color(0xFF111827)}) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 110,
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF6B7280),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Expanded(
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 13,
                  color: textColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }

    Widget buildBottomBar() {
      return Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey.shade200)),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.red.shade100, width: 1.5),
                borderRadius: BorderRadius.circular(14),
                color: Colors.red.shade50,
              ),
              child: IconButton(
                onPressed: () {
                  final seller = product.seller;
                  final sellerName = seller?.name?.trim().isNotEmpty == true
                      ? seller!.name!.trim()
                      : seller?.companyName?.trim().isNotEmpty == true
                          ? seller!.companyName!.trim()
                          : 'Nama Toko';

                  CusNav.nPush(
                      context,
                      ChatPersonView(
                          id: seller?.id?.toString() ?? '',
                          sellerName: sellerName));
                },
                icon: Icon(Icons.chat_bubble_outline_rounded,
                    color: Constant.primaryColor),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    Utils.showLoading();
                    await context
                        .read<BuyerCartProvider>()
                        .addToCart(context, product.id ?? 0, qty: 1);
                    Utils.dismissLoading();
                    CusNav.nPushReplace(context, BuyerCartView());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Constant.primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Tambah ke Keranjang',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7), // Light grey background like home page
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: const Text(
          "Detail Produk",
          style: TextStyle(
              color: Colors.black, fontSize: 16, fontWeight: FontWeight.w700),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            onPressed: () {
              String shareImg = '';
              if (product.images != null) {
                final valid = product.images!
                    .where((e) => e.imgUrl != null && e.imgUrl!.trim().isNotEmpty)
                    .toList();
                if (valid.isNotEmpty) {
                  shareImg = valid.first.imgUrl!;
                }
              }
              Share.share(shareImg, subject: product.name ?? 'Produk');
            },
            icon: const Icon(Icons.ios_share_rounded, color: Colors.black, size: 22),
          ),
          IconButton(
            onPressed: () {
              CusNav.nPush(context, BuyerCartView());
            },
            icon: cartTotal == 0
                ? SvgPicture.asset(Assets.svgsIcCart, width: 24)
                : Badge(
                    isLabelVisible: true,
                    label: Text('$cartTotal'),
                    offset: const Offset(8, -4),
                    backgroundColor: Constant.primaryColor,
                    child: SvgPicture.asset(Assets.svgsIcCart, width: 24),
                  ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                // Product Image
                Container(
                  color: Colors.white,
                  child: Builder(
                    builder: (ctx) {
                      List<String> validUrls = [];
                      if (product.images != null) {
                        for (var img in product.images!) {
                          if (img.imgUrl != null && img.imgUrl!.trim().isNotEmpty) {
                            validUrls.add(img.imgUrl!);
                          }
                        }
                      }
                      
                      if (validUrls.isEmpty) {
                        return Container(
                          height: 250,
                          color: Colors.grey.shade200,
                          alignment: Alignment.center,
                          child: Icon(Icons.image_not_supported_rounded, size: 50, color: Colors.grey),
                        );
                      }
                      
                      return ImageCarousel(
                        imageUrls: validUrls,
                      );
                    },
                  ),
                ),
                
                // Title and Price Section
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              'Rp ${Utils.formatCurrency(product.price ?? 0)}',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: Constant.textPriceColor,
                              ),
                            ),
                          ),
                          StatefulBuilder(
                            builder: (BuildContext context, StateSetter setFavState) {
                              return GestureDetector(
                                onTap: () async {
                                  final wishlistP = context.read<WishlistProvider>();
                                  if (wishlistP.wishlistActionLoading) return; // guard double-tap
                                  final productId = product.id?.toString() ?? '';
                                  if (productId.isEmpty) return;

                                  final wasInWishlist = isFav;
                                  // Optimistic UI
                                  setFavState(() { isFav = !wasInWishlist; });
                                  // Sync back to dashboard model object
                                  widget.product.isInWishlist = !wasInWishlist;

                                  try {
                                    if (wasInWishlist) {
                                      await wishlistP.deleteWishlist(productId: productId);
                                    } else {
                                      await wishlistP.addProductWishlist(
                                        productId: productId,
                                        productData: product,
                                      );
                                    }
                                  } catch (_) {
                                    // Revert on failure
                                    setFavState(() { isFav = wasInWishlist; });
                                    widget.product.isInWishlist = wasInWishlist;
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: isFav ? Colors.red.shade50 : Colors.grey.shade100,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                    color: isFav ? Constant.primaryColor : Colors.grey,
                                    size: 24,
                                  ),
                                ),
                              );
                            },
                          )
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        product.name ?? 'Nama produk tidak tersedia',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF111827),
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              border: Border.all(color: Colors.grey.shade200),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.inventory_2_outlined, size: 14, color: Colors.grey),
                                const SizedBox(width: 6),
                                Text(
                                  'Stok: ${product.qty ?? 0}',
                                  style: const TextStyle(
                                      fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              border: Border.all(color: Colors.grey.shade200),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.sell_outlined, size: 14, color: Colors.grey),
                                const SizedBox(width: 6),
                                Text(
                                  'Terjual: ${product.soldQty ?? 0}',
                                  style: const TextStyle(
                                      fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 10),

                // Store / Seller Info
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.storefront_rounded, color: Constant.primaryColor),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Builder(
                              builder: (ctx) {
                                final seller = product.seller;
                                final sellerName = seller?.name?.trim().isNotEmpty == true
                                    ? seller!.name!.trim()
                                    : seller?.companyName?.trim().isNotEmpty == true
                                        ? seller!.companyName!.trim()
                                        : 'Nama Toko';
                                return Text(
                                  sellerName,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF111827),
                                  ),
                                );
                              }
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.location_on_rounded, size: 14, color: Colors.grey),
                                const SizedBox(width: 4),
                                const Text(
                                  'Lokasi belum tersedia',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded, color: Colors.grey),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // Product Detail & Description
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Detail Produk',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          children: [
                            buildProductDetailRow('Kode Produk', product.productCode ?? '-'),
                            const Divider(height: 16, color: Color(0xFFEEEEEE)),
                            buildProductDetailRow('Ukuran', product.size ?? '-'),
                            const Divider(height: 16, color: Color(0xFFEEEEEE)),
                            buildProductDetailRow('Kategori', product.category?.name ?? '-', textColor: Constant.primaryColor),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Deskripsi Produk',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        product.description?.isNotEmpty == true ? product.description! : 'Deskripsi produk tidak tersedia.',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF4B5563),
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 16),
                      InkWell(
                        onTap: () {},
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Baca Selengkapnya',
                              style: TextStyle(color: Constant.primaryColor, fontWeight: FontWeight.w600, fontSize: 13),
                            ),
                            Icon(Icons.keyboard_arrow_down_rounded, color: Constant.primaryColor, size: 18),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16)
                    ],
                  ),
                ),
                
                const SizedBox(height: 40),
              ],
            ),
          ),
          buildBottomBar(),
        ],
      ),
    );
  }
}
