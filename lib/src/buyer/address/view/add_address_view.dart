import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:mspeed/common/component/custom_dropdown.dart';
import 'package:mspeed/common/helper/Constant.dart';
import 'package:mspeed/src/buyer/region/provider/region_provider.dart';
import 'package:provider/provider.dart';
import 'package:mspeed/common/component/custom_appbar.dart';
import 'package:mspeed/common/component/custom_textfield.dart';
import 'package:mspeed/src/buyer/address/provider/address_provider.dart';
import 'package:mspeed/utils/Utils.dart';

import '../../../../common/base/base_state.dart';
import '../../../../common/component/custom_button.dart';

class AddAddressView extends StatefulWidget {
  final bool isEdit;

  AddAddressView({super.key, this.isEdit = false});

  @override
  State<AddAddressView> createState() => _AddAddressViewState();
}

class _AddAddressViewState extends BaseState<AddAddressView> {
  late StreamSubscription<Position> geolocatorSubscription;

  LatLng? locationCoordinate;
  String? locationName;

  final List<Marker> _markers = [];

  String? selectedProvinceName;
  String? selectedCityName;
  String? selectedDistrictName;

  @override
  void initState() {
    super.initState();
    setData();

    geolocatorSubscription =
        Geolocator.getPositionStream().listen(geolocatorListener);
  }

  @override
  void dispose() {
    geolocatorSubscription.cancel();
    super.dispose();
  }

  void setData() async {
    final regionP = context.read<RegionProvider>();
    await regionP.fetchProvince();

    if (widget.isEdit) {
      var p = context.read<AddressProvider>();
      await p.setDataEditAddress();
      setState(() {
        if (p.locationCoordinate != null) {
          locationCoordinate = p.locationCoordinate!;
          locationName = p.address.text;
          _markers.clear();
          _markers.add(
            Marker(
              point: locationCoordinate!,
              child: Icon(Icons.location_on, color: Colors.red),
            ),
          );
        }
        selectedProvinceName = p.state.text.isNotEmpty ? p.state.text : null;
        selectedCityName = p.city.text.isNotEmpty ? p.city.text : null;
      });

      if (selectedProvinceName != null) {
        final provData = regionP.provinceModel.data;
        final selectedProv = provData?.firstWhere(
          (e) => e?.province?.toLowerCase() == selectedProvinceName?.toLowerCase(),
          orElse: () => null,
        );
        if (selectedProv != null && selectedProv.provinceId != null) {
          await regionP.fetchCity(selectedProv.provinceId!);
          if (selectedCityName != null) {
            final cityData = regionP.cityModel.data;
            final selectedCity = cityData?.firstWhere(
              (e) => e?.cityName?.toLowerCase() == selectedCityName?.toLowerCase(),
              orElse: () => null,
            );
            if (selectedCity != null && selectedCity.cityId != null) {
              await regionP.fetchDistrict(selectedCity.cityId!);
            }
          }
        }
      }
    }
  }

  void geolocatorListener(Position event) {
    locationCoordinate = LatLng(event.latitude, event.longitude);
    _markers.clear();
    _markers.add(
      Marker(
        point: locationCoordinate!,
        child: Icon(Icons.location_on, color: Colors.red),
      ),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final addAddressP = context.watch<AddressProvider>();
    final regionP = context.watch<RegionProvider>();

    return Scaffold(
      backgroundColor: const Color(0xffF5F6FA),
      appBar: CustomAppBar.appBar(
        context,
        "${widget.isEdit ? "Edit" : "Tambah"} Alamat",
        color: Colors.white,
        foregroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Color(0xffE2E4E9), width: 1),
                    ),
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomTextField.borderTextField(
                          controller: addAddressP.name,
                          labelText: "Nama Penerima",
                          hintText: "Masukkan nama penerima",
                        ),
                        SizedBox(height: 16),
                        CustomTextField.borderTextField(
                          controller: addAddressP.phone,
                          labelText: "No. Telepon",
                          hintText: "Contoh: 081234567890",
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d?')),
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          textInputType: TextInputType.number,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Color(0xffE2E4E9), width: 1),
                    ),
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomDropdown.searchDropdown(
                          labelText: "Provinsi",
                          hintText: "Pilih Provinsi",
                          selectedItem: selectedProvinceName,
                          list: regionP.provinceModel.data
                                  ?.map((e) => e?.province ?? '')
                                  .where((e) => e.isNotEmpty)
                                  .toList() ??
                              [],
                          onChanged: (val) async {
                            if (val != null && val != selectedProvinceName) {
                              setState(() {
                                selectedProvinceName = val;
                                selectedCityName = null;
                                selectedDistrictName = null;
                                addAddressP.state.text = val;
                                addAddressP.city.clear();
                                addAddressP.zipCode.clear();
                              });
                              final prov = regionP.provinceModel.data?.firstWhere(
                                (e) => e?.province == val,
                                orElse: () => null,
                              );
                              if (prov != null && prov.provinceId != null) {
                                await regionP.fetchCity(prov.provinceId!);
                              }
                            }
                          },
                        ),
                        SizedBox(height: 16),
                        CustomDropdown.searchDropdown(
                          labelText: "Kota / Kabupaten",
                          hintText: "Pilih Kota / Kabupaten",
                          selectedItem: selectedCityName,
                          list: regionP.cityModel.data
                                  ?.map((e) => e?.cityName ?? '')
                                  .where((e) => e.isNotEmpty)
                                  .toList() ??
                              [],
                          onChanged: (val) async {
                            if (val != null && val != selectedCityName) {
                              setState(() {
                                selectedCityName = val;
                                selectedDistrictName = null;
                                addAddressP.city.text = val;
                                addAddressP.zipCode.clear();
                              });
                              final cityObj = regionP.cityModel.data?.firstWhere(
                                (e) => e?.cityName == val,
                                orElse: () => null,
                              );
                              if (cityObj != null) {
                                addAddressP.zipCode.text = cityObj.postalCode ?? '';
                                if (cityObj.cityId != null) {
                                  await regionP.fetchDistrict(cityObj.cityId!);
                                }
                              }
                            }
                          },
                        ),
                        SizedBox(height: 16),
                        CustomDropdown.searchDropdown(
                          labelText: "Kecamatan",
                          hintText: "Pilih Kecamatan",
                          selectedItem: selectedDistrictName,
                          list: regionP.districtModel.data
                                  ?.map((e) => e?.districtName ?? '')
                                  .where((e) => e.isNotEmpty)
                                  .toList() ??
                              [],
                          onChanged: (val) {
                            if (val != null && val != selectedDistrictName) {
                              setState(() {
                                selectedDistrictName = val;
                              });
                            }
                          },
                        ),
                        SizedBox(height: 16),
                        CustomTextField.borderTextField(
                          controller: addAddressP.zipCode,
                          labelText: "Kode Pos",
                          hintText: "Masukkan kode pos",
                          textInputType: TextInputType.number,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Color(0xffE2E4E9), width: 1),
                    ),
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomTextField.borderTextArea(
                          labelText: "Alamat Lengkap",
                          controller: addAddressP.address,
                          focusNode: FocusNode(),
                        ),
                        SizedBox(height: 16),
                        CustomTextField.borderTextField(
                          controller: addAddressP.detail,
                          labelText: "Detail Alamat (Blok / Unit, No, Patokan)",
                          hintText: "Contoh: Rumah warna hijau pagar hitam",
                        ),
                        SizedBox(height: 16),
                        CustomTextField.borderTextField(
                          controller: addAddressP.title,
                          labelText: "Label Alamat",
                          hintText: "Contoh: Rumah, Kantor",
                        ),
                        SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Atur Sebagai Alamat Utama",
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            Switch(
                              value: addAddressP.mainAddress,
                              activeColor: Constant.primaryColor,
                              onChanged: (val) {
                                addAddressP.mainAddress = val;
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
                    child: Text(
                      "Pilih Titik Lokasi (Map)",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Container(
                    height: 250,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Color(0xffE2E4E9), width: 1),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: FlutterMap(
                      options: MapOptions(
                        initialCenter:
                            locationCoordinate ?? LatLng(-7.1144282, 112.4069792),
                        initialZoom: 15,
                        onMapReady: () {
                          // Map ready logic
                        },
                        onTap: (tapPosition, point) {
                          setState(() {
                            locationCoordinate = point;
                            _markers.clear();
                            _markers.add(
                              Marker(
                                point: locationCoordinate!,
                                child: Icon(Icons.location_on, color: Colors.red),
                              ),
                            );
                          });
                        },
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                          userAgentPackageName: 'com.mspeed.app',
                        ),
                        MarkerLayer(
                          markers: _markers,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        child: CustomButton.mainButton(
          'Simpan',
          borderRadius: BorderRadius.circular(12),
          () async {
            await context
                .read<AddressProvider>()
                .sendAddress(withLoading: true, isEdit: widget.isEdit)
                .then((value) async {
              Utils.showSuccess(
                  msg: "Sukses ${widget.isEdit ? "Edit" : "Tambah"} Alamat");
              await Future.delayed(Duration(seconds: 2));
              Navigator.pop(context, true);
              addAddressP.clearAddressForm();
              return true;
            }).onError((error, stackTrace) async {
              Utils.showFailed(
                  msg: "Gagal ${widget.isEdit ? "Edit" : "Tambah"} Alamat");
              await Future.delayed(Duration(seconds: 2));
              return false;
            });
          },
        ),
      ),
    );
  }
}
