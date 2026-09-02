import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mspeed/common/base/base_state.dart';
import 'package:mspeed/common/component/custom_navigator.dart';
import 'package:mspeed/src/admin/user/provider/admin_user_provider.dart';
import 'package:mspeed/src/keuangan/pesanan/provider/keuangan_provider.dart';
import 'package:mspeed/src/keuangan/pesanan/view/keuangan_pesanan_detail_view.dart';
import 'package:mspeed/src/keuangan/pesanan/view/order_item_widget.dart';
import 'package:mspeed/utils/utils.dart';
import 'package:provider/provider.dart';

// ── Finance Color Palette ───────────────────────────────────────────────────
const Color _kPrimary = Color(0xFFD97706);      // Amber
const Color _kPrimaryDark = Color(0xFFB45309);  // Dark Amber
const Color _kPrimaryLight = Color(0xFFFEF3C7); // Soft Amber
const Color _kSuccess = Color(0xFF10B981);      // Emerald Green
const Color _kSuccessLight = Color(0xFFD1FAE5);
const Color _kWarning = Color(0xFFF59E0B);      // Orange/Amber
const Color _kBg = Color(0xFFF8FAFC);
const Color _kSurface = Color(0xFFFFFFFF);
const Color _kTextPrimary = Color(0xFF1F2937);
const Color _kTextSecondary = Color(0xFF6B7280);
const Color _kBorder = Color(0xFFE5E7EB);

class HomeKeuanganView extends StatefulWidget {
  final VoidCallback? onNavigateToOrders;
  const HomeKeuanganView({super.key, this.onNavigateToOrders});

  @override
  State<HomeKeuanganView> createState() => _HomeKeuanganViewState();
}

class _HomeKeuanganViewState extends BaseState<HomeKeuanganView> {
  final _currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final p = context.read<KeuanganProvider>();
    await Future.wait([
      p.loadProfile(),
      p.fetchOrders(withLoading: true),
    ]);
  }

  Future<void> _handleBackToAdmin() async {
    await Utils.showYesNoDialog(
      context: context,
      title: 'Kembali ke Admin',
      desc: 'Apakah Anda yakin ingin mengakhiri sesi impersonate dan kembali ke dashboard admin?',
      yesCallback: () async {
        CusNav.nPop(context);
        await context.read<AdminUserProvider>().backToAdmin(context);
      },
      noCallback: () => CusNav.nPop(context),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<KeuanganProvider>();
    final orders = p.orders;
    final urgentOrders = orders.where((o) => o.canProcessPayment).toList();
    final recentOrders = orders.take(5).toList();

    return Scaffold(
      backgroundColor: _kBg,
      body: SafeArea(
        child: RefreshIndicator(
          color: _kPrimary,
          onRefresh: _loadData,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // ── Header Section ─────────────────────────────────────────
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                  decoration: const BoxDecoration(
                    color: _kSurface,
                    border: Border(bottom: BorderSide(color: _kBorder, width: 1)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // User Info Row
                      Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [_kPrimary, _kPrimaryDark],
                              ),
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: _kPrimary.withValues(alpha: 0.25),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.account_balance_wallet_rounded,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Portal Finance & Tagihan',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: _kTextSecondary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  p.financeName,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: _kTextPrimary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: _kPrimaryLight,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFFFCD34D)),
                            ),
                            child: const Text(
                              'FINANCE',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: _kPrimaryDark,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Impersonate Banner (if active)
                      if (p.isImpersonated) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFFCD34D)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.swap_horiz_rounded, color: Color(0xFFB45309), size: 18),
                              const SizedBox(width: 8),
                              const Expanded(
                                child: Text(
                                  'Sesi Impersonate Aktif',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF92400E),
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: _handleBackToAdmin,
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: const Text(
                                  'Kembali ke Admin',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFFB45309),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // ── KPI Summary Cards ───────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Ringkasan Keuangan & Tagihan',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: _kTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Primary Cash Paid Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFFD97706), Color(0xFFB45309)],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFD97706).withValues(alpha: 0.3),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.payments_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                const Text(
                                  'Total Nominal Terbayar',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _currencyFormat.format(p.kpiTotalNominalDibayar),
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Dari ${p.kpiTelahDibayar} pesanan lunas',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withValues(alpha: 0.85),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // 3-Grid KPI Stats
                      Row(
                        children: [
                          Expanded(
                            child: _KpiStatCard(
                              title: 'Siap Dibayar',
                              count: p.kpiSiapDibayar,
                              color: _kWarning,
                              bgColor: _kPrimaryLight,
                              icon: Icons.pending_actions_rounded,
                              isActionNeeded: p.kpiSiapDibayar > 0,
                              onTap: widget.onNavigateToOrders,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _KpiStatCard(
                              title: 'Telah Dibayar',
                              count: p.kpiTelahDibayar,
                              color: _kSuccess,
                              bgColor: _kSuccessLight,
                              icon: Icons.check_circle_outline_rounded,
                              onTap: widget.onNavigateToOrders,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _KpiStatCard(
                              title: 'Total Order',
                              count: p.kpiTotalPesanan,
                              color: const Color(0xFF3B82F6),
                              bgColor: const Color(0xFFDBEAFE),
                              icon: Icons.receipt_long_rounded,
                              onTap: widget.onNavigateToOrders,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // ── Action-Required Banner (Siap Dibayar) ────────────────────
              if (urgentOrders.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    child: Row(
                      children: [
                        Container(
                          width: 4,
                          height: 16,
                          decoration: BoxDecoration(
                            color: _kWarning,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Perlu Pembayaran Segera',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: _kTextPrimary,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: _kPrimaryLight,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${urgentOrders.length} Pesanan',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: _kPrimaryDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final order = urgentOrders[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: InkWell(
                          onTap: () {
                            CusNav.nPush(
                              context,
                              KeuanganPesananDetailView(transactionId: order.id.toString()),
                            );
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: OrderItem(
                            order: order,
                            highlightAction: true,
                          ),
                        ),
                      );
                    },
                    childCount: urgentOrders.length,
                  ),
                ),
              ],

              // ── Recent Orders Section ───────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                  child: Row(
                    children: [
                      Container(
                        width: 4,
                        height: 16,
                        decoration: BoxDecoration(
                          color: _kPrimary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Pesanan Terbaru',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: _kTextPrimary,
                        ),
                      ),
                      const Spacer(),
                      if (orders.length > 5)
                        GestureDetector(
                          onTap: widget.onNavigateToOrders,
                          child: const Text(
                            'Lihat Semua',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: _kPrimaryDark,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              if (p.isLoadingOrders)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(
                      child: CircularProgressIndicator(color: _kPrimary),
                    ),
                  ),
                )
              else if (recentOrders.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.inbox_outlined, size: 56, color: Colors.grey.shade300),
                          const SizedBox(height: 12),
                          const Text(
                            'Belum ada data pesanan',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: _kTextSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final order = recentOrders[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: InkWell(
                          onTap: () {
                            CusNav.nPush(
                              context,
                              KeuanganPesananDetailView(transactionId: order.id.toString()),
                            );
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: OrderItem(order: order),
                        ),
                      );
                    },
                    childCount: recentOrders.length,
                  ),
                ),

              // Bottom Spacing for Floating Navigation Bar
              const SliverToBoxAdapter(
                child: SizedBox(height: 100),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── KPI Small Card Component ───────────────────────────────────────────────
class _KpiStatCard extends StatelessWidget {
  final String title;
  final int count;
  final Color color;
  final Color bgColor;
  final IconData icon;
  final bool isActionNeeded;
  final VoidCallback? onTap;

  const _KpiStatCard({
    required this.title,
    required this.count,
    required this.color,
    required this.bgColor,
    required this.icon,
    this.isActionNeeded = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _kSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActionNeeded ? color.withValues(alpha: 0.5) : _kBorder,
            width: isActionNeeded ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 16),
            ),
            const SizedBox(height: 10),
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: color,
                height: 1,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: _kTextSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
