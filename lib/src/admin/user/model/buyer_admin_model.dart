class BuyerAdminDepartment {
  int? id;
  String? name;

  BuyerAdminDepartment({this.id, this.name});

  BuyerAdminDepartment.fromJson(Map<String, dynamic> json) {
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

class BuyerAdminUserData {
  int? id;
  String? firstName;
  String? lastName;
  String? fullName;
  String? phone;
  int? completeness;
  String? access;
  BuyerAdminDepartment? department;

  BuyerAdminUserData({
    this.id,
    this.firstName,
    this.lastName,
    this.fullName,
    this.phone,
    this.completeness,
    this.access,
    this.department,
  });

  BuyerAdminUserData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    firstName = json['first_name']?.toString();
    lastName = json['last_name']?.toString();
    fullName = json['full_name']?.toString();
    phone = json['phone']?.toString();
    completeness = json['completeness'];
    access = json['access']?.toString();
    if (json['department'] != null) {
      department = BuyerAdminDepartment.fromJson(json['department']);
    }
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['first_name'] = firstName;
    data['last_name'] = lastName;
    data['full_name'] = fullName;
    data['phone'] = phone;
    data['completeness'] = completeness;
    data['access'] = access;
    if (department != null) {
      data['department'] = department!.toJson();
    }
    return data;
  }
}

class BuyerAdminAddress {
  int? id;
  String? name;
  String? phone;
  String? detail;
  String? province;
  String? city;
  int? cityId;

  BuyerAdminAddress({
    this.id,
    this.name,
    this.phone,
    this.detail,
    this.province,
    this.city,
    this.cityId,
  });

  BuyerAdminAddress.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name']?.toString();
    phone = json['phone']?.toString();
    detail = json['detail']?.toString();
    province = json['province']?.toString();
    city = json['city']?.toString();
    cityId = json['city_id'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['phone'] = phone;
    data['detail'] = detail;
    data['province'] = province;
    data['city'] = city;
    data['city_id'] = cityId;
    return data;
  }
}

class BuyerAdminModelData {
  int? id;
  String? email;
  String? role;
  String? status;
  BuyerAdminUserData? userData;
  String? fullAddress;
  List<BuyerAdminAddress>? addresses;
  String? createdAt;
  String? updatedAt;

  // Polyfills for old code that is tightly coupled to previous model structure.
  String? get firstname => userData?.firstName;
  String? get lastname => userData?.lastName;
  String? get subditId => userData?.department?.id?.toString(); // fallback mapping for old provider
  String? get telp => userData?.phone;
  String? get alamat => fullAddress;
  String? get kabkota => addresses?.isNotEmpty == true ? addresses!.first.cityId?.toString() : null;
  String? get departmentId => userData?.department?.id?.toString();

  BuyerAdminModelData({
    this.id,
    this.email,
    this.role,
    this.status,
    this.userData,
    this.fullAddress,
    this.addresses,
    this.createdAt,
    this.updatedAt,
  });

  BuyerAdminModelData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    email = json['email']?.toString();
    role = json['role']?.toString();
    status = json['status']?.toString();
    if (json['user_data'] != null) {
      userData = BuyerAdminUserData.fromJson(json['user_data']);
    }
    fullAddress = json['full_address']?.toString();
    if (json['addresses'] != null) {
      final v = json['addresses'];
      final arr0 = <BuyerAdminAddress>[];
      v.forEach((v) {
        arr0.add(BuyerAdminAddress.fromJson(v));
      });
      addresses = arr0;
    }
    createdAt = json['created_at']?.toString();
    updatedAt = json['updated_at']?.toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['email'] = email;
    data['role'] = role;
    data['status'] = status;
    if (userData != null) {
      data['user_data'] = userData!.toJson();
    }
    data['full_address'] = fullAddress;
    if (addresses != null) {
      final arr0 = [];
      addresses!.forEach((v) {
        arr0.add(v.toJson());
      });
      data['addresses'] = arr0;
    }
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}

class BuyerAdminModel {
  List<BuyerAdminModelData>? data;
  dynamic meta;
  dynamic links;

  BuyerAdminModel({
    this.data,
    this.meta,
    this.links,
  });

  BuyerAdminModel.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      final v = json['data'];
      final arr0 = <BuyerAdminModelData>[];
      v.forEach((v) {
        arr0.add(BuyerAdminModelData.fromJson(v));
      });
      data = arr0;
    }
    meta = json['meta'];
    links = json['links'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (this.data != null) {
      final arr0 = [];
      this.data!.forEach((v) {
        arr0.add(v.toJson());
      });
      data['data'] = arr0;
    }
    data['meta'] = meta;
    data['links'] = links;
    return data;
  }
}
