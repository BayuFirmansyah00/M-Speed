import 'package:mspeed/common/model/pagination_meta_model.dart';

class NegoSellerModelData {
  String? id;
  double? negoValue;
  bool? isBuyerDeal;
  bool? isSellerDeal;
  
  NegoCart? cart;
  NegoProduct? product;
  NegoBuyer? buyer;
  
  String? createdAt;
  String? updatedAt;

  NegoSellerModelData({
    this.id,
    this.negoValue,
    this.isBuyerDeal,
    this.isSellerDeal,
    this.cart,
    this.product,
    this.buyer,
    this.createdAt,
    this.updatedAt,
  });

  NegoSellerModelData.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toString();
    
    // Parse numeric fields safely
    if (json['nego_value'] != null) {
      negoValue = double.tryParse(json['nego_value'].toString());
    }
    
    // Parse booleans safely
    isBuyerDeal = json['is_buyer_deal'] == true || json['is_buyer_deal'] == 'true' || json['is_buyer_deal'] == 1;
    isSellerDeal = json['is_seller_deal'] == true || json['is_seller_deal'] == 'true' || json['is_seller_deal'] == 1;

    cart = json['cart'] != null ? NegoCart.fromJson(json['cart']) : null;
    product = json['product'] != null ? NegoProduct.fromJson(json['product']) : null;
    buyer = json['buyer'] != null ? NegoBuyer.fromJson(json['buyer']) : null;
    
    createdAt = json['created_at']?.toString();
    updatedAt = json['updated_at']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['nego_value'] = negoValue;
    data['is_buyer_deal'] = isBuyerDeal;
    data['is_seller_deal'] = isSellerDeal;
    if (cart != null) data['cart'] = cart!.toJson();
    if (product != null) data['product'] = product!.toJson();
    if (buyer != null) data['buyer'] = buyer!.toJson();
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}

class NegoCart {
  String? id;
  int? qty;
  double? initialPrice;
  double? finalPrice;
  String? negoStatus;
  String? buyerNote;
  String? sellerNote;

  NegoCart({
    this.id,
    this.qty,
    this.initialPrice,
    this.finalPrice,
    this.negoStatus,
    this.buyerNote,
    this.sellerNote,
  });

  NegoCart.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toString();
    qty = json['qty'] != null ? int.tryParse(json['qty'].toString()) : null;
    initialPrice = json['initial_price'] != null ? double.tryParse(json['initial_price'].toString()) : null;
    finalPrice = json['final_price'] != null ? double.tryParse(json['final_price'].toString()) : null;
    negoStatus = json['nego_status']?.toString();
    buyerNote = json['buyer_note']?.toString();
    sellerNote = json['seller_note']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['qty'] = qty;
    data['initial_price'] = initialPrice;
    data['final_price'] = finalPrice;
    data['nego_status'] = negoStatus;
    data['buyer_note'] = buyerNote;
    data['seller_note'] = sellerNote;
    return data;
  }
}

class NegoProduct {
  String? id;
  String? name;
  String? productCode;
  double? price;
  String? imageUrl;

  NegoProduct({this.id, this.name, this.productCode, this.price, this.imageUrl});

  NegoProduct.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toString();
    name = json['name']?.toString();
    productCode = json['product_code']?.toString();
    price = json['price'] != null ? double.tryParse(json['price'].toString()) : null;
    imageUrl = json['image_url']?.toString() ??
               json['photo']?.toString() ??
               (json['product_images'] != null && json['product_images'] is List && (json['product_images'] as List).isNotEmpty
                   ? json['product_images'][0]['img_url']?.toString()
                   : null);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['product_code'] = productCode;
    data['price'] = price;
    if (imageUrl != null) data['image_url'] = imageUrl;
    return data;
  }
}

class NegoBuyer {
  String? id;
  String? name;
  String? phone;

  NegoBuyer({this.id, this.name, this.phone});

  NegoBuyer.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toString();
    name = json['name']?.toString();
    phone = json['phone']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['phone'] = phone;
    return data;
  }
}

class NegoSellerModel {
  List<NegoSellerModelData>? data;
  PaginationMetaModel? meta;

  NegoSellerModel({this.data, this.meta});

  NegoSellerModel.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <NegoSellerModelData>[];
      json['data'].forEach((v) {
        data!.add(NegoSellerModelData.fromJson(v));
      });
    }
    if (json['meta'] != null) {
      meta = PaginationMetaModel.fromJson(json['meta']);
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    if (meta != null) {
      data['meta'] = meta!.toJson();
    }
    return data;
  }
}
