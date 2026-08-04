import 'package:flutter/material.dart';
import 'package:mspeed/common/base/base_controller.dart';
import 'package:mspeed/common/component/custom_navigator.dart';
import 'package:mspeed/core/network/api_client.dart';
import 'package:mspeed/src/admin/user/model/basic_user_admin_model.dart';
import 'package:mspeed/src/admin/user/view/user_data_admin_view.dart';
import 'package:mspeed/utils/utils.dart';

class AdminFormKeuanganProvider extends BaseController with ChangeNotifier {
  final TextEditingController firstNameC = TextEditingController();
  final TextEditingController lastNameC = TextEditingController();
  final TextEditingController emailC = TextEditingController();
  final TextEditingController phoneNumberC = TextEditingController();
  final TextEditingController passwordC = TextEditingController();
  
  final TextEditingController subditC = TextEditingController();
  final TextEditingController departmentC = TextEditingController();
  final TextEditingController accessC = TextEditingController();
  bool isActive = true;

  String? selectedSubditId;
  String? selectedDepartmentId;

  List<Map<String, dynamic>> subdirektorates = [];
  List<Map<String, dynamic>> allDepartments = [];

  List<Map<String, dynamic>> get filteredDepartments {
    if (selectedSubditId == null) return [];
    return allDepartments
        .where((dept) => dept['sub_direktorate_id'].toString() == selectedSubditId)
        .toList();
  }

  Future<void> fetchMasterData() async {
    try {
      final response = await ApiClient().dio.get('/audit/v1/admin/finances/create');
      if (response.data['status'] == 'success') {
        final data = response.data['data'];
        
        subdirektorates = List<Map<String, dynamic>>.from(data['sub_direktorates'] ?? []);
        allDepartments = List<Map<String, dynamic>>.from(data['departments'] ?? []);
        
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Failed to fetch finance master data: $e");
      Utils.showFailed(msg: "Maaf, data master belum bisa dimuat (Endpoint Backend belum siap).");
    }
  }

  setData(BasicUserAdminModelData? keuangan) async {
    clearData();
    await fetchMasterData();

    if (keuangan != null) {
      firstNameC.text = keuangan.firstname ?? '';
      lastNameC.text = keuangan.lastname ?? '';
      emailC.text = keuangan.email ?? '';
      phoneNumberC.text = keuangan.telp ?? '';
      
      // Mapping old model to new structure
      if (keuangan.subditId != null && keuangan.subditId != 'null') {
        selectedSubditId = keuangan.subditId;
        final subdit = subdirektorates.firstWhere(
            (e) => e['id'].toString() == selectedSubditId,
            orElse: () => {});
        if (subdit.isNotEmpty) {
          subditC.text = subdit['subdit_name'] ?? '';
        }
      }
      
      // Fetch detail for complete data (active, access)
      if (keuangan.ID != null) {
        try {
          final res = await ApiClient().dio.get('/audit/v1/admin/finances/${keuangan.ID}');
          if (res.statusCode == 200 || res.statusCode == 201) {
            final Map<String, dynamic> data = res.data['data'] ?? {};
            final Map<String, dynamic> uData = data['user_data'] ?? {};
            isActive = data['status'] == 'active' ? true : false;
            accessC.text = uData['access']?.toString() ?? '';
            selectedDepartmentId = (uData['department'] as Map<String, dynamic>?)?['id']?.toString();
          }
        } catch (e) {
          debugPrint("Failed to fetch detail: $e");
        }
      }
    }
  }

  clearData() {
    firstNameC.clear();
    lastNameC.clear();
    emailC.clear();
    phoneNumberC.clear();
    passwordC.clear();
    subditC.clear();
    departmentC.clear();
    accessC.clear();
    isActive = true;
    selectedSubditId = null;
    selectedDepartmentId = null;
    subdirektorates.clear();
    allDepartments.clear();
  }

  Future<void> sendKeuangan(BuildContext context,
      {bool withLoading = false, String? keuanganId}) async {
    if (selectedDepartmentId == null) {
      Utils.showFailed(msg: 'Silakan pilih departemen terlebih dahulu.');
      return;
    }

    if (withLoading) loading(true);
    
    var param = {
      'first_name': firstNameC.text,
      'last_name': lastNameC.text,
      'email': emailC.text,
      'phone': phoneNumberC.text,
      'subdit_id': selectedSubditId,
      'department_id': selectedDepartmentId,
      'access': accessC.text,
      'active': isActive ? '1' : '0',
    };
    
    if (passwordC.text.isNotEmpty) {
      param['password'] = passwordC.text;
    }

    try {
      final isEdit = keuanganId != null;
      final url = isEdit ? '/audit/v1/admin/finances/$keuanganId' : '/audit/v1/admin/finances';
      
      final response = isEdit 
        ? await ApiClient().dio.put(url, data: param)
        : await ApiClient().dio.post(url, data: param);

      if (response.statusCode == 200 || response.statusCode == 201) {
        notifyListeners();
        await Utils.showSuccess(msg: 'Data finance berhasil disimpan!');
        await Future.delayed(const Duration(seconds: 2));
        CusNav.nPushReplace(
            context, const UserDataAdminView(userType: UserDataType.FINANCE));
      } else {
        Utils.showFailed(msg: 'Gagal menyimpan data.');
      }
    } catch (e) {
      Utils.showFailed(msg: e.toString());
    } finally {
      if (withLoading) loading(false);
    }
  }

  Future<void> deleteKeuangan(BuildContext context,
      {bool withLoading = false, String? keuanganId}) async {
    if (keuanganId == null) return;
    
    if (withLoading) loading(true);
    
    try {
      final response = await ApiClient().dio.delete('/audit/v1/admin/finances/$keuanganId');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        notifyListeners();
        await Utils.showSuccess(msg: 'Data finance berhasil dihapus.');
        await Future.delayed(const Duration(seconds: 2));
        CusNav.nPushReplace(
            context, const UserDataAdminView(userType: UserDataType.FINANCE));
      }
    } catch (e) {
      Utils.showFailed(msg: e.toString());
    } finally {
      if (withLoading) loading(false);
    }
  }
}
