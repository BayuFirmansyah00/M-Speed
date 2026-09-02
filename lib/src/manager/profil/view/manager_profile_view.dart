import 'package:flutter/material.dart';
import 'package:mspeed/common/base/base_state.dart';
import 'package:mspeed/common/component/custom_navigator.dart';
import 'package:mspeed/src/admin/user/provider/admin_user_provider.dart';
import 'package:mspeed/src/auth/provider/auth_provider.dart';
import 'package:mspeed/src/manager/pesanan/provider/manager_provider.dart';
import 'package:mspeed/utils/utils.dart';
import 'package:provider/provider.dart';

// ── Brand Colors ───────────────────────────────────────────────────────────
const Color _kPrimary = Color(0xFF1D4ED8);
const Color _kBg = Color(0xFFF8FAFC);
const Color _kSurface = Color(0xFFFFFFFF);
const Color _kTextPrimary = Color(0xFF1F2937);
const Color _kTextSecondary = Color(0xFF6B7280);
const Color _kBorder = Color(0xFFE5E7EB);
const Color _kDanger = Color(0xFFDC2626);

class ManagerProfileView extends StatefulWidget {
  const ManagerProfileView({super.key});

  @override
  State<ManagerProfileView> createState() => _ManagerProfileViewState();
}

class _ManagerProfileViewState extends BaseState<ManagerProfileView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ManagerProvider>().loadProfile();
    });
  }

  Future<void> _handleBackToAdmin() async {
    await Utils.showYesNoDialog(
      context: context,
      title: 'Kembali ke Admin',
      desc: 'Apakah Anda yakin ingin mengakhiri sesi impersonate dan kembali ke dashboard admin?',
      yesCallback: () async {
        CusNav.nPop(context);
        await context.read<AdminUserProvider>().backToAdmin(context);
      },
      noCallback: () => CusNav.nPop(context),
    );
  }

  Future<void> _handleLogout() async {
    await Utils.showYesNoDialog(
      context: context,
      title: 'Konfirmasi Keluar',
      desc: 'Apakah Anda yakin ingin keluar dari akun Manager?',
      yesCallback: () async {
        CusNav.nPop(context);
        await context.read<AuthProvider>().logout();
        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
        }
      },
      noCallback: () => CusNav.nPop(context),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ManagerProvider>();

    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        backgroundColor: _kSurface,
        surfaceTintColor: _kSurface,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Profil Manager',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: _kTextPrimary,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: _kBorder),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
        children: [
          // ── Impersonate Banner (if active) ───────────────────────────
          if (p.isImpersonated) ...[
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFFCD34D)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.swap_horiz_rounded, color: Color(0xFFB45309), size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        'Sesi Impersonate Aktif',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF92400E),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Anda saat ini sedang login sebagai Manager melalui akun Administrator.',
                    style: TextStyle(fontSize: 12, color: Color(0xFF78350F)),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _handleBackToAdmin,
                      icon: const Icon(Icons.arrow_back_rounded, size: 16),
                      label: const Text('Kembali ke Dashboard Admin'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFB45309),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // ── Profile Card ─────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _kSurface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _kBorder),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF1D4ED8), Color(0xFF3B82F6)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      _getInitials(p.managerName),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Name & Role
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p.managerName,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: _kTextPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        p.managerEmail.isNotEmpty ? p.managerEmail : '-',
                        style: const TextStyle(fontSize: 12, color: _kTextSecondary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: _kPrimary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          p.managerRole,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: _kPrimary,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ── Menu Section ─────────────────────────────────────────────
          Container(
            decoration: BoxDecoration(
              color: _kSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _kBorder),
            ),
            child: Column(
              children: [
                _MenuItem(
                  icon: Icons.person_outline_rounded,
                  title: 'Informasi Akun',
                  subtitle: p.managerEmail.isNotEmpty ? p.managerEmail : 'Data profil Manager',
                  onTap: () {
                    Utils.showSuccess(msg: 'Nama: ${p.managerName}\nRole: ${p.managerRole}');
                  },
                ),
                const Divider(height: 1, color: _kBorder),
                _MenuItem(
                  icon: Icons.shield_outlined,
                  title: 'Hak Akses & Otoritas',
                  subtitle: 'Persetujuan Pesanan & Tagihan Buyer',
                  onTap: () {},
                ),
                const Divider(height: 1, color: _kBorder),
                _MenuItem(
                  icon: Icons.info_outline_rounded,
                  title: 'Tentang M-Speed',
                  subtitle: 'Versi 2.0 (Mobile App)',
                  onTap: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ── Action Buttons ───────────────────────────────────────────
          if (p.isImpersonated)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: _kSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.amber.shade300),
              ),
              child: _MenuItem(
                icon: Icons.swap_horiz_rounded,
                iconColor: const Color(0xFFB45309),
                title: 'Kembali ke Admin',
                subtitle: 'Selesaikan sesi impersonate',
                onTap: _handleBackToAdmin,
              ),
            ),

          Container(
            decoration: BoxDecoration(
              color: _kSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _kBorder),
            ),
            child: _MenuItem(
              icon: Icons.logout_rounded,
              iconColor: _kDanger,
              title: 'Keluar dari Akun',
              titleColor: _kDanger,
              subtitle: 'Logout dari aplikasi M-Speed',
              onTap: _handleLogout,
            ),
          ),
        ],
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return 'M';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }
}

// ── Menu Item Widget ───────────────────────────────────────────────────────
class _MenuItem extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final String title;
  final Color? titleColor;
  final String subtitle;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    this.iconColor,
    required this.title,
    this.titleColor,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: (iconColor ?? _kPrimary).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor ?? _kPrimary, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: titleColor ?? _kTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 11, color: _kTextSecondary),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: _kTextSecondary, size: 20),
          ],
        ),
      ),
    );
  }
}
