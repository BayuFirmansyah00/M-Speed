import 'package:flutter/material.dart';
import 'package:mspeed/common/base/base_state.dart';
import 'package:mspeed/common/helper/Constant.dart';
import 'package:mspeed/src/buyer/wishlist/view/seller_favorite_view.dart';
import 'package:mspeed/src/buyer/wishlist/view/wishlist_saya_view.dart';

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
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          bottom: TabBar(
            indicatorSize: TabBarIndicatorSize.tab,
            tabs: [
              Tab(
                child: Text("Wishlist"),
              ),
              Tab(
                child: Text("Seller Favorit"),
              ),
            ],
          ),
          centerTitle: true,
          title: Text(
            'Semua Wishlist',
            style: TextStyle(
              fontWeight: Constant.semibold,
              color: Colors.black,
              fontSize: 17,
            ),
          ),
        ),
        body: TabBarView(
          children: [WishlistSayaView(), SellerFavoriteView()],
        ),
      ),
    );
  }
}
