/// Model Produk — disesuaikan dengan Laravel ProductResource.
///
/// Laravel `GET /api/products` response format:
/// ```json
/// {
///   "data": [
///     {
///       "id": 1,
///       "name": "BOR LISTRIK THERMAL",
///       "product_code": "002",
///       "qty": 19,
///       "price": 2650000,
///       "size": "",
///       "description": "Deskripsi produk",
///       "seller": { "id": 1, "name": "Atria Seller" },
///       "category": { "id": 1, "name": "Consumable" },
///       "created_at": "...",
///       "updated_at": "..."
///     }
///   ],
///   "links": {...},
///   "meta": { "current_page": 1, "last_page": 5 }
/// }
/// ```
class ProductModelData {
  String? id;
  String? name;
  String? productCode;
  String? size;
  String? qty;
  String? price;
  String? description;

  // Relasi Seller (dari Laravel ProductResource)
  String? sellerId;
  String? sellerName;

  // Relasi Category (dari Laravel ProductResource)
  String? categoryId;
  String? categoryName;

  // Field tambahan yang mungkin ada di response extended
  String? photo;

  ProductModelData({
    this.id,
    this.name,
    this.productCode,
    this.size,
    this.qty,
    this.price,
    this.description,
    this.sellerId,
    this.sellerName,
    this.categoryId,
    this.categoryName,
    this.photo,
  });

  ProductModelData.fromJson(Map<String, dynamic> json) {
    // Format baru Laravel: { id, name, product_code, price, ... }
    id = json['id']?.toString() ?? json['ID']?.toString();
    name = json['name']?.toString() ?? json['nama']?.toString();
    productCode = json['product_code']?.toString() ?? json['kode_produk']?.toString();
    size = json['size']?.toString();
    qty = json['qty']?.toString();
    price = json['price']?.toString() ?? json['harga']?.toString();
    description = json['description']?.toString() ?? json['deskripsi']?.toString();

    // Seller dari relasi nested
    if (json['seller'] != null) {
      sellerId = json['seller']['id']?.toString();
      sellerName = json['seller']['name']?.toString();
    } else {
      // Fallback format lama
      sellerId = json['SellerID']?.toString();
      sellerName = json['SellerNama']?.toString();
    }

    // Category dari relasi nested
    if (json['category'] != null) {
      categoryId = json['category']['id']?.toString();
      categoryName = json['category']['name']?.toString();
    } else {
      // Fallback format lama
      categoryId = json['IDKategori']?.toString();
      categoryName = json['NamaKategori']?.toString();
    }

    photo = json['photo']?.toString() ?? json['foto']?.toString();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'product_code': productCode,
      'size': size,
      'qty': qty,
      'price': price,
      'description': description,
      'seller': {'id': sellerId, 'name': sellerName},
      'category': {'id': categoryId, 'name': categoryName},
      'photo': photo,
    };
  }

  // Backward compatibility getters
  String? get ID => id;
  String? get nama => name;
  String? get kodeProduk => productCode;
  String? get harga => price;
  String? get deskripsi => description;
  String? get IDKategori => categoryId;
  String? get NamaKategori => categoryName;
  String? get foto => photo ?? "assets/images/placeholder.png";
  String? get SellerID => sellerId;
  String? get SellerNama => sellerName;
  String? get terjual => "0";
  String? get kota => "";
}

class ProductModel {
  List<ProductModelData?>? data;
  ProductModelMeta? meta;

  ProductModel({this.data, this.meta});

  ProductModel.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      final v = json['data'];
      final arr0 = <ProductModelData>[];
      v.forEach((v) {
        arr0.add(ProductModelData.fromJson(v));
      });
      this.data = arr0;
    }
    meta = json['meta'] != null ? ProductModelMeta.fromJson(json['meta']) : null;
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (data != null) {
      map['data'] = data!.map((v) => v!.toJson()).toList();
    }
    if (meta != null) map['meta'] = meta!.toJson();
    return map;
  }
}

class ProductModelMeta {
  int? currentPage;
  int? lastPage;
  int? total;
  int? perPage;

  ProductModelMeta({this.currentPage, this.lastPage, this.total, this.perPage});

  ProductModelMeta.fromJson(Map<String, dynamic> json) {
    currentPage = json['current_page'];
    lastPage = json['last_page'];
    total = json['total'];
    perPage = json['per_page'];
  }

  Map<String, dynamic> toJson() => {
    'current_page': currentPage,
    'last_page': lastPage,
    'total': total,
    'per_page': perPage,
  };
}
