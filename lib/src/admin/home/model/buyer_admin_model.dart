class DepartmentData {
  int? id;
  String? name;
  int? subDirektorateId;

  DepartmentData({this.id, this.name, this.subDirektorateId});

  factory DepartmentData.fromJson(Map<String, dynamic> json) {
    return DepartmentData(
      id: json['id'] != null ? int.tryParse(json['id'].toString()) : null,
      name: json['name']?.toString(),
      subDirektorateId: json['sub_direktorate_id'] != null
          ? int.tryParse(json['sub_direktorate_id'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'sub_direktorate_id': subDirektorateId,
    };
  }
}

class UserDataModel {
  int? id;
  String? firstName;
  String? lastName;
  String? fullName;
  String? phone;
  int? completeness;
  int? access;
  DepartmentData? department;

  UserDataModel({
    this.id,
    this.firstName,
    this.lastName,
    this.fullName,
    this.phone,
    this.completeness,
    this.access,
    this.department,
  });

  factory UserDataModel.fromJson(Map<String, dynamic> json) {
    return UserDataModel(
      id: json['id'] != null ? int.tryParse(json['id'].toString()) : null,
      firstName: json['first_name']?.toString(),
      lastName: json['last_name']?.toString(),
      fullName: json['full_name']?.toString(),
      phone: json['phone']?.toString(),
      completeness: json['completeness'] != null ? int.tryParse(json['completeness'].toString()) : null,
      access: json['access'] != null ? int.tryParse(json['access'].toString()) : null,
      department: json['department'] != null ? DepartmentData.fromJson(json['department']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'full_name': fullName,
      'phone': phone,
      'completeness': completeness,
      'access': access,
      'department': department?.toJson(),
    };
  }
}

class AddressData {
  int? id;
  String? name;
  String? phone;
  String? detail;
  String? city;
  String? province;
  int? status;

  AddressData({
    this.id,
    this.name,
    this.phone,
    this.detail,
    this.city,
    this.province,
    this.status,
  });

  factory AddressData.fromJson(Map<String, dynamic> json) {
    return AddressData(
      id: json['id'] != null ? int.tryParse(json['id'].toString()) : null,
      name: json['name']?.toString(),
      phone: json['phone']?.toString(),
      detail: json['detail']?.toString(),
      city: json['city']?.toString(),
      province: json['province']?.toString(),
      status: json['status'] != null ? int.tryParse(json['status'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'detail': detail,
      'city': city,
      'province': province,
      'status': status,
    };
  }
}

class BuyerAdminModelData {
  String? ID; // mapped from id for backward compatibility in some places, or keep as int
  String? email;
  String? role;
  String? status;
  String? fullAddress;
  String? createdAt;
  String? updatedAt;
  UserDataModel? userData;
  List<AddressData>? addresses;

  // Compatibility fields for existing views that might still refer to them
  String? get firstname => userData?.firstName;
  String? get lastname => userData?.lastName;
  String? get telp => userData?.phone;
  String? get alamat => fullAddress;
  String? get subditId => userData?.department?.subDirektorateId?.toString();
  String? get departmentId => userData?.department?.id?.toString();
  String? get kabkota => addresses?.isNotEmpty == true ? addresses!.first.city : '';

  BuyerAdminModelData({
    this.ID,
    this.email,
    this.role,
    this.status,
    this.fullAddress,
    this.createdAt,
    this.updatedAt,
    this.userData,
    this.addresses,
  });

  factory BuyerAdminModelData.fromJson(Map<String, dynamic> json) {
    var id = json['id']?.toString() ?? json['ID']?.toString();
    var addrs = <AddressData>[];
    if (json['addresses'] != null && json['addresses'] is List) {
      json['addresses'].forEach((v) {
        if (v != null) addrs.add(AddressData.fromJson(v));
      });
    }

    return BuyerAdminModelData(
      ID: id,
      email: json['email']?.toString(),
      role: json['role']?.toString(),
      status: json['status']?.toString(),
      fullAddress: json['full_address']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
      userData: json['user_data'] != null ? UserDataModel.fromJson(json['user_data']) : null,
      addresses: addrs.isNotEmpty ? addrs : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': ID,
      'email': email,
      'role': role,
      'status': status,
      'full_address': fullAddress,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'user_data': userData?.toJson(),
      'addresses': addresses?.map((v) => v.toJson()).toList(),
    };
  }
}

class BuyerAdminModel {
  List<BuyerAdminModelData?>? data;

  BuyerAdminModel({
    this.data,
  });

  factory BuyerAdminModel.fromJson(Map<String, dynamic> json) {
    // The new response is likely wrapped in "data" due to pagination or AdminBuyerResource::collection
    var dataList = <BuyerAdminModelData>[];
    if (json['data'] != null) {
      json['data'].forEach((v) {
        dataList.add(BuyerAdminModelData.fromJson(v));
      });
    }
    return BuyerAdminModel(
      data: dataList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data?.map((v) => v?.toJson()).toList(),
    };
  }
}
