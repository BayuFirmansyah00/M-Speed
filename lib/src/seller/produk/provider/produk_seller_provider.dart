import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mspeed/common/base/base_controller.dart';
import 'package:mspeed/common/component/custom_image_picker.dart';
import 'package:mspeed/common/helper/multipart.dart';
import 'package:mspeed/src/buyer/product/model/product_model.dart';
import 'package:mspeed/src/seller/produk/model/kategori_model.dart';
import 'package:mspeed/src/seller/produk/model/produk_detail_seller_model.dart';
import 'package:mspeed/src/seller/produk/model/produk_list_seller_model.dart';
import 'package:mspeed/utils/utils.dart';
import 'package:mspeed/common/helper/session_helper.dart';
import '../../../../common/helper/constant.dart';

class ProdukSellerProvider extends BaseController with ChangeNotifier {
  ProductModel _productModel = ProductModel();
  ProductModel get productModel => this._productModel;
  set productModel(ProductModel value) => this._productModel = value;

  TextEditingController searchC = TextEditingController();
  TextEditingController searchNegoC = TextEditingController();

  Duration duration = const Duration(seconds: 2);
  Timer? _searchOnStoppedTyping;
  Timer? get searchOnStoppedTyping => this._searchOnStoppedTyping;
  set searchOnStoppedTyping(Timer? value) {
    this._searchOnStoppedTyping = value;
    notifyListeners();
  }

  //ADD PRODUK
  List<XFile?> _fotoProduk = [null];
  List<XFile?> get fotoProduk => this._fotoProduk;
  set fotoProduk(List<XFile?> value) => this._fotoProduk = value;

  List<String?> fotoProdukUrl = [];

  List<DropdownMenuItem<String>> kategori = [];

  String? selectedKategori;

  TextEditingController kodeC = TextEditingController();
  TextEditingController namaC = TextEditingController();
  TextEditingController kategoriC = TextEditingController();
  TextEditingController hargaC = TextEditingController();
  TextEditingController stokC = TextEditingController();
  TextEditingController deskripsiC = TextEditingController();
  FocusNode deskripsiN = FocusNode();

  pickProductImage(int index) async {
    log("INDEX SELECT : $index");
    final file = await CustomImagePicker.selectImageFromGallery();
    if (file != null) {
      fotoProduk[index] = file;
    }
    if (index == fotoProduk.length - 1) {
      fotoProdukUrl.add(null);
      fotoProduk.add(null);
    }
    notifyListeners();
  }

  onRemoveProductImage(int index) async {
    final imageId = productDetailSellerModel.data?.images?[index].id;
    if (imageId != null) deletedImageId.add(imageId.toString());
    
    fotoProduk.removeAt(index);
    fotoProdukUrl.removeAt(index);
    
    notifyListeners();
  }

  ProdukListSellerModel _produkSellerListModel = ProdukListSellerModel();
  ProdukListSellerModel get produkSellerListModel =>
      this._produkSellerListModel;
  set produkSellerListModel(ProdukListSellerModel value) =>
      this._produkSellerListModel = value;

  int currentPage = 1;

  Future<void> fetchProductListSeller({bool withLoading = false, bool isLoadMore = false}) async {
    if (!isLoadMore) {
      produkSellerListModel = ProdukListSellerModel();
      currentPage = 1;
    } else {
      currentPage++;
    }

    if (withLoading) loading(true);
    final userId = await SessionHelper.getSellerId();
    
    try {
      // TODO: Remove per_page=${Constant.maxPaginationPerPage} when infinite scroll is fully implemented in UI
      // Saat ini UI flutter belum memilki logic infinite scroll yang membaca currentPage.
      final response = await getRest(
        Constant.BASE_API_FULL + '${Constant.epProducts}?seller_id=$userId&page=$currentPage&per_page=${Constant.maxPaginationPerPage}',
      );
      
      final parsed = ProdukListSellerModel.fromJson(response);
      if (isLoadMore) {
        produkSellerListModel.data?.addAll(parsed.data ?? []);
        produkSellerListModel.meta = parsed.meta;
      } else {
        produkSellerListModel = parsed;
      }
      
      notifyListeners();
    } catch (e) {
      Utils.showFailed(msg: e.toString());
      if (isLoadMore) currentPage--;
    } finally {
      if (withLoading) loading(false);
    }
  }

  // DETAIL PRODUK
  bool _productExpanded = false;
  bool get productExpanded => this._productExpanded;
  set productExpanded(bool value) => this._productExpanded = value;

  ProdukDetailSellerModel _productDetailSellerModel = ProdukDetailSellerModel();
  ProdukDetailSellerModel get productDetailSellerModel =>
      this._productDetailSellerModel;
  set productDetailSellerModel(ProdukDetailSellerModel value) =>
      this._productDetailSellerModel = value;

  Future<void> fetchDetailProduct({
    bool withLoading = false,
    required String productId,
  }) async {
    if (withLoading) loading(true);
    try {
      final response = await getRest(
        Constant.BASE_API_FULL + '${Constant.epProducts}/$productId',
      );
      productDetailSellerModel = ProdukDetailSellerModel.fromJson(response);
      notifyListeners();
    } finally {
      if (withLoading) loading(false);
    }
  }

  Future<void> initEditProduk(String id) async {
    await fetchDetailProduct(productId: id);
    var data = productDetailSellerModel.data;
    var foto = productDetailSellerModel.data?.images;
    
    namaC.text = data?.name ?? '';
    hargaC.text = (data?.price ?? 0).toInt().toString();
    kodeC.text = data?.productCode ?? '';
    selectedKategori = data?.category?.id?.toString() ?? '';
    stokC.text = (data?.qty ?? 0).toString();
    deskripsiC.text = data?.description ?? '';
    
    fotoProduk.clear();
    fotoProdukUrl.clear();
    
    if (foto != null) {
      for (var item in foto) {
        if (item.imgUrl != null) {
          fotoProdukUrl.add(item.imgUrl);
          fotoProduk.add(null);
        }
      }
    }
    fotoProdukUrl.add(null);
    fotoProduk.add(null); // To allow adding new images

    notifyListeners();
  }

  List<String> deletedImageId = [];

  Future<void> sendProduct({
    bool withLoading = false,
    bool isEdit = false,
  }) async {
    try {
      if (withLoading) loading(true);

      final data = productDetailSellerModel.data;

      // Prepare request body (Laravel API format baru)
      Map<String, String?> body = {
        'name': namaC.text,
        'price': hargaC.text.replaceAll(".", ""),
        'category_id': selectedKategori ?? '0',
        'qty': stokC.text,
        'description': deskripsiC.text,
      };
      
      if (kodeC.text.isNotEmpty) {
        body['product_code'] = kodeC.text;
      }

      if (isEdit) {
        body['_method'] = 'PUT'; // Laravel multipart update
      }

      // Prepare file uploads
      List<http.MultipartFile> files = [];
      final fotoList = data?.images ?? [];

      if (!isEdit) {
        // --- CREATE PRODUCT ---
        int uploadIndex = 0;
        for (int i = 0; i < fotoProduk.length; i++) {
          final item = fotoProduk[i];
          if (item != null) {
            files.add(await getMultipart('images[$uploadIndex][file]', File(item.path)));
            body['images[$uploadIndex][caption]'] = 'Gambar ${uploadIndex + 1}';
            uploadIndex++;
          }
        }
      } else {
        // --- UPDATE PRODUCT ---
        int newUploadIndex = 0;
        int deleteIndex = 0;

        // Tambahkan ID gambar yang dihapus
        for (var delId in deletedImageId) {
          body['delete_image_ids[$deleteIndex]'] = delId;
          deleteIndex++;
        }

        // Tambahkan gambar baru (serta relasinya jika menggantikan gambar lama di slot tersebut)
        for (int i = 0; i < fotoProduk.length; i++) {
          final item = fotoProduk[i];
          if (item != null) {
            files.add(await getMultipart('new_images[$newUploadIndex][file]', File(item.path)));
            
            // Cek jika ini me-replace gambar yang sudah ada pada index 'i'
            if (i < fotoList.length && fotoList[i].id != null) {
               body['existing_image_ids[$newUploadIndex]'] = fotoList[i].id.toString();
            }
            newUploadIndex++;
          }
        }
      }

      print("========== REQUEST BODY ==========");
      print(body);

      // Perform API request
      final parsed = await postRest(
        '${Constant.BASE_API_FULL}${Constant.epProducts}${isEdit ? '/${data?.id ?? 0}' : ''}',
        body: body,
        files: files.isNotEmpty ? files : null,
      );

      print("========== PARSED SUCCESS JSON ==========");
      print(parsed);

      fetchProductListSeller();
      deletedImageId.clear();
      notifyListeners();
    } catch (e) {
      print("🔥 API ERROR MESSAGE: $e");
      throw Exception(e.toString());
    } finally {
      if (withLoading) loading(false);
    }
  }

  // Future<void> sendProduct({
  //   bool withLoading = false,
  //   bool isEdit = false,
  // }) async {
  //   if (withLoading) loading(true);

  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   var userId = await prefs.getString(Constant.kSetPrefId);
  //   final data = productDetailSellerModel.data;

  //   // Prepare request body
  //   Map<String, String> body = {
  //     'nama': namaC.text,
  //     'harga': hargaC.text.replaceAll(".", ""),
  //     'kategori_id': selectedKategori ?? '0',
  //     'qty': stokC.text,
  //     'deskripsi': deskripsiC.text,
  //     'seller_id': userId ?? '0',
  //   };

  //   // Include product ID for editing
  //   if (isEdit) {
  //     body.addAll({'produk_id': data?.produk?.ID ?? '0'});
  //   }

  //   // Prepare file uploads
  //   List<http.MultipartFile> files = [];

  //   // Handle all images systematically
  //   int uploadCounter = 0; // Counter for upload[] fields
  //   int uploadIdCounter = 0; // Counter for upload_id[] fields

  //   // Handle the main product image (first image)
  //   if (fotoProduk.isNotEmpty && fotoProduk[0] != null) {
  //     files.add(await getMultipart('fileupload', File(fotoProduk[0]!.path)));
  //   }

  //   // Handle additional images (starting from index 1)
  //   for (int i = 1; i < fotoProduk.length - 1; i++) {
  //     // Skip the last null placeholder
  //     final item = fotoProduk[i];

  //     if (item != null) {
  //       // This is a new file to upload
  //       files.add(
  //         await getMultipart('upload[$uploadCounter]', File(item.path)),
  //       );
  //       uploadCounter++;
  //     } else if (i < fotoProdukUrl.length && fotoProdukUrl[i] != null) {
  //       // This is an existing image we want to keep
  //       if (isEdit) {
  //         final fotoList = data?.fotoProduk ?? [];
  //         if (i - 1 < fotoList.length &&
  //             (fotoList[i - 1]?.ID ?? '').isNotEmpty) {
  //           body.addAll({
  //             'upload_id[$uploadIdCounter]': fotoList[i - 1]?.ID ?? '',
  //           });
  //           uploadIdCounter++;
  //         }
  //       }
  //     }
  //   }

  //   log("BODYNYA : $body");

  //   for (int i = 0; i < files.length; i++) {
  //     log("FILES KEY $i : ${files[i].field}");
  //     log("FILES NAME $i : ${files[i].filename}");
  //   }

  //   // Perform the API request
  //   final response = await post(
  //     Constant.BASE_API_FULL + '/${isEdit ? 'edit' : 'create'}produkseller',
  //     body: body,
  //     files: files.isEmpty ? null : files,
  //   );

  //   // Handle the response
  //   if (response.statusCode == 201 || response.statusCode == 200) {
  //     if (withLoading) loading(false);
  //     fetchProductListSeller();
  //     productDetailSellerModel = ProdukDetailSellerModel.fromJson(
  //       jsonDecode(response.body),
  //     );
  //     notifyListeners();
  //   } else {
  //     if (withLoading) loading(false);
  //     final message = jsonDecode(response.body)["messages"]["error"];
  //     throw Exception(message);
  //   }
  // }

  Future<void> hapusProduk({
    bool withLoading = false,
    required String productId,
  }) async {
    if (withLoading) loading(true);

    try {
      await deleteRest(
        Constant.BASE_API_FULL + '${Constant.epProducts}/$productId',
      );
      // final result = BaseResponse.from(parsed); // Usually Laravel just returns a message or success 204
      await Utils.showSuccess(msg: "Produk berhasil dihapus");
      await Future.delayed(Duration(seconds: 2));
      notifyListeners();
    } finally {
      if (withLoading) loading(false);
    }
  }

  // KATEGORI
  KategoriModel? _kategoriModel;
  KategoriModel? get kategoriModel => this._kategoriModel;
  set kategoriModel(KategoriModel? value) => this._kategoriModel = value;

  Future<void> fetchKategori({bool withLoading = false}) async {
    if (withLoading) loading(true);

    try {
      final parsed = await getRest(Constant.BASE_API_FULL + '/categories');
      kategoriModel = KategoriModel.fromJson(parsed);
      kategori =
          kategoriModel?.data
              ?.map(
                (e) => DropdownMenuItem<String>(
                  child: Text(e?.name ?? ''),
                  value: e?.id ?? '',
                ),
              )
              .toList() ??
          [];
      notifyListeners();
    } finally {
      if (withLoading) loading(false);
    }
  }
}
