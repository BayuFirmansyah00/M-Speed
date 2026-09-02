import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mspeed/src/buyer/transaction/provider/transaction_status.dart';
import 'package:mspeed/src/keuangan/pesanan/model/finance_order_model.dart';

class OrderItem extends StatelessWidget {
  final FinanceOrderData? order;
  final bool highlightAction;

  // Backwards compatibility legacy fields
  final String? orderNumber;
  final String? date;
  final String? sellerName;
  final String? total;
  final TransactionStatus? status;
  final Color? bgColor;

  const OrderItem({
    super.key,
    this.order,
    this.highlightAction = false,
    this.orderNumber,
    this.date,
    this.sellerName,
    this.total,
    this.status,
    this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    // Derived properties from modern FinanceOrderData or fallback
    final displayOrderNum = order?.orderNum.isNotEmpty == true
        ? order!.orderNum
        : (orderNumber ?? '-');

    final displayDate = order?.createdAt != null
        ? _formatDate(order!.createdAt!)
        : (date ?? '-');

    final displaySellerName = order?.seller?.companyName.isNotEmpty == true
        ? order!.seller!.companyName
        : (sellerName ?? 'Seller');

    final displayBuyerName = order?.buyer?.buyerName ?? '';

    final displayTotal = order != null
        ? currencyFormatter.format(order!.grandTotal)
        : (total != null ? 'Rp $total' : 'Rp 0');

    final statusLabel = order != null
        ? order!.statusDisplayLabel
        : (status != null ? status!.statusName() : 'MEMPROSES');

    final statusColor = order != null
        ? order!.statusBadgeColor
        : const Color(0xFFD97706);

    final canPay = order?.canProcessPayment ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: (highlightAction || canPay)
              ? const Color(0xFFF59E0B).withValues(alpha: 0.5)
              : const Color(0xFFEBEBF0),
          width: (highlightAction || canPay) ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card (Order Number & Date)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: (highlightAction || canPay)
                  ? const Color(0xFFFEF3C7).withValues(alpha: 0.5)
                  : const Color(0xFFF9FAFC),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(17)),
              border: const Border(bottom: BorderSide(color: Color(0xFFEEF0F5), width: 1)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.receipt_long_rounded, color: Color(0xFFD97706), size: 18),
                    const SizedBox(width: 8),
                    Text(
                      displayOrderNum,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF100629),
                      ),
                    ),
                  ],
                ),
                Text(
                  displayDate,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF8A93A3),
                  ),
                ),
              ],
            ),
          ),

          // Body Card (Seller & Buyer Details)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD97706).withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.storefront_rounded, color: Color(0xFFD97706), size: 16),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Seller',
                            style: TextStyle(fontSize: 10, color: Color(0xFF8A93A3), fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            displaySellerName,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF100629),
                            ),
                          ),
                          if (displayBuyerName.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              'Buyer: $displayBuyerName',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(height: 1, color: Color(0xFFF0F1F5)),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Total Pembayaran',
                          style: TextStyle(fontSize: 10, color: Color(0xFF8A93A3), fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          displayTotal,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFFD97706),
                          ),
                        ),
                      ],
                    ),
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: statusColor.withValues(alpha: 0.3), width: 1),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (canPay) ...[
                              const Icon(Icons.touch_app_rounded, size: 13, color: Color(0xFFF59E0B)),
                              const SizedBox(width: 4),
                            ],
                            Flexible(
                              child: Text(
                                statusLabel,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: statusColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _formatDate(String isoString) {
    try {
      final dt = DateTime.parse(isoString);
      return DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(dt);
    } catch (_) {
      return isoString;
    }
  }
}
