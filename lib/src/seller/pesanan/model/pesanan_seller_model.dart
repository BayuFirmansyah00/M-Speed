import 'package:mspeed/common/model/pagination_meta_model.dart';
import 'seller_order_status.dart';

class SellerOrderModel {
  List<SellerOrderData>? data;
  PaginationMetaModel? meta;

  SellerOrderModel({this.data, this.meta});

  factory SellerOrderModel.fromJson(Map<String, dynamic> json) {
    return SellerOrderModel(
      data: json['data'] != null
          ? (json['data'] as List).map((i) => SellerOrderData.fromJson(i)).toList()
          : null,
      meta: json['meta'] != null ? PaginationMetaModel.fromJson(json['meta']) : null,
    );
  }
}

class SellerOrderData {
  int? id;
  String? orderNum;
  String? receiptNum;
  String? paymentStatus;
  SellerOrderBuyer? buyer;
  SellerOrderShipping? shipping;
  SellerOrderLatestStatus? latestStatus;
  List<SellerOrderItem>? items;
  List<SellerOrderLog>? logsHistory;
  String? createdAt;
  String? updatedAt;

  SellerOrderData({
    this.id,
    this.orderNum,
    this.receiptNum,
    this.paymentStatus,
    this.buyer,
    this.shipping,
    this.latestStatus,
    this.items,
    this.logsHistory,
    this.createdAt,
    this.updatedAt,
  });

  /// Custom getter to return the enum logic for UI based on `logsHistory` to ensure true latest status
  SellerOrderStatus get statusEnum {
    if (logsHistory != null && logsHistory!.isNotEmpty) {
      // Find the log with the highest ID to ensure we get the actual latest status, bypassing the Laravel timestamp ordering bug
      var latestLog = logsHistory!.reduce((a, b) => (a.id ?? 0) > (b.id ?? 0) ? a : b);
      return SellerOrderStatus.fromString(latestLog.status);
    }
    return SellerOrderStatus.fromString(latestStatus?.status);
  }

  /// Calculate subtotal based on items
  double get totalProductPrice {
    double total = 0;
    if (items != null) {
      for (var item in items!) {
        total += (item.finalPrice ?? 0) * (item.qty ?? 0);
      }
    }
    return total;
  }
  
  double get totalOrderPrice {
    return totalProductPrice + (shipping?.cost ?? 0);
  }

  factory SellerOrderData.fromJson(Map<String, dynamic> json) {
    return SellerOrderData(
      id: json['id'],
      orderNum: json['order_num']?.toString(),
      receiptNum: json['receipt_num']?.toString(),
      paymentStatus: json['payment_status']?.toString(),
      buyer: json['buyer'] != null ? SellerOrderBuyer.fromJson(json['buyer']) : null,
      shipping: json['shipping'] != null ? SellerOrderShipping.fromJson(json['shipping']) : null,
      latestStatus: json['latest_status'] != null ? SellerOrderLatestStatus.fromJson(json['latest_status']) : null,
      items: json['items'] != null
          ? (json['items'] as List).map((i) => SellerOrderItem.fromJson(i)).toList()
          : null,
      logsHistory: json['logs_history'] != null
          ? (json['logs_history'] as List).map((i) => SellerOrderLog.fromJson(i)).toList()
          : null,
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }
}

class SellerOrderBuyer {
  String? name;
  String? recipientName;
  String? phone;
  String? email;
  String? address;

  SellerOrderBuyer({this.name, this.recipientName, this.phone, this.email, this.address});

  factory SellerOrderBuyer.fromJson(Map<String, dynamic> json) {
    return SellerOrderBuyer(
      name: json['name']?.toString(),
      recipientName: json['recipient_name']?.toString(),
      phone: json['phone']?.toString(),
      email: json['email']?.toString(),
      address: json['address']?.toString(),
    );
  }
}

class SellerOrderShipping {
  double? cost;
  String? estStart;
  String? estEnd;

  SellerOrderShipping({this.cost, this.estStart, this.estEnd});

  factory SellerOrderShipping.fromJson(Map<String, dynamic> json) {
    return SellerOrderShipping(
      cost: json['cost'] != null ? double.tryParse(json['cost'].toString()) : null,
      estStart: json['est_start']?.toString(),
      estEnd: json['est_end']?.toString(),
    );
  }
}

class SellerOrderLatestStatus {
  String? status;
  String? note;
  String? createdAt;

  SellerOrderLatestStatus({this.status, this.note, this.createdAt});

  factory SellerOrderLatestStatus.fromJson(Map<String, dynamic> json) {
    return SellerOrderLatestStatus(
      status: json['status']?.toString(),
      note: json['note']?.toString(),
      createdAt: json['created_at']?.toString(),
    );
  }
}

class SellerOrderItem {
  int? id;
  String? productName;
  int? qty;
  double? initialPrice;
  double? tax;
  double? finalPrice;

  SellerOrderItem({this.id, this.productName, this.qty, this.initialPrice, this.tax, this.finalPrice});

  factory SellerOrderItem.fromJson(Map<String, dynamic> json) {
    return SellerOrderItem(
      id: json['id'],
      productName: json['product_name']?.toString(),
      qty: json['qty'] != null ? int.tryParse(json['qty'].toString()) : null,
      initialPrice: json['initial_price'] != null ? double.tryParse(json['initial_price'].toString()) : null,
      tax: json['tax'] != null ? double.tryParse(json['tax'].toString()) : null,
      finalPrice: json['final_price'] != null ? double.tryParse(json['final_price'].toString()) : null,
    );
  }
}

class SellerOrderLog {
  int? id;
  String? status;
  String? note;
  String? createdAt;

  SellerOrderLog({this.id, this.status, this.note, this.createdAt});

  factory SellerOrderLog.fromJson(Map<String, dynamic> json) {
    return SellerOrderLog(
      id: json['id'],
      status: json['status']?.toString(),
      note: json['note']?.toString(),
      createdAt: json['created_at']?.toString(),
    );
  }
  
  SellerOrderStatus get statusEnum => SellerOrderStatus.fromString(status);
}
