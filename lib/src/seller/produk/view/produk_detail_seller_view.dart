import 'package:flutter/material.dart';
import 'package:mspeed/common/base/base_state.dart';
import 'package:mspeed/common/component/custom_appbar.dart';
import 'package:mspeed/common/component/custom_navigator.dart';
import 'package:mspeed/common/component/image_carousel.dart';
import 'package:mspeed/common/helper/constant.dart';
import 'package:mspeed/generated/assets.dart';
import 'package:mspeed/src/seller/produk/provider/produk_seller_provider.dart';
import 'package:mspeed/utils/utils.dart';
import 'package:provider/provider.dart';

class ProdukDetailSellerView extends StatefulWidget {
  ProdukDetailSellerView({super.key, required this.productId});
  final String productId;

  @override
  State<ProdukDetailSellerView> createState() => _ProdukDetailSellerViewState();
}

class _ProdukDetailSellerViewState extends BaseState<ProdukDetailSellerView> {
  @override
  void initState() {
    context
        .read<ProdukSellerProvider>()
        .fetchDetailProduct(productId: widget.productId);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ProdukSellerProvider>();
    final data =
        context.watch<ProdukSellerProvider>().productDetailSellerModel.data;
    final detailData = p.productDetailSellerModel.data?.produk;
    PreferredSizeWidget appBar() {
      return CustomAppBar.appBar(context, 'View Produk',
          color: Colors.white,
          isCenter: true,
          textStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          action: [
            InkWell(
              onTap: () async {
                await Utils.showYesNoDialog(
                  context: context,
                  title: 'Konfirmasi Hapus Produk',
                  desc: 'Apakah Anda yakin ingin hapus produk ini?',
                yesCallback: () async {
                    CusNav.nPop(context);
                  },
                  noCallback: () {
                    CusNav.nPop(context);
                  },
                );
              },
              child: Container(
                  padding: EdgeInsets.only(right: 16),
                  width: 40,
                  height: 40,
                  child: Image.asset(Assets.iconsIcDeleteOutlined)),
            )
          ]);
    }

    Widget productInfo() {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Constant.xSizedBox4,
                  Text(
                    detailData?.nama ?? '',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Constant.xSizedBox4,
                  Text(
                    Utils.thousandSeparator(
                        int.parse(detailData?.harga ?? '0')),
                    style: TextStyle(
                      color: Color(0xffED1C24),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            Constant.xSizedBox8,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Constant.xSizedBox8,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Image.asset(
                        Assets.iconsIcKode,
                        width: 16,
                        height: 16,
                      ),
                      Constant.xSizedBox4,
                      Text(
                        detailData?.kodeProduk ?? '',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xff6D7588),
                        ),
                      ),
                    ],
                  ),
                  Constant.xSizedBox8,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Image.asset(
                        Assets.iconsIcStok,
                        width: 16,
                        height: 16,
                      ),
                      Constant.xSizedBox4,
                      Text(
                        'Stok ${detailData?.qty ?? '0'}',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xff6D7588),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    String deskripsi = detailData?.deskripsi ?? '-';

    Widget kategoriDeskripsi() {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Kategori',
              style: TextStyle(color: Color(0xff6D7588)),
            ),
            Constant.xSizedBox4,
            Text('Consumable', style: TextStyle(color: Color(0xff100629))),
            Constant.xSizedBox16,
            Text(
              'Deskripsi',
              style: TextStyle(color: Color(0xff6D7588)),
            ),
            Constant.xSizedBox4,
            Text(detailData?.deskripsi ?? '',
                style: TextStyle(color: Color(0xff100629))),
            Constant.xSizedBox16,
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: appBar(),
      body: SafeArea(
        child: Container(
          color: Color(0xffF6F6F6),
          child: ListView(
            children: [
              ImageCarousel(
                // imageUrls: List.generate(data?.fotoProduk?.length ?? 0, (i) {
                //   final item = data?.fotoProduk?[i];
                //   return item?.foto ?? '';
                // }),
                imageUrls: [detailData?.foto ?? ''],
                isMiniPreview: true,
              ),
              Constant.xSizedBox16,
              productInfo(),
              Constant.xSizedBox16,
              kategoriDeskripsi(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Color(0xffF6F6F6),
        splashColor: Color(0xffF6F6F6),
        foregroundColor: Constant.greenColor,
        onPressed: () async {},
        label: Text(
          "Ubah Produk",
          style: TextStyle(color: Constant.greenColor),
        ),
        icon: SizedBox(
          width: 25,
          height: 25,
          child: Image.asset(Assets.iconsIcEditProduk),
        ),
      ),
    );
  }
}
