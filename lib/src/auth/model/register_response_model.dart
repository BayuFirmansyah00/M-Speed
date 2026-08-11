/// Model yang merepresentasikan response Laravel saat registrasi seller.
///
/// Laravel API Response (`POST /api/v1/merchant/register`) — status 201:
/// ```json
/// {
///   "data": {
///     "id": 1,
///     "name": "Toko ABC",
///     "company_name": null,
///     "phone": null,
///     "owner_name": null,
///     "photo": null,
///     "cp_name": null,
///     "cp_phone": null,
///     "kbli": null,
///     "completeness": 0,
///     "user": {
///       "id": 1,
///       "email": "seller@example.com",
///       "role": "SELLER"
///     },
///     "category": { "id": null, "name": null, "status": null },
///     "created_at": "2026-07-20T00:00:00.000000Z",
///     "updated_at": "2026-07-20T00:00:00.000000Z"
///   },
///   "meta": {
///     "message": "Registrasi merchant berhasil diproses. Silakan verifikasi email Anda.",
///     "access_token": "1|xxxxxxxx",
///     "token_type": "Bearer"
///   }
/// }
/// ```
class RegisterResponseModel {
  RegisterResponseData? data;
  RegisterResponseMeta? meta;

  RegisterResponseModel({this.data, this.meta});

  RegisterResponseModel.fromJson(Map<String, dynamic> json) {
    data = json['data'] != null
        ? RegisterResponseData.fromJson(json['data'])
        : null;
    meta = json['meta'] != null
        ? RegisterResponseMeta.fromJson(json['meta'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (data != null) map['data'] = data!.toJson();
    if (meta != null) map['meta'] = meta!.toJson();
    return map;
  }
}

class RegisterResponseData {
  int? id;
  String? email;
  String? role;
  RegisterResponseSellerProfile? sellerProfile;
  RegisterResponseAddress? address;
  String? createdAt;

  RegisterResponseData({
    this.id,
    this.email,
    this.role,
    this.sellerProfile,
    this.address,
    this.createdAt,
  });

  RegisterResponseData.fromJson(Map<String, dynamic> json) {
    id = json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '');
    email = json['email']?.toString();
    role = json['role']?.toString();
    sellerProfile = json['seller_profile'] != null
        ? RegisterResponseSellerProfile.fromJson(json['seller_profile'])
        : null;
    address = json['address'] != null
        ? RegisterResponseAddress.fromJson(json['address'])
        : null;
    createdAt = json['created_at']?.toString();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'role': role,
      'seller_profile': sellerProfile?.toJson(),
      'address': address?.toJson(),
      'created_at': createdAt,
    };
  }
}

class RegisterResponseSellerProfile {
  int? id;
  String? name;
  String? companyName;
  String? ownerName;
  int? completeness;

  RegisterResponseSellerProfile({
    this.id,
    this.name,
    this.companyName,
    this.ownerName,
    this.completeness,
  });

  RegisterResponseSellerProfile.fromJson(Map<String, dynamic> json) {
    id = json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '');
    name = json['name']?.toString();
    companyName = json['company_name']?.toString();
    ownerName = json['owner_name']?.toString();
    completeness = json['completeness'] is int
        ? json['completeness']
        : int.tryParse(json['completeness']?.toString() ?? '');
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'company_name': companyName,
      'owner_name': ownerName,
      'completeness': completeness,
    };
  }
}

class RegisterResponseAddress {
  int? id;
  String? detail;

  RegisterResponseAddress({this.id, this.detail});

  RegisterResponseAddress.fromJson(Map<String, dynamic> json) {
    id = json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '');
    detail = json['detail']?.toString();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'detail': detail,
    };
  }
}

class RegisterResponseMeta {
  String? message;
  String? accessToken;
  String? tokenType;

  RegisterResponseMeta({this.message, this.accessToken, this.tokenType});

  RegisterResponseMeta.fromJson(Map<String, dynamic> json) {
    message = json['message']?.toString();
    accessToken = json['access_token']?.toString();
    tokenType = json['token_type']?.toString();
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'access_token': accessToken,
      'token_type': tokenType,
    };
  }
}
