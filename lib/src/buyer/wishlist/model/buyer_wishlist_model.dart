class BuyerWishlistModelDataDetail {
  String? ID;
  String? IDWishlist;
  String? foto;
  String? SellerID;
  String? nama;
  String? harga;
  String? qty;
  String? IDKategori;

  BuyerWishlistModelDataDetail({
    this.ID,
    this.IDWishlist,
    this.foto,
    this.SellerID,
    this.nama,
    this.harga,
    this.qty,
    this.IDKategori,
  });
  
  BuyerWishlistModelDataDetail.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('product')) {
      // Format Baru (Laravel REST API)
      ID = json['product']?['id']?.toString();
      IDWishlist = json['id']?.toString();
      foto = json['product']?['photo']?.toString() ?? json['product']?['image']?.toString();
      SellerID = json['product']?['seller_id']?.toString() ?? '-';
      nama = json['product']?['name']?.toString();
      harga = json['product']?['price']?.toString();
      qty = json['product']?['qty']?.toString();
      IDKategori = json['product']?['category_id']?.toString();
    } else {
      // Format Lama
      ID = json['ID']?.toString();
      IDWishlist = json['IDWishlist']?.toString();
      foto = json['foto']?.toString();
      SellerID = json['SellerID']?.toString();
      nama = json['nama']?.toString();
      harga = json['harga']?.toString();
      qty = json['qty']?.toString();
      IDKategori = json['IDKategori']?.toString();
    }
  }
  
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['ID'] = ID;
    data['IDWishlist'] = IDWishlist;
    data['foto'] = foto;
    data['SellerID'] = SellerID;
    data['nama'] = nama;
    data['harga'] = harga;
    data['qty'] = qty;
    data['IDKategori'] = IDKategori;
    return data;
  }
}

class BuyerWishlistModelData {
  String? SellerID;
  String? namaseller;
  List<BuyerWishlistModelDataDetail?>? detail;

  BuyerWishlistModelData({
    this.SellerID,
    this.namaseller,
    this.detail,
  });
  
  BuyerWishlistModelData.fromJson(Map<String, dynamic> json) {
    SellerID = json['SellerID']?.toString();
    namaseller = json['namaseller']?.toString();
    if (json['detail'] != null) {
      final v = json['detail'];
      final arr0 = <BuyerWishlistModelDataDetail>[];
      v.forEach((v) {
        arr0.add(BuyerWishlistModelDataDetail.fromJson(v));
      });
      detail = arr0;
    }
  }
  
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['SellerID'] = SellerID;
    data['namaseller'] = namaseller;
    if (detail != null) {
      final v = detail;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['detail'] = arr0;
    }
    return data;
  }
}

class BuyerWishlistModel {
  String? result;
  List<BuyerWishlistModelData?>? data;

  BuyerWishlistModel({
    this.result,
    this.data,
  });
  
  BuyerWishlistModel.fromJson(Map<String, dynamic> json) {
    result = json['result']?.toString() ?? 'success';
    if (json['data'] != null) {
      final v = json['data'] as List;
      final arr0 = <BuyerWishlistModelData>[];
      
      if (v.isNotEmpty && v.first is Map && (v.first as Map).containsKey('namaseller')) {
        // Format Lama
        v.forEach((item) {
          arr0.add(BuyerWishlistModelData.fromJson(item));
        });
      } else {
        // Format Baru (Laravel REST API - Flat List)
        // Kita grup semua jadi 1 seller untuk memenuhi UI sementara
        final detailList = <BuyerWishlistModelDataDetail>[];
        v.forEach((item) {
           detailList.add(BuyerWishlistModelDataDetail.fromJson(item));
        });
        
        if (detailList.isNotEmpty) {
           arr0.add(BuyerWishlistModelData(
             SellerID: "0",
             namaseller: "Wishlist Produk",
             detail: detailList,
           ));
        }
      }
      this.data = arr0;
    }
  }
  
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['result'] = result;
    if (this.data != null) {
      final v = this.data;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['data'] = arr0;
    }
    return data;
  }
}
