import 'dart:io';
import 'dart:ui';

import 'package:mspeed/src/buyer/home/model/home_model.dart';
import 'package:mspeed/src/buyer/home/view/home_buyer_view.dart';
import 'package:mspeed/src/buyer/notifikasi/view/notifikasi_view.dart';
import 'package:mspeed/src/buyer/profil/view/akun_saya_view.dart';
import 'package:mspeed/src/buyer/wishlist/view/wishlist_view.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainHome extends StatefulWidget {
  final int? index;

  const MainHome({super.key, this.index});

  @override
  State<MainHome> createState() => _MainHomeState();
}

class _MainHomeState extends State<MainHome> {
  int currentIndex = 0;
  late HomeModel homeModel;
  String? roles;

  // Palet Warna M-SPEED
  final Color mRed = const Color(0xFFE50012);

  @override
  void initState() {
    getData();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    roles = ModalRoute.of(context)?.settings.arguments as String?;
    super.didChangeDependencies();
  }

  getData() async {
    setIndex();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {});
  }

  setIndex() {
    setState(() {
      if (widget.index != null) {
        currentIndex = widget.index ?? 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      primary: true,
      extendBody: true, 
      body: SafeArea(
        bottom: false,
        child: WillPopScope(
          onWillPop: () async {
            if (currentIndex != 0) {
              setState(() => currentIndex = 0);
              return false;
            }
            return true;
          },
          child: [
            HomeBuyerView(),
            WishlistView(), 
            NotificationView(),
            AkunSayaView()
          ][currentIndex],
        ),
      ),
      bottomNavigationBar: _buildGlassBottomNav(),
    );
  }

  // --- WIDGET FLOATING APPLE GLASSMORPHISM (FROSTED WHITE) ---
  Widget _buildGlassBottomNav() {
    return SafeArea(
      child: Container(
        height: 70,
        margin: const EdgeInsets.only(left: 20, right: 20, bottom: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(35),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08), // Bayangan hitam netral yang lembut
              blurRadius: 20,
              spreadRadius: 2,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(35),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                // Dasar kaca berwarna putih salju semi-transparan
                color: Colors.white.withOpacity(0.7), 
                borderRadius: BorderRadius.circular(35),
                // Efek pantulan cahaya di pinggiran
                border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildNavItem(0, 'Beranda', Icons.home_rounded),
                  _buildNavItem(1, 'Wishlist', Icons.favorite_rounded),
                  _buildNavItem(2, 'Notifikasi', Icons.notifications_rounded),
                  _buildNavItem(3, 'Akun', Icons.person_rounded),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- LOGIKA ANIMASI: MERAH HANYA UNTUK MENU AKTIF ---
  Widget _buildNavItem(int index, String label, IconData icon) {
    final bool isSelected = currentIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() => currentIndex = index);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutQuint,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 16.0 : 12.0,
          vertical: 10.0,
        ),
        decoration: BoxDecoration(
          // Background MERAH hanya diaplikasikan jika tombol ini sedang di-select
          color: isSelected ? mRed : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 26,
              // Ikon: Putih jika aktif, abu-abu gelap jika mati
              color: isSelected ? Colors.white : Colors.grey.shade600,
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutQuint,
              child: SizedBox(
                width: isSelected ? null : 0,
                child: Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white, // Teks selalu putih karena di atas background merah
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}