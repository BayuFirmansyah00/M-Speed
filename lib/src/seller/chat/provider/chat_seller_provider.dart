import 'dart:convert';
import 'dart:io';

import 'package:mspeed/src/seller/chat/model/chat_seller_model.dart';
import 'package:mspeed/src/seller/chat/model/detail_chat_seller_model.dart';
import 'package:mspeed/common/base/base_controller.dart';
import 'package:mspeed/common/helper/constant.dart';
import 'package:flutter/material.dart';
import 'package:mspeed/src/seller/chat/model/riwayat_komplain_seller_model.dart';
import 'package:mspeed/utils/utils.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:mspeed/common/helper/session_helper.dart';

class ChatSellerProvider extends BaseController with ChangeNotifier {
  ChatSellerModel _chatSellerModel = ChatSellerModel();

  ChatSellerModel get chatSellerModel => _chatSellerModel;

  set chatSellerModel(ChatSellerModel value) {
    _chatSellerModel = value;
  }

  DetailChatSellerModel _detailChatSellerModel = DetailChatSellerModel();

  DetailChatSellerModel get detailChatSellerModel => _detailChatSellerModel;

  set detailChatSellerModel(DetailChatSellerModel value) {
    _detailChatSellerModel = value;
  }

  String formatDate(String dateString) {
    DateTime date = DateTime.parse(dateString);
    DateTime now = DateTime.now();
    DateFormat formatter;

    // Check if the date is from the current year
    if (date.year == now.year) {
      formatter = DateFormat('d MMM');
    } else {
      formatter = DateFormat('d MMM yyyy');
    }

    return formatter.format(date);
  }

  int currentPage = 1;

  Future<void> fetchListChat(BuildContext context,
      {bool withLoading = true, required String idSeller, bool isLoadMore = false}) async {
    
    if (!isLoadMore) {
      chatSellerModel = ChatSellerModel();
      currentPage = 1;
    } else {
      currentPage++;
    }

    if (withLoading) loading(true);

    try {
      throw Exception('Fitur ini belum tersedia pada API backend.');
    } catch (e) {
      if (isLoadMore) currentPage--;
      Utils.showFailed(msg: e.toString());
    } finally {
      if (withLoading) loading(false);
    }
  }

  Future<void> fetchDetailChat(BuildContext context,
      {bool withLoading = true,
      required String idSeller,
      required String idBuyer}) async {
    detailChatSellerModel = DetailChatSellerModel();

    if (withLoading) loading(true);

    try {
      throw Exception('Fitur ini belum tersedia pada API backend.');
    } catch (e) {
      // throw Exception(e);
    } finally {
      if (withLoading) loading(false);
    }
  }

  Future<void> sendChat(BuildContext context,
      {bool withLoading = false,
      required String idPenerima,
      required String idPengirim,
      required String message}) async {
    if (withLoading) loading(true);

    try {
      throw Exception('Fitur ini belum tersedia pada API backend.');
    } catch (e) {
      Utils.showFailed(msg: e.toString());
    } finally {
      if (withLoading) loading(false);
    }
  }

  // KOMPLAIN
  RiwayatKomplainSellerModel riwayat = RiwayatKomplainSellerModel();

  Future<void> fetchRiwayat(
      {bool withLoading = false, required String order_id}) async {
    if (withLoading) loading(true);
    Utils.showFailed(msg: 'Fitur ini belum tersedia pada API backend.');
    if (withLoading) loading(false);
  }

  Future<void> sendComplain(
      {bool withLoading = false,
      required String keterangan,
      required String penerima_id,
      required String nomor_order,
      File? file}) async {
    if (withLoading) loading(true);
    Utils.showFailed(msg: 'Fitur ini belum tersedia pada API backend.');
    if (withLoading) loading(false);
  }
}
