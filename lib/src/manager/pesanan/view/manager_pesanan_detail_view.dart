import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mspeed/common/base/base_state.dart';
import 'package:mspeed/common/component/custom_navigator.dart';
import 'package:mspeed/src/manager/pesanan/model/manager_order_model.dart';
import 'package:mspeed/src/manager/pesanan/provider/manager_provider.dart';
import 'package:mspeed/src/manager/pesanan/view/manager_order_item_widget.dart';
import 'package:provider/provider.dart';

// ── Constants ──────────────────────────────────────────────────────────────
const Color _kPrimary = Color(0xFF1D4ED8);
const Color _kSuccess = Color(0xFF16A34A);
const Color _kDanger = Color(0xFFDC2626);
const Color _kBg = Color(0xFFF8FAFC);
const Color _kSurface = Color(0xFFFFFFFF);
const Color _kTextPrimary = Color(0xFF1F2937);
const Color _kTextSecondary = Color(0xFF6B7280);
const Color _kBorder = Color(0xFFE5E7EB);

final _currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

class ManagerPesananDetailView extends StatefulWidget {
  final int orderId;

  const ManagerPesananDetailView({super.key, required this.orderId});

  @override
  State<ManagerPesananDetailView> createState() => _ManagerPesananDetailViewState();
}

class _ManagerPesananDetailViewState extends BaseState<ManagerPesananDetailView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadDetail());
  }

  Future<void> _loadDetail() async {
    await context.read<ManagerProvider>().fetchOrderDetail(
          orderId: widget.orderId,
          withLoading: true,
        );
  }

  // ── Approve/Reject Order ──────────────────────────────────────────────────
  Future<void> _handleApproveOrder() async {
    final p = context.read<ManagerProvider>();
    p.noteController.clear();

    final confirmed = await _showNoteDialog(
      title: 'Setujui Pesanan',
      subtitle: 'Masukkan catatan persetujuan (opsional)',
      actionLabel: 'Setujui',
      actionColor: _kSuccess,
      icon: Icons.check_circle_outline_rounded,
    );
    if (!confirmed) return;

    final success = await p.approveOrder(
      orderId: widget.orderId,
      note: p.noteController.text.trim().isEmpty ? null : p.noteController.text.trim(),
    );
    if (success && mounted) {
      await _loadDetail();
    }
  }

  Future<void> _handleRejectOrder() async {
    final p = context.read<ManagerProvider>();
    p.noteController.clear();

    final confirmed = await _showNoteDialog(
      title: 'Tolak Pesanan',
      subtitle: 'Masukkan alasan penolakan (opsional)',
      actionLabel: 'Tolak',
      actionColor: _kDanger,
      icon: Icons.cancel_outlined,
    );
    if (!confirmed) return;

    final success = await p.rejectOrder(
      orderId: widget.orderId,
      note: p.noteController.text.trim().isEmpty ? null : p.noteController.text.trim(),
    );
    if (success && mounted) {
      await _loadDetail();
    }
  }

  // ── Approve/Reject Invoice ────────────────────────────────────────────────
  Future<void> _handleApproveInvoice() async {
    final p = context.read<ManagerProvider>();
    p.noteController.clear();

    final confirmed = await _showNoteDialog(
      title: 'Setujui Tagihan',
      subtitle: 'Tagihan akan disetujui (Siap Tagih). Masukkan catatan (opsional)',
      actionLabel: 'Setujui',
      actionColor: _kSuccess,
      icon: Icons.receipt_long_rounded,
    );
    if (!confirmed) return;

    final success = await p.approveInvoice(
      orderId: widget.orderId,
      note: p.noteController.text.trim().isEmpty ? null : p.noteController.text.trim(),
    );
    if (success && mounted) {
      await _loadDetail();
    }
  }

  Future<void> _handleRejectInvoice() async {
    final p = context.read<ManagerProvider>();
    p.noteController.clear();

    final confirmed = await _showNoteDialog(
      title: 'Tolak Tagihan',
      subtitle: 'Masukkan alasan penolakan tagihan (opsional)',
      actionLabel: 'Tolak',
      actionColor: _kDanger,
      icon: Icons.cancel_outlined,
    );
    if (!confirmed) return;

    final success = await p.rejectInvoice(
      orderId: widget.orderId,
      note: p.noteController.text.trim().isEmpty ? null : p.noteController.text.trim(),
    );
    if (success && mounted) {
      await _loadDetail();
    }
  }

  // ── Note Dialog ───────────────────────────────────────────────────────────
  Future<bool> _showNoteDialog({
    required String title,
    required String subtitle,
    required String actionLabel,
    required Color actionColor,
    required IconData icon,
  }) async {
    final p = context.read<ManagerProvider>();
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: _kSurface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: _kBorder,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                // Title
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: actionColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, color: actionColor, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: _kTextPrimary,
                            ),
                          ),
                          Text(
                            subtitle,
                            style: const TextStyle(fontSize: 12, color: _kTextSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Note Input
                Container(
                  decoration: BoxDecoration(
                    color: _kBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _kBorder),
                  ),
                  child: TextField(
                    controller: p.noteController,
                    maxLines: 3,
                    style: const TextStyle(fontSize: 14, color: _kTextPrimary),
                    decoration: const InputDecoration(
                      hintText: 'Tulis catatan di sini...',
                      hintStyle: TextStyle(color: _kTextSecondary, fontSize: 14),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(14),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(color: _kBorder),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Batal', style: TextStyle(color: _kTextPrimary)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: actionColor,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        child: Text(
                          actionLabel,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
    return result ?? false;
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final p = context.watch<ManagerProvider>();
    final order = p.selectedOrder;

    return Scaffold(
      backgroundColor: _kBg,
      appBar: _buildAppBar(order),
      body: p.isLoadingDetail
          ? const Center(child: CircularProgressIndicator(color: _kPrimary))
          : order.id == null
              ? _buildEmptyState()
              : _buildContent(order),
      bottomNavigationBar: order.id == null ? null : _buildActionBar(order),
    );
  }

  PreferredSizeWidget _buildAppBar(ManagerOrderData order) {
    return AppBar(
      backgroundColor: _kSurface,
      surfaceTintColor: _kSurface,
      foregroundColor: _kTextPrimary,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
        onPressed: () => CusNav.nPop(context),
      ),
      title: const Text(
        'Detail Pesanan',
        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: _kTextPrimary),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: _kBorder),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_rounded, size: 56, color: _kTextSecondary),
          SizedBox(height: 16),
          Text('Detail pesanan tidak tersedia', style: TextStyle(color: _kTextSecondary)),
        ],
      ),
    );
  }

  Widget _buildContent(ManagerOrderData order) {
    return RefreshIndicator(
      color: _kPrimary,
      onRefresh: _loadDetail,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
        children: [
          // Status card
          _buildStatusCard(order),
          const SizedBox(height: 12),

          // Buyer info
          _buildSection(
            title: 'Info Pembeli',
            icon: Icons.person_outline_rounded,
            child: _buildBuyerInfo(order.buyer),
          ),
          const SizedBox(height: 12),

          // Seller info
          _buildSection(
            title: 'Info Penjual',
            icon: Icons.storefront_outlined,
            child: _buildSellerInfo(order.seller),
          ),
          const SizedBox(height: 12),

          // Order Items
          if (order.orderItems != null && order.orderItems!.isNotEmpty) ...[
            _buildSection(
              title: 'Daftar Produk',
              icon: Icons.inventory_2_outlined,
              child: _buildOrderItems(order),
            ),
            const SizedBox(height: 12),
          ],

          // Summary
          _buildSection(
            title: 'Ringkasan Pembayaran',
            icon: Icons.receipt_outlined,
            child: _buildSummary(order),
          ),
          const SizedBox(height: 12),

          // Order Logs / Timeline
          if (order.orderLogs != null && order.orderLogs!.isNotEmpty) ...[
            _buildSection(
              title: 'Riwayat Status',
              icon: Icons.timeline_rounded,
              child: _buildTimeline(order.orderLogs!),
            ),
          ],
        ],
      ),
    );
  }

  // ── Status Card ───────────────────────────────────────────────────────────
  Widget _buildStatusCard(ManagerOrderData order) {
    final statusColor = order.statusColor;
    final statusLabel = order.statusLabel;
    final date = _formatDate(order.createdAt);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kBorder),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  order.orderNum ?? '-',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _kTextPrimary),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: statusColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Tanggal: $date',
            style: const TextStyle(fontSize: 12, color: _kTextSecondary),
          ),
        ],
      ),
    );
  }

  // ── Buyer Info ────────────────────────────────────────────────────────────
  Widget _buildBuyerInfo(ManagerOrderBuyer? buyer) {
    if (buyer == null) return const Text('-', style: TextStyle(color: _kTextSecondary));
    return Column(
      children: [
        _buildInfoRow('Nama Pembeli', buyer.buyerName ?? '-'),
        _buildInfoRow('Penerima', buyer.recipientName ?? '-'),
        _buildInfoRow('No. HP', buyer.recipientPhone ?? '-'),
        _buildInfoRow('Email', buyer.recipientEmail ?? '-'),
        _buildInfoRow('Alamat', buyer.recipientAddress ?? '-'),
      ],
    );
  }

  // ── Seller Info ───────────────────────────────────────────────────────────
  Widget _buildSellerInfo(ManagerOrderSeller? seller) {
    if (seller == null) return const Text('-', style: TextStyle(color: _kTextSecondary));
    return Column(
      children: [
        _buildInfoRow('Perusahaan', seller.companyName ?? '-'),
        _buildInfoRow('No. HP', seller.phone ?? '-'),
        _buildInfoRow('Email', seller.email ?? '-'),
        _buildInfoRow('Alamat', seller.address ?? '-'),
      ],
    );
  }

  // ── Order Items ───────────────────────────────────────────────────────────
  Widget _buildOrderItems(ManagerOrderData order) {
    final items = order.orderItems ?? [];
    return Column(
      children: [
        ...items.asMap().entries.map((e) {
          final item = e.value;
          final isLast = e.key == items.length - 1;
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              border: isLast ? null : const Border(bottom: BorderSide(color: _kBorder)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.productName ?? '-',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _kTextPrimary),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Qty: ${item.qty ?? 0} × ${_currency.format(item.finalPrice ?? 0)}',
                        style: const TextStyle(fontSize: 12, color: _kTextSecondary),
                      ),
                    ],
                  ),
                ),
                Text(
                  _currency.format((item.finalPrice ?? 0) * (item.qty ?? 0)),
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _kTextPrimary),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  // ── Summary ───────────────────────────────────────────────────────────────
  Widget _buildSummary(ManagerOrderData order) {
    return Column(
      children: [
        _buildSummaryRow('Subtotal Produk', _currency.format(order.subtotal)),
        _buildSummaryRow('Ongkos Kirim', _currency.format(order.shippingCost ?? 0)),
        Container(
          margin: const EdgeInsets.only(top: 8),
          padding: const EdgeInsets.only(top: 12),
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: _kBorder)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _kTextPrimary),
              ),
              Text(
                _currency.format(order.grandTotal),
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _kPrimary),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: _kTextSecondary)),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: _kTextPrimary)),
        ],
      ),
    );
  }

  // ── Timeline / Order Logs ─────────────────────────────────────────────────
  Widget _buildTimeline(List<ManagerOrderLog> logs) {
    // Sort by id desc so most recent is first
    final sorted = [...logs]..sort((a, b) => (b.id ?? 0).compareTo(a.id ?? 0));
    return Column(
      children: sorted.asMap().entries.map((e) {
        final log = e.value;
        final isLast = e.key == sorted.length - 1;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  margin: const EdgeInsets.only(top: 4),
                  decoration: BoxDecoration(
                    color: e.key == 0 ? _kPrimary : _kBorder,
                    shape: BoxShape.circle,
                  ),
                ),
                if (!isLast)
                  Container(width: 2, height: 40, color: _kBorder),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      log.title ?? log.status ?? '-',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: e.key == 0 ? _kPrimary : _kTextPrimary,
                      ),
                    ),
                    if (log.note != null && log.note!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(log.note!, style: const TextStyle(fontSize: 12, color: _kTextSecondary)),
                    ],
                    const SizedBox(height: 2),
                    Text(
                      _formatDate(log.createdAt),
                      style: const TextStyle(fontSize: 11, color: _kTextSecondary),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  // ── Section wrapper ───────────────────────────────────────────────────────
  Widget _buildSection({required String title, required IconData icon, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kBorder),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: _kPrimary),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _kTextPrimary),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  // ── Info Row ─────────────────────────────────────────────────────────────
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label, style: const TextStyle(fontSize: 12, color: _kTextSecondary)),
          ),
          const Text(' : ', style: TextStyle(fontSize: 12, color: _kTextSecondary)),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13, color: _kTextPrimary, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  // ── Action Bottom Bar ─────────────────────────────────────────────────────
  // Business logic: shows buttons only when conditions are met (same as Laravel service)
  Widget? _buildActionBar(ManagerOrderData order) {
    final bool canApproveOrder = order.canApproveOrder;
    final bool canApproveInvoice = order.canApproveInvoice;

    if (!canApproveOrder && !canApproveInvoice) return null;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 30),
      decoration: const BoxDecoration(
        color: _kSurface,
        border: Border(top: BorderSide(color: _kBorder)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Persetujuan Pesanan Baru (status == 'pesanan baru') ──────────
          if (canApproveOrder) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(right: 6),
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.cancel_outlined, size: 18),
                      label: const Text('Tolak'),
                      onPressed: _handleRejectOrder,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _kDanger,
                        side: const BorderSide(color: _kDanger),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(left: 6),
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
                      label: const Text('Setujui'),
                      onPressed: _handleApproveOrder,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _kSuccess,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Pesanan ini menunggu persetujuan Manager',
              style: TextStyle(fontSize: 11, color: _kTextSecondary),
              textAlign: TextAlign.center,
            ),
          ],

          // ── Persetujuan Tagihan (status == 'tagihan') ─────────────────────
          if (canApproveInvoice) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(right: 6),
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.cancel_outlined, size: 18),
                      label: const Text('Tolak Tagihan'),
                      onPressed: _handleRejectInvoice,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _kDanger,
                        side: const BorderSide(color: _kDanger),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(left: 6),
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.receipt_long_rounded, size: 18),
                      label: const Text('Siap Tagih'),
                      onPressed: _handleApproveInvoice,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _kPrimary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Tagihan dari Seller menunggu konfirmasi Manager',
              style: TextStyle(fontSize: 11, color: _kTextSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(String? iso) {
    if (iso == null || iso.isEmpty) return '-';
    try {
      final dt = DateTime.parse(iso).toLocal();
      return DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(dt);
    } catch (_) {
      return iso;
    }
  }
}
