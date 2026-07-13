import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mspeed/common/base/base_state.dart';
import 'package:mspeed/common/component/custom_appbar.dart';
import 'package:mspeed/common/component/custom_button.dart';
import 'package:mspeed/common/component/custom_dialog.dart';
import 'package:mspeed/common/component/custom_image_picker.dart';
import 'package:mspeed/common/component/custom_navigator.dart';
import 'package:mspeed/common/component/custom_textField.dart';
import 'package:mspeed/common/component/image_network_widget.dart';
import 'package:mspeed/common/helper/Constant.dart';
import 'package:mspeed/common/helper/text_editing_formatter.dart';
import 'package:mspeed/common/page/web_view.dart';
import 'package:mspeed/src/buyer/transaction/widget/transaction_status_stepper.dart';
import 'package:mspeed/src/keuangan/pesanan/model/detail_transaksi_keuangan_model.dart';
import 'package:mspeed/src/keuangan/pesanan/provider/keuangan_provider.dart';
import 'package:mspeed/src/keuangan/pesanan/widget/return_receipt_widget.dart';
import 'package:mspeed/utils/Utils.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as path;
import 'package:permission_handler/permission_handler.dart';

class KeuanganPesananDetailView extends StatefulWidget {
  final String transaction_id;

  const KeuanganPesananDetailView({super.key, required this.transaction_id});

  @override
  State<KeuanganPesananDetailView> createState() =>
      _KeuanganPesananDetailViewState();
}

class _KeuanganPesananDetailViewState
    extends BaseState<KeuanganPesananDetailView> {
  @override
  void initState() {
    initData();
    super.initState();
  }

  Future<void> initData() async {
    final prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString(Constant.kSetPrefId) ?? '1';
    context.read<KeuanganProvider>().fetchDetailTransaction(
        transaction_id: widget.transaction_id, withLoading: true);
    context.read<KeuanganProvider>().clearData();
    await requestPermission(Permission.manageExternalStorage);
    await requestPermission(Permission.photos);
    await requestPermission(Permission.storage);
  }

  DetailTransaksiKeuanganModelData? data = DetailTransaksiKeuanganModelData();

  void refresh() {
    context.read<KeuanganProvider>().fetchDetailTransaction(
        transaction_id: widget.transaction_id, withLoading: true);
  }

  Future<bool> requestPermission(Permission permission) async {
    PermissionStatus status = await permission.request();
    return [PermissionStatus.granted, PermissionStatus.limited]
        .contains(status);
  }

  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    data = context.watch<KeuanganProvider>().detailTransaksi.data;
    final keuanganP = context.watch<KeuanganProvider>();

    void _lihatLampiranTagihan(BuildContext context) {
      CustomDialog.newDialog(
          context: context,
          titlePadding: EdgeInsets.zero,
          contentPadding: EdgeInsets.symmetric(horizontal: 10),
          title: Row(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: Icon(
                    Icons.arrow_back_outlined,
                    color: Colors.black,
                    size: 20,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
              Text(
                "Lampiran Tagihan",
                style: Constant.iBlackMedium16,
              ),
            ],
          ),
          content: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                    onTap: () async {
                      await keuanganP.fetchLampiranTagihanKeuangan(context,
                          transaction_id: data?.ParentOrderModel?.ID ?? "");
                      await CusNav.nPush(
                        context,
                        WebViewPage(
                          "Lihat Faktur",
                          (keuanganP.lihatLampiranModel.data?.faktur ?? ""),
                          true,
                        ),
                        // PdfView(pdfUrl: (keuanganP.lihatLampiranModel.data?.faktur ?? "") , title: "Lihat Faktur")
                      );
                    },
                    child:
                        Text("Lihat Faktur", style: Constant.iBlackMedium13)),
                SizedBox(
                  height: 10,
                ),
                InkWell(
                    onTap: () async {
                      await keuanganP.fetchLampiranTagihanKeuangan(context,
                          transaction_id: data?.ParentOrderModel?.ID ?? "");
                      await CusNav.nPush(
                        context,
                        // PdfView(pdfUrl: (keuanganP.lihatLampiranModel.data?.enofa ?? "") , title: "Lihat Enofa")
                        WebViewPage(
                          "Lihat E-Nofa",
                          (keuanganP.lihatLampiranModel.data?.enofa ?? ""),
                          true,
                        ),
                      );
                      // PDFScreen(path: (keuanganP.lihatLampiranModel.data?.enofa ??
                      //     "")));
                    },
                    child:
                        Text("Lihat E-Nofa", style: Constant.iBlackMedium13)),
              ],
            ),
          ));
    }

    void _cetakSurat(BuildContext context) {
      CustomDialog.newDialog(
          context: context,
          titlePadding: EdgeInsets.zero,
          contentPadding: EdgeInsets.symmetric(horizontal: 10),
          title: Row(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: Icon(
                    Icons.close,
                    color: Colors.black,
                    size: 20,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
              Text(
                "Cetak Surat",
                style: Constant.iBlackMedium16,
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                      onTap: () async {
                        await keuanganP.fetchInvoiceKeuangan(context,
                            transaction_id: data?.ParentOrderModel?.ID ?? "");
                      },
                      child: Text("Cetak Invoice",
                          style: Constant.iBlackMedium13)),
                  SizedBox(
                    height: 10,
                  ),
                  InkWell(
                      onTap: () async {
                        await keuanganP.fetchKwitansiKeuangan(context,
                            transaction_id: data?.ParentOrderModel?.ID ?? "");
                      },
                      child: Text("Cetak Kwitansi",
                          style: Constant.iBlackMedium13)),
                  SizedBox(
                    height: 10,
                  ),
                  InkWell(
                      onTap: () async {
                        await keuanganP.fetchPesananKeuangan(context,
                            transaction_id: data?.ParentOrderModel?.ID ?? "");
                      },
                      child: Text("Cetak Surat Pesanan",
                          style: Constant.iBlackMedium13)),
                  SizedBox(
                    height: 10,
                  ),
                  InkWell(
                      onTap: () async {
                        await keuanganP.fetchSuratJalankeuangan(context,
                            transaction_id: data?.ParentOrderModel?.ID ?? "");
                      },
                      child: Text("Cetak Surat Jalan",
                          style: Constant.iBlackMedium13)),
                  SizedBox(
                    height: 10,
                  ),
                  InkWell(
                      onTap: () async {
                        _lihatLampiranTagihan(context);
                      },
                      child: Text("Lihat Lampiran Tagihan",
                          style: Constant.iBlackMedium13)),
                  SizedBox(
                    height: 10,
                  ),
                ],
              ),
            ),
          ));
    }

    void _uploadBukti(BuildContext context, String parentOrderId) {
      CustomDialog.newDialog(
          titlePadding: EdgeInsets.zero,
          contentPadding: EdgeInsets.all(10),
          context: context,
          title: Row(
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
              SizedBox(
                width: 20,
              ),
              Text(
                "Upload Bukti Pembayaran",
                style: Constant.blackBold13,
              ),
            ],
          ),
          content: StatefulBuilder(builder: (context, state) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomTextField.borderTextField(
                    controller: keuanganP.uploadC,
                    required: false,
                    labelText: "Upload Bukti Bayar",
                    readOnly: true,
                    suffixIcon: Icon(
                      Icons.cloud_upload,
                      color: Colors.grey,
                    ),
                    hintText: keuanganP.attachC.text != ""
                        ? keuanganP.attachC.text
                        : "Upload",
                    textInputType: TextInputType.number,
                    textCapitalization: TextCapitalization.words,
                    focusNode: keuanganP.uploadNode,
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      ThousandsSeparatorInputFormatter(),
                    ],
                    onTap: () async {
                      String fileName;
                      final file =
                          await CustomImagePicker.cameraOrGallery(context);
                      FocusManager.instance.primaryFocus?.unfocus();
                      if (file != null) {
                        fileName = path.basename(file.path);
                        keuanganP.attachC.text = fileName;
                        keuanganP.imageAttachment = file;
                        state(() {});
                        setState(() {});
                      }
                    }),
                SizedBox(
                  height: 20,
                ),
                CustomButton.mainButton("Simpan",
                    borderRadius: BorderRadius.circular(10), () async {
                  // keuanganP
                  await keuanganP.sendBuktiBayar(
                      parent_order_id: parentOrderId,
                      image: keuanganP.imageAttachment!);
                  await Utils.showSuccess(msg: "Berhasil Upload Pembayaran");
                  initData();
                  await CusNav.nPop(context);
                })
              ],
            );
          }));
    }

    void showKembalikanKwitansiDialog(BuildContext context) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            backgroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: ReturnReceiptWidget(
              onSave: () async {
                final success = await keuanganP.kembalikanKwitansi(
                    parentOrderId: data?.ParentOrderModel?.ID ?? '');

                if (success) {
                  await Utils.showSuccess(msg: "Berhasil Kembalikan Tagihan!");
                  await context.read<KeuanganProvider>().fetchDetailTransaction(
                      transaction_id: widget.transaction_id, withLoading: true);
                } else {
                  return;
                }
                Navigator.of(context).pop();
              },
            ),
          );
        },
      );
    }

    String formatCurrency(String amount) {
      // Mengonversi string ke integer
      int value = int.parse(amount);

      // Membuat format untuk Rupiah
      final formatCurrency = NumberFormat.currency(
          locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

      // Mengonversi integer ke format mata uang
      return formatCurrency.format(value);
    }

    List<Widget> showListItems() {
      List<Widget> list = [];
      final length = data?.detail?.length ?? 0;
      final iteration = isExpanded ? length : 1;

      for (int i = 0; i < iteration; i++) {
        list.add(
          Container(
            margin: EdgeInsets.symmetric(vertical: 12),
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Color(0xFFF6F6F6)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Align(
                //     alignment: Alignment.topLeft,
                //     child: Checkbox(value: i % 2 == 0, onChanged: (_) {})),
                ImageNetworkWidget(
                  width: 50,
                  height: 50,
                  radius: 12,
                  imageUrl: data?.detail?[i]?.foto ?? '',
                ),
                SizedBox(
                  width: 8,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data?.detail?[i]?.nama ?? '',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      Text(
                        '${data?.detail?[i]?.qty ?? '1'} x${formatCurrency(data?.detail?[i]?.hargaAkhir ?? '0')}',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: Constant.grayColor),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Text(
                      "Total Harga",
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: Constant.grayColor),
                    ),
                    Text(
                      formatCurrency(data?.detail?[i]?.hargaAkhir ?? '0'),
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }

      return list;
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // SizedBox(
                //   width: 48,
                //   height: 48,
                //   child: ElevatedButton(
                //     onPressed: () {
                //       CusNav.nPush(
                //           context,
                //           ChatPersonView(
                //               id: data?.ParentOrderModel?.SellerID ?? '0',
                //               sellerName:
                //                   data?.detail?.firstOrNull?.SellerNama ?? '-'));
                //     },
                //     style: ElevatedButton.styleFrom(
                //       backgroundColor: Colors.white,
                //       shape: RoundedRectangleBorder(
                //         borderRadius: BorderRadius.circular(12),
                //         side: BorderSide(color: Colors.red, width: 2),
                //       ),
                //       padding: EdgeInsets.zero,
                //     ),
                //     child: Center(
                //       child: Icon(
                //         Icons.chat_bubble_outline,
                //         color: Colors.red,
                //         size: 24, // Adjust icon size as needed
                //       ),
                //     ),
                //   ),
                // ),
                if (data?.timeline?.last?.label == 'Siap Tagih')
                  Expanded(
                    child: SizedBox(
                      height: 50, // Same height as chat button
                      child: ElevatedButton(
                        onPressed: () {
                          showKembalikanKwitansiDialog(context);
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.close,
                              color: Colors.white,
                            ),
                            Expanded(
                              child: Center(
                                child: Text('Kembalikan Kwitansi',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600)),
                              ),
                            ),
                          ],
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Constant.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ),
                if (data?.timeline?.last?.label == 'Siap Tagih')
                  SizedBox(width: 16),
                // if (keuanganP.detailTransaksi.data?.ParentOrderModel?.status ==
                //     'TELAH_DIBAYAR')
                Expanded(
                  child: SizedBox(
                    height: 50, // Same height as chat button
                    child: ElevatedButton(
                      onPressed: () {
                        _cetakSurat(context);
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.print_outlined,
                            color: Colors.white,
                          ),
                          Expanded(
                            child: Center(
                              child: Text('Cetak Surat',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600)),
                            ),
                          ),
                        ],
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF1ABB62),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (data?.timeline?.last?.label == 'Siap Tagih')
              SizedBox(height: 8),
            if (data?.timeline?.last?.label == 'Siap Tagih')
              if (keuanganP.detailTransaksi.data?.ParentOrderModel?.status !=
                  "TELAH_DIBAYAR")
                Container(
                  height: 50, // Same height as chat button
                  child: ElevatedButton(
                    onPressed: () async {
                      _uploadBukti(
                          context,
                          keuanganP
                                  .detailTransaksi.data?.ParentOrderModel?.ID ??
                              "");
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.check,
                          color: Colors.white,
                        ),
                        Expanded(
                          child: Text(
                            'Terima Tagihan',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600),
                            maxLines: 2,
                          ),
                        ),
                      ],
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Constant.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                )
          ],
        ),
      );
    }

    List<Widget> status() {
      final list = data?.timeline ?? [];
      if (list.isEmpty) return [SizedBox()];
      final length = keuanganP.showMore ? list.length : 3;
      var widgets = List<Widget>.generate(
        length,
        (i) {
          final item = list[i];
          return TransactionStatusStepper(
            title: item?.label ?? '',
            date: item?.time ?? '',
            note: item?.desc,
            isLast: i == length - 1,
          );
        },
      );
      if (list.isNotEmpty)
        widgets.add(
          InkWell(
            onTap: () async {
              context.read<KeuanganProvider>().showMore = !keuanganP.showMore;
              setState(() {});
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
              child: Center(
                child: Text(
                  'Tampilkan Lebih ${keuanganP.showMore ? 'Sedikit' : 'Banyak'}',
                  style: TextStyle(
                    color: Constant.redColor,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),
        );
      return widgets;
    }

    Widget statusW() {
      if (data?.ParentOrderModel?.status != "PESANAN_DITOLAK")
        return Container(
          color: Color(0xFFFEF9F4),
          padding: EdgeInsets.only(top: 36, left: 16, right: 16, bottom: 20),
          child: Column(
            children: [
              if (data?.timeline?.isNotEmpty ?? false) ...[
                Container(
                  color: Color(0xfffff9f4),
                  child: Column(children: status()),
                ),
              ] else ...[
                SizedBox(
                    child: Center(
                        child: Text('Timeline Kosong',
                            style: TextStyle(fontSize: 12))))
              ]
            ],
          ),
        );
      return SizedBox();
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar.appBar(
        context,
        'Detail Pesanan',
        color: Colors.white,
        isCenter: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await initData();
        },
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order Status
              // if (data?.ParentOrderModel?.status != "PESANAN_DITOLAK")
              // Container(
              //   color: Color(0xFFFEF9F4),
              //   padding:
              //       EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 20),
              //   child: Column(
              //     children: [
              //       Container(
              //         color: Color(0xfffff9f4),
              //         child: Column(
              //           children: [
              //             // TransactionStatusStepper(containNote: true),
              //             // TransactionStatusStepper(),
              //             // TransactionStatusStepper(isLast: true),
              //             InkWell(
              //               onTap: () async {},
              //               child: Padding(
              //                 padding: const EdgeInsets.symmetric(
              //                     horizontal: 24, vertical: 18),
              //                 child: Center(
              //                   child: Text(
              //                     'Tampilkan Lebih Banyak',
              //                     style: TextStyle(
              //                       color: Constant.redColor,
              //                       fontSize: 12,
              //                     ),
              //                   ),
              //                 ),
              //               ),
              //             ),
              //           ],
              //         ),
              //       ),
              //       SizedBox(height: 16),
              //       TransactionStepper(
              //         status: TransactionStatus.fromString(
              //           data?.ParentOrderModel?.status ?? '-',
              //         ),
              //       ),
              //       SizedBox(height: 16),
              //       Text(
              //         data?.ParentOrderModel?.status?.replaceAll('_', ' ') ??
              //             '-',
              //         style: TextStyle(
              //             color: Colors.black,
              //             fontSize: 14,
              //             fontWeight: FontWeight.w400),
              //       )
              //     ],
              //   ),
              // ), // Order Info
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    statusW(),
                    Text('Ringkasan',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Status Pesanan',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Constant.statusColor(data?.ParentOrderModel?.status ?? "-").withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            (data?.ParentOrderModel?.status ?? "-").replaceAll('_', ' '),
                            style: TextStyle(
                              color: Constant.statusColor(data?.ParentOrderModel?.status ?? "-") == Colors.black ? Colors.grey : Constant.statusColor(data?.ParentOrderModel?.status ?? "-"),
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    orderDetailItem(
                        'No Order', data?.ParentOrderModel?.nomorOrder ?? '-'),
                    SizedBox(height: 16),
                    orderDetailItem(
                        'Tanggal Pesanan',
                        Utils.convertDateddMMMMyyyyHHmm(
                            data?.ParentOrderModel?.Created ?? '-')),
                    SizedBox(height: 16),
                    orderDetailItem('Rekening',
                        '${(data?.ParentOrderModel?.Rekening ?? '').replaceAll("-", "")} (${data?.ParentOrderModel?.bank ?? ''}) ${data?.ParentOrderModel?.anRek ?? ''}'),
                    SizedBox(height: 16),
                    orderDetailItem('Nama Seller',
                        data?.ParentOrderModel?.SellerNama ?? '-'),
                    SizedBox(height: 16),
                    orderDetailItem(
                        'Alamat Seller', data?.ParentOrderModel?.alamat ?? '-'),
                    SizedBox(height: 16),
                    orderDetailItem(
                        'Nama Penerima', data?.ParentOrderModel?.nama ?? '-'),
                    SizedBox(height: 16),
                    orderDetailItem('PC (Kontak Sales)',
                        data?.ParentOrderModel?.telp ?? '-'),
                    SizedBox(height: 16),
                    orderDetailItem('Estimasi Tanggal Pengiriman',
                        '${Utils.convertDateddMMMMyyyy(data?.ParentOrderModel?.estPengiriman ?? '-')} s/d ${Utils.convertDateddMMMMyyyy(data?.ParentOrderModel?.estPengiriman2 ?? '-')}'),
                    SizedBox(height: 16),
                    orderDetailItem(
                        'DPP', data?.ParentOrderModel?.tglTtdSuratJalan ?? '-'),
                  ],
                ),
              ),
              Container(
                color: Color(0xFFF6F6F6),
                height: 8,
                width: double.infinity,
              ),
              // Product Info
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Terima Barang',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    ...showListItems(),
                    Container(
                      color: Color(0xFFF6F6F6),
                      height: 1,
                      width: double.infinity,
                    ),
                    Center(
                      child: TextButton(
                        onPressed: () {
                          setState(() {
                            isExpanded = !isExpanded;
                          });
                        },
                        child: Text(
                          isExpanded
                              ? 'Tutup Tampilan'
                              : 'Tampilkan Produk Lainnya',
                          style: TextStyle(color: Constant.grayColor),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                color: Color(0xFFF6F6F6),
                height: 8,
                width: double.infinity,
              ), // Shipping Info
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Info Pengiriman',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Text('PIC Penerima',
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 12)),
                        ),
                        Expanded(
                          flex: 7,
                          child: Text(
                            data?.ParentOrderModel?.nama ?? "-",
                            textAlign: TextAlign.end,
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Text('Alamat Pengiriman',
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 12)),
                        ),
                        Expanded(
                          flex: 7,
                          child: Text(
                            '${data?.ParentOrderModel?.alamat ?? "-"} ${data?.ParentOrderModel?.telp ?? '-'}',
                            textAlign: TextAlign.end,
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w500),
                          ),
                        ),
                        // Expanded(
                        //     child: Column(
                        //   crossAxisAlignment: CrossAxisAlignment.start,
                        //   children: [
                        //     Text(
                        //       buyerName,
                        //       style: TextStyle(
                        //           fontSize: 14, fontWeight: FontWeight.bold),
                        //     ),
                        //     Text(
                        //       '${data?.ParentOrderModel?.telp}\n${data?.ParentOrderModel?.alamat ?? '-'}',
                        //       style: TextStyle(fontSize: 12),
                        //     ),
                        //   ],
                        // )),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12),
              Container(
                color: Color(0xFFF6F6F6),
                height: 8,
                width: double.infinity,
              ), // Order Summary
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Ringkasan',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(
                      height: 12,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Subtotal',
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 12,
                                fontWeight: FontWeight.w400)),
                        Row(
                          children: [
                            Text(
                              "Rp",
                              textAlign: TextAlign.start,
                            ),
                            Container(
                              width: 90,
                              child: Text(
                                  Utils.thousandSeparator(double.parse(data
                                                  ?.ParentOrderModel
                                                  ?.subtotal ??
                                              '0')
                                          .toInt())
                                      .replaceAll('Rp', ''),
                                  textAlign: TextAlign.end,
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500)),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Ongkos Kirim',
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 12,
                                fontWeight: FontWeight.w400)),
                        Row(
                          children: [
                            Text(
                              "Rp",
                              textAlign: TextAlign.start,
                            ),
                            Container(
                              width: 90,
                              child: Text(
                                  Utils.thousandSeparator(int.parse(
                                          data?.ParentOrderModel?.ongkir ??
                                              '0'))
                                      .replaceAll('Rp', ''),
                                  textAlign: TextAlign.end,
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500)),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Pajak',
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 12,
                                fontWeight: FontWeight.w400)),
                        Row(
                          children: [
                            Text(
                              "Rp",
                              textAlign: TextAlign.start,
                            ),
                            Container(
                              width: 90,
                              child: Text(
                                  Utils.thousandSeparator(int.parse(
                                          data?.ParentOrderModel?.pajak ?? '0'))
                                      .replaceAll('Rp', ''),
                                  textAlign: TextAlign.end,
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500)),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Divider(
                      thickness: 0.5,
                      color: Colors.grey.withOpacity(0.5),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total Harga',
                            style: TextStyle(
                                color: Constant.primaryColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w600)),
                        Row(
                          children: [
                            Text(
                              "Rp",
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                  color: Constant.primaryColor,
                                  fontWeight: FontWeight.bold),
                            ),
                            Container(
                              width: 90,
                              child: Text(
                                  Utils.thousandSeparator(double.parse(data
                                                  ?.ParentOrderModel
                                                  ?.subtotal ??
                                              '0')
                                          .toInt())
                                      .replaceAll('Rp', ''),
                                  textAlign: TextAlign.end,
                                  style: TextStyle(
                                      color: Constant.primaryColor,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                color: Color(0xFFF6F6F6),
                height: 8,
                width: double.infinity,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: buildBottomBar(),
    );
  }

  orderDetailItem(String title, String value) {
    return Row(
      children: [
        Expanded(
          flex: 4,
          child: Text(
            title,
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        Expanded(
          flex: 6,
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
