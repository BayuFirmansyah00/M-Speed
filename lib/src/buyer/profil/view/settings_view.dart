import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';

import 'package:mspeed/common/component/custom_appbar.dart';
import 'package:mspeed/common/component/custom_textfield.dart';
import 'package:mspeed/common/base/base_state.dart';
import 'package:mspeed/common/component/custom_button.dart';
import 'package:mspeed/src/buyer/profil/provider/profile_provider.dart';
import 'package:mspeed/utils/utils.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends BaseState<SettingsView> {
  StreamSubscription<Position>? geolocatorSubscription;
  LatLng? locationCoordinate;
  final List<Marker> _markers = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initLocationAndData();
    });
  }

  @override
  void dispose() {
    geolocatorSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initLocationAndData() async {
    final p = context.read<ProfileProvider>();
    
    // Tipe sudah strict LatLng, tidak perlu pengecekan 'is dynamic'
    if (p.locationCoordinate != null) {
      _updateMarker(p.locationCoordinate!);
    } else {
      _updateMarker(const LatLng(-7.716998591265717, 113.54617994312575));
    }

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    
    if (permission == LocationPermission.deniedForever) return;

    geolocatorSubscription = Geolocator.getPositionStream().listen(_geolocatorListener);
  }

  void _geolocatorListener(Position event) {
    if (!mounted) return;
    _updateMarker(LatLng(event.latitude, event.longitude));
  }

  void _updateMarker(LatLng point) {
    setState(() {
      locationCoordinate = point;
      _markers.clear();
      _markers.add(
        Marker(
          point: locationCoordinate!,
          child: const Icon(Icons.location_on, color: Colors.red, size: 32),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final profileP = context.watch<ProfileProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: CustomAppBar.appBar(
        context,
        "Pengaturan Akun",
        color: Colors.white,
        isCenter: true,
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))
                ]
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Informasi Pribadi", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 16),
                  CustomTextField.borderTextField(
                    controller: profileP.firstNameC,
                    labelText: "Nama Depan",
                    hintText: "Masukkan nama depan",
                    required: false,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField.borderTextField(
                    controller: profileP.lastNameC,
                    labelText: "Nama Belakang",
                    hintText: "Masukkan nama belakang",
                    required: false,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))
                ]
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Keamanan", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 16),
                  CustomTextField.borderTextField(
                    controller: profileP.passwordC,
                    obscureText: true,
                    textInputType: TextInputType.visiblePassword,
                    required: false,
                    labelText: "Ganti Password",
                    hintText: "Masukkan password baru",
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text("  Koordinat Default", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black54)),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                height: 250, 
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFEEEEEE)),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: locationCoordinate == null 
                  ? const Center(child: CircularProgressIndicator())
                  : FlutterMap(
                      options: MapOptions(
                        initialCenter: locationCoordinate!, 
                        initialZoom: 15,
                        onTap: (tapPosition, point) => _updateMarker(point),
                      ),
                      children: [
                      TileLayer(
                          urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                          // KUNCI PERBAIKAN: Menambahkan identitas aplikasi agar tidak diblokir OSM
                          userAgentPackageName: 'com.mspeed.app', 
                        ),
                        MarkerLayer(markers: _markers),
                      ],
                    ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05), 
              spreadRadius: 0, 
              blurRadius: 10, 
              offset: const Offset(0, -4)
            ),
          ],
        ),
        child: SafeArea(
          // KUNCI PERBAIKAN: Bungkus dengan SizedBox untuk mengunci tinggi maksimal button
          child: SizedBox(
            height: 50, 
            child: CustomButton.mainButton(
              'Simpan Pengaturan',
              borderRadius: BorderRadius.circular(12),
              () async {
                FocusManager.instance.primaryFocus?.unfocus(); 
                Utils.showSuccess(msg: "Pengaturan berhasil disimpan");
              },
            ),
          ),
        ),
      ),
    );
  }
}