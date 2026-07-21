/// Model Nego — disesuaikan dengan Laravel NegoResource.
///
/// Laravel `GET /api/negos` response format:
/// ```json
/// {
///   "data": [
///     {
///       "id": 1,
///       "value": 450000,
///       "cart": {
///         "id": 10,
///         "qty": 2,
///         "initial_price": 500000,
///         "final_price": 450000,
///         "product": { "id": 5, "name": "BOR LISTRIK" },
///         "buyer": { "id": 3, "name": "Budi Santoso" }
///       },
///       "created_at": "...",
///       "updated_at": "..."
///     }
///   ]
/// }
/// ```
class RiwayatNegoModelData {
  String? id;
  String? value;

  // Relasi Cart
  String? cartId;
  String? cartQty;
  String? initialPrice;
  String? finalPrice;

  // Relasi Produk (nested di dalam cart)
  String? productId;
  String? productName;

  // Relasi Buyer (nested di dalam cart)
  String? buyerId;
  String? buyerName;

  // Status nego untuk UI
  String? negoStatus;

  RiwayatNegoModelData({
    this.id,
    this.value,
    this.cartId,
    this.cartQty,
    this.initialPrice,
    this.finalPrice,
    this.productId,
    this.productName,
    this.buyerId,
    this.buyerName,
    this.negoStatus,
  });

  RiwayatNegoModelData.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toString() ?? json['ID']?.toString();
    value = json['value']?.toString() ?? json['nego']?.toString();

    final cart = json['cart'];
    if (cart != null) {
      cartId = cart['id']?.toString();
      cartQty = cart['qty']?.toString();
      initialPrice = cart['initial_price']?.toString() ?? json['harga_awal']?.toString();
      finalPrice = cart['final_price']?.toString() ?? json['harga_akhir']?.toString();

      final product = cart['product'];
      if (product != null) {
        productId = product['id']?.toString();
        productName = product['name']?.toString();
      }

      final buyer = cart['buyer'];
      if (buyer != null) {
        buyerId = buyer['id']?.toString();
        buyerName = buyer['name']?.toString();
      }
    } else {
      // Fallback format lama
      productId = json['ProdukID']?.toString();
      productName = json['nama']?.toString();
      buyerId = json['BuyerID']?.toString();
      initialPrice = json['harga_awal']?.toString();
      finalPrice = json['harga_akhir']?.toString();
      cartQty = json['qty']?.toString();
    }

    negoStatus = json['nego_status']?.toString() ?? json['status_nego']?.toString();
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'value': value,
    'cart': {
      'id': cartId,
      'qty': cartQty,
      'initial_price': initialPrice,
      'final_price': finalPrice,
      'product': {'id': productId, 'name': productName},
      'buyer': {'id': buyerId, 'name': buyerName},
    },
    'nego_status': negoStatus,
  };

  // Backward compatibility getters
  String? get nego => value;
  String? get fixstatus => negoStatus;
  String? get nama => productName;
  String? get foto => "";
}

class RiwayatNegoModel {
  List<RiwayatNegoModelData?>? data;
  RiwayatNegoModelMeta? meta;

  RiwayatNegoModel({this.data, this.meta});

  RiwayatNegoModel.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      final v = json['data'];
      final arr0 = <RiwayatNegoModelData>[];
      v.forEach((v) {
        arr0.add(RiwayatNegoModelData.fromJson(v));
      });
      this.data = arr0;
    }
    meta = json['meta'] != null ? RiwayatNegoModelMeta.fromJson(json['meta']) : null;
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (data != null) {
      map['data'] = data!.map((v) => v!.toJson()).toList();
    }
    return map;
  }
}

class RiwayatNegoModelMeta {
  int? currentPage;
  int? lastPage;

  RiwayatNegoModelMeta({this.currentPage, this.lastPage});
  RiwayatNegoModelMeta.fromJson(Map<String, dynamic> json) {
    currentPage = json['current_page'];
    lastPage = json['last_page'];
  }
  Map<String, dynamic> toJson() => {'current_page': currentPage, 'last_page': lastPage};
}
