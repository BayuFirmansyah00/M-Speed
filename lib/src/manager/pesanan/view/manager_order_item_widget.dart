import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mspeed/src/manager/pesanan/model/manager_order_model.dart';

// ── Manager Order Status Color & Label Helper ──────────────────────────────
// Status strings are EXACT matches of Laravel ManagerOrderMainService constants
extension ManagerOrderStatusExt on ManagerOrderData {
  /// Returns display label for current order status (latest log wins)
  String get statusLabel {
    final s = latestLogFromHistory?.status ?? paymentStatus ?? '';
    switch (s) {
      case 'pesanan baru':
        return 'Pesanan Baru';
      case 'approve pesanan by manager':
        return 'Disetujui Manager';
      case 'reject pesanan by manager':
        return 'Ditolak Manager';
      case 'tagihan':
        return 'Tagihan';
      case 'siap tagih by manager':
        return 'Siap Tagih';
      case 'tolak tagih by manager':
        return 'Tagihan Ditolak';
      case 'diterima seller':
        return 'Diterima Seller';
      case 'dikirim':
        return 'Dikirim';
      case 'selesai':
        return 'Selesai';
      default:
        return s.isNotEmpty ? s : 'Tidak Diketahui';
    }
  }

  /// Returns status badge color
  Color get statusColor {
    final s = latestLogFromHistory?.status ?? paymentStatus ?? '';
    switch (s) {
      case 'pesanan baru':
        return const Color(0xFF2563EB); // blue
      case 'approve pesanan by manager':
        return const Color(0xFF16A34A); // green
      case 'reject pesanan by manager':
        return const Color(0xFFDC2626); // red
      case 'tagihan':
        return const Color(0xFFD97706); // amber
      case 'siap tagih by manager':
        return const Color(0xFF0891B2); // cyan
      case 'tolak tagih by manager':
        return const Color(0xFFDC2626); // red
      case 'diterima seller':
        return const Color(0xFF7C3AED); // purple
      case 'dikirim':
        return const Color(0xFF0891B2); // cyan
      case 'selesai':
        return const Color(0xFF16A34A); // green
      default:
        return const Color(0xFF6B7280); // gray
    }
  }
}

// ── Currency Formatter ────────────────────────────────────────────────────
final _currencyFmt = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

// ─────────────────────────────────────────────────────────────────────────────
// Widget
// ─────────────────────────────────────────────────────────────────────────────
class ManagerOrderItemWidget extends StatelessWidget {
  final ManagerOrderData order;
  final VoidCallback? onTap;

  const ManagerOrderItemWidget({super.key, required this.order, this.onTap});

  static const Color _kTextPrimary = Color(0xFF1F2937);
  static const Color _kTextSecondary = Color(0xFF6B7280);
  static const Color _kBorder = Color(0xFFE5E7EB);
  static const Color _kManagerBlue = Color(0xFF1D4ED8);

  @override
  Widget build(BuildContext context) {
    final statusColor = order.statusColor;
    final statusLabel = order.statusLabel;
    final formattedDate = _formatDate(order.createdAt);
    final buyerName = order.buyer?.buyerName ?? order.buyer?.recipientName ?? 'Buyer';
    final totalStr = _currencyFmt.format(order.grandTotal);

    // Show action indicator badges
    final needsAction = order.canApproveOrder || order.canApproveInvoice;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: needsAction ? _kManagerBlue.withValues(alpha: 0.25) : _kBorder,
            width: needsAction ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: needsAction
                  ? _kManagerBlue.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: needsAction ? _kManagerBlue.withValues(alpha: 0.03) : null,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                border: Border(bottom: BorderSide(color: _kBorder.withValues(alpha: 0.6))),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          Icons.receipt_long_rounded,
                          size: 16,
                          color: _kTextSecondary.withValues(alpha: 0.8),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            order.orderNum ?? '-',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: _kTextPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Status badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      statusLabel,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Body ──────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _InfoColumn(label: 'Pembeli', value: buyerName),
                      ),
                      const SizedBox(width: 8),
                      _InfoColumn(
                        label: 'Total Pembayaran',
                        value: totalStr,
                        valueStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: _kManagerBlue,
                        ),
                        crossAxisAlignment: CrossAxisAlignment.end,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _InfoColumn(
                          label: 'Tanggal Pesanan',
                          value: formattedDate,
                        ),
                      ),
                      if (needsAction)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _kManagerBlue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.pending_actions_rounded, size: 12, color: _kManagerBlue),
                              const SizedBox(width: 4),
                              Text(
                                'Perlu Tindakan',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: _kManagerBlue,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
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

// ── Helper widget ──────────────────────────────────────────────────────────
class _InfoColumn extends StatelessWidget {
  final String label;
  final String value;
  final TextStyle? valueStyle;
  final CrossAxisAlignment crossAxisAlignment;

  const _InfoColumn({
    required this.label,
    required this.value,
    this.valueStyle,
    this.crossAxisAlignment = CrossAxisAlignment.start,
  });

  static const Color _kTextPrimary = Color(0xFF1F2937);
  static const Color _kTextSecondary = Color(0xFF6B7280);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: crossAxisAlignment,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: _kTextSecondary)),
        const SizedBox(height: 2),
        Text(
          value,
          style: valueStyle ??
              const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: _kTextPrimary,
              ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
