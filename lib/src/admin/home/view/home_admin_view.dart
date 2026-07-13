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
      final nameToShow = (p.name != null && p.name!.trim().isNotEmpty) ? p.name! : 'Admin M-Speed';
      final emailToShow = (p.email != null && p.email!.trim().isNotEmpty) ? p.email! : 'administrator@mspeed.id';

      return AppBar(
        surfaceTintColor: Colors.white,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        toolbarHeight: kToolbarHeight + 16,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: const Color(0xffE4E6EF),
            height: 1,
          ),
        ),
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Constant.primaryColor, Constant.primaryColor.withOpacity(0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Constant.primaryColor.withOpacity(0.24),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Icon(Icons.admin_panel_settings_rounded, color: Colors.white, size: 20),
          ),
        ),
        leadingWidth: 60,
        titleSpacing: 12,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              nameToShow,
              style: const TextStyle(
                color: Color(0xff100629),
                fontSize: 15,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              emailToShow,
              style: const TextStyle(
                color: Color(0xff8A93A3),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: IconButton(
              style: IconButton.styleFrom(
                backgroundColor: const Color(0xffED1C24).withOpacity(0.08),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                handleTap(() async {
                  Utils.showYesNoDialog(
                    context: context,
                    title: "Konfirmasi",
                    desc: "Apakah Anda Yakin ingin Keluar?",
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
              icon: const Icon(
                Icons.power_settings_new_rounded,
                size: 20,
                color: Color(0xffED1C24),
              ),
            ),
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
      required List<Color> gradientColors,
      required Color iconBg,
      required Color countColor,
    }) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: gradientColors.last.withOpacity(0.22),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Image.asset(
                icon,
                width: 18,
                height: 18,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.left,
              style: TextStyle(
                color: countColor,
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              subtitle,
              textAlign: TextAlign.left,
              style: const TextStyle(
                color: Color(0xff6D7588),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    Widget headerInfo2() {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 4,
                  height: 18,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xffBF83FF), Color(0xff6C47FF)],
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Jumlah User Terdaftar',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xff100629),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xffF3E8FF),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${model?.totalUser ?? '0'} total',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Color(0xffBF83FF),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: headerInfoItem2(
                    icon: Assets.iconsIcAdminTotalUser,
                    title: model?.totalUser ?? '0',
                    gradientColors: const [Color(0xffFAF0FF), Color(0xffF0E2FF)],
                    iconBg: Colors.white.withOpacity(0.75),
                    countColor: Color(0xffBF83FF),
                    subtitle: 'Total User',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: headerInfoItem2(
                    icon: Assets.iconsIcAdminSeller,
                    title: model?.totalSeller ?? '0',
                    subtitle: 'Seller',
                    gradientColors: const [Color(0xffF0FFF7), Color(0xffDCFCE7)],
                    iconBg: Colors.white.withOpacity(0.75),
                    countColor: Color(0xff1ABC62),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: headerInfoItem2(
                    icon: Assets.iconsIcAdminBuyer,
                    title: model?.totalBuyer ?? '0',
                    subtitle: 'Buyer',
                    gradientColors: const [Color(0xffFFFBF0), Color(0xffFFF4DE)],
                    iconBg: Colors.white.withOpacity(0.75),
                    countColor: Color(0xffFF947A),
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


    void _showBuyerSheet(List items) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        isDismissible: true,
        enableDrag: true,
        barrierColor: Colors.black.withOpacity(0.5),
        backgroundColor: Colors.transparent,
        builder: (_) => DraggableScrollableSheet(
          initialChildSize: 0.6,
          maxChildSize: 0.92,
          minChildSize: 0.4,
          builder: (_, sc) => Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                const SizedBox(height: 10),
                Container(width: 40, height: 4, decoration: BoxDecoration(color: Color(0xffE4E6EF), borderRadius: BorderRadius.circular(4))),
                const SizedBox(height: 14),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Container(width: 36, height: 36, decoration: BoxDecoration(color: Constant.primaryColor.withOpacity(0.12), borderRadius: BorderRadius.circular(10)), child: Icon(Icons.people_alt_rounded, color: Constant.primaryColor, size: 18)),
                      const SizedBox(width: 10),
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Text('Transaksi Buyer', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xff100629))),
                        Text('${items.length} buyer', style: TextStyle(fontSize: 12, color: Constant.primaryColor)),
                      ]),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const Divider(height: 1, color: Color(0xffF0F0F0)),
                Expanded(
                  child: ListView.separated(
                    controller: sc,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const Divider(height: 1, indent: 60, endIndent: 16, color: Color(0xffF0F0F0)),
                    itemBuilder: (_, i) {
                      final item = items[i];
                      final initial = (item?.email ?? '-').isNotEmpty ? (item?.email ?? '-')[0].toUpperCase() : '?';
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        child: Row(
                          children: [
                            Container(width: 34, height: 34, decoration: BoxDecoration(color: Constant.primaryColor.withOpacity(0.12), shape: BoxShape.circle), alignment: Alignment.center,
                              child: Text(initial, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Constant.primaryColor))),
                            const SizedBox(width: 12),
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(item?.email ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xff100629))),
                              const SizedBox(height: 2),
                              Text('\${item?.qty} transaksi', style: const TextStyle(fontSize: 11, color: Color(0xff8A93A3))),
                            ])),
                            const SizedBox(width: 8),
                            Text(Utils.thousandSeparator(int.parse(item?.harga ?? '0')), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Constant.primaryColor)),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    Widget buyerTransaction() {
      final items = model?.tbuyer ?? [];
      final preview = items.take(3).toList();
      return Container(
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 18, offset: const Offset(0, 6))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
              decoration: BoxDecoration(
                gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
                  colors: [Constant.primaryColor.withOpacity(0.07), Constant.primaryColor.withOpacity(0.13)]),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  Container(width: 38, height: 38,
                    decoration: BoxDecoration(color: Constant.primaryColor.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
                    child: Icon(Icons.people_alt_rounded, color: Constant.primaryColor, size: 20)),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Transaksi Buyer', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xff100629))),
                    const SizedBox(height: 2),
                    const Text('Daftar transaksi per buyer', style: TextStyle(fontSize: 11, color: Color(0xff96A5B8))),
                  ])),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(color: Constant.primaryColor.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
                    child: Text('${items.length} buyer', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Constant.primaryColor)),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xffF0F0F0)),
            if (items.isEmpty)
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 16),
                child: Text('Belum ada data', style: TextStyle(color: Color(0xff8A93A3), fontSize: 13)),
              )
            else
              ...List.generate(preview.length, (i) {
                final item = preview[i];
                final isLast = i == preview.length - 1 && items.length <= 3;
                final initial = (item?.email ?? '-').isNotEmpty ? (item?.email ?? '-')[0].toUpperCase() : '?';
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      child: Row(
                        children: [
                          Container(width: 34, height: 34,
                            decoration: BoxDecoration(color: Constant.primaryColor.withOpacity(0.12), shape: BoxShape.circle),
                            alignment: Alignment.center,
                            child: Text(initial, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Constant.primaryColor))),
                          const SizedBox(width: 12),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(item?.email ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xff100629))),
                            const SizedBox(height: 2),
                            Text('${item?.qty} transaksi', style: const TextStyle(fontSize: 11, color: Color(0xff8A93A3))),
                          ])),
                          const SizedBox(width: 8),
                          Text(Utils.thousandSeparator(int.parse(item?.harga ?? '0')), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Constant.primaryColor)),
                        ],
                      ),
                    ),
                    if (!isLast) const Divider(height: 1, indent: 60, endIndent: 16, color: Color(0xffF0F0F0)),
                  ],
                );
              }),
            if (items.length > 3)
              GestureDetector(
                onTap: () => _showBuyerSheet(items),
                child: Container(
                  margin: const EdgeInsets.fromLTRB(16, 4, 16, 14),
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  decoration: BoxDecoration(
                    color: Constant.primaryColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Constant.primaryColor.withOpacity(0.2)),
                  ),
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text('Lihat Selengkapnya', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Constant.primaryColor)),
                    const SizedBox(width: 4),
                    Icon(Icons.arrow_forward_rounded, size: 14, color: Constant.primaryColor),
                  ]),
                ),
              )
            else
              const SizedBox(height: 8),
          ],
        ),
      );
    }

    Widget productSellingGraph() {
      return Container(
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header gradient accent ──
            Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xffFFF8EF), Color(0xffFFF3E4)],
                ),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: const Color(0xffFF9900).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.shopping_bag_rounded,
                      color: Color(0xffF58B2B),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Jumlah Pembelian Barang',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xff100629),
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Trend bulanan per produk',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xff96A5B8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      SizedBox(
                          width: 18,
                          child: Image.asset(Assets.iconsIcQuantityLegend)),
                      const SizedBox(width: 5),
                      const Text(
                        'Qty',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xffF58B2B),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Divider(height: 1, color: Color(0xffF0F0F0)),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: HomeAdminGraphView(),
            ),
            const SizedBox(height: 12),
          ],
        ),
      );
    }

    Widget totalTransactionGraph() {
      return Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header gradient accent ──
            Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xffF0FFF9), Color(0xffDCFCE7)],
                ),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: const Color(0xff1ABC62).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.receipt_long_rounded,
                      color: Color(0xff1ABC62),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Jumlah Transaksi Seluruh Buyer',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xff100629),
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Ringkasan transaksi buyer',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xff96A5B8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xff1ABC62).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Live',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Color(0xff1ABC62),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Divider(height: 1, color: Color(0xffF0F0F0)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: HomeAdminTransactionGraph(),
            ),
            const SizedBox(height: 12),
          ],
        ),
      );
    }

    void _showFavouriteSheet(List items) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        isDismissible: true,
        enableDrag: true,
        barrierColor: Colors.black.withOpacity(0.5),
        backgroundColor: Colors.transparent,
        builder: (_) => DraggableScrollableSheet(
          initialChildSize: 0.6,
          maxChildSize: 0.92,
          minChildSize: 0.4,
          builder: (_, sc) => Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                const SizedBox(height: 10),
                Container(width: 40, height: 4, decoration: BoxDecoration(color: Color(0xffE4E6EF), borderRadius: BorderRadius.circular(4))),
                const SizedBox(height: 14),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Container(width: 36, height: 36, decoration: BoxDecoration(color: const Color(0xffFFF4DE), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.star_rounded, color: Color(0xffFF947A), size: 18)),
                      const SizedBox(width: 10),
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Text('Produk Terfavorit', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xff100629))),
                        Text('${items.length} produk', style: const TextStyle(fontSize: 12, color: Color(0xffFF947A))),
                      ]),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const Divider(height: 1, color: Color(0xffF0F0F0)),
                Expanded(
                  child: ListView.separated(
                    controller: sc,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const Divider(height: 1, indent: 56, endIndent: 16, color: Color(0xffF0F0F0)),
                    itemBuilder: (_, i) {
                      final item = items[i];
                      final rankColors = [Color(0xffFFD700), Color(0xffC0C0C0), Color(0xffCD7F32)];
                      final rankColor = i < 3 ? rankColors[i] : const Color(0xffE4E6EF);
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        child: Row(
                          children: [
                            Container(width: 30, height: 30, decoration: BoxDecoration(color: rankColor.withOpacity(0.15), shape: BoxShape.circle), alignment: Alignment.center,
                              child: Text('#${i+1}', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: rankColor))),
                            const SizedBox(width: 12),
                            Expanded(child: Text(item?.nama ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xff100629)))),
                            const SizedBox(width: 8),
                            Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: const Color(0xffF5F6FA), borderRadius: BorderRadius.circular(8)),
                              child: Text('${item?.qty} pcs', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xff6D7588)))),
                            const SizedBox(width: 8),
                            Text(Utils.thousandSeparator(int.parse(item?.harga ?? '0')), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xffFF947A))),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    Widget favouriteProduct() {
      final items = model?.tproduk ?? [];
      final preview = items.take(3).toList();
      return Container(
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 18, offset: const Offset(0, 6))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
              decoration: const BoxDecoration(
                gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
                  colors: [Color(0xffFFFBF5), Color(0xffFFF4DE)]),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  Container(width: 38, height: 38, decoration: BoxDecoration(color: const Color(0xffFF947A).withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.star_rounded, color: Color(0xffFF947A), size: 20)),
                  const SizedBox(width: 12),
                  const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Produk Terfavorit', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xff100629))),
                    SizedBox(height: 2),
                    Text('Ranking produk paling banyak dibeli', style: TextStyle(fontSize: 11, color: Color(0xff96A5B8))),
                  ])),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(color: const Color(0xffFF947A).withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
                    child: Text('${items.length} produk', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xffFF947A))),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xffF0F0F0)),
            if (items.isEmpty)
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 16),
                child: Text('Belum ada data', style: TextStyle(color: Color(0xff8A93A3), fontSize: 13)),
              )
            else
              ...List.generate(preview.length, (i) {
                final item = preview[i];
                final isLast = i == preview.length - 1 && items.length <= 3;
                final rankColors = [Color(0xffFFD700), Color(0xffC0C0C0), Color(0xffCD7F32)];
                final rankColor = i < 3 ? rankColors[i] : const Color(0xffE4E6EF);
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      child: Row(
                        children: [
                          Container(width: 30, height: 30, decoration: BoxDecoration(color: rankColor.withOpacity(0.15), shape: BoxShape.circle), alignment: Alignment.center,
                            child: Text('#${i+1}', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: rankColor))),
                          const SizedBox(width: 12),
                          Expanded(child: Text(item?.nama ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xff100629)))),
                          const SizedBox(width: 8),
                          Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: const Color(0xffF5F6FA), borderRadius: BorderRadius.circular(8)),
                            child: Text('${item?.qty} pcs', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xff6D7588)))),
                          const SizedBox(width: 8),
                          Text(Utils.thousandSeparator(int.parse(item?.harga ?? '0')), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xffFF947A))),
                        ],
                      ),
                    ),
                    if (!isLast) const Divider(height: 1, indent: 56, endIndent: 16, color: Color(0xffF0F0F0)),
                  ],
                );
              }),
            if (items.length > 3)
              GestureDetector(
                onTap: () => _showFavouriteSheet(items),
                child: Container(
                  margin: const EdgeInsets.fromLTRB(16, 4, 16, 14),
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  decoration: BoxDecoration(
                    color: const Color(0xffFF947A).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xffFF947A).withOpacity(0.2)),
                  ),
                  child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text('Lihat Selengkapnya', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xffFF947A))),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_forward_rounded, size: 14, color: Color(0xffFF947A)),
                  ]),
                ),
              )
            else
              const SizedBox(height: 8),
          ],
        ),
      );
    }


    void _showSellerSheet(List items) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        isDismissible: true,
        enableDrag: true,
        barrierColor: Colors.black.withOpacity(0.5),
        backgroundColor: Colors.transparent,
        builder: (_) => DraggableScrollableSheet(
          initialChildSize: 0.6,
          maxChildSize: 0.92,
          minChildSize: 0.4,
          builder: (_, sc) => Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                const SizedBox(height: 10),
                Container(width: 40, height: 4, decoration: BoxDecoration(color: Color(0xffE4E6EF), borderRadius: BorderRadius.circular(4))),
                const SizedBox(height: 14),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Container(width: 36, height: 36, decoration: BoxDecoration(color: const Color(0xffF3E8FF), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.storefront_rounded, color: Color(0xff9B59B6), size: 18)),
                      const SizedBox(width: 10),
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Text('Penjualan Seller', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xff100629))),
                        Text('${items.length} seller', style: const TextStyle(fontSize: 12, color: Color(0xff9B59B6))),
                      ]),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const Divider(height: 1, color: Color(0xffF0F0F0)),
                Expanded(
                  child: ListView.separated(
                    controller: sc,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const Divider(height: 1, indent: 60, endIndent: 16, color: Color(0xffF0F0F0)),
                    itemBuilder: (_, i) {
                      final item = items[i];
                      final initial = (item?.email ?? '-').isNotEmpty ? (item?.email ?? '-')[0].toUpperCase() : '?';
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        child: Row(
                          children: [
                            Container(width: 34, height: 34, decoration: const BoxDecoration(color: Color(0xffF3E8FF), shape: BoxShape.circle), alignment: Alignment.center,
                              child: Text(initial, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xff9B59B6)))),
                            const SizedBox(width: 12),
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(item?.email ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xff100629))),
                              const SizedBox(height: 2),
                              Text('${item?.qty} penjualan', style: const TextStyle(fontSize: 11, color: Color(0xff8A93A3))),
                            ])),
                            const SizedBox(width: 8),
                            Text(Utils.thousandSeparator(int.parse(item?.harga ?? '0')), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xff9B59B6))),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    Widget sellerTransaction() {
      final items = model?.tseller ?? [];
      final preview = items.take(3).toList();
      return Container(
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 18, offset: const Offset(0, 6))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
              decoration: const BoxDecoration(
                gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
                  colors: [Color(0xffFDF5FF), Color(0xffF3E8FF)]),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  Container(width: 38, height: 38, decoration: BoxDecoration(color: const Color(0xff9B59B6).withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.storefront_rounded, color: Color(0xff9B59B6), size: 20)),
                  const SizedBox(width: 12),
                  const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Penjualan Seller', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xff100629))),
                    SizedBox(height: 2),
                    Text('Rekap penjualan per seller', style: TextStyle(fontSize: 11, color: Color(0xff96A5B8))),
                  ])),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(color: const Color(0xff9B59B6).withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
                    child: Text('${items.length} seller', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xff9B59B6))),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xffF0F0F0)),
            if (items.isEmpty)
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 16),
                child: Text('Belum ada data', style: TextStyle(color: Color(0xff8A93A3), fontSize: 13)),
              )
            else
              ...List.generate(preview.length, (i) {
                final item = preview[i];
                final isLast = i == preview.length - 1 && items.length <= 3;
                final initial = (item?.email ?? '-').isNotEmpty ? (item?.email ?? '-')[0].toUpperCase() : '?';
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      child: Row(
                        children: [
                          Container(width: 34, height: 34, decoration: const BoxDecoration(color: Color(0xffF3E8FF), shape: BoxShape.circle), alignment: Alignment.center,
                            child: Text(initial, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xff9B59B6)))),
                          const SizedBox(width: 12),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(item?.email ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xff100629))),
                            const SizedBox(height: 2),
                            Text('${item?.qty} penjualan', style: const TextStyle(fontSize: 11, color: Color(0xff8A93A3))),
                          ])),
                          const SizedBox(width: 8),
                          Text(Utils.thousandSeparator(int.parse(item?.harga ?? '0')), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xff9B59B6))),
                        ],
                      ),
                    ),
                    if (!isLast) const Divider(height: 1, indent: 60, endIndent: 16, color: Color(0xffF0F0F0)),
                  ],
                );
              }),
            if (items.length > 3)
              GestureDetector(
                onTap: () => _showSellerSheet(items),
                child: Container(
                  margin: const EdgeInsets.fromLTRB(16, 4, 16, 14),
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  decoration: BoxDecoration(
                    color: const Color(0xff9B59B6).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xff9B59B6).withOpacity(0.2)),
                  ),
                  child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text('Lihat Selengkapnya', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xff9B59B6))),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_forward_rounded, size: 14, color: Color(0xff9B59B6)),
                  ]),
                ),
              )
            else
              const SizedBox(height: 8),
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
          color: const Color(0xffF5F6FA),
          child: RefreshIndicator(
            onRefresh: () async {
              await getData();
            },
            child: ListView(
              padding: const EdgeInsets.only(bottom: 24),
              children: [
                // ── Filter Card ──────────────────────────────────
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // ── Header ──
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 3,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    color: Constant.primaryColor,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Filter Data',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xff100629),
                                  ),
                                ),
                              ],
                            ),
                            // Badge selected periode
                            if (p.selectedPeriodeData != null &&
                                p.selectedPeriodeData != '0')
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color:
                                      Constant.primaryColor.withOpacity(0.10),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  p.periodeData.entries
                                      .firstWhere(
                                        (e) => e.value == p.selectedPeriodeData,
                                        orElse: () => const MapEntry('', ''),
                                      )
                                      .key,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: Constant.primaryColor,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),

                      // ── Periode Chip Row ──
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'PERIODE',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Color(0xff8A93A3),
                                letterSpacing: 0.8,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: p.periodeData.entries
                                  .map((entry) {
                                final isSelected =
                                    p.selectedPeriodeData == entry.value;
                                final isLast =
                                    entry.key == p.periodeData.keys.last;
                                return Expanded(
                                  child: Padding(
                                    padding:
                                        EdgeInsets.only(right: isLast ? 0 : 6),
                                    child: GestureDetector(
                                      onTap: () async {
                                        final v = entry.value;
                                        if (v == '1') await harian();
                                        if (v == '2') await bulanan();
                                        if (v == '3') await tahunan();
                                        p.selectedPeriodeData = v;
                                        await context
                                            .read<AdminHomeProvider>()
                                            .fetchHome(withLoading: true);
                                        setState(() {});
                                        log('SELECTED DATE: ' +
                                            p.selectedDate.toString());
                                        log('SELECTED MONTH: ' +
                                            p.selectedMonth.toString());
                                        log('SELECTED YEAR: ' +
                                            p.selectedYear.toString());
                                      },
                                      child: AnimatedContainer(
                                        duration:
                                            const Duration(milliseconds: 180),
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 9),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? Constant.primaryColor
                                              : const Color(0xffF5F6FA),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          border: Border.all(
                                            color: isSelected
                                                ? Constant.primaryColor
                                                : const Color(0xffE4E6EF),
                                            width: isSelected ? 1.5 : 1,
                                          ),
                                        ),
                                        child: Text(
                                          entry.key,
                                          textAlign: TextAlign.center,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color: isSelected
                                                ? Colors.white
                                                : const Color(0xff6D7588),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Divider(height: 1, color: Color(0xffF0F0F0)),
                      ),
                      const SizedBox(height: 14),

                      // ── Segmented Toggle Seller / Buyer ──
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'FILTER BERDASARKAN',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Color(0xff8A93A3),
                                letterSpacing: 0.8,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: const Color(0xffF5F6FA),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: const Color(0xffE4E6EF), width: 1),
                              ),
                              child: Row(
                                children: [
                                  // Seller
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        if (p.filterType != 0) {
                                          setState(() => p.filterType = 0);
                                          p.selectedSellerBuyer = null;
                                          p.selectedSellerBuyerId = null;
                                          p.fetchSellers(withLoading: true);
                                        }
                                      },
                                      child: AnimatedContainer(
                                        duration:
                                            const Duration(milliseconds: 200),
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10),
                                        decoration: BoxDecoration(
                                          color: p.filterType == 0
                                              ? Colors.white
                                              : Colors.transparent,
                                          borderRadius:
                                              BorderRadius.circular(9),
                                          boxShadow: p.filterType == 0
                                              ? [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(0.08),
                                                    blurRadius: 8,
                                                    offset:
                                                        const Offset(0, 2),
                                                  ),
                                                ]
                                              : [],
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.storefront_rounded,
                                              size: 14,
                                              color: p.filterType == 0
                                                  ? Constant.primaryColor
                                                  : const Color(0xff8A93A3),
                                            ),
                                            const SizedBox(width: 5),
                                            Text(
                                              'Seller',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: p.filterType == 0
                                                    ? FontWeight.w700
                                                    : FontWeight.w500,
                                                color: p.filterType == 0
                                                    ? Constant.primaryColor
                                                    : const Color(0xff8A93A3),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Buyer
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        if (p.filterType != 1) {
                                          setState(() => p.filterType = 1);
                                          p.selectedSellerBuyer = null;
                                          p.selectedSellerBuyerId = null;
                                          p.fetchBuyers(withLoading: true);
                                        }
                                      },
                                      child: AnimatedContainer(
                                        duration:
                                            const Duration(milliseconds: 200),
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10),
                                        decoration: BoxDecoration(
                                          color: p.filterType == 1
                                              ? Colors.white
                                              : Colors.transparent,
                                          borderRadius:
                                              BorderRadius.circular(9),
                                          boxShadow: p.filterType == 1
                                              ? [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(0.08),
                                                    blurRadius: 8,
                                                    offset:
                                                        const Offset(0, 2),
                                                  ),
                                                ]
                                              : [],
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.person_rounded,
                                              size: 14,
                                              color: p.filterType == 1
                                                  ? Constant.primaryColor
                                                  : const Color(0xff8A93A3),
                                            ),
                                            const SizedBox(width: 5),
                                            Text(
                                              'Buyer',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: p.filterType == 1
                                                    ? FontWeight.w700
                                                    : FontWeight.w500,
                                                color: p.filterType == 1
                                                    ? Constant.primaryColor
                                                    : const Color(0xff8A93A3),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // ── Search Dropdown ──
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'PILIH ${p.filterType == 0 ? 'SELLER' : 'BUYER'}',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Color(0xff8A93A3),
                                letterSpacing: 0.8,
                              ),
                            ),
                            const SizedBox(height: 8),
                            CustomDropdown.searchDropdown(
                              list: p.userData
                                  .map((e) => e.name1 ?? '-')
                                  .toList(),
                              hintText:
                                  'Cari ${p.filterType == 0 ? 'seller' : 'buyer'}...',
                              onChanged: (v) {
                                var index = p.userData
                                    .indexWhere((e) => e.name1 == v);
                                if (index != -1 &&
                                    p.userData[index].id != null) {
                                  setState(() {
                                    p.selectedSellerBuyer = v;
                                    p.selectedSellerBuyerId =
                                        p.userData[index].id;
                                  });
                                }
                              },
                              selectedItem: p.selectedSellerBuyer,
                              borderColor: const Color(0xffE4E6EF),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),

                      // ── Tombol Filter & Reset ──
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  handleTap(() async {
                                    await getData();
                                    setState(() {});
                                  });
                                },
                                child: Container(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 13),
                                  decoration: BoxDecoration(
                                    color: Constant.primaryColor,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Constant.primaryColor
                                            .withOpacity(0.28),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.tune_rounded,
                                          size: 15, color: Colors.white),
                                      SizedBox(width: 6),
                                      Text(
                                        'Terapkan Filter',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            GestureDetector(
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
                              child: Container(
                                padding: const EdgeInsets.all(13),
                                decoration: BoxDecoration(
                                  color: const Color(0xffF5F6FA),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(0xffE4E6EF),
                                    width: 1,
                                  ),
                                ),
                                child: Icon(
                                  Icons.refresh_rounded,
                                  size: 18,
                                  color: Constant.primaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Stats ─────────────────────────────────────────
                headerInfo2(),
                // ── Graphs ────────────────────────────────────────
                productSellingGraph(),
                totalTransactionGraph(),
                // ── Tables ────────────────────────────────────────
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
      backgroundColor: Colors.white,
      appBar: appBar(),
      body: body(),
    );
  }
}
