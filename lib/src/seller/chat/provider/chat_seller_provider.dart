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
import 'package:shared_preferences/shared_preferences.dart';

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

  Future<void> fetchListChat(BuildContext context,
      {bool withLoading = true, required String idSeller}) async {
    if (withLoading) loading(true);

    try {
      final parsed = await getRest(
        Constant.BASE_API_FULL + '/chats?user_id=$idSeller'
      );
      
      // Bungkus data menjadi format yang diharapkan (Map { seller: [...] })
      Map<String, dynamic> dataMap = {};
      if (parsed is List) {
        dataMap = {'seller': parsed};
      } else if (parsed is Map<String, dynamic> && parsed.containsKey('data')) {
        dataMap = {'seller': parsed['data']};
      } else {
        dataMap = {'seller': parsed};
      }
      
      chatSellerModel = ChatSellerModel.fromJson({'result': 'success', 'data': dataMap});
      chatSellerModel.data?.seller?.forEach((element) {
        if (element?.Buat != null)
          element?.Buat = formatDate(element.Buat ?? "");
      });
      notifyListeners();
    } catch (e) {
      if (e.toString().contains("Unauthorized")) {
        Utils.showFailed(msg: "Unauthorized");
        Future.delayed(Duration(seconds: 1)).then((value) {
          Navigator.pushReplacementNamed(context, '/login');
        });
      }
      throw Exception(e);
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
      final parsed = await getRest(
        Constant.BASE_API_FULL + '/chats?user_id=$idBuyer&seller_id=$idSeller'
      );
      
      // Jika parsed adalah List, sesuaikan ke format DetailChatSellerModel
      Map<String, dynamic> dataMap = {};
      if (parsed is List) {
        dataMap = {'result': 'success', 'data': parsed};
      } else if (parsed is Map<String, dynamic> && parsed.containsKey('data')) {
        dataMap = {'result': 'success', 'data': parsed['data']};
      } else {
        dataMap = {'result': 'success', 'data': parsed};
      }

      detailChatSellerModel = DetailChatSellerModel.fromJson(dataMap);

      notifyListeners();
    } catch (e) {
      if (e.toString().contains("Unauthorized")) {
        Utils.showFailed(msg: "Unauthorized");
        Future.delayed(Duration(seconds: 1)).then((value) {
          Navigator.pushReplacementNamed(context, '/login');
        });
      }
      throw Exception(e);
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
      final parsed = await postRest(
        Constant.BASE_API_FULL + '/chats',
        body: {
          'user_id': idPenerima, // Asumsi buyer
          'seller_id': idPengirim,
          'message': message,
          'is_seller': '1', // menandakan ini dari seller
        }
      );

      fetchDetailChat(context,
          withLoading: true, idSeller: idPengirim, idBuyer: idPenerima);
    } catch (e) {
      if (e.toString().contains("Unauthorized")) {
        Utils.showFailed(msg: "Unauthorized");
        Future.delayed(Duration(seconds: 1)).then((value) {
          Navigator.pushReplacementNamed(context, '/login');
        });
      }
      throw Exception(e);
    } finally {
      if (withLoading) loading(false);
    }
  }

  // KOMPLAIN
  RiwayatKomplainSellerModel riwayat = RiwayatKomplainSellerModel();

  Future<void> fetchRiwayat(
      {bool withLoading = false, required String order_id}) async {
    if (withLoading) loading(true);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString(Constant.kSetPrefId) ?? '1';
    // userId = "124";

    final response = await get(
        Constant.BASE_API_FULL + '/getriwayatkomplainseller',
        body: {"seller_id": userId, "order_id": order_id.toString()});

    if (response.statusCode == 201 || response.statusCode == 200) {
      riwayat = RiwayatKomplainSellerModel.fromJson(jsonDecode(response.body));
      notifyListeners();

      if (withLoading) loading(false);
      // return model;
    } else {
      final message = jsonDecode(response.body)["messages"]["error"];
      loading(false);
      throw Exception(message);
    }
  }

  Future<void> sendComplain(
      {bool withLoading = false,
      required String keterangan,
      required String penerima_id,
      required String nomor_order,
      File? file}) async {
    if (withLoading) loading(true);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString(Constant.kSetPrefId) ?? '1';
    // userId = "124";

    final http.MultipartFile? _file = (file == null)
        ? null
        : await http.MultipartFile.fromPath(
            'attachment',
            file.path,
            filename: basename(file.path),
          );

    final response = await post(Constant.BASE_API_FULL + '/balaskomplainseller',
        body: {
          "order_id": nomor_order,
          "keterangan": keterangan,
          "penerima_id": penerima_id,
          "seller_id": userId
        },
        files: _file == null ? null : [_file]);

    if (response.statusCode == 201 || response.statusCode == 200) {
      notifyListeners();
      await fetchRiwayat(order_id: nomor_order, withLoading: true);
      if (withLoading) loading(false);
    } else {
      final message = jsonDecode(response.body)["messages"]["error"];
      loading(false);
      throw Exception(message);
    }
  }
}
