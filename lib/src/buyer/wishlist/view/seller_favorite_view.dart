import 'dart:async';

import 'package:dynamic_height_grid_view/dynamic_height_grid_view.dart';
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

  @override
  Widget build(BuildContext context) {
    final p = context.watch<WishlistProvider>();
    if (sellerFav.isEmpty && searchController.text.isEmpty) {
      sellerFav = p.sellerFavorite.data ?? [];
    }

    void _showBottomSheet(BuildContext context) {
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
                    Assets.svgsIcSheetShare,
                    width: 24,
                  ),
                  title: Text(
                    'Bagikan Link Seller',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w600),
                  ),
                  onTap: () {
                    // Handle action
                  },
                ),
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
                    // Handle action
                  },
                ),
              ],
            ),
          );
        },
      );
    }

    Widget _buildSellerList(BuildContext context, int index) {
      final item = sellerFav[index];
      return Container(
        height: 130,
        child: InkWell(
          onTap: () {
            CusNav.nPush(context,
                SellerHomeProductView(id: item?.SellerID ?? "0", isFav: true));
          },
          child: Card(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SafeNetworkImage(
                        width: 48,
                        height: 48,
                        url: item?.foto ?? '',
                        borderRadius: 40,
                        errorBuilder:
                            Image.asset(Assets.imagesMainImageNotFound),
                      ),
                      // ImageNetworkWidget(
                      //   imageUrl: item?.foto.toString() ?? '',
                      //   width: 48,
                      //   radius: 36,
                      // ),
                      SizedBox(
                        width: 8,
                      ),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item?.SellerName.toString() ?? '',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14)),
                            Row(
                              children: [
                                Image.asset(Assets.iconsIcStoreSeller,
                                    width: 10, height: 10),
                                SizedBox(width: 4),
                                Text(item?.alamat.toString() ?? '',
                                    style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w400)),
                              ],
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                  IconButton(
                    onPressed: () {
                      _showBottomSheet(context);
                    },
                    icon: Icon(Icons.more_horiz, color: Colors.grey),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white,
                      minimumSize: Size(28, 28),
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: Colors.grey),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: () async {
          context
              .read<WishlistProvider>()
              .fetchSellerWishlist(withLoading: true);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
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
                  onChanged: (value) {
                    setState(() {
                      sellerFav = p.sellerFavorite.data
                              ?.where((element) =>
                                  element?.SellerName?.toLowerCase().contains(
                                      searchController.text.toLowerCase()) ??
                                  false)
                              .toList() ??
                          [];
                    });
                    // if (value.length >= 3) {
                    //   if (p.searchOnStoppedTyping != null) {
                    //     p.searchOnStoppedTyping!.cancel();
                    //   }
                    //   p.searchOnStoppedTyping = Timer(p.duration, () {
                    //     initData();
                    //   });
                    // }
                  },
                  // onSubmitted: (_) {
                  //   context
                  //       .read<WishlistProvider>()
                  //       .fetchSellerWishlist(withLoading: true);
                  // },
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: 'Cari disini',
                    hintStyle: TextStyle(color: Colors.grey),
                    border: InputBorder.none,
                    prefixIcon: Icon(Icons.search, color: Colors.grey),
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0),
                    isDense: true,
                  ),
                ),
              ),
              SizedBox(
                height: 8,
              ),
              Expanded(
                child: DynamicHeightGridView(
                  itemCount: sellerFav.length,
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  builder: (ctx, index) {
                    return _buildSellerList(context, index);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
