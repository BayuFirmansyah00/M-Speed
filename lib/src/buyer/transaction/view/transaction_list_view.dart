import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:mspeed/common/base/base_state.dart';
import 'package:mspeed/src/buyer/transaction/provider/transaction_status.dart';
import 'package:mspeed/src/buyer/transaction/view/new_order_view.dart';

// ─── Palet Warna ─────────────────────────────────────────────
class _TC {
  static const primary    = Color(0xFFE50012); // M-Speed Red
  static const bg         = Color(0xFFF5F5F7);
  static const card       = Color(0xFFFFFFFF);
  static const txt1       = Color(0xFF111827);
  static const txt2       = Color(0xFF6B7280);
  static const border     = Color(0xFFE5E7EB);

  // Status tab colors
  static const tabColors = [
    Color(0xFFF58B2B), // Pesanan Baru   – orange
    Color(0xFF2B64F5), // Diterima       – blue
    Color(0xFF10B981), // Dikirim        – green
    Color(0xFF8B5CF6), // Barang Diterima– purple
    Color(0xFFEC4899), // Proses Bayar   – pink
    Color(0xFF1ABC62), // Telah Dibayar  – emerald
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
  int _initialRoute = 0;

  static const List<Map<String, dynamic>> _tabs = [
    {'label': 'Pesanan Baru',       'icon': Icons.add_shopping_cart_rounded},
    {'label': 'Pesanan Diterima',   'icon': Icons.check_circle_outline_rounded},
    {'label': 'Pesanan Dikirim',    'icon': Icons.local_shipping_rounded},
    {'label': 'Barang Diterima',    'icon': Icons.inventory_2_rounded},
    {'label': 'Proses Pembayaran',  'icon': Icons.payment_rounded},
    {'label': 'Telah Dibayar',      'icon': Icons.verified_rounded},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _initialRoute = widget.initialRoute ?? 0;
    if (_initialRoute > 0 && _initialRoute < 6) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _tabController.animateTo(_initialRoute);
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
    return DefaultTabController(
      length: 6,
      child: Scaffold(
        backgroundColor: _TC.bg,
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverAppBar(
              expandedHeight: 100,
              floating: false,
              pinned: true,
              snap: false,
              elevation: 0,
              scrolledUnderElevation: 0,
              backgroundColor: _TC.card,
              leading: Padding(
                padding: const EdgeInsets.all(8.0),
                child: InkWell(
                  onTap: () => Navigator.pop(context),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    decoration: BoxDecoration(
                      color: _TC.bg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 18,
                      color: _TC.txt1,
                    ),
                  ),
                ),
              ),
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.only(left: 16, bottom: 12),
                title: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [_TC.primary, Color(0xFFFF4D5B)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.receipt_long_rounded,
                        color: Colors.white,
                        size: 15,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Daftar Transaksi',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: _TC.txt1,
                        fontSize: 17,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
                background: Container(
                  decoration: const BoxDecoration(
                    color: _TC.card,
                  ),
                ),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(52),
                child: Container(
                  color: _TC.card,
                  child: TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    tabAlignment: TabAlignment.start,
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: _TC.border,
                    indicator: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(8),
                      ),
                      color: _TC.primary.withValues(alpha: 0.08),
                      border: Border(
                        bottom: BorderSide(color: _TC.primary, width: 2.5),
                      ),
                    ),
                    labelColor: _TC.primary,
                    unselectedLabelColor: _TC.txt2,
                    labelStyle: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                    ),
                    tabs: List.generate(_tabs.length, (i) {
                      return Tab(
                        height: 48,
                        child: _TabItem(
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
      ),
    );
  }
}

/// Widget tab dengan icon berwarna sesuai status
class _TabItem extends StatefulWidget {
  final String label;
  final IconData icon;
  final Color color;
  final int index;
  final TabController controller;

  const _TabItem({
    required this.label,
    required this.icon,
    required this.color,
    required this.index,
    required this.controller,
  });

  @override
  State<_TabItem> createState() => _TabItemState();
}

class _TabItemState extends State<_TabItem> {
  late bool _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.controller.index == widget.index;
    widget.controller.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    if (mounted) {
      setState(() {
        _selected = widget.controller.index == widget.index;
      });
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTabChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = _selected ? _TC.primary : _TC.txt2;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: _selected
                ? widget.color.withValues(alpha: 0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(widget.icon, size: 14, color: _selected ? widget.color : _TC.txt2),
        ),
        const SizedBox(width: 6),
        AutoSizeText(
          widget.label,
          style: TextStyle(
            fontWeight: _selected ? FontWeight.w600 : FontWeight.w400,
            color: color,
            fontSize: 12,
          ),
          maxLines: 1,
          minFontSize: 10,
        ),
      ],
    );
  }
}
