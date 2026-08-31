class BuyerProductFilterModel {
  String? status;
  String? message;
  BuyerProductFilterData? data;

  BuyerProductFilterModel({this.status, this.message, this.data});

  BuyerProductFilterModel.fromJson(Map<String, dynamic> json) {
    status = json['status']?.toString();
    message = json['message']?.toString();
    if (json['data'] != null) {
      data = BuyerProductFilterData.fromJson(json['data']);
    }
  }
}

class BuyerProductFilterData {
  List<BuyerProductData>? products;
  BuyerProductPagination? pagination;
  List<BuyerProductCategory>? categories;
  List<String>? cities;
  List<int>? wishlistProductIds;

  BuyerProductFilterData({
    this.products,
    this.pagination,
    this.categories,
    this.cities,
    this.wishlistProductIds,
  });

  BuyerProductFilterData.fromJson(Map<String, dynamic> json) {
    if (json['products'] != null) {
      products = [];
      json['products'].forEach((v) {
        products!.add(BuyerProductData.fromJson(v));
      });
    }
    if (json['pagination'] != null) {
      pagination = BuyerProductPagination.fromJson(json['pagination']);
    }
    if (json['categories'] != null) {
      categories = [];
      json['categories'].forEach((v) {
        categories!.add(BuyerProductCategory.fromJson(v));
      });
    }
    if (json['cities'] != null) {
      cities = List<String>.from(json['cities'].map((x) => x.toString()));
    }
    if (json['wishlist_product_ids'] != null) {
      wishlistProductIds = List<int>.from(json['wishlist_product_ids'].map((x) => int.tryParse(x.toString()) ?? 0));
    }
  }
}

class BuyerProductPagination {
  int? currentPage;
  int? lastPage;
  int? perPage;
  int? total;

  BuyerProductPagination({this.currentPage, this.lastPage, this.perPage, this.total});

  BuyerProductPagination.fromJson(Map<String, dynamic> json) {
    currentPage = int.tryParse(json['current_page']?.toString() ?? '1');
    lastPage = int.tryParse(json['last_page']?.toString() ?? '1');
    perPage = int.tryParse(json['per_page']?.toString() ?? '15');
    total = int.tryParse(json['total']?.toString() ?? '0');
  }
}

class BuyerProductData {
  int? id;
  String? name;
  String? productCode;
  int? qty;
  double? price;
  String? size;
  String? description;
  BuyerProductCategory? category;
  BuyerProductSeller? seller;
  String? photo; 

  BuyerProductData({
    this.id,
    this.name,
    this.productCode,
    this.qty,
    this.price,
    this.size,
    this.description,
    this.category,
    this.seller,
    this.photo,
  });

  BuyerProductData.fromJson(Map<String, dynamic> json) {
    id = int.tryParse(json['id']?.toString() ?? '');
    name = json['name']?.toString();
    productCode = json['product_code']?.toString();
    qty = int.tryParse(json['qty']?.toString() ?? '0');
    price = double.tryParse(json['price']?.toString() ?? '0');
    size = json['size']?.toString();
    description = json['description']?.toString();
    
    if (json['category'] != null) {
      category = BuyerProductCategory.fromJson(json['category']);
    }
    if (json['seller_data'] != null) {
      seller = BuyerProductSeller.fromJson(json['seller_data']);
    }
    
    if (json['product_images'] != null && json['product_images'] is List && (json['product_images'] as List).isNotEmpty) {
      final imgPath = json['product_images'][0]['img_path']?.toString();
      photo = imgPath;
    }
  }
}

class BuyerProductCategory {
  int? id;
  String? name;

  BuyerProductCategory({this.id, this.name});

  BuyerProductCategory.fromJson(Map<String, dynamic> json) {
    id = int.tryParse(json['id']?.toString() ?? '');
    name = json['name']?.toString();
  }
}

class BuyerProductSeller {
  int? id;
  String? companyName;

  BuyerProductSeller({this.id, this.companyName});

  BuyerProductSeller.fromJson(Map<String, dynamic> json) {
    id = int.tryParse(json['id']?.toString() ?? '');
    companyName = json['company_name']?.toString();
  }
}
