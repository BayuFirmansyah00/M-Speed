import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:mspeed/common/component/custom_dropdown.dart';
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
    if (widget.isEdit) {
      var p = context.read<AddressProvider>();
      await p.setDataEditAddress();
      setState(() {
        if (p.locationCoordinate != null) {
          locationCoordinate = p.locationCoordinate!;
          locationName = p.address.text;
          _markers.add(
            Marker(
              point: locationCoordinate!,
              child: Icon(Icons.location_on, color: Colors.red),
            ),
          );
        }
      });
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
    return Scaffold(
      backgroundColor: Colors.white,
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomTextField.borderTextField(
                    controller: addAddressP.name,
                    labelText: "Nama Lengkap",
                  ),
                  SizedBox(height: 12),
                  CustomTextField.borderTextField(
                    controller: addAddressP.phone,
                    labelText: "No Telp",
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d?')),
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    textInputType: TextInputType.number,
                  ),
                  SizedBox(height: 12),
                  CustomDropdown.normalDropdown(
                    labelText: "Kota",
                    hintText: "Select",
                    controller: addAddressP.city,
                    onChanged: (v) {
                      if (v != null) {
                        addAddressP.city.text = v;
                      }
                    },
                    list: [
                      DropdownMenuItem(
                          child: Text("Jawa Barat"), value: "Jawa Barat"),
                      DropdownMenuItem(
                          child: Text("Jawa Tengah"), value: "Jawa Tengah"),
                      // Add more options as needed
                    ],
                  ),
                  SizedBox(height: 12),
                  CustomDropdown.normalDropdown(
                    labelText: "Kecamatan",
                    hintText: "Select",
                    controller: addAddressP.state,
                    onChanged: (v) {
                      if (v != null) {
                        addAddressP.state.text = v;
                      }
                    },
                    list: [
                      DropdownMenuItem(
                          child: Text("Kecamatan 1"), value: "Kecamatan 1"),
                      DropdownMenuItem(
                          child: Text("Kecamatan 2"), value: "Kecamatan 2"),
                      // Add more options as needed
                    ],
                  ),
                  SizedBox(height: 12),
                  CustomTextField.borderTextArea(
                    labelText: "Alamat",
                    controller: addAddressP.address,
                    focusNode: FocusNode(),
                  ),
                  SizedBox(height: 12),
                  CustomTextField.borderTextField(
                    controller: addAddressP.detail,
                    labelText: "Detail Lainnya (Blok / Unit, No, Patokan)",
                  ),
                  SizedBox(height: 12),
                  CustomTextField.borderTextField(
                    controller: addAddressP.label,
                    labelText: "Label",
                  ),
                ],
              ),
            ),
          ),
          Container(
            height: 300, // Adjust height as needed
            child: FlutterMap(
              options: MapOptions(
                initialCenter:
                    locationCoordinate ?? LatLng(-7.1144282, 112.4069792),
                initialZoom: 15,
                onMapReady: () {
                  // Optional: Add logic if needed when the map is ready
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
                  urlTemplate:
                      "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                  subdomains: ['a', 'b', 'c'],
                ),
                MarkerLayer(
                  markers: _markers,
                ),
              ],
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
