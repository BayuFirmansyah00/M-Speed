class BuyerNegoModel {
  final int? id;
  final int? cartId;
  final String? value;
  final bool? isBuyerDeal;
  final bool? isSellerDeal;
  final String? createdAt;
  final String? updatedAt;

  BuyerNegoModel({
    this.id,
    this.cartId,
    this.value,
    this.isBuyerDeal,
    this.isSellerDeal,
    this.createdAt,
    this.updatedAt,
  });

  factory BuyerNegoModel.fromJson(Map<String, dynamic> json) {
    return BuyerNegoModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      cartId: json['cart_id'] is int ? json['cart_id'] : int.tryParse(json['cart_id']?.toString() ?? ''),
      value: json['value']?.toString(),
      isBuyerDeal: json['is_buyer_deal'] == true || json['is_buyer_deal'] == 1 || json['is_buyer_deal'] == '1',
      isSellerDeal: json['is_seller_deal'] == true || json['is_seller_deal'] == 1 || json['is_seller_deal'] == '1',
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cart_id': cartId,
      'value': value,
      'is_buyer_deal': isBuyerDeal,
      'is_seller_deal': isSellerDeal,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  double get parsedValue => double.tryParse(value ?? '0') ?? 0;
  int get intValue => parsedValue.toInt();
}
