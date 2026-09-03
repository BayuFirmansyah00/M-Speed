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
import 'package:mspeed/src/admin/user/model/seller_admin_model.dart';

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
      final currentEmail = prefs.getString(Constant.kSetPrefEmail) ?? '';
      await prefs.setString('admin_original_token', currentToken);
      await prefs.setString('admin_original_email', currentEmail);

      // POST /api/aimpersonate/{id} — Laravel Sanctum Impersonate
      final response = await ApiClient().dio.post('/aimpersonate/$id');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data['data'] ?? {};
        final impersonatedUser = data['user'] ?? {};
        final accessToken = data['access_token']?.toString() ?? '';
        final adminId = data['admin_id']?.toString() ?? '';
        final role = impersonatedUser['role']?.toString().toUpperCase() ?? '';

        // Simpan token impersonate baru
        await prefs.setString(Constant.kSetPrefToken, accessToken);
        await prefs.setString(Constant.kSetPrefId, impersonatedUser['id']?.toString() ?? '');
        await prefs.setString(Constant.kSetPrefEmail, impersonatedUser['email']?.toString() ?? '');
        await prefs.setString(Constant.kSetPrefRoles, role);
        await prefs.setString('admin_original_id', adminId);
        await prefs.setBool(Constant.kSetPrefIsAdmin, false);
        await prefs.setBool('is_impersonated', true);

        log('IMPERSONATE SUCCESS: role=$role, token=$accessToken, adminId=$adminId');

        // Navigasi berdasarkan role target
        if (role == 'SELLER') {
          Navigator.pushNamedAndRemoveUntil(context, '/sellerHome', (route) => false);
        } else if (role == 'PENERIMA' || role == 'RECEIVER') {
          Navigator.pushNamedAndRemoveUntil(context, '/penerimaHome', (route) => false);
        } else if (role == 'KEUANGAN' || role == 'FINANCE') {
          Navigator.pushNamedAndRemoveUntil(context, '/keuanganHome', (route) => false);
        } else if (role == 'MANAGER') {
          Navigator.pushNamedAndRemoveUntil(context, '/managerHome', (route) => false);
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
      final adminId = prefs.getString('admin_original_id') ?? '';
      bool tokenRestoredFromApi = false;
      try {
        final response = await ApiClient().dio.post(
          '/impersonate/stop',
          data: {'admin_id': adminId},
        );
        if (response.statusCode == 200 || response.statusCode == 201) {
          final data = response.data['data'] ?? {};
          final newAdminToken = data['access_token']?.toString() ?? '';
          if (newAdminToken.isNotEmpty) {
            await prefs.setString(Constant.kSetPrefToken, newAdminToken);
            tokenRestoredFromApi = true;
          }
        }
      } catch (_) {
        // Abaikan error jika API gagal
      }

      // Restore token admin asli sebagai fallback
      if (!tokenRestoredFromApi) {
        final adminToken = prefs.getString('admin_original_token') ?? '';
        if (adminToken.isNotEmpty) {
          await prefs.setString(Constant.kSetPrefToken, adminToken);
        }
      }
      
      final adminEmail = prefs.getString('admin_original_email') ?? '';
      if (adminEmail.isNotEmpty) {
        await prefs.setString(Constant.kSetPrefEmail, adminEmail);
      }
      await prefs.setString(Constant.kSetPrefId, adminId);
      
      await prefs.remove('admin_original_token');
      await prefs.remove('admin_original_id');
      await prefs.remove('admin_original_email');

      // Set kembali ke role admin
      await prefs.setString(Constant.kSetPrefRoles, 'ADMIN');
      await prefs.setBool(Constant.kSetPrefIsAdmin, true);
      await prefs.setBool('is_impersonated', false);

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
          final dept = uData['department'];
          final mgr = uData['manager'];
          String deptName = (dept is Map) ? (dept['name']?.toString() ?? '') : '';
          String mgrName = (mgr is Map) ? (mgr['name']?.toString() ?? '') : '';
          final isActive = item['status'] == 'active' || uData['active'] == 1;

          userData.add(
            UserData(
              name1: uData['first_name']?.toString() ?? '',
              name2: uData['last_name']?.toString() ?? '',
              email: item['email']?.toString() ?? '',
              id: item['id']?.toString() ?? '',
              alamat: item['full_address']?.toString() ?? '',
              status: isActive ? 'Aktif' : 'Tidak Aktif',
              telp: uData['phone']?.toString() ?? '',
              departemen: deptName,
              manager: mgrName,
              rawModel: item,
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

  Future<void> fetchSellers({bool withLoading = false, String search = '', int page = 1}) async {
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
        '/audit/v1/admin/sellers',
        queryParameters: param,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final parsed = SellerAdminModel.fromJson(response.data as Map<String, dynamic>);
        final dataList = parsed.data ?? [];
        final _meta = parsed.meta;
        if (_meta != null) {
          currentPage = _meta['current_page'] ?? 1;
          final lastPage = _meta['last_page'] ?? 1;
          hasMore = currentPage < lastPage;
        } else {
          hasMore = dataList.isNotEmpty;
        }
    
        for (var item in dataList) {
          final sellerData = item.sellerData;
          final sellerAddress = item.sellerAddress;
          final isActive = (sellerData?.active == 1) || (item.status == 'active');

          userData.add(
            UserData(
              name1: sellerData?.companyName ?? sellerData?.name ?? '',
              name2: sellerData?.ownerName ?? '',
              email: item.email ?? '',
              id: item.id?.toString() ?? '',
              alamat: sellerAddress?.fullAddress ?? sellerAddress?.cityName ?? '',
              status: isActive ? 'Aktif' : 'Tidak Aktif',
              telp: sellerData?.cpPhone ?? sellerData?.phone ?? '',
              kelengkapan: sellerData?.completeness != null ? '${sellerData?.completeness}%' : null,
              rawModel: item,
            ),
          );
        }

        notifyListeners();
      } else {
        throw Exception("Gagal memuat data seller");
      }
    } catch (e) {
      debugPrint("fetchSellers Error: $e");
      Utils.showFailed(msg: "Gagal memuat data seller dari server");
    } finally {
      if (page == 1) {
        if (withLoading) loading(false);
      } else {
        isLoadingMore = false;
        notifyListeners();
      }
    }
  }

  Future<void> deleteSeller({
    bool withLoading = false,
    String id = '0',
  }) async {
    if (withLoading) loading(true);

    try {
      final response = await ApiClient().dio.delete(
        '/audit/v1/admin/sellers/$id',
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final message = response.data['message'] ?? 'Berhasil menghapus seller';
        notifyListeners();
        await Utils.showSuccess(msg: message);
        await Future.delayed(Duration(seconds: 2), () {});
        if (withLoading) loading(false);
        fetchSellers(withLoading: true);
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
          final mgr = uData['manager'];
          String deptName = (dept is Map) ? (dept['name']?.toString() ?? '') : '';
          String mgrName = (mgr is Map) ? (mgr['name']?.toString() ?? '') : '';
          final isActive = item['status'] == 'active' || uData['active'] == 1;

          userData.add(
            UserData(
              name1: uData['first_name']?.toString() ?? '',
              name2: uData['last_name']?.toString() ?? '',
              email: item['email']?.toString() ?? '',
              id: item['id']?.toString() ?? '',
              alamat: item['full_address']?.toString() ?? deptName,
              status: isActive ? 'Aktif' : 'Tidak Aktif',
              telp: uData['phone']?.toString() ?? '',
              departemen: deptName,
              manager: mgrName,
              rawModel: item,
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
          final isActive = item['status'] == 'active' || uData['active'] == 1;
          userData.add(
            UserData(
              name1: uData['first_name']?.toString() ?? '',
              name2: uData['last_name']?.toString() ?? '',
              email: item['email']?.toString() ?? '',
              id: item['id']?.toString() ?? '',
              alamat: item['full_address']?.toString() ?? '',
              status: isActive ? 'Aktif' : 'Tidak Aktif',
              telp: uData['phone']?.toString() ?? '',
              rawModel: item,
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
          final isActive = item['status'] == 'active' || profile['active'] == 1;
          final totalMembers = item['total_members'] ?? 0;
          userData.add(
            UserData(
              name1: profile['first_name']?.toString() ?? '',
              name2: profile['last_name']?.toString() ?? '',
              email: item['email']?.toString() ?? '',
              id: item['id']?.toString() ?? '',
              alamat: '',
              status: isActive ? 'Aktif' : 'Tidak Aktif',
              telp: profile['phone']?.toString() ?? '',
              anggota: '$totalMembers Anggota',
              rawModel: item,
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
              telp: uData['phone']?.toString() ?? '',
              rawModel: item,
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
              telp: uData['phone']?.toString() ?? '',
              rawModel: item,
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
  Future<void> fetchSubDirektorat({bool withLoading = false, String search = '', int page = 1}) async {
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
        '/audit/v1/admin/sub-direktorates',
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
          userData.add(
            UserData(
              name1: item['subdit_code']?.toString() ?? '',
              name2: item['subdit_name']?.toString() ?? '',
              email: '-', // Sub-direktorat tidak memiliki email
              id: item['id']?.toString() ?? '',
              alamat: '${item['total_departments'] ?? 0} Departemen', // Sub-direktorat tidak punya alamat
              rawModel: item,
            ),
          );
        }

        notifyListeners();
      } else {
        throw Exception("Gagal memuat data sub-direktorat");
      }
    } catch (e) {
      debugPrint("fetchSubDirektorat Error: $e");
      Utils.showFailed(msg: "Gagal memuat data dari server (500)");
    } finally {
      if (withLoading) loading(false);
    }
  }

  Future<void> deleteSubDirektorat({
    bool withLoading = false,
    String subditId = "0",
  }) async {
    if (withLoading) loading(true);

    try {
      final response = await ApiClient().dio.delete('/audit/v1/admin/sub-direktorates/$subditId');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        notifyListeners();
        await Utils.showSuccess(msg: "Data sub-direktorat berhasil dihapus");
        await Future.delayed(Duration(seconds: 2), () {});
        if (withLoading) loading(false);
        fetchSubDirektorat(withLoading: true);
      } else {
        throw Exception("Gagal menghapus data sub-direktorat");
      }
    } catch (e) {
      debugPrint("deleteSubDirektorat Error: $e");
      Utils.showFailed(msg: e.toString());
    } finally {
      if (withLoading) loading(false);
    }
  }

  Future<void> toggleUserStatus({
    required UserDataType userType,
    required String userId,
  }) async {
    String endpoint = '';
    switch (userType) {
      case UserDataType.BUYER:
        endpoint = '/audit/v1/admin/buyers/$userId/toggle-status';
        break;
      case UserDataType.SELLER:
        endpoint = '/audit/v1/admin/sellers/$userId/toggle-status';
        break;
      case UserDataType.FINANCE:
        endpoint = '/audit/v1/admin/finances/$userId/toggle-status';
        break;
      case UserDataType.PENERIMA:
        endpoint = '/audit/v1/admin/receivers/$userId/toggle-status';
        break;
      case UserDataType.MANAGER:
        endpoint = '/audit/v1/admin/managers/$userId/toggle-status';
        break;
      default:
        return;
    }

    try {
      final response = await ApiClient().dio.patch(endpoint);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final msg = response.data['message'] ?? 'Status berhasil diubah';
        await Utils.showSuccess(msg: msg);
      } else {
        throw Exception("Gagal mengubah status user");
      }
    } catch (e) {
      debugPrint("toggleUserStatus Error: $e");
      Utils.showFailed(msg: "Gagal mengubah status user: $e");
    }
  }
}
