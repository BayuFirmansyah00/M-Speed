import 'package:dynamic_height_grid_view/dynamic_height_grid_view.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mspeed/common/component/custom_navigator.dart';
import 'package:mspeed/common/component/image_network_widget.dart';
import 'package:mspeed/common/helper/constant.dart';
import 'package:mspeed/common/helper/safe_network_image.dart';
import 'package:mspeed/src/buyer/chat/view/chat_person_view.dart';
import 'package:mspeed/src/buyer/home/provider/home_provider.dart';
import 'package:mspeed/src/buyer/home/view/sort_bottom_sheet.dart';
import 'package:mspeed/src/buyer/product/view/detail_product_view.dart';
import 'package:mspeed/src/buyer/seller/provider/seller_provider.dart';
import 'package:mspeed/src/buyer/seller/view/seller_home_info_view.dart';
import 'package:mspeed/src/buyer/transaction/view/detail_transaction_view.dart';
import 'package:mspeed/src/buyer/wishlist/provider/wishlist_provider.dart';
import 'package:mspeed/utils/utils.dart';
import 'package:provider/provider.dart';

import '../../../../generated/assets.dart';
import '../../../admin/home/view/product_or_seller_search_view.dart';

class SellerHomeProductView extends StatefulWidget {
  final String id;
  final bool isFav;

  SellerHomeProductView({Key? key, required this.id, this.isFav = false})
      : super(key: key);

  @override
  State<SellerHomeProductView> createState() => _SellerHomeProductViewState();
}

class _SellerHomeProductViewState extends State<SellerHomeProductView> {
  bool isFav = false;

  @override
  void initState() {
    isFav = widget.isFav;
    getData();
    super.initState();
  }

  Future<void> getData() async {
    await context
        .read<WishlistProvider>()
        .fetchDetailSeller(sellerId: widget.id);
    // final p = context.read<WishlistProvider>();
    // await p.fetchSellerWishlist();
    // await p.fetchTransaction(seller_id: widget.id);
  }

  final icons = [
    Assets.iconsIcConsumable,
    Assets.iconsIcApd,
    Assets.assetsIconsIcTools,
    Assets.iconsIcStationery,
    Assets.assetsIconsIcServices,
    Assets.iconsIcOther
  ];

  @override
  Widget build(BuildContext context) {
    final data = context.watch<WishlistProvider>().detailSellerBuyer.data;
    // final categories = context.watch<WishlistProvider>().detailSellerBuyer.data ?? [];

    Widget _buildProductItem(int index) {
      final prodP = data?.dataProduk?[index];
      return InkWell(
        onTap: () {
          CusNav.nPush(context, DetailProductView(id: prodP?.ID ?? ""));
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ImageNetworkWidget(
            //   imageUrl: prodP?.foto.toString() ?? '',
            //   radius: 12,
            // ),
            SafeNetworkImage(
              width: double.infinity,
              height: 100,
              url: prodP?.foto ?? '',
              borderRadius: 10,
              errorBuilder: Image.asset(Assets.imagesMainImageNotFound),
            ),
            SizedBox(height: 8),
            Text('${prodP?.nama ?? '-'}',
                style: TextStyle(fontWeight: FontWeight.w400, fontSize: 12)),
            Text('Rp ${Utils.formatCurrency(num.parse(prodP?.harga ?? '0'))}',
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w700,
                    fontSize: 16)),
            Row(
              children: [
                Image.asset(Assets.iconsIcStoreSeller, width: 14, height: 14),
                SizedBox(width: 4),
                Text('${data?.getSeller?.nama ?? '-'}',
                    style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                        fontWeight: FontWeight.w400)),
              ],
            ),
            Text('Stok ${prodP?.qty} • ${prodP?.IDKategori}',
                style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                    fontWeight: FontWeight.w400)),
            SizedBox(height: 16),
          ],
        ),
      );
    }

    void _showSortBottomSheet(BuildContext context) {
      showModalBottomSheet(
        backgroundColor: Colors.white,
        context: context,
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(16), // Adjust this value as needed
          ),
        ),
        builder: (BuildContext context) {
          return SortBottomSheet();
        },
      );
    }

    Widget buildSellerfInfo() {
      final sellerP = data?.getSeller;
      return Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                ImageNetworkWidget(
                  imageUrl: sellerP?.foto ?? '',
                  width: 50,
                  radius: 30,
                ),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SellerHomeInfoView(
                                  id: data?.getSeller?.ID ?? "")),
                        );
                      },
                      child: Row(
                        children: [
                          Text(
                            data?.getSeller?.nama ?? "",
                            style: TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 14),
                          ),
                          SizedBox(width: 4),
                          Icon(
                            Icons.navigate_next,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 12,
                          color: Colors.grey,
                        ),
                        Text(data?.getSeller?.alamat ?? '',
                            style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                                fontWeight: FontWeight.w400)),
                      ],
                    ),
                  ],
                ),
                Spacer(),
                Column(
                  children: [
                    Container(
                      width: 45,
                      // Memberikan lebar tetap
                      height: 45,
                      // Memberikan tinggi tetap yang sama agar berbentuk lingkaran
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Color(0xFFF58B2B), width: 2),
                        shape: BoxShape
                            .circle, // Mengatur bentuk menjadi lingkaran
                      ),
                      alignment: Alignment.center,
                      // Menjaga teks di tengah
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      child: Text(
                        data?.dataProduk?.length.toString() ?? '0',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 4,
                    ),
                    Text(
                      "Total Produk",
                      style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                          fontWeight: FontWeight.w400),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      CusNav.nPush(
                          context,
                          ChatPersonView(
                            sellerName: data?.getSeller?.nama ?? "-",
                            id: widget.id,
                          ));
                    },
                    child: Text(
                      "Pesan",
                      style: TextStyle(
                          color: Color(0xFFED1C24),
                          fontSize: 14,
                          fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                        foregroundColor: Color(0xFFED1C24),
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(color: Color(0xFFED1C24))),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      if (isFav) {
                        await context
                            .read<WishlistProvider>()
                            .removeSellerWishlist(sellerId: widget.id);
                      } else {
                        await context
                            .read<WishlistProvider>()
                            .addSellerWishlist(sellerId: widget.id);
                      }
                      setState(() {
                        isFav = !isFav;
                      });
                    },
                    child: Text(
                      isFav ? "Unfollow" : "Favoritkan",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFED1C24),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 8,
            margin: EdgeInsets.only(top: 12),
            color: Color(0xFFF6F6F6),
          ),
        ],
      );
    }

    final scroll = ScrollPhysics();
    Widget buildProductPage() {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: ListView(
          physics: scroll,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Semua Produk",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  IconButton(
                    icon: Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                        decoration: BoxDecoration(
                          color: Color(0xFFEEF0F8),
                          borderRadius: BorderRadius.circular(36),
                        ),
                        child: Row(
                          children: [
                            Text(
                              "Urutkan",
                              style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w400),
                            ),
                            SizedBox(
                              width: 4,
                            ),
                            SvgPicture.asset(
                              Assets.svgsIcSearchTampilan,
                              height: 16,
                            ),
                          ],
                        )),
                    onPressed: () {
                      _showSortBottomSheet(context);
                    },
                  ),
                ],
              ),
            ),
            DynamicHeightGridView(
              itemCount: data?.dataProduk?.length ?? 0,
              //data?.dataProduk?.length ?? 0,
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              physics: scroll,
              shrinkWrap: true,
              mainAxisSpacing: 10,
              builder: (ctx, index) {
                return _buildProductItem(index);
              },
            ),
          ],
        ),
      );
    }

    Widget buildKategoriPage() {
      return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: SingleChildScrollView(
            child: Column(
              children: List.generate(data?.dataKategori?.length ?? 0, (index) {
                return InkWell(
                  onTap: () async {
                    if (index != (data?.dataKategori?.length ?? 0) - 1) {
                      final kategori = context.read<HomeProvider>().kategoriMap;
                      final namaKategori =
                          data?.dataKategori?[index]?.nama ?? '';
                      if (kategori.isNotEmpty &&
                          kategori.containsKey(namaKategori))
                        kategori[data?.dataKategori?[index]?.nama ?? ''] = true;
                      await CusNav.nPush(context, ProductOrSellerSearchView());
                    }
                  },
                  child: Column(
                    children: [
                      SizedBox(
                        height: 12,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Color(0xFFDBDFE9)),
                              ),
                              child: Image.asset(
                                icons[index],
                                width: 36,
                                height: 36,
                              ),
                            ),
                            SizedBox(width: 16),
                            Text(data?.dataKategori?[index]?.nama ?? '',
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w400)),
                          ],
                        ),
                      ),
                      Divider(
                        color: Colors.grey[50],
                      )
                    ],
                  ),
                );
              }),
            ),
          ));
    }

    Widget buildRiwayatPage() {
      return Container(
          child: ListView.builder(
              itemCount: data?.dataRiwayat?.length,
              itemBuilder: (context, index) {
                final riwayat = data?.dataRiwayat?[index];
                return Container(
                  padding: EdgeInsets?.all(10),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Image.asset(Assets.iconsIcStore),
                              SizedBox(width: 10,),
                              Text(riwayat?.SellerNama ?? ""),
                            ],
                          ),
                          Text(
                            riwayat?.nomorOrder ?? "",
                            style: TextStyle(
                              fontWeight: FontWeight.w300,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      Constant.xSizedBox16,
                      ...List.generate(riwayat?.detail?.length ?? 0, (indexx) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: SafeNetworkImage(
                                    url: riwayat?.detail?[indexx]?.foto ?? "",
                                    width: 60,
                                    height: 60,
                                    borderRadius: 10,
                                    errorBuilder: Image.asset(
                                        "assets/images/main-image-not-found.png"),
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                  flex: 8,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Text(riwayat?.detail?[indexx]?.nama ??
                                                "", overflow: TextOverflow.ellipsis, maxLines: 1,),
                                            SizedBox(
                                              height: 5,
                                            ),
                                            Text(
                                              riwayat?.Created != "0000-00-00"
                                                  ? DateFormat('d MMMM yyy')
                                                      .format(
                                                      DateTime.parse(
                                                          riwayat?.Created ??
                                                              "0000-00-00"),
                                                    )
                                                  : '',
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w300),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Text(
                                            "x${riwayat?.detail?[indexx]?.qty}" ??
                                                "",
                                            style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w400),
                                          ),
                                          SizedBox(
                                            height: 5,
                                          ),
                                          Text(
                                            Utils.thousandSeparator(int.parse(riwayat?.detail?[indexx]?.harga ?? "")),
                                            style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10,),
                          ],
                        );
                      }),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(("${riwayat?.jum} Produk") ?? "", style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w300,
                          ),),
                          Row(
                            children: [
                              Text(("Total Pesanan: "), style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),),
                              Text(Utils.thousandSeparator(int.parse(riwayat?.total ?? "0")), style: TextStyle(
                                fontSize: 12,
                                color: Colors.red,
                                fontWeight: FontWeight.w600,
                              ),),
                            ],
                          ),

                        ],
                      ),
                    ],
                  ),
                );
              }));
    }

    final transactions =
        context.watch<SellerProvider>().daftarTransaksi.data ?? [];
    // final transaksi = context.watch<WishlistProvider>().detailSellerBuyer.data?.dataRiwayat ?? [];
    Widget buildRiwayatPage1() {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Semua Produk",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  IconButton(
                    icon: Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                        decoration: BoxDecoration(
                          color: Color(0xFFEEF0F8),
                          borderRadius: BorderRadius.circular(36),
                        ),
                        child: Row(
                          children: [
                            Text(
                              "Urutkan",
                              style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w400),
                            ),
                            SizedBox(
                              width: 4,
                            ),
                            SvgPicture.asset(
                              Assets.svgsIcSearchTampilan,
                              height: 16,
                            ),
                          ],
                        )),
                    onPressed: () {
                      // _showSortBottomSheet(context);
                    },
                  ),
                ],
              ),
            ),
            ListView.builder(
              // shrinkWrap: true,
              // primary: false,
              itemCount: data?.dataRiwayat?.length,
              itemBuilder: (context, index) {
                return InkWell(
                    onTap: () {
                      CusNav.nPush(
                          context,
                          DetailTransactionView(
                            transaction_id: data?.dataRiwayat?[index]?.ID ?? '',
                            seller_id:
                                data?.dataRiwayat?[index]?.SellerID ?? '',
                          ));
                    },
                    child: Container(
                      child: Text("text"),
                    ));
              },
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        forceMaterialTransparency: true,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: TextField(
          decoration: InputDecoration(
            contentPadding:
                EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
            // Adjust the padding
            isDense: true,
            hintText: "Cari Produk",
            hintStyle: TextStyle(
                color: Color(
                  0xFF6D7588,
                ),
                fontSize: 14,
                fontWeight: FontWeight.w400),
            filled: true,
            fillColor: Colors.white,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Color(0xFFEEF0F8),
                width: 1.0,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Color(0xFFEEF0F8),
                width: 1.0,
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          buildSellerfInfo(),
          Expanded(
            child: DefaultTabController(
              length: 3,
              child: Column(
                children: [
                  TabBar(indicatorSize: TabBarIndicatorSize.tab, tabs: [
                    Tab(
                      text: 'Produk',
                    ),
                    Tab(
                      text: 'Kategori',
                    ),
                    Tab(
                      text: 'Riwayat Transaksi',
                    )
                  ]),
                  Expanded(
                    child: TabBarView(
                      children: [
                        buildProductPage(),
                        buildKategoriPage(),
                        buildRiwayatPage(),
                      ],
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
