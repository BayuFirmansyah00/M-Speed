import 'package:flutter/material.dart';

// ── Root Response Model for Receiver Order List ────────────────────────────
class ReceiverOrderListResponse {
  final List<ReceiverOrderData> data;
  final ReceiverOrderMeta? meta;

  ReceiverOrderListResponse({
    required this.data,
    this.meta,
  });

  factory ReceiverOrderListResponse.fromJson(Map<String, dynamic> json) {
    var rawList = json['data'];
    List<ReceiverOrderData> list = [];
    if (rawList is List) {
      list = rawList.map((e) => ReceiverOrderData.fromJson(e as Map<String, dynamic>)).toList();
    }

    ReceiverOrderMeta? meta;
    if (json['meta'] != null && json['meta'] is Map<String, dynamic>) {
      meta = ReceiverOrderMeta.fromJson(json['meta']);
    }

    return ReceiverOrderListResponse(
      data: list,
      meta: meta,
    );
  }
}

// ── Root Response Model for Single Receiver Order Detail ───────────────────
class ReceiverOrderDetailResponse {
  final ReceiverOrderData? data;

  ReceiverOrderDetailResponse({this.data});

  factory ReceiverOrderDetailResponse.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null && json['data'] is Map<String, dynamic>) {
      return ReceiverOrderDetailResponse(
        data: ReceiverOrderData.fromJson(json['data']),
      );
    }
    return ReceiverOrderDetailResponse(data: null);
  }
}

// ── Receiver Order Main Data ───────────────────────────────────────────────
class ReceiverOrderData {
  final int id;
  final String orderNum;
  final String paymentStatus;
  final double shippingCost;
  final ReceiverSeller? seller;
  final ReceiverBuyer? buyer;
  final ReceiverRecipient? recipient;
  final ReceiverOrderLog? latestLog;
  final List<ReceiverOrderItem> orderItems;
  final List<ReceiverOrderLog> orderLogs;
  final String? createdAt;
  final String? updatedAt;

  ReceiverOrderData({
    required this.id,
    required this.orderNum,
    required this.paymentStatus,
    required this.shippingCost,
    this.seller,
    this.buyer,
    this.recipient,
    this.latestLog,
    required this.orderItems,
    required this.orderLogs,
    this.createdAt,
    this.updatedAt,
  });

  factory ReceiverOrderData.fromJson(Map<String, dynamic> json) {
    return ReceiverOrderData(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      orderNum: json['order_num']?.toString() ?? '',
      paymentStatus: json['payment_status']?.toString() ?? '',
      shippingCost: json['shipping_cost'] != null
          ? (double.tryParse(json['shipping_cost'].toString()) ?? 0.0)
          : 0.0,
      seller: json['seller'] != null && json['seller'] is Map<String, dynamic>
          ? ReceiverSeller.fromJson(json['seller'])
          : null,
      buyer: json['buyer'] != null && json['buyer'] is Map<String, dynamic>
          ? ReceiverBuyer.fromJson(json['buyer'])
          : null,
      recipient: json['recipient'] != null && json['recipient'] is Map<String, dynamic>
          ? ReceiverRecipient.fromJson(json['recipient'])
          : null,
      latestLog: json['latest_log'] != null && json['latest_log'] is Map<String, dynamic>
          ? ReceiverOrderLog.fromJson(json['latest_log'])
          : null,
      orderItems: (json['order_items'] is List)
          ? (json['order_items'] as List).map((i) => ReceiverOrderItem.fromJson(i)).toList()
          : [],
      orderLogs: (json['order_logs'] is List)
          ? (json['order_logs'] as List).map((l) => ReceiverOrderLog.fromJson(l)).toList()
          : [],
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  // ── Computed Business Logic Getters ──────────────────────────────────────

  /// Calculates total price of all order items combined
  double get subtotalItems {
    return orderItems.fold<double>(0.0, (sum, item) => sum + item.finalPrice);
  }

  /// Calculates Grand Total including shipping costs
  double get grandTotal {
    return subtotalItems + shippingCost;
  }

  /// Total units / quantity of items in the order
  int get totalQty {
    return orderItems.fold<int>(0, (sum, item) => sum + item.qty);
  }

  /// Latest status log from order history
  String get effectiveStatus {
    if (latestLog != null && latestLog!.status.isNotEmpty) {
      return latestLog!.status.toLowerCase().trim();
    }
    return paymentStatus.toLowerCase().trim();
  }

  /// Can Receiver verify/confirm receipt of order?
  /// Backend rule: `latestLog->status == 'pesanan dikirim'`
  bool get canVerifyReception {
    final s = effectiveStatus;
    return s == 'pesanan dikirim' || s == 'barang dikirim';
  }

  /// Has the order been received and verified by Receiver?
  bool get isReceived {
    final s = effectiveStatus;
    return s == 'pesanan diterima penerima' ||
        s == 'penerimaan & verifikasi' ||
        s == 'pesanan dibayar' ||
        s == 'pesanan selesai';
  }

  /// Human-friendly display label for status badge
  String get statusDisplayLabel {
    final s = effectiveStatus;
    switch (s) {
      case 'pesanan dikirim':
      case 'barang dikirim':
        return 'Sedang Dikirim (Siap Diterima)';
      case 'pesanan diterima penerima':
        return 'Telah Diterima';
      case 'penerimaan & verifikasi':
        return 'Penerimaan & Verifikasi';
      case 'pesanan dibayar':
        return 'Telah Dibayar';
      case 'siap tagih by manager':
        return 'Siap Ditagihkan';
      case 'menunggu persetujuan manager':
        return 'Menunggu Manager';
      case 'pesanan disetujui manager':
        return 'Disetujui Manager';
      case 'pesanan diproses seller':
        return 'Diproses Seller';
      case 'pesanan selesai':
        return 'Selesai';
      case 'dibatalkan':
        return 'Dibatalkan';
      default:
        return s.toUpperCase();
    }
  }

  /// Badge theme color corresponding to status
  Color get statusBadgeColor {
    final s = effectiveStatus;
    switch (s) {
      case 'pesanan dikirim':
      case 'barang dikirim':
        return const Color(0xFFF59E0B); // Amber / Warning (Action required)
      case 'pesanan diterima penerima':
      case 'pesanan dibayar':
      case 'pesanan selesai':
        return const Color(0xFF10B981); // Emerald Green
      case 'dibatalkan':
      case 'pembayaran ditolak finance':
        return const Color(0xFFEF4444); // Red / Danger
      default:
        return const Color(0xFF3B82F6); // Blue / Info
    }
  }
}

// ── Seller Information ─────────────────────────────────────────────────────
class ReceiverSeller {
  final int id;
  final String companyName;
  final String phone;
  final String email;
  final String address;

  ReceiverSeller({
    required this.id,
    required this.companyName,
    required this.phone,
    required this.email,
    required this.address,
  });

  factory ReceiverSeller.fromJson(Map<String, dynamic> json) {
    return ReceiverSeller(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      companyName: json['company_name']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
    );
  }
}

// ── Buyer Information ──────────────────────────────────────────────────────
class ReceiverBuyer {
  final int id;
  final String buyerName;

  ReceiverBuyer({
    required this.id,
    required this.buyerName,
  });

  factory ReceiverBuyer.fromJson(Map<String, dynamic> json) {
    return ReceiverBuyer(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      buyerName: json['buyer_name']?.toString() ?? '',
    );
  }
}

// ── Recipient Information ──────────────────────────────────────────────────
class ReceiverRecipient {
  final int? recipientId;
  final String recipientName;
  final String recipientPhone;
  final String recipientEmail;
  final String recipientAddress;

  ReceiverRecipient({
    this.recipientId,
    required this.recipientName,
    required this.recipientPhone,
    required this.recipientEmail,
    required this.recipientAddress,
  });

  factory ReceiverRecipient.fromJson(Map<String, dynamic> json) {
    return ReceiverRecipient(
      recipientId: json['recipient_id'] is int
          ? json['recipient_id']
          : int.tryParse(json['recipient_id']?.toString() ?? ''),
      recipientName: json['recipient_name']?.toString() ?? '',
      recipientPhone: json['recipient_phone']?.toString() ?? '',
      recipientEmail: json['recipient_email']?.toString() ?? '',
      recipientAddress: json['recipient_address']?.toString() ?? '',
    );
  }
}

// ── Order Item ─────────────────────────────────────────────────────────────
class ReceiverOrderItem {
  final int id;
  final String productName;
  final int qty;
  final double initialPrice;
  final double tax;
  final double finalPrice;

  ReceiverOrderItem({
    required this.id,
    required this.productName,
    required this.qty,
    required this.initialPrice,
    required this.tax,
    required this.finalPrice,
  });

  factory ReceiverOrderItem.fromJson(Map<String, dynamic> json) {
    return ReceiverOrderItem(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      productName: json['product_name']?.toString() ?? '',
      qty: json['qty'] is int ? json['qty'] : int.tryParse(json['qty']?.toString() ?? '0') ?? 0,
      initialPrice: json['initial_price'] != null
          ? (double.tryParse(json['initial_price'].toString()) ?? 0.0)
          : 0.0,
      tax: json['tax'] != null ? (double.tryParse(json['tax'].toString()) ?? 0.0) : 0.0,
      finalPrice: json['final_price'] != null
          ? (double.tryParse(json['final_price'].toString()) ?? 0.0)
          : 0.0,
    );
  }
}

// ── Order Log Tracking ─────────────────────────────────────────────────────
class ReceiverOrderLog {
  final int id;
  final String title;
  final String status;
  final String? note;
  final String? createdAt;

  ReceiverOrderLog({
    required this.id,
    required this.title,
    required this.status,
    this.note,
    this.createdAt,
  });

  factory ReceiverOrderLog.fromJson(Map<String, dynamic> json) {
    return ReceiverOrderLog(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      title: json['title']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      note: json['note']?.toString(),
      createdAt: json['created_at']?.toString(),
    );
  }
}

// ── Pagination Meta ────────────────────────────────────────────────────────
class ReceiverOrderMeta {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;

  ReceiverOrderMeta({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
  });

  factory ReceiverOrderMeta.fromJson(Map<String, dynamic> json) {
    return ReceiverOrderMeta(
      currentPage: json['current_page'] is int
          ? json['current_page']
          : int.tryParse(json['current_page']?.toString() ?? '1') ?? 1,
      lastPage: json['last_page'] is int
          ? json['last_page']
          : int.tryParse(json['last_page']?.toString() ?? '1') ?? 1,
      perPage: json['per_page'] is int
          ? json['per_page']
          : int.tryParse(json['per_page']?.toString() ?? '15') ?? 15,
      total: json['total'] is int
          ? json['total']
          : int.tryParse(json['total']?.toString() ?? '0') ?? 0,
    );
  }
}
