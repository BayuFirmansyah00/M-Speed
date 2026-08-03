import 'package:flutter/material.dart';
import 'package:mspeed/common/base/base_controller.dart';
import 'package:mspeed/common/component/custom_navigator.dart';
import 'package:mspeed/core/network/api_client.dart';
import 'package:mspeed/src/admin/user/model/keuangan_admin_model.dart';
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
        
        subdirektorates = List<Map<String, dynamic>>.from(data['sub_direktorates']);
        allDepartments = List<Map<String, dynamic>>.from(data['departments']);
        
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Failed to fetch finance master data: $e");
    }
  }

  setData(KeuanganAdminModelData? keuangan) async {
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
      
      // We assume user_data will contain department info from the API if it's the new API.
      // But KeuanganAdminModelData is from the old API, so it might not have departmentId directly.
      // We will handle editing in a later step if needed.
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
      'department_id': selectedDepartmentId,
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
