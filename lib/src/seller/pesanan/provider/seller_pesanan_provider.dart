import 'dart:convert';
import 'dart:io';

import 'package:mspeed/common/base/base_controller.dart';
import 'package:mspeed/common/helper/constant.dart';
import 'package:flutter/material.dart';
import 'package:mspeed/common/helper/multipart.dart';
import 'package:mspeed/src/seller/pesanan/model/detail_pesanan_seller_model.dart';
import 'package:mspeed/src/seller/pesanan/model/pesanan_seller_model.dart';
import 'package:mspeed/src/seller/pesanan/view/pesanan_buat_surat_view.dart';
import 'package:mspeed/src/seller/pesanan/view/upload_lampiran_view.dart';
import 'package:path/path.dart';
import 'package:http/http.dart' as http;

class SellerPesananProvider extends BaseController with ChangeNotifier {
  var pesananSellerModel = PesananSellerModel();
  Future<void> fetchListPesanan({
    bool withLoading = false,
    String sellerId = "196",
  }) async {
    if (withLoading) loading(true);
    final response = await get(
      Constant.BASE_API_FULL + '/getpesananseller',
      body: {"seller_id": sellerId},
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      pesananSellerModel = PesananSellerModel.fromJson(
        jsonDecode(response.body),
      );
      notifyListeners();

      if (withLoading) loading(false);
      // return model;
    } else {
      final message = jsonDecode(response.body)["messages"]["error"];
      loading(false);
      throw Exception(message);
    }
  }

  var detailPesananSellerModel = DetailPesananSellerModel();

  void reset() {
    detailPesananSellerModel = DetailPesananSellerModel();
    notifyListeners();
  }

  bool showMore = false;

  Future<void> fetchDetailPesanan({
    bool withLoading = false,
    String seller_id = '196',
    required String parent_id,
  }) async {
    if (withLoading) loading(true);

    final response = await get(
      Constant.BASE_API_FULL + '/getdetailpesananseller',
      body: {"seller_id": seller_id, "parent_order_id": parent_id},
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      detailPesananSellerModel = DetailPesananSellerModel.fromJson(
        jsonDecode(response.body),
      );
      notifyListeners();

      if (withLoading) loading(false);
    } else {
      final message = jsonDecode(response.body)["messages"]["error"];
      loading(false);
      throw Exception(message);
    }
  }

  String? rejectOrderReason;

  Future<bool> fetchActionPesananBaru({
    bool withLoading = false,
    required String parent_id,
    required bool terima,
  }) async {
    if (withLoading) loading(true);

    final path = terima ? 'terimapesananseller' : 'tolakpesananseller';

    var body = {"parent_order_id": parent_id};
    if (!terima && rejectOrderReason != null && rejectOrderReason?.trim() != '')
      body.addAll({'alasantolak': rejectOrderReason!});
    final response = await post(Constant.BASE_API_FULL + '/$path', body: body);

    if (response.statusCode == 201 || response.statusCode == 200) {
      fetchDetailPesanan(parent_id: parent_id, withLoading: true);
      notifyListeners();
      if (withLoading) loading(false);
      return true;
    } else {
      final message = jsonDecode(response.body)["messages"]["error"];
      loading(false);
      return false;
      throw Exception(message);
    }
  }

  Future<bool> kirimBarang({
    bool withLoading = false,
    required String parent_id,
  }) async {
    if (withLoading) loading(true);
    final response = await post(
      Constant.BASE_API_FULL + '/kirimbarangseller',
      body: {"parent_order_id": parent_id},
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      fetchDetailPesanan(parent_id: parent_id, withLoading: true);
      notifyListeners();
      if (withLoading) loading(false);
      return true;
    } else {
      final message = jsonDecode(response.body)["messages"]["error"];
      loading(false);
      return false;
      throw Exception(message);
    }
  }

  bool? _isTtdSuccess = null;

  bool? get isTtdSuccess => _isTtdSuccess;

  set isTtdSuccess(bool? value) {
    _isTtdSuccess = value;
  }

  Future<bool> addTtdPemesanan({
    bool withLoading = false,
    required String transaction_id,
    required String nomor_order,
    required SuratType suratType,
    required File image,
  }) async {
    if (withLoading) loading(true);
    final file = await http.MultipartFile.fromPath(
      'signature',
      image.path,
      filename: basename(image.path), // Use the file name of the image
    );

    final response = await post(
      Constant.BASE_API_FULL + '/${suratType.path}',
      body: {"nomor_order": nomor_order, "parent_order_id": transaction_id},
      files: [file],
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      if (withLoading) loading(false);
      if (jsonDecode(response.body)["status"] == "success") {
        isTtdSuccess = true;
        return true;
      } else {
        isTtdSuccess = false;
        return false;
      }
    } else {
      isTtdSuccess = false;
      return false;
    }
  }

  Future<bool> uploadLampiran({
    bool withLoading = false,
    required String transaction_id,
    required File faktur,
    required File eNota,
    required List<OtherFile> lainnya,
  }) async {
    if (withLoading) loading(true);

    final mFaktur = await getMultipart('faktur', faktur);
    // http.MultipartFile.fromPath(
    //   'faktur',
    //   faktur.path,
    //   filename: basename(faktur.path), // Use the file name of the image
    // );

    final mNota = await getMultipart('enofa', eNota);
    // await http.MultipartFile.fromPath(
    //   'enofa',
    //   eNota.path,
    //   filename: basename(eNota.path), // Use the file name of the image
    // );

    List<http.MultipartFile> mLainnya = [];
    for (int i = 0; i < lainnya.length; i++) {
      if (lainnya[i].file == null) continue;
      mLainnya.add(
        await http.MultipartFile.fromPath(
          'filelain[]',
          lainnya[i].file!.path,
          filename: basename(lainnya[i].controller.text),
        ),
      );
    }

    final response = await post(
      Constant.BASE_API_FULL + '/uploadlampiranseller',
      body: {"parent_order_id": transaction_id},
      files: [mFaktur, mNota, ...mLainnya],
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      if (withLoading) loading(false);
      if (jsonDecode(response.body)["status"] == "success") {
        // isTtdSuccess = true;
        return true;
      } else {
        // isTtdSuccess = false;
        return false;
      }
    } else {
      // isTtdSuccess = false;
      return false;
    }
  }

  Future<bool> buatSuratJalan({
    bool withLoading = false,
    required String transaction_id,
    required List<ProductCatatan> productCatatan,
    required String catatan,
  }) async {
    if (withLoading) loading(true);

    final body = {"parent_order_id": transaction_id, "catatan": catatan};
    for (int i = 0; i < productCatatan.length; i++) {
      print(productCatatan[i].ket);
      body["produk_id[$i]"] = productCatatan[i].id;
      body["keterangan[$i]"] = productCatatan[i].ket ?? '';
    }

    final response = await post(
      Constant.BASE_API_FULL + '/buatsuratjalanseller',
      body: body,
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      if (withLoading) loading(false);
      if (jsonDecode(response.body)["status"] == "success") {
        return true;
      } else {
        return false;
      }
      // notifyListeners();

      // return model;
    } else {
      return false;
      final message = jsonDecode(response.body)["messages"]["error"];
      loading(false);
      throw Exception(message);
    }
  }

  Future<String?> getPdf({
    bool withLoading = false,
    required PDF_LINK pdf,
    required String transaction_id,
  }) async {
    if (withLoading) loading(true);
    final response = await get(
      Constant.BASE_API_FULL + '/${pdf.pdf}',
      body: {"parent_order_id": transaction_id},
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      if (withLoading) loading(false);

      if (jsonDecode(response.body)["result"] == "success") {
        return jsonDecode(response.body)["data"];
      } else {
        return null;
      }
    } else {
      final message = jsonDecode(response.body)["messages"]["error"];
      loading(false);
      return null;
    }
  }
}

enum PDF_LINK {
  SURAT_PESANAN("cetaksuratpesananseller"),
  SURAT_JALAN("cetaksuratjalanseller");

  final String pdf;

  const PDF_LINK(this.pdf);
}

class ProductCatatan {
  final String id;
  String? ket;

  ProductCatatan({required this.id, this.ket});
}
