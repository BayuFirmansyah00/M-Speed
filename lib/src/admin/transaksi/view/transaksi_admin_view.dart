import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mspeed/common/component/custom_navigator.dart';
import 'package:mspeed/common/helper/constant.dart';
import 'package:mspeed/generated/assets.dart';
import 'package:mspeed/src/admin/transaksi/view/data_dpp_admin_view.dart';
import 'package:mspeed/src/admin/transaksi/view/data_order_admin_view.dart';

class TransaksiAdminView extends StatefulWidget {
  const TransaksiAdminView({super.key});

  @override
  State<TransaksiAdminView> createState() => _TransaksiAdminViewState();
}

class _TransaksiAdminViewState extends State<TransaksiAdminView> {
  @override
  Widget build(BuildContext context) {
    final menus = [
      _TxMenu(
        title: 'Data DPP',
        subtitle: 'Dasar pengenaan pajak transaksi',
        icon: Icons.receipt_long_rounded,
        gradient: [const Color(0xff06B6D4), const Color(0xff0284C7)],
        onTap: () => CusNav.nPush(context, DataDppAdminView()),
      ),
      _TxMenu(
        title: 'Data Order',
        subtitle: 'Riwayat dan status semua pesanan',
        icon: Icons.assignment_rounded,
        gradient: [const Color(0xffF97316), const Color(0xffEA580C)],
        onTap: () => CusNav.nPush(context, DataOrderAdminView()),
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xffF5F6FA),
      body: CustomScrollView(
        slivers: [
          // ── Gradient SliverAppBar ──
          SliverAppBar(
            expandedHeight: 140,
            floating: false,
            pinned: true,
            automaticallyImplyLeading: false,
            backgroundColor: const Color(0xff0284C7),
            surfaceTintColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xff06B6D4), Color(0xff0284C7)],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -30, top: -30,
                      child: Container(
                        width: 150, height: 150,
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.07), shape: BoxShape.circle),
                      ),
                    ),
                    Positioned(
                      left: -20, bottom: -20,
                      child: Container(
                        width: 100, height: 100,
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), shape: BoxShape.circle),
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
                                  Assets.svgsIcAdminTransaksi,
                                  width: 20, height: 20,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Manajemen Transaksi',
                                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
                                  SizedBox(height: 2),
                                  Text('Pantau dan kelola semua data transaksi',
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

          // ── Label ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: Row(
                children: [
                  Container(
                    width: 3, height: 16,
                    decoration: BoxDecoration(color: const Color(0xff0284C7), borderRadius: BorderRadius.circular(4)),
                  ),
                  const SizedBox(width: 8),
                  const Text('Kategori Transaksi',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xff100629))),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xff0284C7).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text('2 kategori',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xff0284C7))),
                  ),
                ],
              ),
            ),
          ),

          // ── Cards ──
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _TxMenuCard(menu: menus[i]),
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

// ─── Data class ───────────────────────────────────────────────────────────────
class _TxMenu {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> gradient;
  final VoidCallback onTap;
  const _TxMenu({required this.title, required this.subtitle, required this.icon, required this.gradient, required this.onTap});
}

// ─── Card Widget ──────────────────────────────────────────────────────────────
class _TxMenuCard extends StatefulWidget {
  final _TxMenu menu;
  const _TxMenuCard({required this.menu});

  @override
  State<_TxMenuCard> createState() => _TxMenuCardState();
}

class _TxMenuCardState extends State<_TxMenuCard> with SingleTickerProviderStateMixin {
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
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 16, offset: const Offset(0, 4))],
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
                  child: Icon(m.icon, color: Colors.white, size: 32),
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
