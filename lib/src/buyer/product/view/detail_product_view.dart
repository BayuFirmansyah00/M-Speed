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
        {Color textColor = Colors.black}) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          children: [
            SizedBox(
              width: 100,
              child: Text(
                '$label:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            SizedBox(width: 8),
            Text(
              value,
              style: TextStyle(color: textColor),
            ),
          ],
        ),
      );
    }

    Widget buildBottomBar() {
      return Container(
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 5,
              blurRadius: 7,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: 48,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  CusNav.nPush(
                      context,
                      ChatPersonView(
                          id: data?.SellerID ?? '',
                          sellerName: data?.SellerNama ?? ''));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.red, width: 2),
                  ),
                  padding: EdgeInsets.zero,
                ),
                child: Center(
                  child: Icon(
                    Icons.chat_bubble_outline,
                    color: Colors.red,
                    size: 24, // Adjust icon size as needed
                  ),
                ),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: SizedBox(
                height: 48, // Same height as chat button
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await context
                        .read<ShoppingCartProvider>()
                        .addToCart(context, produkId: data?.ID ?? '0', qty: 1);

                    CusNav.nPushReplace(context, ShoppingCartView());
                  },
                  icon: Icon(Icons.add, color: Colors.white),
                  label:
                      Text('Keranjang', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
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
      backgroundColor: Colors.white,
      appBar: CustomAppBar.appBar(
        context,
        "Detail Product",
        isCenter: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        color: Colors.white,
        action: [
          IconButton(
              onPressed: () {
                Share.share(data?.foto ?? '', subject: data?.nama ?? '');
              },
              icon: SvgPicture.asset(
                Assets.svgsIcShareApp,
                width: 24,
              )),
          IconButton(
            onPressed: () {
              CusNav.nPush(context, ShoppingCartView());
            },
            icon: cartTotal == 0
                ? SizedBox()
                : Badge(
                    isLabelVisible: true,
                    label: Text('$cartTotal'),
                    offset: Offset(8, -4),
                    backgroundColor: Colors.redAccent,
                    child: SvgPicture.asset(Assets.svgsIcCart, width: 24),
                  ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                ImageCarousel(
                  imageUrls: [
                    data?.foto ?? '',
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Rp ${Utils.formatCurrency(num.parse(data?.harga ?? '0'))}',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              StatefulBuilder(
                                builder: (BuildContext context,
                                    StateSetter setState) {
                                  return IconButton(
                                    onPressed: () {
                                      setState(() {
                                        isFav = !isFav;
                                        final productId =
                                            widget.id; // TODO: CHANGE PRODUCT ID // TODO: CHANGE USER ID

                                        context
                                            .read<WishlistProvider>()
                                            .addProductWishlist(
                                                productId: productId.toString(),
                                                );
                                      });
                                    },
                                    icon: Icon(isFav
                                        ? Icons.favorite
                                        : Icons.favorite_border),
                                    color:
                                        isFav ? Colors.red : Color(0xFF6D7588),
                                  );
                                },
                              )
                            ],
                          ),
                          Text(
                            data?.nama ?? '',
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w400),
                          ),
                          SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Terjual: ${data?.terjual ?? 0}',
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w400),
                              ),
                              Text(
                                'Stok: ${data?.qty ?? 0}',
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w400),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Container(
                      height: 8,
                      color: Color(0xFFF6F6F6),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Detail Produk',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          buildProductDetailRow(
                              'Kode', data?.kodeProduk ?? '-'),
                          Divider(
                            color: Color(0xFFEEF0F8),
                          ),
                          buildProductDetailRow(
                              'Kategori', data?.NamaKategori ?? '-',
                              textColor: Colors.red),
                          Divider(
                            color: Color(0xFFEEF0F8),
                          ),
                          buildProductDetailRow('Lokasi', data?.kota ?? '-'),
                          Divider(
                            color: Color(0xFFEEF0F8),
                          ),
                          Text(
                            'Deskripsi Produk',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(
                            height: 12,
                          ),
                          Text(
                            data?.deskripsi ?? '',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF6D7588)),
                          ),
                          InkWell(
                              onTap: () {},
                              child: Text(
                                'Baca Selengkapnya',
                                style: TextStyle(color: Colors.red),
                              )),
                          SizedBox(height: 16)
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          buildBottomBar(),
        ],
      ),
    );
  }
}
