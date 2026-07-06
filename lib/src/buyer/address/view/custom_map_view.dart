import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mspeed/src/seller/profil/provider/profile_seller_provider.dart';
import 'package:provider/provider.dart';
import 'package:mspeed/common/component/custom_button.dart';
import 'package:mspeed/common/component/custom_container.dart';
import 'package:mspeed/common/helper/constant.dart';
import 'package:mspeed/src/buyer/address/model/street_name_model.dart';
import 'package:http/http.dart' as http;
import 'package:mspeed/src/buyer/address/provider/address_provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../provider/custom_map_provider.dart';

class CustomMapView extends StatefulWidget {
  final LatLng center;
  final void Function(PickedData pickedData) onPicked;
  Color buttonColor;
  String buttonText;

  CustomMapView({
    Key? key,
    required this.center,
    required this.onPicked,
    this.buttonColor = Colors.blue,
    this.buttonText = 'Pilih Lokasi',
  }) : super(key: key);

  @override
  State<CustomMapView> createState() => CustomMapViewState();
}

class CustomMapViewState extends State<CustomMapView> {
  String? displayName;
  String? name;
  final FocusNode _focusNode = FocusNode();
  List<OSMdata> _options = <OSMdata>[];
  Timer? _debounce;
  var client = http.Client();

  void setNameCurrentPosAtInit() async {
    final p = context.read<CustomMapProvider>();
    final profileP = context.read<ProfileSellerProvider>();
    final streetNameModel =
        // await p.getPlacemarks(widget.center.latitude, widget.center.longitude);
        await p.getStreetName(widget.center.latitude, widget.center.longitude);
    setState(() {
      // p.searchController.text = streetNameModel;
      // p.displayName = streetNameModel;
      // p.name = streetNameModel;
      p.searchController.text = streetNameModel?.displayName ?? "";
      p.displayName = streetNameModel?.displayName;
      p.name = streetNameModel?.name;
      profileP.addressC.text = streetNameModel?.displayName ?? "";
      profileP.latC.text = streetNameModel?.lat ?? "";
      profileP.lngC.text = streetNameModel?.lon ?? "";
      var address = streetNameModel?.address;
      var provinsi = address?.state;
      var kota = address?.county;
      if (address != null && provinsi != null) {
        profileP.provinceC.text = provinsi;
        profileP.selectedProvince = provinsi;
        var index =
            profileP.provinsiModel?.data?.indexWhere((e) => e == provinsi) ??
                -1;
        if (index != -1 && profileP.provinsiModel?.data?[index]?.nama != null) {
          setState(() {
            profileP.selectedProvinceId =
                profileP.provinsiModel?.data?[index]?.ID ?? '';
          });
        }
      }
      if (address != null && kota != null) {
        profileP.cityC.text = kota;
        profileP.selectedCity = kota;

        var index =
            profileP.kotaModel?.data?.indexWhere((e) => e == kota) ?? -1;
        if (index != -1 && profileP.kotaModel?.data?[index]?.kota != null) {
          setState(() {
            profileP.selectedCityId =
                profileP.kotaModel?.data?[index]?.ID ?? '';
          });
        }
      }
    });
  }

  @override
  void initState() {
    context.read<CustomMapProvider>().init(this);
    setNameCurrentPosAtInit();
    super.initState();
  }

  @override
  void dispose() {
    // context.read<CustomMapProvider>().dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    OutlineInputBorder inputBorder = OutlineInputBorder(
      borderSide: BorderSide(color: widget.buttonColor, width: 1),
      borderRadius: BorderRadius.circular(32),
    );
    OutlineInputBorder inputFocusBorder = OutlineInputBorder(
      borderSide: BorderSide(color: widget.buttonColor, width: 1),
      borderRadius: BorderRadius.circular(32),
    );
    final p = context.watch<CustomMapProvider>();
    return SafeArea(
      child: Stack(
        children: [
          wMap(),
          Center(
            child: Container(
              margin: EdgeInsets.only(bottom: 42),
              child: Icon(
                Icons.location_on,
                color: Constant.primaryColor,
                size: 42,
              ),
            ),
          ),
          Positioned(
            bottom: 60,
            right: 5,
            child: FloatingActionButton(
              heroTag: 'btn3',
              backgroundColor: widget.buttonColor,
              onPressed: () async {
                p.focusToCoordinate(
                  widget.center.latitude,
                  widget.center.longitude,
                );
              },
              child: Icon(Icons.my_location),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              margin: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
              ),
              child: Column(
                children: [
                  TextFormField(
                    controller: p.searchController,
                    focusNode: _focusNode,
                    decoration: InputDecoration(
                      hintText: 'Cari Alamat Lokasi..',
                      border: inputBorder,
                      contentPadding: EdgeInsets.zero,
                      focusedBorder: inputFocusBorder,
                      prefixIcon: Icon(Icons.search),
                      suffixIcon: InkWell(
                        onTap: () {
                          p.searchController.clear();
                          _options.clear();
                          setState(() {});
                        },
                        child: Icon(Icons.close),
                      ),
                    ),
                    onChanged: (String value) {
                      if (_debounce?.isActive ?? false) _debounce?.cancel();

                      _debounce =
                          Timer(const Duration(milliseconds: 2000), () async {
                        if (kDebugMode) {
                          log(value);
                        }
                        var client = http.Client();
                        try {
                          String url =
                              'https://nominatim.openstreetmap.org/search?q=$value&format=json&polygon_geojson=1&addressdetails=1';
                          if (kDebugMode) {
                            log(url);
                          }
                          var response = await client.get(Uri.parse(url));
                          var decodedResponse =
                              jsonDecode(utf8.decode(response.bodyBytes))
                                  as List<dynamic>;
                          if (kDebugMode) {
                            log(decodedResponse.toString());
                          }
                          _options = decodedResponse
                              .map((e) => OSMdata(
                                  displayname: e['display_name'],
                                  lat: double.parse(e['lat']),
                                  lon: double.parse(e['lon'])))
                              .toList();
                          setState(() {});
                        } finally {
                          client.close();
                        }
                      });

                      setState(() {});
                    },
                  ),
                  StatefulBuilder(builder: ((context, state) {
                    return SizedBox(
                      height:
                          (_debounce?.isActive == true || _debounce == null) ||
                                  p.searchController.text.isEmpty ||
                                  _options.isEmpty
                              ? 0
                              : MediaQuery.of(context).size.height * 0.6,
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: _options.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(_options[index].displayname),
                            subtitle: Text(
                                '${_options[index].lat},${_options[index].lon}'),
                            onTap: () {
                              p.focusToCoordinate(
                                  _options[index].lat, _options[index].lon);

                              _focusNode.unfocus();
                              _options.clear();
                              state(() {});
                              setState(() {});
                            },
                          );
                        },
                      ),
                    );
                  })),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 22,
            left: 12,
            right: 12,
            child: CustomContainer.mainCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    (p.name ?? "") == "" ? p.displayName ?? '' : '',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: Constant.semibold,
                      fontSize: 12,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    p.displayName ?? "-",
                    style: TextStyle(
                      color: Constant.borderRegularColor,
                      fontWeight: Constant.semibold,
                      fontSize: 12,
                    ),
                  ),
                  SizedBox(height: 16),
                  Center(
                    child: CustomButton.mainButton(widget.buttonText, () async {
                      pickData().then((value) {
                        widget.onPicked(value);
                      }).onError((error, stackTrace) async {
                        final center = p.center ?? await p.getCenter();
                        FirebaseCrashlytics.instance
                            .log("API Nominatim Error!");
                        widget.onPicked(PickedData(center, "-"));
                      });
                    },
                        stretched: false,
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 12, horizontal: 36)),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Future<PickedData> pickData() async {
    final p = context.read<CustomMapProvider>();
    final center = p.center ?? await p.getCenter();

    StreetNameModel? streetNameModel =
        await p.getStreetName(center.latitude, center.longitude);
    context.read<AddressProvider>().streetNameModel = streetNameModel;
    // final address = await p.getPlacemarks(center.latitude, center.longitude);
    setState(() {
      // displayName = address;
      // name = address;
      displayName = streetNameModel?.displayName;
      name = streetNameModel?.name;
    });
    // return PickedData(center, address);
    return PickedData(center, streetNameModel?.displayName ?? "");
  }

  Widget wMap() {
    final p = context.read<CustomMapProvider>();
    return FlutterMap(
      options: MapOptions(
        initialCenter: widget.center,
        initialZoom: 15,
        onMapEvent: (event) {
          if (event is MapEventMoveStart) {
            p.center = event.camera.center;
            p.onCameraMove(); // Call onCameraMove when the camera moves
            setState(() {});
          }
        },
      ),
      children: [
        TileLayer(
          urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
          subdomains: ['a', 'b', 'c'],
        ),
        // MarkerLayer(
        //   markers: [
        //     Marker(
        //       point: widget.center,
        //       child: Icon(Icons.location_on,
        //           color: Constant.primaryColor, size: 42),
        //     ),
        //   ],
        // ),
      ],
    );
  }
}

class OSMdata {
  final String displayname;
  final double lat;
  final double lon;

  OSMdata({required this.displayname, required this.lat, required this.lon});

  @override
  String toString() {
    return '$displayname, $lat, $lon';
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is OSMdata && other.displayname == displayname;
  }

  @override
  int get hashCode => Object.hash(displayname, lat, lon);
}

class PickedData {
  final LatLng latLong;
  final String address;

  PickedData(this.latLong, this.address);
}
