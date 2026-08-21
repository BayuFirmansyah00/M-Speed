class ProfileSellerModel {
  String? result;
  ProfileData? data;

  ProfileSellerModel({this.result, this.data});

  factory ProfileSellerModel.fromJson(Map<String, dynamic> json) {
    return ProfileSellerModel(
      result: json['result']?.toString() ?? 'success',
      data: json['data'] != null ? ProfileData.fromJson(json['data']) : null,
    );
  }
}

class ProfileData {
  int? id;
  String? email;
  String? role;
  SellerProfileInfo? profile;
  List<BankAccountInfo>? bankAccounts;
  List<LegalityInfo>? legalities;

  ProfileData({
    this.id,
    this.email,
    this.role,
    this.profile,
    this.bankAccounts,
    this.legalities,
  });

  factory ProfileData.fromJson(Map<String, dynamic> json) {
    return ProfileData(
      id: json['id'],
      email: json['email']?.toString(),
      role: json['role']?.toString(),
      profile: json['profile'] != null ? SellerProfileInfo.fromJson(json['profile']) : null,
      bankAccounts: (json['bank_accounts'] as List?)
          ?.map((e) => BankAccountInfo.fromJson(e))
          .toList() ?? [],
      legalities: (json['legalities'] as List?)
          ?.map((e) => LegalityInfo.fromJson(e))
          .toList() ?? [],
    );
  }
}

class SellerProfileInfo {
  int? id;
  String? name;
  String? companyName;
  String? phone;
  String? ownerName;
  String? photoUrl;
  String? cpName;
  String? cpPhone;
  String? kbli;
  String? completeness;
  String? category;
  String? signatureUrl;
  String? signatureDate;
  String? detailAddress;
  int? cityId;
  String? cityName;
  int? provinceId;
  String? provinceName;
  String? latitude;
  String? longitude;

  SellerProfileInfo({
    this.id,
    this.name,
    this.companyName,
    this.phone,
    this.ownerName,
    this.photoUrl,
    this.cpName,
    this.cpPhone,
    this.kbli,
    this.completeness,
    this.category,
    this.signatureUrl,
    this.signatureDate,
    this.detailAddress,
    this.cityId,
    this.cityName,
    this.provinceId,
    this.provinceName,
    this.latitude,
    this.longitude,
  });

  factory SellerProfileInfo.fromJson(Map<String, dynamic> json) {
    return SellerProfileInfo(
      id: json['id'],
      name: json['name']?.toString(),
      companyName: json['company_name']?.toString(),
      phone: json['phone']?.toString(),
      ownerName: json['owner_name']?.toString(),
      photoUrl: json['photo_url']?.toString(),
      cpName: json['cp_name']?.toString(),
      cpPhone: json['cp_phone']?.toString(),
      kbli: json['kbli']?.toString(),
      completeness: json['completeness']?.toString(),
      category: json['category']?.toString(),
      signatureUrl: json['signature_url']?.toString(),
      signatureDate: json['signature_date']?.toString(),
      detailAddress: json['detail_address']?.toString(),
      cityId: json['city_id'],
      cityName: json['city_name']?.toString(),
      provinceId: json['province_id'],
      provinceName: json['province_name']?.toString(),
      latitude: json['latitude']?.toString(),
      longitude: json['longitude']?.toString(),
    );
  }
}

class BankAccountInfo {
  int? id;
  String? bankName;
  String? rekNum;
  String? rekNameOf;
  String? passbookImgUrl;

  BankAccountInfo({
    this.id,
    this.bankName,
    this.rekNum,
    this.rekNameOf,
    this.passbookImgUrl,
  });

  factory BankAccountInfo.fromJson(Map<String, dynamic> json) {
    return BankAccountInfo(
      id: json['id'],
      bankName: json['bank_name']?.toString(),
      rekNum: json['rek_num']?.toString(),
      rekNameOf: json['rek_name_of']?.toString(),
      passbookImgUrl: json['passbook_img_url']?.toString(),
    );
  }
}

class LegalityInfo {
  int? id;
  String? legalityNum;
  String? type;
  String? fileUrl;

  LegalityInfo({
    this.id,
    this.legalityNum,
    this.type,
    this.fileUrl,
  });

  factory LegalityInfo.fromJson(Map<String, dynamic> json) {
    return LegalityInfo(
      id: json['id'],
      legalityNum: json['legality_num']?.toString(),
      type: json['type']?.toString(),
      fileUrl: json['file_url']?.toString(),
    );
  }
}
