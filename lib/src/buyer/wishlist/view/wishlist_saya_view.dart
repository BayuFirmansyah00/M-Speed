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

  @override
  Widget build(BuildContext context) {
    final p = context.watch<WishlistProvider>();
    if (wishlists.isEmpty && searchController.text.isEmpty) {
      wishlists = p.wishlistModel.data ?? [];
    }

    log("WISHLISTS : $wishlists");
    void _showBottomSheet(
      BuildContext context,
      BuyerWishlistModelDataDetail data,
    ) {
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
        ),
        builder: (BuildContext context) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    icon: Icon(
                      Icons.close,
                      color: Colors.black,
                      size: 24,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
                ListTile(
                  leading: SvgPicture.asset(
                    Assets.svgsIcSheetLihatSeller,
                    width: 24,
                  ),
                  title: Text(
                    'Lihat Seller',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w600),
                  ),
                  onTap: () {
                    // Handle action
                    CusNav.nPush(context,
                        SellerHomeProductView(id: data.SellerID ?? "0"));
                  },
                ),
                // ListTile(
                //   leading: SvgPicture.asset(
                //     Assets.svgsIcSheetShare,
                //     width: 24,
                //   ),
                //   title: Text(
                //     'Bagikan Link Barang',
                //     style: TextStyle(
                //         color: Colors.black,
                //         fontSize: 16,
                //         fontWeight: FontWeight.w600),
                //   ),
                //   onTap: () {
                //     // Handle action
                //   },
                // ),
                ListTile(
                  leading: SvgPicture.asset(
                    Assets.svgsIcSheetBuang,
                    width: 24,
                  ),
                  title: Text(
                    'Hapus',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w600),
                  ),
                  onTap: () {
                    context
                        .read<WishlistProvider>()
                        .deleteWishlist(idProduk: data.ID.toString());
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          );
        },
      );
    }

    Widget _buildProductItem(BuyerWishlistModelDataDetail? e) {
      return Expanded(
        child: Card(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () async {
                    await CusNav.nPush(
                        context, DetailProductView(id: e?.ID ?? ''));
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: CachedNetworkImage(
                            imageUrl: e?.foto ?? '',
                            fit: BoxFit.cover,
                            placeholder: (context, url) => AspectRatio(
                              aspectRatio: 1,
                              child: Container(
                                width: double.infinity,
                                // height: 200.0,
                                color: Colors.grey[200],
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => AspectRatio(
                              aspectRatio: 1,
                              child: Container(
                                width: double.infinity,
                                // height: 200.0,
                                color: Colors.grey[200],
                                child: Center(
                                  child: Icon(
                                    Icons.error,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(e?.nama ?? "-",
                          style: TextStyle(
                              fontWeight: FontWeight.w400, fontSize: 12)),
                      Text(Utils.thousandSeparator(int.parse(e?.harga ?? "0")),
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w700,
                              fontSize: 16)),
                      Row(
                        children: [
                          Image.asset(Assets.iconsIcStoreSeller,
                              width: 14, height: 14),
                          SizedBox(width: 4),
                          Text(e?.SellerID ?? '-',
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400)),
                        ],
                      ),
                      Text('Stok ${e?.qty} • ${e?.IDKategori}',
                          style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                              fontWeight: FontWeight.w400)),
                      SizedBox(
                        height: 12,
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        _showBottomSheet(context, e!);
                      },
                      icon: Icon(Icons.more_horiz, color: Colors.grey),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white,
                        minimumSize: Size(32, 32),
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(color: Colors.grey),
                        ),
                      ),
                    ),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // Add your button action here
                          context
                              .read<WishlistProvider>()
                              .addToCart(
                                context,
                                produkId: e?.ID ?? "0",
                              )
                              .then((value) {
                            Utils.showSuccess(
                                msg: "Produk berhasil ditambahkan ke cart");
                          });
                        },
                        icon: Icon(Icons.add, color: Colors.red, size: 14),
                        label: Text(
                          "Keranjang",
                          style: TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                              fontWeight: FontWeight.w400),
                        ),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.red,
                          backgroundColor: Colors.white,
                          minimumSize: Size(double.infinity, 32),
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          elevation: 0,
                          side: BorderSide(color: Colors.red),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      );
    }

    final scrollPhysics = ScrollPhysics();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: RefreshIndicator(
          onRefresh: () async {
            context.read<WishlistProvider>().fetchWishlist(withLoading: true);
          },
          child: SingleChildScrollView(
            physics: scrollPhysics,
            child: Column(
              children: [
                SizedBox(
                  height: 8,
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextField(
                    controller: searchController,
                    // onChanged: (String value) {
                    //   setState(() {
                    //     wishlists = context
                    //         .read<WishlistProvider>()
                    //         .wishlistModel
                    //         .data?.where((e) {
                    //       return e!.nama?.contains(value) ?? false;
                    //     }).toList() ??
                    //         [];
                    //   });
                    // },
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
                      hintText: 'Cari disini',
                      hintStyle: TextStyle(color: Colors.grey),
                      border: InputBorder.none,
                      prefixIcon: Icon(Icons.search, color: Colors.grey),
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 12.0),
                      isDense: true,
                    ),
                  ),
                ),
                SizedBox(
                  height: 8,
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                  child: ListView.builder(
                    primary: false,
                    shrinkWrap: true,
                    itemBuilder: (context, i) {
                      return Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                  child: Text(wishlists[i]?.namaseller ?? "-")),
                              SizedBox(width: 8),
                              Expanded(
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 0, vertical: 10),
                                  child: ElevatedButton(
                                      onPressed: () {
                                        context
                                            .read<WishlistProvider>()
                                            .addAllToCart(
                                                sellerId:
                                                    wishlists[i]?.SellerID ??
                                                        '');
                                      },
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.add,
                                            color: Colors.white,
                                            size: 12,
                                          ),
                                          SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              'Keranjang Semua',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12),
                                            ),
                                          ),
                                        ],
                                      )),
                                ),
                              )
                            ],
                          ),
                          DynamicHeightGridView(
                              builder: (context, index) {
                                return _buildProductItem(
                                    wishlists[i]?.detail?[index]);
                              },
                              shrinkWrap: true,
                              physics: scrollPhysics,
                              itemCount: wishlists[i]?.detail?.length ?? 0,
                              crossAxisCount: 2),
                        ],
                      );
                    },
                    itemCount: wishlists.length,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
