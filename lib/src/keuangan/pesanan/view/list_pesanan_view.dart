import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:mspeed/common/base/base_state.dart';
import 'package:mspeed/common/component/custom_navigator.dart';
import 'package:mspeed/common/helper/Constant.dart';
import 'package:mspeed/generated/assets.dart';
import 'package:mspeed/src/admin/user/provider/admin_user_provider.dart';
import 'package:mspeed/src/auth/provider/auth_provider.dart';
import 'package:mspeed/src/auth/view/login_view.dart';

import 'package:mspeed/src/buyer/transaction/provider/transaction_status.dart';
import 'package:mspeed/src/keuangan/notifikasi/provider/notifikasi_keuangan_provider.dart';
import 'package:mspeed/src/keuangan/notifikasi/view/notifikasi_keuangan_view.dart';
import 'package:mspeed/src/keuangan/pesanan/model/daftar_transaksi_keuangan_model.dart';
import 'package:mspeed/src/keuangan/pesanan/provider/keuangan_provider.dart';
import 'package:mspeed/src/keuangan/pesanan/view/order_item_widget.dart';
import 'package:mspeed/src/keuangan/pesanan/view/keuangan_pesanan_detail_view.dart';
import 'package:mspeed/utils/utils.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ListPesananView extends StatefulWidget {
  const ListPesananView({super.key});

  @override
  State<ListPesananView> createState() => _ListPesananViewState();
}

class _ListPesananViewState extends BaseState<ListPesananView> {
  // String userId = "", firstName = "", lastName = "", fullName = "";
  String fullName = "";
  String userId = "";
  bool isCollapsed = false;

  @override
  void initState() {
    initData();
    super.initState();
  }

  Future<void> initData() async {
    final prefs = await SharedPreferences.getInstance();
    userId = await prefs.getString(Constant.kSetPrefId) ?? "";
    final firstName = await prefs.getString(Constant.kSetPrefFirstName) ?? "";
    final lastName = await prefs.getString(Constant.kSetPrefLastName) ?? "";
    fullName = "${firstName} ${lastName}";
    log("Isinya name : ${fullName}");

    context.read<KeuanganProvider>().fetchTransaction(withLoading: true);
    context
        .read<NotifikasiKeuanganProvider>()
        .fetchNotification(withLoading: true);
  }

  List<DaftarTransaksiKeuanganModelData?> transactions = [];
  final searchController = TextEditingController();

  void refresh() {
    context.read<KeuanganProvider>().fetchTransaction(withLoading: true);
    context
        .read<NotifikasiKeuanganProvider>()
        .fetchNotification(withLoading: true);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<KeuanganProvider>();
    if (transactions.isEmpty && searchController.text.isEmpty) {
      transactions = p.daftarTransaksi.data ?? [];
    }

    Widget _buildOption(String title, String path, GestureTapCallback? onTap) {
      return InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              SizedBox(
                  width: 18,
                  height: 18,
                  child: FittedBox(child: Image.asset(path))),
              Constant.xSizedBox8,
              Text(title),
            ],
          ),
        ),
      );
    }

    void _showLogoutBottomSheet(BuildContext context) {
      showModalBottomSheet(
        backgroundColor: Colors.white,
        context: context,
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(16), // Adjust this value as needed
          ),
        ),
        builder: (BuildContext context) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 12),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () {
                        CusNav.nPop(context);
                      },
                    ),
                    Text(
                      'Opsi',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                _buildOption(
                  'Login Admin',
                  Assets.imagesIcLoginAdmin,
                  () async {
                    handleTap(() async {
                      Utils.showYesNoDialog(
                        context: context,
                        title: "Konfirmasi",
                        desc: "Apakah Anda Yakin ingin kembali ke Admin",
                        yesCallback: () async {
                          handleTap(() async {
                            await context
                                .read<AdminUserProvider>()
                                .backToAdmin(context);
                          });
                        },
                        noCallback: () => CusNav.nPop(context),
                      );
                    });
                  },
                ),
                _buildOption(
                  'Logout',
                  Assets.imagesIcLogoutToAdmin,
                  () async {
                    handleTap(() async {
                      Utils.showYesNoDialog(
                        context: context,
                        title: "Konfirmasi",
                        desc: "Apakah Anda Yakin ingin keluar",
                        yesCallback: () async {
                          handleTap(() async {
                            Navigator.pushNamedAndRemoveUntil(
                                context, '/login', (route) => false);
                          });
                        },
                        noCallback: () => CusNav.nPop(context),
                      );
                    });
                  },
                ),
                SizedBox(height: 20),
              ],
            ),
          );
        },
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(16, 25, 16, 16),
          child: RefreshIndicator(
            onRefresh: () async {
              await context
                  .read<KeuanganProvider>()
                  .fetchTransaction(withLoading: true);
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Image.asset(Assets.iconsIcSellerProfile,
                        width: 53, height: 53),
                    SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Selamat datang',
                              style: TextStyle(
                                  color: Constant.grayColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400)),
                          Text(fullName,
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                    Consumer<NotifikasiKeuanganProvider>(
                      builder: (context, nkProvider, child) {
                        return IconButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => NotifikasiKeuanganView(),
                              ),
                            );
                          },
                          icon: Badge(
                            isLabelVisible:
                                nkProvider.unreadCount.toString() == '0'
                                    ? false
                                    : true,
                            label: Text(
                              nkProvider.unreadCount.toString(),
                            ),
                            offset: const Offset(8, -4),
                            backgroundColor: Colors.redAccent,
                            child: Image.asset(
                              Assets.iconsIcNotificationBlack,
                              width: 24,
                              color: isCollapsed ? Colors.black : Colors.black,
                            ),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.logout, color: Colors.red),
                      onPressed: () async {
                        SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        final isAdmin =
                            await prefs.getBool(Constant.kSetPrefIsAdmin) ??
                                false;
                        if (isAdmin) {
                          _showLogoutBottomSheet(context);
                        } else {
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
                                    MaterialPageRoute(
                                        builder: (context) => LoginView()),
                                    (Route<dynamic> route) => false,
                                  );
                                });
                              },
                              noCallback: () {
                                Navigator.pop(context);
                              },
                            );
                          });
                        }
                      },
                    ),
                  ],
                ),
                SizedBox(
                  height: 24,
                ),
                TextField(
                  controller: searchController,
                  onChanged: (value) {
                    setState(() {
                      transactions = p.daftarTransaksi.data
                              ?.where((element) =>
                                  element?.nomorOrder
                                      ?.toLowerCase()
                                      .contains(value.toLowerCase()) ??
                                  false)
                              .toList() ??
                          [];
                    });
                  },
                  textInputAction: TextInputAction.search, // This
                  decoration: InputDecoration(
                    hintText: 'Cari',
                    hintStyle: TextStyle(color: Color(0xFF6D7588)),
                    prefixIcon: Icon(
                      Icons.search,
                      color: Color(0xFF6D7588),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Color(0xFFEEF0F8)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Color(0xFFEEF0F8)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Color(0xFFEEF0F8)),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                SizedBox(
                  height: 12,
                ),
                Text('Daftar Pesanan',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Constant.grayColor)),
                SizedBox(
                  height: 4,
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () {
                          CusNav.nPush(
                              context,
                              KeuanganPesananDetailView(
                                transaction_id: transactions[index]?.ID ?? '0',
                              ));
                        },
                        child: OrderItem(
                          bgColor:
                              index % 2 == 0 ? Color(0xFFF6F6F6) : Colors.white,
                          orderNumber: transactions[index]?.nomorOrder ?? "-",
                          date: transactions[index]?.Created ?? "-",
                          total: transactions[index]?.total ?? "0",
                          sellerName: transactions[index]?.nama ?? "-",
                          status: TransactionStatus.fromString(
                              transactions[index]?.status ?? "PESANAN_BARU"),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
