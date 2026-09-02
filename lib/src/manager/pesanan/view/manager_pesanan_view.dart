import 'package:flutter/material.dart';
import 'package:mspeed/common/base/base_state.dart';
import 'package:mspeed/common/component/custom_navigator.dart';
import 'package:mspeed/src/manager/pesanan/provider/manager_provider.dart';
import 'package:mspeed/src/manager/pesanan/view/manager_order_item_widget.dart';
import 'package:mspeed/src/manager/pesanan/view/manager_pesanan_detail_view.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mspeed/common/helper/constant.dart';

// ── Brand Colors ───────────────────────────────────────────────────────────
const Color _kPrimary = Color(0xFF1D4ED8);
const Color _kBg = Color(0xFFF8FAFC);
const Color _kSurface = Color(0xFFFFFFFF);
const Color _kTextPrimary = Color(0xFF1F2937);
const Color _kTextSecondary = Color(0xFF6B7280);
const Color _kBorder = Color(0xFFE5E7EB);

/// Available filter status labels mapped to Laravel status strings
const List<Map<String, String>> _kFilterStatuses = [
  {'label': 'Semua', 'value': ''},
  {'label': 'Pesanan Baru', 'value': 'pesanan baru'},
  {'label': 'Disetujui Manager', 'value': 'approve pesanan by manager'},
  {'label': 'Ditolak Manager', 'value': 'reject pesanan by manager'},
  {'label': 'Tagihan', 'value': 'tagihan'},
  {'label': 'Siap Tagih', 'value': 'siap tagih by manager'},
  {'label': 'Tolak Tagihan', 'value': 'tolak tagih by manager'},
  {'label': 'Diterima Seller', 'value': 'diterima seller'},
  {'label': 'Dikirim', 'value': 'dikirim'},
  {'label': 'Selesai', 'value': 'selesai'},
];

class ManagerPesananView extends StatefulWidget {
  const ManagerPesananView({super.key});

  @override
  State<ManagerPesananView> createState() => _ManagerPesananViewState();
}

class _ManagerPesananViewState extends BaseState<ManagerPesananView> {
  String _managerName = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _init();
    });
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    final first = prefs.getString(Constant.kSetPrefFirstName) ?? '';
    final last = prefs.getString(Constant.kSetPrefLastName) ?? '';
    if (mounted) {
      setState(() {
        _managerName = '$first $last'.trim();
      });
    }
    await _loadOrders();
  }

  Future<void> _loadOrders() async {
    await context.read<ManagerProvider>().fetchOrders(withLoading: true);
  }

  void _openDetail(int orderId) {
    CusNav.nPush(context, ManagerPesananDetailView(orderId: orderId));
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ManagerProvider>();
    final filtered = p.filteredOrders;
    final pendingCount = (p.orders.data ?? []).where((o) => o.canApproveOrder || o.canApproveInvoice).length;
    debugPrint('[MANAGER_PESANAN_VIEW] build: rawOrders=${p.orders.data?.length ?? 0}, filteredOrders=${filtered.length}, filterStatus="${p.filterStatus}"');

    return Scaffold(
      backgroundColor: _kBg,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(pendingCount),
            _buildSearchAndFilter(p),
            Expanded(
              child: p.isLoadingOrders
                  ? const Center(child: CircularProgressIndicator(color: _kPrimary))
                  : filtered.isEmpty
                      ? _buildEmptyState()
                      : RefreshIndicator(
                          color: _kPrimary,
                          onRefresh: _loadOrders,
                          child: ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
                            itemCount: filtered.length,
                            itemBuilder: (ctx, i) {
                              final order = filtered[i];
                              return ManagerOrderItemWidget(
                                order: order,
                                onTap: () => _openDetail(order.id!),
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────
  Widget _buildHeader(int pendingCount) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      color: _kSurface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Manajemen Pesanan',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: _kTextPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _managerName.isNotEmpty ? 'Halo, $_managerName' : 'Manager',
                      style: const TextStyle(fontSize: 13, color: _kTextSecondary),
                    ),
                  ],
                ),
              ),
              if (pendingCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: _kPrimary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _kPrimary.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.pending_actions_rounded, size: 16, color: _kPrimary),
                      const SizedBox(width: 6),
                      Text(
                        '$pendingCount Menunggu',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _kPrimary),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Search + Filter chip bar ───────────────────────────────────────────────
  Widget _buildSearchAndFilter(ManagerProvider p) {
    return Container(
      color: _kSurface,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Search
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Container(
              height: 46,
              decoration: BoxDecoration(
                color: _kBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _kBorder),
              ),
              child: Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Icon(Icons.search_rounded, size: 20, color: _kTextSecondary),
                  ),
                  Expanded(
                    child: TextField(
                      controller: p.searchController,
                      style: const TextStyle(fontSize: 14, color: _kTextPrimary),
                      decoration: const InputDecoration(
                        hintText: 'Cari No. Pesanan / Pembeli / Seller',
                        hintStyle: TextStyle(fontSize: 14, color: _kTextSecondary),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  if (p.searchController.text.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 18, color: _kTextSecondary),
                      onPressed: () {
                        p.searchController.clear();
                        setState(() {});
                      },
                    ),
                ],
              ),
            ),
          ),

          // Filter chips
          SizedBox(
            height: 48,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: _kFilterStatuses.length,
              itemBuilder: (ctx, i) {
                final filter = _kFilterStatuses[i];
                final isSelected = (p.filterStatus ?? '') == filter['value'];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(
                      filter['label']!,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected ? Colors.white : _kTextSecondary,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (_) {
                      p.filterStatus = filter['value']!.isEmpty ? null : filter['value'];
                      setState(() {});
                    },
                    selectedColor: _kPrimary,
                    backgroundColor: _kBg,
                    checkmarkColor: Colors.white,
                    showCheckmark: false,
                    side: BorderSide(
                      color: isSelected ? _kPrimary : _kBorder,
                    ),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 0),
                    visualDensity: VisualDensity.compact,
                  ),
                );
              },
            ),
          ),

          const Divider(height: 1, color: _kBorder),
        ],
      ),
    );
  }

  // ── Empty State ───────────────────────────────────────────────────────────
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_rounded, size: 56, color: _kTextSecondary.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          const Text(
            'Belum ada pesanan',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: _kTextSecondary),
          ),
          const SizedBox(height: 8),
          Text(
            'Pesanan dari Buyer di bawah Anda\nakan muncul di sini',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: _kTextSecondary.withValues(alpha: 0.8)),
          ),
        ],
      ),
    );
  }
}
