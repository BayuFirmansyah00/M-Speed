class BuyerCartResponse {
  final BuyerCartData? data;

  BuyerCartResponse({this.data});

  factory BuyerCartResponse.fromJson(Map<String, dynamic> json) {
    return BuyerCartResponse(
      data: json['data'] != null ? BuyerCartData.fromJson(json['data']) : null,
    );
  }
}

class BuyerCartData {
  final List<BuyerTempOrder> tempOrders;

  BuyerCartData({required this.tempOrders});

  factory BuyerCartData.fromJson(Map<String, dynamic> json) {
    return BuyerCartData(
      tempOrders: json['temp_orders'] != null
          ? (json['temp_orders'] as List).map((i) => BuyerTempOrder.fromJson(i)).toList()
          : [],
    );
  }
}

class BuyerTempOrder {
  final int? id;
  final int? sellerId;
  final BuyerCartSeller? seller;
  final List<BuyerCartItem> carts;

  BuyerTempOrder({
    this.id,
    this.sellerId,
    this.seller,
    required this.carts,
  });

  factory BuyerTempOrder.fromJson(Map<String, dynamic> json) {
    return BuyerTempOrder(
      id: json['id'],
      sellerId: json['seller_id'],
      seller: json['seller'] != null ? BuyerCartSeller.fromJson(json['seller']) : null,
      carts: json['carts'] != null
          ? (json['carts'] as List).map((i) => BuyerCartItem.fromJson(i)).toList()
          : [],
    );
  }
}

class BuyerCartSeller {
  final int? id;
  final String? companyName;
  final String? photo;

  BuyerCartSeller({
    this.id,
    this.companyName,
    this.photo,
  });

  factory BuyerCartSeller.fromJson(Map<String, dynamic> json) {
    return BuyerCartSeller(
      id: json['id'],
      companyName: json['company_name'],
      photo: json['photo'],
    );
  }
}

class BuyerCartItem {
  final int? id;
  final int? qty;
  final String? initialPrice;
  final String? finalPrice;
  final String? buyerNote;
  final String? negoStatus;
  final BuyerCartProduct? product;

  BuyerCartItem({
    this.id,
    this.qty,
    this.initialPrice,
    this.finalPrice,
    this.buyerNote,
    this.negoStatus,
    this.product,
  });

  factory BuyerCartItem.fromJson(Map<String, dynamic> json) {
    return BuyerCartItem(
      id: json['id'],
      qty: json['qty'],
      initialPrice: json['initial_price']?.toString(),
      finalPrice: json['final_price']?.toString(),
      buyerNote: json['buyer_note'],
      negoStatus: json['nego_status'],
      product: json['product'] != null ? BuyerCartProduct.fromJson(json['product']) : null,
    );
  }
}

class BuyerCartProduct {
  final int? id;
  final String? name;
  final dynamic price;
  final int? qty; // stok
  final String? weight;
  final List<BuyerCartProductImage> productImages;

  BuyerCartProduct({
    this.id,
    this.name,
    this.price,
    this.qty,
    this.weight,
    required this.productImages,
  });

  factory BuyerCartProduct.fromJson(Map<String, dynamic> json) {
    return BuyerCartProduct(
      id: json['id'],
      name: json['name'],
      price: json['price'],
      qty: json['qty'],
      weight: json['weight']?.toString(),
      productImages: json['product_images'] != null
          ? (json['product_images'] as List).map((i) => BuyerCartProductImage.fromJson(i)).toList()
          : [],
    );
  }
  
  String? get firstImage {
    if (productImages.isNotEmpty) {
      return productImages.first.imgPath;
    }
    return null;
  }
}

class BuyerCartProductImage {
  final int? id;
  final String? imgPath;

  BuyerCartProductImage({
    this.id,
    this.imgPath,
  });

  factory BuyerCartProductImage.fromJson(Map<String, dynamic> json) {
    return BuyerCartProductImage(
      id: json['id'],
      imgPath: json['img_path'],
    );
  }
}
