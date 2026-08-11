import 'dart:io';

import 'package:mspeed/src/buyer/home/model/home_model.dart';
import 'package:flutter/material.dart';
import 'package:mspeed/src/seller/home/view/home_seller_view.dart';
import 'package:mspeed/src/seller/nego/view/nego_seller_view.dart';
import 'package:mspeed/src/seller/pesanan/view/pesanan_seller_view.dart';
import 'package:mspeed/src/seller/produk/view/produk_seller_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../common/helper/constant.dart';

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _NavItem({required this.icon, required this.activeIcon, required this.label});
}

class SellerMainHome extends StatefulWidget {
  final int? index;
  const SellerMainHome({super.key, this.index});
  @override
  State<SellerMainHome> createState() => _SellerMainHomeState();
}

class _SellerMainHomeState extends State<SellerMainHome> with SingleTickerProviderStateMixin {
  int currentIndex = 0;
  late HomeModel homeModel;
  String? roles;
  late AnimationController _indicatorController;
  late Animation<double> _indicatorAnim;
  int _prevIndex = 0;

  // M-SPEED Brand Colors
  static const Color _primaryBlue = Color(0xFF1565C0);
  static const Color _inactiveGrey = Color(0xFF9CA3AF);

  static const _navItems = [
    _NavItem(icon: Icons.home_outlined,         activeIcon: Icons.home_rounded,            label: 'Beranda'),
    _NavItem(icon: Icons.inventory_2_outlined,   activeIcon: Icons.inventory_2_rounded,     label: 'Produk'),
    _NavItem(icon: Icons.receipt_long_outlined,  activeIcon: Icons.receipt_long_rounded,    label: 'Pesanan'),
    _NavItem(icon: Icons.handshake_outlined,     activeIcon: Icons.handshake_rounded,       label: 'Nego'),
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
  void dispose() { _indicatorController.dispose(); super.dispose(); }

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
    _indicatorAnim = Tween<double>(begin: _prevIndex.toDouble(), end: index.toDouble())
        .animate(CurvedAnimation(parent: _indicatorController, curve: Curves.easeInOutCubic));
    _indicatorController.forward(from: 0);
    setState(() => currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      bottomNavigationBar: _buildNav(),
      body: SafeArea(
        bottom: false,
        child: WillPopScope(
          onWillPop: () async { if (currentIndex != 0) { _onTap(0); return false; } return true; },
          child: [
            HomeSellerView(jumpToPesanan: () => _onTap(2)),
            ProdukSellerView(),
            PesananSellerView(),
            NegoSellerView(),
          ][currentIndex],
        ),
      ),
    );
  }

  Widget _buildNav() {
    final bottomPad = Platform.isIOS ? 20.0 : 12.0;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, bottomPad),
      child: LayoutBuilder(builder: (context, constraints) {
        final slotWidth = constraints.maxWidth / _navItems.length;
        const inset = 6.0;
        return Container(
          height: 66,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: const Color(0xFFE5E7EB), width: 0.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: Stack(children: [
              // Sliding indicator — SOLID color, no gradient
              AnimatedBuilder(
                animation: _indicatorAnim,
                builder: (_, __) => Positioned(
                  left: _indicatorAnim.value * slotWidth + inset,
                  top: 7,
                  child: Container(
                    width: slotWidth - inset * 2,
                    height: 52,
                    decoration: BoxDecoration(
                      color: _primaryBlue,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: _primaryBlue.withOpacity(0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Items
              Row(children: List.generate(_navItems.length, (i) {
                final isActive = currentIndex == i;
                return Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => _onTap(i),
                    child: SizedBox(
                      height: 66,
                      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          switchInCurve: Curves.easeOutBack,
                          switchOutCurve: Curves.easeIn,
                          transitionBuilder: (child, anim) => ScaleTransition(
                            scale: anim, child: FadeTransition(opacity: anim, child: child)),
                          child: Icon(_navItems[i].activeIcon,
                            key: ValueKey(isActive),
                            size: 22,
                            color: isActive ? Colors.white : _inactiveGrey),
                        ),
                        AnimatedSize(
                          duration: const Duration(milliseconds: 220),
                          curve: Curves.easeInOut,
                          child: isActive
                              ? Padding(
                                  padding: const EdgeInsets.only(top: 2),
                                  child: Text(_navItems[i].label,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                      letterSpacing: 0.1,
                                    )),
                                )
                              : Padding(
                                  padding: const EdgeInsets.only(top: 2),
                                  child: Text(_navItems[i].label,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                      color: _inactiveGrey,
                                      letterSpacing: 0.1,
                                    )),
                                ),
                        ),
                      ]),
                    ),
                  ),
                );
              })),
            ]),
          ),
        );
      }),
    );
  }
}
