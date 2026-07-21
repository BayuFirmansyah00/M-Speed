/// Model Kota/Kabupaten yang mendukung format response Laravel ResourceCollection.
///
/// Format baru Laravel (`GET /api/cities`):
/// ```json
/// {
///   "data": [
///     { "id": 1, "name": "Kota Bandung", "province_id": 9 }
///   ]
/// }
/// ```
///
/// Format lama (backward-compatible):
/// ```json
/// {
///   "result": "success",
///   "data": [{ "ID": "47", "kota": "Bandung" }]
/// }
/// ```
class KotaModelData {
  String? ID;
  String? kota;
  String? provinceId;

  KotaModelData({
    this.ID,
    this.kota,
    this.provinceId,
  });

  KotaModelData.fromJson(Map<String, dynamic> json) {
    // Mendukung format baru Laravel: { id, name, province_id }
    // dan format lama: { ID, kota }
    ID = json['id']?.toString() ?? json['ID']?.toString();
    kota = json['name']?.toString() ?? json['kota']?.toString();
    provinceId = json['province_id']?.toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = ID;
    data['name'] = kota;
    if (provinceId != null) data['province_id'] = provinceId;
    return data;
  }
}

class KotaModel {
  String? result;
  List<KotaModelData?>? data;

  KotaModel({
    this.result,
    this.data,
  });

  KotaModel.fromJson(Map<String, dynamic> json) {
    // Format baru Laravel ResourceCollection tidak memiliki field 'result'
    result = json['result']?.toString() ?? 'success';

    if (json['data'] != null) {
      final v = json['data'];
      final arr0 = <KotaModelData>[];
      v.forEach((v) {
        arr0.add(KotaModelData.fromJson(v));
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
