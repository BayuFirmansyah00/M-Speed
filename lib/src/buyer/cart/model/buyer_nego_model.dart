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
      id: json['id'],
      cartId: json['cart_id'],
      value: json['value']?.toString(),
      isBuyerDeal: json['is_buyer_deal'],
      isSellerDeal: json['is_seller_deal'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}
