/// Model Shopping Cart — disesuaikan dengan Laravel CartResource.
///
/// Laravel `GET /api/carts` response format:
/// ```json
/// {
///   "data": [
///     {
///       "id": 1,
///       "qty": 2,
///       "initial_price": 2650000,
///       "final_price": 2500000,
///       "nego_status": "PENDING",
///       "buyer_note": "catatan buyer",
///       "seller_note": "catatan seller",
///       "status": "ACTIVE",
///       "user_data": { "id": 3, "first_name": "Budi", "last_name": "S" },
///       "product": { "id": 5, "name": "BOR LISTRIK", "price": 2650000 },
///       "created_at": "...",
///       "updated_at": "..."
///     }
///   ],
///   "meta": { "current_page": 1, "last_page": 2 }
/// }
/// ```
///
/// Catatan: Response Laravel tidak mengelompokkan cart per seller.
/// Flutter perlu mengelompokkannya sendiri berdasarkan product.seller_id.

class ShoppingCartModelDataDetail {
  String? id;
  int? qty;
  double? initialPrice;
  double? finalPrice;
  String? negoStatus;
  String? buyerNote;
  String? sellerNote;
  String? status;

  // Relasi product (dari CartResource)
  String? productId;
  String? productName;
  double? productPrice;

  // Relasi user_data (buyer)
  String? userDataId;
  String? userDataFirstName;
  String? userDataLastName;

  // Field tambahan untuk UI (dihitung atau diambil dari product detail)
  String? photo;
  String? sellerName;
  String? sellerId;

  ShoppingCartModelDataDetail({
    this.id,
    this.qty,
    this.initialPrice,
    this.finalPrice,
    this.negoStatus,
    this.buyerNote,
    this.sellerNote,
    this.status,
    this.productId,
    this.productName,
    this.productPrice,
    this.userDataId,
    this.userDataFirstName,
    this.userDataLastName,
    this.photo,
    this.sellerName,
    this.sellerId,
  });

  ShoppingCartModelDataDetail.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toString() ?? json['ID']?.toString();
    qty = json['qty'] is int ? json['qty'] : int.tryParse(json['qty']?.toString() ?? '0');
    initialPrice = (json['initial_price'] ?? json['harga_awal'])?.toDouble();
    finalPrice = (json['final_price'] ?? json['harga_akhir'])?.toDouble();
    negoStatus = json['nego_status']?.toString() ?? json['status_nego']?.toString();
    buyerNote = json['buyer_note']?.toString() ?? json['catatan']?.toString();
    sellerNote = json['seller_note']?.toString();
    status = json['status']?.toString();

    final product = json['product'];
    if (product != null) {
      productId = product['id']?.toString();
      productName = product['name']?.toString();
      productPrice = product['price']?.toDouble();
    } else {
      // Fallback format lama
      productId = json['IDProduk']?.toString() ?? json['ProdukID']?.toString();
      productName = json['nama']?.toString();
      productPrice = double.tryParse(json['harga_awal']?.toString() ?? '0');
    }

    final userData = json['user_data'];
    if (userData != null) {
      userDataId = userData['id']?.toString();
      userDataFirstName = userData['first_name']?.toString();
      userDataLastName = userData['last_name']?.toString();
    }

    photo = json['photo']?.toString() ?? json['foto']?.toString();
    sellerName = json['seller']?['name']?.toString() ?? json['namaseller']?.toString();
    sellerId = json['seller']?['id']?.toString() ?? json['SellerID']?.toString();
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'qty': qty,
    'initial_price': initialPrice,
    'final_price': finalPrice,
    'nego_status': negoStatus,
    'buyer_note': buyerNote,
    'seller_note': sellerNote,
    'status': status,
    'product': {'id': productId, 'name': productName, 'price': productPrice},
    'user_data': {
      'id': userDataId,
      'first_name': userDataFirstName,
      'last_name': userDataLastName
    },
  };

  /// Helper: harga yang aktif (final jika ada nego disetujui, else initial)
  double get hargaAkhir => finalPrice ?? initialPrice ?? 0;

  // Backward compatibility getters for UI
  String? get ID => id;
  String? get ProdukID => productId;
  String? get IDProduk => productId;
  String? get hargaAwal => initialPrice?.toString();
  String? get hargaSebelumNego => initialPrice?.toString();
  String? get fixprice => finalPrice?.toString();
  String? get statusNego => negoStatus;
  String? get nego2 => null; // To avoid errors in condition
  String? get nego3 => null;
  String? get nego => finalPrice?.toString();
  String? get nama => productName;
  String? get foto => photo;
  String? get SellerID => sellerId;
  String? get namaseller => sellerName;
  String? get qtyString => qty?.toString();
}

/// Grup cart per seller — dibangun di Flutter setelah fetch dari API
class ShoppingCartModelData {
  String? sellerId;
  String? sellerName;
  List<ShoppingCartModelDataDetail?>? detail;
  double? total;

  ShoppingCartModelData({
    this.sellerId,
    this.sellerName,
    this.detail,
    this.total,
  });

  ShoppingCartModelData.fromJson(Map<String, dynamic> json) {
    sellerId = json['SellerID']?.toString();
    sellerName = json['namaseller']?.toString();
    if (json['detail'] != null) {
      final v = json['detail'];
      final arr0 = <ShoppingCartModelDataDetail>[];
      v.forEach((v) {
        arr0.add(ShoppingCartModelDataDetail.fromJson(v));
      });
      detail = arr0;
    }
    total = json['total']?.toDouble();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['SellerID'] = sellerId;
    data['namaseller'] = sellerName;
    if (detail != null) {
      data['detail'] = detail!.map((v) => v!.toJson()).toList();
    }
    data['total'] = total;
    return data;
  }

  // Backward compatibility getters
  String? get SellerID => sellerId;
  String? get namaseller => sellerName;
}

class ShoppingCartModel {
  List<ShoppingCartModelData?>? data;
  ShoppingCartModelMeta? meta;
  List<dynamic>? pajak;

  ShoppingCartModel({this.data, this.meta, this.pajak});

  ShoppingCartModel.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      final v = json['data'] as List;

      if (v.isNotEmpty) {
        final firstItem = v.first;
        final isLaravelResourceFormat = firstItem.containsKey('initial_price') ||
            firstItem.containsKey('nego_status') ||
            firstItem.containsKey('product');

        if (isLaravelResourceFormat) {
          // Format baru Laravel: flat list — kelompokkan per seller
          final Map<String, ShoppingCartModelData> grouped = {};
          for (var item in v) {
            final sId = item['seller']?['id']?.toString() ??
                item['product']?['seller_id']?.toString() ?? '0';
            final sName = item['seller']?['name']?.toString() ?? 'Penjual';

            if (!grouped.containsKey(sId)) {
              grouped[sId] = ShoppingCartModelData(
                sellerId: sId,
                sellerName: sName,
                detail: [],
                total: 0,
              );
            }

            final detail = ShoppingCartModelDataDetail.fromJson(item);
            grouped[sId]!.detail!.add(detail);
            grouped[sId]!.total =
                (grouped[sId]!.total ?? 0) + detail.hargaAkhir;
          }
          this.data = grouped.values.toList();
        } else {
          // Format lama: sudah dikelompokkan per seller
          this.data = v
              .map((v) => ShoppingCartModelData.fromJson(v))
              .toList();
        }
      }
    }

    meta = json['meta'] != null
        ? ShoppingCartModelMeta.fromJson(json['meta'])
        : null;
    pajak = json['pajak'] as List<dynamic>?;
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (data != null) {
      map['data'] = data!.map((v) => v!.toJson()).toList();
    }
    map['pajak'] = pajak;
    return map;
  }
}

class ShoppingCartModelMeta {
  int? currentPage;
  int? lastPage;
  int? total;

  ShoppingCartModelMeta({this.currentPage, this.lastPage, this.total});

  ShoppingCartModelMeta.fromJson(Map<String, dynamic> json) {
    currentPage = json['current_page'];
    lastPage = json['last_page'];
    total = json['total'];
  }

  Map<String, dynamic> toJson() => {
    'current_page': currentPage,
    'last_page': lastPage,
    'total': total,
  };
}
