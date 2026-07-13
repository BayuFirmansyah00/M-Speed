import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mspeed/common/base/base_state.dart';
import 'package:mspeed/common/component/custom_navigator.dart';
import 'package:mspeed/common/helper/constant.dart';
import 'package:mspeed/generated/assets.dart';
import 'package:mspeed/src/admin/user/view/user_data_admin_view.dart';

class UserAdminView extends StatefulWidget {
  const UserAdminView({super.key});

  @override
  State<UserAdminView> createState() => _UserAdminViewState();
}

class _UserAdminViewState extends BaseState<UserAdminView> {
  @override
  Widget build(BuildContext context) {
    // ─── Data menu ───────────────────────────────────────────────────
    final menus = [
      _UserMenu(
        title: 'Buyer',
        subtitle: 'Kelola data pengguna buyer',
        icon: Icons.shopping_bag_rounded,
        gradient: [const Color(0xff3B82F6), const Color(0xff1D4ED8)],
        onTap: () => CusNav.nPush(context, UserDataAdminView(userType: UserDataType.BUYER)),
      ),
      _UserMenu(
        title: 'Seller',
        subtitle: 'Kelola data vendor / seller',
        icon: Icons.storefront_rounded,
        gradient: [const Color(0xff10B981), const Color(0xff059669)],
        onTap: () => CusNav.nPush(context, UserDataAdminView(userType: UserDataType.SELLER)),
      ),
      _UserMenu(
        title: 'Data Finance',
        subtitle: 'Kelola data keuangan',
        icon: Icons.account_balance_rounded,
        gradient: [const Color(0xffF59E0B), const Color(0xffD97706)],
        onTap: () => CusNav.nPush(context, UserDataAdminView(userType: UserDataType.FINANCE)),
      ),
      _UserMenu(
        title: 'Data Penerima',
        subtitle: 'Kelola data penerima barang',
        icon: Icons.person_pin_rounded,
        gradient: [const Color(0xff8B5CF6), const Color(0xff7C3AED)],
        onTap: () => CusNav.nPush(context, UserDataAdminView(userType: UserDataType.PENERIMA)),
      ),
      _UserMenu(
        title: 'Data Manager',
        subtitle: 'Kelola data manager platform',
        icon: Icons.manage_accounts_rounded,
        gradient: [const Color(0xffEC4899), const Color(0xffBE185D)],
        onTap: () => CusNav.nPush(context, UserDataAdminView(userType: UserDataType.MANAGER)),
      ),
      _UserMenu(
        title: 'Data Audit',
        subtitle: 'Kelola data auditor / pengawas',
        icon: Icons.fact_check_rounded,
        gradient: [const Color(0xff14B8A6), const Color(0xff0F766E)],
        onTap: () => CusNav.nPush(context, UserDataAdminView(userType: UserDataType.AUDIT)),
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xffF5F6FA),
      body: CustomScrollView(
        slivers: [
          // ── Modern Gradient SliverAppBar ──
          SliverAppBar(
            expandedHeight: 140,
            floating: false,
            pinned: true,
            automaticallyImplyLeading: false,
            backgroundColor: Constant.primaryColor,
            surfaceTintColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Constant.primaryColor,
                      Constant.primaryColor.withOpacity(0.75),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -30, top: -30,
                      child: Container(
                        width: 150, height: 150,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.07),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Positioned(
                      left: -20, bottom: -20,
                      child: Container(
                        width: 100, height: 100,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 56, 20, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: SvgPicture.asset(
                                  Assets.svgsIsAdminUsers,
                                  width: 20, height: 20,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Manajemen User',
                                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
                                  SizedBox(height: 2),
                                  Text('Kelola semua data pengguna sistem',
                                    style: TextStyle(fontSize: 12, color: Colors.white70)),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── User Count Badge ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: Row(
                children: [
                  Container(
                    width: 3, height: 16,
                    decoration: BoxDecoration(
                      color: Constant.primaryColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text('Kategori User',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xff100629))),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Constant.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('${menus.length} kategori',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Constant.primaryColor)),
                  ),
                ],
              ),
            ),
          ),

          // ── Menu List (matching Transaksi & Master style) ──
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _UserMenuCard(menu: menus[i]),
                ),
                childCount: menus.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Data class ──────────────────────────────────────────────────────────────
class _UserMenu {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> gradient;
  final VoidCallback onTap;
  const _UserMenu({required this.title, required this.subtitle, required this.icon, required this.gradient, required this.onTap});
}

// ─── Card Widget (matching Transaksi style) ──────────────────────────────────
class _UserMenuCard extends StatefulWidget {
  final _UserMenu menu;
  const _UserMenuCard({required this.menu});

  @override
  State<_UserMenuCard> createState() => _UserMenuCardState();
}

class _UserMenuCardState extends State<_UserMenuCard> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 120));
    _scale = Tween<double>(begin: 1.0, end: 0.97).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final m = widget.menu;
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) { _ctrl.reverse(); m.onTap(); },
      onTapCancel: () => _ctrl.reverse(),
      child: AnimatedBuilder(
        animation: _scale,
        builder: (_, child) => Transform.scale(scale: _scale.value, child: child),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 16, offset: const Offset(0, 4)),
            ],
          ),
          child: Row(
            children: [
              // Left gradient strip with icon
              Container(
                width: 80,
                height: 88,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                    colors: m.gradient,
                  ),
                  borderRadius: const BorderRadius.horizontal(left: Radius.circular(20)),
                ),
                child: Center(
                  child: Icon(m.icon, color: Colors.white, size: 30),
                ),
              ),
              const SizedBox(width: 16),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(m.title,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xff100629))),
                    const SizedBox(height: 4),
                    Text(m.subtitle,
                      style: const TextStyle(fontSize: 12, color: Color(0xff8A93A3))),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: m.gradient[0].withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.arrow_forward_rounded, color: m.gradient[0], size: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
