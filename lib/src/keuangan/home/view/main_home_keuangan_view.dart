import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mspeed/src/keuangan/home/view/home_keuangan_view.dart';
import 'package:mspeed/src/keuangan/pesanan/view/list_pesanan_view.dart';
import 'package:mspeed/src/keuangan/profil/view/finance_profile_view.dart';

const Color _kPrimary = Color(0xFFD97706);

class _KeuanganNavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _KeuanganNavItem({required this.icon, required this.activeIcon, required this.label});
}

class MainHomeKeuanganView extends StatefulWidget {
  const MainHomeKeuanganView({super.key});

  @override
  State<MainHomeKeuanganView> createState() => _MainHomeKeuanganViewState();
}

class _MainHomeKeuanganViewState extends State<MainHomeKeuanganView> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _indicatorController;
  late Animation<double> _indicatorAnim;
  int _prevIndex = 0;

  static const _navItems = [
    _KeuanganNavItem(
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard_rounded,
      label: 'Dashboard',
    ),
    _KeuanganNavItem(
      icon: Icons.receipt_long_outlined,
      activeIcon: Icons.receipt_long_rounded,
      label: 'Pesanan',
    ),
    _KeuanganNavItem(
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
      duration: const Duration(milliseconds: 300),
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
    _indicatorAnim = Tween<double>(begin: _prevIndex.toDouble(), end: index.toDouble())
        .animate(CurvedAnimation(parent: _indicatorController, curve: Curves.easeInOutCubic));
    _indicatorController.forward(from: 0);
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      HomeKeuanganView(
        onNavigateToOrders: () => _onTap(1),
      ),
      const ListPesananView(),
      const FinanceProfileView(),
    ];

    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _selectedIndex,
        children: pages,
      ),
      bottomNavigationBar: _buildNav(),
    );
  }

  Widget _buildNav() {
    final bottomPad = Platform.isIOS ? 20.0 : 12.0;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, bottomPad),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final slotWidth = constraints.maxWidth / _navItems.length;
          const inset = 6.0;
          return Container(
            height: 68,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: _kPrimary.withValues(alpha: 0.15),
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
                  // Sliding gradient indicator
                  AnimatedBuilder(
                    animation: _indicatorAnim,
                    builder: (_, __) => Positioned(
                      left: _indicatorAnim.value * slotWidth + inset,
                      top: 8,
                      child: Container(
                        width: slotWidth - inset * 2,
                        height: 52,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [_kPrimary, Color(0xFFB45309)],
                          ),
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [
                            BoxShadow(
                              color: _kPrimary.withValues(alpha: 0.35),
                              blurRadius: 14,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Nav items
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
                                    size: 24,
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
