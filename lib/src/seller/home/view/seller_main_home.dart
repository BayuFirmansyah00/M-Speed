import 'dart:io';

import 'package:mspeed/src/buyer/home/model/home_model.dart';
import 'package:flutter/material.dart';
import 'package:mspeed/src/seller/home/view/home_seller_view.dart';
import 'package:mspeed/src/seller/nego/view/nego_seller_view.dart';
import 'package:mspeed/src/seller/pesanan/view/pesanan_seller_view.dart';
import 'package:mspeed/src/seller/produk/view/produk_seller_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../common/helper/constant.dart';
import '../../../../common/component/custom_navigator.dart';
import '../../profil/view/profile_edit_seller_view.dart';

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
  bool isProfileIncomplete = false;

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
    _checkCompleteness();
  }

  Future<void> _checkCompleteness() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // Gunakan mekanisme SharedPreferences sesuai instruksi jika endpoint me belum ada
    String? compStr = prefs.getString('completeness');
    int completeness = int.tryParse(compStr ?? '0') ?? 0;

    if (completeness < 100) {
      setState(() {
        isProfileIncomplete = true;
      });
      _showIncompleteProfileModal();
    } else {
      setState(() {
        isProfileIncomplete = false;
      });
    }
  }

  void _showIncompleteProfileModal() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return WillPopScope(
            onWillPop: () async => false, // Cegah ditutup dengan tombol back
            child: Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.warning_rounded, color: Colors.orange, size: 60),
                    const SizedBox(height: 16),
                    const Text(
                      "Lengkapi Profil Seller",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "Untuk mulai menggunakan semua fitur Seller, Anda diwajibkan melengkapi profil terlebih dahulu.",
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Constant.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          // Arahkan ke halaman edit profil
                          Navigator.pop(context); // Tutup dialog
                          _navigateToProfile();
                        },
                        child: const Text("Lengkapi Profil", style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    });
  }

  void _navigateToProfile() async {
    // Navigasi ke Edit Profile dan tunggu kembali
    await CusNav.nPush(context, const ProfileEditSellerView());
    // Setelah kembali dari edit profile, cek ulang completeness
    _checkCompleteness();
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
    if (isProfileIncomplete) {
      _showIncompleteProfileModal();
      return;
    }
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
          onWillPop: () async { 
            if (isProfileIncomplete) {
               _showIncompleteProfileModal();
               return false;
            }
            if (currentIndex != 0) { _onTap(0); return false; } 
            return true; 
          },
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
    final primary = const Color(0xff059669); // Emerald Green
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
              BoxShadow(color: primary.withOpacity(0.15), blurRadius: 30, offset: const Offset(0, 10)),
              BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 16, offset: const Offset(0, 4)),
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
                        colors: [isProfileIncomplete ? Colors.grey : primary, isProfileIncomplete ? Colors.grey : primary.withOpacity(0.82)],
                      ),
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [BoxShadow(color: isProfileIncomplete ? Colors.grey.withOpacity(0.4) : primary.withOpacity(0.4), blurRadius: 14, offset: const Offset(0, 6))],
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
                      height: 68,
                      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          switchInCurve: Curves.easeOutBack,
                          switchOutCurve: Curves.easeIn,
                          transitionBuilder: (child, anim) => ScaleTransition(
                            scale: anim, child: FadeTransition(opacity: anim, child: child)),
                          child: Icon(_navItems[i].activeIcon,
                            key: ValueKey(isActive),
                            size: 24,
                            color: isActive ? Colors.white : Colors.grey.shade400),
                        ),
                        AnimatedSize(
                          duration: const Duration(milliseconds: 220),
                          curve: Curves.easeInOut,
                          child: isActive
                              ? Padding(
                                  padding: const EdgeInsets.only(top: 3),
                                  child: Text(_navItems[i].label,
                                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 0.2)),
                                )
                              : const SizedBox.shrink(),
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
