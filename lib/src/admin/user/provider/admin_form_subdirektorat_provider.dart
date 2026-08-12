import 'package:flutter/material.dart';
import 'package:mspeed/common/base/base_controller.dart';
import 'package:mspeed/utils/utils.dart';
import 'package:mspeed/core/network/api_client.dart';
import 'package:mspeed/src/admin/user/provider/admin_user_provider.dart';
import 'package:provider/provider.dart';

class AdminFormSubDirektoratProvider extends BaseController with ChangeNotifier {
  final subditCodeC = TextEditingController();
  final subditNameC = TextEditingController();

  Future<void> setData(dynamic subdit) async {
    if (subdit != null) {
      subditCodeC.text = subdit['subdit_code']?.toString() ?? '';
      subditNameC.text = subdit['subdit_name']?.toString() ?? '';
    } else {
      subditCodeC.clear();
      subditNameC.clear();
    }
    notifyListeners();
  }

  Future<void> sendSubDirektorat(BuildContext context, {String? subditId}) async {
    if (subditCodeC.text.trim().isEmpty) {
      Utils.showFailed(msg: 'Kode Sub-Direktorat tidak boleh kosong');
      return;
    }
    if (subditNameC.text.trim().isEmpty) {
      Utils.showFailed(msg: 'Nama Sub-Direktorat tidak boleh kosong');
      return;
    }

    loading(true);
    final data = {
      'subdit_code': subditCodeC.text.trim(),
      'subdit_name': subditNameC.text.trim(),
    };

    try {
      final isEdit = subditId != null;
      final url = isEdit ? '/audit/v1/admin/sub-direktorates/$subditId' : '/audit/v1/admin/sub-direktorates';
      
      final response = isEdit 
        ? await ApiClient().dio.put(url, data: data)
        : await ApiClient().dio.post(url, data: data);

      if (response.statusCode == 200 || response.statusCode == 201) {
        await Utils.showSuccess(msg: 'Berhasil menyimpan data Sub-Direktorat');
        if (context.mounted) {
          context.read<AdminUserProvider>().fetchSubDirektorat(withLoading: true);
          Navigator.pop(context);
        }
      }
    } catch (e) {
      debugPrint('Error save Sub-Direktorat: $e');
      Utils.showFailed(msg: 'Gagal menyimpan data Sub-Direktorat');
    } finally {
      loading(false);
    }
  }
}
