import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mspeed/common/base/base_state.dart';
import 'package:mspeed/common/component/custom_navigator.dart';
import 'package:mspeed/common/helper/Constant.dart';
import 'package:mspeed/common/helper/app_colors.dart';
import 'package:mspeed/generated/assets.dart';
import 'package:mspeed/src/admin/user/provider/admin_user_provider.dart';
import 'package:mspeed/src/auth/provider/auth_provider.dart';
import 'package:mspeed/src/auth/view/login_view.dart';
import 'package:mspeed/src/buyer/profil/model/akun_saya_buyer_model.dart';
import 'package:mspeed/src/buyer/profil/provider/profile_provider.dart';
import 'package:mspeed/src/buyer/profil/view/settings_view.dart';
import 'package:mspeed/src/buyer/cart/view/buyer_cart_view.dart';
import 'package:mspeed/src/buyer/chat/view/chat_list_view.dart';
import 'package:mspeed/src/buyer/cart/provider/buyer_cart_provider.dart';
import 'package:mspeed/src/buyer/transaction/provider/transaction_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../utils/utils.dart';
import '../../transaction/view/transaction_list_view.dart';

// ─── PALET : M-Speed Buyer Blue ───────────────────────────────
class _C {
  static Color get primary   => AppColors.buyerPrimary;
  static Color get secondary => AppColors.buyerDark;
  static const bg        = Color(0xFFF5F5F7);
  static const card      = Color(0xFFFFFFFF);
  static const txt1      = Color(0xFF111827);
  static const txt2      = Color(0xFF6B7280);
  static const txt3      = Color(0xFF9CA3AF);
  static const border    = Color(0xFFEEEEEE);

  // Warna per status transaksi (hanya 4 utama)
  static const statusColors = [
    Color(0xFF1565C0), // Pesanan Baru  – blue
    Color(0xFF10B981), // Diterima      – green
    Color(0xFFF58B2B), // Dikirim       – orange
    Color(0xFF8B5CF6), // Brg. Diterima – purple
  ];

  static const statusIcons = [
    Icons.add_shopping_cart_rounded,
    Icons.check_circle_outline_rounded,
    Icons.local_shipping_rounded,
    Icons.inventory_2_rounded,
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
  ];

  final List<String> imgStatus = [
    Assets.iconsImgAkunPesananbaru,
    Assets.iconsImgAkunPesananditerima,
    Assets.iconsImgAkunPesanandikirim,
    Assets.iconsImgAkunBarangditerima,
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
      // Fetch semua tab transaksi untuk menghitung summary counter
      // Tab 1-6: Pesanan Baru, Diterima, Dikirim, Barang Diterima, Proses Pembayaran, Telah Dibayar
      final txP = context.read<TransactionProvider>();
      for (int i = 1; i <= 6; i++) {
        txP.fetchTransaction(withLoading: false, status: i);
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
    final cartTotal = context.watch<BuyerCartProvider>().totalCartItems;

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
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                _buildProfileHeader(cartTotal),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                  child: Column(
                    children: [
                      _buildOrderStats(),
                      const SizedBox(height: 16),
                      _buildSettingsGroup(),
                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── Profile Header (Blue gradient with decorative circles) ──
  Widget _buildProfileHeader(int cartTotal) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.buyerDark,
            AppColors.buyerPrimary,
            AppColors.buyerMedium,
          ],
        ),
      ),
      child: Stack(
        children: [
          // ── Decorative circles ──
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            left: -40,
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          Positioned(
            top: 80,
            right: 60,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),

          // ── Content ──
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
              child: Column(
                children: [
                  // Top bar: centered person icon + right action buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Notification button
                      _ActionButton(
                        icon: Icons.notifications_none_rounded,
                        badge: null,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => ChatListView()),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Cart button
                      _ActionButton(
                        icon: Icons.shopping_cart_outlined,
                        badge: cartTotal > 0 ? '$cartTotal' : null,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => BuyerCartView()),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Profile row: Avatar + Name + Badge
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Avatar with ring
                      Container(
                        width: 88,
                        height: 88,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                            width: 3,
                          ),
                        ),
                        child: Container(
                          margin: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.15),
                          ),
                          child: const Icon(
                            Icons.person_rounded,
                            color: Colors.white,
                            size: 44,
                          ),
                        ),
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Profil Saya',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                                color: Colors.white.withValues(alpha: 0.7),
                              ),
                            ),
                            Builder(
                              builder: (context) {
                                final userData = userModel.data?.userData;
                                String? displayName;
                                if (userData != null) {
                                  final fullName = (userData['full_name']?.toString() ?? '').trim();
                                  if (fullName.isNotEmpty) {
                                    displayName = fullName;
                                  } else {
                                    final fName = (userData['first_name']?.toString() ?? '').trim();
                                    final lName = (userData['last_name']?.toString() ?? '').trim();
                                    final combined = "$fName $lName".trim();
                                    if (combined.isNotEmpty) displayName = combined;
                                  }
                                }

                                if (displayName != null && displayName.isNotEmpty) {
                                  return Text(
                                    'Hai, $displayName!',
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                      letterSpacing: -0.3,
                                      height: 1.2,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  );
                                }

                                return FutureBuilder<String>(
                                  future: getName(),
                                  builder: (context, snap) {
                                    final name = (snap.data != null && snap.data!.trim().isNotEmpty)
                                        ? snap.data!.trim()
                                        : 'Pengguna';
                                    return Text(
                                      'Hai, $name!',
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                        letterSpacing: -0.3,
                                        height: 1.2,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    );
                                  },
                                );
                              },
                            ),
                            const SizedBox(height: 10),
                            // Member badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.25),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.verified_rounded,
                                    size: 14,
                                    color: Colors.greenAccent.shade200,
                                  ),
                                  const SizedBox(width: 6),
                                  const Text(
                                    'Member M-Speed',
                                    style: TextStyle(
                                      fontSize: 12,
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

  // ─── Ringkasan Transaksi (4 items, grid layout) ──────────────
  Widget _buildOrderStats() {
    // Hitung counter dari TransactionProvider (data aktual dari Laravel)
    // Tab index: 1=Pesanan Baru, 2=Diterima, 3=Dikirim, 4=Barang Diterima
    final txP = context.watch<TransactionProvider>();
    final List<String> statusCount = [
      (txP.daftarTransaksi[0].data?.length ?? 0).toString(), // Ps. Baru
      (txP.daftarTransaksi[1].data?.length ?? 0).toString(), // Diterima
      (txP.daftarTransaksi[2].data?.length ?? 0).toString(), // Dikirim
      (txP.daftarTransaksi[3].data?.length ?? 0).toString(), // Brg. Diterima
    ];

    return Container(
      decoration: BoxDecoration(
        color: _C.card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [_C.shadow],
      ),
      child: Column(
        children: [
          // Header row
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _C.secondary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.receipt_long_rounded,
                    size: 18,
                    color: _C.secondary,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Ringkasan Transaksi',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: _C.txt1,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => CusNav.nPush(context, TransactionListView()),
                  child: Row(
                    children: [
                      Text(
                        'Lihat Semua',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _C.primary,
                        ),
                      ),
                      const SizedBox(width: 2),
                      Icon(Icons.chevron_right, size: 18, color: _C.primary),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          // 4-item grid
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
            child: Row(
              children: List.generate(4, (index) {
                return Expanded(
                  child: GestureDetector(
                    onTap: () => CusNav.nPush(
                      context,
                      TransactionListView(initialRoute: index),
                    ),
                    child: _StatusCard(
                      image: imgStatus[index],
                      label: statusName[index],
                      count: statusCount[index],
                      color: _C.statusColors[index],
                      icon: _C.statusIcons[index],
                    ),
                  ),
                );
              }),
            ),
          ),
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
            color: const Color(0xFF6B7280),
            onTap: () => CusNav.nPush(context, SettingsView()),
          ),
          _divider(),
          _menuTile(
            title: 'Logout',
            iconAsset: Assets.svgsIcLogout,
            subtitle: 'Keluar dari akun Anda',
            color: AppColors.error,
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: SvgPicture.asset(
                  iconAsset,
                  width: 22,
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
                      color: isDestructive ? AppColors.error : _C.txt1,
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
            Icon(
              Icons.chevron_right_rounded,
              color: _C.txt3,
              size: 22,
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
                    title: 'Konfirmasi',
                    desc: 'Apakah Anda yakin?',
                    noCallback: () => Navigator.pop(context),
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
                    child: Icon(
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
                      color: AppColors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.logout_rounded, color: AppColors.error),
                  ),
                  title: Text(
                    'Logout Total',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.error,
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
                    title: 'Konfirmasi',
                    desc: 'Apakah Anda yakin?',
                    noCallback: () => Navigator.pop(context),
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

// ─── Action Button (Notification/Cart) ─────────────────────────
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String? badge;
  final VoidCallback onTap;

  const _ActionButton({required this.icon, this.badge, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.25),
              ),
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          if (badge != null && badge != '0')
            Positioned(
              top: -2,
              right: -2,
              child: Container(
                padding: const EdgeInsets.all(4),
                constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Center(
                  child: Text(
                    badge!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      height: 1,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Status Card Widget (Grid layout) ─────────────────────────
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
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Image.asset(image, width: 24, fit: BoxFit.contain),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            count,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 10,
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
