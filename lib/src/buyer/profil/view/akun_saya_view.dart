import 'dart:ui';
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

// ─── PALET WARNA ──────────────────────────────────────────────
class _C {
  static const primary   = Color(0xFFE50012);
  static const primaryBg = Color(0xFFFFEBED);
  static const navy      = Color(0xFF0B1F4E);
  static const bg        = Color(0xFFF4F6FB);
  static const card      = Color(0xFFFFFFFF);
  static const txt1      = Color(0xFF0D1117);
  static const txt2      = Color(0xFF4A5568);
  static const txt3      = Color(0xFF9AA5B1);
  static const border    = Color(0xFFEEF0F5);

  static const statusColors = [
    Color(0xFFF59E0B), // Pesanan Baru    – amber
    Color(0xFF3B82F6), // Diterima        – blue
    Color(0xFF10B981), // Dikirim         – green
    Color(0xFF8B5CF6), // Barang Diterima – purple
    Color(0xFFEC4899), // Proses Bayar    – pink
    Color(0xFF059669), // Telah Dibayar   – emerald
  ];


  static BoxShadow get shadow => const BoxShadow(
    color: Color(0x0E000000),
    blurRadius: 16,
    offset: Offset(0, 6),
  );

  static BoxShadow get shadowPrimary => BoxShadow(
    color: primary.withValues(alpha: 0.28),
    blurRadius: 18,
    offset: const Offset(0, 6),
  );
}

// ─── MAIN VIEW ────────────────────────────────────────────────
class AkunSayaView extends StatefulWidget {
  @override
  State<AkunSayaView> createState() => _AkunSayaViewState();
}

class _AkunSayaViewState extends BaseState<AkunSayaView>
    with TickerProviderStateMixin {
  String userId    = '';
  String _name     = '';
  String _email    = '';
  String _initials = '';
  AkunSayaBuyerModel userModel = AkunSayaBuyerModel();

  late AnimationController _entranceCtrl;
  late AnimationController _pulseCtrl;
  late Animation<double>   _fadeAnim;
  late Animation<double>   _slideAnim;
  late Animation<double>   _pulseAnim;

  final List<String> statusName = [
    'Ps. Baru',
    'Diterima',
    'Dikirim',
    'Brg. Diterima',
    'Proses Bayar',
    'Telah Dibayar',
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
    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _fadeAnim  = CurvedAnimation(parent: _entranceCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<double>(begin: 30, end: 0).animate(
      CurvedAnimation(parent: _entranceCtrl, curve: Curves.easeOutCubic),
    );
    _pulseAnim = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    _initData();
  }

  Future<void> _initData() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getString(Constant.kSetPrefId) ?? '';

    final first = prefs.getString(Constant.kSetPrefFirstName) ?? '';
    final last  = prefs.getString(Constant.kSetPrefLastName)  ?? '';
    final email = prefs.getString(Constant.kSetPrefEmail)     ?? '—';
    final fullName = '$first $last'.trim();

    // Inisial dari nama
    final parts = fullName.trim().split(' ');
    String initials = '';
    if (parts.isNotEmpty && parts[0].isNotEmpty) initials += parts[0][0];
    if (parts.length > 1 && parts[1].isNotEmpty) initials += parts[1][0];

    if (mounted) {
      setState(() {
        _name     = fullName.isNotEmpty ? fullName : 'Pengguna';
        _email    = email;
        _initials = initials.toUpperCase();
      });

      final p = context.read<ProfileProvider>();
      if (p.akunBuyerModel.data == null || p.akunBuyerModel.result != 'success') {
        p.fetchBuyer(context, withLoading: false, idBuyer: userId);
      }

      List<String> years = List.generate(2024 - 1900 + 1, (i) => (1900 + i).toString());
      for (int i = years.length - 1; i >= 0; i--) p.timeList?.add(years[i]);

      _entranceCtrl.forward();
    }
  }

  @override
  void dispose() {
    _entranceCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    userModel = context.watch<ProfileProvider>().akunBuyerModel;

    return Scaffold(
      backgroundColor: _C.bg,
      body: RefreshIndicator(
        color: _C.primary,
        backgroundColor: _C.card,
        strokeWidth: 2.5,
        displacement: 48,
        onRefresh: () async {
          await context.read<ProfileProvider>().fetchBuyer(
            context,
            withLoading: false,
            idBuyer: userId,
          );
        },
        child: FadeTransition(
          opacity: _fadeAnim,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            slivers: [
              _buildSliverAppBar(),
              SliverToBoxAdapter(
                child: AnimatedBuilder(
                  animation: _slideAnim,
                  builder: (_, child) => Transform.translate(
                    offset: Offset(0, _slideAnim.value),
                    child: child,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        _buildOrderStats(),
                        const SizedBox(height: 14),
                        _buildMenuGroup(),
                        const SizedBox(height: 120),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── SLIVER APP BAR ───────────────────────────────────────────
  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 260,
      pinned: true,
      floating: false,
      snap: false,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: _C.navy,
      title: Text(
        _name.isNotEmpty ? _name : 'Akun Saya',
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          letterSpacing: -0.2,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      centerTitle: true,
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.parallax,
        background: _buildProfileBanner(),
      ),
    );
  }

  // ─── PROFILE BANNER ───────────────────────────────────────────
  Widget _buildProfileBanner() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF060F2E), Color(0xFF0B1F4E), Color(0xFF1A3A7C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          // ── Dekorasi pattern ────────────────────────────────
          _circle(size: 240, x: -80, y: -80, alpha: 0.05),
          _circle(size: 160, x: null, xRight: -40, y: null, yBottom: -40, alpha: 0.06),
          _circle(size: 70, x: null, xRight: 90, y: 60, alpha: 0.08),
          // Garis dekoratif
          Positioned(
            top: 120,
            left: 0,
            right: 0,
            child: Container(
              height: 1,
              color: Colors.white.withValues(alpha: 0.04),
            ),
          ),
          // ── Konten utama ────────────────────────────────────
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Avatar dengan pulse ring
                      _buildAvatar(),
                      const SizedBox(width: 20),
                      Expanded(child: _buildUserInfo()),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // ── Info bar bawah ──────────────────────────
                  _buildInfoBar(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return AnimatedBuilder(
      animation: _pulseAnim,
      builder: (_, child) => Container(
        width: 84,
        height: 84,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: _C.primary.withValues(alpha: 0.3 * (_pulseAnim.value - 0.9) / 0.2),
              blurRadius: 24,
              spreadRadius: 4,
            ),
          ],
        ),
        child: child,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer ring animasi
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.15),
                width: 2,
              ),
            ),
          ),
          // Avatar circle
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFFE50012), Color(0xFFFF4D5B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [_C.shadowPrimary],
              border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 2),
            ),
            child: Center(
              child: Text(
                _initials.isNotEmpty ? _initials : '?',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PROFIL SAYA',
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            color: Colors.white.withValues(alpha: 0.5),
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _name,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: -0.5,
            height: 1.1,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Icon(Icons.mail_outline_rounded, size: 10, color: Colors.white),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                _email,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.white.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        // Member badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFE50012), Color(0xFFFF4D5B)],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [_C.shadowPrimary],
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.verified_rounded, size: 11, color: Colors.white),
              SizedBox(width: 5),
              Text(
                'Member M-Speed',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 0.3),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoBar() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.15), width: 1),
          ),
          child: Row(
            children: [
              const Icon(Icons.person_outline_rounded, size: 14, color: Colors.white70),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'ID Pengguna: $userId',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => CusNav.nPush(context, TransactionListView()),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Lihat Transaksi →',
                    style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── RINGKASAN TRANSAKSI ──────────────────────────────────────
  Widget _buildOrderStats() {
    final statusCount = [
      userModel.data?.pesananBaru       ?? '0',
      userModel.data?.pesananDiterima   ?? '0',
      userModel.data?.pesananDikirim    ?? '0',
      userModel.data?.barangDiterima?.toString()   ?? '0',
      userModel.data?.prosesPembayaran?.toString() ?? '0',
      userModel.data?.telahDibayar      ?? '0',
    ];

    return Container(
      decoration: BoxDecoration(
        color: _C.card,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [_C.shadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header section
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0B1F4E), Color(0xFF1A3A7C)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: const Icon(Icons.receipt_long_rounded, size: 18, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Status Transaksi',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: _C.txt1),
                        ),
                        SizedBox(height: 1),
                        Text('Pantau semua pesananmu', style: TextStyle(fontSize: 11, color: _C.txt3)),
                      ],
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () => CusNav.nPush(context, TransactionListView()),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _C.primaryBg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      children: [
                        Text('Semua', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: _C.primary)),
                        SizedBox(width: 3),
                        Icon(Icons.arrow_forward_ios_rounded, size: 9, color: _C.primary),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Status grid 3x2
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 6,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1.0,
              ),
              itemBuilder: (ctx, i) {
                final color = _C.statusColors[i];
                return GestureDetector(
                  onTap: () => CusNav.nPush(ctx, TransactionListView(initialRoute: i)),
                  child: AnimatedBuilder(
                    animation: _entranceCtrl,
                    builder: (_, child) {
                      final delay = (0.2 + i * 0.07).clamp(0.0, 0.95);
                      final t = CurvedAnimation(
                        parent: _entranceCtrl,
                        curve: Interval(delay, (delay + 0.4).clamp(0.0, 1.0), curve: Curves.easeOutBack),
                      );
                      return Transform.scale(
                        scale: t.value.clamp(0.0, 1.0),
                        child: Opacity(opacity: t.value.clamp(0.0, 1.0), child: child),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.07),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: color.withValues(alpha: 0.18), width: 1),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Image.asset(imgStatus[i], width: 20, fit: BoxFit.contain),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            statusCount[i],
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: color,
                              height: 1,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            statusName[i],
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 9,
                              color: _C.txt2,
                              fontWeight: FontWeight.w600,
                              height: 1.2,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ─── MENU GROUP ───────────────────────────────────────────────
  Widget _buildMenuGroup() {
    final menuItems = [
      _MenuItem(
        title: 'Transaksi',
        subtitle: 'Kelola semua pesanan',
        iconAsset: Assets.svgsIcTransaksi,
        gradientColors: const [Color(0xFF0B1F4E), Color(0xFF1A3A7C)],
        onTap: () => CusNav.nPush(context, TransactionListView()),
      ),
      _MenuItem(
        title: 'Pengaturan Akun',
        subtitle: 'Ubah profil & data diri',
        iconAsset: Assets.svgsIcPengaturanAkun,
        gradientColors: const [Color(0xFF059669), Color(0xFF10B981)],
        onTap: () => CusNav.nPush(context, SettingsView()),
      ),
      _MenuItem(
        title: 'Logout',
        subtitle: 'Keluar dari akun',
        iconAsset: Assets.svgsIcLogout,
        gradientColors: const [Color(0xFFE50012), Color(0xFFFF4D5B)],
        isDestructive: true,
        onTap: _handleLogout,
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: _C.card,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [_C.shadow],
      ),
      child: Column(
        children: List.generate(menuItems.length, (i) {
          final m = menuItems[i];
          return Column(
            children: [
              _buildMenuTile(m, index: i),
              if (i < menuItems.length - 1)
                const Divider(height: 1, indent: 72, endIndent: 16, color: _C.border),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildMenuTile(_MenuItem m, {required int index}) {
    return AnimatedBuilder(
      animation: _entranceCtrl,
      builder: (_, child) {
        final delay = (0.5 + index * 0.08).clamp(0.0, 0.95);
        final t = CurvedAnimation(
          parent: _entranceCtrl,
          curve: Interval(delay, (delay + 0.4).clamp(0.0, 1.0), curve: Curves.easeOut),
        );
        return Transform.translate(
          offset: Offset(30 * (1 - t.value), 0),
          child: Opacity(opacity: t.value.clamp(0.0, 1.0), child: child),
        );
      },
      child: InkWell(
        onTap: m.onTap,
        borderRadius: index == 0
            ? const BorderRadius.vertical(top: Radius.circular(24))
            : index == 2
                ? const BorderRadius.vertical(bottom: Radius.circular(24))
                : BorderRadius.zero,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              // Gradient icon
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: m.gradientColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: m.gradientColors[0].withValues(alpha: 0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: SvgPicture.asset(
                    m.iconAsset,
                    width: 20,
                    colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      m.title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: m.isDestructive ? _C.primary : _C.txt1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      m.subtitle,
                      style: const TextStyle(fontSize: 12, color: _C.txt3, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: _C.bg,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Icon(Icons.chevron_right_rounded, color: _C.txt3, size: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── LOGOUT HANDLER ───────────────────────────────────────────
  Future<void> _handleLogout() async {
    final prefs = await SharedPreferences.getInstance();
    final isAdmin = prefs.getBool(Constant.kSetPrefIsAdmin) ?? false;

    if (isAdmin) {
      _showLogoutBottomSheet(context);
    } else {
      Utils.showYesNoDialog(
        context: context,
        title: 'Konfirmasi Logout',
        desc: 'Apakah Anda yakin ingin keluar dari akun?',
        yesCallback: () async {
          await context.read<AuthProvider>().logout();
          if (mounted) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => LoginView()),
              (route) => false,
            );
          }
        },
        noCallback: () => Navigator.pop(context),
      );
    }
  }

  void _showLogoutBottomSheet(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        margin: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _C.card,
          borderRadius: BorderRadius.circular(28),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40, height: 5,
                  decoration: BoxDecoration(color: _C.border, borderRadius: BorderRadius.circular(10)),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Opsi Keluar',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: _C.txt1),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Pilih tindakan yang ingin dilakukan',
                  style: TextStyle(fontSize: 13, color: _C.txt3),
                ),
                const SizedBox(height: 20),
                _logoutOption(
                  ctx: ctx,
                  icon: Icons.admin_panel_settings_rounded,
                  title: 'Kembali ke Admin',
                  subtitle: 'Beralih ke mode administrator',
                  color: _C.navy,
                  onTap: () {
                    Navigator.pop(ctx);
                    Utils.showYesNoDialog(
                      context: context,
                      title: 'Konfirmasi',
                      desc: 'Apakah Anda yakin ingin kembali ke Admin?',
                      yesCallback: () async {
                        await context.read<AdminUserProvider>().backToAdmin(context);
                      },
                      noCallback: () => Navigator.pop(context),
                    );
                  },
                ),
                const Divider(height: 1, indent: 20, endIndent: 20, color: _C.border),
                _logoutOption(
                  ctx: ctx,
                  icon: Icons.logout_rounded,
                  title: 'Logout Total',
                  subtitle: 'Keluar dari semua sesi',
                  color: _C.primary,
                  isDestructive: true,
                  onTap: () {
                    Navigator.pop(ctx);
                    Utils.showYesNoDialog(
                      context: context,
                      title: 'Konfirmasi',
                      desc: 'Apakah Anda yakin ingin keluar sepenuhnya?',
                      yesCallback: () async {
                        await context.read<AuthProvider>().logout();
                        if (mounted) {
                          Navigator.pushNamedAndRemoveUntil(context, '/login', (r) => false);
                        }
                      },
                      noCallback: () => Navigator.pop(context),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _logoutOption({
    required BuildContext ctx,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: isDestructive ? _C.primary : _C.txt1)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(fontSize: 12, color: _C.txt3)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: _C.txt3),
          ],
        ),
      ),
    );
  }

  // Helper: dekoratif lingkaran transparan
  Widget _circle({
    required double size,
    double? x,
    double? xRight,
    double? y,
    double? yBottom,
    required double alpha,
  }) {
    return Positioned(
      left: x,
      right: xRight,
      top: y,
      bottom: yBottom,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: alpha),
        ),
      ),
    );
  }
}

// ─── DATA MODEL MENU ──────────────────────────────────────────
class _MenuItem {
  final String title;
  final String subtitle;
  final String iconAsset;
  final List<Color> gradientColors;
  final VoidCallback onTap;
  final bool isDestructive;

  const _MenuItem({
    required this.title,
    required this.subtitle,
    required this.iconAsset,
    required this.gradientColors,
    required this.onTap,
    this.isDestructive = false,
  });
}
