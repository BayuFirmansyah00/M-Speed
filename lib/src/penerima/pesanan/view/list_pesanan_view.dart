import 'package:flutter/material.dart';
import 'package:mspeed/common/base/base_state.dart';
import 'package:mspeed/common/component/custom_navigator.dart';
import 'package:mspeed/common/helper/Constant.dart';
import 'package:mspeed/generated/assets.dart';
import 'package:mspeed/src/admin/user/provider/admin_user_provider.dart';
import 'package:mspeed/src/auth/provider/auth_provider.dart';
import 'package:mspeed/src/auth/view/login_view.dart';

import 'package:mspeed/src/buyer/transaction/provider/transaction_status.dart';
import 'package:mspeed/src/penerima/notifikasi/provider/notifikasi_penerima_provider.dart';
import 'package:mspeed/src/penerima/notifikasi/view/notifikasi_penerima_view.dart';
import 'package:mspeed/src/penerima/pesanan/model/pesanan_penerima_model.dart';
import 'package:mspeed/src/penerima/pesanan/provider/penerima_pesanan_provider.dart';
import 'package:mspeed/src/penerima/pesanan/view/order_item_widget.dart';
import 'package:mspeed/src/penerima/pesanan/view/penerima_pesanan_detail_view.dart';
import 'package:mspeed/utils/utils.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ListPesananView extends StatefulWidget {
  const ListPesananView({super.key});

  @override
  State<ListPesananView> createState() => _ListPesananViewState();
}

class _ListPesananViewState extends BaseState<ListPesananView> {
  String userId = "", userName = "";
  bool isCollapsed = false;

  @override
  void initState() {
    initData();
    refresh();
    super.initState();
  }

  Future<void> initData() async {
    final prefs = await SharedPreferences.getInstance();
    userId = await prefs.getString(Constant.kSetPrefId) ?? "";
    userName = await prefs.getString(Constant.kSetPrefFirstName) ?? "";
    // userName = userName;

    context.read<PenerimaPesananProvider>().fetchTransaction(withLoading: true);
    context
        .read<NotifikasiPenerimaProvider>()
        .fetchNotification(withLoading: true);
  }

  List<PesananPenerimaModelData?> listPesanan = [];
  final searchC = TextEditingController();

  void refresh() {
    context.read<PenerimaPesananProvider>().fetchTransaction(
          withLoading: true,
        );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<PenerimaPesananProvider>();
    if (listPesanan.isEmpty && searchC.text.isEmpty) {
      listPesanan = p.pesananPenerimaModel.data ?? [];
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
        child: RefreshIndicator(
          onRefresh: () async {
            refresh();
          },
          child: Padding(
            padding: EdgeInsets.fromLTRB(16, 25, 16, 16),
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
                          Text(userName,
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                    Consumer<NotifikasiPenerimaProvider>(
                      builder: (context, npProvider, child) {
                        return IconButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    NotificationPenerimaView(),
                              ),
                            );
                          },
                          icon: Badge(
                            isLabelVisible:
                                npProvider.unreadCount.toString() == '0'
                                    ? false
                                    : true,
                            label: Text(
                              npProvider.unreadCount.toString(),
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
                  controller: searchC,
                  // onSubmitted: (_) {
                  //   refresh();
                  // },
                  onChanged: (value) {
                    setState(() {
                      listPesanan = p.pesananPenerimaModel.data
                              ?.where((element) =>
                                  element?.nomorOrder
                                      ?.toLowerCase()
                                      .contains(searchC.text.toLowerCase()) ??
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
                    itemCount: listPesanan.length,
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () {
                          CusNav.nPush(
                              context,
                              PenerimaPesananDetailView(
                                transaction_id: listPesanan[index]?.ID ?? '0',
                                seller_id: listPesanan[index]?.SellerID ?? '0',
                              ));
                        },
                        child: OrderItem(
                          bgColor:
                              index % 2 == 0 ? Color(0xFFF6F6F6) : Colors.white,
                          orderNumber: listPesanan[index]?.nomorOrder ?? "-",
                          date: listPesanan[index]?.Created ?? "-",
                          sellerName: listPesanan[index]?.nama ?? "-",
                          status: TransactionStatus.fromString(
                              listPesanan[index]?.status ?? "PESANAN_BARU"),
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
