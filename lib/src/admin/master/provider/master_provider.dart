import 'dart:convert';

import 'package:mspeed/common/base/base_response.dart';
import 'package:mspeed/common/component/custom_navigator.dart';
import 'package:mspeed/src/admin/master/model/alamat_admin_model.dart';
import 'package:mspeed/src/admin/master/model/kategori_admin_model.dart';
import 'package:mspeed/src/admin/master/model/materai_admin_model.dart';
import 'package:mspeed/src/admin/master/model/kota_admin_model.dart';
import 'package:mspeed/src/admin/master/model/pajak_admin_model.dart';
import 'package:mspeed/src/admin/master/model/provinsi_admin_model.dart';
import 'package:mspeed/src/admin/master/model/subdit_admin_model.dart';
import 'package:mspeed/common/base/base_controller.dart';
import 'package:mspeed/common/helper/constant.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:mspeed/core/network/api_client.dart';
import 'package:mspeed/src/admin/master/view/data_alamat_admin.dart';
import 'package:mspeed/src/admin/master/view/data_kategori_admin.dart';
import 'package:mspeed/src/admin/master/view/data_materai_admin_view.dart';
import 'package:mspeed/src/admin/master/view/data_subdit_admin_view.dart';
import 'package:mspeed/src/admin/master/view/data_pajak_admin.dart';
import 'package:mspeed/utils/utils.dart';

class MasterProvider extends BaseController with ChangeNotifier {
  AlamatAdminModel alamatAdminModel = AlamatAdminModel();
  AlamatAdminModel get getAlamatAdminModel => this.alamatAdminModel;
  set setAlamatAdminModel(AlamatAdminModel alamatAdminModel) =>
      this.alamatAdminModel = alamatAdminModel;

  final searchSubditC = TextEditingController();
  final searchAlamatC = TextEditingController();
  final searchPajakC = TextEditingController();
  final searchKategoriC = TextEditingController();
  final searchMateraiC = TextEditingController();
  SubditAdminModel subditAdminModel = SubditAdminModel();
  SubditAdminModel get getSubditAdminModel => this.subditAdminModel;
  set setSubditAdminModel(SubditAdminModel subditAdminModel) =>
      this.subditAdminModel = subditAdminModel;

  ProvinsiAdminModel provinsiAdminModel = ProvinsiAdminModel();
  ProvinsiAdminModel get getProvinsiAdminModel => this.provinsiAdminModel;
  set setProvinsiAdminModel(ProvinsiAdminModel provinsiAdminModel) =>
      this.provinsiAdminModel = provinsiAdminModel;

  KotaAdminModel kotaAdminModel = KotaAdminModel();
  KotaAdminModel get getKotaAdminModel => this.kotaAdminModel;
  set setKotaAdminModel(KotaAdminModel kotaAdminModel) =>
      this.kotaAdminModel = kotaAdminModel;

  PajakAdminModel pajakAdminModel = PajakAdminModel();
  PajakAdminModel get getPajakAdminModel => this.pajakAdminModel;
  set setPajakAdminModel(PajakAdminModel pajakAdminModel) =>
      this.pajakAdminModel = pajakAdminModel;

  KategoriAdminModel kategoriAdminModel = KategoriAdminModel();
  KategoriAdminModel get getKategoriAdminModel => this.kategoriAdminModel;
  set setKategoriAdminModel(KategoriAdminModel kategoriAdminModel) =>
      this.kategoriAdminModel = kategoriAdminModel;

  MateraiAdminModel materaiAdminModel = MateraiAdminModel();
  MateraiAdminModel get getMateraiAdminModel => this.materaiAdminModel;
  set setMateraiAdminModel(MateraiAdminModel materaiAdminModel) =>
      this.materaiAdminModel = materaiAdminModel;

  final TextEditingController provinceC = TextEditingController();
  final TextEditingController cityC = TextEditingController();
  final TextEditingController alamatC =
      TextEditingController(); // This is 'detail'
  final TextEditingController namaC = TextEditingController(); // This is 'name'
  final TextEditingController nomorTeleponC =
      TextEditingController(); // This is 'phone'
  String? selectedProvince;
  String? selectedCity;
  int statusValue = 1;
  final TextEditingController pajakC = TextEditingController();
  final TextEditingController prosentaseC = TextEditingController();
  final TextEditingController typePajakC = TextEditingController();

  final TextEditingController namaKategoriC = TextEditingController();

  // Controllers for Materai
  final TextEditingController typeMateraiC = TextEditingController();
  final TextEditingController nominalMateraiC = TextEditingController();
  final TextEditingController pathMateraiC = TextEditingController();
  final TextEditingController orderDocumentIdMateraiC = TextEditingController();

  // Controllers for Subdit
  final TextEditingController subditCodeC = TextEditingController();
  final TextEditingController subditNameC = TextEditingController();

  setData(AlamatAdminModelData? alamat) async {
    clearData();
    await fetchProvinsiAdmin();
    final province = provinsiAdminModel.data ?? [];
    final city = kotaAdminModel.data ?? [];
    if (alamat != null) {
      if (province.isNotEmpty) {
        selectedProvince = alamat.provId ?? '';
        provinceC.text =
            province.firstWhere((e) => e?.ID == alamat.provId)?.nama ?? '';
      }
      if (city.isNotEmpty) {
        selectedCity = alamat.kotaId ?? '';
        cityC.text = city.firstWhere((e) => e?.ID == alamat.kotaId)?.nama ?? '';
      }
      alamatC.text = alamat.nama ?? '';
      namaC.text = alamat.recipientName ?? '';
      nomorTeleponC.text = alamat.phone ?? '';
      statusValue = (alamat.status ?? '1') == '1' ? 1 : 0;
    }
  }

  setDataPajak(PajakAdminModelData? pajak) async {
    clearData();
    await fetchPajakAdmin();
    if (pajak != null) {
      pajakC.text = pajak.nama ?? '';
      prosentaseC.text = pajak.persentase ?? '';
      typePajakC.text =
          '1'; // Default type for existing taxes since API needs it
    }
  }

  Future<void> setDataMaterai(MateraiAdminModelData? materai) async {
    typeMateraiC.clear();
    nominalMateraiC.clear();
    pathMateraiC.clear();
    orderDocumentIdMateraiC.clear();
    if (materai != null) {
      typeMateraiC.text = materai.type ?? '';
      nominalMateraiC.text = materai.nominal ?? '';
      pathMateraiC.text = 'dummy.pdf';
      orderDocumentIdMateraiC.text = '1';
    }
  }

  Future<void> setDataSubdit(SubditAdminModelData? subdit) async {
    subditCodeC.clear();
    subditNameC.clear();
    if (subdit != null) {
      subditCodeC.text = subdit.subditCode ?? '';
      subditNameC.text = subdit.subditName ?? '';
    }
  }

  setDataKategori(KategoriAdminModelData? kategori) async {
    namaKategoriC.clear();
    await fetchKategoriAdmin();
    if (kategori != null) {
      namaKategoriC.text = kategori.nama ?? '';
    }
  }

  clearData() {
    provinceC.clear();
    selectedProvince = null;
    selectedCity = null;
    alamatC.clear();
    cityC.clear();
  }

  // TextEditingController catatanC = TextEditingController();

  // FocusNode catatanNode = FocusNode();

  Future<void> fetchAlamatAdmin({
    bool withLoading = false,
    String search = '',
  }) async {
    if (withLoading) loading(true);

    try {
      final response = await ApiClient().dio.get(
        '/audit/v1/admin/addresses',
        queryParameters: search.isNotEmpty ? {"search": search} : {},
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        alamatAdminModel = AlamatAdminModel.fromJson(response.data);
        notifyListeners();
        if (withLoading) loading(false);
      }
    } on DioException catch (e) {
      final message = e.response?.data["messages"]?["error"] ?? e.message;
      loading(false);
      throw Exception(message);
    } catch (e) {
      loading(false);
      throw Exception(e.toString());
    }
  }

  Future<void> fetchPajakAdmin({
    bool withLoading = false,
    String search = '',
  }) async {
    if (withLoading) loading(true);

    try {
      final response = await ApiClient().dio.get(
        '/audit/v1/admin/taxes',
        queryParameters: search.isNotEmpty ? {"search": search} : {},
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        pajakAdminModel = PajakAdminModel.fromJson(response.data);
        notifyListeners();
        if (withLoading) loading(false);
      }
    } on DioException catch (e) {
      final message = e.response?.data["messages"]?["error"] ?? e.message;
      loading(false);
      throw Exception(message);
    } catch (e) {
      loading(false);
      throw Exception(e.toString());
    }
  }

  Future<void> fetchSubditAdmin({
    bool withLoading = false,
    String search = '',
  }) async {
    if (withLoading) loading(true);

    try {
      final response = await ApiClient().dio.get(
        '/audit/v1/admin/sub-direktorates',
        queryParameters: search.isNotEmpty ? {"search": search} : {},
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        subditAdminModel = SubditAdminModel.fromJson(response.data);
        notifyListeners();
        if (withLoading) loading(false);
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

  Future<void> fetchKategoriAdmin({
    bool withLoading = false,
    String search = '',
  }) async {
    if (withLoading) loading(true);

    try {
      final response = await ApiClient().dio.get(
        '/audit/v1/admin/categories',
        queryParameters: search.isNotEmpty ? {"search": search} : {},
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        kategoriAdminModel = KategoriAdminModel.fromJson(response.data);
        notifyListeners();
        if (withLoading) loading(false);
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

  Future<void> sendKategori(
    BuildContext context, {
    bool withLoading = false,
    String? kategoriid,
  }) async {
    Utils.showFailed(msg: 'Fitur ini belum tersedia pada API backend.');
  }

  TextEditingController provinsiSearchC = TextEditingController();

  Future<void> fetchProvinsiAdmin({bool withLoading = false}) async {
    if (withLoading) loading(true);
    Map<String, dynamic> param = {};
    if (provinsiSearchC.text.isNotEmpty)
      param.addAll({'search': provinsiSearchC.text});

    try {
      final response = await ApiClient().dio.get(
        '/provinces',
        queryParameters: param,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        provinsiAdminModel = ProvinsiAdminModel.fromJson(response.data);
        notifyListeners();
        if (withLoading) loading(false);
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

  TextEditingController kotaSearchC = TextEditingController();

  Future<void> fetchKotaAdmin({bool withLoading = false}) async {
    if (withLoading) loading(true);
    Map<String, dynamic> param = {};
    if (kotaSearchC.text.isNotEmpty) param.addAll({'search': kotaSearchC.text});
    param.addAll({'prov_id': "${selectedProvince ?? 0}"});

    try {
      final response = await ApiClient().dio.get(
        '/cities',
        queryParameters: param,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        kotaAdminModel = KotaAdminModel.fromJson(response.data);
        notifyListeners();
        if (withLoading) loading(false);
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

  Future<void> sendAlamat(
    BuildContext context, {
    bool withLoading = false,
    String? alamatId,
  }) async {
    Utils.showFailed(msg: 'Fitur ini belum tersedia pada API backend.');
  }

  Future<void> deleteAlamat({
    bool withLoading = false,
    String? alamatId,
  }) async {
    Utils.showFailed(msg: 'Fitur hapus ini belum tersedia pada API backend.');
  }

  Future<void> sendPajak(
    BuildContext context, {
    bool withLoading = false,
    String? pajakId,
  }) async {
    Utils.showFailed(msg: 'Fitur ini belum tersedia pada API backend.');
  }

  fetchMateraiAdmin({bool withLoading = true, String search = ""}) async {
    if (withLoading) loading(true);

    try {
      final response = await ApiClient().dio.get(
        '/audit/v1/admin/materais',
        queryParameters: search.isNotEmpty ? {"search": search} : {},
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        print('FETCH MATERAI RESPONSE: ${response.data}');
        materaiAdminModel = MateraiAdminModel.fromJson(response.data);
        notifyListeners();
      } else {
        Utils.showFailed(
          msg: response.data?['message'] ?? 'Gagal mengambil data materai',
        );
      }

      if (withLoading) loading(false);
    } catch (e) {
      if (withLoading) loading(false);
      Utils.showFailed(msg: 'Terjadi Kesalahan: $e');
    }
  }

  Future<void> sendMaterai(
    BuildContext context, {
    bool withLoading = false,
    String? materaiId,
  }) async {
    Utils.showFailed(msg: 'Fitur ini belum tersedia pada API backend.');
  }

  Future<void> sendSubdit(
    BuildContext context, {
    bool withLoading = false,
    String? subditId,
  }) async {
    if (withLoading) loading(true);
    var param = {
      'subdit_code': subditCodeC.text,
      'subdit_name': subditNameC.text,
    };

    try {
      dynamic response;
      if (subditId != null) {
        response = await ApiClient().dio.put(
          '/audit/v1/admin/sub-direktorates/$subditId',
          data: param,
        );
      } else {
        response = await ApiClient().dio.post(
          '/audit/v1/admin/sub-direktorates',
          data: param,
        );
      }

      if (response.statusCode == 201 || response.statusCode == 200) {
        final message = response.data['message'] ?? 'Berhasil';
        notifyListeners();
        await Utils.showSuccess(msg: message);
        await Future.delayed(Duration(seconds: 2), () {});
        CusNav.nPushReplace(context, const DataSubditAdminView());
        if (withLoading) loading(false);
      }
    } on DioException catch (e) {
      var decoded = e.response?.data;
      String errorMessage = 'Terjadi kesalahan saat menyimpan data.';
      if (decoded != null && decoded['message'] != null) {
        errorMessage = decoded['message'];
      }
      if (decoded != null && decoded['errors'] != null) {
        final errors = decoded['errors'] as Map<String, dynamic>;
        if (errors.isNotEmpty) {
          errorMessage = errors.values.first[0].toString();
        }
      }
      loading(false);
      throw Exception(errorMessage);
    } catch (e) {
      loading(false);
      throw Exception(e.toString());
    }
  }
}
