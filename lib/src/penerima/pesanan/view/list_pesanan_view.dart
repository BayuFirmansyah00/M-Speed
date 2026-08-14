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
  String userId = "";
  String userName = "";
  final searchC = TextEditingController();

  @override
  void initState() {
    super.initState();
    initData();
  }

  Future<void> initData() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getString(Constant.kSetPrefId) ?? "";
    userName = prefs.getString(Constant.kSetPrefFirstName) ?? "";

    if (!mounted) return;

    // Hindari concurrent withLoading: true yang memicu multiple loading overlay.
    final pesananP = context.read<PenerimaPesananProvider>();
    final notifP = context.read<NotifikasiPenerimaProvider>();

    await pesananP.fetchTransaction(withLoading: true);
    // Notifikasi di-load tanpa loading agar tidak memblokir UI.
    notifP.fetchNotification(withLoading: false);
  }

  void refresh() {
    final pesananP = context.read<PenerimaPesananProvider>();
    final notifP = context.read<NotifikasiPenerimaProvider>();

    pesananP.fetchTransaction(withLoading: true).then((_) {
      notifP.fetchNotification(withLoading: false);
    });
  }

  List<PesananPenerimaModelData?> _filterOrders(
    List<PesananPenerimaModelData?>? source,
    String query,
  ) {
    if (source == null) return [];
    if (query.trim().isEmpty) return source;
    final lower = query.toLowerCase();
    return source
        .where((e) =>
            (e?.nomorOrder?.toLowerCase().contains(lower) ?? false) ||
            (e?.nama?.toLowerCase().contains(lower) ?? false))
        .toList();
  }

  Widget _buildOption(String title, String path, GestureTapCallback? onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: FittedBox(child: Image.asset(path)),
            ),
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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext modalContext) {
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => CusNav.nPop(modalContext),
                  ),
                  const Text(
                    'Opsi',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildOption(
                'Login Admin',
                Assets.imagesIcLoginAdmin,
                () async {
                  Navigator.pop(modalContext);
                  Utils.showYesNoDialog(
                    context: context,
                    title: "Konfirmasi",
                    desc: "Apakah Anda Yakin ingin kembali ke Admin",
                    yesCallback: () async {
                      await context.read<AdminUserProvider>().backToAdmin(context);
                    },
                    noCallback: () => CusNav.nPop(context),
                  );
                },
              ),
              _buildOption(
                'Logout',
                Assets.imagesIcLogoutToAdmin,
                () async {
                  Navigator.pop(modalContext);
                  Utils.showYesNoDialog(
                    context: context,
                    title: 'Konfirmasi',
                    desc: 'Apakah Anda yakin?',
                    noCallback: () => Navigator.pop(context),
                    yesCallback: () async {
                      Navigator.pushNamedAndRemoveUntil(
                          context, '/login', (route) => false);
                    },
                  );
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<PenerimaPesananProvider>();
    final source = p.pesananPenerimaModel.data ?? [];
    final listPesanan = _filterOrders(source, searchC.text);

    final total = source.length;
    final proses = source.where((e) {
      final s = e?.status ?? '';
      return s == 'PESANAN_BARU' ||
          s == 'PESANAN_DITERIMA' ||
          s == 'PESANAN_DIKIRIM' ||
          s == 'PROSES_PEMBAYARAN' ||
          s == 'TELAH_DIBAYAR' ||
          s == 'pesanan baru' ||
          s == 'approve pesanan by manager' ||
          s == 'pesanan diterima penjual' ||
          s == 'pesanan dikirim' ||
          s == 'siap tagih by manager' ||
          s == 'penerimaan & verifikasi';
    }).length;
    final selesai = source.where((e) {
      final s = e?.status ?? '';
      return s == 'BARANG_DITERIMA' || s == 'PESANAN_SELESAI' || s == 'pesanan diterima penerima' || s == 'pesanan dibayar';
    }).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      body: SafeArea(
        child: RefreshIndicator(
          color: Constant.primaryColor,
          backgroundColor: Colors.white,
          onRefresh: () async => refresh(),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
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
                      child: const CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.white,
                        backgroundImage: AssetImage(Assets.iconsIcSellerProfile),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Selamat datang,',
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.2,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            userName,
                            style: const TextStyle(
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
                                color: Colors.black.withValues(alpha: 0.04),
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
                                  builder: (context) =>
                                      const NotificationPenerimaView(),
                                ),
                              );
                            },
                            icon: Badge(
                              isLabelVisible:
                                  npProvider.unreadCount.toString() != '0',
                              label: Text(npProvider.unreadCount.toString()),
                              offset: const Offset(8, -4),
                              backgroundColor: Constant.primaryColor,
                              child: const Icon(Icons.notifications_none_rounded,
                                  color: Colors.black87),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 10,
                            spreadRadius: 1,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.logout_rounded,
                            color: Colors.redAccent, size: 22),
                        onPressed: () async {
                          final prefs =
                              await SharedPreferences.getInstance();
                          final isAdmin =
                              prefs.getBool(Constant.kSetPrefIsAdmin) ?? false;
                          if (isAdmin) {
                            _showLogoutBottomSheet(context);
                          } else {
                            Utils.showYesNoDialog(
                    context: context,
                    title: 'Konfirmasi',
                    desc: 'Apakah Anda yakin?',
                    noCallback: () => Navigator.pop(context),
                    yesCallback: () async {
                                await context.read<AuthProvider>().logout();
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => LoginView()),
                                  (Route<dynamic> route) => false,
                                );
                              },
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // SUMMARY CARDS
                Row(
                  children: [
                    _buildStatCard(
                      label: 'Total',
                      value: total,
                      icon: Icons.receipt_long_rounded,
                      color: Constant.primaryColor,
                    ),
                    const SizedBox(width: 10),
                    _buildStatCard(
                      label: 'Proses',
                      value: proses,
                      icon: Icons.local_shipping_rounded,
                      color: const Color(0xFF0B4177),
                    ),
                    const SizedBox(width: 10),
                    _buildStatCard(
                      label: 'Selesai',
                      value: selesai,
                      icon: Icons.check_circle_rounded,
                      color: const Color(0xFF16A34A),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // SEARCH BAR
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 20,
                        spreadRadius: 0,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: searchC,
                    onChanged: (_) => setState(() {}),
                    textInputAction: TextInputAction.search,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w500),
                    decoration: InputDecoration(
                      hintText: 'Cari nomor order atau penjual...',
                      hintStyle: TextStyle(
                          color: Colors.black38,
                          fontWeight: FontWeight.w400),
                      prefixIcon: const Icon(Icons.search_rounded,
                          color: Colors.black38),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.transparent,
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 14, horizontal: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // TITLE
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Daftar Pesanan',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                        letterSpacing: 0.2,
                      ),
                    ),
                    Text(
                      '${listPesanan.length} pesanan',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.black.withValues(alpha: 0.4),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // LIST VIEW
                Expanded(
                  child: listPesanan.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.only(bottom: 100),
                          itemCount: listPesanan.length,
                          itemBuilder: (context, index) {
                            final item = listPesanan[index];
                            return InkWell(
                              key: ValueKey(item?.ID ?? index),
                              onTap: () {
                                CusNav.nPush(
                                  context,
                                  PenerimaPesananDetailView(
                                    transaction_id: item?.ID ?? '0',
                                    seller_id: item?.SellerID ?? '0',
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(16),
                              child: OrderItem(
                                bgColor: Colors.transparent,
                                orderNumber: item?.nomorOrder ?? "-",
                                date: item?.Created ?? "-",
                                sellerName: item?.nama ?? "-",
                                status: TransactionStatus.fromString(
                                    item?.status ?? "PESANAN_BARU"),
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

  Widget _buildStatCard({
    required String label,
    required int value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 16,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 16, color: color),
            ),
            const SizedBox(height: 10),
            Text(
              '$value',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: color,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.black.withValues(alpha: 0.45),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 80),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.04),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.receipt_long_outlined,
                  size: 42,
                  color: Colors.black.withValues(alpha: 0.25),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Belum ada pesanan',
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Pesanan yang ditugaskan kepada Anda\nakan muncul di sini',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black.withValues(alpha: 0.45),
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
