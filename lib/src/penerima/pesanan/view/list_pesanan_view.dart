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
      backgroundColor: const Color(0xFFF5F5F7), // Apple style background
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            refresh();
          },
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, 24, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // HEADER
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [Constant.primaryColor, Colors.orangeAccent],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.white,
                        backgroundImage: AssetImage(Assets.iconsIcSellerProfile),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Selamat datang,',
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.2,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            userName,
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.3,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Consumer<NotifikasiPenerimaProvider>(
                      builder: (context, npProvider, child) {
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 10,
                                spreadRadius: 1,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: IconButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => NotificationPenerimaView(),
                                ),
                              );
                            },
                            icon: Badge(
                              isLabelVisible: npProvider.unreadCount.toString() != '0',
                              label: Text(npProvider.unreadCount.toString()),
                              offset: const Offset(8, -4),
                              backgroundColor: Constant.primaryColor,
                              child: Icon(Icons.notifications_none_rounded, color: Colors.black87),
                            ),
                          ),
                        );
                      },
                    ),
                    SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 10,
                            spreadRadius: 1,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.logout_rounded, color: Colors.redAccent, size: 22),
                        onPressed: () async {
                          SharedPreferences prefs = await SharedPreferences.getInstance();
                          final isAdmin = await prefs.getBool(Constant.kSetPrefIsAdmin) ?? false;
                          if (isAdmin) {
                            _showLogoutBottomSheet(context);
                          } else {
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
                          }
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 32),
                
                // SEARCH BAR
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 20,
                        spreadRadius: 0,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: searchC,
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
                    textInputAction: TextInputAction.search,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    decoration: InputDecoration(
                      hintText: 'Cari nomor order...',
                      hintStyle: TextStyle(color: Colors.black38, fontWeight: FontWeight.w400),
                      prefixIcon: const Icon(Icons.search_rounded, color: Colors.black38),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.transparent,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                    ),
                  ),
                ),
                SizedBox(height: 24),
                
                // TITLE
                Text(
                  'Daftar Pesanan',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                    letterSpacing: 0.2,
                  ),
                ),
                SizedBox(height: 16),
                
                // LIST VIEW
                Expanded(
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 24),
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
                        borderRadius: BorderRadius.circular(16),
                        child: OrderItem(
                          bgColor: Colors.transparent, // Color is handled inside OrderItem
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
