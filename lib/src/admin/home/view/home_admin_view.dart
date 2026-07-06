import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mspeed/common/base/base_state.dart';
import 'package:mspeed/common/component/custom_button.dart';
import 'package:mspeed/common/component/custom_dropdown.dart';
import 'package:mspeed/common/component/custom_navigator.dart';
import 'package:mspeed/common/helper/constant.dart';
import 'package:mspeed/generated/assets.dart';
import 'package:mspeed/src/admin/home/model/home_admin_model.dart';
import 'package:mspeed/src/admin/home/view/home_admin_graph_view.dart';
import 'package:mspeed/src/admin/home/view/home_admin_transaction_graph.dart';
import 'package:mspeed/src/auth/provider/auth_provider.dart';
import 'package:mspeed/src/auth/view/login_view.dart';
import 'package:mspeed/utils/utils.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../provider/admin_home_provider.dart';

class HomeAdminView extends StatefulWidget {
  @override
  State<HomeAdminView> createState() => _HomeSellerViewState();
}

class _HomeSellerViewState extends BaseState<HomeAdminView> {
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

    final p = context.read<AdminHomeProvider>();
    List<String> years =
        List.generate(2024 - 1900 + 1, (index) => (1900 + index).toString());
    for (int i = years.length - 1; i >= 0; i--) {
      p.timeList?.add(years[i]);
    }
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  Future<void> getData() async {
    Utils.showLoading();
    final p = context.read<AdminHomeProvider>();
    await p.fetchHome(withLoading: false);
    await p.fetchSellers(withLoading: false);
    final prefs = await SharedPreferences.getInstance();
    name = await prefs.getString(Constant.kSetPrefFirstName) ?? "";
    name += " " + (await prefs.getString(Constant.kSetPrefLastName) ?? "");
    Utils.dismissLoading();
  }

  String name = '';

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AdminHomeProvider>();
    final model = context.watch<AdminHomeProvider>().homeAdminModel.data;
    // final tableMostBuy =
    //     context.watch<AdminHomeProvider>().homeAdminModel.data?.pembelian;
    // final tableTransaksi =
    //     context.watch<AdminHomeProvider>().homeAdminModel.data?.transaksi;
    PreferredSizeWidget appBar() {
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
            Text(p.name ?? '', style: Constant.blackBold16),
            Constant.xSizedBox4,
          ],
        ),
        actions: <Widget>[
          IconButton(
            onPressed: () {
              handleTap(() async {
                Utils.showYesNoDialog(
                  context: context,
                  title: "Konfirmasi",
                  desc: "Apakah Anda Yakin ingin Keluar",
                  yesCallback: () async {
                    handleTap(() async {
                      await context.read<AuthProvider>().logout();
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => LoginView()),
                        (Route<dynamic> route) => false,
                      );
                    });
                  },
                  noCallback: () {
                    Navigator.pop(context);
                  },
                );
              });
            },
            icon: Icon(Icons.logout, size: 24, color: Constant.primaryColor),
          ),
        ],
      );
    }

    // Widget headerInfoItem({
    //   required String title,
    //   required String subtitle,
    //   required Color subtitleColor,
    // }) {
    //   return Column(
    //     children: [
    //       Text(
    //         title,
    //         textAlign: TextAlign.center,
    //         style: TextStyle(color: Color(0xff6D7588), fontSize: 12),
    //       ),
    //       Constant.xSizedBox4,
    //       Text(
    //         subtitle,
    //         textAlign: TextAlign.center,
    //         style: TextStyle(
    //           color: subtitleColor,
    //           fontSize: 15,
    //           fontWeight: FontWeight.w700,
    //         ),
    //       ),
    //     ],
    //   );
    // }

    // Widget headerInfo() {
    //   return Padding(
    //     padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
    //     child: Row(
    //       children: [
    //         Expanded(
    //           child: Column(
    //             children: [
    //               headerInfoItem(
    //                 title: 'Produk Terjual',
    //                 subtitle: '212',
    //                 subtitleColor: Color(0xff5397AA),
    //               ),
    //               Constant.xSizedBox8,
    //               headerInfoItem(
    //                 title: 'Total Pendapatan',
    //                 subtitle: 'Rp 3.090.000',
    //                 subtitleColor: Color(0xff1ABC62),
    //               ),
    //             ],
    //           ),
    //         ),
    //         Constant.xSizedBox16,
    //         Expanded(
    //           child: Column(
    //             children: [
    //               headerInfoItem(
    //                 title: 'Total Permintaan Pesanan',
    //                 subtitle: 'Rp 8.098.500',
    //                 subtitleColor: Color(0xffBF83FF),
    //               ),
    //               Constant.xSizedBox8,
    //               headerInfoItem(
    //                 title: 'Total Belum Lunas',
    //                 subtitle: 'Rp 1.098.500',
    //                 subtitleColor: Color(0xffE43532),
    //               ),
    //             ],
    //           ),
    //         ),
    //       ],
    //     ),
    //   );
    // }

    Widget headerInfoItem2({
      required String icon,
      required String title,
      required String subtitle,
      required Color bgColor,
      required Color titleColor,
    }) {
      return Container(
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Jumlah User Terdaftar'),
            Constant.xSizedBox8,
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: headerInfoItem2(
                    icon: Assets.iconsIcAdminTotalUser,
                    title: model?.totalUser ?? '0',
                    bgColor: Color(0xffF3E8FF),
                    titleColor: Color(0xffBF83FF),
                    subtitle: 'Total User',
                  ),
                ),
                Constant.xSizedBox8,
                Expanded(
                  child: headerInfoItem2(
                    icon: Assets.iconsIcAdminSeller,
                    title: model?.totalSeller ?? '0',
                    subtitle: 'Seller',
                    bgColor: Color(0xffDCFCE7),
                    titleColor: Color(0xff1ABC62),
                  ),
                ),
                Constant.xSizedBox8,
                Expanded(
                  child: headerInfoItem2(
                    icon: Assets.iconsIcAdminBuyer,
                    title: model?.totalBuyer ?? '0',
                    subtitle: 'Buyer',
                    bgColor: Color(0xffFFF4DE),
                    titleColor: Color(0xffFF947A),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    // Widget buyerTransactionTitle() {
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

    // TableRow orderItem({
    //   required String number,
    //   required String product,
    //   required String salesQty,
    //   required String amount,
    //   required String status,
    //   required Color statusColor,
    // }) {
    //   return TableRow(
    //     decoration: BoxDecoration(color: Colors.transparent),
    //     children: [
    //       Padding(
    //         padding: const EdgeInsets.only(left: 8, top: 8),
    //         child: Text(
    //           '$number',
    //           textAlign: TextAlign.left,
    //           style: TextStyle(
    //             color: Color(0xff100629),
    //             fontSize: 12,
    //           ),
    //         ),
    //       ),
    //       Padding(
    //         padding: const EdgeInsets.only(top: 8),
    //         child: Text(
    //           '$product',
    //           textAlign: TextAlign.left,
    //           style: TextStyle(
    //             color: Color(0xff100629),
    //             fontSize: 12,
    //           ),
    //         ),
    //       ),
    //       Padding(
    //         padding: const EdgeInsets.only(top: 8),
    //         child: Text(
    //           '$salesQty',
    //           textAlign: TextAlign.left,
    //           style: TextStyle(
    //             color: Color(0xff100629),
    //             fontSize: 12,
    //           ),
    //         ),
    //       ),
    //       Padding(
    //         padding: const EdgeInsets.only(top: 8),
    //         child: Text(
    //           '$amount',
    //           textAlign: TextAlign.right,
    //           style: TextStyle(
    //             color: Color(0xff100629),
    //             fontSize: 12,
    //           ),
    //         ),
    //       ),
    //       Padding(
    //         padding: const EdgeInsets.only(top: 8, right: 4),
    //         child: Text(
    //           '$status',
    //           textAlign: TextAlign.right,
    //           style: TextStyle(
    //             color: statusColor,
    //             fontSize: 12,
    //           ),
    //         ),
    //       ),
    //     ],
    //   );
    // }

    TableRow favouriteItem({
      required int index,
      required HomeAdminModelDataTproduk? data,
    }) {
      return TableRow(
        decoration: BoxDecoration(color: Colors.transparent),
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8, top: 8),
            child: Text(
              '#${index + 1}',
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
              data?.nama ?? '',
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
              data?.qty ?? '',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xff100629),
                fontSize: 12,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8, right: 4),
            child: Text(
              Utils.thousandSeparator(int.parse(data?.harga ?? '')),
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

    List<TableRow> tableFavouriteProduct() {
      return List.generate(model?.tproduk?.length ?? 0, (i) {
        final item = model?.tproduk?[i];
        return favouriteItem(index: i, data: item);
      });
    }

    TableRow buyerItem(
        {required int index, required HomeAdminModelDataTbuyer? data}) {
      return TableRow(
        decoration: BoxDecoration(color: Colors.transparent),
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8, top: 8),
            child: Text(
              '#${index + 1}',
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
              data?.email ?? '',
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
              data?.qty ?? '',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xff100629),
                fontSize: 12,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8, right: 4),
            child: Text(
              Utils.thousandSeparator(int.parse(data?.harga ?? '')),
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

    List<TableRow> tableBuyerTransaction() {
      return List.generate(model?.tbuyer?.length ?? 0, (i) {
        final item = model?.tbuyer?[i];
        return buyerItem(index: i, data: item);
      });
    }

    Widget buyerTransaction() {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Transaksi Buyer'),
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
                  decoration: BoxDecoration(color: Color(0xffDEEDFF)),
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
                        'Email',
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
                        'Qty',
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
                ...tableBuyerTransaction(),
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
            SizedBox(
              height: 16,
            ),
            Text('Jumlah Pembelian Barang'),
            HomeAdminGraphView(),
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

    Widget totalTransactionGraph() {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 16,
            ),
            Text('Jumlah Transaksi Seluruh Buyer'),
            HomeAdminTransactionGraph(),
            Constant.xSizedBox4,
          ],
        ),
      );
    }

    Widget favouriteProduct() {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Produk Terfavorit'),
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
                ...tableFavouriteProduct(),
              ],
            ),
          ],
        ),
      );
    }

    TableRow sellerItem(
        {required int index, required HomeAdminModelDataTseller? data}) {
      return TableRow(
        decoration: BoxDecoration(color: Colors.transparent),
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8, top: 8),
            child: Text(
              '#${index + 1}',
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
              data?.email ?? '',
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
              data?.qty ?? '',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xff100629),
                fontSize: 12,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8, right: 4),
            child: Text(
              Utils.thousandSeparator(int.parse(data?.harga ?? '')),
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

    List<TableRow> tableSeller() {
      return List.generate(model?.tseller?.length ?? 0, (i) {
        final item = model?.tseller?[i];
        return sellerItem(index: i, data: item);
      });
    }

    Widget sellerTransaction() {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Penjualan Seller'),
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
                  decoration: BoxDecoration(color: Color(0xFFEEDEFF)),
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
                        'Email',
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
                        'Qty',
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
                ...tableSeller(),
              ],
            ),
          ],
        ),
      );
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
                        'Per Bulan',
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
                    initialDateTime:
                        DateFormat('yyyy').parse(DateTime.now().toString()),
                    mode: CupertinoDatePickerMode.monthYear,
                    use24hFormat: true,
                    // This is called when the user changes the time.
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
    }

    Widget body() {
      return SafeArea(
        child: Container(
          color: Colors.white,
          child: RefreshIndicator(
            onRefresh: () async {
              await getData();
            },
            child: ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                  child: CustomDropdown.normalDropdown(
                    selectedItem: p.selectedPeriodeData,
                    list: p.periodeData.entries
                        .map((item) => DropdownMenuItem(
                              child: Text(
                                item.key,
                                style: TextStyle(color: Constant.primaryColor),
                              ),
                              value: item.value,
                            ))
                        .toList(),
                    onChanged: (v) async {
                      if (v == 'Periode Data Harian') await harian();
                      if (v == 'Periode Data Bulanan') await bulanan();
                      if (v == 'Periode Data Tahunan') await tahunan();
                      p.selectedPeriodeData = v;
                      await context
                          .read<AdminHomeProvider>()
                          .fetchHome(withLoading: true);

                      log('INI SELECTED DATE' + p.selectedDate.toString());
                      log('INI SELECTED MONTH' + p.selectedMonth.toString());
                      log('INI SELECTED YEAR' + p.selectedYear.toString());
                    },
                    borderColor: Constant.primaryColor,
                    activeBorderColor: Constant.primaryColor,
                    iconColor: Constant.primaryColor,
                    borderWidth: 1,
                    activeBorderWidth: 1,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Radio(
                              value: 0,
                              groupValue: p.filterType,
                              visualDensity:
                                  VisualDensity(vertical: -4, horizontal: -4),
                              onChanged: (value) {
                                if (p.filterType != value) {
                                  setState(() {
                                    p.filterType = 0;
                                  });
                                  p.selectedSellerBuyer = null;
                                  p.selectedSellerBuyerId = null;
                                  setState(() {});
                                  p.fetchSellers(withLoading: true);
                                }
                              },
                            ),
                            Text(
                              'Filter Seller',
                              style: TextStyle(fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Row(
                            children: [
                              Radio(
                                value: 1,
                                groupValue: p.filterType,
                                visualDensity:
                                    VisualDensity(vertical: -4, horizontal: -4),
                                onChanged: (value) {
                                  if (p.filterType != value) {
                                    setState(() {
                                      p.filterType = 1;
                                    });
                                    p.selectedSellerBuyer = null;
                                    p.selectedSellerBuyerId = null;
                                    setState(() {});
                                    p.fetchBuyers(withLoading: true);
                                  }
                                },
                              ),
                              Text(
                                'Filter Buyer',
                                style: TextStyle(fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child:
                      // Theme(
                      //   data: ThemeData(scaffoldBackgroundColor: Colors.white),
                      //   child: DropdownSearch<String>(
                      //     popupProps: PopupProps.dialog(
                      //       showSearchBox: true,
                      //       showSelectedItems: true,
                      //       dialogProps: DialogProps(backgroundColor: Colors.white),
                      //     ),
                      //     items: p.userData.map((e) => e.name1 ?? '-').toList(),
                      //     selectedItem: p.selectedSellerBuyer,
                      //     dropdownButtonProps: DropdownButtonProps(
                      //       icon: const Icon(
                      //         Icons.keyboard_arrow_down,
                      //         color: Color(0xffB9B9B9),
                      //       ),
                      //     ),
                      //     validator: (value) {
                      //       return null;
                      //     },
                      //     dropdownDecoratorProps: DropDownDecoratorProps(
                      //       dropdownSearchDecoration: InputDecoration(
                      //         isDense: true,
                      //         contentPadding: EdgeInsets.zero,
                      //         hintText:
                      //             'Pilih ${p.filterType == 0 ? 'Seller' : 'Buyer'}',
                      //         hintStyle: TextStyle(
                      //             color: Colors.black26 /*, fontSize: 12*/),
                      //         filled: true,
                      //         fillColor: Colors.white,
                      //         suffixIconColor: Constant.primaryColor,
                      //         hoverColor: Constant.primaryColor,
                      //         focusColor: Constant.primaryColor,
                      //         prefix: SizedBox(width: 12),
                      //         border: OutlineInputBorder(
                      //           borderSide: BorderSide(color: Color(0xffB9B9B9)),
                      //           borderRadius: BorderRadius.circular(10),
                      //         ),
                      //         enabledBorder: OutlineInputBorder(
                      //           borderSide: BorderSide(color: Color(0xffB9B9B9)),
                      //           borderRadius: BorderRadius.circular(10),
                      //         ),
                      //         focusedBorder: OutlineInputBorder(
                      //           borderSide: BorderSide(color: Color(0xffB9B9B9)),
                      //           borderRadius: BorderRadius.circular(10),
                      //         ),
                      //       ),
                      //     ),
                      //     onChanged: (v) {
                      //       var index = p.userData.indexWhere((e) => e.name1 == v);
                      //       if (index != -1 && p.userData[index].id != null) {
                      //         p.selectedSellerBuyer = v;
                      //         p.selectedSellerBuyerId = p.userData[index].id;
                      //       }
                      //       setState(() {});
                      //     },
                      //     clearButtonProps: ClearButtonProps(
                      //       icon: Icon(Icons.clear, size: 17, color: Colors.black),
                      //     ),
                      //   ),
                      // ),
                      CustomDropdown.searchDropdown(
                    list: p.userData.map((e) => e.name1 ?? '-').toList(),
                    hintText: 'Pilih ${p.filterType == 0 ? 'Seller' : 'Buyer'}',
                    onChanged: (v) {
                      var index = p.userData.indexWhere((e) => e.name1 == v);
                      if (index != -1 && p.userData[index].id != null) {
                        setState(() {
                          p.selectedSellerBuyer = v;
                          p.selectedSellerBuyerId = p.userData[index].id;
                        });
                      }
                    },
                    selectedItem: p.selectedSellerBuyer,
                  ),
                ),
                CustomButton.mainButton('Filter',
                    margin: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                    borderRadius: BorderRadius.circular(12), () async {
                  handleTap(() async {
                    await getData();
                    setState(() {});
                  });
                }),
                SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: InkWell(
                    onTap: () async {
                      p.selectedPeriodeData = '0';
                      p.selectedSellerBuyer = null;
                      p.selectedSellerBuyerId = null;
                      p.filterType = 0;
                      p.userData.clear();
                      setState(() {});
                      await p.fetchHome(withLoading: true);
                      await p.fetchSellers(withLoading: false);
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(right: 20),
                      child: Text(
                        'Reset filter',
                        style: TextStyle(
                          color: Constant.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 8),
                Container(
                  child: Divider(
                    color: Colors.grey.withOpacity(0.2),
                    thickness: 5,
                  ),
                ),
                headerInfo2(),
                productSellingGraph(),
                totalTransactionGraph(),
                favouriteProduct(),
                buyerTransaction(),
                sellerTransaction(),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Color(0XFFED1C24),
      appBar: appBar(),
      body: body(),
    );
  }
}
