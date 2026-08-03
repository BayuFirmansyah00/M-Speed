class BannerAdminModelData {
  String? id;
  String? judul;
  String? deskripsi;
  String? imageUrl;

  BannerAdminModelData({
    this.id,
    this.judul,
    this.deskripsi,
    this.imageUrl,
  });

  BannerAdminModelData.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toString();
    judul = json['judul']?.toString();
    deskripsi = json['deskripsi']?.toString();
    imageUrl = json['image_url']?.toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['judul'] = judul;
    data['deskripsi'] = deskripsi;
    data['image_url'] = imageUrl;
    return data;
  }
}

class BannerAdminModel {
  String? result;
  List<BannerAdminModelData?>? data;

  BannerAdminModel({
    this.result,
    this.data,
  });

  BannerAdminModel.fromJson(Map<String, dynamic> json) {
    result = json['result']?.toString();
    if (json['data'] != null) {
      final v = json['data'];
      final arr0 = <BannerAdminModelData>[];
      v.forEach((v) {
        arr0.add(BannerAdminModelData.fromJson(v));
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
