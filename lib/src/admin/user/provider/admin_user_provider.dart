import 'dart:async';
import 'dart:convert';

import 'package:mspeed/common/base/base_controller.dart';
import 'package:mspeed/common/base/base_response.dart';
import 'package:mspeed/common/helper/constant.dart';
import 'package:mspeed/src/admin/home/model/buyer_admin_model.dart';
import 'package:mspeed/src/admin/home/model/seller_admin_model.dart';
import 'package:mspeed/src/admin/user/model/keuangan_admin_model.dart';
import 'package:mspeed/src/admin/user/model/penerima_admin_model.dart';
import 'package:mspeed/src/admin/user/view/user_data_admin_view.dart';
import 'package:mspeed/src/auth/model/login_model.dart';
import 'package:mspeed/src/admin/user/model/manager_admin_model.dart';
import 'package:mspeed/src/admin/user/model/audit_admin_model.dart';
import 'package:flutter/material.dart';
import 'package:mspeed/utils/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminUserProvider extends BaseController with ChangeNotifier {
  List<UserData> userData = [];
  final searchC = TextEditingController();
  String? id;

  Future<void> changeSession(BuildContext context, String id) async {
    try {
      loading(true);
      FocusManager.instance.primaryFocus?.unfocus();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      Map<String, String> param = {'id': id};
      final response = await post(
        Constant.BASE_API_FULL + '/changesession',
        body: param,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final model = LoginModel.fromJson(jsonDecode(response.body));

        // set to shared preferences
        await prefs.setString(Constant.kSetPrefId, "${model.jenis?.ID ?? 0}");
        await prefs.setString(
          Constant.kSetPrefToken,
          model.jenis?.password ?? '',
        );
        await prefs.setString(
          Constant.kSetPrefFirstName,
          model.jenis?.firstname ?? '',
        );
        await prefs.setString(
          Constant.kSetPrefLastName,
          model.jenis?.lastname ?? '',
        );
        await prefs.setString(Constant.kSetPrefRoles, model.jenis?.jenis ?? '');
        await prefs.setBool(
          Constant.kSetPrefIsAdmin,
          model.jenis?.isAdmin ?? false,
        );
        await prefs.setString(
          Constant.kSetPrefSubditId,
          model.jenis?.subditId ?? '',
        );

        if (model.jenis?.jenis == 'SELLER')
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/sellerHome',
            (route) => false,
          );
        else if (model.jenis?.jenis == 'PENERIMA')
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/penerimaHome',
            (route) => false,
          );
        else if (model.jenis?.jenis == 'KEUANGAN')
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/keuanganHome',
            (route) => false,
          );
        else if (model.jenis?.jenis == 'ADMIN')
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/adminHome',
            (route) => false,
          );
        else
          Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);

        loading(false);
      } else {
        final message = jsonDecode(response.body)["messages"]["error"];
        loading(false);
        Utils.showFailed(msg: message);
        // return LoginModel();
        throw Exception(message);
      }
    } catch (e) {
      loading(false);
      Utils.showFailed(msg: '$e');
    }
  }

  Future<void> backToAdmin(BuildContext context) async {
    try {
      loading(true);
      FocusManager.instance.primaryFocus?.unfocus();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final response = await post(Constant.BASE_API_FULL + '/backtoadmin');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final model = LoginModel.fromJson(jsonDecode(response.body));

        // set to shared preferences
        await prefs.setString(Constant.kSetPrefId, "${model.jenis?.ID ?? 0}");
        await prefs.setString(
          Constant.kSetPrefToken,
          model.jenis?.password ?? '',
        );
        await prefs.setString(
          Constant.kSetPrefFirstName,
          model.jenis?.firstname ?? '',
        );
        await prefs.setString(
          Constant.kSetPrefLastName,
          model.jenis?.lastname ?? '',
        );
        await prefs.setString(Constant.kSetPrefRoles, model.jenis?.jenis ?? '');
        await prefs.setBool(
          Constant.kSetPrefIsAdmin,
          model.jenis?.isAdmin ?? false,
        );
        await prefs.setString(
          Constant.kSetPrefSubditId,
          model.jenis?.subditId ?? '',
        );

        // log("JENIS : ${model.jenis?.jenis}");
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/adminHome',
          (route) => false,
        );

        loading(false);
      } else {
        final message = jsonDecode(response.body)["messages"]["error"];
        loading(false);
        Utils.showFailed(msg: message);
        // return LoginModel();
        throw Exception(message);
      }
    } catch (e) {
      loading(false);
      Utils.showFailed(msg: '$e');
    }
  }

  BuyerAdminModel buyerAdminModel = BuyerAdminModel();
  Future<void> fetchBuyers({
    bool withLoading = false,
    String search = '',
  }) async {
    if (withLoading) loading(true);
    Map<String, String> param = {};
    if (search.isNotEmpty) param.addAll({'search': search});
    if (id != null) param.addAll({'buyer_id': id ?? '0'});

    final response = await get(
      Constant.BASE_API_FULL + '/getbuyeradmin',
      body: param,
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      userData.clear();
      buyerAdminModel = BuyerAdminModel.fromJson(jsonDecode(response.body));
      buyerAdminModel.data?.forEach((v) {
        userData.add(
          UserData(
            name1: v?.firstname,
            name2: v?.lastname,
            email: v?.email,
            id: v?.ID,
            alamat: v?.alamat,
          ),
        );
      });

      notifyListeners();

      if (withLoading) loading(false);
    } else {
      final message = jsonDecode(response.body)["messages"]["error"];
      loading(false);
      throw Exception(message);
    }
  }

  Future<void> deleteBuyer({bool withLoading = false, String? buyerId}) async {
    if (withLoading) loading(true);

    final response = await post(
      Constant.BASE_API_FULL + '/hapusbuyeradmin',
      body: {'buyer_id': buyerId},
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final model = BaseResponse.from(response);
      notifyListeners();
      await Utils.showSuccess(msg: model.message);
      await Future.delayed(Duration(seconds: 2), () {});
      if (withLoading) loading(false);
      fetchSellers(withLoading: true);
    } else {
      final message = jsonDecode(response.body)["messages"]["error"];
      loading(false);
      throw Exception(message);
    }
  }

  var sellerAdminModel = SellerAdminModel();
  Future<void> fetchSellers({
    bool withLoading = false,
    String search = '',
  }) async {
    if (withLoading) loading(true);
    Map<String, String> param = {};
    if (search.isNotEmpty) param.addAll({'search': search});
    if (id != null) param.addAll({'seller_id': id ?? '0'});

    final response = await get(
      Constant.BASE_API_FULL + '/getselleradmin',
      body: param,
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      userData.clear();
      sellerAdminModel = SellerAdminModel.fromJson(jsonDecode(response.body));
      sellerAdminModel.data?.forEach((v) {
        userData.add(
          UserData(
            name1: v?.nama,
            name2: v?.namaPemilik,
            email: v?.email,
            id: v?.ID,
            alamat: v?.alamat,
            status: v?.status,
          ),
        );
      });

      notifyListeners();

      if (withLoading) loading(false);
    } else {
      final message = jsonDecode(response.body)["messages"]["error"];
      loading(false);
      throw Exception(message);
    }
  }

  Future<void> deleteSeller({
    bool withLoading = false,
    String id = "148",
  }) async {
    if (withLoading) loading(true);

    final response = await post(
      Constant.BASE_API_FULL + '/hapusselleradmin',
      body: {'seller_id': id},
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final model = BaseResponse.from(response);
      notifyListeners();
      await Utils.showSuccess(msg: model.message);
      await Future.delayed(Duration(seconds: 2), () {});
      if (withLoading) loading(false);
      fetchSellers(withLoading: true);
    } else {
      final message = jsonDecode(response.body)["messages"]["error"];
      loading(false);
      throw Exception(message);
    }
  }

  var keuanganAdminModel = KeuanganAdminModel();
  Future<void> fetchKeuangan({
    bool withLoading = false,
    String search = '',
  }) async {
    if (withLoading) loading(true);
    Map<String, String> param = {};
    if (search.isNotEmpty) param.addAll({'search': search});
    if (id != null) param.addAll({'keuangan_id': id ?? '0'});

    final response = await get(
      Constant.BASE_API_FULL + '/getkeuanganadmin',
      body: param,
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      userData.clear();
      keuanganAdminModel = KeuanganAdminModel.fromJson(
        jsonDecode(response.body),
      );
      keuanganAdminModel.data?.forEach((v) {
        userData.add(
          UserData(
            name1: v?.firstname,
            name2: v?.lastname,
            email: v?.email,
            id: v?.ID,
            alamat: v?.alamat,
          ),
        );
      });

      notifyListeners();

      if (withLoading) loading(false);
    } else {
      final message = jsonDecode(response.body)["messages"]["error"];
      loading(false);
      throw Exception(message);
    }
  }

  Future<void> deleteKeuangan({
    bool withLoading = false,
    String keuanganId = "148",
  }) async {
    if (withLoading) loading(true);

    final response = await post(
      Constant.BASE_API_FULL + '/hapuskeuanganadmin',
      body: {'keuangan_id': keuanganId},
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final model = BaseResponse.from(response);
      notifyListeners();
      await Utils.showSuccess(msg: model.message);
      await Future.delayed(Duration(seconds: 2), () {});
      if (withLoading) loading(false);
      fetchKeuangan(withLoading: true);
    } else {
      final message = jsonDecode(response.body)["messages"]["error"];
      loading(false);
      throw Exception(message);
    }
  }

  var penerimaAdminModel = PenerimaAdminModel();
  Future<void> fetchPenerima({
    bool withLoading = false,
    String search = '',
  }) async {
    if (withLoading) loading(true);
    Map<String, String> param = {};
    if (search.isNotEmpty) param.addAll({'search': search});
    if (id != null) param.addAll({'penerima_id': id ?? '0'});

    final response = await get(
      Constant.BASE_API_FULL + '/getpenerimaadmin',
      body: param,
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      userData.clear();
      penerimaAdminModel = PenerimaAdminModel.fromJson(
        jsonDecode(response.body),
      );
      penerimaAdminModel.data?.forEach((v) {
        userData.add(
          UserData(
            name1: v?.firstname,
            name2: v?.lastname,
            email: v?.email,
            id: v?.ID,
            alamat: v?.alamat,
          ),
        );
      });

      notifyListeners();

      if (withLoading) loading(false);
    } else {
      final message = jsonDecode(response.body)["messages"]["error"];
      loading(false);
      throw Exception(message);
    }
  }

  Future<void> deletePenerima({
    bool withLoading = false,
    String penerimaId = "148",
  }) async {
    if (withLoading) loading(true);

    final response = await post(
      Constant.BASE_API_FULL + '/hapuspenerimaadmin',
      body: {'penerima_id': penerimaId},
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final model = BaseResponse.from(response);
      notifyListeners();
      await Utils.showSuccess(msg: model.message);
      await Future.delayed(Duration(seconds: 2), () {});
      if (withLoading) loading(false);
      fetchPenerima(withLoading: true);
    } else {
      final message = jsonDecode(response.body)["messages"]["error"];
      loading(false);
      throw Exception(message);
    }
  }
  
var managerAdminModel = ManagerAdminModel();
Future<void> fetchManager({
  bool withLoading = false,
  String search = '',
}) async {
  if (withLoading) loading(true);
  Map<String, String> param = {};
  if (search.isNotEmpty) param.addAll({'search': search});
  if (id != null) param.addAll({'manager_id': id ?? '0'});
  final response = await get(
    Constant.BASE_API_FULL + '/getmanageradmin',
    body: param,
  );
 
  if (response.statusCode == 201 || response.statusCode == 200) {
    userData.clear();
    managerAdminModel = ManagerAdminModel.fromJson(
      jsonDecode(response.body),
    );
    managerAdminModel.data?.forEach((v) {
      userData.add(
        UserData(
          name1: v?.firstname,
          name2: v?.lastname,
          email: v?.email,
          id: v?.ID,
          alamat: v?.alamat,
        ),
      );
    });
 
    notifyListeners();
 
    if (withLoading) loading(false);
  } else {
    final message = jsonDecode(response.body)["messages"]["error"];
    loading(false);
    throw Exception(message);
  }
}

var auditAdminModel = AuditAdminModel();
Future<void> fetchAudit({
  bool withLoading = false,
  String search = '',
}) async {
  if (withLoading) loading(true);
  Map<String, String> param = {};
  if (search.isNotEmpty) param.addAll({'search': search});
 
  // TODO KONFIRMASI KE BACKEND: endpoint 'getauditadmin' ini ASUMSI
  final response = await get(
    Constant.BASE_API_FULL + '/getauditadmin',
    body: param,
  );
 
  if (response.statusCode == 201 || response.statusCode == 200) {
    userData.clear();
    auditAdminModel = AuditAdminModel.fromJson(
      jsonDecode(response.body),
    );
    auditAdminModel.data?.forEach((v) {
      userData.add(
        UserData(
          // NOTE: reuse UserData class -- Audit cuma punya username & fullname,
          // jadi dipetakan ke name1/name2 seadanya. Kalau ternyata butuh tampilan
          // khusus (2 kolom saja: username, Full Name), pertimbangkan bikin
          // widget list item terpisah untuk Audit, bukan reuse produkItem().
          name1: v?.username,
          name2: v?.fullname,
          id: v?.ID,
        ),
      );
    });
 
    notifyListeners();
 
    if (withLoading) loading(false);
  } else {
    final message = jsonDecode(response.body)["messages"]["error"];
    loading(false);
    throw Exception(message);
  }
}
 
Future<void> deleteManager({
  bool withLoading = false,
  String managerId = "0",
}) async {
  if (withLoading) loading(true);
 
  final response = await post(
    Constant.BASE_API_FULL + '/hapusmanageradmin',
    body: {'manager_id': managerId},
  );
 
  if (response.statusCode == 201 || response.statusCode == 200) {
    final model = BaseResponse.from(response);
    notifyListeners();
    await Utils.showSuccess(msg: model.message);
    await Future.delayed(Duration(seconds: 2), () {});
    if (withLoading) loading(false);
    fetchManager(withLoading: true);
  } else {
    final message = jsonDecode(response.body)["messages"]["error"];
    loading(false);
    throw Exception(message);
  }
}
}
