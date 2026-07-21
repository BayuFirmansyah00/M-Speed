import 'package:flutter/material.dart';
import 'package:mspeed/common/base/base_state.dart';
import 'package:mspeed/common/component/custom_appbar.dart';
import 'package:mspeed/common/component/custom_button.dart';
import 'package:mspeed/common/component/custom_navigator.dart';
import 'package:mspeed/common/component/custom_textfield.dart';
import 'package:mspeed/common/helper/constant.dart';
import 'package:mspeed/common/helper/safe_network_image.dart';
import 'package:mspeed/generated/assets.dart';
import 'package:mspeed/src/seller/produk/model/produk_list_seller_model.dart';
import 'package:mspeed/src/seller/produk/provider/produk_seller_provider.dart';
import 'package:mspeed/src/seller/produk/view/produk_add_seller_view.dart';
import 'package:mspeed/src/seller/produk/view/produk_detail_seller_view.dart';
import 'package:mspeed/utils/utils.dart';
import 'package:provider/provider.dart';

class ProdukSellerView extends StatefulWidget {
  const ProdukSellerView({super.key});

  @override
  State<ProdukSellerView> createState() => _ProdukSellerViewState();
}

class _ProdukSellerViewState extends BaseState<ProdukSellerView> {
  late ScrollController scrollC;
  @override
  void initState() {
    scrollC =
        ScrollController()..addListener(() {
          setState(() {});
        });
    refresh();
    super.initState();
  }

  List<ProdukListSellerModelData?> listProdukModel = [];
  final searchController = TextEditingController();

  Future<void> refresh() async {
    final p = context.read<ProdukSellerProvider>();
    await p.fetchProductListSeller(withLoading: true);
    listProdukModel = p.produkSellerListModel.data ?? [];
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ProdukSellerProvider>();
    if (listProdukModel.isEmpty && searchController.text.isEmpty) {
      listProdukModel = p.produkSellerListModel.data ?? [];
    }

    Widget search() => Container(
      color: Colors.white,
      padding: EdgeInsets.only(top: 8, bottom: 16, left: 20, right: 20),
      child: CustomTextField.borderTextField(
        controller: searchController,
        required: false,
        hintText: "Cari",
        hintColor: Color(0xff6D7588),
        borderColor: Color(0xffDBDFE9),
        prefix: Padding(
          padding: const EdgeInsets.all(12),
          child: Image.asset(
            'assets/icons/ic-search.png',
            width: 5,
            height: 5,
            color: Color(0xff6D7588),
          ),
        ),
        onChanged: (val) {
          setState(() {
            listProdukModel =
                p.produkSellerListModel.data
                    ?.where(
                      (element) =>
                          element?.nama?.toLowerCase().contains(
                            searchController.text.toLowerCase(),
                          ) ??
                          false,
                    )
                    .toList() ??
                [];
          });
        },
      ),
    );
    PreferredSizeWidget appBar() {
      return CustomAppBar.appBar(
        context,
        'Produk',
        color: Colors.white,
        isCenter: true,
        titleSpacing: 24,
        textStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        isLeading: false,
        action: [
          InkWell(
            onTap: () async {
              final p = context.read<ProdukSellerProvider>();
              p.fotoProduk.clear();
              p.fotoProduk.add(null);
              p.namaC.clear();
              p.hargaC.clear();
              p.stokC.clear();
              p.selectedKategori = null;
              p.deskripsiC.clear();
              await CusNav.nPush(context, ProdukAddSellerView());
              refresh();
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: CircleAvatar(
                radius: 14,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xffED1C24),
                  ),
                  child: Icon(Icons.add, size: 27, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      );
    }

    Widget produkItem(ProdukListSellerModelData? data) {
      return InkWell(
        onTap: () async {
          await CusNav.nPush(
            context,
            ProdukDetailSellerView(productId: data?.ID ?? ''),
          );
        },
        child: Container(
          color: Colors.white,
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: SafeNetworkImage(
                        width: 70,
                        height: 70,
                        url: data?.foto ?? '',
                        errorBuilder: Image.asset(Assets.imagesImgPlaceholder),
                      ),
                    ),
                  ),
                  Constant.xSizedBox16,
                  Expanded(
                    flex: 6,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Constant.xSizedBox4,
                        Text(data?.nama ?? ''),
                        Constant.xSizedBox4,
                        Text(
                          Utils.thousandSeparator(
                            int.parse(data?.harga ?? '0'),
                          ),
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  Constant.xSizedBox8,
                  Expanded(
                    flex: 3,
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
                              data?.kodeProduk ?? '',
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
                              'Stok ${data?.qty ?? '0'}',
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
              Constant.xSizedBox12,
              Row(
                children: [
                  Expanded(
                    child: CustomButton.secondaryButton(
                      'Ubah Produk',
                      () async {
                        await CusNav.nPush(
                          context,
                          ProdukAddSellerView(
                            isEdit: true,
                            productId: data?.ID,
                          ),
                        );
                      },
                      contentPadding: EdgeInsets.symmetric(vertical: 8),
                      color: Color(0xff1ABC62),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  Constant.xSizedBox12,
                  Expanded(
                    child: CustomButton.secondaryButton(
                      'Hapus Produk',
                      () async {
                        await Utils.showYesNoDialog(
                          context: context,
                          title: 'Konfirmasi Hapus Produk',
                          desc: 'Apakah Anda yakin ingin hapus produk ini?',
                          yesCallback: () async {
                            CusNav.nPop(context);
                            await context
                                .read<ProdukSellerProvider>()
                                .hapusProduk(
                                  productId: data?.ID ?? '0',
                                  withLoading: true,
                                );
                            scrollC.jumpTo(0);
                            await context
                                .read<ProdukSellerProvider>()
                                .fetchProductListSeller(withLoading: true);
                          },
                          noCallback: () {
                            CusNav.nPop(context);
                          },
                        );
                      },
                      contentPadding: EdgeInsets.symmetric(vertical: 8),
                      color: Color(0xffED1C24),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: appBar(),
      body: SafeArea(
        child: Container(
          color: Color(0xffF6F6F6),
          child: Column(
            children: [
              search(),
              Constant.xSizedBox8,
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    refresh();
                  },
                  child: ListView.separated(
                    controller: scrollC,
                    itemCount: listProdukModel.length ?? 0,
                    itemBuilder: (c, i) {
                      final item = listProdukModel[i];
                      return produkItem(item);
                    },
                    separatorBuilder: (_, __) => Constant.xSizedBox8,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
