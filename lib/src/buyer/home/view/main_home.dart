import 'dart:io';

import 'package:mspeed/src/buyer/home/model/home_model.dart';
import 'package:mspeed/src/buyer/home/view/home_buyer_view.dart';
import 'package:mspeed/src/buyer/notifikasi/view/notifikasi_view.dart';
import 'package:mspeed/src/buyer/profil/view/akun_saya_view.dart';
import 'package:mspeed/src/buyer/wishlist/view/wishlist_view.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../common/helper/constant.dart';

// ─────────────────────────────────────────
// Data model nav item
// ─────────────────────────────────────────
class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _NavItem({required this.icon, required this.activeIcon, required this.label});
}

// ─────────────────────────────────────────
// Main Buyer Home
// ─────────────────────────────────────────
class MainHome extends StatefulWidget {
  final int? index;
  const MainHome({super.key, this.index});
  @override
  State<MainHome> createState() => _MainHomeState();
}

class _MainHomeState extends State<MainHome> with SingleTickerProviderStateMixin {
  int currentIndex = 0;
  late HomeModel homeModel;
  String? roles;

  // For the slide animation
  late AnimationController _indicatorController;
  late Animation<double> _indicatorAnim;
  int _prevIndex = 0;

  static const _navItems = [
    _NavItem(icon: Icons.home_outlined,          activeIcon: Icons.home_rounded,              label: 'Beranda'),
    _NavItem(icon: Icons.favorite_border_rounded, activeIcon: Icons.favorite_rounded,          label: 'Wishlist'),
    _NavItem(icon: Icons.notifications_outlined,  activeIcon: Icons.notifications_rounded,     label: 'Notifikasi'),
    _NavItem(icon: Icons.person_outline_rounded,  activeIcon: Icons.person_rounded,            label: 'Akun'),
  ];

  @override
  void initState() {
    super.initState();
    _indicatorController = AnimationController(vsync: this, duration: const Duration(milliseconds: 350));
    _indicatorAnim = Tween<double>(begin: 0, end: 0).animate(
      CurvedAnimation(parent: _indicatorController, curve: Curves.easeInOutCubic),
    );
    if (widget.index != null) currentIndex = widget.index ?? 0;
    getData();
  }

  @override
  void dispose() {
    _indicatorController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    roles = ModalRoute.of(context)?.settings.arguments as String?;
    super.didChangeDependencies();
  }

  getData() async { setState(() {}); }

  void jumpToJamaah()  => _onTap(1);
  void jumpToSubAgen() => _onTap(2);
  void jumpToProfile() => _onTap(roles == 'agen' ? 4 : 3);

  void _onTap(int index) {
    if (index == currentIndex) return;
    _prevIndex = currentIndex;
    // Animate indicator from old position to new
    _indicatorAnim = Tween<double>(
      begin: _prevIndex.toDouble(),
      end: index.toDouble(),
    ).animate(CurvedAnimation(parent: _indicatorController, curve: Curves.easeInOutCubic));
    _indicatorController.forward(from: 0);
    setState(() => currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      bottomNavigationBar: _FloatingNavBar(
        itemCount: _navItems.length,
        currentIndex: currentIndex,
        indicatorAnim: _indicatorAnim,
        onTap: _onTap,
        itemBuilder: (i, isActive) => _NavIconLabel(
          item: _navItems[i],
          isActive: isActive,
          primaryColor: Constant.primaryColor,
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: WillPopScope(
          onWillPop: () async {
            if (currentIndex != 0) { _onTap(0); return false; }
            return true;
          },
          child: [
            HomeBuyerView(),
            WishlistView(),
            NotificationView(),
            AkunSayaView(),
          ][currentIndex],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// Shared floating nav bar widget
// ─────────────────────────────────────────
class _FloatingNavBar extends StatelessWidget {
  final int itemCount;
  final int currentIndex;
  final Animation<double> indicatorAnim;
  final ValueChanged<int> onTap;
  final Widget Function(int index, bool isActive) itemBuilder;

  const _FloatingNavBar({
    required this.itemCount,
    required this.currentIndex,
    required this.indicatorAnim,
    required this.onTap,
    required this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Constant.primaryColor;
    final bottomPad = Platform.isIOS ? 20.0 : 12.0;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, bottomPad),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final totalWidth = constraints.maxWidth;
          final slotWidth = totalWidth / itemCount;
          const indicatorInset = 6.0;
          final indicatorW = slotWidth - indicatorInset * 2;

          return Container(
            height: 68,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: primary.withOpacity(0.15),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: Stack(
                children: [
                  // ── Sliding pill indicator ──
                  AnimatedBuilder(
                    animation: indicatorAnim,
                    builder: (_, __) {
                      return Positioned(
                        left: indicatorAnim.value * slotWidth + indicatorInset,
                        top: 8,
                        child: Container(
                          width: indicatorW,
                          height: 52,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [primary, primary.withOpacity(0.82)],
                            ),
                            borderRadius: BorderRadius.circular(22),
                            boxShadow: [
                              BoxShadow(
                                color: primary.withOpacity(0.4),
                                blurRadius: 14,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  // ── Nav items ──
                  Row(
                    children: List.generate(itemCount, (i) {
                      final isActive = currentIndex == i;
                      return Expanded(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => onTap(i),
                          child: SizedBox(
                            height: 68,
                            child: itemBuilder(i, isActive),
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

// ─────────────────────────────────────────
// Single nav item: icon + animated label
// ─────────────────────────────────────────
class _NavIconLabel extends StatelessWidget {
  final _NavItem item;
  final bool isActive;
  final Color primaryColor;

  const _NavIconLabel({
    required this.item,
    required this.isActive,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
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
            isActive ? item.activeIcon : item.icon,
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
                    item.label,
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
    );
  }
}
