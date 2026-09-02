/// Manager Team Member Model
/// Source of truth: ManagerTeamResource.php
/// Fields: id, first_name, last_name, full_name, phone, completeness, user, department

class ManagerTeamModel {
  List<ManagerTeamMember>? data;

  ManagerTeamModel({this.data});

  factory ManagerTeamModel.fromJson(Map<String, dynamic> json) {
    return ManagerTeamModel(
      data: json['data'] != null
          ? (json['data'] as List).map((i) => ManagerTeamMember.fromJson(i)).toList()
          : null,
    );
  }
}

class ManagerTeamMember {
  int? id;
  String? firstName;
  String? lastName;
  String? fullName;
  String? phone;
  String? completeness;
  ManagerTeamUser? user;
  ManagerTeamDepartment? department;
  String? createdAt;
  String? updatedAt;

  ManagerTeamMember({
    this.id,
    this.firstName,
    this.lastName,
    this.fullName,
    this.phone,
    this.completeness,
    this.user,
    this.department,
    this.createdAt,
    this.updatedAt,
  });

  factory ManagerTeamMember.fromJson(Map<String, dynamic> json) {
    return ManagerTeamMember(
      id: json['id'],
      firstName: json['first_name']?.toString(),
      lastName: json['last_name']?.toString(),
      fullName: json['full_name']?.toString(),
      phone: json['phone']?.toString(),
      completeness: json['completeness']?.toString(),
      user: json['user'] != null ? ManagerTeamUser.fromJson(json['user']) : null,
      department: json['department'] != null ? ManagerTeamDepartment.fromJson(json['department']) : null,
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }
}

class ManagerTeamUser {
  int? id;
  String? email;
  String? role;

  ManagerTeamUser({this.id, this.email, this.role});

  factory ManagerTeamUser.fromJson(Map<String, dynamic> json) {
    return ManagerTeamUser(
      id: json['id'],
      email: json['email']?.toString(),
      role: json['role']?.toString(),
    );
  }
}

class ManagerTeamDepartment {
  int? id;
  String? name;
  String? subDirektorate;

  ManagerTeamDepartment({this.id, this.name, this.subDirektorate});

  factory ManagerTeamDepartment.fromJson(Map<String, dynamic> json) {
    return ManagerTeamDepartment(
      id: json['id'],
      name: json['name']?.toString(),
      subDirektorate: json['sub_direktorate']?.toString(),
    );
  }
}
