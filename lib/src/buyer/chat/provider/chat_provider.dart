import 'dart:convert';

import 'package:mspeed/src/buyer/chat/model/chat_buyer_model.dart';
import 'package:mspeed/src/buyer/chat/model/detail_chat_buyer_model.dart';
import 'package:mspeed/common/base/base_controller.dart';
import 'package:mspeed/common/helper/constant.dart';
import 'package:flutter/material.dart';
import 'package:mspeed/utils/utils.dart';
import 'package:intl/intl.dart';

class ChatProvider extends BaseController with ChangeNotifier {
  ChatBuyerModel _chatBuyerModel = ChatBuyerModel();

  ChatBuyerModel get chatBuyerModel => _chatBuyerModel;

  set chatBuyerModel(ChatBuyerModel value) {
    _chatBuyerModel = value;
  }

  DetailChatBuyerModel _detailChatBuyerModel = DetailChatBuyerModel();

  DetailChatBuyerModel get detailChatBuyerModel => _detailChatBuyerModel;

  set detailChatBuyerModel(DetailChatBuyerModel value) {
    _detailChatBuyerModel = value;
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

  Future<void> fetchListChat(BuildContext context,
      {bool withLoading = true, required String idBuyer}) async {
    if (withLoading) loading(true);
    Utils.showFailed(msg: 'Fitur ini belum tersedia pada API backend.');
    if (withLoading) loading(false);
  }

  Future<void> fetchDetailChat(BuildContext context,
      {bool withLoading = true,
      required String idSeller,
      required String idUser}) async {
    if (withLoading) loading(true);
    Utils.showFailed(msg: 'Fitur ini belum tersedia pada API backend.');
    if (withLoading) loading(false);
  }

  Future<void> sendChat(BuildContext context,
      {bool withLoading = false,
      required String idPenerima,
      required String idPengirim,
      required String message}) async {
    if (withLoading) loading(true);
    Utils.showFailed(msg: 'Fitur ini belum tersedia pada API backend.');
    if (withLoading) loading(false);
  }
}
