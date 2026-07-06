import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mspeed/common/base/base_state.dart';
import 'package:mspeed/common/component/custom_appbar.dart';
import 'package:mspeed/common/component/image_network_widget.dart';
import 'package:mspeed/common/helper/Constant.dart';
import 'package:mspeed/src/buyer/transaction/model/detail_tansaction_buyer_model.dart';
import 'package:mspeed/src/buyer/transaction/provider/transaction_provider.dart';
import 'package:mspeed/utils/Utils.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DetailPesananAdminView extends StatefulWidget {
  const DetailPesananAdminView({super.key, required this.transaction_id});

  final String transaction_id;

  @override
  State<DetailPesananAdminView> createState() => _DetailPesananAdminViewState();
}

class _DetailPesananAdminViewState extends BaseState<DetailPesananAdminView> {
  String userId = "";
  String buyerName = "";
  String buyerPhone = "";

  @override
  void initState() {
    initData();
    super.initState();
  }

  Future<void> initData() async {
    final prefs = await SharedPreferences.getInstance();
    userId = await prefs.getString(Constant.kSetPrefId) ?? "";
    buyerName = await prefs.getString(Constant.kSetPrefFirstName) ?? "";
    buyerPhone = await prefs.getString(Constant.kSetPrefPhone) ?? "";

    context.read<TransactionProvider>().fetchDetailTransaction(
        transaction_id: widget.transaction_id, withLoading: true);
  }

  DetailTransaksiBuyerModelData? data = DetailTransaksiBuyerModelData();

  void refresh() {
    // context.read<TransactionProvider>().fetchTransaction(withLoading: true);
  }

  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    data = context.watch<TransactionProvider>().getDetailTransaksi.data;

    List<Widget> showListItems() {
      List<Widget> list = [];
      final length = data?.detail?.length ?? 0;
      if (length == 0) {
        return [
          Center(
              child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              "tidak ada data",
              style: TextStyle(color: Colors.grey),
            ),
          ))
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
                            fontSize: 14, fontWeight: FontWeight.w400),
                      ),
                      Text(
                        '${data?.detail?[i]?.qty ?? '1'} x${formatCurrency(data?.detail?[i]?.harga ?? '0')}',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: Constant.grayColor),
                      )
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
                          color: Constant.grayColor),
                    ),
                    Text(
                      formatCurrency(data?.detail?[i]?.hargaAkhir ?? '0'),
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      }

      return list;
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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              color: Color(0xFFF6F6F6),
              height: 8,
              width: double.infinity,
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Ringkasan',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(
                    height: 8,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('No Order',
                          style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                              fontWeight: FontWeight.w400)),
                      Text(data?.ParentOrderModel?.nomorOrder ?? '-',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w400)),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Tanggal Order',
                          style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                              fontWeight: FontWeight.w400)),
                      Text(data?.ParentOrderModel?.Created ?? '-',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w400)),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Rekening',
                          style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                              fontWeight: FontWeight.w400)),
                      Text(data?.detail?.firstOrNull?.noRek ?? '-',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w400)),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Estimasi Pengiriman',
                          style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                              fontWeight: FontWeight.w400)),
                      Text(data?.ParentOrderModel?.estPengiriman ?? '-',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w400)),
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
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Info Pengiriman',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('PIC Penerima',
                          style: TextStyle(color: Colors.grey, fontSize: 12)),
                      SizedBox(
                        width: 36,
                      ),
                      Expanded(
                          child: Text(
                        buyerName,
                        style: TextStyle(fontSize: 12),
                        textAlign: TextAlign.end,
                      )),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Alamat Pengiriman',
                          style: TextStyle(color: Colors.grey, fontSize: 12)),
                      SizedBox(
                        width: 36,
                      ),
                      Expanded(
                          child: Text(
                        '${data?.ParentOrderModel?.alamat ?? '-'}\n${data?.ParentOrderModel?.telp}',
                        style: TextStyle(fontSize: 12),
                        textAlign: TextAlign.end,
                      )),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Estimasi Tanggal Pengiriman',
                          style: TextStyle(color: Colors.grey, fontSize: 12)),
                      SizedBox(
                        width: 36,
                      ),
                      Expanded(
                          child: Text(
                        data?.ParentOrderModel?.estPengiriman ?? '-',
                        style: TextStyle(fontSize: 12),
                        textAlign: TextAlign.end,
                      )),
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
                  Text('Detail Produk',
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
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Ringkasan',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Subtotal',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Row(
                          children: [
                            Text('Rp'),
                            Expanded(
                                child: Text(
                              Utils.thousandSeparator(
                                  int.parse(
                                      data?.ParentOrderModel?.subtotal ?? '0'),
                                  symbol: ''),
                              textAlign: TextAlign.end,
                            )),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Ongkos Kirim',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Row(
                          children: [
                            Text('Rp'),
                            Expanded(
                                child: Text(
                              Utils.thousandSeparator(
                                  int.parse(
                                      data?.ParentOrderModel?.ongkir ?? '0'),
                                  symbol: ''),
                              textAlign: TextAlign.end,
                            )),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Pajak',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Row(
                          children: [
                            Text('Rp'),
                            Expanded(
                                child: Text(
                              Utils.thousandSeparator(
                                  int.parse(
                                      data?.ParentOrderModel?.pajak ?? '0'),
                                  symbol: ''),
                              textAlign: TextAlign.end,
                            )),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Divider(
                    color: Color(0xFFF6F6F6),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text('Total Harga',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Constant.primaryColor)),
                      ),
                      Expanded(
                        flex: 1,
                        child: Row(
                          children: [
                            Text(
                              'Rp',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                            Expanded(
                                child: Text(
                              Utils.thousandSeparator(
                                  int.parse(
                                      data?.ParentOrderModel?.total ?? '0'),
                                  symbol: ''),
                              textAlign: TextAlign.end,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            )),
                          ],
                        ),
                      ),
                    ],
                  ),
                  //
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //   children: [
                  //     Text('Total Harga',
                  //         style: TextStyle(
                  //             fontWeight: FontWeight.bold,
                  //             color: Constant.primaryColor)),
                  //     Text(
                  //       formatCurrency(data?.ParentOrderModel?.total ?? '0'),
                  //       style: TextStyle(
                  //         fontWeight: FontWeight.bold,
                  //         color: Colors.red,
                  //       ),
                  //     ),
                  //   ],
                  // ),
                ],
              ),
            ),
            SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: buildBottomBar(),
    );
  }

  Widget buildBottomBar() {
    return Container(
      padding: EdgeInsets.all(8.0),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: SizedBox(
              height: 48, // Same height as chat button
              child: ElevatedButton(
                onPressed: () {
                  if (data?.ParentOrderModel?.tglTtdSuratPesanan == null) {
                    // showTtdDialog(context);
                  } else {}
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(
                      Icons.clear,
                      color: Colors.white,
                      size: 14,
                    ),
                    Text('Tolak Pesanan',
                        style: TextStyle(color: Colors.white)),
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
          SizedBox(width: 8),
          Expanded(
            child: SizedBox(
              height: 48, // Same height as chat button
              child: ElevatedButton(
                onPressed: () {
                  if (data?.ParentOrderModel?.tglTtdSuratPesanan == null) {
                    // showTtdDialog(context);
                  } else {}
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 14,
                    ),
                    Text('Terima Pesanan',
                        style: TextStyle(color: Colors.white)),
                  ],
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF1ABC62),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String formatCurrency(String amount) {
    // Mengonversi string ke integer
    int value = int.parse(amount);

    // Membuat format untuk Rupiah
    final formatCurrency =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);

    // Mengonversi integer ke format mata uang
    return formatCurrency.format(value);
  }
}
