import 'dart:async';
import 'dart:developer';

import 'package:mspeed/common/base/base_controller.dart';
import 'package:mspeed/common/helper/constant.dart';
import 'package:mspeed/src/admin/user/view/user_data_admin_view.dart';
import 'package:flutter/material.dart';
import 'package:mspeed/utils/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:mspeed/core/network/api_client.dart';

class AdminUserProvider extends BaseController with ChangeNotifier {
  List<UserData> userData = [];
  int currentPage = 1;
  bool hasMore = true;
  bool isLoadingMore = false;
  final searchC = TextEditingController();
  String? id;

  Future<void> changeSession(BuildContext context, String id) async {
    try {
      loading(true);
      FocusManager.instance.primaryFocus?.unfocus();
      SharedPreferences prefs = await SharedPreferences.getInstance();

      // Simpan token admin asli sebelum impersonate
      final currentToken = prefs.getString(Constant.kSetPrefToken) ?? '';
      await prefs.setString('admin_original_token', currentToken);

      // POST /api/aimpersonate/{id} — Laravel Sanctum Impersonate
      final response = await ApiClient().dio.post('/aimpersonate/$id');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data['data'] ?? {};
        final impersonatedUser = data['impersonated_user'] ?? {};
        final accessToken = data['access_token']?.toString() ?? '';
        final role = impersonatedUser['role']?.toString().toUpperCase() ?? '';

        // Simpan token impersonate baru
        await prefs.setString(Constant.kSetPrefToken, accessToken);
        await prefs.setString(Constant.kSetPrefId, impersonatedUser['id']?.toString() ?? '');
        await prefs.setString(Constant.kSetPrefEmail, impersonatedUser['email']?.toString() ?? '');
        await prefs.setString(Constant.kSetPrefRoles, role);
        await prefs.setBool(Constant.kSetPrefIsAdmin, false);

        log('IMPERSONATE SUCCESS: role=$role, token=$accessToken');

        // Navigasi berdasarkan role target
        if (role == 'SELLER') {
          Navigator.pushNamedAndRemoveUntil(context, '/sellerHome', (route) => false);
        } else if (role == 'PENERIMA' || role == 'RECEIVER') {
          Navigator.pushNamedAndRemoveUntil(context, '/penerimaHome', (route) => false);
        } else if (role == 'KEUANGAN' || role == 'FINANCE') {
          Navigator.pushNamedAndRemoveUntil(context, '/keuanganHome', (route) => false);
        } else if (role == 'BUYER') {
          Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
        } else {
          Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
        }

        loading(false);
      } else {
        loading(false);
        Utils.showFailed(msg: 'Gagal melakukan impersonate');
      }
    } on DioException catch (e) {
      loading(false);
      final msg = e.response?.data?['message'] ?? 'Gagal melakukan impersonate';
      Utils.showFailed(msg: msg);
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

      // POST /api/impersonate/stop — revoke token impersonate
      try {
        await ApiClient().dio.post('/impersonate/stop');
      } catch (_) {
        // Token impersonate mungkin sudah expired, lanjutkan saja
      }

      // Restore token admin asli
      final adminToken = prefs.getString('admin_original_token') ?? '';
      if (adminToken.isNotEmpty) {
        await prefs.setString(Constant.kSetPrefToken, adminToken);
        await prefs.remove('admin_original_token');
      }

      // Set kembali ke role admin
      await prefs.setString(Constant.kSetPrefRoles, 'ADMIN');
      await prefs.setBool(Constant.kSetPrefIsAdmin, true);

      log('BACK TO ADMIN: token restored');

      Navigator.pushNamedAndRemoveUntil(
        context,
        '/adminHome',
        (route) => false,
      );

      loading(false);
    } catch (e) {
      loading(false);
      Utils.showFailed(msg: '$e');
    }
  }

  Future<void> fetchBuyers({bool withLoading = false, String search = '', int page = 1}) async {
        if (page == 1) {
      if (withLoading) loading(true);
      userData.clear();
      hasMore = true;
      currentPage = 1;
    } else {
      isLoadingMore = true;
    }
    notifyListeners();
    Map<String, dynamic> param = {'page': page};
    
    if (search.isNotEmpty) param.addAll({'search': search});

    try {
      final response = await ApiClient().dio.get(
        '/audit/v1/admin/buyers',
        queryParameters: param,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
                final dataList = response.data['data'] as List<dynamic>? ?? [];
        final _meta = response.data['meta'];
        if (_meta != null) {
          currentPage = _meta['current_page'] ?? 1;
          final lastPage = _meta['last_page'] ?? 1;
          hasMore = currentPage < lastPage;
        } else {
          hasMore = dataList.isNotEmpty;
        }
    
        
        for (var item in dataList) {
          final uData = item['user_data'] ?? {};
          userData.add(
            UserData(
              name1: uData['first_name']?.toString() ?? '',
              name2: uData['last_name']?.toString() ?? '',
              email: item['email']?.toString() ?? '',
              id: item['id']?.toString() ?? '',
              alamat: item['full_address']?.toString() ?? '',
              status: item['status']?.toString() == 'active' ? '1' : '0',
            ),
          );
        }

        notifyListeners();
      } else {
        throw Exception("Gagal memuat data buyer");
      }
    } catch (e) {
      debugPrint("fetchBuyers Error: $e");
      Utils.showFailed(msg: "Gagal memuat data dari server (500)");
    } finally {
      if (page == 1) {
        if (withLoading) loading(false);
      } else {
        isLoadingMore = false;
        notifyListeners();
      }
    }
  }

  Future<void> deleteBuyer({bool withLoading = false, String? buyerId}) async {
    if (withLoading) loading(true);

    try {
      final response = await ApiClient().dio.delete(
        '/audit/v1/admin/buyers/$buyerId',
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final message = response.data['message'] ?? 'Berhasil menghapus pembeli';
        notifyListeners();
        await Utils.showSuccess(msg: message);
        await Future.delayed(Duration(seconds: 2), () {});
        if (withLoading) loading(false);
        fetchBuyers(withLoading: true);
      }
    } on DioException catch (e) {
      final message = e.response?.data["message"] ?? e.message;
      loading(false);
      throw Exception(message);
    } catch (e) {
      loading(false);
      throw Exception(e.toString());
    }
  }

  // NOTE: AdminSellerApiController belum tersedia dari tim backend.
  // Fungsi ini adalah placeholder sementara.
  Future<void> fetchSellers({bool withLoading = false, String search = '', int page = 1}) async {
    if (withLoading) loading(true);
    userData.clear();
    notifyListeners();
    if (withLoading) loading(false);
    // TODO: Ganti dengan endpoint v1/admin/sellers setelah backend ready
    debugPrint('fetchSellers: AdminSellerApiController belum tersedia dari tim backend');
  }

  Future<void> deleteSeller({
    bool withLoading = false,
    String id = '0',
  }) async {
    Utils.showFailed(msg: 'Fitur hapus seller belum tersedia dari backend');
    // TODO: Ganti dengan endpoint DELETE v1/admin/sellers/{id} setelah backend ready
  }

  Future<void> fetchKeuangan({bool withLoading = false, String search = '', int page = 1}) async {
        if (page == 1) {
      if (withLoading) loading(true);
      userData.clear();
      hasMore = true;
      currentPage = 1;
    } else {
      isLoadingMore = true;
    }
    notifyListeners();
    Map<String, dynamic> param = {'page': page};
    
    if (search.isNotEmpty) param.addAll({'search': search});

    try {
      final response = await ApiClient().dio.get(
        '/audit/v1/admin/finances',
        queryParameters: param,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        userData.clear();
                final dataList = response.data['data'] as List<dynamic>? ?? [];
        final _meta = response.data['meta'];
        if (_meta != null) {
          currentPage = _meta['current_page'] ?? 1;
          final lastPage = _meta['last_page'] ?? 1;
          hasMore = currentPage < lastPage;
        } else {
          hasMore = dataList.isNotEmpty;
        }
    
        
        for (var item in dataList) {
          final uData = item['user_data'] ?? {};
          final dept = uData['department'];
          String alamatDept = '';
          if (dept != null && dept is Map) {
            alamatDept = dept['name']?.toString() ?? '';
          }

          userData.add(
            UserData(
              name1: uData['first_name']?.toString() ?? '',
              name2: uData['last_name']?.toString() ?? '',
              email: item['email']?.toString() ?? '',
              id: item['id']?.toString() ?? '',
              alamat: alamatDept,
              status: item['status']?.toString() == 'active' ? '1' : '0',
            ),
          );
        }

        notifyListeners();
      } else {
        throw Exception("Gagal memuat data finance");
      }
    } catch (e) {
      debugPrint("fetchKeuangan Error: $e");
      Utils.showFailed(msg: "Gagal memuat data dari server (500)");
    } finally {
      if (page == 1) {
        if (withLoading) loading(false);
      } else {
        isLoadingMore = false;
        notifyListeners();
      }
    }
  }

  Future<void> deleteKeuangan({
    bool withLoading = false,
    String keuanganId = "148",
  }) async {
    if (withLoading) loading(true);

    try {
      final response = await ApiClient().dio.delete('/audit/v1/admin/finances/$keuanganId');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        notifyListeners();
        await Utils.showSuccess(msg: "Data finance berhasil dihapus");
        await Future.delayed(Duration(seconds: 2), () {});
        if (withLoading) loading(false);
        fetchKeuangan(withLoading: true);
      } else {
        throw Exception("Gagal menghapus data");
      }
    } catch (e) {
      debugPrint("deleteKeuangan Error: $e");
      Utils.showFailed(msg: e.toString());
    } finally {
      if (withLoading) loading(false);
    }
  }

  Future<void> fetchPenerima({bool withLoading = false, String search = '', int page = 1}) async {
        if (page == 1) {
      if (withLoading) loading(true);
      userData.clear();
      hasMore = true;
      currentPage = 1;
    } else {
      isLoadingMore = true;
    }
    notifyListeners();
    Map<String, dynamic> param = {'page': page};
    
    if (search.isNotEmpty) param.addAll({'search': search});

    try {
      final response = await ApiClient().dio.get(
        '/audit/v1/admin/receivers',
        queryParameters: param,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
                final dataList = response.data['data'] as List<dynamic>;
        final _meta = response.data['meta'];
        if (_meta != null) {
          currentPage = _meta['current_page'] ?? 1;
          final lastPage = _meta['last_page'] ?? 1;
          hasMore = currentPage < lastPage;
        } else {
          hasMore = dataList.isNotEmpty;
        }
    
        
        for (var item in dataList) {
          final uData = item['user_data'] ?? {};
          userData.add(
            UserData(
              name1: uData['first_name']?.toString() ?? '',
              name2: uData['last_name']?.toString() ?? '',
              email: item['email']?.toString() ?? '',
              id: item['id']?.toString() ?? '',
              alamat: item['full_address']?.toString() ?? '',
            ),
          );
        }

        notifyListeners();
      } else {
        throw Exception("Gagal memuat data penerima");
      }
    } catch (e) {
      debugPrint("fetchPenerima Error: $e");
      Utils.showFailed(msg: "Gagal memuat data dari server (500)");
    } finally {
      if (page == 1) {
        if (withLoading) loading(false);
      } else {
        isLoadingMore = false;
        notifyListeners();
      }
    }
  }

  Future<void> deletePenerima({
    bool withLoading = false,
    String penerimaId = "148",
  }) async {
    if (withLoading) loading(true);

    try {
      final response = await ApiClient().dio.delete('/audit/v1/admin/receivers/$penerimaId');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        notifyListeners();
        await Utils.showSuccess(msg: "Data penerima berhasil dihapus");
        await Future.delayed(Duration(seconds: 2), () {});
        if (withLoading) loading(false);
        fetchPenerima(withLoading: true);
      } else {
        throw Exception("Gagal menghapus data penerima");
      }
    } catch (e) {
      debugPrint("deletePenerima Error: $e");
      Utils.showFailed(msg: e.toString());
    } finally {
      if (withLoading) loading(false);
    }
  }

  Future<void> fetchManager({bool withLoading = false, String search = '', int page = 1}) async {
        if (page == 1) {
      if (withLoading) loading(true);
      userData.clear();
      hasMore = true;
      currentPage = 1;
    } else {
      isLoadingMore = true;
    }
    notifyListeners();
    Map<String, dynamic> param = {'page': page};
    
    if (search.isNotEmpty) param.addAll({'search': search});

    try {
      final response = await ApiClient().dio.get(
        '/audit/v1/admin/managers',
        queryParameters: param,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        userData.clear();
                final dataList = response.data['data'] as List<dynamic>? ?? [];
        final _meta = response.data['meta'];
        if (_meta != null) {
          currentPage = _meta['current_page'] ?? 1;
          final lastPage = _meta['last_page'] ?? 1;
          hasMore = currentPage < lastPage;
        } else {
          hasMore = dataList.isNotEmpty;
        }
    
        
        for (var item in dataList) {
          // Manager menggunakan key 'profile' bukan 'user_data'
          final profile = item['profile'] ?? {};
          userData.add(
            UserData(
              name1: profile['first_name']?.toString() ?? '',
              name2: profile['last_name']?.toString() ?? '',
              email: item['email']?.toString() ?? '',
              id: item['id']?.toString() ?? '',
              alamat: profile['phone']?.toString() ?? '',
              status: item['status']?.toString() == 'active' ? '1' : '0',
            ),
          );
        }

        notifyListeners();
      } else {
        throw Exception("Gagal memuat data manager");
      }
    } catch (e) {
      debugPrint("fetchManager Error: $e");
      Utils.showFailed(msg: "Gagal memuat data dari server (500)");
    } finally {
      if (page == 1) {
        if (withLoading) loading(false);
      } else {
        isLoadingMore = false;
        notifyListeners();
      }
    }
  }

  Future<void> deleteManager({
    bool withLoading = false,
    String managerId = "0",
  }) async {
    if (withLoading) loading(true);

    try {
      final response = await ApiClient().dio.delete('/audit/v1/admin/managers/$managerId');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        notifyListeners();
        await Utils.showSuccess(msg: "Data manager berhasil dihapus");
        await Future.delayed(Duration(seconds: 2), () {});
        if (withLoading) loading(false);
        fetchManager(withLoading: true);
      } else {
        throw Exception("Gagal menghapus data manager");
      }
    } catch (e) {
      debugPrint("deleteManager Error: $e");
      Utils.showFailed(msg: e.toString());
    } finally {
      if (withLoading) loading(false);
    }
  }

  Future<void> fetchAudit({bool withLoading = false, String search = '', int page = 1}) async {
        if (page == 1) {
      if (withLoading) loading(true);
      userData.clear();
      hasMore = true;
      currentPage = 1;
    } else {
      isLoadingMore = true;
    }
    notifyListeners();
    Map<String, dynamic> param = {'page': page};
    
    if (search.isNotEmpty) param.addAll({'search': search});

    try {
      final response = await ApiClient().dio.get(
        '/audit/v1/admin/audits',
        queryParameters: param,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
                final dataList = response.data['data'] as List<dynamic>;
        final _meta = response.data['meta'];
        if (_meta != null) {
          currentPage = _meta['current_page'] ?? 1;
          final lastPage = _meta['last_page'] ?? 1;
          hasMore = currentPage < lastPage;
        } else {
          hasMore = dataList.isNotEmpty;
        }
    
        
        for (var item in dataList) {
          final uData = item['user_data'] ?? {};
          userData.add(
            UserData(
              name1: uData['first_name']?.toString() ?? '',
              name2: uData['last_name']?.toString() ?? '',
              email: item['email']?.toString() ?? '',
              id: item['id']?.toString() ?? '',
              alamat: uData['phone']?.toString() ?? '',
            ),
          );
        }

        notifyListeners();
      } else {
        throw Exception("Gagal memuat data audit");
      }
    } catch (e) {
      debugPrint("fetchAudit Error: $e");
      Utils.showFailed(msg: "Gagal memuat data dari server (500)");
    } finally {
      if (withLoading) loading(false);
    }
  }

  Future<void> deleteAudit({
    bool withLoading = false,
    String auditId = "0",
  }) async {
    if (withLoading) loading(true);

    try {
      final response = await ApiClient().dio.delete('/audit/v1/admin/audits/$auditId');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        notifyListeners();
        await Utils.showSuccess(msg: "Data audit berhasil dihapus");
        await Future.delayed(Duration(seconds: 2), () {});
        if (withLoading) loading(false);
        fetchAudit(withLoading: true);
      } else {
        throw Exception("Gagal menghapus data audit");
      }
    } catch (e) {
      debugPrint("deleteAudit Error: $e");
      Utils.showFailed(msg: e.toString());
    } finally {
      if (withLoading) loading(false);
    }
  }

  Future<void> fetchDireksi({bool withLoading = false, String search = '', int page = 1}) async {
        if (page == 1) {
      if (withLoading) loading(true);
      userData.clear();
      hasMore = true;
      currentPage = 1;
    } else {
      isLoadingMore = true;
    }
    notifyListeners();
    Map<String, dynamic> param = {'page': page};
    
    if (search.isNotEmpty) param.addAll({'search': search});

    try {
      final response = await ApiClient().dio.get(
        '/audit/v1/admin/direksi',
        queryParameters: param,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
                final dataList = response.data['data'] as List<dynamic>;
        final _meta = response.data['meta'];
        if (_meta != null) {
          currentPage = _meta['current_page'] ?? 1;
          final lastPage = _meta['last_page'] ?? 1;
          hasMore = currentPage < lastPage;
        } else {
          hasMore = dataList.isNotEmpty;
        }
    
        
        for (var item in dataList) {
          final uData = item['user_data'] ?? {};
          userData.add(
            UserData(
              name1: uData['first_name']?.toString() ?? '',
              name2: uData['last_name']?.toString() ?? '',
              email: item['email']?.toString() ?? '',
              id: item['id']?.toString() ?? '',
              alamat: uData['phone']?.toString() ?? '',
            ),
          );
        }

        notifyListeners();
      } else {
        throw Exception("Gagal memuat data direksi");
      }
    } catch (e) {
      debugPrint("fetchDireksi Error: $e");
      Utils.showFailed(msg: "Gagal memuat data dari server (500)");
    } finally {
      if (withLoading) loading(false);
    }
  }

  Future<void> deleteDireksi({
    bool withLoading = false,
    String direksiId = "0",
  }) async {
    if (withLoading) loading(true);

    try {
      final response = await ApiClient().dio.delete('/audit/v1/admin/direksi/$direksiId');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        notifyListeners();
        await Utils.showSuccess(msg: "Data direksi berhasil dihapus");
        await Future.delayed(Duration(seconds: 2), () {});
        if (withLoading) loading(false);
        fetchDireksi(withLoading: true);
      } else {
        throw Exception("Gagal menghapus data direksi");
      }
    } catch (e) {
      debugPrint("deleteDireksi Error: $e");
      Utils.showFailed(msg: e.toString());
    } finally {
      if (withLoading) loading(false);
    }
  }
}
