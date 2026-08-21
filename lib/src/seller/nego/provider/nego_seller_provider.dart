import 'dart:convert';
import 'package:mspeed/common/base/base_controller.dart';
import 'package:mspeed/common/helper/constant.dart';
import 'package:mspeed/src/seller/nego/model/nego_seller_model.dart';
import 'package:mspeed/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mspeed/common/helper/session_helper.dart';

class NegoSellerProvider extends BaseController with ChangeNotifier {
  NegoSellerModel _negoSellerModel = NegoSellerModel();
  NegoSellerModel get negoSellerModel => _negoSellerModel;
  set negoSellerModel(NegoSellerModel value) {
    _negoSellerModel = value;
    notifyListeners();
  }

  TextEditingController negoHargaC = TextEditingController();
  FocusNode negoHargaN = FocusNode();
  TextEditingController searchNegoC = TextEditingController();

  int currentPage = 1;

  Future<void> fetchNego({bool withLoading = false, bool isLoadMore = false}) async {
    if (!isLoadMore) {
      currentPage = 1;
      _negoSellerModel = NegoSellerModel();
    } else {
      currentPage++;
    }

    if (withLoading) loading(true);

    try {
      final String search = searchNegoC.text;
      String url = Constant.BASE_API_FULL + '/seller/v1/seller/negos?page=$currentPage&per_page=${Constant.maxPaginationPerPage}';
      if (search.isNotEmpty) {
        url += '&search=$search';
      }

      final response = await get(url);
      final parsed = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (!isLoadMore) {
          negoSellerModel = NegoSellerModel.fromJson(parsed);
        } else {
          var moreData = NegoSellerModel.fromJson(parsed);
          if (moreData.data != null) {
            _negoSellerModel.data?.addAll(moreData.data!);
          }
          _negoSellerModel.meta = moreData.meta;
          notifyListeners();
        }
      } else {
        throw Exception(parsed['message'] ?? 'Failed to load negos');
      }
    } catch (e) {
      if (isLoadMore) currentPage--;
      Utils.showFailed(msg: e.toString());
    } finally {
      if (withLoading) loading(false);
    }
  }

  Future<bool> acceptOrRejectNego({
    bool withLoading = false,
    required String negoId,
    String? cartId,
    String? value,
    bool isAccept = true,
  }) async {
    if (isAccept) {
      if (cartId == null || value == null) {
        Utils.showFailed(msg: 'Data negosiasi tidak lengkap.');
        return false;
      }
      
      if (withLoading) loading(true);
      try {
        final response = await post(
          Constant.BASE_API_FULL + '/seller/v1/seller/negos/$negoId/approve',
          body: {
            'cart_id': cartId,
            'value': value,
          },
        );
        final parsed = jsonDecode(response.body);

        if (response.statusCode == 200 || response.statusCode == 201) {
          Utils.showSuccess(msg: 'Nego berhasil disetujui.');
          return true;
        } else {
          throw Exception(parsed['message'] ?? 'Gagal menyetujui nego.');
        }
      } catch (e) {
        Utils.showFailed(msg: e.toString());
        return false;
      } finally {
        if (withLoading) loading(false);
      }
    }

    // Aksi Tolak/Hapus (Delete)
    if (withLoading) loading(true);
    try {
      final response = await delete(
        Constant.BASE_API_FULL + '/seller/v1/seller/negos/$negoId',
      );
      final parsed = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 204) {
        Utils.showSuccess(msg: 'Nego berhasil ditolak/dihapus.');
        return true;
      } else {
        throw Exception(parsed['message'] ?? 'Gagal menolak nego.');
      }
    } catch (e) {
      Utils.showFailed(msg: e.toString());
      return false;
    } finally {
      if (withLoading) loading(false);
    }
  }

  Future<bool> requestNegoUlang({
    bool withLoading = false,
    required String cartId, // Menggunakan cartId sesuai API MSpeed
  }) async {
    final valueText = negoHargaC.text.replaceAll('.', '');
    if (valueText.isEmpty) {
      Utils.showFailed(msg: 'Harga tidak valid.');
      return false;
    }
    final double? value = double.tryParse(valueText);
    if (value == null || value < 0) {
      Utils.showFailed(msg: 'Harga tidak valid.');
      return false;
    }

    if (withLoading) loading(true);
    try {
      final response = await post(
        Constant.BASE_API_FULL + '/seller/v1/seller/carts/$cartId/counter-nego',
        body: {'value': value.toString()},
      );
      final parsed = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        Utils.showSuccess(msg: 'Harga counter berhasil dikirim.');
        negoHargaC.clear();
        return true;
      } else {
        throw Exception(parsed['message'] ?? 'Gagal mengirim counter nego.');
      }
    } catch (e) {
      Utils.showFailed(msg: e.toString());
      return false;
    } finally {
      if (withLoading) loading(false);
    }
  }
}
