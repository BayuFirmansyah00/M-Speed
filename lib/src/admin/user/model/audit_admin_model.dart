///
/// Model untuk data Audit.
///
/// CATATAN:
/// Berdasarkan tampilan tabel web admin, Audit HANYA punya kolom:
/// - username
/// - Full Name
/// dan TIDAK ada tombol Hapus / Ganti Sesi (beda dari Manager/Buyer/Seller).
///
/// ASUMSI field 'fullname' sebagai 1 field tunggal (bukan firstname+lastname
/// terpisah seperti Manager) -- karena tabel cuma tampilkan "Full Name".
/// Field 'password' ditambahkan karena kemungkinan besar dibutuhkan saat
/// create/edit akun login, walau tidak tampil di tabel. WAJIB dikonfirmasi
/// ke backend / form web (klik "Create New" di web admin untuk lihat field
/// form aslinya).
///
class AuditAdminModelData {
  /*
  Contoh JSON yang DIASUMSIKAN (belum terverifikasi):
  {
    "ID": "1",
    "username": "audit",
    "fullname": "Audit"
  }
  */

  String? ID;
  String? username;
  String? fullname;

  AuditAdminModelData({
    this.ID,
    this.username,
    this.fullname,
  });

  AuditAdminModelData.fromJson(Map<String, dynamic> json) {
    ID = json['ID']?.toString();
    username = json['username']?.toString();
    fullname = json['fullname']?.toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['ID'] = ID;
    data['username'] = username;
    data['fullname'] = fullname;
    return data;
  }
}

class AuditAdminModel {
  /*
  {
    "result": "success",
    "data": [ { ...AuditAdminModelData... } ]
  }
  */

  String? result;
  List<AuditAdminModelData?>? data;

  AuditAdminModel({
    this.result,
    this.data,
  });

  AuditAdminModel.fromJson(Map<String, dynamic> json) {
    result = json['result']?.toString();
    if (json['data'] != null) {
      final v = json['data'];
      final arr0 = <AuditAdminModelData>[];
      v.forEach((v) {
        arr0.add(AuditAdminModelData.fromJson(v));
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
