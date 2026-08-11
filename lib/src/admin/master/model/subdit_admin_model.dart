class SubditDepartment {
  int? id;
  String? departmentName;

  SubditDepartment({this.id, this.departmentName});

  SubditDepartment.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    departmentName = json['department_name']?.toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['department_name'] = departmentName;
    return data;
  }
}

class SubditAdminModelData {
  String? id;
  String? subditCode;
  String? subditName;
  String? totalDepartments;
  List<SubditDepartment>? departments;
  String? createdAt;
  String? updatedAt;

  SubditAdminModelData({
    this.id,
    this.subditCode,
    this.subditName,
    this.totalDepartments,
    this.departments,
    this.createdAt,
    this.updatedAt,
  });

  SubditAdminModelData.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toString();
    subditCode = json['subdit_code']?.toString();
    subditName = json['subdit_name']?.toString();
    totalDepartments = json['total_departments']?.toString();
    if (json['departments'] != null) {
      final v = json['departments'];
      final arr0 = <SubditDepartment>[];
      v.forEach((v) {
        arr0.add(SubditDepartment.fromJson(v));
      });
      departments = arr0;
    }
    createdAt = json['created_at']?.toString();
    updatedAt = json['updated_at']?.toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['subdit_code'] = subditCode;
    data['subdit_name'] = subditName;
    data['total_departments'] = totalDepartments;
    if (departments != null) {
      final arr0 = [];
      departments!.forEach((v) {
        arr0.add(v.toJson());
      });
      data['departments'] = arr0;
    }
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}

class SubditAdminModel {
  String? result;
  List<SubditAdminModelData?>? data;
  dynamic meta;
  dynamic links;

  SubditAdminModel({
    this.result,
    this.data,
    this.meta,
    this.links,
  });

  SubditAdminModel.fromJson(Map<String, dynamic> json) {
    result = json['result']?.toString();
    if (json['data'] != null) {
      final v = json['data'];
      final arr0 = <SubditAdminModelData>[];
      v.forEach((v) {
        arr0.add(SubditAdminModelData.fromJson(v));
      });
      this.data = arr0;
    }
    meta = json['meta'];
    links = json['links'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['result'] = result;
    if (this.data != null) {
      final v = this.data;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['data'] = arr0;
    }
    data['meta'] = meta;
    data['links'] = links;
    return data;
  }
}
