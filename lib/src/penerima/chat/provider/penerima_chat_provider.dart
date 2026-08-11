
import 'package:mspeed/utils/utils.dart';
import 'dart:io';

import 'package:mspeed/common/base/base_controller.dart';

import 'package:flutter/material.dart';
import 'package:mspeed/src/penerima/chat/model/riwayat_komplain_penerima_model.dart';
import 'package:mspeed/src/seller/pesanan/model/detail_pesanan_seller_model.dart';




class PenerimaChatProvider extends BaseController with ChangeNotifier {
  RiwayatKomplainPenerimaModel riwayat = RiwayatKomplainPenerimaModel();

  Future<void> fetchRiwayat(
      {bool withLoading = false, required String order_id}) async {
    if (withLoading) loading(true);
    Utils.showFailed(msg: 'Fitur ini belum tersedia pada API backend.');
    if (withLoading) loading(false);
  }

  Future<void> sendComplain(
      {bool withLoading = false,
      required String keterangan,
      required String seller_id,
      required String nomor_order,
      File? file}) async {
    if (withLoading) loading(true);
    Utils.showFailed(msg: 'Fitur ini belum tersedia pada API backend.');
    if (withLoading) loading(false);
  }

  bool? _isTtdSuccess = null;

  bool? get isTtdSuccess => _isTtdSuccess;

  set isTtdSuccess(bool? value) {
    _isTtdSuccess = value;
  }

  Future<bool> addTtdPemesanan(
      {bool withLoading = false,
      required String transaction_id,
      required String nomor_order,
      required File image}) async {
    if (withLoading) loading(true);
    Utils.showFailed(msg: 'Fitur ini belum tersedia pada API backend.');
    if (withLoading) loading(false);
    isTtdSuccess = false;
    return false;
  }

  DetailPesananSellerModel detailPesananNew = DetailPesananSellerModel();

  Future<void> fetchDetailPesananNew(
      {bool withLoading = false,
      String seller_id = '196',
      required String parent_id}) async {
    if (withLoading) loading(true);
    Utils.showFailed(msg: 'Fitur ini belum tersedia pada API backend.');
    if (withLoading) loading(false);
  }
}
