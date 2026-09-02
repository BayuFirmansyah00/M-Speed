import 'dart:convert';
import 'package:mspeed/common/base/base_controller.dart';
import 'package:mspeed/common/helper/constant.dart';
import 'package:mspeed/src/seller/nego/model/nego_seller_model.dart';
import 'package:mspeed/utils/utils.dart';
import 'package:flutter/material.dart';

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
  bool _isProcessingAction = false;
  bool get isProcessingAction => _isProcessingAction;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /// Helper untuk membersihkan dan mem-parse input harga secara aman
  static double? parsePriceInput(String raw) {
    String cleaned = raw.trim();
    if (cleaned.isEmpty) return null;

    // Hapus simbol Rp dan spasi terlebih dahulu
    cleaned = cleaned.replaceAll(RegExp(r'[^\d.,]'), '');

    if (cleaned.contains('.') && cleaned.contains(',')) {
      // e.g. "1.250.000,50" atau "131.628,45"
      cleaned = cleaned.replaceAll('.', '').replaceAll(',', '.');
    } else if (cleaned.contains('.')) {
      // Cek apakah ada lebih dari satu titik (e.g. "1.000.000") -> pasti ribuan
      int dotCount = '.'.allMatches(cleaned).length;
      if (dotCount > 1) {
        cleaned = cleaned.replaceAll('.', '');
      } else {
        // Hanya satu titik (e.g. "350.000" vs "131628.45")
        final parts = cleaned.split('.');
        if (parts.length == 2 && parts[1].length == 3) {
          cleaned = cleaned.replaceAll('.', '');
        }
      }
    } else if (cleaned.contains(',')) {
      final parts = cleaned.split(',');
      if (parts.length == 2 && parts[1].length == 3) {
        cleaned = cleaned.replaceAll(',', '');
      } else {
        cleaned = cleaned.replaceAll(',', '.');
      }
    }

    cleaned = cleaned.replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(cleaned);
  }

  Future<void> fetchNego({bool withLoading = false, bool isLoadMore = false}) async {
    if (!isLoadMore) {
      currentPage = 1;
      _negoSellerModel = NegoSellerModel();
    } else {
      currentPage++;
    }

    if (withLoading) {
      _isLoading = true;
      notifyListeners();
    }

    try {
      final String search = searchNegoC.text.trim();
      String url = Constant.BASE_API_FULL + '/seller/v1/seller/negos?page=$currentPage&per_page=${Constant.maxPaginationPerPage}';
      if (search.isNotEmpty) {
        url += '&search=$search';
      }

      final response = await get(url);
      final parsed = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (!isLoadMore) {
          _negoSellerModel = NegoSellerModel.fromJson(parsed);
        } else {
          var moreData = NegoSellerModel.fromJson(parsed);
          if (moreData.data != null) {
            _negoSellerModel.data?.addAll(moreData.data!);
          }
          _negoSellerModel.meta = moreData.meta;
        }
      } else {
        throw Exception(parsed['message'] ?? 'Gagal memuat daftar negosiasi.');
      }
    } catch (e) {
      if (isLoadMore) currentPage--;
      Utils.showFailed(msg: e.toString());
    } finally {
      if (withLoading) {
        _isLoading = false;
      }
      notifyListeners();
    }
  }

  Future<bool> acceptOrRejectNego({
    bool withLoading = false,
    required String negoId,
    String? cartId,
    String? value,
    bool isAccept = true,
  }) async {
    if (_isProcessingAction) return false;
    _isProcessingAction = true;
    notifyListeners();

    if (isAccept) {
      if (withLoading) loading(true);
      try {
        final response = await post(
          Constant.BASE_API_FULL + '/seller/v1/seller/negos/$negoId/approve',
          body: {
            'seller_note': 'Disetujui oleh penjual',
          },
        );
        final parsed = jsonDecode(response.body);

        if (response.statusCode == 200 || response.statusCode == 201) {
          // Optimistic local update
          final itemIndex = _negoSellerModel.data?.indexWhere((e) => e.id?.toString() == negoId.toString()) ?? -1;
          if (itemIndex != -1 && _negoSellerModel.data != null) {
            _negoSellerModel.data![itemIndex].isSellerDeal = true;
            if (_negoSellerModel.data![itemIndex].isBuyerDeal == true) {
              _negoSellerModel.data![itemIndex].cart?.negoStatus = 'DEAL';
            }
          }
          Utils.showSuccess(msg: 'Nego berhasil disetujui.');
          return true;
        } else {
          throw Exception(parsed['message'] ?? 'Gagal menyetujui nego.');
        }
      } catch (e) {
        Utils.showFailed(msg: e.toString());
        return false;
      } finally {
        _isProcessingAction = false;
        if (withLoading) loading(false);
        notifyListeners();
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
        // Hapus item secara lokal agar langsung hilang dari UI
        _negoSellerModel.data?.removeWhere((item) => item.id?.toString() == negoId.toString());
        Utils.showSuccess(msg: 'Nego berhasil ditolak.');
        return true;
      } else {
        throw Exception(parsed['message'] ?? 'Gagal menolak nego.');
      }
    } catch (e) {
      Utils.showFailed(msg: e.toString());
      return false;
    } finally {
      _isProcessingAction = false;
      if (withLoading) loading(false);
      notifyListeners();
    }
  }

  Future<bool> requestNegoUlang({
    bool withLoading = false,
    required String cartId,
  }) async {
    if (_isProcessingAction) return false;

    final double? value = parsePriceInput(negoHargaC.text);
    if (value == null || value <= 0) {
      Utils.showFailed(msg: 'Masukkan nominal harga nego yang valid (lebih dari 0).');
      return false;
    }

    _isProcessingAction = true;
    if (withLoading) loading(true);
    notifyListeners();

    try {
      final response = await post(
        Constant.BASE_API_FULL + '/seller/v1/seller/carts/$cartId/counter-nego',
        body: {'value': value.toString()},
      );
      final parsed = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        Utils.showSuccess(msg: 'Tawaran harga counter berhasil dikirim.');
        negoHargaC.clear();
        return true;
      } else {
        throw Exception(parsed['message'] ?? 'Gagal mengirim counter nego.');
      }
    } catch (e) {
      Utils.showFailed(msg: e.toString());
      return false;
    } finally {
      _isProcessingAction = false;
      if (withLoading) loading(false);
      notifyListeners();
    }
  }
}
