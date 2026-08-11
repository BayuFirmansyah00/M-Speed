import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mspeed/common/base/base_state.dart';
import 'package:mspeed/common/component/custom_navigator.dart';
import 'package:mspeed/common/helper/constant.dart';
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

class AkunSayaView extends StatefulWidget {
  @override
  State<AkunSayaView> createState() => _AkunSayaViewState();
}

class _AkunSayaViewState extends BaseState<AkunSayaView> {
  String userId = '';
  String _name = '';
  String _email = '';
  String _initials = '';
  AkunSayaBuyerModel userModel = AkunSayaBuyerModel();

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
    _initData();
  }

  Future<void> _initData() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getString(Constant.kSetPrefId) ?? '';

    final first = prefs.getString(Constant.kSetPrefFirstName) ?? '';
    final last = prefs.getString(Constant.kSetPrefLastName) ?? '';
    final email = prefs.getString(Constant.kSetPrefEmail) ?? '—';
    final fullName = '$first $last'.trim();

    final parts = fullName.trim().split(' ');
    String initials = '';
    if (parts.isNotEmpty && parts[0].isNotEmpty) initials += parts[0][0];
    if (parts.length > 1 && parts[1].isNotEmpty) initials += parts[1][0];

    if (mounted) {
      setState(() {
        _name = fullName.isNotEmpty ? fullName : 'Pengguna';
        _email = email;
        _initials = initials.toUpperCase();
      });

      final p = context.read<ProfileProvider>();
      if (p.akunBuyerModel.data == null || p.akunBuyerModel.result != 'success') {
        p.fetchBuyer(context, withLoading: false, idBuyer: userId);
      }

      List<String> years = List.generate(2024 - 1900 + 1, (i) => (1900 + i).toString());
      if (p.timeList == null || p.timeList!.isEmpty) {
        for (int i = years.length - 1; i >= 0; i--) p.timeList?.add(years[i]);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    userModel = context.watch<ProfileProvider>().akunBuyerModel;

    return Scaffold(
      backgroundColor: Constant.dsBackground,
      appBar: AppBar(
        backgroundColor: Constant.dsSurface,
        elevation: 0,
        titleSpacing: Constant.space16,
        centerTitle: false,
        title: const Text(
          'Akun Saya',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Constant.dsTextPrimary,
          ),
        ),
      ),
      body: RefreshIndicator(
        color: Constant.dsPrimary,
        backgroundColor: Constant.dsSurface,
        onRefresh: () async {
          await context.read<ProfileProvider>().fetchBuyer(
                context,
                withLoading: false,
                idBuyer: userId,
              );
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(Constant.space16, Constant.space16, Constant.space16, 120),
          child: Column(
            children: [
              _buildHeaderCard(),
              const SizedBox(height: Constant.space24),
              _buildOrderStats(),
              const SizedBox(height: Constant.space24),
              _buildMenuGroup(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(Constant.space16),
      decoration: BoxDecoration(
        color: Constant.dsSurface,
        borderRadius: BorderRadius.circular(Constant.radiusLg),
        boxShadow: [Constant.shadowSmall],
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Constant.dsPrimary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                _initials.isNotEmpty ? _initials : '?',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: Constant.space16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _name.isNotEmpty ? _name : 'Memuat...',
                  style: TextStyle(
                    fontFamily: Constant.primaryTextStyle.fontFamily,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Constant.dsTextPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: Constant.space4),
                Text(
                  _email,
                  style: TextStyle(
                    fontFamily: Constant.primaryTextStyle.fontFamily,
                    fontSize: 13,
                    color: Constant.dsTextSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: Constant.space8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Constant.dsPrimary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(Constant.radiusXs),
                  ),
                  child: const Text(
                    'Member',
                    style: TextStyle(
                      color: Constant.dsPrimary,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderStats() {
    final totals = [
      userModel.data?.pesananBaru ?? "0",
      userModel.data?.pesananDiterima ?? "0",
      userModel.data?.pesananDikirim ?? "0",
      userModel.data?.barangDiterima?.toString() ?? "0",
      userModel.data?.prosesPembayaran?.toString() ?? "0",
      userModel.data?.telahDibayar ?? "0",
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Pesanan Saya',
              style: TextStyle(
                fontFamily: Constant.primaryTextStyle.fontFamily,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Constant.dsTextPrimary,
              ),
            ),
            GestureDetector(
              onTap: () {
                CusNav.nPush(context, const TransactionListView(initialRoute: 0));
              },
              child: const Text(
                'Lihat Semua',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Constant.dsPrimary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: Constant.space12),
        Container(
          padding: const EdgeInsets.all(Constant.space16),
          decoration: BoxDecoration(
            color: Constant.dsSurface,
            borderRadius: BorderRadius.circular(Constant.radiusLg),
            boxShadow: [Constant.shadowSmall],
          ),
          child: Wrap(
            spacing: 12,
            runSpacing: 16,
            alignment: WrapAlignment.spaceBetween,
            children: List.generate(6, (index) {
              return GestureDetector(
                onTap: () {
                  CusNav.nPush(context, TransactionListView(initialRoute: index));
                },
                child: SizedBox(
                  width: (MediaQuery.of(context).size.width - 32 - 32 - 24) / 3, // 3 columns
                  child: Column(
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Constant.dsBackground,
                              shape: BoxShape.circle,
                            ),
                            child: Image.asset(imgStatus[index]),
                          ),
                          if (totals[index] != "0")
                            Positioned(
                              top: -4,
                              right: -4,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Constant.dsSecondary,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  totals[index],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: Constant.space8),
                      Text(
                        statusName[index],
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        style: TextStyle(
                          fontFamily: Constant.primaryTextStyle.fontFamily,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Constant.dsTextPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuGroup() {
    final List<_MenuItem> menus = [
      _MenuItem(
        title: 'Pengaturan',
        icon: Icons.settings_rounded,
        onTap: () => CusNav.nPush(context, const SettingsView()),
      ),
      _MenuItem(
        title: 'Logout',
        icon: Icons.logout_rounded,
        isDestructive: true,
        onTap: _handleLogout,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pusat Bantuan & Pengaturan',
          style: TextStyle(
            fontFamily: Constant.primaryTextStyle.fontFamily,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Constant.dsTextPrimary,
          ),
        ),
        const SizedBox(height: Constant.space12),
        Container(
          decoration: BoxDecoration(
            color: Constant.dsSurface,
            borderRadius: BorderRadius.circular(Constant.radiusLg),
            boxShadow: [Constant.shadowSmall],
          ),
          child: Column(
            children: menus.map((m) => _buildMenuTile(m, m == menus.last)).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuTile(_MenuItem m, bool isLast) {
    return InkWell(
      onTap: m.onTap,
      borderRadius: isLast
          ? const BorderRadius.vertical(bottom: Radius.circular(Constant.radiusLg))
          : BorderRadius.zero,
      child: Container(
        decoration: BoxDecoration(
          border: isLast ? null : const Border(bottom: BorderSide(color: Constant.dsDivider, width: 1)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: Constant.space16, vertical: Constant.space16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: m.isDestructive ? Constant.dsSecondary.withValues(alpha: 0.1) : Constant.dsPrimary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(Constant.radiusSm),
              ),
              child: Icon(
                m.icon,
                size: 20,
                color: m.isDestructive ? Constant.dsSecondary : Constant.dsPrimary,
              ),
            ),
            const SizedBox(width: Constant.space16),
            Expanded(
              child: Text(
                m.title,
                style: TextStyle(
                  fontFamily: Constant.primaryTextStyle.fontFamily,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: m.isDestructive ? Constant.dsSecondary : Constant.dsTextPrimary,
                ),
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Constant.dsTextSecondary, size: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _handleLogout() async {
    final prefs = await SharedPreferences.getInstance();
    final isOriginalAdmin = prefs.getString('admin_original_token') != null && prefs.getString('admin_original_token')!.isNotEmpty;
    final isAdmin = (prefs.getBool(Constant.kSetPrefIsAdmin) ?? false) || isOriginalAdmin;

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
          color: Constant.dsSurface,
          borderRadius: BorderRadius.circular(28),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(color: Constant.dsBorder, borderRadius: BorderRadius.circular(10)),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Opsi Keluar',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Constant.dsTextPrimary),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Pilih tindakan yang ingin dilakukan',
                  style: TextStyle(fontSize: 13, color: Constant.dsTextSecondary),
                ),
                const SizedBox(height: 20),
                _logoutOption(
                  ctx: ctx,
                  icon: Icons.admin_panel_settings_rounded,
                  title: 'Stop Impersonate (Kembali ke Admin)',
                  color: Constant.dsPrimary,
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
                const Divider(height: 1, indent: 20, endIndent: 20, color: Constant.dsBorder),
                _logoutOption(
                  ctx: ctx,
                  icon: Icons.logout_rounded,
                  title: 'Logout Total',
                  color: Constant.dsSecondary,
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
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: isDestructive ? Constant.dsSecondary : Constant.dsTextPrimary,
                ),
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Constant.dsTextSecondary),
          ],
        ),
      ),
    );
  }
}

class _MenuItem {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final bool isDestructive;

  const _MenuItem({
    required this.title,
    required this.icon,
    required this.onTap,
    this.isDestructive = false,
  });
}
