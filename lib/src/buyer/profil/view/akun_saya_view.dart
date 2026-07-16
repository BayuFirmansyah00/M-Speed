import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mspeed/common/base/base_state.dart';
import 'package:mspeed/common/component/custom_navigator.dart';
import 'package:mspeed/common/helper/Constant.dart';
import 'package:mspeed/generated/assets.dart';
import 'package:mspeed/src/admin/user/provider/admin_user_provider.dart';
import 'package:mspeed/src/auth/provider/auth_provider.dart';
import 'package:mspeed/src/auth/view/login_view.dart';
import 'package:mspeed/src/buyer/profil/model/akun_saya_buyer_model.dart';
import 'package:mspeed/src/buyer/profil/provider/profile_provider.dart';
import 'package:mspeed/src/buyer/profil/view/settings_view.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../utils/utils.dart';
import '../../transaction/view/transaction_list_view.dart';

// ─── PALET : M-Speed Premium ──────────────────────────────────
class _C {
  static const primary   = Color(0xFFE50012); // Merah M-Speed
  static const secondary = Color(0xFF0B4177); // Biru M-Speed
  static const bg        = Color(0xFFF5F5F7); // Background Apple Grey
  static const card      = Color(0xFFFFFFFF);
  static const txt1      = Color(0xFF111827);
  static const txt2      = Color(0xFF6B7280);
  static const txt3      = Color(0xFF9CA3AF);
  static const border    = Color(0xFFEEEEEE);

  // Warna per status transaksi
  static const statusColors = [
    Color(0xFFF58B2B), // Pesanan Baru   – orange
    Color(0xFF2B64F5), // Diterima       – blue
    Color(0xFF10B981), // Dikirim        – green
    Color(0xFF8B5CF6), // Barang Diterima– purple
    Color(0xFFEC4899), // Proses Bayar   – pink
    Color(0xFF1ABC62), // Telah Dibayar  – emerald
  ];

  static const statusIcons = [
    Icons.add_shopping_cart_rounded,
    Icons.check_circle_outline_rounded,
    Icons.local_shipping_rounded,
    Icons.inventory_2_rounded,
    Icons.payment_rounded,
    Icons.verified_rounded,
  ];

  static const shadow = BoxShadow(
    color: Color(0x0D000000),
    blurRadius: 12,
    offset: Offset(0, 4),
  );
}

class AkunSayaView extends StatefulWidget {
  @override
  State<AkunSayaView> createState() => _AkunSayaViewState();
}

class _AkunSayaViewState extends BaseState<AkunSayaView>
    with SingleTickerProviderStateMixin {
  String userId = "";
  AkunSayaBuyerModel userModel = AkunSayaBuyerModel();
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  final List<String> statusName = [
    "Ps. Baru",
    "Diterima",
    "Dikirim",
    "Brg. Diterima",
    "Proses Bayar",
    "Telah Dibayar",
  ];

  final List<String> imgStatus = [
    Assets.iconsImgAkunPesananbaru,
    Assets.iconsImgAkunPesananditerima,
    Assets.iconsImgAkunPesanandikirim,
    Assets.iconsImgAkunBarangditerima,
    Assets.iconsImgAkunProsespembayaran,
    Assets.iconsImgAkunTelahdibayar,
  ];

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    initData();
  }

  Future<void> initData() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getString(Constant.kSetPrefId) ?? "";
    if (mounted) {
      final akunBuyer = context.read<ProfileProvider>().akunBuyerModel;
      if (akunBuyer.data == null || akunBuyer.result != "success") {
        context.read<ProfileProvider>().fetchBuyer(
          context,
          withLoading: false,
          idBuyer: userId,
        );
      }
      final p = context.read<ProfileProvider>();
      List<String> years = List.generate(
        2024 - 1900 + 1,
        (index) => (1900 + index).toString(),
      );
      for (int i = years.length - 1; i >= 0; i--) {
        p.timeList?.add(years[i]);
      }
      _animCtrl.forward();
    }
  }

  Future<String> getName() async {
    final prefs = await SharedPreferences.getInstance();
    String first = prefs.getString(Constant.kSetPrefFirstName) ?? "";
    String last  = prefs.getString(Constant.kSetPrefLastName) ?? "";
    return "$first $last".trim();
  }

  Future<String> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(Constant.kSetPrefEmail) ?? "—";
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    userModel = context.watch<ProfileProvider>().akunBuyerModel;

    return Scaffold(
      backgroundColor: _C.bg,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: RefreshIndicator(
          color: _C.primary,
          backgroundColor: _C.card,
          onRefresh: () async {
            await context.read<ProfileProvider>().fetchBuyer(
              context,
              withLoading: true,
              idBuyer: userId,
            );
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              _buildSliverHeader(),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    const SizedBox(height: 20),
                    _buildOrderStats(),
                    const SizedBox(height: 16),
                    _buildSettingsGroup(),
                    const SizedBox(height: 32),
                  ]),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 120)),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Sliver Header dengan gradient ───────────────────────────
  Widget _buildSliverHeader() {
    return SliverAppBar(
      expandedHeight: 240,
      pinned: false,
      floating: false,
      snap: false,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: _C.secondary,
      // Collapsed: tampilkan nama user
      title: AnimatedBuilder(
        animation: const AlwaysStoppedAnimation(0),
        builder: (context, _) {
          return FutureBuilder<String>(
            future: getName(),
            builder: (context, snap) => Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.35),
                      width: 1.5,
                    ),
                  ),
                  child: const Icon(
                    Icons.person_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  snap.data ?? 'Akun Saya',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    fontSize: 16,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          );
        },
      ),
      centerTitle: true,
      flexibleSpace: FlexibleSpaceBar(
        background: _buildProfileHeader(),
        collapseMode: CollapseMode.parallax,
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF072A5C), Color(0xFF0B4177), Color(0xFF1565C0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          // Dekorasi bulat besar kanan atas
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
          ),
          // Bulat kecil kiri tengah
          Positioned(
            bottom: 30,
            left: -40,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          // Bulat kecil tengah
          Positioned(
            top: 60,
            right: 80,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          // Garis dekoratif diagonal
          Positioned(
            bottom: -10,
            right: -20,
            child: Transform.rotate(
              angle: -0.3,
              child: Container(
                width: 150,
                height: 2,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
          // Konten utama
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 56, 24, 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Avatar dengan glowing ring
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          // Outer glow ring
                          Container(
                            width: 82,
                            height: 82,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.2),
                                width: 2,
                              ),
                            ),
                          ),
                          // Avatar
                          Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white.withValues(alpha: 0.35),
                                  Colors.white.withValues(alpha: 0.15),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.6),
                                width: 2,
                              ),
                            ),
                            child: const Icon(
                              Icons.person_rounded,
                              color: Colors.white,
                              size: 36,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Label kecil
                            Text(
                              'PROFIL SAYA',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Colors.white.withValues(alpha: 0.6),
                                letterSpacing: 1.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            // Nama user
                            FutureBuilder<String>(
                              future: getName(),
                              builder: (context, snap) => Text(
                                snap.data ?? 'Memuat...',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: -0.5,
                                  height: 1.1,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Badge member
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _C.primary.withValues(alpha: 0.85),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.2),
                                ),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.verified_rounded,
                                      size: 12, color: Colors.white),
                                  SizedBox(width: 5),
                                  Text(
                                    'Member M-Speed',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Ringkasan Transaksi ──────────────────────────────────────
  Widget _buildOrderStats() {
    List<String> statusCount = [
      userModel.data?.pesananBaru ?? '0',
      userModel.data?.pesananDiterima ?? '0',
      userModel.data?.pesananDikirim ?? '0',
      userModel.data?.barangDiterima?.toString() ?? '0',
      userModel.data?.prosesPembayaran?.toString() ?? '0',
      userModel.data?.telahDibayar ?? '0',
    ];

    return Container(
      decoration: BoxDecoration(
        color: _C.card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [_C.shadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: _C.secondary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.receipt_long_rounded,
                        size: 16,
                        color: _C.secondary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Ringkasan Transaksi',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: _C.txt1,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () => CusNav.nPush(context, TransactionListView()),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: _C.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Lihat Semua →',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _C.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 140,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: 6,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final statusColor = _C.statusColors[index];
                final count = statusCount[index];
                return GestureDetector(
                  onTap: () => CusNav.nPush(
                    context,
                    TransactionListView(initialRoute: index),
                  ),
                  child: _StatusCard(
                    image: imgStatus[index],
                    label: statusName[index],
                    count: count,
                    color: statusColor,
                    icon: _C.statusIcons[index],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // ─── Settings Group ───────────────────────────────────────────
  Widget _buildSettingsGroup() {
    return Container(
      decoration: BoxDecoration(
        color: _C.card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [_C.shadow],
      ),
      child: Column(
        children: [
          _menuTile(
            title: 'Transaksi',
            iconAsset: Assets.svgsIcTransaksi,
            subtitle: 'Kelola semua pesanan',
            color: _C.secondary,
            onTap: () => CusNav.nPush(context, TransactionListView()),
          ),
          _divider(),
          _menuTile(
            title: 'Pengaturan Akun',
            iconAsset: Assets.svgsIcPengaturanAkun,
            subtitle: 'Ubah profil & lokasi',
            color: const Color(0xFF10B981),
            onTap: () => CusNav.nPush(context, SettingsView()),
          ),
          _divider(),
          _menuTile(
            title: 'Logout',
            iconAsset: Assets.svgsIcLogout,
            subtitle: 'Keluar dari akun',
            color: _C.primary,
            isDestructive: true,
            onTap: _handleLogout,
          ),
        ],
      ),
    );
  }

  Widget _divider() =>
      const Divider(height: 1, indent: 72, endIndent: 16, color: _C.border);

  Widget _menuTile({
    required String title,
    required String iconAsset,
    required VoidCallback onTap,
    String subtitle = '',
    Color color = _C.txt1,
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: SvgPicture.asset(
                  iconAsset,
                  width: 20,
                  colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isDestructive ? _C.primary : _C.txt1,
                    ),
                  ),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 12, color: _C.txt2),
                    ),
                  ],
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: _C.bg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.chevron_right_rounded,
                color: _C.txt3,
                size: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleLogout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final isAdmin = prefs.getBool(Constant.kSetPrefIsAdmin) ?? false;

    if (isAdmin) {
      _showLogoutBottomSheet(context);
    } else {
      Utils.showYesNoDialog(
        context: context,
        title: "Konfirmasi",
        desc: "Apakah Anda yakin ingin keluar?",
        yesCallback: () async {
          await context.read<AuthProvider>().logout();
          if (mounted) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => LoginView()),
              (Route<dynamic> route) => false,
            );
          }
        },
        noCallback: () => Navigator.pop(context),
      );
    }
  }

  void _showLogoutBottomSheet(BuildContext context) {
    showModalBottomSheet(
      backgroundColor: _C.card,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext bsContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: _C.border,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Opsi Keluar',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _C.txt1,
                  ),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _C.secondary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.admin_panel_settings_rounded,
                      color: _C.secondary,
                    ),
                  ),
                  title: const Text(
                    'Kembali ke Admin',
                    style: TextStyle(fontWeight: FontWeight.w600, color: _C.txt1),
                  ),
                  subtitle: const Text(
                    'Beralih ke mode administrator',
                    style: TextStyle(fontSize: 12, color: _C.txt2),
                  ),
                  onTap: () {
                    Navigator.pop(bsContext);
                    Utils.showYesNoDialog(
                      context: context,
                      title: "Konfirmasi",
                      desc: "Apakah Anda Yakin ingin kembali ke Admin?",
                      yesCallback: () async {
                        await context.read<AdminUserProvider>().backToAdmin(context);
                      },
                      noCallback: () => Navigator.pop(context),
                    );
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _C.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.logout_rounded, color: _C.primary),
                  ),
                  title: const Text(
                    'Logout Total',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: _C.primary,
                    ),
                  ),
                  subtitle: const Text(
                    'Keluar dari semua sesi',
                    style: TextStyle(fontSize: 12, color: _C.txt2),
                  ),
                  onTap: () {
                    Navigator.pop(bsContext);
                    Utils.showYesNoDialog(
                      context: context,
                      title: "Konfirmasi",
                      desc: "Apakah Anda Yakin ingin keluar sepenuhnya?",
                      yesCallback: () async {
                        await context.read<AuthProvider>().logout();
                        if (mounted) {
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            '/login',
                            (route) => false,
                          );
                        }
                      },
                      noCallback: () => Navigator.pop(context),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─── Status Card Widget ───────────────────────────────────────
class _StatusCard extends StatelessWidget {
  final String image;
  final String label;
  final String count;
  final Color color;
  final IconData icon;

  const _StatusCard({
    required this.image,
    required this.label,
    required this.count,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 88,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Center(child: Image.asset(image, width: 22, fit: BoxFit.contain)),
          ),
          const SizedBox(height: 6),
          Text(
            count,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 9.5,
              color: _C.txt2,
              fontWeight: FontWeight.w500,
              height: 1.3,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
