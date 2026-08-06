class MateraiAdminModelData {
  String? id;
  String? type;
  String? nominal;

  MateraiAdminModelData({
    this.id,
    this.type,
    this.nominal,
  });

  MateraiAdminModelData.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toString();
    type = json['type']?.toString();
    nominal = json['nominal']?.toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['type'] = type;
    data['nominal'] = nominal;
    return data;
  }
}

class MateraiAdminModel {
  String? result;
  List<MateraiAdminModelData>? data;
  String? message;

  MateraiAdminModel({
    this.result,
    this.data,
    this.message,
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
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['result'] = result;
    if (this.data != null) {
      final v = this.data;
      final arr0 = [];
      for (var v in v!) {
        arr0.add(v.toJson());
      }
      data['data'] = arr0;
    }
    data['message'] = message;
    return data;
  }
}
