import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mspeed/common/base/base_state.dart';
import 'package:mspeed/common/component/custom_appbar.dart';
import 'package:mspeed/common/component/custom_container.dart';
import 'package:mspeed/common/component/custom_dialog.dart';
import 'package:mspeed/common/component/custom_navigator.dart';
import 'package:mspeed/common/component/image_network_widget.dart';
import 'package:mspeed/common/helper/Constant.dart';
import 'package:mspeed/generated/assets.dart';
import 'package:mspeed/src/buyer/chat/view/chat_person_view.dart';
import 'package:mspeed/src/buyer/seller/view/seller_home_product_view.dart';
import 'package:mspeed/src/buyer/transaction/model/detail_tansaction_buyer_model.dart';
import 'package:mspeed/src/buyer/transaction/provider/transaction_provider.dart';
import 'package:mspeed/src/buyer/transaction/widget/file_button_widget.dart';
import 'package:mspeed/src/buyer/transaction/widget/return_bill_widget.dart';
import 'package:mspeed/src/buyer/transaction/widget/submit_ttd_widget.dart';
import 'package:mspeed/src/buyer/transaction/widget/transaction_status_stepper.dart';
import 'package:mspeed/src/seller/pesanan/model/detail_pesanan_seller_model.dart';
import 'package:mspeed/src/seller/pesanan/provider/seller_pesanan_provider.dart';
import 'package:mspeed/utils/utils.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

class DetailTransactionView extends StatefulWidget {
  final String transaction_id, seller_id;

  const DetailTransactionView({
    super.key,
    required this.transaction_id,
    required this.seller_id,
  });

  @override
  State<DetailTransactionView> createState() => _DetailTransactionViewState();
}

class _DetailTransactionViewState extends BaseState<DetailTransactionView> {
  String userId = "";
  String buyerName = "";
  String buyerPhone = "";

  @override
  void initState() {
    super.initState();
    initData();
  }

  Future<void> initData() async {
    final prefs = await SharedPreferences.getInstance();
    userId = await prefs.getString(Constant.kSetPrefId) ?? "";
    buyerName = await prefs.getString(Constant.kSetPrefFirstName) ?? "";
    buyerPhone = await prefs.getString(Constant.kSetPrefPhone) ?? "";
    await context.read<TransactionProvider>().fetchDetailTransaction(
      transaction_id: widget.transaction_id,
    );

    await context.read<SellerPesananProvider>().fetchDetailPesanan(
      seller_id: widget.seller_id,
      withLoading: true,
      parent_id: widget.transaction_id,
    );
  }

  DetailTransaksiBuyerModelData? data = DetailTransaksiBuyerModelData();
  DetailPesananSellerModelData? dataSeller = DetailPesananSellerModelData();

  // void refresh() {
  //   context.read<SellerPesananProvider>().fetchDetailPesanan(
  //       seller_id: widget.seller_id,
  //       withLoading: true,
  //       parent_id: widget.transaction_id);
  // }

  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    data = context.watch<TransactionProvider>().getDetailTransaksi.data;
    dataSeller =
        context.watch<SellerPesananProvider>().detailPesananSellerModel.data;
    final transactionP = context.watch<TransactionProvider>();
    final item = context.watch<TransactionProvider>().getDetailTransaksi.data;

    _historyNego(BuildContext context) {
      CustomDialog.newDialog(
        context: context,
        titlePadding: EdgeInsets.zero,
        contentPadding: EdgeInsets.zero,
        title: Row(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                icon: Icon(Icons.close, color: Colors.black, size: 20),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
            Text("Riwayat Nego", style: Constant.iBlackMedium16),
          ],
        ),
        content: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(
                transactionP.riwayatNegoTransaksiModel.data?.length ?? 0,
                (index) {
                  return transactionP
                              .riwayatNegoTransaksiModel
                              .data?[index]
                              ?.nego !=
                          null
                      ? CustomContainer.mainCard(
                        margin: EdgeInsets.only(bottom: 10),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Expanded(
                                //   flex: 3,
                                //   child: SafeNetworkImage(
                                //     url: transactionP.riwayatNegoTransaksiModel?
                                //         .data?[index]?.foto ??
                                //         "",
                                //     width: double.minPositive,
                                //     height: 50,
                                //     errorBuilder: Image.asset(
                                //         Assets.imagesMainImageNotFound),
                                //   ),
                                // ),
                                SizedBox(width: 5),
                                Expanded(
                                  flex: 4,
                                  child: Text(
                                    Utils.thousandSeparator(
                                      int.parse(
                                        transactionP
                                                .riwayatNegoTransaksiModel
                                                .data?[index]
                                                ?.hargaAwal ??
                                            "-",
                                      ),
                                    ),
                                    style: Constant.iBlackMedium16.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        Utils.thousandSeparator(
                                          int.parse(
                                            (transactionP
                                                        .riwayatNegoTransaksiModel
                                                        .data?[index]
                                                        ?.nego ??
                                                    "-")
                                                .replaceAll(".", ""),
                                          ),
                                        ),
                                        style: Constant.iBlackMedium16.copyWith(
                                          fontSize: 14,
                                        ),
                                      ),
                                      Text(
                                        transactionP
                                                .riwayatNegoTransaksiModel
                                                .data?[index]
                                                ?.status ??
                                            "Menunggu",
                                        style: Constant.greyThrough12,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      )
                      : SizedBox();
                },
              ),
            ),
          ),
        ),
      );
    }

    List<Widget> showListItems() {
      List<Widget> list = [];
      final length = data?.detail?.length ?? 0;
      if (length == 0) {
        return [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                "Tidak ada data",
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ),
        ];
      }

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
              children: [
                ImageNetworkWidget(
                  width: 50,
                  height: 50,
                  radius: 12,
                  imageUrl: data?.detail?[i]?.foto ?? '',
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data?.detail?[i]?.nama ?? '',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      Text(
                        '${data?.detail?[i]?.qty ?? '1'} x${formatCurrency(data?.detail?[i]?.harga ?? '0')}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: Constant.grayColor,
                        ),
                      ),
                      InkWell(
                        onTap: () async {
                          setState(() async {
                            await transactionP.fetchRiwayatNegoTransaksi(
                              context,
                              tempOrderId:
                                  item?.ParentOrderModel?.TempOrderID ?? "0",
                              productId: item?.detail?[i]?.ID ?? "0",
                            );
                            await _historyNego(context);
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 5,
                          ),
                          margin: EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: Color(0xFF5396A9),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            "Riwayat Nego",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Harga',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Constant.grayColor,
                      ),
                    ),
                    Text(
                      formatCurrency(data?.detail?[i]?.hargaAkhir ?? '0'),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
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

    List<Widget> status() {
      final list = data?.timeline ?? [];
      if (list.isEmpty) return [SizedBox()];
      final length =
          transactionP.showMore
              ? list.length
              : (list.length >= 3 ? 3 : list.length);
      var widgets = List<Widget>.generate(length, (i) {
        final item = list[i];
        return TransactionStatusStepper(
          title: item?.label ?? '',
          date: item?.time ?? '',
          note: item?.desc,
          isLast: i == length - 1,
        );
      });
      if (list.isNotEmpty && list.length > 3)
        widgets.add(
          InkWell(
            onTap: () async {
              context.read<TransactionProvider>().showMore =
                  !transactionP.showMore;
              setState(() {});
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
              child: Center(
                child: Text(
                  'Tampilkan Lebih ${transactionP.showMore ? 'Sedikit' : 'Banyak'}',
                  style: TextStyle(color: Constant.redColor, fontSize: 12),
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
          padding: EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 20),
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
                    child: Text(
                      'Timeline Kosong',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      return SizedBox();
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar.appBar(
        context,
        'Detail Order',
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
              statusW(),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
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
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'No Order',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        Text(
                          data?.ParentOrderModel?.nomorOrder ?? '-',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Tanggal Order',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        Text(
                          data?.ParentOrderModel?.Created ?? '-',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Departemen',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        Text(
                          data?.NamaDepartment ?? '-',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Alamat Pengiriman',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        SizedBox(width: 20),
                        Expanded(
                          child: Text(
                            data?.ParentOrderModel?.alamat ?? '-',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.end,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Nama Seller',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        Text(
                          data?.ParentOrderModel?.SellerNama ?? '-',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Alamat Seller',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        SizedBox(width: 20),
                        Expanded(
                          child: Text(
                            data?.ParentOrderModel?.SellerAlamat ?? '-',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.end,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Nama Penerima',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        Text(
                          data?.ParentOrderModel?.PenerimaNama ?? '-',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'PIC (Kontak Sales)',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        Text(
                          data?.ParentOrderModel?.telp ?? '-',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Estimasi Tanggal Pengiriman',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        SizedBox(width: 20),
                        Expanded(
                          child: Text(
                            '${data?.ParentOrderModel?.estPengiriman != "0000-00-00" ? DateFormat('d MMMM yyyy').format(DateTime.parse(data?.ParentOrderModel?.estPengiriman ?? "0000-00-00")) : ''} - ${data?.ParentOrderModel?.estPengiriman2 != "0000-00-00" ? DateFormat('d MMMM yyyy').format(DateTime.parse(data?.ParentOrderModel?.estPengiriman2 ?? "0000-00-00")) : ''}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.end,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'DPP',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        SizedBox(width: 20),
                        Expanded(
                          child: Text(
                            '${data?.ParentOrderModel?.nomorDpp ?? ''}${data?.ParentOrderModel?.dpp != null ? ' - ${data?.ParentOrderModel?.dpp}' : ''}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.end,
                          ),
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
              // Product Info
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          onTap: () {},
                          child: Text(
                            'Detail Produk',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            CusNav.nPush(
                              context,
                              SellerHomeProductView(
                                id: data?.detail?.firstOrNull?.SellerID ?? '0',
                              ),
                            );
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              SvgPicture.asset(Assets.svgsIcBukuAlamat),
                              Text(data?.ParentOrderModel?.SellerNama ?? '-'),
                              Icon(Icons.navigate_next),
                            ],
                          ),
                        ),
                      ],
                    ),
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
                    Text(
                      'Info Pengiriman',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Alamat',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                        SizedBox(width: 36),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data?.ParentOrderModel?.PenerimaNama ?? '-',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${data?.ParentOrderModel?.telp}\n${data?.ParentOrderModel?.alamat ?? '-'}',
                                style: TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
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
              ), // Order Summary
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rincian Belanja',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Subtotal'),
                        Text(
                          formatCurrency(
                            data?.ParentOrderModel?.subtotal ?? '0',
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Ongkir'),
                        Text(
                          formatCurrency(data?.ParentOrderModel?.ongkir ?? '0'),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Pajak'),
                        Text(
                          formatCurrency(data?.ParentOrderModel?.pajak ?? '0'),
                        ),
                      ],
                    ),
                    Divider(color: Color(0xFFF6F6F6)),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          formatCurrency(data?.ParentOrderModel?.total ?? '0'),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),
            ],
          ),
        ),
      ),
      bottomNavigationBar: buildBottomBar(),
    );
  }

  Future<void> _launchURL(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Could not launch $url';
    }
  }

  void showTtdDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: SubmitTtdWidget(
            onSubmit: (v) async {
              final provider = context.read<TransactionProvider>();
              final sellerP = context.read<SellerPesananProvider>();

              final success = await provider.addTtdPemesanan(
                transaction_id: data?.ParentOrderModel?.ID ?? '',
                nomor_order: data?.ParentOrderModel?.nomorOrder ?? '',
                image: v,
              );

              // TODO: SNACKBAR NOT SHOWING IDK WHY ¯\_(ツ)_/¯. PROBS CONTEXT ISSUE
              // if (success) {
              //   print('haloo');
              //   final snackBar = SnackBar(
              //     backgroundColor: Colors.blue,
              //     content: Text(
              //       'Berhasil Menambahkan Tanda Tangan',
              //       style: TextStyle(color: Colors.white),
              //     ),
              //   );
              //   ScaffoldMessenger.of(context).showSnackBar(snackBar);
              // } else {
              //   print('halooaaaaa');
              //   final snackBar = SnackBar(
              //       backgroundColor: Colors.red,
              //       content: Text(
              //         'Gagal Menambahkan Tanda Tangan',
              //         style: TextStyle(color: Colors.white),
              //       ));
              //   ScaffoldMessenger.of(context).showSnackBar(snackBar);
              // }

              if (success) {
                await Utils.showSuccess(msg: "Berhasil Tanda Tangan!");
                await sellerP.fetchDetailPesanan(
                  parent_id: widget.transaction_id,
                  seller_id: widget.seller_id,
                  withLoading: false,
                );
                provider.isTtdSuccess = null;
              }
              Navigator.of(context).pop();

              //context.showSuccessDialog();
            },
          ),
        );
      },
    );
  }

  void showKembalikanTagihanDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: ReturnBillWidget(
            onSave: () async {
              final provider = context.read<TransactionProvider>();
              final sellerP = context.read<SellerPesananProvider>();

              final success = await provider.kembalikanTagihan(
                parentOrderId: data?.ParentOrderModel?.ID ?? '',
              );

              if (success) {
                await Utils.showSuccess(msg: "Berhasil Kembalikan Tagihan!");
                await provider.fetchDetailTransaction(
                  transaction_id: widget.transaction_id,
                );
                await sellerP.fetchDetailPesanan(
                  parent_id: widget.transaction_id,
                  seller_id: widget.seller_id,
                  withLoading: false,
                );
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

  void showUploadEMateraiDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: FileButtonWidget(
            onSave: () async {
              final provider = context.read<TransactionProvider>();
              final sellerP = context.read<SellerPesananProvider>();

              final success = await provider.uploadEMaterai(
                parentOrderId: data?.ParentOrderModel?.ID ?? '',
              );

              if (success) {
                await Utils.showSuccess(msg: "Berhasil Upload E-Materai!");
                await provider.fetchDetailTransaction(
                  transaction_id: widget.transaction_id,
                );
                await sellerP.fetchDetailPesanan(
                  parent_id: widget.transaction_id,
                  seller_id: widget.seller_id,
                  withLoading: false,
                );
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

  Widget buildBottomBar() {
    final status = data?.timeline?.last?.label;
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 48,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                CusNav.nPush(
                  context,
                  ChatPersonView(
                    id: data?.ParentOrderModel?.SellerID ?? '0',
                    sellerName: data?.ParentOrderModel?.SellerNama ?? '-',
                  ),
                );
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
                child: Image.asset(Assets.iconsIcChatOn, width: 24, height: 24),
              ),
            ),
          ),
          // if ((data?.ParentOrderModel?.status == 'PESANAN_BARU' &&
          //     dataSeller?.ParentOrderModel?.ttdPesananBuyer == null)) ...[
          SizedBox(width: 16),
          if (data?.ParentOrderModel?.status == 'PESANAN_BARU' &&
              dataSeller?.ParentOrderModel?.ttdPesananBuyer == null)
            Expanded(
              child: SizedBox(
                height: 48, // Same height as chat button
                child: ElevatedButton(
                  onPressed: () {
                    showTtdDialog(context);
                  },
                  child: Text(
                    'Buat Surat Pesanan',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
          if (data?.timeline != null &&
              (data?.timeline?.isNotEmpty ?? false) &&
              (status == 'Tagihan' || status == 'Kwitansi Dikembalikan')) ...[
            Expanded(
              child: Container(
                margin: EdgeInsets.only(right: 4),
                height: 48, // Same height as chat button
                child: ElevatedButton(
                  onPressed: () {
                    showKembalikanTagihanDialog(context);
                  },
                  child: Text(
                    'Kembalikan Tagihan',
                    style: TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Container(
                margin: EdgeInsets.only(left: 4),
                height: 48, // Same height as chat button
                child: ElevatedButton(
                  onPressed: () {
                    showUploadEMateraiDialog(context);
                  },
                  child: Text(
                    'Upload E-Materai',
                    style: TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
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
          // ]
        ],
      ),
    );
  }

  String formatCurrency(String amount) {
    int value = double.parse(amount).toInt();
    final formatCurrency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );
    return formatCurrency.format(value);
  }
}
