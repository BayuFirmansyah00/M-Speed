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
  String? name;
  String? companyName;
  String? phone;
  String? ownerName;
  String? photo;
  String? cpName;
  String? cpPhone;
  String? kbli;
  int? completeness;
  RegisterResponseUser? user;
  String? createdAt;
  String? updatedAt;

  RegisterResponseData({
    this.id,
    this.name,
    this.companyName,
    this.phone,
    this.ownerName,
    this.photo,
    this.cpName,
    this.cpPhone,
    this.kbli,
    this.completeness,
    this.user,
    this.createdAt,
    this.updatedAt,
  });

  RegisterResponseData.fromJson(Map<String, dynamic> json) {
    id = json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '');
    name = json['name']?.toString();
    companyName = json['company_name']?.toString();
    phone = json['phone']?.toString();
    ownerName = json['owner_name']?.toString();
    photo = json['photo']?.toString();
    cpName = json['cp_name']?.toString();
    cpPhone = json['cp_phone']?.toString();
    kbli = json['kbli']?.toString();
    completeness = json['completeness'] is int
        ? json['completeness']
        : int.tryParse(json['completeness']?.toString() ?? '');
    user = json['user'] != null
        ? RegisterResponseUser.fromJson(json['user'])
        : null;
    createdAt = json['created_at']?.toString();
    updatedAt = json['updated_at']?.toString();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'company_name': companyName,
      'phone': phone,
      'owner_name': ownerName,
      'photo': photo,
      'cp_name': cpName,
      'cp_phone': cpPhone,
      'kbli': kbli,
      'completeness': completeness,
      'user': user?.toJson(),
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

class RegisterResponseUser {
  int? id;
  String? email;
  String? role;

  RegisterResponseUser({this.id, this.email, this.role});

  RegisterResponseUser.fromJson(Map<String, dynamic> json) {
    id = json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '');
    email = json['email']?.toString();
    role = json['role']?.toString();
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'email': email, 'role': role};
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
