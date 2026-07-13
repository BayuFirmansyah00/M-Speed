import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mspeed/common/component/custom_appbar.dart';
import 'package:mspeed/common/component/custom_navigator.dart';
import 'package:mspeed/generated/assets.dart';
import 'package:mspeed/src/buyer/cart/provider/shopping_cart_provider.dart';
import 'package:mspeed/src/buyer/cart/view/shopping_cart_view.dart';
import 'package:mspeed/src/buyer/chat/view/chat_person_view.dart';
import 'package:mspeed/src/buyer/wishlist/provider/wishlist_provider.dart';
import 'package:mspeed/utils/utils.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../common/component/image_carousel.dart';
import '../provider/product_provider.dart';

class DetailProductView extends StatefulWidget {
  final String id;

  DetailProductView({Key? key, required this.id}) : super(key: key);

  @override
  State<DetailProductView> createState() => _DetailProductViewState();
}

class _DetailProductViewState extends State<DetailProductView> {
  bool isFav = false;
  @override
  void initState() {
    getData();
    super.initState();
  }

  getData() async {
    Utils.showLoading();
    await context
        .read<ProductProvider>()
        .fetchDetailProduct(productId: widget.id);
    await context.read<ShoppingCartProvider>().fetchShoppingCart(context);
    Utils.dismissLoading();
  }

  @override
  Widget build(BuildContext context) {
    final data = context.watch<ProductProvider>().productModel.data?.first;
    final cartTotal = context.watch<ShoppingCartProvider>().countQtyCartItem();

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
                  CusNav.nPush(
                      context,
                      ChatPersonView(
                          id: data?.SellerID ?? '',
                          sellerName: data?.SellerNama ?? ''));
                },
                icon: const Icon(Icons.chat_bubble_outline_rounded,
                    color: Color(0xFFE50012)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    await context
                        .read<ShoppingCartProvider>()
                        .addToCart(context, produkId: data?.ID ?? '0', qty: 1);
                    CusNav.nPushReplace(context, ShoppingCartView());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE50012),
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
              Share.share(data?.foto ?? '', subject: data?.nama ?? '');
            },
            icon: const Icon(Icons.ios_share_rounded, color: Colors.black, size: 22),
          ),
          IconButton(
            onPressed: () {
              CusNav.nPush(context, ShoppingCartView());
            },
            icon: cartTotal == 0
                ? SvgPicture.asset(Assets.svgsIcCart, width: 24)
                : Badge(
                    isLabelVisible: true,
                    label: Text('$cartTotal'),
                    offset: const Offset(8, -4),
                    backgroundColor: const Color(0xFFE50012),
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
                  child: ImageCarousel(
                    imageUrls: [data?.foto ?? ''],
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
                              'Rp ${Utils.formatCurrency(num.parse(data?.harga ?? '0'))}',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFFE50012),
                              ),
                            ),
                          ),
                          StatefulBuilder(
                            builder: (BuildContext context, StateSetter setState) {
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    isFav = !isFav;
                                    context
                                        .read<WishlistProvider>()
                                        .addProductWishlist(productId: widget.id);
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: isFav ? Colors.red.shade50 : Colors.grey.shade100,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                    color: isFav ? const Color(0xFFE50012) : Colors.grey,
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
                        data?.nama ?? '',
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
                                  'Stok: ${data?.qty ?? 0}',
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
                                  'Terjual: ${data?.terjual ?? 0}',
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
                        child: const Icon(Icons.storefront_rounded, color: Color(0xFFE50012)),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data?.SellerNama ?? 'Nama Toko',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF111827),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.location_on_rounded, size: 14, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text(
                                  data?.kota ?? 'Lokasi',
                                  style: const TextStyle(
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
                            buildProductDetailRow('Kode Produk', data?.kodeProduk ?? '-'),
                            const Divider(height: 16, color: Color(0xFFEEEEEE)),
                            buildProductDetailRow('Kategori', data?.NamaKategori ?? '-', textColor: const Color(0xFFE50012)),
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
                        data?.deskripsi ?? '',
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
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Baca Selengkapnya',
                              style: TextStyle(color: Color(0xFFE50012), fontWeight: FontWeight.w600, fontSize: 13),
                            ),
                            Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFFE50012), size: 18),
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
