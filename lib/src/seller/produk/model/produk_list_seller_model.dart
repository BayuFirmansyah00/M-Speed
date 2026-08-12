import 'package:mspeed/common/model/pagination_meta_model.dart';
import 'package:mspeed/src/seller/produk/model/produk_detail_seller_model.dart';

class ProdukListSellerModel {
  String? result;
  List<ProdukDetailSellerModelData>? data;
  PaginationMetaModel? meta;

  ProdukListSellerModel({
    this.result,
    this.data,
    this.meta,
  });

  ProdukListSellerModel.fromJson(Map<String, dynamic> json) {
    result = json['result']?.toString() ?? 'success';
    if (json['data'] != null) {
      final v = json['data'] as List;
      data = v.map((e) => ProdukDetailSellerModelData.fromJson(e)).toList();
    }
    if (json['meta'] != null) {
      meta = PaginationMetaModel.fromJson(json['meta']);
    }
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['result'] = result;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    if (this.meta != null) {
      data['meta'] = this.meta!.toJson();
    }
    return data;
  }
}
