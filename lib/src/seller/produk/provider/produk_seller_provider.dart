import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mspeed/common/base/base_controller.dart';
import 'package:mspeed/common/base/base_response.dart';
import 'package:mspeed/common/component/custom_image_picker.dart';
import 'package:mspeed/common/helper/multipart.dart';
import 'package:mspeed/src/buyer/product/model/product_model.dart';
import 'package:mspeed/src/seller/home/model/kategori_model.dart';
import 'package:mspeed/src/seller/produk/model/produk_detail_seller_model.dart';
import 'package:mspeed/src/seller/produk/model/produk_list_seller_model.dart';
import 'package:mspeed/utils/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
    // if (fotoProduk[index] != null && fotoProduk.length == 2) {
    //   fotoProduk[index] = null;
    //   fotoProduk.removeAt(1);
    // } else {
    final imageId = productDetailSellerModel.data?.fotoProduk?[index - 1]?.ID;
    if (imageId != null) deletedImageId.add(imageId);
    if (index == 0) {
      fotoProduk[index] = null;
    } else {
      fotoProduk.removeAt(index);
      fotoProdukUrl.removeAt(index);
    }
    notifyListeners();
    // }
  }

  ProdukListSellerModel _produkSellerListModel = ProdukListSellerModel();
  ProdukListSellerModel get produkSellerListModel =>
      this._produkSellerListModel;
  set produkSellerListModel(ProdukListSellerModel value) =>
      this._produkSellerListModel = value;

  Future<void> fetchProductListSeller({bool withLoading = false}) async {
    produkSellerListModel = ProdukListSellerModel();
    if (withLoading) loading(true);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userId = await prefs.getString(Constant.kSetPrefId);
    Map<String, String> body = {'seller_id': userId ?? ''};
    final response = await get(
      Constant.BASE_API_FULL + '/products',
      body: body,
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      produkSellerListModel = ProdukListSellerModel.fromJson(
        jsonDecode(response.body),
      );
      notifyListeners();
      if (withLoading) loading(false);
    } else {
      final message = jsonDecode(response.body)["messages"]["error"];
      loading(false);
      throw Exception(message);
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
    Map<String, String> body = {'produk_id': productId};
    final response = await get(
      Constant.BASE_API_FULL + '/products/$productId',
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      productDetailSellerModel = ProdukDetailSellerModel.fromJson(
        jsonDecode(response.body),
      );
      notifyListeners();
      if (withLoading) loading(false);
    } else {
      final message = jsonDecode(response.body)["messages"]["error"];
      loading(false);
      throw Exception(message);
    }
  }

  Future<void> initEditProduk(String id) async {
    await fetchDetailProduct(productId: id);
    var data = productDetailSellerModel.data?.produk;
    var foto = productDetailSellerModel.data?.fotoProduk;
    namaC.text = data?.nama ?? '';
    hargaC.text = data?.harga ?? '';
    kodeC.text = data?.kodeProduk ?? '';
    selectedKategori = data?.IDKategori ?? '';
    stokC.text = data?.qty ?? '';
    deskripsiC.text = data?.deskripsi ?? '';
    fotoProduk.clear();
    fotoProdukUrl.clear();
    if (data?.foto != null) {
      fotoProdukUrl.add(data?.foto);
      fotoProduk.add(null);
    }
    if (foto != null) {
      for (var item in foto) {
        if (item?.foto != null) {
          fotoProdukUrl.add(item!.foto!);
          fotoProduk.add(null); // Assuming foto is a URL or path
        }
      }
    }
    fotoProdukUrl.add(null);
    fotoProduk.add(null); // To allow adding new images

    // fotoProdukUrl.add(data?.foto);
    // for (int i = 0; i < (foto?.length ?? 0); i++)
    //   fotoProdukUrl.add(foto?[i]?.foto);
    notifyListeners();
  }

  List<String> deletedImageId = [];

  Future<void> sendProduct({
    bool withLoading = false,
    bool isEdit = false,
  }) async {
    try {
      if (withLoading) loading(true);

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString(Constant.kSetPrefId);
      final data = productDetailSellerModel.data;

      // Prepare request body
      Map<String, String?> body = {
        'nama': namaC.text,
        'harga': hargaC.text.replaceAll(".", ""),
        'kategori_id': selectedKategori ?? '0',
        'qty': stokC.text,
        'deskripsi': deskripsiC.text,
        'seller_id': userId ?? '0',
      };

      if (isEdit) {
        body['_method'] = 'PUT'; // Laravel multipart update
      }

      // Prepare file uploads
      List<http.MultipartFile> files = [];

      // Add main image
      if (fotoProduk.isNotEmpty && fotoProduk.first != null) {
        files.add(await getMultipart('fileupload', File(fotoProduk.first!.path)));
      }

      final fotoList = data?.fotoProduk ?? [];
      List<File> newFileList = [];

      // Process additional images
      for (int i = 1; i < fotoProduk.length; i++) {
        final item = fotoProduk[i];
        final isNewFile = i > fotoList.length;

        if (item != null && !isNewFile) {
          files.add(await getMultipart('upload[${i - 1}]', File(item.path)));
        } else if (item != null) {
          newFileList.add(File(item.path));
        } else if (i < fotoProduk.length - 1) {
          files.add(await getMultipart('upload[${i - 1}]', null));
        }
      }

      if (isEdit) {
        // Add existing image IDs for update
        for (int i = 0; i < fotoList.length; i++) {
          final item = fotoList[i];

          if (item != null &&
              i < fotoProduk.length - 2 &&
              (item.ID ?? '').trim().isNotEmpty &&
              fotoProduk[i + 1] != null) {
            body['upload_id[$i]'] = item.ID!;
          } else if (fotoProduk[i + 1] == null) {
            body['upload_id[$i]'] = null;
          }
        }

        // Add new images for edit
        for (int i = 0; i < newFileList.length; i++) {
          files.add(await getMultipart('upload_new[$i]', File(newFileList[i].path)));
        }

        // Add deleted image IDs
        for (int i = 0; i < deletedImageId.length; i++) {
          body['upload_id_delete[$i]'] = deletedImageId[i];
        }
      }

      // ========= IMPORTANT FIX =========
      // Backend expects at least one "upload" index.
      // If none exists, send a placeholder upload[0].
      bool hasUploadField = files.any((f) => f.field.startsWith('upload'));
      if (!hasUploadField) {
        files.add(await getMultipart('upload[0]', null));
      }

      // Debug logs
      print("========== REQUEST BODY ==========");
      print(body);

      print("========== FILES SENT ==========");
      for (var f in files) {
        print("KEY: ${f.field}, FILE: ${f.filename}");
      }

      // Perform API request
      final response = await post(
        '${Constant.BASE_API_FULL}/products${isEdit ? '/${data?.produk?.ID ?? 0}' : ''}',
        body: body,
        files: files,
      );

      if (withLoading) loading(false);

      print("========== RAW RESPONSE ==========");
      print("STATUS: ${response.statusCode}");
      print("BODY: ${response.body}");

      // SUCCESS
      if (response.statusCode == 200 || response.statusCode == 201) {
        final parsed = jsonDecode(response.body);
        print("========== PARSED SUCCESS JSON ==========");
        print(parsed);

        fetchProductListSeller();
        productDetailSellerModel = ProdukDetailSellerModel.fromJson(parsed);
        deletedImageId.clear();
        notifyListeners();
        return;
      }

      // ERROR CASE (JSON)
      final errJson = jsonDecode(response.body);
      print("========== ERROR RESPONSE JSON ==========");
      print(errJson);

      final message = errJson["message"] ??
          errJson["messages"]?["error"] ??
          "Unknown Error";

      print("🔥 API ERROR MESSAGE: $message");
      throw Exception(message);

    } catch (e, stack) {
      print("🔥🔥🔥 EXCEPTION IN sendProduct()");
      print("ERROR: $e");
      print("STACKTRACE:");
      print(stack);

      if (withLoading) loading(false);
      rethrow;
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

  Future<void> deleteProduct({
    bool withLoading = false,
    required String productId,
  }) async {
    if (withLoading) loading(true);

    final response = await delete(
      Constant.BASE_API_FULL + '/products/$productId',
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final result = BaseResponse.from(response);
      await Utils.showSuccess(msg: result.message);
      await Future.delayed(Duration(seconds: 2));
      notifyListeners();
      if (withLoading) loading(false);
    } else {
      final message = jsonDecode(response.body)["messages"]["error"];
      loading(false);
      throw Exception(message);
    }
  }

  // KATEGORI
  KategoriModel? _kategoriModel;
  KategoriModel? get kategoriModel => this._kategoriModel;
  set kategoriModel(KategoriModel? value) => this._kategoriModel = value;

  Future<void> fetchKategori({bool withLoading = false}) async {
    if (withLoading) loading(true);

    final response = await get(Constant.BASE_API_FULL + '/categories');

    if (response.statusCode == 201 || response.statusCode == 200) {
      kategoriModel = KategoriModel.fromJson(jsonDecode(response.body));
      kategori =
          kategoriModel?.data
              ?.map(
                (e) => DropdownMenuItem<String>(
                  child: Text(e?.nama ?? ''),
                  value: e?.ID ?? '',
                ),
              )
              .toList() ??
          [];
      notifyListeners();
      if (withLoading) loading(false);
    } else {
      final message = jsonDecode(response.body)["messages"]["error"];
      loading(false);
      throw Exception(message);
    }
  }
}
