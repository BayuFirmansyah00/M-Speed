import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:mspeed/common/base/base_controller.dart';
import 'package:mspeed/common/component/custom_navigator.dart';
import 'package:mspeed/common/helper/constant.dart';
import 'package:flutter/material.dart';
import 'package:mspeed/common/helper/encrypt.dart';
import 'package:mspeed/common/page/pdf_view.dart';
import 'package:mspeed/src/keuangan/pesanan/model/daftar_transaksi_keuangan_model.dart';
import 'package:mspeed/src/keuangan/pesanan/model/detail_transaksi_keuangan_model.dart';
import 'package:mspeed/src/keuangan/pesanan/model/download_model.dart';
import 'package:mspeed/src/keuangan/pesanan/model/lihat_lampiran_model.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class KeuanganProvider extends BaseController with ChangeNotifier {
  DaftarTransaksiKeuanganModel _daftarTransaksi =
      DaftarTransaksiKeuanganModel();

  DaftarTransaksiKeuanganModel get daftarTransaksi => _daftarTransaksi;

  set daftarTransaksi(DaftarTransaksiKeuanganModel value) {
    _daftarTransaksi = value;
  }

  TextEditingController uploadC = TextEditingController();
  FocusNode uploadNode = FocusNode();

  TextEditingController attachC = TextEditingController();
  String? fileAttachUrl;
  TextEditingController descC = TextEditingController();

  bool _isReady = false;
  String _errorMessage = '';

  bool get isReady => this._isReady;

  set isReady(bool value) => this._isReady = value;

  String? _remotePDFpath;
  String? get remotePDFpath => this._remotePDFpath;

  set remotePDFpath(String? value) {
    this._remotePDFpath = value;
    notifyListeners();
  }

  String get errorMessage => this._errorMessage;

  set errorMessage(String value) => this._errorMessage = value;

  Completer<PDFViewController> _controller = Completer<PDFViewController>();
  Completer<PDFViewController> get controller => this._controller;

  set controller(Completer<PDFViewController> value) =>
      this._controller = value;
  int? _pages = 1;
  int? _currentPage = 1;
  bool _isRender = false;
  bool get isRender => this._isRender;
  set isRender(bool value) => this._isRender = value;
  int? get pages => this._pages;

  set pages(int? value) => this._pages = value;

  int? get currentPage => this._currentPage;

  set currentPage(int? value) => this._currentPage = value;

  File? _imageAttachment;
  File? get imageAttachment => _imageAttachment;

  set imageAttachment(File? imageAttachment1) {
    _imageAttachment = imageAttachment1;
    notifyListeners();
  }

  clearData() {
    attachC.clear();
  }

  Future<void> fetchViewNotif({
    bool withLoading = false,
    required String id,
    required String type,
  }) async {
    if (withLoading) loading(true);
    controller = Completer<PDFViewController>();
    pages = 1;
    currentPage = 1;
    isReady = false;
    errorMessage = '';
    downloadModel = DownloadModel();
    String encodedId = Encrypt().encode64(id);
    Map<String, String> param = {'id': encodedId, 'type': type};

    final response = await post(
        Constant.BASE_API_FULL + '/notification/notif/view',
        body: param);

    if (response.statusCode == 201 || response.statusCode == 200) {
      downloadModel = DownloadModel.fromJson(jsonDecode(response.body));
      remotePDFpath = downloadModel.data ?? "";
      notifyListeners();
      if (withLoading) loading(false);
      // isFetching = false;
    } else {
      remotePDFpath = '';
      final message = jsonDecode(response.body)["message"];
      loading(false);
      throw Exception(message);
    }
  }

  Future<void> fetchTransaction({bool withLoading = false}) async {
    if (withLoading) loading(true);

    final response = await get(Constant.BASE_API_FULL + '/getpesanankeuangan');

    if (response.statusCode == 201 || response.statusCode == 200) {
      daftarTransaksi =
          DaftarTransaksiKeuanganModel.fromJson(jsonDecode(response.body));
      notifyListeners();

      if (withLoading) loading(false);
      // return model;
    } else {
      final message = jsonDecode(response.body)["messages"]["error"];
      loading(false);
      throw Exception(message);
    }
  }

  DetailTransaksiKeuanganModel _detailTransaksi =
      DetailTransaksiKeuanganModel();

  DetailTransaksiKeuanganModel get detailTransaksi => _detailTransaksi;

  set detailTransaksi(DetailTransaksiKeuanganModel value) {
    _detailTransaksi = value;
  }

  bool showMore = false;

  Future<void> fetchDetailTransaction(
      {bool withLoading = false, required String transaction_id}) async {
    if (withLoading) loading(true);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString(Constant.kSetPrefId) ?? '1';

    final response = await get(
        Constant.BASE_API_FULL + '/getdetailpesanankeuangan',
        body: {"keuangan_id": userId, "parent_order_id": transaction_id});
    log("ISINYA REKENing : ${detailTransaksi.data?.ParentOrderModel?.Rekening}");

    if (response.statusCode == 201 || response.statusCode == 200) {
      detailTransaksi =
          DetailTransaksiKeuanganModel.fromJson(jsonDecode(response.body));
      notifyListeners();

      if (withLoading) loading(false);
      // return model;
    } else {
      final message = jsonDecode(response.body)["messages"]["error"];
      loading(false);
      throw Exception(message);
    }
  }

  DownloadModel _downloadModel = DownloadModel();

  DownloadModel get downloadModel => _downloadModel;

  set downloadModel(DownloadModel value) {
    _downloadModel = value;
  }

  LihatLampiranModel _lihatLampiranModel = LihatLampiranModel();

  LihatLampiranModel get lihatLampiranModel => _lihatLampiranModel;

  set lihatLampiranModel(LihatLampiranModel value) {
    _lihatLampiranModel = value;
  }

  Future<String?> fetchPesananKeuangan(BuildContext context,
      {bool withLoading = false, required String transaction_id}) async {
    if (withLoading) loading(true);
    final response = await get(
        Constant.BASE_API_FULL + '/cetaksuratpesanankeuangan',
        body: {"parent_order_id": transaction_id});

    if (response.statusCode == 201 || response.statusCode == 200) {
      downloadModel = DownloadModel.fromJson(jsonDecode(response.body));
      notifyListeners();
      if (withLoading) loading(false);

      await CusNav.nPush(
          context,
          PdfView(
              pdfUrl: (downloadModel.data ?? ""),
              title: "Download Surat Pesanan"));

      if (jsonDecode(response.body)["result"] == "success") {
        return jsonDecode(response.body)["data"];
      } else {
        return null;
      }
      // return model;
    } else {
      loading(false);
      return null;
    }
  }

  Future<String?> fetchInvoiceKeuangan(BuildContext context,
      {bool withLoading = false, required String transaction_id}) async {
    if (withLoading) loading(true);
    final response = await get(Constant.BASE_API_FULL + '/cetakinvoicekeuangan',
        body: {"parent_order_id": transaction_id});

    if (response.statusCode == 201 || response.statusCode == 200) {
      downloadModel = DownloadModel.fromJson(jsonDecode(response.body));
      notifyListeners();
      if (withLoading) loading(false);

      // await launchUrl(Uri.parse(downloadModel.data ?? ""));
      await CusNav.nPush(
          context,
          PdfView(
              pdfUrl: (downloadModel.data ?? ""), title: "Download Invoice"));

      if (jsonDecode(response.body)["result"] == "success") {
        return jsonDecode(response.body)["data"];
      } else {
        return null;
      }
      // return model;
    } else {
      loading(false);
      return null;
    }
  }

  Future<String?> fetchKwitansiKeuangan(BuildContext context,
      {bool withLoading = false, required String transaction_id}) async {
    if (withLoading) loading(true);
    final response = await get(
        Constant.BASE_API_FULL + '/cetakkwitansikeuangan',
        body: {"parent_order_id": transaction_id});

    if (response.statusCode == 201 || response.statusCode == 200) {
      downloadModel = DownloadModel.fromJson(jsonDecode(response.body));
      notifyListeners();
      if (withLoading) loading(false);

      // await launchUrl(Uri.parse(downloadModel.data ?? ""));
      await CusNav.nPush(
          context,
          PdfView(
              pdfUrl: (downloadModel.data ?? ""), title: "Download Kwitansi"));

      if (jsonDecode(response.body)["result"] == "success") {
        return jsonDecode(response.body)["data"];
      } else {
        return null;
      }
      // return model;
    } else {
      loading(false);
      return null;
    }
  }

  Future<String?> fetchSuratJalankeuangan(BuildContext context,
      {bool withLoading = false, required String transaction_id}) async {
    if (withLoading) loading(true);
    final response = await get(
        Constant.BASE_API_FULL + '/cetaksuratjalankeuangan',
        body: {"parent_order_id": transaction_id});

    if (response.statusCode == 201 || response.statusCode == 200) {
      downloadModel = DownloadModel.fromJson(jsonDecode(response.body));
      notifyListeners();
      if (withLoading) loading(false);

      await CusNav.nPush(
          context,
          PdfView(
              pdfUrl: (downloadModel.data ?? ""),
              title: "Download Surat Jalan"));

      if (jsonDecode(response.body)["result"] == "success") {
        return jsonDecode(response.body)["data"];
      } else {
        return null;
      }
      // return model;
    } else {
      loading(false);
      return null;
    }
  }

  Future<String?> fetchLampiranTagihanKeuangan(BuildContext context,
      {bool withLoading = false, required String transaction_id}) async {
    if (withLoading) loading(true);

    final response = await get(
      Constant.BASE_API_FULL + '/lihatlampirantagihan',
      body: {"parent_order_id": transaction_id},
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      lihatLampiranModel =
          LihatLampiranModel.fromJson(jsonDecode(response.body));
      notifyListeners();

      if (withLoading) loading(false);

      var result = jsonDecode(response.body)["result"];
      if (result == "success") {
        var data = jsonDecode(response.body)["data"];
        return data["url"] as String?;
      } else {
        return null;
      }
    } else {
      final message = jsonDecode(response.body)["messages"]["error"];
      loading(false);
      throw Exception(message);
    }
  }

  bool? _isBuktiUpload = null;

  bool? get isBuktiUpload => _isBuktiUpload;

  set isBuktiUpload(bool? value) {
    _isBuktiUpload = value;
  }

  Future<bool> sendBuktiBayar(
      {bool withLoading = false,
      required String parent_order_id,
      required File image}) async {
    if (withLoading) loading(true);
    final prefs = await SharedPreferences.getInstance();
    String? userId = await prefs.getString(Constant.kSetPrefId) ?? "";

    final file = await http.MultipartFile.fromPath(
      'bukti',
      image.path,
      filename: basename(image.path), // Use the file name of the image
    );

    final response = await post(Constant.BASE_API_FULL + '/uploadbuktibayar',
        body: {"parent_order_id": parent_order_id, "keuangan_id": userId},
        files: [file]);

    if (response.statusCode == 201 || response.statusCode == 200) {
      if (withLoading) loading(false);
      if (jsonDecode(response.body)["status"] == "success") {
        isBuktiUpload = true;
        return true;
      } else {
        isBuktiUpload = false;
        return false;
      }
    } else {
      isBuktiUpload = false;
      return false;
    }
  }

  String? reason;

  Future<bool> kembalikanKwitansi({
    bool withLoading = true,
    required String parentOrderId,
  }) async {
    if (withLoading) loading(true);
    final prefs = await SharedPreferences.getInstance();
    String? keuanganId = await prefs.getString(Constant.kSetPrefId) ?? "";

    final response = await post(
      Constant.BASE_API_FULL + '/kembalikankwitansi',
      body: {
        "keuangan_id": keuanganId,
        "parent_order_id": parentOrderId,
        "desc": reason,
      },
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
      // final message = jsonDecode(response.body)["messages"]["error"];
      // loading(false);
      // throw Exception(message);
    }
  }
}
