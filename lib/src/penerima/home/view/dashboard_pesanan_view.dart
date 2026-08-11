import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mspeed/common/helper/Constant.dart';
import 'package:mspeed/generated/assets.dart';
import 'package:mspeed/src/penerima/chat/view/list_chat_pesanan_view.dart';
import 'package:mspeed/src/penerima/pesanan/view/list_pesanan_view.dart';

class _NavItem {
  final Widget icon;
  final Widget activeIcon;
  final String label;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

class DashboardPesananView extends StatefulWidget {
  const DashboardPesananView({Key? key}) : super(key: key);

  @override
  State<DashboardPesananView> createState() => _DashboardPesananViewState();
}

class _DashboardPesananViewState extends State<DashboardPesananView>
    with SingleTickerProviderStateMixin {
  int currentIndex = 0;
  late AnimationController _indicatorController;
  late Animation<double> _indicatorAnim;
  int _prevIndex = 0;

  static const _navItems = [
    _NavItem(
      icon: _NavIcon(path: Assets.iconsIcPesananBlack, isActive: false),
      activeIcon: _NavIcon(path: Assets.iconsIcPesananRed, isActive: true),
      label: 'Pesanan',
    ),
    _NavItem(
      icon: _NavIcon(svgPath: Assets.svgsIcChat, isActive: false),
      activeIcon: _NavIcon(svgPath: Assets.svgsIcChat, isActive: true),
      label: 'Chat',
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
        child: IndexedStack(
          index: currentIndex,
          children: const [
            ListPesananView(),
            ListChatPesananView(),
          ],
        ),
      ),
    );
  }

  Widget _buildNav() {
    final primary = Constant.primaryColor;
    final bottomPad = Platform.isIOS ? 20.0 : 12.0;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, bottomPad),
      child: LayoutBuilder(builder: (context, constraints) {
        final slotWidth = constraints.maxWidth / _navItems.length;
        const inset = 6.0;

        return Container(
          height: 68,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(color: primary.withValues(alpha: 0.15), blurRadius: 30, offset: const Offset(0, 10)),
              BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 16, offset: const Offset(0, 4)),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: Stack(children: [
              // Sliding indicator
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
                        BoxShadow(color: primary.withValues(alpha: 0.4), blurRadius: 14, offset: const Offset(0, 6)),
                      ],
                    ),
                  ),
                ),
              ),
              // Items
              Row(
                children: List.generate(_navItems.length, (i) {
                  final isActive = currentIndex == i;
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
                              child: SizedBox(
                                key: ValueKey(isActive),
                                width: 24,
                                height: 24,
                                child: isActive ? _navItems[i].activeIcon : _navItems[i].icon,
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
            ]),
          ),
        );
      }),
    );
  }
}

class _NavIcon extends StatelessWidget {
  final String? path;
  final String? svgPath;
  final bool isActive;

  const _NavIcon({this.path, this.svgPath, required this.isActive});

  @override
  Widget build(BuildContext context) {
    final color = isActive ? Constant.primaryColor : Colors.grey.shade400;

    if (svgPath != null) {
      return SvgPicture.asset(
        svgPath!,
        width: 24,
        height: 24,
        color: color,
      );
    }

    return Image.asset(
      path!,
      width: 24,
      height: 24,
      color: color,
    );
  }
}
