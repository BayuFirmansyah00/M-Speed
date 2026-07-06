import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:mspeed/common/component/custom_appbar.dart';
import 'package:mspeed/common/component/custom_textfield.dart';
import 'package:mspeed/src/buyer/address/provider/address_provider.dart';
import 'package:mspeed/utils/Utils.dart';

import '../../../../common/base/base_state.dart';
import '../../../../common/component/custom_button.dart';

class SettingsView extends StatefulWidget {
  SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends BaseState<SettingsView> {
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

  void geolocatorListener(Position event) async {
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
        "Pengaturan",
        color: Colors.white,
        isCenter: true,
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
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomTextField.borderTextField(
                    controller: addAddressP.firstName,
                    labelText: "Nama Depan",
                    required: false,
                  ),
                  SizedBox(height: 12),
                  CustomTextField.borderTextField(
                    controller: addAddressP.lastName,
                    labelText: "Nama Belakang",
                    required: false,
                  ),
                  SizedBox(height: 12),
                  CustomTextField.borderTextField(
                    controller: addAddressP.password,
                    obscureText: true,
                    textInputType: TextInputType.visiblePassword,
                    required: false,
                    labelText: "Ganti Password",
                  ),
                  SizedBox(height: 12),
                  Container(
                    height: 300, // Adjust height as needed
                    child: FlutterMap(
                      options: MapOptions(
                        initialCenter: locationCoordinate ??
                            LatLng(-7.716998591265717,
                                113.54617994312575), // Default location
                        initialZoom: 15,
                        onTap: (tapPosition, point) {
                          setState(() {
                            locationCoordinate = point;
                            _markers.clear();
                            _markers.add(
                              Marker(
                                point: locationCoordinate!,
                                child:
                                    Icon(Icons.location_on, color: Colors.red),
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
            // Implement save functionality as needed
            Utils.showSuccess(msg: "Pengaturan disimpan");
          },
        ),
      ),
    );
  }
}
