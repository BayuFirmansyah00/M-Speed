class PenerimaAdminManager {
  int? id;
  String? name;

  PenerimaAdminManager({this.id, this.name});

  PenerimaAdminManager.fromJson(Map<String, dynamic> json) {
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

class PenerimaAdminDepartment {
  int? id;
  String? name;

  PenerimaAdminDepartment({this.id, this.name});

  PenerimaAdminDepartment.fromJson(Map<String, dynamic> json) {
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

class PenerimaAdminUserData {
  int? id;
  String? firstName;
  String? lastName;
  String? fullName;
  String? phone;
  int? completeness;
  String? access;
  PenerimaAdminDepartment? department;
  PenerimaAdminManager? manager;

  PenerimaAdminUserData({
    this.id,
    this.firstName,
    this.lastName,
    this.fullName,
    this.phone,
    this.completeness,
    this.access,
    this.department,
    this.manager,
  });

  PenerimaAdminUserData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    firstName = json['first_name']?.toString();
    lastName = json['last_name']?.toString();
    fullName = json['full_name']?.toString();
    phone = json['phone']?.toString();
    completeness = json['completeness'];
    access = json['access']?.toString();
    if (json['department'] != null) {
      department = PenerimaAdminDepartment.fromJson(json['department']);
    }
    if (json['manager'] != null) {
      manager = PenerimaAdminManager.fromJson(json['manager']);
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
    if (manager != null) {
      data['manager'] = manager!.toJson();
    }
    return data;
  }
}

class PenerimaAdminAddress {
  int? id;
  String? name;
  String? phone;
  String? detail;
  String? province;
  String? city;
  int? status;

  PenerimaAdminAddress({
    this.id,
    this.name,
    this.phone,
    this.detail,
    this.province,
    this.city,
    this.status,
  });

  PenerimaAdminAddress.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name']?.toString();
    phone = json['phone']?.toString();
    detail = json['detail']?.toString();
    province = json['province']?.toString();
    city = json['city']?.toString();
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['phone'] = phone;
    data['detail'] = detail;
    data['province'] = province;
    data['city'] = city;
    data['status'] = status;
    return data;
  }
}

class PenerimaAdminModelData {
  int? id;
  String? email;
  String? role;
  String? status;
  PenerimaAdminUserData? userData;
  String? fullAddress;
  List<PenerimaAdminAddress>? addresses;
  String? createdAt;
  String? updatedAt;

  // Polyfills for old code that is tightly coupled to previous model structure.
  String? get ID => id?.toString();
  String? get subditId => userData?.department?.id?.toString();

  PenerimaAdminModelData({
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

  PenerimaAdminModelData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    email = json['email']?.toString();
    role = json['role']?.toString();
    status = json['status']?.toString();
    if (json['user_data'] != null) {
      userData = PenerimaAdminUserData.fromJson(json['user_data']);
    }
    fullAddress = json['full_address']?.toString();
    if (json['addresses'] != null) {
      final v = json['addresses'];
      final arr0 = <PenerimaAdminAddress>[];
      v.forEach((v) {
        arr0.add(PenerimaAdminAddress.fromJson(v));
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

class PenerimaAdminModel {
  List<PenerimaAdminModelData>? data;
  dynamic meta;
  dynamic links;

  PenerimaAdminModel({
    this.data,
    this.meta,
    this.links,
  });

  PenerimaAdminModel.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      final v = json['data'];
      final arr0 = <PenerimaAdminModelData>[];
      v.forEach((v) {
        arr0.add(PenerimaAdminModelData.fromJson(v));
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
