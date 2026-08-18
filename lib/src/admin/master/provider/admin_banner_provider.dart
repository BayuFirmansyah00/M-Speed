import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mspeed/common/base/base_controller.dart';
import 'package:mspeed/common/component/custom_navigator.dart';
import 'package:mspeed/src/admin/master/model/banner_admin_model.dart';
import 'package:mspeed/utils/utils.dart';
import 'package:dio/dio.dart';
import 'package:mspeed/core/network/api_client.dart';

class AdminBannerProvider extends BaseController with ChangeNotifier {
  List<BannerAdminModelData> bannerList = [];
  final TextEditingController judulC = TextEditingController();
  final TextEditingController deskripsiC = TextEditingController();
  File? selectedImage;
  String? existingImageUrl;

  final ImagePicker _picker = ImagePicker();

  // DUMMY DATA REMOVED
  AdminBannerProvider() {
    bannerList = [];
  }

  Future<void> fetchBanners({bool withLoading = false}) async {
    if (withLoading) loading(true);
    try {
      final response = await ApiClient().dio.get('/audit/v1/admin/banners');
      if (response.statusCode == 200 || response.statusCode == 201) {
        final model = BannerAdminModel.fromJson(response.data);
        final List<BannerAdminModelData> list = [];
        if (model.data != null) {
          for (var item in model.data!) {
            if (item != null) list.add(item);
          }
        }
        bannerList = list;
        notifyListeners();
      }
      if (withLoading) loading(false);
    } on DioException catch (e) {
      final message = e.response?.data["message"] ?? 'Terjadi kesalahan saat memuat banner';
      loading(false);
      throw Exception(message);
    } catch (e) {
      loading(false);
      throw Exception(e.toString());
    }
  }

  void setData(BannerAdminModelData? banner) {
    clearData();
    if (banner != null) {
      judulC.text = banner.judul ?? '';
      deskripsiC.text = banner.deskripsi ?? '';
      existingImageUrl = banner.imageUrl;
    }
  }

  void clearData() {
    judulC.clear();
    deskripsiC.clear();
    selectedImage = null;
    existingImageUrl = null;
  }

  Future<void> pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 80,
    );
    if (image != null) {
      final file = File(image.path);
      final sizeInBytes = await file.length();
      final sizeInMb = sizeInBytes / (1024 * 1024);
      if (sizeInMb > 2) {
        Utils.showFailed(msg: 'Ukuran gambar maksimal 2MB.');
        return;
      }
      selectedImage = file;
      notifyListeners();
    }
  }

  void removeImage() {
    selectedImage = null;
    existingImageUrl = null;
    notifyListeners();
  }

  Future<void> saveBanner(BuildContext context, {String? id}) async {
    if (judulC.text.isEmpty || deskripsiC.text.isEmpty) {
      Utils.showFailed(msg: 'Judul dan deskripsi harus diisi');
      return;
    }
    if (id == null && selectedImage == null) {
      Utils.showFailed(msg: 'Gambar harus dipilih');
      return;
    }

    loading(true);
    try {
      FormData formData = FormData.fromMap({
        'title': judulC.text,
        'caption': deskripsiC.text,
      });

      if (selectedImage != null) {
        formData.files.add(MapEntry(
          'image',
          await MultipartFile.fromFile(selectedImage!.path),
        ));
      }

      // For PUT method with multipart form data in Laravel, we need to send POST with _method=PUT
      if (id != null) {
        formData.fields.add(MapEntry('_method', 'PUT'));
      }

      final response = await ApiClient().dio.post(
        id != null ? '/audit/v1/admin/banners/$id' : '/audit/v1/admin/banners',
        data: formData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        await Utils.showSuccess(msg: 'Berhasil menyimpan banner');
        await fetchBanners();
        clearData();
        CusNav.nPop(context);
      }
      loading(false);
    } on DioException catch (e) {
      loading(false);
      final message = e.response?.data["message"] ?? 'Terjadi kesalahan saat menyimpan banner';
      Utils.showFailed(msg: message);
    } catch (e) {
      loading(false);
      Utils.showFailed(msg: e.toString());
    }
  }

  Future<void> deleteBanner(String id) async {
    loading(true);
    try {
      final response = await ApiClient().dio.delete('/audit/v1/admin/banners/$id');
      if (response.statusCode == 200 || response.statusCode == 201) {
        await Utils.showSuccess(msg: 'Berhasil menghapus banner');
        await fetchBanners();
      }
      loading(false);
    } on DioException catch (e) {
      loading(false);
      final message = e.response?.data["message"] ?? 'Terjadi kesalahan saat menghapus banner';
      Utils.showFailed(msg: message);
    } catch (e) {
      loading(false);
      Utils.showFailed(msg: e.toString());
    }
  }
}
