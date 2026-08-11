class ProvinsiAdminModelData {
  String? id;
  String? name;
  String? createdAt;
  String? updatedAt;

  // Polyfills
  String? get ID => id;
  String? get nama => name;

  ProvinsiAdminModelData({
    this.id,
    this.name,
    this.createdAt,
    this.updatedAt,
  });

  ProvinsiAdminModelData.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toString() ?? json['ID']?.toString();
    name = json['name']?.toString() ?? json['nama']?.toString();
    createdAt = json['created_at']?.toString();
    updatedAt = json['updated_at']?.toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}

class ProvinsiAdminModel {
  String? result;
  List<ProvinsiAdminModelData>? data;
  dynamic meta;
  dynamic links;

  ProvinsiAdminModel({
    this.result,
    this.data,
    this.meta,
    this.links,
  });

  ProvinsiAdminModel.fromJson(Map<String, dynamic> json) {
    result = json['result']?.toString() ?? "success";
    if (json['data'] != null) {
      final v = json['data'];
      final arr0 = <ProvinsiAdminModelData>[];
      v.forEach((v) {
        arr0.add(ProvinsiAdminModelData.fromJson(v));
      });
      data = arr0;
    }
    meta = json['meta'];
    links = json['links'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['result'] = result;
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
