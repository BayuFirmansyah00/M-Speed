class KotaAdminModelData {
  String? id;
  String? name;
  String? provId;
  String? provName;
  String? createdAt;
  String? updatedAt;

  // Polyfills
  String? get ID => id;
  String? get nama => name;

  KotaAdminModelData({
    this.id,
    this.name,
    this.provId,
    this.provName,
    this.createdAt,
    this.updatedAt,
  });

  KotaAdminModelData.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toString() ?? json['ID']?.toString();
    name = json['name']?.toString() ?? json['nama']?.toString();
    if (json['province'] != null && json['province'] is Map) {
      provId = json['province']['id']?.toString();
      provName = json['province']['name']?.toString();
    } else {
      provId = json['prov_id']?.toString();
    }
    createdAt = json['created_at']?.toString();
    updatedAt = json['updated_at']?.toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    if (provId != null || provName != null) {
      data['province'] = {
        'id': provId,
        'name': provName,
      };
    }
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}

class KotaAdminModel {
  String? result;
  List<KotaAdminModelData>? data;
  dynamic meta;
  dynamic links;

  KotaAdminModel({
    this.result,
    this.data,
    this.meta,
    this.links,
  });

  KotaAdminModel.fromJson(Map<String, dynamic> json) {
    result = json['result']?.toString() ?? "success";
    if (json['data'] != null) {
      final v = json['data'];
      final arr0 = <KotaAdminModelData>[];
      v.forEach((v) {
        arr0.add(KotaAdminModelData.fromJson(v));
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
