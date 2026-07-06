import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:geocoding/geocoding.dart';

import '../../../../common/base/base_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart'; // Added for TextEditingController
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart'; // Import for LatLng

import '../model/street_name_model.dart';
import '../view/custom_map_view.dart';

class CustomMapProvider extends BaseController with ChangeNotifier {
  TextEditingController searchController = TextEditingController();
  String? _displayName;
  String? _name;
  LatLng? _center;
  bool _movingFlag = false;

  String? get displayName => _displayName;

  set displayName(String? value) {
    _displayName = value;
    notifyListeners();
  }

  get name => _name;

  set name(value) {
    _name = value;
    notifyListeners();
  }

  LatLng? get center => _center;

  set center(LatLng? value) {
    _center = value;
    notifyListeners();
  }

  get movingFlag => _movingFlag;

  set movingFlag(value) {
    _movingFlag = value;
    notifyListeners();
  }

  StreamSubscription? getStreetNameSubs;
  late CustomMapViewState state;

  void init(CustomMapViewState state) {
    this.state = state;
    notifyListeners();
  }

  Future<String> getPlacemarks(double lat, double long) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, long);

      var address = '';

      if (placemarks.isNotEmpty) {
        // Concatenate non-null components of the address
        var streets = placemarks.reversed
            .map((placemark) => placemark.street)
            .where((street) => street != null);

        // Filter out unwanted parts
        streets = streets.where((street) =>
            street!.toLowerCase() !=
            placemarks.reversed.last.locality!
                .toLowerCase()); // Remove city names
        streets = streets
            .where((street) => !street!.contains('+')); // Remove street codes

        address += streets.join(', ');

        address += ', ${placemarks.reversed.last.subLocality ?? ''}';
        address += ', ${placemarks.reversed.last.locality ?? ''}';
        address += ', ${placemarks.reversed.last.subAdministrativeArea ?? ''}';
        address += ', ${placemarks.reversed.last.administrativeArea ?? ''}';
        address += ', ${placemarks.reversed.last.postalCode ?? ''}';
        address += ', ${placemarks.reversed.last.country ?? ''}';
      }

      print("Your Address for ($lat, $long) is: $address");

      return address;
    } catch (e) {
      print("Error getting placemarks: $e");
      return "No Address";
    }
  }

  Future<StreetNameModel?> getStreetName(double lat, double lng) async {
    var client = http.Client();
    String url =
        'https://nominatim.openstreetmap.org/reverse?lat=$lat&lon=$lng&format=json';

    if (kDebugMode) {
      log(url);
    }

    // final response = await get(url);

    final response = await client.get(Uri.parse(url));
    if (kDebugMode) {
      log(response.body);
    }

    if (response.statusCode == 200) {
      final model = StreetNameModel.fromJson(jsonDecode(response.body));
      return model;
    } else {
      final message = jsonDecode(response.body)["messages"]["error"];
      throw Exception(message);
    }
  }

  Future<void> dispose() async {
    searchController.dispose();
    displayName = null;
    name = null;

    // No map controller to dispose as we're using flutter_map
  }

  Future<void> focusToCoordinate(double latitude, double longitude) async {
    // No map controller to move as we're using flutter_map
    center = LatLng(latitude, longitude);
    notifyListeners();
  }

  Future<LatLng> getCenter() async {
    // Since there's no map controller, we just return the current center
    return _center ?? LatLng(0, 0); // Default to (0,0) if center is not set
  }

  void onCameraMove() async {
    if (getStreetNameSubs != null) {
      await getStreetNameSubs!.cancel();
    }
    final center = this.center ?? await getCenter();
    print('get street name');
    getStreetNameSubs = getStreetName(center.latitude, center.longitude)
        // getStreetNameSubs = getPlacemarks(center.latitude, center.longitude)
        .asStream()
        .listen((event) {
      // log('street name: $event');
      // searchController.text = event;
      // displayName = event;
      // name = event;
      log('street name: ${event?.displayName}');
      searchController.text = event?.displayName ?? "-";
      displayName = event?.displayName ?? "-";
      name = event?.name ?? "-";

      notifyListeners();
    });
  }
}
