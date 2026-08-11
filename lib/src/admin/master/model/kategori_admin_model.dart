class KategoriAdminModelData {
  String? id;
  String? name;
  String? status;
  String? createdAt;
  String? updatedAt;

  // Polyfills for old code
  String? get ID => id;
  String? get nama => name;

  KategoriAdminModelData({
    this.id,
    this.name,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  KategoriAdminModelData.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toString() ?? json['ID']?.toString();
    name = json['name']?.toString() ?? json['nama']?.toString();
    status = json['status']?.toString();
    createdAt = json['created_at']?.toString();
    updatedAt = json['updated_at']?.toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['status'] = status;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}

class KategoriAdminModel {
  String? result;
  List<KategoriAdminModelData>? data;
  dynamic meta;
  dynamic links;

  KategoriAdminModel({
    this.result,
    this.data,
    this.meta,
    this.links,
  });

  KategoriAdminModel.fromJson(Map<String, dynamic> json) {
    result = json['result']?.toString() ?? "success";
    if (json['data'] != null && (json['data'] is List)) {
      final v = json['data'];
      final arr0 = <KategoriAdminModelData>[];
      v.forEach((v) {
        arr0.add(KategoriAdminModelData.fromJson(v));
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
