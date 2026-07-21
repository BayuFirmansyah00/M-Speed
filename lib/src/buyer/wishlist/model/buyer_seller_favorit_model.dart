class BuyerSellerFavoritModelData {
  String? ID;
  String? SellerID;
  String? BuyerID;
  String? SellerName;
  String? alamat;
  String? foto;
  String? BuyerName;

  BuyerSellerFavoritModelData({
    this.ID,
    this.SellerID,
    this.BuyerID,
    this.SellerName,
    this.alamat,
    this.foto,
    this.BuyerName,
  });
  
  BuyerSellerFavoritModelData.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('seller_data')) {
      // Format Baru (Laravel REST API - FollowResource)
      ID = json['id']?.toString();
      SellerID = json['seller_data']?['id']?.toString();
      SellerName = json['seller_data']?['name']?.toString();
      BuyerID = json['user_data']?['id']?.toString();
      BuyerName = json['user_data']?['first_name']?.toString();
      foto = json['seller_data']?['photo']?.toString();
      alamat = json['seller_data']?['address']?.toString();
    } else {
      // Format Lama
      ID = json['ID']?.toString();
      SellerID = json['SellerID']?.toString();
      BuyerID = json['BuyerID']?.toString();
      SellerName = json['SellerName']?.toString();
      alamat = json['alamat']?.toString();
      foto = json['foto']?.toString();
      BuyerName = json['BuyerName']?.toString();
    }
  }
  
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['ID'] = ID;
    data['SellerID'] = SellerID;
    data['BuyerID'] = BuyerID;
    data['SellerName'] = SellerName;
    data['alamat'] = alamat;
    data['foto'] = foto;
    data['BuyerName'] = BuyerName;
    return data;
  }
}

class BuyerSellerFavoritModel {
  String? result;
  List<BuyerSellerFavoritModelData?>? data;

  BuyerSellerFavoritModel({
    this.result,
    this.data,
  });
  
  BuyerSellerFavoritModel.fromJson(Map<String, dynamic> json) {
    result = json['result']?.toString() ?? 'success';
    if (json['data'] != null) {
      final v = json['data'];
      final arr0 = <BuyerSellerFavoritModelData>[];
      v.forEach((v) {
        arr0.add(BuyerSellerFavoritModelData.fromJson(v));
      });
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
