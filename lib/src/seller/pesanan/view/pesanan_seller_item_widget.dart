import 'package:flutter/material.dart';
import '../../../buyer/transaction/provider/transaction_status.dart';

class PesananSellerItemWidget extends StatelessWidget {
  final String orderNumber;
  final String date;
  final String sellerName; // Not currently used, kept for compat
  final String alamat;
  final String totalPesanan;
  final TransactionStatus status;
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
  static const Color _kPrimaryBlue = Color(0xFF1565C0);
  static const Color _kSuccess = Color(0xFF16A765);
  static const Color _kDanger = Color(0xFFE53935);
  static const Color _kWarning = Color(0xFFF9A825);
  static const Color _kTextPrimary = Color(0xFF1F2937);
  static const Color _kTextSecondary = Color(0xFF6B7280);
  static const Color _kBorder = Color(0xFFE5E7EB);

  Color _getStatusColor() {
    switch (status) {
      case TransactionStatus.PESANAN_BARU:
      case TransactionStatus.PESANAN_DIKIRIM:
        return _kWarning;
      case TransactionStatus.BARANG_DITERIMA:
      case TransactionStatus.TELAH_DIBAYAR:
      case TransactionStatus.PESANAN_SELESAI:
        return _kSuccess;
      case TransactionStatus.PROSES_PEMBAYARAN:
      case TransactionStatus.PESANAN_DITOLAK:
        return _kDanger;
      case TransactionStatus.PESANAN_DITERIMA:
        return _kPrimaryBlue;
      default:
        return _kTextSecondary;
    }
  }

  String _getStatusLabel() {
    switch (status) {
      case TransactionStatus.PESANAN_BARU:
        return 'Pesanan Baru';
      case TransactionStatus.PESANAN_DITERIMA:
        return 'Diterima';
      case TransactionStatus.PESANAN_DIKIRIM:
        return 'Dikirim';
      case TransactionStatus.BARANG_DITERIMA:
        return 'Brg Diterima';
      case TransactionStatus.PROSES_PEMBAYARAN:
        return 'Proses Bayar';
      case TransactionStatus.TELAH_DIBAYAR:
        return 'Dibayar';
      case TransactionStatus.PESANAN_DITOLAK:
        return 'Ditolak';
      case TransactionStatus.PESANAN_SELESAI:
        return 'Selesai';
      default:
        return status.toString().split('.').last.replaceAll('_', ' ');
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();
    final statusLabel = _getStatusLabel();

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
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _kPrimaryBlue),
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
