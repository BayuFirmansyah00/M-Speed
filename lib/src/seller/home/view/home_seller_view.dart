import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mspeed/common/base/base_state.dart';
import 'package:mspeed/common/component/custom_button.dart';
import 'package:mspeed/common/component/custom_dropdown.dart';
import 'package:mspeed/common/component/custom_navigator.dart';
import 'package:mspeed/common/helper/constant.dart';
import 'package:mspeed/common/helper/safe_network_image.dart';
import 'package:mspeed/generated/assets.dart';
import 'package:mspeed/src/seller/chat/view/chat_list_seller_view.dart';
import 'package:mspeed/src/seller/home/model/home_seller_model.dart' as s;
import 'package:mspeed/src/seller/home/model/home_seller_model.dart';
import 'package:mspeed/src/seller/home/view/home_seller_graph_view.dart';
import 'package:mspeed/src/seller/notifikasi/provider/notifikasi_seller_provider.dart';
import 'package:mspeed/src/seller/notifikasi/view/notifikasi__seller_view.dart';
import 'package:mspeed/src/seller/profil/provider/profile_seller_provider.dart';
import 'package:mspeed/src/seller/profil/view/profile_seller_view.dart';
import 'package:mspeed/utils/utils.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../provider/seller_home_provider.dart';

class HomeSellerView extends StatefulWidget {
  final VoidCallback jumpToPesanan;

  const HomeSellerView({super.key, required this.jumpToPesanan});
  @override
  State<HomeSellerView> createState() => _HomeSellerViewState();
}

class _HomeSellerViewState extends BaseState<HomeSellerView> {
  final scrollController = ScrollController();
  bool isCollapsed = false;

  @override
  void initState() {
    getData();
    super.initState();
    scrollController.addListener(() {
      if (scrollController.offset > 200 && !isCollapsed) {
        setState(() {
          isCollapsed = true;
        });
      } else if (scrollController.offset <= 200 && isCollapsed) {
        setState(() {
          isCollapsed = false;
        });
      }
    });
    final p = context.read<SellerHomeProvider>();
    List<String> years = List.generate(
      2024 - 1900 + 1,
      (index) => (1900 + index).toString(),
    );
    for (int i = years.length - 1; i >= 0; i--) {
      p.timeList?.add(years[i]);
    }
    context.read<NotifikasiSellerProvider>().fetchNotification(
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

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  Future<void> getData() async {
    Utils.showLoading();
    await context.read<ProfileSellerProvider>().fetchProfile(
      context,
      withLoading: false,
    );
    await context.read<SellerHomeProvider>().fetchSellerHome(
      withLoading: false,
    );
    Utils.dismissLoading();
    // await requestPermission(Permission.location);
    // await requestPermission(Permission.accessMediaLocation);
    // await requestPermission(Permission.manageExternalStorage);
    // await requestPermission(Permission.photos);
    // await requestPermission(Permission.storage);
    if (Platform.isAndroid) {
      await requestPermission(Permission.manageExternalStorage);
      await requestPermission(Permission.storage);
    } else if (Platform.isIOS) {}
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<SellerHomeProvider>();
    final data = context.watch<SellerHomeProvider>().homeSellerModel?.data;
    final notifP = context.watch<NotifikasiSellerProvider>();
    final profileP = context.watch<ProfileSellerProvider>();
    // final tableOrderNew = context
    //     .watch<SellerHomeProvider>()
    //     .homeSellerModel
    //     ?.data
    //     ?.tablePesananTerbaru;
    final tableMostBuy =
        context
            .watch<SellerHomeProvider>()
            .homeSellerModel
            ?.data
            ?.tablePalingLaris;

    Widget headerInfoItem({
      required String title,
      required String subtitle,
      required List<Color> gradientColors,
      required IconData icon,
    }) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: gradientColors.last.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: Colors.white, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      );
    }

    Widget headerInfo() {
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
        child: Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  headerInfoItem(
                    title: 'Total Produk',
                    subtitle: data?.produk ?? '0',
                    gradientColors: const [
                      Color(0xff0D9488),
                      Color(0xff14B8A6),
                    ],
                    icon: Icons.inventory_2_rounded,
                  ),
                  Constant.xSizedBox16,
                  headerInfoItem(
                    title: 'Total Pendapatan',
                    subtitle: Utils.thousandSeparator(
                      int.parse(data?.totalPendapatan ?? '0'),
                    ),
                    gradientColors: const [
                      Color(0xff059669),
                      Color(0xff10B981),
                    ],
                    icon: Icons.account_balance_wallet_rounded,
                  ),
                ],
              ),
            ),
            Constant.xSizedBox16,
            Expanded(
              child: Column(
                children: [
                  headerInfoItem(
                    title: 'Permintaan Pesanan',
                    subtitle: Utils.thousandSeparator(
                      int.parse(data?.totalPermintaanPesanan ?? '0'),
                    ),
                    gradientColors: const [
                      Color(0xffD97706),
                      Color(0xffF59E0B),
                    ],
                    icon: Icons.shopping_cart_rounded,
                  ),
                  Constant.xSizedBox16,
                  headerInfoItem(
                    title: 'Total Belum Lunas',
                    subtitle: Utils.thousandSeparator(
                      int.parse(data?.totalBelumLunas ?? '0'),
                    ),
                    gradientColors: const [
                      Color(0xffE11D48),
                      Color(0xffF43F5E),
                    ],
                    icon: Icons.receipt_long_rounded,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    Widget headerInfoItem2({
      required String icon,
      required String title,
      required String subtitle,
      required List<Color> bgGradient,
      required Color iconBgColor,
      required Color textColor,
    }) {
      return Container(
        height: 145,
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: bgGradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: bgGradient.last.withOpacity(0.15),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Image.asset(icon, width: 28, height: 28),
            ),
            const Spacer(),
            Text(
              title,
              textAlign: TextAlign.left,
              style: TextStyle(
                color: textColor,
                fontSize: 22,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              textAlign: TextAlign.left,
              style: TextStyle(
                color: textColor.withOpacity(0.8),
                fontSize: 12,
                fontWeight: FontWeight.w600,
                height: 1.1,
              ),
            ),
          ],
        ),
      );
    }

    Widget headerInfo2() {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
        child: Row(
          children: [
            Expanded(
              flex: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  headerInfoItem2(
                    icon: Assets.iconsIcPesananBaru,
                    title: '${data?.pesananBaru ?? '0'}',
                    subtitle: 'Pesanan Baru',
                    bgGradient: const [Color(0xffECFDF5), Color(0xffD1FAE5)],
                    iconBgColor: Colors.white,
                    textColor: const Color(0xff065F46),
                  ),
                  Constant.xSizedBox8,
                  headerInfoItem2(
                    icon: Assets.iconsIcBarangDiterima,
                    title: '${data?.barangDiterima ?? 0}',
                    subtitle: 'Barang Diterima',
                    bgGradient: const [Color(0xffDCFCE7), Color(0xffBBF7D0)],
                    iconBgColor: Colors.white,
                    textColor: const Color(0xff16A34A),
                  ),
                ],
              ),
            ),
            Constant.xSizedBox8,
            Expanded(
              flex: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  headerInfoItem2(
                    icon: Assets.iconsIcPesananDiterima,
                    title: '${data?.pesananDiterima ?? 0}',
                    subtitle: 'Pesanan Diterima',
                    bgGradient: const [Color(0xffF0FDF4), Color(0xffBBF7D0)],
                    iconBgColor: Colors.white,
                    textColor: const Color(0xff15803D),
                  ),
                  Constant.xSizedBox8,
                  headerInfoItem2(
                    icon: Assets.iconsIcProsesBayar,
                    title: '${data?.prosesPembayaran ?? 0}',
                    subtitle: 'Proses Bayar',
                    bgGradient: const [Color(0xffECFCCB), Color(0xffD9F99D)],
                    iconBgColor: Colors.white,
                    textColor: const Color(0xff4D7C0F),
                  ),
                ],
              ),
            ),
            Constant.xSizedBox8,
            Expanded(
              flex: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  headerInfoItem2(
                    icon: Assets.iconsIcPesananDikirim,
                    title: '${data?.pesananDikirim ?? '0'}',
                    subtitle: 'Pesanan Dikirim',
                    bgGradient: const [Color(0xffCCFBF1), Color(0xff99F6E4)],
                    iconBgColor: Colors.white,
                    textColor: const Color(0xff0F766E),
                  ),
                  Constant.xSizedBox8,
                  headerInfoItem2(
                    icon: Assets.iconsIcPesananDibayar,
                    title: '${data?.pesananDibayar ?? '0'}',
                    subtitle: 'Pesanan Dibayar',
                    bgGradient: const [Color(0xffCFFAFE), Color(0xffA5F3FC)],
                    iconBgColor: Colors.white,
                    textColor: const Color(0xff0E7490),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Widget newestOrderTitle() {
    //   return Container(
    //     padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
    //     color: Color(0xffDEEDFF),
    //     child: Row(
    //       children: [
    //         Text('No'),
    //         Text('Product'),
    //         Text('No'),
    //         Text('No'),
    //       ],
    //     ),
    //   );
    // }

    Color statusColor(String status) {
      if (status == 'PESANAN_BARU') return Constant.pesananBaruColor;
      if (status == 'PESANAN_DITERIMA') return Constant.pesananDiterimaColor;
      if (status == 'PESANAN_DIKIRIM') return Constant.pesananDikirimColor;
      if (status == 'BARANG_DITERIMA') return Constant.barangDiterimaColor;
      if (status == 'PROSES_PEMBAYARAN') return Constant.prosesPembayaranColor;
      if (status == 'TELAH_DIBAYAR') return Constant.telahDibayarColor;
      if (status == 'PESANAN_DITOLAK') return Constant.pesananDitolakColor;
      return Colors.black;
    }

    TableRow orderItem({
      required int index,
      required HomeSellerModelDataTablePesananTerbaru? data,
    }) {
      String status = (data?.status ?? '')
          .replaceAll('_', ' ')
          .toLowerCase()
          .split(' ')
          .map((word) => word.capitalize())
          .join(' ');
      return TableRow(
        decoration: BoxDecoration(
          color: index % 2 != 0 ? Color(0xffF8F8F8) : Colors.transparent,
        ),
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: 8,
              top: 8,
              right: 8,
              bottom: 8,
            ),
            child: Text(
              '${index + 1}',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xff100629), fontSize: 12),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: 8,
              top: 8,
              right: 8,
              bottom: 8,
            ),
            child: Text(
              '${data?.nomorOrder}',
              textAlign: TextAlign.left,
              style: TextStyle(color: Color(0xff100629), fontSize: 12),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              '${Utils.thousandSeparator(int.parse(data?.total ?? '0'))}',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xff100629), fontSize: 12),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              '${data?.alamat ?? '-'}',
              textAlign: TextAlign.right,
              style: TextStyle(color: Color(0xff100629), fontSize: 12),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 8, right: 4),
            child: Text(
              status,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: statusColor(data?.status ?? ''),
                fontSize: 12,
              ),
            ),
          ),
        ],
      );
    }

    TableRow productItem({
      required int index,
      required s.HomeSellerModelDataTablePalingLaris? data,
    }) {
      return TableRow(
        decoration: BoxDecoration(color: Colors.transparent),
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: 8,
              top: 8,
              right: 8,
              bottom: 8,
            ),
            child: Text(
              '#${index + 1}',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xff100629), fontSize: 12),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              '${data?.nama ?? '-'}',
              textAlign: TextAlign.left,
              style: TextStyle(color: Color(0xff100629), fontSize: 12),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              '${data?.qty ?? '0'}',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xff100629), fontSize: 12),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8, right: 8),
            child: Text(
              Utils.thousandSeparator(int.parse(data?.harga ?? '0')),
              textAlign: TextAlign.right,
              style: TextStyle(color: Color(0xff100629), fontSize: 12),
            ),
          ),
        ],
      );
    }

    List<TableRow> tableNewestOrder() {
      return List.generate(data?.tablePesananTerbaru?.length ?? 0, (i) {
        final item = data?.tablePesananTerbaru?[i];
        return orderItem(index: i, data: item);
      });
    }

    Widget newestOrder() {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Pesanan Terbaru'),
                InkWell(
                  onTap: widget.jumpToPesanan,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Text(
                      'Lihat Semua Pesanan',
                      style: TextStyle(color: Constant.primaryColor),
                    ),
                  ),
                ),
              ],
            ),
            Constant.xSizedBox8,
            Table(
              border: TableBorder.all(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(5),
              ),
              columnWidths: const <int, TableColumnWidth>{
                0: IntrinsicColumnWidth(flex: 0.5),
                1: FlexColumnWidth(),
                2: FlexColumnWidth(),
                3: FlexColumnWidth(),
                4: FlexColumnWidth(),
              },
              defaultVerticalAlignment: TableCellVerticalAlignment.top,
              children: [
                // title
                TableRow(
                  decoration: const BoxDecoration(
                    color: Color(0xffECFDF5),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(8),
                    ),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 8),
                      child: Text(
                        'No',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xff100629),
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 8),
                      child: Text(
                        'No Pesanan',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xff100629),
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 8),
                      child: Text(
                        'Total',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xff100629),
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 8),
                      child: Text(
                        'Alamat',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xff100629),
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 8),
                      child: Text(
                        'Status',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xff100629),
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                // content
                ...tableNewestOrder(),
              ],
            ),
          ],
        ),
      );
    }

    Widget productSellingGraph() {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Jumlah Penjualan Produk'),
            HomeSellerGraphView(),
            Constant.xSizedBox4,
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 30,
                  child: Image.asset(Assets.iconsIcQuantityLegend),
                ),
                Constant.xSizedBox8,
                Text('Quantity', style: TextStyle(color: Color(0xff96A5B8))),
              ],
            ),
          ],
        ),
      );
    }

    List<TableRow> tableMostBuyedProducts() {
      return List.generate(tableMostBuy?.length ?? 0, (i) {
        final item = tableMostBuy?[i];
        return productItem(index: i, data: item);
      });
    }

    Widget mostBuyedProducts() {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Produk Terlaris'),
            Constant.xSizedBox8,
            Table(
              border: TableBorder.all(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(5),
              ),
              columnWidths: const <int, TableColumnWidth>{
                0: IntrinsicColumnWidth(flex: 0.5),
                1: FlexColumnWidth(),
                2: FlexColumnWidth(),
                3: FlexColumnWidth(),
              },
              defaultVerticalAlignment: TableCellVerticalAlignment.top,
              children: [
                // title
                TableRow(
                  decoration: const BoxDecoration(
                    color: Color(0xffF0FDF4),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(8),
                    ),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 8),
                      child: Text(
                        '#',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xff100629),
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 8),
                      child: Text(
                        'Product',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xff100629),
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 8),
                      child: Text(
                        'Sales Qty',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xff100629),
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 8),
                      child: Text(
                        'Amount',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xff100629),
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                // content
                ...tableMostBuyedProducts(),
              ],
            ),
          ],
        ),
      );
    }

    tahunan() async {
      await showCupertinoModalPopup<void>(
        context: context,
        builder: (_) {
          final size = MediaQuery.of(context).size;
          return Container(
            color: Colors.white,
            height: size.height * 0.55,
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: Constant.grayColor.withOpacity(0.5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Per Tahun',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          CusNav.nPop(context);
                        },
                        child: Text(
                          'Batal',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Constant.grayColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Constant.xSizedBox12,
                Container(
                  height: 200.0,
                  child: Flex(
                    direction: Axis.horizontal,
                    children: <Widget>[
                      // Flexible(
                      //   flex: 8,
                      //   child: CupertinoDatePicker(
                      //     mode: CupertinoDatePickerMode.date,
                      //     initialDateTime: p.date,
                      //     onDateTimeChanged: (DateTime dateTime) {
                      //       p.selectedDate = dateTime;
                      //     },
                      //   ),
                      // ),
                      Flexible(
                        flex: 10,
                        child: CupertinoPicker(
                          itemExtent: 38,
                          onSelectedItemChanged: (int index) {
                            setState(() {
                              p.selectedYear = p.timeList![index];
                            });
                          },
                          children:
                              (p.timeList ?? [])
                                  .map(
                                    (item) => Center(
                                      child: Text(
                                        item,
                                        style: TextStyle(fontSize: 20),
                                      ),
                                    ),
                                  )
                                  .toList(),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: CustomButton.mainButton(
                    'Konfirmasi',
                    borderRadius: BorderRadius.circular(10),
                    () async {
                      handleTap(() async {
                        CusNav.nPop(context);
                      });
                    },
                  ),
                ),
              ],
            ),
          );
        },
      );
      // showModalBottomSheet(
      //     context: context,
      //     builder: (BuildContext context) {
      //       return Container(
      //         height: 300,
      //         child: Column(
      //           children: <Widget>[
      //             Row(
      //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //               children: <Widget>[
      //                 CupertinoButton(
      //                   child: Text(
      //                     'Cancel',
      //                     style: TextStyle(color: Colors.grey),
      //                   ),
      //                   onPressed: () {
      //                     Navigator.of(context).pop();
      //                   },
      //                 ),
      //                 CupertinoButton(
      //                   child: Text(
      //                     'Done',
      //                     style: TextStyle(color: Colors.blue),
      //                   ),
      //                   onPressed: () {
      //                     setState(() {});
      //                     Navigator.of(context).pop();
      //                   },
      //                 )
      //               ],
      //             ),
      //             Container(
      //                 height: 200.0,
      //                 child: Flex(
      //                   direction: Axis.horizontal,
      //                   children: <Widget>[
      //                     // Flexible(
      //                     //   flex: 8,
      //                     //   child: CupertinoDatePicker(
      //                     //     mode: CupertinoDatePickerMode.date,
      //                     //     initialDateTime: p.date,
      //                     //     onDateTimeChanged: (DateTime dateTime) {
      //                     //       p.selectedDate = dateTime;
      //                     //     },
      //                     //   ),
      //                     // ),
      //                     Flexible(
      //                       flex: 10,
      //                       child: CupertinoPicker(
      //                           itemExtent: 38,
      //                           onSelectedItemChanged: (int index) {
      //                             setState(() {
      //                               p.selectedYear = p.timeList![index];
      //                             });
      //                           },
      //                           children: (p.timeList ?? [])
      //                               .map((item) => Center(
      //                                   child: Text(item,
      //                                       style: TextStyle(fontSize: 20))))
      //                               .toList()),
      //                     ),
      //                   ],
      //                 )),
      //           ],
      //         ),
      //       );
      //     });
    }

    harian() async {
      await showCupertinoModalPopup<void>(
        context: context,
        builder: (_) {
          final size = MediaQuery.of(context).size;
          return Container(
            color: Colors.white,
            height: size.height * 0.55,
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: Constant.grayColor.withOpacity(0.5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Per Hari',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          CusNav.nPop(context);
                        },
                        child: Text(
                          'Batal',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Constant.grayColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Constant.xSizedBox12,
                Container(
                  height: 200,
                  child: CupertinoDatePicker(
                    initialDateTime: DateTime.now(),
                    mode: CupertinoDatePickerMode.date,
                    use24hFormat: true,
                    // This is called when the user changes the time.
                    onDateTimeChanged: (DateTime newTime) {
                      setState(() => p.selectedDate = newTime);
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: CustomButton.mainButton(
                    'Konfirmasi',
                    borderRadius: BorderRadius.circular(10),
                    () async {
                      handleTap(() async {
                        CusNav.nPop(context);
                      });
                    },
                  ),
                ),
              ],
            ),
          );
        },
      );
    }

    bulanan() async {
      await showCupertinoModalPopup<void>(
        context: context,
        builder: (_) {
          final size = MediaQuery.of(context).size;
          return Container(
            color: Colors.white,
            height: size.height * 0.55,
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: Constant.grayColor.withOpacity(0.5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Per Hari',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          CusNav.nPop(context);
                        },
                        child: Text(
                          'Batal',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Constant.grayColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Constant.xSizedBox12,
                Container(
                  height: 200,
                  child: CupertinoDatePicker(
                    // Menggunakan DateTime.now() langsung untuk memulai dari bulan dan tahun sekarang
                    initialDateTime: DateTime.now(),
                    mode: CupertinoDatePickerMode.monthYear,
                    use24hFormat: true,
                    // Fungsi ini dipanggil ketika pengguna mengubah bulan/tahun
                    onDateTimeChanged: (DateTime newTime) {
                      setState(() {
                        p.selectedDate = newTime;
                        p.selectedMonth = newTime.month.toString();
                        p.selectedYear = newTime.year.toString();
                      });
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: CustomButton.mainButton(
                    'Konfirmasi',
                    borderRadius: BorderRadius.circular(10),
                    () async {
                      handleTap(() async {
                        CusNav.nPop(context);
                      });
                    },
                  ),
                ),
              ],
            ),
          );
        },
      );
    }

    Widget customHeader() {
      final data = profileP.profileSellerModel.data?.profile;
      return Container(
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Color(0xff059669), Color(0xff34D399)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: ClipOval(
                    child: SafeNetworkImage(
                      width: 48,
                      height: 48,
                      url: data?.photoUrl ?? '',
                      boxFit: BoxFit.cover,
                      errorBuilder: Image.asset(
                        Assets.iconsIcSellerProfile,
                        width: 48,
                        height: 48,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Selamat datang,',
                        style: TextStyle(
                          color: Color(0xff8A93A3),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        data?.companyName ?? data?.name ?? '-',
                        style: const TextStyle(
                          color: Color(0xff100629),
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // WAIT BACKEND: Notifikasi & Chat belum tersedia di MSpeed
                // Icon Notifikasi dan Chat disembunyikan sementara
                IconButton(
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xffF5F6FA),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfileSellerView(),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.person_outline_rounded,
                    color: Color(0xff100629),
                    size: 22,
                  ),
                ),
              ],
            ),
              // Ringkasan Bisnis dropdown removed because dashboard is not available
          ],
        ),
      );
    }

    Widget _buildShortcutButton({
      required IconData icon,
      required String label,
      required Color color,
      required VoidCallback onTap,
    }) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          width: MediaQuery.of(context).size.width / 2 - 28,
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xffE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 12),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xff100629),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    Widget body() {
      return SafeArea(
        child: Container(
          color: const Color(0xffF5F6FA),
          child: RefreshIndicator(
            onRefresh: () async {
              getData();
            },
            color: const Color(0xff059669),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                customHeader(),
                const SizedBox(height: 32),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Kelola Toko Anda',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xff100629),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      _buildShortcutButton(
                        icon: Icons.inventory_2_rounded,
                        label: 'Produk',
                        color: const Color(0xff059669),
                        onTap: () {
                          // Jump to Produk is handled by BottomNav in Main, but here we can just show a toast or wait, the tab index logic is managed by SellerMainHome
                          // For simplicity, do nothing or show toast
                          Utils.showFailed(msg: 'Gunakan navigasi bawah untuk membuka Produk');
                        }
                      ),
                      _buildShortcutButton(
                        icon: Icons.receipt_long_rounded,
                        label: 'Pesanan',
                        color: const Color(0xffF59E0B),
                        onTap: widget.jumpToPesanan,
                      ),
                      _buildShortcutButton(
                        icon: Icons.handshake_rounded,
                        label: 'Negosiasi',
                        color: const Color(0xff3B82F6),
                        onTap: () {
                          Utils.showFailed(msg: 'Gunakan navigasi bawah untuk membuka Negosiasi');
                        }
                      ),
                      _buildShortcutButton(
                        icon: Icons.person_rounded,
                        label: 'Profil',
                        color: const Color(0xff8B5CF6),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProfileSellerView(),
                            ),
                          );
                        }
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(backgroundColor: const Color(0xffF5F6FA), body: body());
  }
}
