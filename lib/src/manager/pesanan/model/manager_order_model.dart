/// Manager Order Model
/// Source of truth: ManagerOrderResource.php
/// Fields: id, order_num, payment_status, shipping_cost, seller, buyer,
///         prk_submission_id, latest_log, order_items, order_logs,
///         created_at, updated_at

class ManagerOrderModel {
  List<ManagerOrderData>? data;
  ManagerOrderMeta? meta;

  ManagerOrderModel({this.data, this.meta});

  factory ManagerOrderModel.fromJson(Map<String, dynamic> json) {
    return ManagerOrderModel(
      data: json['data'] != null
          ? (json['data'] as List).map((i) => ManagerOrderData.fromJson(i)).toList()
          : null,
      meta: json['meta'] != null ? ManagerOrderMeta.fromJson(json['meta']) : null,
    );
  }
}

class ManagerOrderMeta {
  int? currentPage;
  int? lastPage;
  int? total;
  int? perPage;

  ManagerOrderMeta({this.currentPage, this.lastPage, this.total, this.perPage});

  factory ManagerOrderMeta.fromJson(Map<String, dynamic> json) {
    return ManagerOrderMeta(
      currentPage: json['current_page'],
      lastPage: json['last_page'],
      total: json['total'],
      perPage: json['per_page'],
    );
  }
}

class ManagerOrderData {
  int? id;
  String? orderNum;
  String? paymentStatus;
  double? shippingCost;
  ManagerOrderSeller? seller;
  ManagerOrderBuyer? buyer;
  String? prkSubmissionId;
  ManagerOrderLog? latestLog;
  List<ManagerOrderItem>? orderItems;
  List<ManagerOrderLog>? orderLogs;
  String? createdAt;
  String? updatedAt;

  ManagerOrderData({
    this.id,
    this.orderNum,
    this.paymentStatus,
    this.shippingCost,
    this.seller,
    this.buyer,
    this.prkSubmissionId,
    this.latestLog,
    this.orderItems,
    this.orderLogs,
    this.createdAt,
    this.updatedAt,
  });

  factory ManagerOrderData.fromJson(Map<String, dynamic> json) {
    return ManagerOrderData(
      id: json['id'],
      orderNum: json['order_num']?.toString(),
      paymentStatus: json['payment_status']?.toString(),
      shippingCost: json['shipping_cost'] != null ? (json['shipping_cost'] as num).toDouble() : null,
      seller: json['seller'] != null ? ManagerOrderSeller.fromJson(json['seller']) : null,
      buyer: json['buyer'] != null ? ManagerOrderBuyer.fromJson(json['buyer']) : null,
      prkSubmissionId: json['prk_submission_id']?.toString(),
      latestLog: json['latest_log'] != null ? ManagerOrderLog.fromJson(json['latest_log']) : null,
      orderItems: json['order_items'] != null
          ? (json['order_items'] as List).map((i) => ManagerOrderItem.fromJson(i)).toList()
          : null,
      orderLogs: json['order_logs'] != null
          ? (json['order_logs'] as List).map((i) => ManagerOrderLog.fromJson(i)).toList()
          : null,
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  /// Returns the real latest status from order_logs by highest id
  ManagerOrderLog? get latestLogFromHistory {
    if (orderLogs != null && orderLogs!.isNotEmpty) {
      return orderLogs!.reduce((a, b) => (a.id ?? 0) > (b.id ?? 0) ? a : b);
    }
    return latestLog;
  }

  /// Calculates subtotal from order items
  double get subtotal {
    double total = 0;
    if (orderItems != null) {
      for (var item in orderItems!) {
        total += (item.finalPrice ?? 0) * (item.qty ?? 0);
      }
    }
    return total;
  }

  double get grandTotal => subtotal + (shippingCost ?? 0);

  /// Can manager approve this order? (status must be 'pesanan baru')
  bool get canApproveOrder {
    final status = latestLogFromHistory?.status ?? paymentStatus;
    return status == 'pesanan baru';
  }

  /// Can manager approve/reject invoice? (status must be 'tagihan')
  bool get canApproveInvoice {
    final status = latestLogFromHistory?.status ?? paymentStatus;
    return status == 'tagihan';
  }
}

class ManagerOrderSeller {
  int? id;
  String? companyName;
  String? phone;
  String? email;
  String? address;

  ManagerOrderSeller({this.id, this.companyName, this.phone, this.email, this.address});

  factory ManagerOrderSeller.fromJson(Map<String, dynamic> json) {
    return ManagerOrderSeller(
      id: json['id'],
      companyName: json['company_name']?.toString(),
      phone: json['phone']?.toString(),
      email: json['email']?.toString(),
      address: json['address']?.toString(),
    );
  }
}

class ManagerOrderBuyer {
  int? id;
  String? buyerName;
  String? recipientName;
  String? recipientPhone;
  String? recipientEmail;
  String? recipientAddress;

  ManagerOrderBuyer({
    this.id,
    this.buyerName,
    this.recipientName,
    this.recipientPhone,
    this.recipientEmail,
    this.recipientAddress,
  });

  factory ManagerOrderBuyer.fromJson(Map<String, dynamic> json) {
    return ManagerOrderBuyer(
      id: json['id'],
      buyerName: json['buyer_name']?.toString(),
      recipientName: json['recipient_name']?.toString(),
      recipientPhone: json['recipient_phone']?.toString(),
      recipientEmail: json['recipient_email']?.toString(),
      recipientAddress: json['recipient_address']?.toString(),
    );
  }
}

class ManagerOrderLog {
  int? id;
  String? title;
  String? status;
  String? note;
  String? createdAt;

  ManagerOrderLog({this.id, this.title, this.status, this.note, this.createdAt});

  factory ManagerOrderLog.fromJson(Map<String, dynamic> json) {
    return ManagerOrderLog(
      id: json['id'],
      title: json['title']?.toString(),
      status: json['status']?.toString(),
      note: json['note']?.toString(),
      createdAt: json['created_at']?.toString(),
    );
  }
}

class ManagerOrderItem {
  int? id;
  String? productName;
  int? qty;
  double? initialPrice;
  double? tax;
  double? finalPrice;

  ManagerOrderItem({this.id, this.productName, this.qty, this.initialPrice, this.tax, this.finalPrice});

  factory ManagerOrderItem.fromJson(Map<String, dynamic> json) {
    return ManagerOrderItem(
      id: json['id'],
      productName: json['product_name']?.toString(),
      qty: json['qty'],
      initialPrice: json['initial_price'] != null ? (json['initial_price'] as num).toDouble() : null,
      tax: json['tax'] != null ? (json['tax'] as num).toDouble() : null,
      finalPrice: json['final_price'] != null ? (json['final_price'] as num).toDouble() : null,
    );
  }
}
