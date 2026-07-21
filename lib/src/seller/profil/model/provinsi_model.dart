/// Model Provinsi yang mendukung format response Laravel ResourceCollection.
///
/// Format baru Laravel (`GET /api/provinces`):
/// ```json
/// {
///   "data": [
///     { "id": 1, "name": "Aceh" }
///   ]
/// }
/// ```
///
/// Format lama (backward-compatible):
/// ```json
/// {
///   "result": "success",
///   "data": [{ "ID": "1", "nama": "Aceh" }]
/// }
/// ```
class ProvinsiModelData {
  String? ID;
  String? nama;

  ProvinsiModelData({
    this.ID,
    this.nama,
  });

  ProvinsiModelData.fromJson(Map<String, dynamic> json) {
    // Mendukung format baru Laravel: { id, name }
    // dan format lama: { ID, nama }
    ID = json['id']?.toString() ?? json['ID']?.toString();
    nama = json['name']?.toString() ?? json['nama']?.toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = ID;
    data['name'] = nama;
    return data;
  }
}

class ProvinsiModel {
  String? result;
  List<ProvinsiModelData?>? data;

  ProvinsiModel({
    this.result,
    this.data,
  });

  ProvinsiModel.fromJson(Map<String, dynamic> json) {
    // Format baru Laravel ResourceCollection tidak memiliki field 'result'
    result = json['result']?.toString() ?? 'success';

    if (json['data'] != null) {
      final v = json['data'];
      final arr0 = <ProvinsiModelData>[];
      v.forEach((v) {
        arr0.add(ProvinsiModelData.fromJson(v));
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
