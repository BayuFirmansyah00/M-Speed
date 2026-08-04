import 'dart:convert';

import 'package:mspeed/common/base/base_response.dart';
import 'package:mspeed/common/component/custom_navigator.dart';
import 'package:mspeed/src/admin/master/model/alamat_admin_model.dart';
import 'package:mspeed/src/admin/master/model/kategori_admin_model.dart';
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

  final TextEditingController provinceC = TextEditingController();
  final TextEditingController cityC = TextEditingController();
  final TextEditingController alamatC = TextEditingController();
  String? selectedProvince;
  String? selectedCity;

  final TextEditingController pajakC = TextEditingController();
  final TextEditingController prosentaseC = TextEditingController();

  final TextEditingController namaKategoriC = TextEditingController();

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
    }
  }

  setDataPajak(PajakAdminModelData? pajak) async {
    clearData();
    await fetchPajakAdmin();
    if (pajak != null) {
      pajakC.text = pajak.nama ?? '';
      prosentaseC.text = pajak.persentase ?? '';
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

  Future<void> fetchAlamatAdmin(
      {bool withLoading = false, String search = ''}) async {
    if (withLoading) loading(true);

    try {
      final response = await ApiClient().dio.get('/getalamatadmin',
          queryParameters: search.isNotEmpty ? {"search": search} : {});

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

  Future<void> fetchPajakAdmin(
      {bool withLoading = false, String search = ''}) async {
    if (withLoading) loading(true);

    try {
      final response = await ApiClient().dio.get('/getpajakadmin',
          queryParameters: search.isNotEmpty ? {"search": search} : {});

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

  Future<void> fetchSubditAdmin(
      {bool withLoading = false, String search = ''}) async {
    if (withLoading) loading(true);

    try {
      final response = await ApiClient().dio.get('/audit/v1/admin/sub-direktorates',
          queryParameters: search.isNotEmpty ? {"search": search} : {});

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

  Future<void> fetchKategoriAdmin(
      {bool withLoading = false, String search = ''}) async {
    if (withLoading) loading(true);

    try {
      final response = await ApiClient().dio.get('/categories',
          queryParameters: search.isNotEmpty ? {"search": search} : {});

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

  Future<void> sendKategori(BuildContext context,
      {bool withLoading = false, String? kategoriid}) async {
    if (withLoading) loading(true);
    var param = {'nama': namaKategoriC.text};
    var url = '/createkategoriadmin';
    if (kategoriid != null) {
      url = '/editkategoriadmin';
      param.addAll({'kategori_id': kategoriid});
    }
    
    try {
      final response = await ApiClient().dio.post(url, data: param);
      if (response.statusCode == 201 || response.statusCode == 200) {
        final message = response.data['message'] ?? 'Berhasil';
        notifyListeners();
        await Utils.showSuccess(msg: message);
        await Future.delayed(Duration(seconds: 2), () {});
        CusNav.nPushReplace(context, DataKategoriAdminView());
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

  TextEditingController provinsiSearchC = TextEditingController();

  Future<void> fetchProvinsiAdmin({bool withLoading = false}) async {
    if (withLoading) loading(true);
    Map<String, dynamic> param = {};
    if (provinsiSearchC.text.isNotEmpty)
      param.addAll({'search': provinsiSearchC.text});
    
    try {
      final response = await ApiClient().dio.get('/provinces', queryParameters: param);

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
      final response = await ApiClient().dio.get('/cities', queryParameters: param);

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

  Future<void> sendAlamat(BuildContext context,
      {bool withLoading = false, String? alamatId}) async {
    if (withLoading) loading(true);
    var param = {
      'prov_id': "${selectedProvince}",
      'kota_id': "${selectedCity}",
      'nama': alamatC.text,
    };
    if (alamatId != null) param.addAll({'alamat_id': alamatId});

    try {
      final response = await ApiClient().dio.post(
          '/${alamatId != null ? 'edit' : 'create'}alamatadmin',
          data: param);

      if (response.statusCode == 201 || response.statusCode == 200) {
        final message = response.data['message'] ?? 'Berhasil';
        notifyListeners();
        await Utils.showSuccess(msg: message);
        await Future.delayed(Duration(seconds: 2), () {});
        CusNav.nPushReplace(context, DataAlamatAdminView());
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

  Future<void> deleteAlamat(
      {bool withLoading = false, String? alamatId}) async {
    if (withLoading) loading(true);

    try {
      final response = await ApiClient().dio.post('/hapusalamatadmin',
          data: {'alamat_id': alamatId});

      if (response.statusCode == 201 || response.statusCode == 200) {
        final message = response.data['message'] ?? 'Berhasil';
        notifyListeners();
        await Utils.showSuccess(msg: message);
        await Future.delayed(Duration(seconds: 2), () {});
        if (withLoading) loading(false);
        fetchAlamatAdmin(withLoading: true);
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

  Future<void> sendPajak(BuildContext context,
      {bool withLoading = false, String? pajakId}) async {
    if (withLoading) loading(true);
    var param = {
      'nama': pajakC.text,
      'persentase': prosentaseC.text,
    };
    if (pajakId != null) param.addAll({'pajak_id': pajakId});

    try {
      final response = await ApiClient().dio.post(
          '/${pajakId != null ? 'edit' : 'create'}pajakadmin',
          data: param);

      if (response.statusCode == 201 || response.statusCode == 200) {
        final message = response.data['message'] ?? 'Berhasil';
        notifyListeners();
        await Utils.showSuccess(msg: message);
        await Future.delayed(Duration(seconds: 2), () {});
        CusNav.nPushReplace(context, DataAlamatAdminView());
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
}
