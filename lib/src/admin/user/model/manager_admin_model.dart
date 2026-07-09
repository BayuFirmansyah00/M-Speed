///
/// Model untuk data Manager.
///
/// CATATAN PENTING:
/// Struktur field di bawah ini ASUMSI, mengikuti pola BuyerAdminModel /
/// KeuanganAdminModel (firstname, lastname, email, telp, alamat).
/// Field ini BELUM diverifikasi ke response API asli karena belum ada akses
/// backend/Network tab untuk endpoint Manager.
///
/// Sebelum dipakai produksi:
/// 1. Buka mspeed2.erdata.id/admin/dashboard -> User Data -> Manager
/// 2. Buka DevTools > Network, lihat request list Manager
/// 3. Cocokkan field JSON response dengan field di bawah ini, sesuaikan bila beda
///
class ManagerAdminModelData {
  /*
  Contoh JSON yang DIASUMSIKAN (belum terverifikasi):
  {
    "ID": "1",
    "firstname": "Budi",
    "lastname": "Santoso",
    "email": "budi.manager@example.com",
    "telp": "081234567890",
    "alamat": "",
    "status": ""
  }
  */

  String? ID;
  String? firstname;
  String? lastname;
  String? email;
  String? telp;
  String? alamat;
  String? status;

  ManagerAdminModelData({
    this.ID,
    this.firstname,
    this.lastname,
    this.email,
    this.telp,
    this.alamat,
    this.status,
  });

  ManagerAdminModelData.fromJson(Map<String, dynamic> json) {
    ID = json['ID']?.toString();
    firstname = json['firstname']?.toString();
    lastname = json['lastname']?.toString();
    email = json['email']?.toString();
    telp = json['telp']?.toString();
    alamat = json['alamat']?.toString();
    status = json['status']?.toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['ID'] = ID;
    data['firstname'] = firstname;
    data['lastname'] = lastname;
    data['email'] = email;
    data['telp'] = telp;
    data['alamat'] = alamat;
    data['status'] = status;
    return data;
  }
}

class ManagerAdminModel {
  /*
  {
    "result": "success",
    "data": [ { ...ManagerAdminModelData... } ]
  }
  */

  String? result;
  List<ManagerAdminModelData?>? data;

  ManagerAdminModel({
    this.result,
    this.data,
  });

  ManagerAdminModel.fromJson(Map<String, dynamic> json) {
    result = json['result']?.toString();
    if (json['data'] != null) {
      final v = json['data'];
      final arr0 = <ManagerAdminModelData>[];
      v.forEach((v) {
        arr0.add(ManagerAdminModelData.fromJson(v));
      });
      this.data = arr0;
    }
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
    return data;
  }
}