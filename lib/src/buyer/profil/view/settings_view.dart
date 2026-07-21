import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';

import 'package:mspeed/common/component/custom_textfield.dart';
import 'package:mspeed/common/base/base_state.dart';
import 'package:mspeed/common/component/custom_button.dart';
import 'package:mspeed/src/buyer/profil/provider/profile_provider.dart';
import 'package:mspeed/utils/utils.dart';

// ─── Palet Warna ──────────────────────────────────────────────
class _SC {
  static const primary   = Color(0xFFE50012);
  static const navy      = Color(0xFF0B1F4E);
  static const green     = Color(0xFF10B981);
  static const amber     = Color(0xFFF59E0B);
  static const bg        = Color(0xFFF4F6FB);
  static const card      = Color(0xFFFFFFFF);
  static const txt1      = Color(0xFF0D1117);
  static const txt2      = Color(0xFF4A5568);
  static const txt3      = Color(0xFF9AA5B1);
  static const border    = Color(0xFFEEF0F5);

  static BoxShadow get shadow => const BoxShadow(
    color: Color(0x0D000000),
    blurRadius: 16,
    offset: Offset(0, 6),
  );
}

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends BaseState<SettingsView> {
  StreamSubscription<Position>? _geoSub;
  LatLng? _coord;
  final List<Marker> _markers = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initLocation());
  }

  @override
  void dispose() {
    _geoSub?.cancel();
    super.dispose();
  }

  Future<void> _initLocation() async {
    final p = context.read<ProfileProvider>();
    _updateMarker(p.locationCoordinate ?? const LatLng(-7.716998591265717, 113.54617994312575));

    final svcEnabled = await Geolocator.isLocationServiceEnabled();
    if (!svcEnabled) return;

    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
      if (perm == LocationPermission.denied) return;
    }
    if (perm == LocationPermission.deniedForever) return;

    _geoSub = Geolocator.getPositionStream().listen((pos) {
      if (!mounted) return;
      _updateMarker(LatLng(pos.latitude, pos.longitude));
    });
  }

  void _updateMarker(LatLng point) {
    setState(() {
      _coord = point;
      _markers
        ..clear()
        ..add(Marker(
          point: point,
          child: Container(
            decoration: BoxDecoration(
              color: _SC.primary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: _SC.primary.withValues(alpha: 0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(6),
            child: const Icon(Icons.location_on_rounded,
                color: Colors.white, size: 20),
          ),
        ));
    });
  }

  @override
  Widget build(BuildContext context) {
    final profileP = context.watch<ProfileProvider>();

    return Scaffold(
      backgroundColor: _SC.bg,
      // ── AppBar ─────────────────────────────────────────────
      appBar: AppBar(
        backgroundColor: _SC.card,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: _SC.card,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.all(10),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              decoration: BoxDecoration(
                color: _SC.bg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 17,
                color: _SC.txt1,
              ),
            ),
          ),
        ),
        title: const Text(
          'Pengaturan Akun',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: _SC.txt1,
            letterSpacing: -0.3,
          ),
        ),
      ),
      // ── Body ───────────────────────────────────────────────
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Kartu: Informasi Pribadi ──────────────────
            _buildSectionCard(
              icon: Icons.person_rounded,
              iconColor: _SC.navy,
              title: 'Informasi Pribadi',
              subtitle: 'Nama lengkap akun',
              child: Column(
                children: [
                  CustomTextField.borderTextField(
                    controller: profileP.firstNameC,
                    labelText: 'Nama Depan',
                    hintText: 'Masukkan nama depan',
                    required: false,
                  ),
                  const SizedBox(height: 14),
                  CustomTextField.borderTextField(
                    controller: profileP.lastNameC,
                    labelText: 'Nama Belakang',
                    hintText: 'Masukkan nama belakang',
                    required: false,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // ── Kartu: Keamanan ───────────────────────────
            _buildSectionCard(
              icon: Icons.lock_rounded,
              iconColor: _SC.green,
              title: 'Keamanan',
              subtitle: 'Ubah password akun',
              child: CustomTextField.borderTextField(
                controller: profileP.passwordC,
                obscureText: true,
                textInputType: TextInputType.visiblePassword,
                required: false,
                labelText: 'Password Baru',
                hintText: 'Masukkan password baru',
              ),
            ),
            const SizedBox(height: 14),

            // ── Kartu: Lokasi ──────────────────────────────
            _buildSectionCard(
              icon: Icons.location_on_rounded,
              iconColor: _SC.amber,
              title: 'Koordinat Default',
              subtitle: 'Tap peta untuk ubah lokasi',
              child: Column(
                children: [
                  // Map
                  Container(
                    height: 230,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: _SC.border),
                      boxShadow: [_SC.shadow],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: _coord == null
                          ? Container(
                              color: _SC.bg,
                              child: const Center(
                                child: CircularProgressIndicator(
                                  color: _SC.primary,
                                  strokeWidth: 2,
                                ),
                              ),
                            )
                          : FlutterMap(
                              options: MapOptions(
                                initialCenter: _coord!,
                                initialZoom: 15,
                                onTap: (_, point) => _updateMarker(point),
                              ),
                              children: [
                                TileLayer(
                                  urlTemplate:
                                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                  userAgentPackageName: 'com.mspeed.app',
                                ),
                                MarkerLayer(markers: _markers),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Koordinat text
                  if (_coord != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 9),
                      decoration: BoxDecoration(
                        color: _SC.bg,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: _SC.border),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.my_location_rounded,
                              size: 14, color: _SC.txt3),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${_coord!.latitude.toStringAsFixed(6)}, ${_coord!.longitude.toStringAsFixed(6)}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: _SC.txt2,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      // ── Bottom: Tombol Simpan ───────────────────────────────
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        decoration: const BoxDecoration(
          color: _SC.card,
          boxShadow: [
            BoxShadow(
              color: Color(0x0E000000),
              blurRadius: 16,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            height: 52,
            child: CustomButton.mainButton(
              'Simpan Pengaturan',
              borderRadius: BorderRadius.circular(14),
              () async {
                FocusManager.instance.primaryFocus?.unfocus();
                Utils.showSuccess(msg: 'Pengaturan berhasil disimpan');
              },
            ),
          ),
        ),
      ),
    );
  }

  // ─── Section card helper ─────────────────────────────────────
  Widget _buildSectionCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _SC.card,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [_SC.shadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 18, color: iconColor),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      color: _SC.txt1,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 11, color: _SC.txt3),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 18),
          // Content
          child,
        ],
      ),
    );
  }
}
