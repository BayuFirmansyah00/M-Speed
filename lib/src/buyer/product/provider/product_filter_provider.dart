
import 'package:flutter/material.dart';
import 'package:mspeed/common/base/base_controller.dart';

class ProductFilterProvider extends BaseController with ChangeNotifier {
  bool _allFiter = true;
  bool get allFiter => this._allFiter;

  set allFiter(bool value) => this._allFiter = value;

  Map<String, bool> listFilter = {};
  Map<String, bool> get getListFilter => this.listFilter;

  void setListFilterIndex(String k, bool v) {
    listFilter.forEach((k, v) {
      listFilter[k] = false;
    });
    // if (listFilter[k] == true && !v) {
    //   listFilter[k] = v;
    // } else {
    listFilter[k] = v;
    // }
    notifyListeners();
  }

  // category
  bool _tape = false;
  bool _hardware = false;
  bool _bearing = false;
  bool _machinery = false;
  bool _safetyEquipment = false;
  bool _lubricants = false;

  bool get tape => this._tape;

  set tape(bool value) => this._tape = value;

  bool get hardware => this._hardware;

  set hardware(value) {
    this._hardware = value;
    notifyListeners();
  }

  bool get bearing => this._bearing;

  set bearing(value) {
    this._bearing = value;
    notifyListeners();
  }

  bool get machinery => this._machinery;

  set machinery(value) {
    this._machinery = value;
    notifyListeners();
  }

  bool get safetyEquipment => this._safetyEquipment;

  set safetyEquipment(value) {
    this._safetyEquipment = value;
    notifyListeners();
  }

  bool get lubricants => this._lubricants;

  set lubricants(value) {
    this._lubricants = value;
    notifyListeners();
  }

  //brand
  bool _dwyer = false;
  bool _fluke = false;
  bool _dca = false;
  bool _krisbow = false;

  bool get dwyer => this._dwyer;

  set dwyer(bool value) {
    this._dwyer = value;
    notifyListeners();
  }

  bool get fluke => this._fluke;

  set fluke(value) {
    this._fluke = value;
    notifyListeners();
  }

  bool get dca => this._dca;

  set dca(value) {
    this._dca = value;
    notifyListeners();
  }

  bool get krisbow => this._krisbow;

  set krisbow(value) {
    this._krisbow = value;
    notifyListeners();
  }

  //location

  bool _surabaya = false;
  bool _dkiJakarta = false;
  bool _bandung = false;
  bool _bali = false;

  bool get surabaya => this._surabaya;

  set surabaya(bool value) {
    this._surabaya = value;
    notifyListeners();
  }

  bool get dkiJakarta => this._dkiJakarta;

  set dkiJakarta(bool value) {
    this._dkiJakarta = value;
    notifyListeners();
  }

  bool get bandung => this._bandung;

  set bandung(bool value) {
    this._bandung = value;
    notifyListeners();
  }

  bool get bali => this._bali;

  set bali(bool value) {
    this._bali = value;
    notifyListeners();
  }

  //promo
  bool _flashSale = false;
  bool _gratisOngkir = false;
  bool _cashback = false;
  bool _bonusProduk = false;

  bool get flashSale => this._flashSale;

  set flashSale(bool value) {
    this._flashSale = value;
    notifyListeners();
  }

  bool get gratisOngkir => this._gratisOngkir;

  set gratisOngkir(value) {
    this._gratisOngkir = value;
    notifyListeners();
  }

  bool get cashback => this._cashback;

  set cashback(value) {
    this._cashback = value;
    notifyListeners();
  }

  bool get bonusProduk => this._bonusProduk;

  set bonusProduk(value) {
    this._bonusProduk = value;
    notifyListeners();
  }

  //color
  bool _yellow = false;
  bool _green = false;
  bool _black = false;

  bool get yellow => this._yellow;

  set yellow(bool value) {
    this._yellow = value;
    notifyListeners();
  }

  bool get green => this._green;

  set green(bool value) {
    this._green = value;
    notifyListeners();
  }

  bool get black => this._black;

  set black(bool value) {
    this._black = value;
    notifyListeners();
  }
}
