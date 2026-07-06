import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:mspeed/common/component/custom_appbar.dart';
import '../provider/search_location_provider.dart';
import 'custom_map_view.dart';

class SearchLocationView extends StatefulWidget {
  final LatLng currentLocation;

  const SearchLocationView(this.currentLocation, {Key? key}) : super(key: key);

  static Widget create(LatLng currentLocation) => ChangeNotifierProvider(
      create: (context) => SearchLocationProvider(),
      child: SearchLocationView(currentLocation));

  @override
  State<SearchLocationView> createState() => _SearchLocationViewState();
}

class _SearchLocationViewState extends State<SearchLocationView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar.appBar(context, "Pilih Lokasi",
          color: Colors.white, foregroundColor: Colors.black),
      body: CustomMapView(
        center: LatLng(
          widget.currentLocation.latitude,
          widget.currentLocation.longitude,
        ),
        onPicked: (pickedData) {
          print(pickedData.latLong.toJson());
          Navigator.pop(context, pickedData);
        },
      ),
    );
  }

  @override
  dispose() {
    super.dispose();
    // context.read<SearchLocationProvider>().mapController.future.then((value) {
    //   value.dispose();
    // });
  }
}
