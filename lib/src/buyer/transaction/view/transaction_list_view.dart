import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:mspeed/common/base/base_state.dart';
import 'package:mspeed/src/buyer/transaction/provider/transaction_status.dart';
import 'package:mspeed/src/buyer/transaction/view/new_order_view.dart';

// ─── Palet Warna ──────────────────────────────────────────────
class _TC {
  static const primary   = Color(0xFFE50012);
  static const bg        = Color(0xFFF4F6FB);
  static const card      = Color(0xFFFFFFFF);
  static const txt1      = Color(0xFF0D1117);
  static const txt3      = Color(0xFF9AA5B1);
  static const border    = Color(0xFFEEF0F5);

  static const tabColors = [
    Color(0xFFF59E0B), // Pesanan Baru   – amber
    Color(0xFF3B82F6), // Diterima       – blue
    Color(0xFF10B981), // Dikirim        – green
    Color(0xFF8B5CF6), // Barang Diterima – purple
    Color(0xFFEC4899), // Proses Bayar   – pink
    Color(0xFF059669), // Telah Dibayar  – emerald
  ];
}

class TransactionListView extends StatefulWidget {
  final int? initialRoute;
  const TransactionListView({super.key, this.initialRoute});

  @override
  State<TransactionListView> createState() => _TransactionListViewState();
}

class _TransactionListViewState extends BaseState<TransactionListView>
    with TickerProviderStateMixin {
  late TabController _tabController;

  static const List<Map<String, dynamic>> _tabs = [
    {'label': 'Pesanan Baru',      'icon': Icons.add_shopping_cart_rounded},
    {'label': 'Diterima',          'icon': Icons.check_circle_outline_rounded},
    {'label': 'Dikirim',           'icon': Icons.local_shipping_rounded},
    {'label': 'Brg. Diterima',     'icon': Icons.inventory_2_rounded},
    {'label': 'Proses Bayar',      'icon': Icons.payment_rounded},
    {'label': 'Telah Dibayar',     'icon': Icons.verified_rounded},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    final init = widget.initialRoute ?? 0;
    if (init > 0 && init < 6) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _tabController.animateTo(init);
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _TC.bg,
      body: NestedScrollView(
        headerSliverBuilder: (ctx, innerScrolled) => [
          SliverAppBar(
            expandedHeight: 130, // Ditambah 20px agar ada jarak
            floating: false,
            pinned: true,
            snap: false,
            elevation: 0,
            scrolledUnderElevation: 0,
            backgroundColor: _TC.card,
            surfaceTintColor: _TC.card,
            // ── Back button ──────────────────────────────────
            leading: Padding(
              padding: const EdgeInsets.all(10),
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  decoration: BoxDecoration(
                    color: _TC.bg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 17,
                    color: _TC.txt1,
                  ),
                ),
              ),
            ),
            // ── Flexible title ────────────────────────────────
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: Container(
                color: _TC.card,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(72, 18, 24, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        // Section label
                        Text(
                          'MANAJEMEN PESANAN',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: _TC.txt3,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF0B1F4E), Color(0xFF1A3A7C)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(9),
                              ),
                              child: const Icon(Icons.receipt_long_rounded,
                                  color: Colors.white, size: 16),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'Daftar Transaksi',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: _TC.txt1,
                                fontSize: 20,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // ── Tab Bar ───────────────────────────────────────
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(54),
              child: Container(
                decoration: const BoxDecoration(
                  color: _TC.card,
                  border: Border(bottom: BorderSide(color: _TC.border)),
                ),
                child: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  indicator: BoxDecoration(
                    color: _TC.primary.withValues(alpha: 0.07),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                    border: const Border(
                      bottom: BorderSide(color: _TC.primary, width: 2.5),
                    ),
                  ),
                  labelColor: _TC.primary,
                  unselectedLabelColor: _TC.txt3,
                  labelPadding: EdgeInsets.zero,
                  tabs: List.generate(_tabs.length, (i) {
                    return Tab(
                      height: 50,
                      child: _TabChip(
                        label: _tabs[i]['label'],
                        icon: _tabs[i]['icon'],
                        color: _TC.tabColors[i],
                        index: i,
                        controller: _tabController,
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            NewOrderView(status: TransactionStatus.PESANAN_BARU),
            NewOrderView(status: TransactionStatus.PESANAN_DITERIMA),
            NewOrderView(status: TransactionStatus.PESANAN_DIKIRIM),
            NewOrderView(status: TransactionStatus.BARANG_DITERIMA),
            NewOrderView(status: TransactionStatus.PROSES_PEMBAYARAN),
            NewOrderView(status: TransactionStatus.TELAH_DIBAYAR),
          ],
        ),
      ),
    );
  }
}

// ─── Tab Chip Widget ──────────────────────────────────────────
class _TabChip extends StatefulWidget {
  final String label;
  final IconData icon;
  final Color color;
  final int index;
  final TabController controller;

  const _TabChip({
    required this.label,
    required this.icon,
    required this.color,
    required this.index,
    required this.controller,
  });

  @override
  State<_TabChip> createState() => _TabChipState();
}

class _TabChipState extends State<_TabChip> {
  late bool _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.controller.index == widget.index;
    widget.controller.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    if (mounted) {
      setState(() => _selected = widget.controller.index == widget.index);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTabChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: _selected
              ? widget.color.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: _selected
                    ? widget.color.withValues(alpha: 0.18)
                    : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Icon(
                widget.icon,
                size: 13,
                color: _selected ? widget.color : _TC.txt3,
              ),
            ),
            const SizedBox(width: 6),
            AutoSizeText(
              widget.label,
              style: TextStyle(
                fontWeight: _selected ? FontWeight.w700 : FontWeight.w500,
                color: _selected ? _TC.primary : _TC.txt3,
                fontSize: 12,
              ),
              maxLines: 1,
              minFontSize: 10,
            ),
          ],
        ),
      ),
    );
  }
}
