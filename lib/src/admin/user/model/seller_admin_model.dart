class SellerAdminCategory {
  int? id;
  String? name;

  SellerAdminCategory({this.id, this.name});

  SellerAdminCategory.fromJson(Map<String, dynamic> json) {
    id = json['id'] != null ? int.tryParse(json['id'].toString()) : null;
    name = json['name']?.toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    return data;
  }
}

class SellerAdminData {
  int? id;
  String? name;
  String? companyName;
  String? ownerName;
  String? phone;
  String? photoUrl;
  String? cpName;
  String? cpPhone;
  String? kbli;
  int? completeness;
  int? active;
  SellerAdminCategory? category;

  SellerAdminData({
    this.id,
    this.name,
    this.companyName,
    this.ownerName,
    this.phone,
    this.photoUrl,
    this.cpName,
    this.cpPhone,
    this.kbli,
    this.completeness,
    this.active,
    this.category,
  });

  SellerAdminData.fromJson(Map<String, dynamic> json) {
    id = json['id'] != null ? int.tryParse(json['id'].toString()) : null;
    name = json['name']?.toString();
    companyName = json['company_name']?.toString();
    ownerName = json['owner_name']?.toString();
    phone = json['phone']?.toString();
    photoUrl = json['photo_url']?.toString();
    cpName = json['cp_name']?.toString();
    cpPhone = json['cp_phone']?.toString();
    kbli = json['kbli']?.toString();
    completeness = json['completeness'] != null ? int.tryParse(json['completeness'].toString()) : null;
    active = json['active'] != null ? int.tryParse(json['active'].toString()) : null;
    category = json['category'] != null ? SellerAdminCategory.fromJson(json['category']) : null;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['company_name'] = companyName;
    data['owner_name'] = ownerName;
    data['phone'] = phone;
    data['photo_url'] = photoUrl;
    data['cp_name'] = cpName;
    data['cp_phone'] = cpPhone;
    data['kbli'] = kbli;
    data['completeness'] = completeness;
    if (category != null) {
      data['category'] = category!.toJson();
    }
    return data;
  }
}

class SellerAdminAddress {
  int? id;
  String? detail;
  int? cityId;
  String? cityName;
  String? provinceName;
  String? fullAddress;
  String? latitude;
  String? longitude;

  SellerAdminAddress({
    this.id,
    this.detail,
    this.cityId,
    this.cityName,
    this.provinceName,
    this.fullAddress,
    this.latitude,
    this.longitude,
  });

  SellerAdminAddress.fromJson(Map<String, dynamic> json) {
    id = json['id'] != null ? int.tryParse(json['id'].toString()) : null;
    detail = json['detail']?.toString();
    cityId = json['city_id'] != null ? int.tryParse(json['city_id'].toString()) : null;
    cityName = json['city_name']?.toString();
    provinceName = json['province_name']?.toString();
    fullAddress = json['full_address']?.toString();
    latitude = json['latitude']?.toString();
    longitude = json['longitude']?.toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['detail'] = detail;
    data['city_id'] = cityId;
    data['city_name'] = cityName;
    data['province_name'] = provinceName;
    data['full_address'] = fullAddress;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    return data;
  }
}

class SellerAdminModelData {
  int? id;
  String? email;
  String? role;
  String? status;
  SellerAdminData? sellerData;
  SellerAdminAddress? sellerAddress;
  String? createdAt;
  String? updatedAt;

  SellerAdminModelData({
    this.id,
    this.email,
    this.role,
    this.status,
    this.sellerData,
    this.sellerAddress,
    this.createdAt,
    this.updatedAt,
  });

  SellerAdminModelData.fromJson(Map<String, dynamic> json) {
    id = json['id'] != null ? int.tryParse(json['id'].toString()) : null;
    email = json['email']?.toString();
    role = json['role']?.toString();
    status = json['status']?.toString();
    sellerData = json['seller_data'] != null ? SellerAdminData.fromJson(json['seller_data']) : null;
    sellerAddress = json['seller_address'] != null ? SellerAdminAddress.fromJson(json['seller_address']) : null;
    createdAt = json['created_at']?.toString();
    updatedAt = json['updated_at']?.toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['email'] = email;
    data['role'] = role;
    if (sellerData != null) {
      data['seller_data'] = sellerData!.toJson();
    }
    if (sellerAddress != null) {
      data['seller_address'] = sellerAddress!.toJson();
    }
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}

class SellerAdminModel {
  List<SellerAdminModelData>? data;
  Map<String, dynamic>? meta;

  SellerAdminModel({
    this.data,
    this.meta,
  });

  SellerAdminModel.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      final v = json['data'];
      final arr0 = <SellerAdminModelData>[];
      v.forEach((v) {
        arr0.add(SellerAdminModelData.fromJson(v));
      });
      this.data = arr0;
    }
    meta = json['meta'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (this.data != null) {
      final v = this.data;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v.toJson());
      });
      data['data'] = arr0;
    }
    data['meta'] = meta;
    return data;
  }
}
