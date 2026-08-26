import 'dart:async';


import 'package:mspeed/common/base/base_controller.dart';
import 'package:mspeed/common/helper/constant.dart';
// import 'package:mspeed/src/admin/home/model/dashboard_admin_model.dart';
import 'package:mspeed/src/admin/transaksi/model/dpp_admin_model.dart';
import 'package:mspeed/src/buyer/transaction/model/detail_tansaction_buyer_model.dart';
import 'package:flutter/material.dart';
import 'package:mspeed/core/network/api_client.dart';
import 'package:dio/dio.dart';
import 'package:mspeed/utils/utils.dart';
import 'package:mspeed/common/component/custom_navigator.dart';

class TransactionAdminProvider extends BaseController with ChangeNotifier {
  final searchC = TextEditingController();
  DppAdminModel dpp = DppAdminModel();

  Future<void> fetchList(
      {bool withLoading = false,
      String sellerId = "148",
      String search = ''}) async {
    if (withLoading) loading(true);

    try {
      final queryParams = <String, String>{};
      if (search.isNotEmpty) {
        queryParams['search'] = search;
      }

      final parsed = await getRest(
        '${Constant.BASE_API_FULL}/audit/v1/admin/dpp',
        body: queryParams,
      );
      if (parsed == null) {
        loading(false);
        return;
      }

      dpp = DppAdminModel.fromJson(parsed);

      loading(false);
    } catch (e) {
      loading(false);
      throw Exception(e.toString());
    }
  }

  final searchOrderC = TextEditingController();
  List<DetailTransaksiBuyerModelDataParentOrderModel> orders = [];

  Future<void> fetchList2(
      {bool withLoading = false,
      String search = ''}) async {
    if (withLoading) loading(true);

    try {
      final queryParams = <String, String>{
        'search': search,
      };

      final parsed = await getRest(
        '${Constant.BASE_API_FULL}/audit/v1/admin/transactions',
        body: queryParams,
      );
      if (parsed == null) {
        loading(false);
        return;
      }

      orders.clear();

      if (parsed['data'] != null) {
        for (var item in parsed['data']) {
          orders.add(DetailTransaksiBuyerModelDataParentOrderModel(
            ID: item['id']?.toString(),
            nomorOrder: item['order_number']?.toString(),
            status: item['payment_status']?.toString(),
            SellerNama: item['seller_snapshot']?['name']?.toString(),
            nama: item['actors_snapshot']?['buyer']?['name']?.toString(),
            PenerimaNama: item['actors_snapshot']?['recipient']?['name']?.toString(),
            total: item['payment_summary']?['grand_total']?.toString() ?? '0',
            Created: item['created_at']?.toString(),
          ));
        }
      }

      loading(false);
    } catch (e) {
      loading(false);
      throw Exception(e.toString());
    }
  }

  Future<void> verifyOrder(BuildContext context, String orderId) async {
    try {
      loading(true);
      final response = await ApiClient().dio.post('/finance/v1/finance/orders/$orderId/verify');
      if (response.statusCode == 200 || response.statusCode == 201) {
        final message = response.data['message'] ?? 'Order berhasil diverifikasi';
        await Utils.showSuccess(msg: message);
        await fetchList2(withLoading: true); // Refresh list order
        CusNav.nPop(context);
      }
      loading(false);
    } on DioException catch (e) {
      loading(false);
      final message = e.response?.data['message'] ?? 'Gagal verifikasi order';
      Utils.showFailed(msg: message);
    } catch (e) {
      loading(false);
      Utils.showFailed(msg: 'Terjadi kesalahan: $e');
    }
  }

  Future<void> payOrder(BuildContext context, String orderId) async {
    try {
      loading(true);
      final response = await ApiClient().dio.post('/finance/v1/finance/orders/$orderId/pay');
      if (response.statusCode == 200 || response.statusCode == 201) {
        final message = response.data['message'] ?? 'Order berhasil dibayar';
        await Utils.showSuccess(msg: message);
        await fetchList2(withLoading: true); // Refresh list order
        CusNav.nPop(context);
      }
      loading(false);
    } on DioException catch (e) {
      loading(false);
      final message = e.response?.data['message'] ?? 'Gagal membayar order';
      Utils.showFailed(msg: message);
    } catch (e) {
      loading(false);
      Utils.showFailed(msg: 'Terjadi kesalahan: $e');
    }
  }
}
