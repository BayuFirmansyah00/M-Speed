import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mspeed/common/base/base_controller.dart';
import 'package:mspeed/common/component/custom_navigator.dart';
import 'package:mspeed/src/admin/master/model/banner_admin_model.dart';
import 'package:mspeed/src/admin/master/view/data_banner_admin_view.dart';
import 'package:mspeed/utils/utils.dart';

class AdminBannerProvider extends BaseController with ChangeNotifier {
  List<BannerAdminModelData> bannerList = [];
  final TextEditingController judulC = TextEditingController();
  final TextEditingController deskripsiC = TextEditingController();
  File? selectedImage;
  String? existingImageUrl;

  final ImagePicker _picker = ImagePicker();

  // DUMMY DATA INITIALIZATION
  AdminBannerProvider() {
    bannerList = [
      BannerAdminModelData(
        id: '1',
        judul: 'Promo Akhir Tahun',
        deskripsi: 'Dapatkan diskon besar-besaran untuk pembelian alat kebersihan.',
        imageUrl: 'https://via.placeholder.com/600x300.png?text=Promo+Akhir+Tahun',
      ),
      BannerAdminModelData(
        id: '2',
        judul: 'Produk Baru 2024',
        deskripsi: 'Sapu lidi kualitas premium kini hadir di katalog.',
        imageUrl: 'https://via.placeholder.com/600x300.png?text=Produk+Baru',
      ),
    ];
  }

  Future<void> fetchBanners({bool withLoading = false}) async {
    if (withLoading) loading(true);
    // Simulasi delay jaringan
    await Future.delayed(const Duration(seconds: 1));
    notifyListeners();
    if (withLoading) loading(false);
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
    loading(true);
    await Future.delayed(const Duration(seconds: 1)); // Simulasi API request

    if (judulC.text.isEmpty || deskripsiC.text.isEmpty) {
      loading(false);
      Utils.showFailed(msg: 'Judul dan Deskripsi tidak boleh kosong.');
      return;
    }

    if (id == null && selectedImage == null) {
      loading(false);
      Utils.showFailed(msg: 'Silakan pilih gambar terlebih dahulu.');
      return;
    }

    if (id == null) {
      // Create
      bannerList.add(BannerAdminModelData(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        judul: judulC.text,
        deskripsi: deskripsiC.text,
        imageUrl: selectedImage?.path ?? 'https://via.placeholder.com/600x300.png?text=New+Banner',
      ));
      Utils.showSuccess(msg: 'Banner berhasil ditambahkan (Simulasi).');
    } else {
      // Update
      final index = bannerList.indexWhere((e) => e.id == id);
      if (index != -1) {
        bannerList[index].judul = judulC.text;
        bannerList[index].deskripsi = deskripsiC.text;
        if (selectedImage != null) {
          bannerList[index].imageUrl = selectedImage!.path;
        } else if (existingImageUrl == null) {
           bannerList[index].imageUrl = 'https://via.placeholder.com/600x300.png?text=Updated+Banner';
        }
      }
      Utils.showSuccess(msg: 'Banner berhasil diperbarui (Simulasi).');
    }

    notifyListeners();
    loading(false);
    await Future.delayed(const Duration(seconds: 1));
    CusNav.nPushReplace(context, const DataBannerAdminView());
  }

  Future<void> deleteBanner(String id) async {
    loading(true);
    await Future.delayed(const Duration(seconds: 1)); // Simulasi API request
    bannerList.removeWhere((e) => e.id == id);
    notifyListeners();
    loading(false);
    Utils.showSuccess(msg: 'Banner berhasil dihapus (Simulasi).');
  }
}
