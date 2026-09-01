class BuyerCheckoutResponse {
  final List<BuyerCheckoutData>? data;
  final BuyerCheckoutMeta? meta;

  BuyerCheckoutResponse({this.data, this.meta});

  factory BuyerCheckoutResponse.fromJson(Map<String, dynamic> json) {
    return BuyerCheckoutResponse(
      data: json['data'] != null
          ? (json['data'] as List).map((i) => BuyerCheckoutData.fromJson(i)).toList()
          : null,
      meta: json['meta'] != null ? BuyerCheckoutMeta.fromJson(json['meta']) : null,
    );
  }
}

class BuyerCheckoutMeta {
  final String? message;

  BuyerCheckoutMeta({this.message});

  factory BuyerCheckoutMeta.fromJson(Map<String, dynamic> json) {
    return BuyerCheckoutMeta(
      message: json['message'],
    );
  }
}

class BuyerCheckoutData {
  final int? id;
  final String? orderNum;
  final String? receiptNum;
  final String? paymentStatus;
  final BuyerCheckoutSeller? seller;
  final List<BuyerCheckoutItem>? items;

  BuyerCheckoutData({
    this.id,
    this.orderNum,
    this.receiptNum,
    this.paymentStatus,
    this.seller,
    this.items,
  });

  factory BuyerCheckoutData.fromJson(Map<String, dynamic> json) {
    return BuyerCheckoutData(
      id: json['id'],
      orderNum: json['order_num'],
      receiptNum: json['receipt_num'],
      paymentStatus: json['payment_status'],
      seller: json['seller'] != null ? BuyerCheckoutSeller.fromJson(json['seller']) : null,
      items: json['items'] != null
          ? (json['items'] as List).map((i) => BuyerCheckoutItem.fromJson(i)).toList()
          : null,
    );
  }
}

class BuyerCheckoutSeller {
  final int? id;
  final String? companyName;
  final String? phone;
  final String? email;
  final String? address;

  BuyerCheckoutSeller({
    this.id,
    this.companyName,
    this.phone,
    this.email,
    this.address,
  });

  factory BuyerCheckoutSeller.fromJson(Map<String, dynamic> json) {
    return BuyerCheckoutSeller(
      id: json['id'],
      companyName: json['company_name'],
      phone: json['phone'],
      email: json['email'],
      address: json['address'],
    );
  }
}

class BuyerCheckoutItem {
  final int? id;
  final String? productName;
  final int? qty;
  final dynamic initialPrice;
  final dynamic tax;
  final dynamic finalPrice;

  BuyerCheckoutItem({
    this.id,
    this.productName,
    this.qty,
    this.initialPrice,
    this.tax,
    this.finalPrice,
  });

  factory BuyerCheckoutItem.fromJson(Map<String, dynamic> json) {
    return BuyerCheckoutItem(
      id: json['id'],
      productName: json['product_name'],
      qty: json['qty'],
      initialPrice: json['initial_price'],
      tax: json['tax'],
      finalPrice: json['final_price'],
    );
  }
}
