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
        '/buyer-addresses',
        queryParameters: search.isNotEmpty ? {"search": search} : {},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        alamatAdminModel = AlamatAdminModel.fromJson(response.data);
        notifyListeners();
      }
      if (withLoading) loading(false);
    } on DioException catch (e) {
      final message = e.response?.data["message"] ?? 'Terjadi kesalahan saat memuat alamat';
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
        '/taxs',
        queryParameters: search.isNotEmpty ? {"search": search} : {},
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        pajakAdminModel = PajakAdminModel.fromJson(response.data);
        notifyListeners();
        if (withLoading) loading(false);
      }
    } on DioException catch (e) {
      final message = e.response?.data["message"] ?? 'Terjadi kesalahan';
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
        '/categories',
        queryParameters: search.isNotEmpty ? {"search": search} : {},
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        kategoriAdminModel = KategoriAdminModel.fromJson(response.data);
        notifyListeners();
        if (withLoading) loading(false);
      }
    } on DioException catch (e) {
      final message = e.response?.data["message"] ?? 'Terjadi kesalahan';
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
    if (withLoading) loading(true);
    var param = {
      'name': namaKategoriC.text,
      'status': '1',
    };

    try {
      dynamic response;
      if (kategoriid != null) {
        response = await ApiClient().dio.put(
          '/categories/$kategoriid',
          data: param,
        );
      } else {
        response = await ApiClient().dio.post(
          '/categories',
          data: param,
        );
      }

      if (response.statusCode == 201 || response.statusCode == 200) {
        notifyListeners();
        await Utils.showSuccess(msg: 'Berhasil menyimpan kategori');
        await Future.delayed(const Duration(seconds: 2));
        CusNav.nPushReplace(context, const DataKategoriAdminView());
        if (withLoading) loading(false);
      }
    } on DioException catch (e) {
      final message = e.response?.data["message"] ?? 'Terjadi kesalahan';
      loading(false);
      throw Exception(message);
    } catch (e) {
      loading(false);
      throw Exception(e.toString());
    }
  }

  Future<void> deleteKategori(
    BuildContext context, {
    bool withLoading = false,
    required String kategoriId,
  }) async {
    if (withLoading) loading(true);
    try {
      final response = await ApiClient().dio.delete('/categories/$kategoriId');
      if (response.statusCode == 201 || response.statusCode == 200) {
        await Utils.showSuccess(msg: 'Berhasil menghapus kategori');
        await fetchKategoriAdmin(withLoading: true);
        if (withLoading) loading(false);
      }
    } on DioException catch (e) {
      final message = e.response?.data["message"] ?? 'Terjadi kesalahan';
      loading(false);
      throw Exception(message);
    } catch (e) {
      loading(false);
      throw Exception(e.toString());
    }
  }

  TextEditingController provinsiSearchC = TextEditingController();

  Future<void> fetchProvinsiAdmin({bool withLoading = false}) async {
    if (withLoading) loading(true);

    try {
      final response = await ApiClient().dio.get(
        '/provinces',
        queryParameters: provinsiSearchC.text.isNotEmpty ? {"search": provinsiSearchC.text} : {},
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        provinsiAdminModel = ProvinsiAdminModel.fromJson(response.data);
        notifyListeners();
        if (withLoading) loading(false);
      }
    } on DioException catch (e) {
      final message = e.response?.data["message"] ?? 'Terjadi kesalahan';
      loading(false);
      throw Exception(message);
    } catch (e) {
      loading(false);
      throw Exception(e.toString());
    }
  }

  Future<void> sendProvinsi(
    BuildContext context, {
    bool withLoading = false,
    String? provinsiId,
  }) async {
    if (withLoading) loading(true);
    var param = {
      'name': provinceC.text,
    };

    try {
      dynamic response;
      if (provinsiId != null) {
        response = await ApiClient().dio.put('/provinces/$provinsiId', data: param);
      } else {
        response = await ApiClient().dio.post('/provinces', data: param);
      }

      if (response.statusCode == 201 || response.statusCode == 200) {
        notifyListeners();
        await Utils.showSuccess(msg: 'Berhasil menyimpan provinsi');
        await Future.delayed(const Duration(seconds: 2));
        CusNav.nPop(context);
        if (withLoading) loading(false);
      }
    } on DioException catch (e) {
      final message = e.response?.data["message"] ?? 'Terjadi kesalahan';
      loading(false);
      throw Exception(message);
    } catch (e) {
      loading(false);
      throw Exception(e.toString());
    }
  }

  Future<void> deleteProvinsi(
    BuildContext context, {
    bool withLoading = false,
    required String provinsiId,
  }) async {
    if (withLoading) loading(true);
    try {
      final response = await ApiClient().dio.delete('/provinces/$provinsiId');
      if (response.statusCode == 201 || response.statusCode == 200) {
        await Utils.showSuccess(msg: 'Berhasil menghapus provinsi');
        await fetchProvinsiAdmin(withLoading: true);
        if (withLoading) loading(false);
      }
    } on DioException catch (e) {
      final message = e.response?.data["message"] ?? 'Terjadi kesalahan';
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

    try {
      final response = await ApiClient().dio.get(
        '/cities',
        queryParameters: kotaSearchC.text.isNotEmpty ? {"search": kotaSearchC.text} : {},
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        kotaAdminModel = KotaAdminModel.fromJson(response.data);
        notifyListeners();
        if (withLoading) loading(false);
      }
    } on DioException catch (e) {
      final message = e.response?.data["message"] ?? 'Terjadi kesalahan';
      loading(false);
      throw Exception(message);
    } catch (e) {
      loading(false);
      throw Exception(e.toString());
    }
  }

  Future<void> sendKota(
    BuildContext context, {
    bool withLoading = false,
    String? kotaId,
  }) async {
    if (withLoading) loading(true);
    var param = {
      'name': cityC.text,
      'province_id': selectedProvince,
    };

    try {
      dynamic response;
      if (kotaId != null) {
        response = await ApiClient().dio.put('/cities/$kotaId', data: param);
      } else {
        response = await ApiClient().dio.post('/cities', data: param);
      }

      if (response.statusCode == 201 || response.statusCode == 200) {
        notifyListeners();
        await Utils.showSuccess(msg: 'Berhasil menyimpan kota');
        await Future.delayed(const Duration(seconds: 2));
        CusNav.nPop(context);
        if (withLoading) loading(false);
      }
    } on DioException catch (e) {
      final message = e.response?.data["message"] ?? 'Terjadi kesalahan';
      loading(false);
      throw Exception(message);
    } catch (e) {
      loading(false);
      throw Exception(e.toString());
    }
  }

  Future<void> deleteKota(
    BuildContext context, {
    bool withLoading = false,
    required String kotaId,
  }) async {
    if (withLoading) loading(true);
    try {
      final response = await ApiClient().dio.delete('/cities/$kotaId');
      if (response.statusCode == 201 || response.statusCode == 200) {
        await Utils.showSuccess(msg: 'Berhasil menghapus kota');
        await fetchKotaAdmin(withLoading: true);
        if (withLoading) loading(false);
      }
    } on DioException catch (e) {
      final message = e.response?.data["message"] ?? 'Terjadi kesalahan';
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
    if (namaC.text.isEmpty ||
        nomorTeleponC.text.isEmpty ||
        alamatC.text.isEmpty ||
        selectedCity == null) {
      Utils.showFailed(msg: 'Mohon lengkapi semua data alamat');
      return;
    }

    if (withLoading) loading(true);
    try {
      final param = {
        "name": alamatC.text,
        "recipient_name": namaC.text,
        "phone": nomorTeleponC.text,
        "detail": alamatC.text,
        "status": statusValue.toString(),
        "city_id": selectedCity,
      };

      dynamic response;
      if (alamatId != null) {
        response = await ApiClient().dio.put(
          '/buyer-addresses/$alamatId',
          data: param,
        );
      } else {
        response = await ApiClient().dio.post(
          '/buyer-addresses',
          data: param,
        );
      }

      if (response.statusCode == 201 || response.statusCode == 200) {
        notifyListeners();
        await Utils.showSuccess(msg: 'Berhasil menyimpan alamat');
        await Future.delayed(const Duration(seconds: 2));
        CusNav.nPushReplace(context, const DataAlamatAdminView());
      }
      if (withLoading) loading(false);
    } on DioException catch (e) {
      loading(false);
      final message = e.response?.data["message"] ?? 'Terjadi kesalahan';
      Utils.showFailed(msg: message);
    } catch (e) {
      loading(false);
      Utils.showFailed(msg: e.toString());
    }
  }

  Future<void> deleteAlamat({
    bool withLoading = false,
    String? alamatId,
  }) async {
    if (withLoading) loading(true);
    try {
      final response = await ApiClient().dio.delete('/buyer-addresses/$alamatId');
      if (response.statusCode == 201 || response.statusCode == 200) {
        await Utils.showSuccess(msg: 'Berhasil menghapus alamat');
        await fetchAlamatAdmin(withLoading: true);
      }
      if (withLoading) loading(false);
    } on DioException catch (e) {
      loading(false);
      final message = e.response?.data["message"] ?? 'Terjadi kesalahan';
      Utils.showFailed(msg: message);
    } catch (e) {
      loading(false);
      Utils.showFailed(msg: e.toString());
    }
  }

  Future<void> sendPajak(
    BuildContext context, {
    bool withLoading = false,
    String? pajakId,
  }) async {
    if (withLoading) loading(true);
    var param = {
      'name': pajakC.text,
      'percentage': prosentaseC.text,
      'type': typePajakC.text.isNotEmpty ? typePajakC.text : '1',
    };

    try {
      dynamic response;
      if (pajakId != null) {
        response = await ApiClient().dio.put(
          '/taxs/$pajakId',
          data: param,
        );
      } else {
        response = await ApiClient().dio.post(
          '/taxs',
          data: param,
        );
      }

      if (response.statusCode == 201 || response.statusCode == 200) {
        notifyListeners();
        await Utils.showSuccess(msg: 'Berhasil menyimpan pajak');
        await Future.delayed(const Duration(seconds: 2));
        CusNav.nPushReplace(context, const DataPajakAdminView());
        if (withLoading) loading(false);
      }
    } on DioException catch (e) {
      final message = e.response?.data["message"] ?? 'Terjadi kesalahan';
      loading(false);
      throw Exception(message);
    } catch (e) {
      loading(false);
      throw Exception(e.toString());
    }
  }

  Future<void> deletePajak(
    BuildContext context, {
    bool withLoading = false,
    required String pajakId,
  }) async {
    if (withLoading) loading(true);
    try {
      final response = await ApiClient().dio.delete('/taxs/$pajakId');
      if (response.statusCode == 201 || response.statusCode == 200) {
        await Utils.showSuccess(msg: 'Berhasil menghapus pajak');
        await fetchPajakAdmin(withLoading: true);
        if (withLoading) loading(false);
      }
    } on DioException catch (e) {
      final message = e.response?.data["message"] ?? 'Terjadi kesalahan';
      loading(false);
      throw Exception(message);
    } catch (e) {
      loading(false);
      throw Exception(e.toString());
    }
  }

  Future<void> fetchMateraiAdmin({bool withLoading = true, String search = ""}) async {
    if (withLoading) loading(true);

    try {
      final response = await ApiClient().dio.get(
        '/materais',
        queryParameters: search.isNotEmpty ? {"search": search} : {},
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        materaiAdminModel = MateraiAdminModel.fromJson(response.data);
        notifyListeners();
        if (withLoading) loading(false);
      }
    } on DioException catch (e) {
      final message = e.response?.data["message"] ?? 'Terjadi kesalahan';
      loading(false);
      throw Exception(message);
    } catch (e) {
      loading(false);
      throw Exception(e.toString());
    }
  }

  Future<void> sendMaterai(
    BuildContext context, {
    bool withLoading = false,
    String? materaiId,
  }) async {
    if (withLoading) loading(true);
    var param = {
      'name': typeMateraiC.text, // StoreMateraiRequest expects 'name'
      'nominal': nominalMateraiC.text,
    };

    try {
      dynamic response;
      if (materaiId != null) {
        response = await ApiClient().dio.put(
          '/materais/$materaiId',
          data: param,
        );
      } else {
        response = await ApiClient().dio.post(
          '/materais',
          data: param,
        );
      }

      if (response.statusCode == 201 || response.statusCode == 200) {
        notifyListeners();
        await Utils.showSuccess(msg: 'Berhasil menyimpan materai');
        await Future.delayed(const Duration(seconds: 2));
        CusNav.nPushReplace(context, const DataMateraiAdminView());
        if (withLoading) loading(false);
      }
    } on DioException catch (e) {
      final message = e.response?.data["message"] ?? 'Terjadi kesalahan';
      loading(false);
      throw Exception(message);
    } catch (e) {
      loading(false);
      throw Exception(e.toString());
    }
  }

  Future<void> deleteMaterai(
    BuildContext context, {
    bool withLoading = false,
    required String materaiId,
  }) async {
    if (withLoading) loading(true);
    try {
      final response = await ApiClient().dio.delete('/materais/$materaiId');
      if (response.statusCode == 201 || response.statusCode == 200) {
        await Utils.showSuccess(msg: 'Berhasil menghapus materai');
        await fetchMateraiAdmin(withLoading: true);
        if (withLoading) loading(false);
      }
    } on DioException catch (e) {
      final message = e.response?.data["message"] ?? 'Terjadi kesalahan';
      loading(false);
      throw Exception(message);
    } catch (e) {
      loading(false);
      throw Exception(e.toString());
    }
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
