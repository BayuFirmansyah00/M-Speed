import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_signature_pad/flutter_signature_pad.dart';
import 'package:mspeed/common/base/base_state.dart';
import 'package:mspeed/common/component/custom_appbar.dart';
import 'package:mspeed/common/component/custom_textField.dart';
import 'package:mspeed/common/helper/Constant.dart';
import 'package:mspeed/common/helper/safe_network_image.dart';
import 'package:mspeed/generated/assets.dart';
import 'package:mspeed/src/seller/pesanan/model/detail_pesanan_seller_model.dart';
import 'package:mspeed/src/seller/pesanan/provider/seller_pesanan_provider.dart';
import 'package:mspeed/utils/Utils.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:provider/provider.dart';

class PesananBuatSuratView extends StatefulWidget {
  final DetailPesananSellerModel data;
  final SuratType suratType;

  PesananBuatSuratView({required this.data, required this.suratType});

  @override
  _PdfSignatureScreenState createState() => _PdfSignatureScreenState();
}

class _PdfSignatureScreenState extends BaseState<PesananBuatSuratView> {
  GlobalKey<SignatureState> signKey = GlobalKey();
  bool productExpanded = false;

  @override
  void initState() {
    super.initState();
  }

  final catatanC = TextEditingController();
  final List<ProductCatatan> products = [];

  @override
  Widget build(BuildContext context) {
    final list = widget.data.data?.detail;
    for (int i = 0; i < (widget.data.data?.detail?.length ?? 0); i++) {
      products.add(ProductCatatan(id: list![i]!.ID!));
    }

    Widget grayDivider() {
      return Container(
          color: Color(0xFFF6F6F6), height: 8, width: double.infinity);
    }

    Widget detailProduk() {
      int total = widget.data.data?.detail?.length ?? 0;
      int collapsedCount = total > 2 ? 2 : total;

      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Produk', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            ListView.separated(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: productExpanded ? total : collapsedCount,
              separatorBuilder: (_, __) => Constant.xSizedBox16,
              itemBuilder: (c, i) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: SafeNetworkImage(
                          width: 70,
                          height: 70,
                          url: widget.data.data?.detail?[i]?.foto ?? '',
                          errorBuilder: Image.asset(Assets.imagesImgHeadphone),
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                widget.data.data?.detail?[i]?.nama ?? '-',
                              ),
                              Text(
                                'Total Harga',
                                style: TextStyle(
                                    fontSize: 12, color: Constant.textColor2),
                              ),
                            ],
                          ),
                          Constant.xSizedBox4,
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                widget.data.data?.detail?[i]?.hargaAkhir != null
                                    ? '${widget.data.data?.detail?[i]?.qty ?? '1'} x ${Utils.thousandSeparator(int.parse(widget.data.data?.detail?[i]?.hargaAkhir ?? '0'))}'
                                    : '${widget.data.data?.detail?[i]?.qty ?? '1'} x ${Utils.thousandSeparator(int.parse(widget.data.data?.detail?[i]?.harga ?? '0'))}',
                                style: TextStyle(
                                  color: Constant.textColor2,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                Utils.thousandSeparator(int.parse(
                                    widget.data.data?.detail?[i]?.hargaAkhir ??
                                        '0')),
                                style: TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                          Constant.xSizedBox8,
                          CustomTextField.normalTextField(
                              onChanged: (v) {
                                products[i].ket = v.isEmpty ? null : v;
                              },
                              required: false,
                              hintText: 'Tambahkan Keterangan ...',
                              controller: TextEditingController()),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
            SizedBox(height: 16),
            InkWell(
              onTap: () {
                setState(() {
                  productExpanded = !productExpanded;
                });
              },
              child: Container(
                padding: EdgeInsets.all(20),
                child: Center(
                  child: Text(
                      '${productExpanded ? "Sembunyikan" : "Tampilkan"} Produk Lainnya',
                      style: TextStyle(
                        fontSize: 12,
                        color: Constant.textColor2,
                      )),
                ),
              ),
            ),
          ],
        ),
      );
    }

    Widget catatan() {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Catatan', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            CustomTextField.borderTextArea(
                hintText: 'Masukkan catatan bila ada...',
                controller: catatanC,
                required: false,
                focusNode: FocusNode())
          ],
        ),
      );
    }

    Widget ttd() {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tanda Tangan',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                Row(
                  children: [
                    IconButton(
                        onPressed: () {
                          signKey.currentState?.clear();
                        },
                        icon: Icon(
                          Icons.clear,
                          color: Colors.red,
                        )),
                    IconButton(
                        onPressed: () {},
                        icon: Icon(
                          Icons.check,
                          color: Colors.green,
                        )),
                  ],
                )
              ],
            ),
            SizedBox(
              height: 12,
            ),
            Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(10)),
              height: 188,
              child: Signature(
                key: signKey,
                color: Colors.black87,
                strokeWidth: 5,
                onSign: () {},
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
        widget.suratType.title,
        color: Colors.white,
        isCenter: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: ListView(
        children: [
          if (widget.suratType == SuratType.SURAT_JALAN) ...[
            grayDivider(),
            detailProduk(),
            grayDivider(),
            catatan(),
          ],
          grayDivider(),
          ttd(),
          SizedBox(height: 16.0),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Constant.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
            onPressed: () async {
              final p = context.read<SellerPesananProvider>();
              final sign = signKey.currentState!;
              final image = await sign.getData();
              var data = await image.toByteData(format: ImageByteFormat.png);
              final dir = await getTemporaryDirectory();

              if (data != null) {
                final file = File('${dir.path}/signature.png');
                if (file.existsSync()) {
                  file.deleteSync();
                }
                file.writeAsBytesSync(data.buffer.asUint8List(), flush: true);
                sign.clear();
                // if (widget.suratType == SuratType.SURAT_PESANAN) {
                //   final success = await p.fetchActionPesananBaru(
                //       parent_id: widget.data.data?.ParentOrderModel?.ID ?? '',
                //       terima: true,
                //       withLoading: true);
                //
                //   if (!success) return;
                // }

                final successTtd = await p.addTtdPemesanan(
                    transaction_id:
                        widget.data.data?.ParentOrderModel?.ID ?? '',
                    nomor_order:
                        widget.data.data?.ParentOrderModel?.nomorOrder ?? '',
                    suratType: widget.suratType,
                    image: file);

                if (widget.suratType == SuratType.SURAT_JALAN) {
                  if (!await p.buatSuratJalan(
                      transaction_id:
                          widget.data.data?.ParentOrderModel?.ID ?? '',
                      productCatatan: products,
                      catatan: catatanC.text)) return;
                }

                // widget.onSubmit(file);
                if (successTtd) {
                  Navigator.pop(context);
                  p.fetchDetailPesanan(
                    parent_id: widget.data.data?.ParentOrderModel?.ID ?? '',
                  );
                }
              } else {
                sign.clear();
              }
            },
            child: Text(
              'Simpan',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}

enum SuratType {
  SURAT_JALAN("addsuratjalanseller", "Buat Surat Jalan"),
  SURAT_PESANAN("addsuratpesananseller", "Buat Surat Pesanan"),
  KWITANSI("addkwitansiseller", "-");

  final String path;
  final String title;

  const SuratType(this.path, this.title);
}
