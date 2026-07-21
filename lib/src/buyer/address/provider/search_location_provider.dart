import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../../../../common/base/base_controller.dart';

class SearchLocationProvider extends BaseController with ChangeNotifier {
  LatLng? currentLocation;

  void updateLocation(LatLng newLocation) {
    currentLocation = newLocation;
    notifyListeners();
  }

  void init() {
    notifyListeners();
  }
}
