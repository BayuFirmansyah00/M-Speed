import 'package:flutter/material.dart';

/// Model representing list and single order response for Role Finance
/// Maps exactly to Laravel FinanceOrderResource
class FinanceOrderListResponse {
  final List<FinanceOrderData> data;
  final FinanceOrderMeta? meta;
  final FinanceOrderLinks? links;

  FinanceOrderListResponse({
    this.data = const [],
    this.meta,
    this.links,
  });

  factory FinanceOrderListResponse.fromJson(dynamic json) {
    if (json is List) {
      return FinanceOrderListResponse(
        data: json.map((item) => FinanceOrderData.fromJson(item)).toList(),
      );
    }
    if (json is Map<String, dynamic>) {
      final rawData = json['data'];
      List<FinanceOrderData> items = [];
      if (rawData is List) {
        items = rawData.map((item) => FinanceOrderData.fromJson(item)).toList();
      } else if (rawData is Map<String, dynamic>) {
        items = [FinanceOrderData.fromJson(rawData)];
      }
      return FinanceOrderListResponse(
        data: items,
        meta: json['meta'] != null ? FinanceOrderMeta.fromJson(json['meta']) : null,
        links: json['links'] != null ? FinanceOrderLinks.fromJson(json['links']) : null,
      );
    }
    return FinanceOrderListResponse();
  }
}

class FinanceOrderDetailResponse {
  final FinanceOrderData? data;
  final String? message;

  FinanceOrderDetailResponse({this.data, this.message});

  factory FinanceOrderDetailResponse.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    return FinanceOrderDetailResponse(
      data: rawData is Map<String, dynamic> ? FinanceOrderData.fromJson(rawData) : null,
      message: json['meta']?['message']?.toString() ?? json['message']?.toString(),
    );
  }
}

class FinanceOrderData {
  final int id;
  final String orderNum;
  final String paymentStatus;
  final double shippingCost;
  final FinanceOrderSeller? seller;
  final FinanceOrderBuyer? buyer;
  final FinanceOrderFinance? finance;
  final int? prkSubmissionId;
  final FinanceOrderLog? latestLog;
  final List<FinanceOrderItem> orderItems;
  final List<FinanceOrderLog> orderLogs;
  final List<FinancePaymentProof> paymentProofs;
  final String? createdAt;
  final String? updatedAt;

  FinanceOrderData({
    this.id = 0,
    this.orderNum = '',
    this.paymentStatus = '',
    this.shippingCost = 0.0,
    this.seller,
    this.buyer,
    this.finance,
    this.prkSubmissionId,
    this.latestLog,
    this.orderItems = const [],
    this.orderLogs = const [],
    this.paymentProofs = const [],
    this.createdAt,
    this.updatedAt,
  });

  factory FinanceOrderData.fromJson(Map<String, dynamic> json) {
    return FinanceOrderData(
      id: _parseInt(json['id']),
      orderNum: json['order_num']?.toString() ?? json['order_number']?.toString() ?? '',
      paymentStatus: json['payment_status']?.toString() ?? '',
      shippingCost: _parseDouble(json['shipping_cost']),
      seller: json['seller'] != null ? FinanceOrderSeller.fromJson(json['seller']) : null,
      buyer: json['buyer'] != null ? FinanceOrderBuyer.fromJson(json['buyer']) : null,
      finance: json['finance'] != null ? FinanceOrderFinance.fromJson(json['finance']) : null,
      prkSubmissionId: json['prk_submission_id'] != null ? _parseInt(json['prk_submission_id']) : null,
      latestLog: json['latest_log'] != null ? FinanceOrderLog.fromJson(json['latest_log']) : null,
      orderItems: (json['order_items'] as List<dynamic>?)
              ?.map((e) => FinanceOrderItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      orderLogs: (json['order_logs'] as List<dynamic>?)
              ?.map((e) => FinanceOrderLog.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      paymentProofs: (json['payment_proofs'] as List<dynamic>?)
              ?.map((e) => FinancePaymentProof.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  // ── Computed Business Logic & Helpers ─────────────────────────────────────

  /// Subtotal of all items
  double get subtotalItems {
    if (orderItems.isEmpty) return 0.0;
    return orderItems.fold(0.0, (sum, item) => sum + item.finalPrice);
  }

  /// Grand Total = Subtotal Items + Shipping Cost
  double get grandTotal => subtotalItems + shippingCost;

  /// Status of the latest log in lowercase
  String get activeStatusLog {
    if (latestLog != null && latestLog!.status.isNotEmpty) {
      return latestLog!.status.toLowerCase().trim();
    }
    if (orderLogs.isNotEmpty) {
      return orderLogs.first.status.toLowerCase().trim();
    }
    return paymentStatus.toLowerCase().trim();
  }

  /// Actionability: Finance can execute payment or reject payment
  /// only when latest order log status is 'penerimaan & verifikasi'
  bool get canProcessPayment => activeStatusLog == 'penerimaan & verifikasi';

  /// Whether the order is paid
  bool get isPaid =>
      paymentStatus.toLowerCase().contains('dibayar') ||
      activeStatusLog == 'pesanan dibayar' ||
      activeStatusLog == 'telah_dibayar';

  /// Whether payment was rejected by finance
  bool get isRejected => activeStatusLog.contains('ditolak');

  /// Status display label
  String get statusDisplayLabel {
    final status = activeStatusLog;
    if (status == 'penerimaan & verifikasi') return 'Siap Dibayar';
    if (status == 'pesanan dibayar' || status == 'telah_dibayar') return 'Telah Dibayar';
    if (status == 'pembayaran ditolak finance') return 'Pembayaran Ditolak';
    if (status == 'siap tagih by manager') return 'Siap Tagih';
    if (status == 'barang dikirim') return 'Dikirim';
    if (status == 'pesanan diterima seller') return 'Diproses Seller';
    if (status == 'pesanan disetujui manager') return 'Disetujui Manager';
    if (status == 'pesanan baru') return 'Pesanan Baru';
    if (status == 'pesanan selesai') return 'Pesanan Selesai';
    if (status == 'dibatalkan') return 'Dibatalkan';
    return status.isNotEmpty ? status.toUpperCase() : 'MEMPROSES';
  }

  /// Status display color
  Color get statusBadgeColor {
    final status = activeStatusLog;
    if (status == 'penerimaan & verifikasi') return const Color(0xFFF59E0B); // Amber - Action Required
    if (status == 'pesanan dibayar' || status == 'telah_dibayar' || status == 'pesanan selesai') {
      return const Color(0xFF10B981); // Emerald - Done
    }
    if (status.contains('ditolak') || status == 'dibatalkan') {
      return const Color(0xFFEF4444); // Red - Rejected
    }
    if (status == 'barang dikirim') return const Color(0xFF3B82F6); // Blue
    return const Color(0xFF6B7280); // Gray
  }

  static int _parseInt(dynamic val) {
    if (val == null) return 0;
    if (val is int) return val;
    return int.tryParse(val.toString()) ?? 0;
  }

  static double _parseDouble(dynamic val) {
    if (val == null) return 0.0;
    if (val is double) return val;
    if (val is int) return val.toDouble();
    return double.tryParse(val.toString()) ?? 0.0;
  }
}

class FinanceOrderSeller {
  final int id;
  final String companyName;
  final String phone;
  final String email;
  final String address;

  FinanceOrderSeller({
    this.id = 0,
    this.companyName = '',
    this.phone = '',
    this.email = '',
    this.address = '',
  });

  factory FinanceOrderSeller.fromJson(Map<String, dynamic> json) {
    return FinanceOrderSeller(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      companyName: json['company_name']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
    );
  }
}

class FinanceOrderBuyer {
  final int id;
  final String buyerName;
  final String recipientName;
  final String recipientPhone;
  final String recipientEmail;
  final String recipientAddress;

  FinanceOrderBuyer({
    this.id = 0,
    this.buyerName = '',
    this.recipientName = '',
    this.recipientPhone = '',
    this.recipientEmail = '',
    this.recipientAddress = '',
  });

  factory FinanceOrderBuyer.fromJson(Map<String, dynamic> json) {
    return FinanceOrderBuyer(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      buyerName: json['buyer_name']?.toString() ?? '',
      recipientName: json['recipient_name']?.toString() ?? '',
      recipientPhone: json['recipient_phone']?.toString() ?? '',
      recipientEmail: json['recipient_email']?.toString() ?? '',
      recipientAddress: json['recipient_address']?.toString() ?? '',
    );
  }
}

class FinanceOrderFinance {
  final int? financeId;
  final String? financeName;

  FinanceOrderFinance({this.financeId, this.financeName});

  factory FinanceOrderFinance.fromJson(Map<String, dynamic> json) {
    return FinanceOrderFinance(
      financeId: json['finance_id'] != null
          ? int.tryParse(json['finance_id'].toString())
          : null,
      financeName: json['finance_name']?.toString(),
    );
  }
}

class FinanceOrderItem {
  final int id;
  final String productName;
  final int qty;
  final double initialPrice;
  final double tax;
  final double finalPrice;

  FinanceOrderItem({
    this.id = 0,
    this.productName = '',
    this.qty = 0,
    this.initialPrice = 0.0,
    this.tax = 0.0,
    this.finalPrice = 0.0,
  });

  factory FinanceOrderItem.fromJson(Map<String, dynamic> json) {
    return FinanceOrderItem(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      productName: json['product_name']?.toString() ?? '',
      qty: json['qty'] is int ? json['qty'] : int.tryParse(json['qty']?.toString() ?? '0') ?? 0,
      initialPrice: (json['initial_price'] is num) ? (json['initial_price'] as num).toDouble() : 0.0,
      tax: (json['tax'] is num) ? (json['tax'] as num).toDouble() : 0.0,
      finalPrice: (json['final_price'] is num) ? (json['final_price'] as num).toDouble() : 0.0,
    );
  }
}

class FinanceOrderLog {
  final int id;
  final String status;
  final String? note;
  final String? createdAt;

  FinanceOrderLog({
    this.id = 0,
    this.status = '',
    this.note,
    this.createdAt,
  });

  factory FinanceOrderLog.fromJson(Map<String, dynamic> json) {
    return FinanceOrderLog(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      status: json['status']?.toString() ?? '',
      note: json['note']?.toString(),
      createdAt: json['created_at']?.toString(),
    );
  }
}

class FinancePaymentProof {
  final int id;
  final String title;
  final String? fileUrl;

  FinancePaymentProof({
    this.id = 0,
    this.title = '',
    this.fileUrl,
  });

  factory FinancePaymentProof.fromJson(Map<String, dynamic> json) {
    return FinancePaymentProof(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      title: json['title']?.toString() ?? '',
      fileUrl: json['file_url']?.toString(),
    );
  }
}

class FinanceOrderMeta {
  final int? currentPage;
  final int? lastPage;
  final int? perPage;
  final int? total;

  FinanceOrderMeta({
    this.currentPage,
    this.lastPage,
    this.perPage,
    this.total,
  });

  factory FinanceOrderMeta.fromJson(Map<String, dynamic> json) {
    return FinanceOrderMeta(
      currentPage: json['current_page'] is int ? json['current_page'] : null,
      lastPage: json['last_page'] is int ? json['last_page'] : null,
      perPage: json['per_page'] is int ? json['per_page'] : null,
      total: json['total'] is int ? json['total'] : null,
    );
  }
}

class FinanceOrderLinks {
  final String? first;
  final String? last;
  final String? prev;
  final String? next;

  FinanceOrderLinks({this.first, this.last, this.prev, this.next});

  factory FinanceOrderLinks.fromJson(Map<String, dynamic> json) {
    return FinanceOrderLinks(
      first: json['first']?.toString(),
      last: json['last']?.toString(),
      prev: json['prev']?.toString(),
      next: json['next']?.toString(),
    );
  }
}
