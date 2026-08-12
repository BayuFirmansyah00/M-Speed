class ProdukDetailSellerModelDataFotoProduk {
  int? id;
  String? caption;
  String? imgUrl;

  ProdukDetailSellerModelDataFotoProduk({
    this.id,
    this.caption,
    this.imgUrl,
  });

  ProdukDetailSellerModelDataFotoProduk.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    caption = json['caption']?.toString();
    imgUrl = json['img_url']?.toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['caption'] = caption;
    data['img_url'] = imgUrl;
    return data;
  }
}

class ProdukDetailSellerModelDataCategory {
  int? id;
  String? name;

  ProdukDetailSellerModelDataCategory({
    this.id,
    this.name,
  });

  ProdukDetailSellerModelDataCategory.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name']?.toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    return data;
  }
}

class ProdukDetailSellerModelData {
  int? id;
  String? name;
  String? productCode;
  int? qty;
  double? price;
  String? size;
  String? description;
  ProdukDetailSellerModelDataCategory? category;
  List<ProdukDetailSellerModelDataFotoProduk>? images;
  String? createdAt;
  String? updatedAt;

  ProdukDetailSellerModelData({
    this.id,
    this.name,
    this.productCode,
    this.qty,
    this.price,
    this.size,
    this.description,
    this.category,
    this.images,
    this.createdAt,
    this.updatedAt,
  });

  ProdukDetailSellerModelData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name']?.toString();
    productCode = json['product_code']?.toString();
    qty = json['qty'] != null ? int.tryParse(json['qty'].toString()) : null;
    price = json['price'] != null ? double.tryParse(json['price'].toString()) : null;
    size = json['size']?.toString();
    description = json['description']?.toString();
    category = json['category'] != null
        ? ProdukDetailSellerModelDataCategory.fromJson(json['category'])
        : null;
    
    if (json['images'] != null) {
      final v = json['images'] as List;
      images = v.map((e) => ProdukDetailSellerModelDataFotoProduk.fromJson(e)).toList();
    }
    createdAt = json['created_at']?.toString();
    updatedAt = json['updated_at']?.toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['product_code'] = productCode;
    data['qty'] = qty;
    data['price'] = price;
    data['size'] = size;
    data['description'] = description;
    if (category != null) {
      data['category'] = category!.toJson();
    }
    if (images != null) {
      data['images'] = images!.map((v) => v.toJson()).toList();
    }
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}

class ProdukDetailSellerModel {
  String? result;
  ProdukDetailSellerModelData? data;

  ProdukDetailSellerModel({
    this.result,
    this.data,
  });

  ProdukDetailSellerModel.fromJson(Map<String, dynamic> json) {
    result = json['result']?.toString() ?? 'success';
    data = (json['data'] != null)
        ? ProdukDetailSellerModelData.fromJson(json['data'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['result'] = result;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}
