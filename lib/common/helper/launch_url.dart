import 'dart:io';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:map_launcher/map_launcher.dart';

class LaunchUrl {
  Future<void> launchUrlApp(Uri url) async {
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  Future<void> launchWhatsApp(
      String message, String phone, BuildContext context) async {
    String path = "";
    if (Platform.isAndroid) {
      // add the [https]
      path = "https://wa.me/$phone/?text=${Uri.parse(message)}"; // new line
    } else {
      // add the [https]
      path =
          "https://api.whatsapp.com/send?phone=$phone=${Uri.parse(message)}"; // new line
    }
    if (!await launchUrl(Uri.parse(path))) {
      // Widgets.showSnackBar(context, "Whatsapp tidak terinstal", false);
      LaunchUrl().launchUrlApp(Uri.parse(
          "https://play.google.com/store/apps/details?id=com.whatsapp&hl=en"));
      Navigator.pop(context);
      throw Exception('Could not launch $path');
    }
  }

  Future<void> launchGoogleMap(double latitude, double longitude, String title,
      String description) async {
    if (await MapLauncher.isMapAvailable(
            Platform.isAndroid ? MapType.google : MapType.apple) ??
        false) {
      await MapLauncher.showMarker(
        mapType: Platform.isAndroid ? MapType.google : MapType.apple,
        coords: Coords(latitude, longitude),
        title: title,
        description: description,
      );
    }
  }
}
