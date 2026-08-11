class MateraiOrderDocument {
  int? id;
  String? status;
  String? filePath;

  MateraiOrderDocument({this.id, this.status, this.filePath});

  MateraiOrderDocument.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    status = json['status']?.toString();
    filePath = json['file_path']?.toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['status'] = status;
    data['file_path'] = filePath;
    return data;
  }
}

class MateraiAdminModelData {
  String? id;
  String? type;
  String? nominal;
  String? filePath;
  String? fileUrl;
  MateraiOrderDocument? orderDocument;
  String? createdAt;
  String? updatedAt;

  MateraiAdminModelData({
    this.id,
    this.type,
    this.nominal,
    this.filePath,
    this.fileUrl,
    this.orderDocument,
    this.createdAt,
    this.updatedAt,
  });

  MateraiAdminModelData.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toString();
    type = json['type']?.toString();
    nominal = json['nominal']?.toString();
    filePath = json['file_path']?.toString();
    fileUrl = json['file_url']?.toString();
    if (json['order_document'] != null) {
      orderDocument = MateraiOrderDocument.fromJson(json['order_document']);
    }
    createdAt = json['created_at']?.toString();
    updatedAt = json['updated_at']?.toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['type'] = type;
    data['nominal'] = nominal;
    data['file_path'] = filePath;
    data['file_url'] = fileUrl;
    if (orderDocument != null) {
      data['order_document'] = orderDocument!.toJson();
    }
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}

class MateraiAdminModel {
  String? result;
  List<MateraiAdminModelData>? data;
  String? message;
  dynamic meta;
  dynamic links;

  MateraiAdminModel({
    this.result,
    this.data,
    this.message,
    this.meta,
    this.links,
  });

  MateraiAdminModel.fromJson(Map<String, dynamic> json) {
    result = json['result']?.toString();
    if (json['data'] != null) {
      final v = json['data'];
      final arr0 = <MateraiAdminModelData>[];
      v.forEach((v) {
        arr0.add(MateraiAdminModelData.fromJson(v));
      });
      data = arr0;
    }
    message = json['message']?.toString();
    meta = json['meta'];
    links = json['links'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['result'] = result;
    if (this.data != null) {
      final arr0 = [];
      for (var v in this.data!) {
        arr0.add(v.toJson());
      }
      data['data'] = arr0;
    }
    data['message'] = message;
    data['meta'] = meta;
    data['links'] = links;
    return data;
  }
}
