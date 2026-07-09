import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:mspeed/src/buyer/profil/model/akun_saya_buyer_model.dart';
import 'package:mspeed/common/base/base_controller.dart';
import 'package:mspeed/common/helper/constant.dart';
import 'package:flutter/material.dart';
import 'package:mspeed/utils/utils.dart';

class ProfileProvider extends BaseController with ChangeNotifier {
  AkunSayaBuyerModel _akunBuyerModel = AkunSayaBuyerModel();

  AkunSayaBuyerModel get akunBuyerModel => _akunBuyerModel;

  set akunBuyerModel(AkunSayaBuyerModel value) {
    _akunBuyerModel = value;
  }

  // --- CONTROLLER PENGATURAN AKUN ---
  final TextEditingController firstNameC = TextEditingController();
  final TextEditingController lastNameC = TextEditingController();
  final TextEditingController passwordC = TextEditingController();
  
  // Tipe data diubah menjadi LatLng agar aman saat Type Checking
  LatLng? locationCoordinate; 
  String? locationName;

  String formatRupiah(String price) {
    final formatter = NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);
    return formatter.format(int.parse(price));
  }

  // FILTER
  String? selectedPeriodeData = '0';
  Map<String, String> periodeData = {
    'Hari ini': '0',
    'Periode Data Harian': '1',
    'Periode Data Bulanan': '2',
    'Periode Data Tahunan': '3',
  };
  
  DateTime? _selectedDate;
  DateTime? get selectedDate => this._selectedDate;
  set selectedDate(DateTime? value) => this._selectedDate = value;

  String? _selectedMonth;
  String? get selectedMonth => this._selectedMonth;
  set selectedMonth(String? value) => this._selectedMonth = value;

  String? _selectedYear;
  String? get selectedYear => this._selectedYear;
  set selectedYear(String? value) => this._selectedYear = value;

  List<String>? timeList = [];

  Future<void> fetchAkunSaya(BuildContext context, {bool withLoading = true, required String idBuyer}) async {
    if (withLoading) loading(true);

    Map<String, String> body = {};

    if (selectedPeriodeData == 'Hari Ini' && selectedDate != null) {
      selectedDate = DateTime.now();
      selectedMonth = DateFormat('MM').format(DateTime.now());
      selectedYear = DateFormat('yyyy').format(DateTime.now());
      body.addAll({
        'user_id': idBuyer,
        'status': '1',
        'date': DateFormat('yyyy-MM-dd').format(DateTime.now()),
        'month': DateFormat('MM').format(DateTime.now()),
        'year': DateFormat('yyyy').format(DateTime.now()),
      });
    }

    if (selectedPeriodeData == 'Harian' && selectedDate != null) {
      body.addAll({
        'user_id': idBuyer,
        'status': '1',
        'date': DateFormat('yyyy-MM-dd').format(selectedDate!),
      });
    }

    if (selectedPeriodeData == 'Bulanan' && selectedMonth != null && selectedYear != null) {
      body.addAll({
        'user_id': idBuyer,
        'status': '2',
        'month': selectedMonth!,
        'year': selectedYear!,
      });
    }

    if (selectedPeriodeData == 'Tahunan' && selectedYear != null) {
      body.addAll({
        'user_id': idBuyer,
        'status': '3',
        'year': selectedYear!,
      });
    }

    final response = await get(Constant.BASE_API_FULL + '/getakunsayabuyer', body: body);

    if (response.statusCode == 201 || response.statusCode == 200) {
      akunBuyerModel = AkunSayaBuyerModel.fromJson(jsonDecode(response.body));
      notifyListeners();
      if (withLoading) loading(false);
    } else {
      final message = jsonDecode(response.body)["messages"]["error"];
      loading(false);
      if (message.toString().contains("Unauthorized")) {
        Utils.showFailed(msg: "Unauthorized");
        Future.delayed(const Duration(seconds: 1)).then((value) {
          Navigator.pushReplacementNamed(context, '/login');
        });
      }
      throw Exception(message);
    }
  }

  Future<void> fetchBuyer(BuildContext context, {bool withLoading = true, required String idBuyer}) async {
    if (withLoading) loading(true);

    final response = await get(Constant.BASE_API_FULL + '/getakunsayabuyer', body: {'user_id': idBuyer});

    if (response.statusCode == 201 || response.statusCode == 200) {
      akunBuyerModel = AkunSayaBuyerModel.fromJson(jsonDecode(response.body));
      notifyListeners();
      if (withLoading) loading(false);
    } else {
      final message = jsonDecode(response.body)["messages"]["error"];
      loading(false);
      if (message.toString().contains("Unauthorized")) {
        Utils.showFailed(msg: "Unauthorized");
        Future.delayed(const Duration(seconds: 1)).then((value) {
          Navigator.pushReplacementNamed(context, '/login');
        });
      }
      throw Exception(message);
    }
  }
}