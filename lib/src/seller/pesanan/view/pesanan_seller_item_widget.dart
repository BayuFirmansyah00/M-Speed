import 'package:flutter/material.dart';
import '../model/seller_order_status.dart';


class PesananSellerItemWidget extends StatelessWidget {
  final String orderNumber;
  final String date;
  final String sellerName; // Not currently used, kept for compat
  final String alamat;
  final String totalPesanan;
  final SellerOrderStatus status;
  final Color bgColor; // Not used anymore as we use a modern white card, kept for compat

  const PesananSellerItemWidget({
    super.key,
    required this.orderNumber,
    required this.date,
    required this.sellerName,
    required this.alamat,
    required this.totalPesanan,
    required this.status,
    required this.bgColor,
  });

  // M-SPEED Brand Colors
  static const Color _kPrimary = Color(0xFF1565C0);
  static const Color _kTextPrimary = Color(0xFF1F2937);
  static const Color _kTextSecondary = Color(0xFF6B7280);
  static const Color _kBorder = Color(0xFFE5E7EB);

  @override
  Widget build(BuildContext context) {
    final statusColor = status.color;
    final statusLabel = status.displayTitle;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Order Number and Status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: _kBorder.withOpacity(0.6), width: 1)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.receipt_long_rounded, size: 18, color: _kTextSecondary.withOpacity(0.8)),
                    const SizedBox(width: 8),
                    Text(
                      orderNumber,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _kTextPrimary,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
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
          
          // Body: Date, Alamat, Total
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Info Row
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Tanggal Pesanan', style: TextStyle(fontSize: 11, color: _kTextSecondary)),
                          const SizedBox(height: 2),
                          Text(date, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: _kTextPrimary)),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Total Pesanan', style: TextStyle(fontSize: 11, color: _kTextSecondary)),
                          const SizedBox(height: 2),
                          Text(
                            totalPesanan,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _kPrimary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text('Alamat Pengiriman', style: TextStyle(fontSize: 11, color: _kTextSecondary)),
                const SizedBox(height: 2),
                Text(
                  alamat,
                  style: const TextStyle(fontSize: 13, color: _kTextPrimary),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
