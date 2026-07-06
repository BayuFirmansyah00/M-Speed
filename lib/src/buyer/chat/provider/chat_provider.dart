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

    final response = await get(Constant.BASE_API_FULL + '/getchatbuyer',
        body: {'user_id': idBuyer});

    if (response.statusCode == 201 || response.statusCode == 200) {
      chatBuyerModel = ChatBuyerModel.fromJson(jsonDecode(response.body));
      chatBuyerModel.data?.seller?.forEach((element) {
        element?.Buat = formatDate(element.Buat ?? "");
      });

      notifyListeners();
      if (withLoading) loading(false);
    } else {
      final message = jsonDecode(response.body)["messages"]["error"];
      loading(false);
      if (message.toString().contains("Unauthorized")) {
        Utils.showFailed(msg: "Unauthorized");
        Future.delayed(Duration(seconds: 1)).then((value) {
          Navigator.pushReplacementNamed(context, '/login');
        });
      }
      throw Exception(message);
    }
  }

  Future<void> fetchDetailChat(BuildContext context,
      {bool withLoading = true,
      required String idSeller,
      required String idUser}) async {
    detailChatBuyerModel = DetailChatBuyerModel();

    if (withLoading) loading(true);

    final response = await get(Constant.BASE_API_FULL + '/getdetailchatbuyer',
        body: {'user_id': idUser, 'seller_id': idSeller});

    if (response.statusCode == 201 || response.statusCode == 200) {
      detailChatBuyerModel =
          DetailChatBuyerModel.fromJson(jsonDecode(response.body));
      // detailChatBuyerModel.data?.seller?.forEach((element) {
      //   element?.Buat = formatDate(element.Buat ?? "");
      // });

      notifyListeners();
      if (withLoading) loading(false);
    } else {
      final message = jsonDecode(response.body)["messages"]["error"];
      loading(false);
      if (message.toString().contains("Unauthorized")) {
        Utils.showFailed(msg: "Unauthorized");
        Future.delayed(Duration(seconds: 1)).then((value) {
          Navigator.pushReplacementNamed(context, '/login');
        });
      }
      throw Exception(message);
    }
  }

  Future<void> sendChat(BuildContext context,
      {bool withLoading = false,
      required String idPenerima,
      required String idPengirim,
      required String message}) async {
    if (withLoading) loading(true);

    final response = await post(Constant.BASE_API_FULL + '/sendmessagebuyer',
        body: {
          'penerima_id': idPenerima,
          'pengirim_id': idPengirim,
          'pesan': message
        });

    if (response.statusCode == 201 || response.statusCode == 200) {
      // notifyListeners();
      fetchDetailChat(context,
          withLoading: true, idSeller: idPenerima, idUser: idPengirim);
      // if (withLoading) loading(false);
    } else {
      final message = jsonDecode(response.body)["messages"]["error"];
      loading(false);
      if (message.toString().contains("Unauthorized")) {
        Utils.showFailed(msg: "Unauthorized");
        Future.delayed(Duration(seconds: 1)).then((value) {
          Navigator.pushReplacementNamed(context, '/login');
        });
      }
      throw Exception(message);
    }
  }
}
