class BuyerDashboardModel {
  List<DashboardBannerModel>? banners;
  List<DashboardCategoryModel>? categories;
  List<DashboardProductModel>? products;
  List<OrderLogModel>? latestOrderLogs;

  BuyerDashboardModel({
    this.banners,
    this.categories,
    this.products,
    this.latestOrderLogs,
  });

  BuyerDashboardModel.fromJson(Map<String, dynamic> json) {
    if (json['banners'] != null) {
      banners = <DashboardBannerModel>[];
      json['banners'].forEach((v) {
        banners!.add(DashboardBannerModel.fromJson(v));
      });
    }
    if (json['categories'] != null) {
      categories = <DashboardCategoryModel>[];
      json['categories'].forEach((v) {
        categories!.add(DashboardCategoryModel.fromJson(v));
      });
    }
    if (json['products'] != null) {
      products = <DashboardProductModel>[];
      json['products'].forEach((v) {
        products!.add(DashboardProductModel.fromJson(v));
      });
    }
    if (json['latest_order_logs'] != null) {
      latestOrderLogs = <OrderLogModel>[];
      json['latest_order_logs'].forEach((v) {
        latestOrderLogs!.add(OrderLogModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (this.banners != null) {
      data['banners'] = this.banners!.map((v) => v.toJson()).toList();
    }
    if (this.categories != null) {
      data['categories'] = this.categories!.map((v) => v.toJson()).toList();
    }
    if (this.products != null) {
      data['products'] = this.products!.map((v) => v.toJson()).toList();
    }
    if (this.latestOrderLogs != null) {
      data['latest_order_logs'] =
          this.latestOrderLogs!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class DashboardBannerModel {
  int? id;
  String? caption;
  String? imgUrl;

  DashboardBannerModel({this.id, this.caption, this.imgUrl});

  DashboardBannerModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    caption = json['caption']?.toString();
    imgUrl = json['img_url']?.toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = this.id;
    data['caption'] = this.caption;
    data['img_url'] = this.imgUrl;
    return data;
  }
}

class DashboardCategoryModel {
  int? id;
  String? name;
  String? status;

  DashboardCategoryModel({this.id, this.name, this.status});

  DashboardCategoryModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name']?.toString();
    status = json['status']?.toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = this.id;
    data['name'] = this.name;
    data['status'] = this.status;
    return data;
  }
}

class DashboardProductModel {
  int? id;
  String? name;
  String? productCode;
  int? qty;
  int? soldQty;
  double? price;
  String? size;
  String? description;
  bool? isInWishlist;
  ProductCategoryModel? category;
  ProductSellerModel? seller;
  List<ProductImageModel>? images;

  DashboardProductModel({
    this.id,
    this.name,
    this.productCode,
    this.qty,
    this.soldQty,
    this.price,
    this.size,
    this.description,
    this.isInWishlist,
    this.category,
    this.seller,
    this.images,
  });

  DashboardProductModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name']?.toString();
    productCode = json['product_code']?.toString();
    qty = json['qty'] is int ? json['qty'] : int.tryParse(json['qty']?.toString() ?? '0');
    soldQty = json['sold_qty'] is int ? json['sold_qty'] : int.tryParse(json['sold_qty']?.toString() ?? '0') ?? 0;
    price = json['price'] != null ? double.tryParse(json['price'].toString()) : null;
    size = json['size']?.toString();
    description = json['description']?.toString();
    isInWishlist = json['is_in_wishlist'];
    category = json['category'] != null
        ? ProductCategoryModel.fromJson(json['category'])
        : null;
    seller = json['seller'] != null
        ? ProductSellerModel.fromJson(json['seller'])
        : null;
    if (json['images'] != null) {
      images = <ProductImageModel>[];
      json['images'].forEach((v) {
        images!.add(ProductImageModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = this.id;
    data['name'] = this.name;
    data['product_code'] = this.productCode;
    data['qty'] = this.qty;
    data['sold_qty'] = this.soldQty;
    data['price'] = this.price;
    data['size'] = this.size;
    data['description'] = this.description;
    data['is_in_wishlist'] = this.isInWishlist;
    if (this.category != null) {
      data['category'] = this.category!.toJson();
    }
    if (this.seller != null) {
      data['seller'] = this.seller!.toJson();
    }
    if (this.images != null) {
      data['images'] = this.images!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ProductCategoryModel {
  int? id;
  String? name;

  ProductCategoryModel({this.id, this.name});

  ProductCategoryModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name']?.toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = this.id;
    data['name'] = this.name;
    return data;
  }
}

class ProductSellerModel {
  int? id;
  String? name;
  String? companyName;

  ProductSellerModel({this.id, this.name, this.companyName});

  ProductSellerModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name']?.toString();
    companyName = json['company_name']?.toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = this.id;
    data['name'] = this.name;
    data['company_name'] = this.companyName;
    return data;
  }
}

class ProductImageModel {
  int? id;
  String? caption;
  String? imgUrl;

  ProductImageModel({this.id, this.caption, this.imgUrl});

  ProductImageModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    caption = json['caption']?.toString();
    imgUrl = json['img_url']?.toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = this.id;
    data['caption'] = this.caption;
    data['img_url'] = this.imgUrl;
    return data;
  }
}

class OrderLogModel {
  int? id;
  String? status;
  String? note;
  String? orderNum;
  String? createdAt;

  OrderLogModel({
    this.id,
    this.status,
    this.note,
    this.orderNum,
    this.createdAt,
  });

  OrderLogModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    status = json['status']?.toString();
    note = json['note']?.toString();
    orderNum = json['order_num']?.toString();
    createdAt = json['created_at']?.toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = this.id;
    data['status'] = this.status;
    data['note'] = this.note;
    data['order_num'] = this.orderNum;
    data['created_at'] = this.createdAt;
    return data;
  }
}
