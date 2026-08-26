class BasicUserAdminDepartment {
  int? id;
  String? name;

  BasicUserAdminDepartment({this.id, this.name});

  BasicUserAdminDepartment.fromJson(Map<String, dynamic> json) {
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

class BasicUserAdminManagerRef {
  int? id;
  String? name;

  BasicUserAdminManagerRef({this.id, this.name});

  BasicUserAdminManagerRef.fromJson(Map<String, dynamic> json) {
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

class BasicUserAdminUserData {
  int? id;
  String? firstName;
  String? lastName;
  String? fullName;
  String? phone;
  int? completeness;
  String? access;
  BasicUserAdminDepartment? department;
  BasicUserAdminManagerRef? manager;

  BasicUserAdminUserData({
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

  BasicUserAdminUserData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    firstName = json['first_name']?.toString();
    lastName = json['last_name']?.toString();
    fullName = json['full_name']?.toString();
    phone = json['phone']?.toString();
    completeness = json['completeness'];
    access = json['access']?.toString();
    if (json['department'] != null) {
      department = BasicUserAdminDepartment.fromJson(json['department']);
    }
    if (json['manager'] != null) {
      manager = BasicUserAdminManagerRef.fromJson(json['manager']);
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

class BasicUserAdminModelData {
  int? id;
  String? email;
  String? role;
  String? status;
  BasicUserAdminUserData? userData;
  String? createdAt;
  String? updatedAt;
  int? totalMembers;

  // Polyfills for old code that is tightly coupled to previous model structure.
  // Polyfills for old code that is tightly coupled to previous model structure.
  String? get ID => id?.toString();

  BasicUserAdminModelData({
    this.id,
    this.email,
    this.role,
    this.status,
    this.userData,
    this.createdAt,
    this.updatedAt,
    this.totalMembers,
  });

  BasicUserAdminModelData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    email = json['email']?.toString();
    role = json['role']?.toString();
    status = json['status']?.toString();
    
    // Support both `user_data` (Finance, Direksi, Audit) and `profile` (Manager)
    if (json['user_data'] != null) {
      userData = BasicUserAdminUserData.fromJson(json['user_data']);
    } else if (json['profile'] != null) {
      userData = BasicUserAdminUserData.fromJson(json['profile']);
    }

    totalMembers = json['total_members'];
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
    data['total_members'] = totalMembers;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}

class BasicUserAdminModel {
  List<BasicUserAdminModelData>? data;
  dynamic meta;
  dynamic links;

  BasicUserAdminModel({
    this.data,
    this.meta,
    this.links,
  });

  BasicUserAdminModel.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      final v = json['data'];
      final arr0 = <BasicUserAdminModelData>[];
      v.forEach((v) {
        arr0.add(BasicUserAdminModelData.fromJson(v));
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
