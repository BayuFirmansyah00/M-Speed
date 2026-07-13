import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mspeed/common/base/base_state.dart';
import 'package:mspeed/common/component/custom_appbar.dart';
import 'package:mspeed/common/component/custom_button.dart';
import 'package:mspeed/common/component/custom_navigator.dart';
import 'package:mspeed/common/component/image_network_widget.dart';
import 'package:mspeed/common/helper/Constant.dart';
import 'package:mspeed/common/helper/safe_network_image.dart';
import 'package:mspeed/generated/assets.dart';
import 'package:mspeed/src/buyer/transaction/provider/transaction_status.dart';
import 'package:mspeed/src/seller/chat/view/chat_pesanan_komplain_view.dart';
import 'package:mspeed/src/seller/pesanan/model/detail_pesanan_seller_model.dart';
import 'package:mspeed/src/seller/pesanan/provider/seller_pesanan_provider.dart';
import 'package:mspeed/src/seller/pesanan/view/cetak_surat_view.dart';
import 'package:mspeed/src/seller/pesanan/view/pesanan_buat_surat_view.dart';
import 'package:mspeed/src/seller/pesanan/view/upload_lampiran_view.dart';
import 'package:mspeed/src/seller/pesanan/widget/reject_order_widget.dart';
import 'package:mspeed/src/seller/pesanan/widget/transaction_status_stepper.dart';
import 'package:mspeed/src/seller/produk/provider/produk_seller_provider.dart';
import 'package:mspeed/utils/utils.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';

class PesananSellerDetailView extends StatefulWidget {
  final String transaction_id;

  const PesananSellerDetailView({super.key, required this.transaction_id});

  @override
  State<PesananSellerDetailView> createState() =>
      _PesananSellerDetailViewState();
}

class _PesananSellerDetailViewState extends BaseState<PesananSellerDetailView> {
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
    userId = "148";

    context.read<SellerPesananProvider>().reset();
    refresh();
    await requestPermission(Permission.manageExternalStorage);
    await requestPermission(Permission.photos);
    await requestPermission(Permission.storage);
  }

  void refresh() {
    context.read<SellerPesananProvider>().fetchDetailPesanan(
      parent_id: widget.transaction_id,
      withLoading: true,
    );
  }

  Future<bool> requestPermission(Permission permission) async {
    PermissionStatus status = await permission.request();
    return [
      PermissionStatus.granted,
      PermissionStatus.limited,
    ].contains(status);
  }

  Future<void> showSuccessDialog(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 60),
                    SizedBox(height: 10),
                    Text(
                      'Berhasil',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              Divider(),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  refresh();
                },
                child: Text(
                  'Oke',
                  style: TextStyle(
                    color: Constant.primaryColor,
                    fontWeight: FontWeight.w400,
                    fontSize: 20,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  DetailPesananSellerModelData? dataSeller = DetailPesananSellerModelData();
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final data =
        context.watch<SellerPesananProvider>().detailPesananSellerModel;
    final productExpanded =
        context.watch<ProdukSellerProvider>().productExpanded;
    final p = context.read<SellerPesananProvider>();
    dataSeller = data.data;
    if (p.isTtdSuccess == true) {
      p.isTtdSuccess = null;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await showSuccessDialog(context);
        refresh();
      });
    }

    List<Widget> showListItems() {
      List<Widget> list = [];
      final length = 3;
      if (length == 0) {
        return [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                "tidak ada data",
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
                Align(
                  alignment: Alignment.topLeft,
                  child: Checkbox(value: i % 2 == 0, onChanged: (_) {}),
                ),
                ImageNetworkWidget(
                  width: 50,
                  height: 50,
                  radius: 12,
                  imageUrl: '',
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'A',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      Text(
                        'B',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: Constant.grayColor,
                        ),
                      ),
                      Text(
                        'C',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }

      return list;
    }

    Widget grayDivider() {
      return Container(
        color: Color(0xFFF6F6F6),
        height: 8,
        width: double.infinity,
      );
    }

    Widget detailInfo() {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
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
                  dataSeller?.ParentOrderModel?.nomorOrder ?? '-',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
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
                  dataSeller?.ParentOrderModel?.Created ?? '-',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
                ),
              ],
            ),
            // SizedBox(height: 16),
            // Row(
            //   crossAxisAlignment: CrossAxisAlignment.start,
            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //   children: [
            //     Text(
            //       'Departemen',
            //       style: TextStyle(
            //         color: Colors.grey,
            //         fontSize: 12,
            //         fontWeight: FontWeight.w400,
            //       ),
            //     ),
            //     Text(
            //       dataSeller?.NamaDepartment ?? '-',
            //       style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
            //     ),
            //   ],
            // ),
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
                    dataSeller?.ParentOrderModel?.alamat ?? '-',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
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
                  dataSeller?.ParentOrderModel?.SellerNama ?? '-',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
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
                    dataSeller?.ParentOrderModel?.alamat ?? '-',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
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
                  dataSeller?.ParentOrderModel?.nama ?? '-',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
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
                  dataSeller?.ParentOrderModel?.telp ?? '-',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
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
                    '${dataSeller?.ParentOrderModel?.estPengiriman != "0000-00-00" ? DateFormat('d MMMM yyyy').format(DateTime.parse(dataSeller?.ParentOrderModel?.estPengiriman ?? "0000-00-00")) : ''} - ${dataSeller?.ParentOrderModel?.estPengiriman2 != "0000-00-00" ? DateFormat('d MMMM yyyy').format(DateTime.parse(dataSeller?.ParentOrderModel?.estPengiriman2 ?? "0000-00-00")) : ''}',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            // Row(
            //   crossAxisAlignment: CrossAxisAlignment.start,
            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //   children: [
            //     Text(
            //       'DPP',
            //       style: TextStyle(
            //         color: Colors.grey,
            //         fontSize: 12,
            //         fontWeight: FontWeight.w400,
            //       ),
            //     ),
            //     SizedBox(width: 20),
            //     Expanded(
            //       child: Text(
            //         '${dataSeller?.ParentOrderModel?.nomorDpp ?? ''}${dataSeller?.ParentOrderModel?.dpp != null ? ' - ${dataSeller?.ParentOrderModel?.dpp}' : ''}',
            //         style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
            //         maxLines: 2,
            //         overflow: TextOverflow.ellipsis,
            //         textAlign: TextAlign.end,
            //       ),
            //     ),
            //   ],
            // ),
          ],
        ),
      );
    }

    // Widget ringkasan() {
    //   return Padding(
    //     padding: const EdgeInsets.all(16.0),
    //     child: Column(
    //       crossAxisAlignment: CrossAxisAlignment.start,
    //       children: [
    //         Text('Ringkasan', style: TextStyle(fontWeight: FontWeight.bold)),
    //         SizedBox(height: 12),
    //         Row(
    //           crossAxisAlignment: CrossAxisAlignment.start,
    //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //           children: [
    //             Text(
    //               'No Pesanan',
    //               style: TextStyle(
    //                 color: Colors.grey,
    //                 fontSize: 12,
    //                 fontWeight: FontWeight.w400,
    //               ),
    //             ),
    //             Constant.xSizedBox16,
    //             Text(
    //               dataSeller?.ParentOrderModel?.nomorOrder ?? "-",
    //               textAlign: TextAlign.right,
    //               style: TextStyle(
    //                 color: Constant.primaryColor,
    //                 fontSize: 14,
    //                 fontWeight: FontWeight.w600,
    //               ),
    //             ),
    //           ],
    //         ),
    //         SizedBox(height: 16),
    //         Row(
    //           crossAxisAlignment: CrossAxisAlignment.start,
    //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //           children: [
    //             Text(
    //               'Tanggal Pesanan',
    //               style: TextStyle(
    //                 color: Colors.grey,
    //                 fontSize: 12,
    //                 fontWeight: FontWeight.w400,
    //               ),
    //             ),
    //             Constant.xSizedBox16,
    //             Text(
    //               dataSeller?.ParentOrderModel?.Created ?? "-",
    //               textAlign: TextAlign.right,
    //               style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
    //             ),
    //           ],
    //         ),
    //         SizedBox(height: 16),
    //         Row(
    //           crossAxisAlignment: CrossAxisAlignment.start,
    //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //           children: [
    //             Text(
    //               'Total Pesanan',
    //               style: TextStyle(
    //                 color: Colors.grey,
    //                 fontSize: 12,
    //                 fontWeight: FontWeight.w400,
    //               ),
    //             ),
    //             Constant.xSizedBox16,
    //             Text(
    //               formatCurrency(dataSeller?.ParentOrderModel?.total ?? "0"),
    //               textAlign: TextAlign.right,
    //               style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
    //             ),
    //           ],
    //         ),
    //         SizedBox(height: 16),
    //         Row(
    //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //           children: [
    //             Text(
    //               'Status Pesanan',
    //               style: TextStyle(
    //                 color: Colors.grey,
    //                 fontSize: 12,
    //                 fontWeight: FontWeight.w400,
    //               ),
    //             ),
    //             Constant.xSizedBox16,
    //             Text(
    //               dataSeller?.ParentOrderModel?.status?.replaceAll('_', ' ') ??
    //                   "-",
    //               style: TextStyle(
    //                 fontSize: 14,
    //                 fontWeight: FontWeight.w400,
    //                 color: Constant.statusColor(
    //                   dataSeller?.ParentOrderModel?.status ?? "-",
    //                 ),
    //               ),
    //             ),
    //           ],
    //         ),
    //       ],
    //     ),
    //   );
    // }

    // Widget infoPengiriman() {
    //   return Padding(
    //     padding: const EdgeInsets.all(16.0),
    //     child: Column(
    //       crossAxisAlignment: CrossAxisAlignment.start,
    //       children: [
    //         InkWell(
    //           onTap: () {
    //             CusNav.nPush(context, UploadLampiranView(data: data));
    //           },
    //           child: Text(
    //             'Info Pengiriman',
    //             style: TextStyle(fontWeight: FontWeight.bold),
    //           ),
    //         ),
    //         SizedBox(height: 12),
    //         Row(
    //           crossAxisAlignment: CrossAxisAlignment.start,
    //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //           children: [
    //             Expanded(
    //               child: Text(
    //                 'PIC Penerima',
    //                 style: TextStyle(
    //                   color: Colors.grey,
    //                   fontSize: 12,
    //                   fontWeight: FontWeight.w400,
    //                 ),
    //               ),
    //             ),
    //             Constant.xSizedBox16,
    //             Expanded(
    //               child: Text(
    //                 dataSeller?.ParentOrderModel?.nama ?? "-",
    //                 textAlign: TextAlign.right,
    //                 style: TextStyle(
    //                   color: Constant.primaryColor,
    //                   fontSize: 14,
    //                   fontWeight: FontWeight.w600,
    //                 ),
    //               ),
    //             ),
    //           ],
    //         ),
    //         SizedBox(height: 16),
    //         Row(
    //           crossAxisAlignment: CrossAxisAlignment.start,
    //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //           children: [
    //             Expanded(
    //               child: Text(
    //                 'Alamat Pengiriman',
    //                 style: TextStyle(
    //                   color: Colors.grey,
    //                   fontSize: 12,
    //                   fontWeight: FontWeight.w400,
    //                 ),
    //               ),
    //             ),
    //             Constant.xSizedBox16,
    //             Expanded(
    //               child: Text(
    //                 dataSeller?.ParentOrderModel?.alamat ?? "-",
    //                 textAlign: TextAlign.right,
    //                 style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
    //               ),
    //             ),
    //           ],
    //         ),
    //         SizedBox(height: 16),
    //         Row(
    //           crossAxisAlignment: CrossAxisAlignment.start,
    //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //           children: [
    //             Expanded(
    //               child: Text(
    //                 'Estimasi Tanggal Pengiriman',
    //                 style: TextStyle(
    //                   color: Colors.grey,
    //                   fontSize: 12,
    //                   fontWeight: FontWeight.w400,
    //                 ),
    //               ),
    //             ),
    //             Constant.xSizedBox16,
    //             Expanded(
    //               child: Text(
    //                 '${dataSeller?.ParentOrderModel?.estPengiriman ?? "-"} - ${dataSeller?.ParentOrderModel?.estPengiriman2 ?? '-'}',
    //                 textAlign: TextAlign.right,
    //                 style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
    //               ),
    //             ),
    //           ],
    //         ),
    //         SizedBox(height: 16),
    //       ],
    //     ),
    //   );
    // }

    Widget detailProduk() {
      int total = data.data?.detail?.length ?? 0;
      int collapsedCount = total > 2 ? 2 : total;

      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Detail Produk',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
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
                          url: data.data?.detail?[i]?.foto ?? '',
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
                          Text(data.data?.detail?[i]?.nama ?? '-'),
                          Constant.xSizedBox4,
                          Text(
                            data.data?.detail?[i]?.hargaAkhir != null
                                ? '${data.data?.detail?[i]?.qty ?? '1'} x ${formatCurrency(data.data?.detail?[i]?.hargaAkhir ?? '0')}'
                                : '${data.data?.detail?[i]?.qty ?? '1'} x ${formatCurrency(data.data?.detail?[i]?.harga ?? '0')}',
                            style: TextStyle(
                              color: Constant.textColor2,
                              fontSize: 12,
                            ),
                          ),
                          SizedBox(height: 4),
                          if (data.data?.detail?[i]?.dikomplain == 'YES')
                            InkWell(
                              onTap: () async {
                                CusNav.nPush(
                                  context,
                                  ChatPesananKomplainView(
                                    orderId:
                                        data.data?.detail?[i]?.IDOrder ?? '',
                                    penerimaId:
                                        data
                                            .data
                                            ?.ParentOrderModel
                                            ?.penerimaID ??
                                        '',
                                  ),
                                );
                              },
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.history,
                                    color: Constant.primaryColor,
                                    size: 12,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'Dikomplain',
                                    style: TextStyle(
                                      color: Constant.primaryColor,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
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
                          Text(
                            'Total Harga',
                            style: TextStyle(
                              fontSize: 12,
                              color: Constant.textColor2,
                            ),
                          ),
                          Constant.xSizedBox8,
                          Text(
                            Utils.thousandSeparator(
                              int.parse(
                                data.data?.detail?[i]?.hargaAkhir ?? '0',
                              ),
                            ),
                            style: TextStyle(fontSize: 12),
                          ),
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
                context.read<ProdukSellerProvider>().productExpanded =
                    !productExpanded;
                setState(() {});
              },
              child: Container(
                padding: EdgeInsets.all(20),
                child: Center(
                  child: Text(
                    '${productExpanded ? "Sembunyikan" : "Tampilkan"} Produk Lainnya',
                    style: TextStyle(fontSize: 12, color: Constant.textColor2),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    Widget ringkasanHarga() {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ringkasan', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Subtotal',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                Constant.xSizedBox16,
                Expanded(
                  child: Text(
                    Utils.thousandSeparator(
                      double.parse(
                        dataSeller?.ParentOrderModel?.subtotal ?? '0',
                      ).toInt(),
                    ),
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: Constant.primaryColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Ongkos Kirim',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                Constant.xSizedBox16,
                Expanded(
                  child: Text(
                    Utils.thousandSeparator(
                      int.parse(dataSeller?.ParentOrderModel?.ongkir ?? '0'),
                    ),
                    textAlign: TextAlign.right,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Pajak',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                Constant.xSizedBox16,
                Expanded(
                  child: Text(
                    Utils.thousandSeparator(
                      int.parse(dataSeller?.ParentOrderModel?.pajak ?? '0'),
                    ),
                    textAlign: TextAlign.right,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Total Harga',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                Constant.xSizedBox16,
                Expanded(
                  child: Text(
                    Utils.thousandSeparator(
                      int.parse(dataSeller?.ParentOrderModel?.total ?? '0'),
                    ),
                    textAlign: TextAlign.right,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
          ],
        ),
      );
    }

    /*
    1. status == PESANAN_BARU && ttd_pesanan_buyer == null
  - Buyer - Tombol ttd surat jalan muncul
  2. status == PESANAN_BARU && ttd_pesanan_buyer != null
    - Seller - Tombol terima dan tolak muncul  \\
  3. status == PESANAN_DITERIMA && ttd_pesanan_buyer != null && ttd_pesanan_seller != null
    - Seller - Tombol ttd surat pesanan muncul  \\
  4. status != PESANAN_DITERIMA && ttd_pesanan_buyer != null && ttd_pesanan_seller != null
    - Seller - Tombol cetak surat pesanan muncul
  5. (status == PESANAN_DITERIMA || status == PESANAN_DIKIRIM) && ttd_suratjalan_seller == null
    - Seller - Tombol buat surat jalan muncul \\
  6. ttd_suratjalan_seller != null
    - Seller - Tombol cetak surat jalan muncul //
  7. status == PESANAN_DITERIMA && ttd_pesanan_buyer != null && ttd_pesanan_seller != null && ttd_suratjalan_seller != null
    - Seller - Tombol kirim barang muncul //
  8. ttd_suratjalan_seller != null && ttd_suratjalan_penerima == null (dan checkbox terima barang sudah dicentang semua)
    - Penerima - Tombol ttd surat jalan muncul
  9. ttd_suratjalan_seller != null && ttd_suratjalan_penerima != null
    - Penerima - Button cetak surat muncul
  10. (status == PESANAN_TELAH_DITERIMA || status == TELAH_DIBAYAR) && lampiran == null
    - Seller - Button upload lampiran tagihan muncul //
  11. status != TELAH_DIBAYAR
    - Keuangan - Button Lanjutkan pembayaran muncul
     */
    Widget handleBottom() {
      final status = dataSeller?.ParentOrderModel?.status;
      if (status == null)
        return Container(
          width: double.infinity, // Or a specific width if needed
          height: double.infinity, // Or a specific height if needed
          child: Stack(
            children: [
              // Your other widgets here
              Align(
                alignment: Alignment.bottomCenter, // Align to the bottom center
                child: SizedBox(
                  height: 32,
                  width: 32,
                  child: CircularProgressIndicator(),
                ),
              ),
            ],
          ),
        );

      final ttdPesananBuyer = dataSeller?.ParentOrderModel?.ttdPesananBuyer;
      if (status == 'PESANAN_DITOLAK') {
        return SizedBox();
      }
      if (status == "PESANAN_BARU") {
        return bottomPesananBaru(data);
      }

      return bottomPesanan(data);
    }

    List<Widget> status() {
      final list = dataSeller?.timeline ?? [];
      if (list.isEmpty) return [SizedBox()];
      final length =
          p.showMore ? list.length : (list.length >= 3 ? 3 : list.length);
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
              context.read<SellerPesananProvider>().showMore = !p.showMore;
              setState(() {});
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
              child: Center(
                child: Text(
                  'Tampilkan Lebih ${p.showMore ? 'Sedikit' : 'Banyak'}',
                  style: TextStyle(color: Constant.redColor, fontSize: 12),
                ),
              ),
            ),
          ),
        );
      return widgets;
    }

    Widget statusW() {
      if (dataSeller?.ParentOrderModel?.status != "PESANAN_DITOLAK")
        return Container(
          color: Color(0xFFFEF9F4),
          padding: EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 20),
          child: Column(
            children: [
              if (dataSeller?.timeline?.isNotEmpty ?? false) ...[
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
          refresh();
        },
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order Info
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
                            color: Constant.statusColor(dataSeller?.ParentOrderModel?.status ?? "-").withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            (dataSeller?.ParentOrderModel?.status ?? "-").replaceAll('_', ' '),
                            style: TextStyle(
                              color: Constant.statusColor(dataSeller?.ParentOrderModel?.status ?? "-") == Colors.black ? Colors.grey : Constant.statusColor(dataSeller?.ParentOrderModel?.status ?? "-"),
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
                          dataSeller?.ParentOrderModel?.nomorOrder ?? '-',
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
                          dataSeller?.ParentOrderModel?.Created ?? '-',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    // Row(
                    //   crossAxisAlignment: CrossAxisAlignment.start,
                    //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //   children: [
                    //     Text(
                    //       'Departemen',
                    //       style: TextStyle(
                    //         color: Colors.grey,
                    //         fontSize: 12,
                    //         fontWeight: FontWeight.w400,
                    //       ),
                    //     ),
                    //     Text(
                    //       data?.NamaDepartment ?? '-',
                    //       style: TextStyle(
                    //         fontSize: 14,
                    //         fontWeight: FontWeight.w400,
                    //       ),
                    //     ),
                    //   ],
                    // ),
                    // SizedBox(height: 16),
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
                            dataSeller?.ParentOrderModel?.alamat ?? '-',
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
                          dataSeller?.ParentOrderModel?.SellerNama ?? '-',
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
                            dataSeller?.ParentOrderModel?.alamat ?? '-',
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
                          dataSeller?.ParentOrderModel?.nama ?? '-',
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
                          dataSeller?.ParentOrderModel?.telp ?? '-',
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
                            '${dataSeller?.ParentOrderModel?.estPengiriman != "0000-00-00" ? DateFormat('d MMMM yyyy').format(DateTime.parse(dataSeller?.ParentOrderModel?.estPengiriman ?? "0000-00-00")) : ''} - ${dataSeller?.ParentOrderModel?.estPengiriman2 != "0000-00-00" ? DateFormat('d MMMM yyyy').format(DateTime.parse(dataSeller?.ParentOrderModel?.estPengiriman2 ?? "0000-00-00")) : ''}',
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
                    // SizedBox(height: 16),
                    // Row(
                    //   crossAxisAlignment: CrossAxisAlignment.start,
                    //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //   children: [
                    //     Text(
                    //       'DPP',
                    //       style: TextStyle(
                    //         color: Colors.grey,
                    //         fontSize: 12,
                    //         fontWeight: FontWeight.w400,
                    //       ),
                    //     ),
                    //     SizedBox(width: 20),
                    //     Expanded(
                    //       child: Text(
                    //         '${dataSeller?.ParentOrderModel?.nomorDpp ?? ''}${dataSeller?.ParentOrderModel?.dpp != null ? ' - ${dataSeller?.ParentOrderModel?.dpp}' : ''}',
                    //         style: TextStyle(
                    //           fontSize: 14,
                    //           fontWeight: FontWeight.w400,
                    //         ),
                    //         maxLines: 2,
                    //         overflow: TextOverflow.ellipsis,
                    //         textAlign: TextAlign.end,
                    //       ),
                    //     ),
                    //   ],
                    // ),
                  ],
                ),
              ),
              // ringkasan(),
              // grayDivider(),
              // infoPengiriman(),
              grayDivider(),
              detailProduk(),
              grayDivider(),
              ringkasanHarga(), // Order Summary
              grayDivider(), // Order Summary
            ],
          ),
        ),
      ),
      bottomNavigationBar: handleBottom(),
    );
  }

  void showAlasanTolakPesananDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: RejectOrderWidget(
            onSave: () async {
              final p = context.read<SellerPesananProvider>();
              final data = p.detailPesananSellerModel.data?.ParentOrderModel;
              final success = await p.fetchActionPesananBaru(
                parent_id: data?.ID ?? '',
                terima: false,
                withLoading: true,
              );

              if (success) {
                refresh();
                await Utils.showSuccess(msg: "Berhasil Tolak Pesanan!");
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

  Widget bottomPesananBaru(DetailPesananSellerModel data) {
    return Container(
      height: kBottomNavigationBarHeight + 24,
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(color: Colors.white),
      child: Row(
        children: [
          Expanded(
            child: CustomButton.mainButtonWithIcon2(
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Icon(Icons.close, color: Colors.white, weight: 10),
              ),
              'Tolak',
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              () async {
                await Utils.showYesNoDialog(
                  context: context,
                  title: 'Konfirmasi Pesanan',
                  desc: 'Apakah Anda yakin ingin tolak pesanan ini?',
                  yesCallback: () async {
                    CusNav.nPop(context);
                    showAlasanTolakPesananDialog(context);
                  },
                  noCallback: () {
                    CusNav.nPop(context);
                  },
                );
              },
              textStyle: TextStyle(
                fontWeight: Constant.bold,
                color: Colors.white,
              ),
              contentPadding: EdgeInsets.symmetric(vertical: 8),
              color: Color(0xffED1C24),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          Constant.xSizedBox12,
          Expanded(
            child: CustomButton.mainButtonWithIcon2(
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Icon(Icons.check, color: Colors.white, weight: 10),
              ),
              'Terima',
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              () async {
                await Utils.showYesNoDialog(
                  context: context,
                  title: 'Konfirmasi Pesanan',
                  desc: 'Apakah Anda yakin ingin Terima Pesanan ini?',
                  yesCallback: () async {
                    CusNav.nPop(context);
                    final p = context.read<SellerPesananProvider>();
                    p.fetchActionPesananBaru(
                      terima: true,
                      parent_id: dataSeller?.ParentOrderModel?.ID ?? '',
                    );
                  },
                  noCallback: () {
                    CusNav.nPop(context);
                  },
                );
              },
              textStyle: TextStyle(
                fontWeight: Constant.bold,
                color: Colors.white,
              ),
              contentPadding: EdgeInsets.symmetric(vertical: 8),
              color: Color(0xff1ABC62),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ],
      ),
    );
  }

  Widget suratJalan(DetailPesananSellerModel data) {
    final status = dataSeller?.ParentOrderModel?.status ?? '';
    final lampiran = dataSeller?.ParentOrderModel?.lampiran;
    final ttdSuratjalanSeller =
        dataSeller?.ParentOrderModel?.ttdSuratjalanSeller;

    if ((status == 'PESANAN_DITERIMA' || status == 'PESANAN_DIKIRIM') &&
        ttdSuratjalanSeller == null) {
      print('SIKLUS: 5');

      return Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: CustomButton.mainButtonWithIcon2(
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Icon(Icons.check, color: Colors.white, weight: 10),
            ),
            'Buat Surat Jalan',
            textStyle: TextStyle(color: Colors.white),
            () async {
              CusNav.nPush(
                context,
                PesananBuatSuratView(
                  data: data,
                  suratType: SuratType.SURAT_JALAN,
                ),
              );
            },
            mainAxisAlignment: MainAxisAlignment.start,
            contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            color: Color(0xffED1C24),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }

    if ((status == 'PESANAN_TELAH_DITERIMA' || status == 'TELAH_DIBAYAR') &&
        lampiran == null) {
      print('SIKLUS: 10');

      return Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: CustomButton.mainButtonWithIcon2(
            Icon(Icons.print_outlined, color: Colors.white, weight: 10),
            'Buat Tagihan',
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            () {
              CusNav.nPush(context, UploadLampiranView(data: data));
            },
            textStyle: TextStyle(color: Colors.white),
            contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            color: Color(0xffED1C24),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }

    if (ttdSuratjalanSeller != null) {
      print('SIKLUS: 6');

      return Expanded(
        child: CustomButton.mainButtonWithIcon2(
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Icon(Icons.print_outlined, color: Colors.white, weight: 10),
          ),
          'Cetak Surat Jalan',
          () async {
            final pdf = await context.read<SellerPesananProvider>().getPdf(
              pdf: PDF_LINK.SURAT_JALAN,
              transaction_id: dataSeller?.ParentOrderModel?.ID ?? '',
            );
            CusNav.nPush(
              context,
              CetakSuratView(
                pdfUrl: pdf.toString(),
                title: 'Cetak Surat Jalan',
              ),
            );
          },
          mainAxisAlignment: MainAxisAlignment.start,
          textStyle: TextStyle(color: Colors.white),
          contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          color: Color(0xff1ABC62),
          borderRadius: BorderRadius.circular(10),
        ),
      );
    }

    return SizedBox();
  }

  Widget suratPesanan(DetailPesananSellerModel data) {
    final status = dataSeller?.ParentOrderModel?.status ?? '';
    final ttdSuratpesananSeller =
        dataSeller?.ParentOrderModel?.ttdPesananSeller;
    final ttdSuratPesananBuyer = dataSeller?.ParentOrderModel?.ttdPesananBuyer;

    if (status == 'PESANAN_DITERIMA' &&
        ttdSuratPesananBuyer != null &&
        ttdSuratpesananSeller == null) {
      print('SIKLUS: 3');

      return Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: CustomButton.mainButtonWithIcon2(
            Icon(Icons.check, color: Colors.white, weight: 10),
            'Buat Surat Pesanan',
            mainAxisAlignment: MainAxisAlignment.start,
            () async {
              CusNav.nPush(
                context,
                PesananBuatSuratView(
                  data: data,
                  suratType: SuratType.SURAT_PESANAN,
                ),
              );
            },
            flexText: 9,
            stretched: true,
            textStyle: TextStyle(color: Colors.white),
            contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            color: Constant.primaryColor,
            textAlign: TextAlign.center,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }

    if (ttdSuratPesananBuyer != null && ttdSuratpesananSeller != null) {
      print('SIKLUS: 4');

      return Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: CustomButton.mainButtonWithIcon2(
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Icon(
                Icons.print_outlined,
                color: Colors.white,
                weight: 10,
              ),
            ),
            'Cetak Surat Pesanan',
            () async {
              final pdf = await context.read<SellerPesananProvider>().getPdf(
                pdf: PDF_LINK.SURAT_PESANAN,
                transaction_id: dataSeller?.ParentOrderModel?.ID ?? '',
              );
              CusNav.nPush(
                context,
                CetakSuratView(
                  pdfUrl: pdf.toString(),
                  title: 'Cetak Surat Jalan',
                ),
              );
            },
            mainAxisAlignment: MainAxisAlignment.start,
            textStyle: TextStyle(color: Colors.white),
            contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            color: Color(0xff1ABC62),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }

    return SizedBox();
  }

  Widget bottomPesanan(DetailPesananSellerModel data) {
    final status = dataSeller?.ParentOrderModel?.status ?? '';
    final ttdSuratJalanSeller =
        dataSeller?.ParentOrderModel?.ttdSuratjalanSeller;
    final ttdPesananBuyer = dataSeller?.ParentOrderModel?.ttdPesananBuyer;
    final ttdPesananSeller = dataSeller?.ParentOrderModel?.ttdPesananSeller;

    final isKirimBarang =
        status == 'PESANAN_DITERIMA' &&
        ttdSuratJalanSeller != null &&
        ttdPesananBuyer != null &&
        ttdPesananSeller != null;

    if (isKirimBarang) print('SIKLUS: 10');

    return Container(
      height: kBottomNavigationBarHeight + (isKirimBarang ? 80 : 24),
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(color: Colors.white),
      child: Column(
        children: [
          Row(children: [suratPesanan(data), suratJalan(data)]),
          if (isKirimBarang) ...[
            Constant.xSizedBox8,
            Expanded(
              child: CustomButton.mainButton(
                'Kirim Barang',
                textStyle: TextStyle(color: Colors.white),
                () async {
                  if (await context.read<SellerPesananProvider>().kirimBarang(
                    parent_id: dataSeller?.ParentOrderModel?.ID ?? '',
                  ))
                    context.showSuccessDialog();
                },
                padding: EdgeInsets.zero,
                contentPadding: EdgeInsets.symmetric(vertical: 0),
                color: Color(0xffED1C24),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String formatCurrency(String amount) {
    int value = int.parse(amount);
    final formatCurrency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );
    return formatCurrency.format(value);
  }

  int statusCompare(String s1, String s2) {
    final t1 = TransactionStatus.fromString(s1);
    final t2 = TransactionStatus.fromString(s2);
    return t1.index.compareTo(t2.index);
  }
}
