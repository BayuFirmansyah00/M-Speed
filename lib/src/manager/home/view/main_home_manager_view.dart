import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mspeed/common/helper/Constant.dart';
import 'package:mspeed/src/manager/dashboard/view/manager_dashboard_view.dart';
import 'package:mspeed/src/manager/pesanan/provider/manager_provider.dart';
import 'package:mspeed/src/manager/pesanan/view/manager_pesanan_view.dart';
import 'package:mspeed/src/manager/profil/view/manager_profile_view.dart';
import 'package:mspeed/src/manager/team/view/manager_team_view.dart';
import 'package:provider/provider.dart';

// ── Nav Item Definition ────────────────────────────────────────────────────
class _ManagerNavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _ManagerNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

/// MainHomeManagerView
/// The root scaffold for the Manager role.
/// Tabs:
///   0 → ManagerDashboardView  (Dashboard)
///   1 → ManagerPesananView    (Pesanan)
///   2 → ManagerTeamView       (Tim)
///   3 → ManagerProfileView    (Profil)
class MainHomeManagerView extends StatefulWidget {
  const MainHomeManagerView({super.key});

  @override
  State<MainHomeManagerView> createState() => _MainHomeManagerViewState();
}

class _MainHomeManagerViewState extends State<MainHomeManagerView>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  int _prevIndex = 0;
  late AnimationController _indicatorController;
  late Animation<double> _indicatorAnim;

  static const _navItems = [
    _ManagerNavItem(
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard_rounded,
      label: 'Dashboard',
    ),
    _ManagerNavItem(
      icon: Icons.receipt_long_outlined,
      activeIcon: Icons.receipt_long_rounded,
      label: 'Pesanan',
    ),
    _ManagerNavItem(
      icon: Icons.group_outlined,
      activeIcon: Icons.group_rounded,
      label: 'Tim',
    ),
    _ManagerNavItem(
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
      label: 'Profil',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _indicatorController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _indicatorAnim = Tween<double>(begin: 0, end: 0).animate(
      CurvedAnimation(parent: _indicatorController, curve: Curves.easeInOutCubic),
    );
  }

  @override
  void dispose() {
    _indicatorController.dispose();
    super.dispose();
  }

  void _onTap(int index) {
    if (index == _selectedIndex) return;
    _prevIndex = _selectedIndex;
    _indicatorAnim = Tween<double>(
      begin: _prevIndex.toDouble(),
      end: index.toDouble(),
    ).animate(
      CurvedAnimation(parent: _indicatorController, curve: Curves.easeInOutCubic),
    );
    _indicatorController.forward(from: 0);
    setState(() => _selectedIndex = index);

    final p = context.read<ManagerProvider>();
    debugPrint('[MANAGER_NAV] Selected index = $index (${_navItems[index].label})');

    if (index == 0) {
      p.fetchDashboard(withLoading: false);
    } else if (index == 1) {
      // Direct tab tap: reset filter to all
      p.filterStatus = null;
      p.fetchOrders(withLoading: false);
    } else if (index == 2) {
      p.fetchTeam(withLoading: false);
    }
  }

  void _navigateToOrdersWithFilter(String statusFilter) {
    final p = context.read<ManagerProvider>();
    p.filterStatus = statusFilter.isEmpty ? null : statusFilter;
    debugPrint('[MANAGER_NAV] Navigate from Dashboard KPI filter: "$statusFilter"');
    p.fetchOrders(withLoading: true);

    if (_selectedIndex != 1) {
      _prevIndex = _selectedIndex;
      _indicatorAnim = Tween<double>(
        begin: _prevIndex.toDouble(),
        end: 1.0,
      ).animate(
        CurvedAnimation(parent: _indicatorController, curve: Curves.easeInOutCubic),
      );
      _indicatorController.forward(from: 0);
      setState(() => _selectedIndex = 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> widgetOptions = [
      ManagerDashboardView(
        onNavigateToOrdersWithFilter: _navigateToOrdersWithFilter,
      ),
      const ManagerPesananView(),
      const ManagerTeamView(),
      const ManagerProfileView(),
    ];

    return Scaffold(
      extendBody: true,
      body: SafeArea(
        bottom: false,
        child: IndexedStack(
          index: _selectedIndex,
          children: widgetOptions,
        ),
      ),
      bottomNavigationBar: _buildNav(),
    );
  }

  Widget _buildNav() {
    final primary = Constant.primaryColor;
    final bottomPad = Platform.isIOS ? 20.0 : 12.0;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, bottomPad),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final slotWidth = constraints.maxWidth / _navItems.length;
          const inset = 4.0;

          return Container(
            height: 68,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: primary.withValues(alpha: 0.15),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: Stack(
                children: [
                  // ── Sliding gradient indicator ──────────────────────────
                  AnimatedBuilder(
                    animation: _indicatorAnim,
                    builder: (_, __) => Positioned(
                      left: _indicatorAnim.value * slotWidth + inset,
                      top: 8,
                      child: Container(
                        width: slotWidth - inset * 2,
                        height: 52,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [primary, primary.withValues(alpha: 0.82)],
                          ),
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [
                            BoxShadow(
                              color: primary.withValues(alpha: 0.4),
                              blurRadius: 14,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // ── Nav items ────────────────────────────────────────────
                  Row(
                    children: List.generate(_navItems.length, (i) {
                      final isActive = _selectedIndex == i;
                      return Expanded(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => _onTap(i),
                          child: SizedBox(
                            height: 68,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 250),
                                  switchInCurve: Curves.easeOutBack,
                                  switchOutCurve: Curves.easeIn,
                                  transitionBuilder: (child, anim) => ScaleTransition(
                                    scale: anim,
                                    child: FadeTransition(opacity: anim, child: child),
                                  ),
                                  child: Icon(
                                    _navItems[i].activeIcon,
                                    key: ValueKey(isActive),
                                    size: 22,
                                    color: isActive ? Colors.white : Colors.grey.shade400,
                                  ),
                                ),
                                AnimatedSize(
                                  duration: const Duration(milliseconds: 220),
                                  curve: Curves.easeInOut,
                                  child: isActive
                                      ? Padding(
                                          padding: const EdgeInsets.only(top: 3),
                                          child: Text(
                                            _navItems[i].label,
                                            style: const TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white,
                                              letterSpacing: 0.2,
                                            ),
                                          ),
                                        )
                                      : const SizedBox.shrink(),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
