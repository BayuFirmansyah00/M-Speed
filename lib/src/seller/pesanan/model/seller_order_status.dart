import 'package:flutter/material.dart';
import '../../../../common/helper/constant.dart';

enum SellerOrderStatus {
  pesananBaru('pesanan baru', 0),
  notApproveByManager('not approve pesanan by manager', 1),
  rejectPesananByManager('reject pesanan by manager', 1),
  approvePesananByManager('approve pesanan by manager', 2),
  pesananDiterimaPenjual('pesanan diterima penjual', 3),
  pesananDikirim('pesanan dikirim', 4),
  pesananDikirm('pesanan dikirm', 4), // Fallback for DB typo
  pesananDiterimaPenerima('pesanan diterima penerima', 5),
  tagihan('tagihan', 6),
  siapTagihByManager('siap tagih by manager', 7),
  tolakTagihByManager('tolak tagih by manager', 8),
  penerimaanVerifikasi('penerimaan & verifikasi', 9),
  pesananDibayar('pesanan dibayar', 10),
  pembayaranDitolakFinance('pembayaran ditolak finance', 11),
  unknown('unknown', -1);

  final String rawValue;
  final int indexStatus;

  const SellerOrderStatus(this.rawValue, this.indexStatus);

  /// Parse the raw string from Laravel backend to the enum
  static SellerOrderStatus fromString(String? status) {
    if (status == null) return SellerOrderStatus.unknown;
    
    final lower = status.toLowerCase().trim();
    for (var element in SellerOrderStatus.values) {
      if (element.rawValue == lower) {
        return element;
      }
    }
    return SellerOrderStatus.unknown;
  }

  /// Title to display in the UI for this status
  String get displayTitle {
    switch (this) {
      case SellerOrderStatus.pesananBaru:
        return 'Pesanan Baru (Menunggu Manager)';
      case SellerOrderStatus.notApproveByManager:
      case SellerOrderStatus.rejectPesananByManager:
        return 'Pesanan Ditolak Manager';
      case SellerOrderStatus.approvePesananByManager:
        return 'Pesanan Disetujui Manager';
      case SellerOrderStatus.pesananDiterimaPenjual:
        return 'Diproses Penjual';
      case SellerOrderStatus.pesananDikirim:
      case SellerOrderStatus.pesananDikirm:
        return 'Pesanan Dikirim';
      case SellerOrderStatus.pesananDiterimaPenerima:
        return 'Pesanan Diterima Penerima';
      case SellerOrderStatus.tagihan:
        return 'Menunggu Verifikasi Tagihan Manager';
      case SellerOrderStatus.siapTagihByManager:
        return 'Siap Ditagih (Menunggu Finance)';
      case SellerOrderStatus.tolakTagihByManager:
        return 'Tagihan Ditolak Manager';
      case SellerOrderStatus.penerimaanVerifikasi:
        return 'Terverifikasi (Menunggu Pembayaran)';
      case SellerOrderStatus.pesananDibayar:
        return 'Pesanan Lunas (Telah Dibayar)';
      case SellerOrderStatus.pembayaranDitolakFinance:
        return 'Pembayaran Ditolak Finance';
      case SellerOrderStatus.unknown:
        return rawValue; // Fallback to raw string if unknown
    }
  }
  
  /// Helper logic for UI buttons based strictly on Laravel Business Flow
  bool get canAccept => this == SellerOrderStatus.approvePesananByManager;
  bool get canReject => this == SellerOrderStatus.approvePesananByManager;
  bool get canShip => this == SellerOrderStatus.pesananDiterimaPenjual;
  bool get canCreateInvoice => this == SellerOrderStatus.pesananDiterimaPenerima;
  bool get canReInvoice => this == SellerOrderStatus.tolakTagihByManager;

  bool get isCompleted =>
      this == SellerOrderStatus.penerimaanVerifikasi ||
      this == SellerOrderStatus.pesananDibayar;
  bool get isRejected =>
      this == SellerOrderStatus.notApproveByManager ||
      this == SellerOrderStatus.rejectPesananByManager ||
      this == SellerOrderStatus.pembayaranDitolakFinance;
  
  /// Color for the UI tags
  Color get color {
    switch (this) {
      case SellerOrderStatus.pesananBaru:
      case SellerOrderStatus.approvePesananByManager:
        return Constant.statusColor('PESANAN_BARU');
      case SellerOrderStatus.pesananDiterimaPenjual:
        return Constant.statusColor('PESANAN_DITERIMA');
      case SellerOrderStatus.pesananDikirim:
      case SellerOrderStatus.pesananDikirm:
        return Constant.statusColor('PESANAN_DIKIRIM');
      case SellerOrderStatus.pesananDiterimaPenerima:
      case SellerOrderStatus.tagihan:
      case SellerOrderStatus.siapTagihByManager:
        return Constant.statusColor('PESANAN_TELAH_DITERIMA');
      case SellerOrderStatus.penerimaanVerifikasi:
      case SellerOrderStatus.pesananDibayar:
        return Constant.statusColor('TELAH_DIBAYAR');
      case SellerOrderStatus.notApproveByManager:
      case SellerOrderStatus.rejectPesananByManager:
      case SellerOrderStatus.tolakTagihByManager:
      case SellerOrderStatus.pembayaranDitolakFinance:
        return Constant.statusColor('PESANAN_DITOLAK');
      default:
        return Colors.grey;
    }
  }
}
