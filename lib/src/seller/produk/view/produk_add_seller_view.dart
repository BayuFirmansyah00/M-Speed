import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mspeed/common/component/custom_appbar.dart';
import 'package:mspeed/common/component/custom_button.dart';
import 'package:mspeed/common/component/custom_dropdown.dart';
import 'package:mspeed/common/component/custom_navigator.dart';
import 'package:mspeed/common/component/custom_textfield.dart';
import 'package:mspeed/common/helper/constant.dart';
import 'package:mspeed/common/helper/safe_network_image.dart';
import 'package:mspeed/common/helper/text_editing_formatter.dart';
import 'package:mspeed/generated/assets.dart';
import 'package:mspeed/src/seller/produk/model/produk_detail_seller_model.dart';
import 'package:mspeed/src/seller/produk/provider/produk_seller_provider.dart';
import 'package:mspeed/utils/utils.dart';
import 'package:provider/provider.dart';

class ProdukAddSellerView extends StatefulWidget {
  ProdukAddSellerView({super.key, this.isEdit = false, this.productId});
  bool isEdit;
  String? productId;
  @override
  State<ProdukAddSellerView> createState() => _ProdukAddSellerViewState();
}

class _ProdukAddSellerViewState extends State<ProdukAddSellerView> {
  @override
  void initState() {
    getData();
    super.initState();
  }

  getData() async {
    final p = context.read<ProdukSellerProvider>();
    await p.fetchKategori(withLoading: true);
    if (widget.isEdit && widget.productId != null)
      await p.initEditProduk(widget.productId ?? '0');
    // if (!widget.isEdit) {
    //   p.fotoProduk.clear();
    //   p.fotoProduk.add(null);
    //   p.namaC.clear();
    //   p.hargaC.clear();
    //   p.stokC.clear();
    //   p.selectedKategori = null;
    //   p.deskripsiC.clear();
    // }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ProdukSellerProvider>();
    PreferredSizeWidget appBar() {
      return CustomAppBar.appBar(
        context,
        '${widget.isEdit ? 'Edit' : 'Create'} Produk',
        color: Colors.white,
        isCenter: true,
        textStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
      );
    }

    List<Widget> fotoItem() {
      final fotoLength = p.fotoProduk.length;
      return List.generate(fotoLength, (index) {
        final item = p.fotoProduk[index];
        String? itemUrl;
        // log("FOTO PRODUK URL : ${p.fotoProdukUrl[index]}");
        if (p.fotoProdukUrl.isNotEmpty &&
            index < p.fotoProdukUrl.length &&
            p.fotoProdukUrl[index] != null) {
          itemUrl = p.fotoProdukUrl[index];
        }
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              if (item != null) ...[
                InkWell(
                  onTap: () async {
                    setState(() {
                      context.read<ProdukSellerProvider>().pickProductImage(
                        index,
                      );
                    });
                  },
                  child: SizedBox(
                    width: 70,
                    height: 70,
                    child: Image.file(File(item.path), width: 70, height: 70),
                  ),
                ),
              ] else ...[
                InkWell(
                  onTap: () async {
                    setState(() {
                      context.read<ProdukSellerProvider>().pickProductImage(
                        index,
                      );
                    });
                  },
                  child: SafeNetworkImage(
                    width: 70,
                    height: 70,
                    url: itemUrl ?? '',
                    errorBuilder: Image.file(
                      File(item?.path ?? ''),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset(Assets.imagesImgPlaceholder);
                      },
                    ),
                  ),
                ),
              ],
              if ((index > 0 || item != null) && index != fotoLength - 1)
                Positioned(
                  right: 3,
                  top: 3,
                  child: Container(
                    width: 15,
                    height: 15,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      color: Colors.pink,
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: Icon(
                        Icons.close_rounded,
                        color: Colors.yellow,
                        size: 15,
                      ),
                      onPressed: () async {
                        setState(() {
                          context
                              .read<ProdukSellerProvider>()
                              .onRemoveProductImage(index);
                        });
                      },
                    ),
                  ),
                ),
            ],
          ),
        );
      });
    }

    Widget fotoProduk() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Foto produk', style: TextStyle(color: Constant.textColor2)),
          Constant.xSizedBox16,
          Align(
            alignment: Alignment.center,
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              alignment: WrapAlignment.start,
              spacing: 8,
              runSpacing: 8,
              children: fotoItem(),
            ),
          ),
        ],
      );
    }

    Widget form() {
      return Column(
        children: [
          // Constant.xSizedBox16,
          // CustomTextField.borderTextField(
          //     labelText: 'Kode', controller: p.kodeC),
          Constant.xSizedBox16,
          CustomTextField.borderTextField(
            labelText: 'Nama',
            controller: p.namaC,
            textCapitalization: TextCapitalization.words,
            onChanged: (v) {
              setState(() {});
            },
          ),
          Constant.xSizedBox16,
          CustomDropdown.normalDropdown(
            selectedItem: p.selectedKategori,
            labelText: 'Kategori',
            controller: p.kategoriC,
            onChanged: (v) {
              if (v != null) {
                p.kategoriC.text = v;
                p.selectedKategori = v;
              }
              FocusManager.instance.primaryFocus?.unfocus();
              log("KATEGORI : $v");
              setState(() {});
            },
            list: p.kategori,
          ),
          Constant.xSizedBox16,
          Row(
            children: [
              Expanded(
                child: CustomTextField.borderTextField(
                  labelText: 'Harga',
                  controller: p.hargaC,
                  textInputType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    ThousandsSeparatorInputFormatter(),
                  ],
                  onChanged: (v) {
                    setState(() {});
                  },
                ),
              ),
              Constant.xSizedBox16,
              Expanded(
                child: CustomTextField.borderTextField(
                  labelText: 'Stok',
                  controller: p.stokC,
                  textInputType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    ThousandsSeparatorInputFormatter(),
                  ],
                  onChanged: (v) {
                    setState(() {});
                  },
                ),
              ),
            ],
          ),
          Constant.xSizedBox16,
          CustomTextField.borderTextArea(
            labelText: 'Deskripsi',
            controller: p.deskripsiC,
            focusNode: p.deskripsiN,
            onChanged: (v) {
              setState(() {});
            },
          ),
          Constant.xSizedBox16,
        ],
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: appBar(),
      body: SafeArea(
        child: Container(
          color: Colors.white,
          child: ListView(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            children: [fotoProduk(), form()],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        height: kBottomNavigationBarHeight + 12,
        color: Colors.white,
        child: CustomButton.mainButton(
          'Simpan',
          color:
              p.namaC.text.isNotEmpty &&
                      p.hargaC.text.isNotEmpty &&
                      p.stokC.text.isNotEmpty
                  ? null
                  : Colors.grey,
          borderRadius: BorderRadius.circular(12),
          () async {
            await context
                .read<ProdukSellerProvider>()
                .sendProduct(withLoading: true, isEdit: widget.isEdit)
                .then((value) async {
                  Utils.showSuccess(
                    msg: "Sukses ${widget.isEdit ? "Edit" : "Tambah"} Produk",
                  );
                  await Future.delayed(Duration(seconds: 2));

                  CusNav.nPop(context, true);
                  p.productDetailSellerModel = ProdukDetailSellerModel();
                  p.fotoProduk.clear();
                  p.fotoProdukUrl.clear();
                  p.fotoProduk.add(null);
                  p.namaC.clear();
                  p.hargaC.clear();
                  p.stokC.clear();
                  p.selectedKategori = null;
                  setState(() {});
                  return true;
                })
                .onError((error, stackTrace) async {
                  Utils.showFailed(msg: error.toString());
                  await Future.delayed(Duration(seconds: 2));
                  return false;
                });
          },
          // margin: EdgeInsets.symmetric(horizontal: 16),
        ),
      ),
    );
  }
}
