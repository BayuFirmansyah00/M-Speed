import 'dart:convert';

import 'package:latlong2/latlong.dart';
import 'package:mspeed/src/buyer/address/model/address_model.dart';
import 'package:mspeed/common/base/base_controller.dart';
import 'package:mspeed/common/helper/constant.dart';
import 'package:mspeed/src/buyer/address/model/address_shipping_list_model.dart';
import 'package:mspeed/src/buyer/address/model/address_shipping_detail_model.dart';
import 'package:flutter/material.dart';
import 'package:mspeed/src/buyer/address/model/akun_penerima_model.dart';
import 'package:mspeed/src/buyer/address/model/alamat_buyer_model.dart';

// import '../../cart/model/shopping_cart_confirm_model.dart';
// import '../../cart/provider/shopping_cart_provider.dart';
import '../model/street_name_model.dart';

class AddressProvider extends BaseController with ChangeNotifier {
  AddressModel _addressModel = AddressModel();
  AddressModel get addressModel => this._addressModel;
  set addressModel(AddressModel value) => this._addressModel = value;

  AddressModelData? _addressModelData = AddressModelData();
  AddressModelData? get addressModelData => this._addressModelData;
  set addressModelData(AddressModelData? value) =>
      this._addressModelData = value;
  AlamatBuyerModel? _alamatBuyerModel = AlamatBuyerModel();
  AlamatBuyerModel? get alamatBuyerModel => this._alamatBuyerModel;
  set alamatBuyerModel(AlamatBuyerModel? value) =>
      this._alamatBuyerModel = value;

  AkunPenerimaModel? _akunPenerimaModel = AkunPenerimaModel();
  AkunPenerimaModel? get akunPenerimaModel => this._akunPenerimaModel;
  set akunPenerimaModel(AkunPenerimaModel? value) =>
      this._akunPenerimaModel = value;

  AddressShippingListModel addressShippingListModel =
      AddressShippingListModel();
  AddressShippingDetailModel addressShippingDetailModel =
      AddressShippingDetailModel();

  AddressShippingListModel get getAddressShippingList =>
      this.addressShippingListModel;
  AddressShippingDetailModel get getAddressShippingDetail =>
      this.getAddressShippingDetail;

  AddressShippingListModelData? _addressShippingListModelData =
      AddressShippingListModelData();
  AddressShippingListModelData? get addressShippingListModelData =>
      this._addressShippingListModelData;

  set addressShippingListModelData(AddressShippingListModelData? value) {
    this._addressShippingListModelData = value;
    notifyListeners();
  }

  set setAddressShippingListModel(
          AddressShippingListModel addressShippingListModel) =>
      this.addressShippingListModel = addressShippingListModel;
  set setAddressShippingDetailModel(
          AddressShippingDetailModel addressShippingDetailModel) =>
      this.addressShippingDetailModel = addressShippingDetailModel;

  StreetNameModel? _streetNameModel;
  StreetNameModel? get streetNameModel => this._streetNameModel;

  bool _mainAddress = false;
  bool get mainAddress => this._mainAddress;

  set mainAddress(bool value) {
    this._mainAddress = value;
    notifyListeners();
  }

  set streetNameModel(StreetNameModel? value) {
    this._streetNameModel = value;
    notifyListeners();
  }

  TextEditingController name = TextEditingController();
  TextEditingController phone = TextEditingController();
  TextEditingController country = TextEditingController();
  TextEditingController state = TextEditingController();
  TextEditingController city = TextEditingController();
  TextEditingController address = TextEditingController();
  TextEditingController zipCode = TextEditingController();
  TextEditingController title = TextEditingController();
  TextEditingController label = TextEditingController();
  TextEditingController detail = TextEditingController();
  TextEditingController firstName = TextEditingController();
  TextEditingController lastName = TextEditingController();
  TextEditingController password = TextEditingController();
  LatLng? locationCoordinate;

  Future<void> fetchAddressPenerimaList({bool withLoading = false}) async {
    if (withLoading) loading(true);

    final response = await get(
      Constant.BASE_API_FULL + '/getalamatbuyer',
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      alamatBuyerModel = AlamatBuyerModel.fromJson(jsonDecode(response.body));
      notifyListeners();

      if (withLoading) loading(false);
    } else {
      final message = jsonDecode(response.body)["messages"]["error"];
      loading(false);
      throw Exception(message);
    }
  }

  Future<void> fetchAddressList({bool withLoading = false}) async {
    if (withLoading) loading(true);

    final response = await get(
      Constant.BASE_API_FULL + '/getbukualamatbuyer',
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      addressModel = AddressModel.fromJson(jsonDecode(response.body));
      notifyListeners();

      if (withLoading) loading(false);
    } else {
      final message = jsonDecode(response.body)["messages"]["error"];
      loading(false);
      throw Exception(message);
    }
  }

  Future<void> fetchAkunPenerima({bool withLoading = false}) async {
    if (withLoading) loading(true);

    final response = await get(Constant.BASE_API_FULL + '/getpenerimabuyer');

    if (response.statusCode == 201 || response.statusCode == 200) {
      akunPenerimaModel = AkunPenerimaModel.fromJson(jsonDecode(response.body));
      notifyListeners();

      if (withLoading) loading(false);
    } else {
      final message = jsonDecode(response.body)["messages"]["error"];
      loading(false);
      throw Exception(message);
    }
  }

  AkunPenerimaModelData? _selectedPenerima;
  AkunPenerimaModelData? get selectedPenerima => this._selectedPenerima;

  set selectedPenerima(AkunPenerimaModelData? value) {
    this._selectedPenerima = value;
    notifyListeners();
  }

  AlamatBuyerModelData? _selectedAddress;
  AlamatBuyerModelData? get selectedAddress => this._selectedAddress;

  set selectedAddress(AlamatBuyerModelData? value) {
    this._selectedAddress = value;
    notifyListeners();
  }

  String? _selectedPenerimaID;
  String? get selectedPenerimaID => this._selectedPenerimaID;

  set selectedPenerimaID(String? value) {
    this._selectedPenerimaID = value;
    notifyListeners();
  }

  String? _selectedAddressPenerima;
  String? get selectedAddressPenerima => this._selectedAddressPenerima;

  set selectedAddressPenerima(String? value) {  
    this._selectedAddressPenerima = value;
    notifyListeners();
  }
  

  Future<void> setBuyerAddress(
      {bool withLoading = false, bool isEdit = false}) async {
    if (withLoading) loading(true);
    Map<String, String> param = {
      "penerima_id": selectedPenerimaID ?? '',
      "alamat": selectedAddressPenerima ?? ''
    };
    final response =
        await post(Constant.BASE_API_FULL + '/setalamatbuyer', body: param);

    if (response.statusCode == 201 || response.statusCode == 200) {
      notifyListeners();

      if (withLoading) loading(false);
    } else {
      final message = jsonDecode(response.body)["messages"]["error"];
      loading(false);
      throw Exception(message);
    }
  }

  Future<void> fetchAddressShippingList({bool withLoading = false}) async {
    if (withLoading) loading(true);

    final response = await get(Constant.BASE_API_FULL + '/address');

    if (response.statusCode == 201 || response.statusCode == 200) {
      setAddressShippingListModel =
          AddressShippingListModel.fromJson(jsonDecode(response.body));
      notifyListeners();

      if (withLoading) loading(false);
    } else {
      final message = jsonDecode(response.body)["messages"]["error"];
      loading(false);
      throw Exception(message);
    }
  }

  setDataEditAddress() async {
    await fetchAddressShippingDetail(
        id: "${addressShippingListModelData?.id ?? 0}");
    final data = addressShippingDetailModel.data;
    name.text = data?.name ?? "";
    phone.text = data?.phone ?? "";
    address.text = data?.address ?? "";
    title.text = data?.title ?? "";
    streetNameModel = StreetNameModel(
      displayName: data?.address ?? "",
      address: StreetNameModelAddress(
        country: data?.country ?? "",
        state: data?.state ?? "",
        city: data?.city ?? "",
        postcode: data?.zipCode ?? "",
      ),
    );
    locationCoordinate = LatLng(double.parse(data?.latitude ?? "0"),
        double.parse(data?.longitude ?? "0"));
    mainAddress = data?.isDefault == 1 ? true : false;
  }

  Future<void> fetchAddressShippingDetail(
      {bool withLoading = false, required String id}) async {
    if (withLoading) loading(true);

    final response = await get(Constant.BASE_API_FULL + '/address/$id');

    if (response.statusCode == 201 || response.statusCode == 200) {
      setAddressShippingDetailModel =
          AddressShippingDetailModel.fromJson(jsonDecode(response.body));
      notifyListeners();

      if (withLoading) loading(false);
    } else {
      final message = jsonDecode(response.body)["messages"]["error"];
      loading(false);
      throw Exception(message);
    }
  }

  Future<void> sendAddress(
      {bool withLoading = false, bool isEdit = false}) async {
    if (withLoading) loading(true);
    Map<String, String> param = {
      "name": name.text,
      "phone": phone.text,
      "country": streetNameModel?.address?.country ?? "",
      "state": streetNameModel?.address?.state ?? "",
      "city": streetNameModel?.address?.city ?? "",
      "address": streetNameModel?.displayName ?? "",
      "zip_code": streetNameModel?.address?.postcode ?? "",
      "is_default": mainAddress ? "1" : "0",
      "title": title.text,
      "latitude": "${locationCoordinate?.latitude ?? 0}",
      "longitude": "${locationCoordinate?.longitude ?? 0}",
    };
    final response = await post(
        Constant.BASE_API_FULL +
            '/address${isEdit ? '/${addressShippingListModelData?.id ?? 0}' : ''}',
        body: param);

    if (response.statusCode == 201 || response.statusCode == 200) {
      notifyListeners();

      if (withLoading) loading(false);
    } else {
      final message = jsonDecode(response.body)["messages"]["error"];
      loading(false);
      throw Exception(message);
    }
  }

  Future<void> deleteAddress({bool withLoading = false}) async {
    if (withLoading) loading(true);

    final response = await delete(Constant.BASE_API_FULL +
        '/address/${addressShippingListModelData?.id ?? 0}');

    if (response.statusCode == 201 || response.statusCode == 200) {
      notifyListeners();

      if (withLoading) loading(false);
    } else {
      final message = jsonDecode(response.body)["messages"]["error"];
      loading(false);
      throw Exception(message);
    }
  }

  clearAddressForm() {
    name.clear();
    phone.clear();
    address.clear();
    streetNameModel = null;
    title.clear();
    locationCoordinate = null;
    mainAddress = false;
  }

  // Future<void> fetchAddressShippingDefault(BuildContext context,
  //     {bool withLoading = false}) async {
  //   if (withLoading) loading(true);

  //   final response = await get(Constant.BASE_API_FULL + '/address');

  //   if (response.statusCode == 201 || response.statusCode == 200) {
  //     final cartP = context.read<ShoppingCartProvider>();
  //     final addressP = context.read<AddressProvider>();
  //     setAddressShippingListModel =
  //         AddressShippingListModel.fromJson(jsonDecode(response.body));
  //     final addressList = addressP.getAddressShippingList.data ?? [];

  //     AddressShippingListModelData? addr;
  //     for (int i = 0; i < addressList.length; i++) {
  //       if (addressList[i]?.isDefault == 1) {
  //         addr = addressList[i];
  //         break;
  //       }
  //     }
  //     // log("ADDR : ${addr?.address}");
  //     // log("SELECTED ADDRESS 1 : ${cartP.selectedAddress?.address}");
  //     // jika ada yang default maka pilih yg default
  //     // if (cartP.selectedAddress == null) {
  //     if (addr != null) {
  //       // log("YA");
  //       cartP.selectedAddress = ShoppingCartConfirmModelDataAddress(
  //           address: addr.address, name: addr.name, phone: addr.phone);
  //     } else {
  //       // log("TIDAK");
  //       // jika TIDAK ada yang default maka pilih yg pertamma
  //       cartP.selectedAddress = ShoppingCartConfirmModelDataAddress(
  //           address: addressList.first?.address,
  //           name: addressList.first?.name,
  //           phone: addressList.first?.phone);
  //     }
  //     // }

  //     log("SELECTED ADDRESS : ${cartP.selectedAddress?.address}");
  //     notifyListeners();

  //     if (withLoading) loading(false);
  //   } else {
  //     final message = jsonDecode(response.body)["messages"]["error"];
  //     loading(false);
  //     throw Exception(message);
  //   }
  // }
}
