import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mspeed/common/base/base_state.dart';
import 'package:mspeed/common/component/custom_button.dart';
import 'package:mspeed/common/component/custom_dropdown.dart';
import 'package:mspeed/common/component/custom_navigator.dart';
import 'package:mspeed/common/helper/constant.dart';
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
    List<String> years =
        List.generate(2024 - 1900 + 1, (index) => (1900 + index).toString());
    for (int i = years.length - 1; i >= 0; i--) {
      p.timeList?.add(years[i]);
    }
    context
        .read<NotifikasiSellerProvider>()
        .fetchNotification(withLoading: true);
  }

  Future<bool> requestPermission(Permission permission) async {
    PermissionStatus status = await permission.request();
    return [PermissionStatus.granted, PermissionStatus.limited]
        .contains(status);
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  Future<void> getData() async {
    Utils.showLoading();
    await context
        .read<ProfileSellerProvider>()
        .fetchProfile(context, withLoading: false);
    await context
        .read<SellerHomeProvider>()
        .fetchSellerHome(withLoading: false);
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
    final tableMostBuy = context
        .watch<SellerHomeProvider>()
        .homeSellerModel
        ?.data
        ?.tablePalingLaris;

    PreferredSizeWidget appBar() {
      final data = profileP.profileSellerModel.data?.getSeller;
      return AppBar(
        surfaceTintColor: Colors.white,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        toolbarHeight: kToolbarHeight + 8,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Image.asset(Assets.iconsIcSellerProfile, scale: 2),
        ),
        leadingWidth: 56,
        titleSpacing: 12,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Selamat datang',
              style: TextStyle(color: Color(0xff6D7588), fontSize: 14),
            ),
            Constant.xSizedBox4,
            Text(data?.nama ?? '', style: Constant.blackBold16),
            Constant.xSizedBox4,
          ],
        ),
        actions: <Widget>[
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NotificationSellerView(),
                ),
              );
            },
            icon: Badge(
              isLabelVisible:
                  notifP.unreadCount.toString() == '0' ? false : true,
              label: Text(
                notifP.unreadCount.toString(),
              ),
              offset: const Offset(8, -4),
              backgroundColor: Colors.redAccent,
              child: Image.asset(
                Assets.iconsIcNotificationBlack,
                width: 24,
                color: isCollapsed ? Colors.black : Colors.black,
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ChatListSellerView()),
              );
            },
            icon: Badge(
              isLabelVisible: true,
              label: const Text("2"),
              offset: const Offset(8, -4),
              backgroundColor: Colors.redAccent,
              child: SvgPicture.asset(Assets.svgsIcChat,
                  width: 24, color: isCollapsed ? Colors.black : Colors.black),
            ),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfileSellerView()),
              );
              // Navigator.pushNamed(context, '/chat_list');
            },
            icon: Image.asset(Assets.iconsIcAkunAppbar,
                width: 24, color: isCollapsed ? Colors.black : Colors.black),
          ),
        ],
      );
    }

    Widget headerInfoItem({
      required String title,
      required String subtitle,
      required Color subtitleColor,
    }) {
      return Column(
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xff6D7588), fontSize: 12),
          ),
          Constant.xSizedBox4,
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: subtitleColor,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
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
                    subtitle: data?.produk ?? '',
                    subtitleColor: Color(0xff5397AA),
                  ),
                  Constant.xSizedBox8,
                  headerInfoItem(
                    title: 'Total Pendapatan',
                    subtitle: Utils.thousandSeparator(
                        int.parse(data?.totalPendapatan ?? '0')),
                    subtitleColor: Color(0xff1ABC62),
                  ),
                ],
              ),
            ),
            Constant.xSizedBox16,
            Expanded(
              child: Column(
                children: [
                  headerInfoItem(
                    title: 'Total Permintaan Pesanan',
                    subtitle: Utils.thousandSeparator(
                        int.parse(data?.totalPermintaanPesanan ?? '0')),
                    subtitleColor: Color(0xffBF83FF),
                  ),
                  Constant.xSizedBox8,
                  headerInfoItem(
                    title: 'Total Belum Lunas',
                    subtitle: Utils.thousandSeparator(
                        int.parse(data?.totalBelumLunas ?? '0')),
                    subtitleColor: Color(0xffE43532),
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
      required Color bgColor,
      required Color titleColor,
    }) {
      return Container(
        height: 145,
        width: double.infinity,
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              icon,
              width: 35,
              height: 35,
            ),
            Constant.xSizedBox8,
            Text(
              title,
              textAlign: TextAlign.left,
              style: TextStyle(
                color: titleColor,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              subtitle,
              textAlign: TextAlign.left,
              style: TextStyle(
                color: Color(0xff6D7588),
                fontSize: 14,
                fontWeight: FontWeight.w400,
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
                    bgColor: Color(0xffDEEDFF),
                    titleColor: Color(0xff5397AA),
                  ),
                  Constant.xSizedBox8,
                  headerInfoItem2(
                    icon: Assets.iconsIcBarangDiterima,
                    title: '${data?.barangDiterima ?? 0}',
                    subtitle: 'Barang Diterima',
                    bgColor: Color(0xffDCFCE7),
                    titleColor: Color(0xff1ABC62),
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
                    bgColor: Color(0xffF3E8FF),
                    titleColor: Color(0xffBF83FF),
                  ),
                  Constant.xSizedBox8,
                  headerInfoItem2(
                    icon: Assets.iconsIcProsesBayar,
                    title: '${data?.prosesPembayaran ?? 0}',
                    subtitle: 'Proses Bayar',
                    bgColor: Color(0xffFFDEDE),
                    titleColor: Color(0xffED1C24),
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
                    bgColor: Color(0xffFFF4DE),
                    titleColor: Color(0xffFF947A),
                  ),
                  Constant.xSizedBox8,
                  headerInfoItem2(
                    icon: Assets.iconsIcPesananDibayar,
                    title: '${data?.pesananDibayar ?? '0'}',
                    subtitle: 'Pesanan Dibayar',
                    bgColor: Color(0xffFFFDCD),
                    titleColor: Color(0xffFFC17A),
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

    TableRow orderItem(
        {required int index,
        required HomeSellerModelDataTablePesananTerbaru? data}) {
      String status = (data?.status ?? '')
          .replaceAll('_', ' ')
          .toLowerCase()
          .split(' ')
          .map((word) => word.capitalize())
          .join(' ');
      return TableRow(
        decoration: BoxDecoration(
            color: index % 2 != 0 ? Color(0xffF8F8F8) : Colors.transparent),
        children: [
          Padding(
            padding:
                const EdgeInsets.only(left: 8, top: 8, right: 8, bottom: 8),
            child: Text(
              '${index + 1}',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xff100629),
                fontSize: 12,
              ),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.only(left: 8, top: 8, right: 8, bottom: 8),
            child: Text(
              '${data?.nomorOrder}',
              textAlign: TextAlign.left,
              style: TextStyle(
                color: Color(0xff100629),
                fontSize: 12,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              '${Utils.thousandSeparator(int.parse(data?.total ?? '0'))}',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xff100629),
                fontSize: 12,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              '${data?.alamat ?? '-'}',
              textAlign: TextAlign.right,
              style: TextStyle(
                color: Color(0xff100629),
                fontSize: 12,
              ),
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

    TableRow productItem(
        {required int index,
        required s.HomeSellerModelDataTablePalingLaris? data}) {
      return TableRow(
        decoration: BoxDecoration(color: Colors.transparent),
        children: [
          Padding(
            padding:
                const EdgeInsets.only(left: 8, top: 8, right: 8, bottom: 8),
            child: Text(
              '#${index + 1}',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xff100629),
                fontSize: 12,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              '${data?.nama ?? '-'}',
              textAlign: TextAlign.left,
              style: TextStyle(
                color: Color(0xff100629),
                fontSize: 12,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              '${data?.qty ?? '0'}',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xff100629),
                fontSize: 12,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8, right: 8),
            child: Text(
              Utils.thousandSeparator(int.parse(data?.harga ?? '0')),
              textAlign: TextAlign.right,
              style: TextStyle(
                color: Color(0xff100629),
                fontSize: 12,
              ),
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
                    child: Text('Lihat Semua Pesanan',
                        style: TextStyle(color: Constant.primaryColor)),
                  ),
                ),
              ],
            ),
            Constant.xSizedBox8,
            Table(
              border: TableBorder.all(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(5)),
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
                  decoration: BoxDecoration(color: Color(0xffDEEDFF)),
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
                    child: Image.asset(Assets.iconsIcQuantityLegend)),
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
                  borderRadius: BorderRadius.circular(5)),
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
                  decoration: BoxDecoration(color: Color(0xffFFEEDE)),
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
                            fontWeight: FontWeight.bold, fontSize: 16),
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
                            children: (p.timeList ?? [])
                                .map((item) => Center(
                                    child: Text(item,
                                        style: TextStyle(fontSize: 20))))
                                .toList()),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: CustomButton.mainButton('Konfirmasi',
                      borderRadius: BorderRadius.circular(10), () async {
                    handleTap(() async {
                      CusNav.nPop(context);
                    });
                  }),
                )
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
                            fontWeight: FontWeight.bold, fontSize: 16),
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
                  child: CustomButton.mainButton('Konfirmasi',
                      borderRadius: BorderRadius.circular(10), () async {
                    handleTap(() async {
                      CusNav.nPop(context);
                    });
                  }),
                )
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
                            fontWeight: FontWeight.bold, fontSize: 16),
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
                  child: CustomButton.mainButton('Konfirmasi',
                      borderRadius: BorderRadius.circular(10), () async {
                    handleTap(() async {
                      CusNav.nPop(context);
                    });
                  }),
                )
              ],
            ),
          );
        },
      );
    }

    Widget body() {
      return SafeArea(
        child: Container(
          color: Colors.white,
          child: RefreshIndicator(
            onRefresh: () async {
              getData();
            },
            child: ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                  child: CustomDropdown.normalDropdown(
                    selectedItem: p.selectedPeriodeData,
                    list: p.periodeData
                        .map((e) => DropdownMenuItem(
                            child: Text(
                              e,
                              style: TextStyle(color: Constant.primaryColor),
                            ),
                            value: e))
                        .toList(),
                    onChanged: (v) async {
                      if (v == 'Harian') await harian();
                      if (v == 'Bulanan') await bulanan();
                      if (v == 'Tahunan') await tahunan();
                      p.selectedPeriodeData = v;
                      await getData();
                    },
                    borderColor: Constant.primaryColor,
                    activeBorderColor: Constant.primaryColor,
                    iconColor: Constant.primaryColor,
                    borderWidth: 1,
                    activeBorderWidth: 1,
                  ),
                ),
                Container(
                  child: Divider(
                    color: Colors.grey.withOpacity(0.2),
                    thickness: 5,
                  ),
                ),
                headerInfo(),
                headerInfo2(),
                Constant.xSizedBox12,
                productSellingGraph(),
                mostBuyedProducts(),
                newestOrder(),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(appBar: appBar(), body: body());
  }
}
