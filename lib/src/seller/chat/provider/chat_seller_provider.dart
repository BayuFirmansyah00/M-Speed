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
      // TODO: Remove per_page=${Constant.maxPaginationPerPage} when infinite scroll is fully implemented in UI
      final parsed = await getRest(
        Constant.BASE_API_FULL + '${Constant.epChats}?user_id=$idSeller&page=$currentPage&per_page=${Constant.maxPaginationPerPage}'
      );
      
      // Mengubah respon menjadi format yang diharapkan ChatSellerModel
      // Laravel mengembalikan JSON { data: [...] } (paginasi).
      // Model Flutter kita (ChatSellerModel) sebelumnya mengharapkan `data: { seller: [...] }`.
      Map<String, dynamic> formattedJson = {};
      if (parsed is Map<String, dynamic> && parsed.containsKey('data')) {
        formattedJson = {
          'result': 'success',
          'data': {'seller': parsed['data']},
          'meta': parsed['meta']
        };
      } else {
        formattedJson = {
          'result': 'success',
          'data': {'seller': parsed}
        };
      }
      
      final responseModel = ChatSellerModel.fromJson(formattedJson);

      if (isLoadMore) {
        chatSellerModel.data?.seller?.addAll(responseModel.data?.seller ?? []);
      } else {
        chatSellerModel = responseModel;
      }

      chatSellerModel.data?.seller?.forEach((element) {
        if (element?.createdAt != null)
          element?.createdAt = formatDate(element.createdAt ?? "");
      });
      notifyListeners();
    } catch (e) {
      if (isLoadMore) currentPage--;
      if (e.toString().contains("Unauthorized")) {
        Utils.showFailed(msg: "Unauthorized");
        Future.delayed(Duration(seconds: 1)).then((value) {
          Navigator.pushReplacementNamed(context, '/login');
        });
      }
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
      final parsed = await getRest(
        Constant.BASE_API_FULL + '${Constant.epChats}?user_id=$idBuyer&seller_id=$idSeller'
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
        Constant.BASE_API_FULL + '${Constant.epChats}',
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
    String userId = await SessionHelper.getSellerId();
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
    String userId = await SessionHelper.getSellerId();
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
