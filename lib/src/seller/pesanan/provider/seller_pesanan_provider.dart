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
import 'package:shared_preferences/shared_preferences.dart';

class SellerPesananProvider extends BaseController with ChangeNotifier {
  var pesananSellerModel = PesananSellerModel();
  Future<void> fetchListPesanan({
    bool withLoading = false,
  }) async {
    if (withLoading) loading(true);
    
    try {
      // Ambil seller_id dari sesi login (bukan hardcode)
      final prefs = await SharedPreferences.getInstance();
      final sellerId = prefs.getString(Constant.kSetPrefId) ?? '';

      final parsed = await getRest(
        Constant.BASE_API_FULL + '/parent-orders?seller_id=$sellerId',
      );
      
      pesananSellerModel = PesananSellerModel.fromJson(parsed);
      notifyListeners();
    } catch (e) {
      throw Exception(e);
    } finally {
      if (withLoading) loading(false);
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
    required String parent_id,
  }) async {
    if (withLoading) loading(true);

    try {
      // Ambil seller_id dari sesi login (bukan hardcode)
      final prefs = await SharedPreferences.getInstance();
      final sellerId = prefs.getString(Constant.kSetPrefId) ?? '';

      final parsed = await getRest(
        Constant.BASE_API_FULL + '/parent-orders/$parent_id?seller_id=$sellerId',
      );
      
      detailPesananSellerModel = DetailPesananSellerModel.fromJson(parsed);
      notifyListeners();
    } catch (e) {
      throw Exception(e);
    } finally {
      if (withLoading) loading(false);
    }
  }

  String? rejectOrderReason;

  Future<bool> fetchActionPesananBaru({
    bool withLoading = false,
    required String parent_id,
    required bool terima,
  }) async {
    if (withLoading) loading(true);

    // PUT /api/parent-orders/{id} — update status pesanan
    var body = {"status": terima ? "accepted" : "rejected"};
    if (!terima && rejectOrderReason != null && rejectOrderReason?.trim() != '')
      body.addAll({'reject_reason': rejectOrderReason!});
      
    final response = await put(Constant.BASE_API_FULL + '/parent-orders/$parent_id', body: body);

    if (response.statusCode == 201 || response.statusCode == 200) {
      fetchDetailPesanan(parent_id: parent_id, withLoading: true);
      notifyListeners();
      if (withLoading) loading(false);
      return true;
    } else {
      final decoded = jsonDecode(response.body);
      final message = decoded['message'] ?? decoded['messages']?['error'] ?? 'Terjadi kesalahan';
      loading(false);
      return false;
      // throw Exception(message); // exception dihilangkan karena return false
    }
  }

  Future<bool> kirimBarang({
    bool withLoading = false,
    required String parent_id,
  }) async {
    if (withLoading) loading(true);
    
    // PUT /api/parent-orders/{id} — update status pengiriman
    final response = await put(
      Constant.BASE_API_FULL + '/parent-orders/$parent_id',
      body: {"status": "shipped"},
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      fetchDetailPesanan(parent_id: parent_id, withLoading: true);
      notifyListeners();
      if (withLoading) loading(false);
      return true;
    } else {
      final decoded = jsonDecode(response.body);
      final message = decoded['message'] ?? decoded['messages']?['error'] ?? 'Terjadi kesalahan';
      loading(false);
      return false;
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
      'file',
      image.path,
      filename: basename(image.path), 
    );

    // POST /api/order-documents — upload dokumen pesanan
    final response = await post(
      Constant.BASE_API_FULL + '/order-documents',
      body: {
        "parent_order_id": transaction_id, 
        "nomor_order": nomor_order,
        "document_type_id": suratType == SuratType.SURAT_PESANAN ? "2" : "3" // TTD Seller
      },
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

    // POST /api/order-documents — upload lampiran seller (faktur, enofa, lainnya)
    final response = await post(
      Constant.BASE_API_FULL + '/order-documents',
      body: {"parent_order_id": transaction_id, "document_type_id": "4"}, // ID untuk lampiran
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

    // POST /api/parent-orders/{id}/surat-jalan
    final response = await post(
      Constant.BASE_API_FULL + '/parent-orders/$transaction_id/surat-jalan',
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
