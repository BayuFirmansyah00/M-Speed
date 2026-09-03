import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mspeed/generated/assets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../common/helper/constant.dart';
import 'package:permission_handler/permission_handler.dart';

class SplashView extends StatefulWidget {
  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    init();
    super.didChangeDependencies();
  }

  Future<String> checkRoles() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    final roles = (prefs.getString(Constant.kSetPrefRoles) ?? '').toUpperCase();
    switch (roles) {
      case 'SELLER':
        return '/sellerHome';
      case 'PENERIMA':
      case 'RECEIVER':
        return '/penerimaHome';
      case 'KEUANGAN':
      case 'FINANCE':
        return '/keuanganHome';
      case 'MANAGER':
        return '/managerHome';
      case 'ADMIN':
      case 'AUDIT':
        return '/adminHome';
      case 'BUYER':
        return '/home';
      default:
        return '/login';
    }
  }

  void init() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(Constant.kSetPrefToken);
    final bool isLoggedIn = token != null && token.trim().isNotEmpty;
    final roles = prefs.getString(Constant.kSetPrefRoles);

    String targetRoute = '/login';
    if (isLoggedIn) {
      targetRoute = await checkRoles();
    }

    Timer(
      const Duration(seconds: 2),
      () {
        if (!mounted) return;
        Navigator.of(context).pushReplacementNamed(
          targetRoute,
          arguments: roles,
        );
      },
    );

    // await requestPermission(Permission.storage);
    // //await requestPermission(Permission.location);
    // await requestPermission(Permission.accessMediaLocation);
    // await requestPermission(Permission.manageExternalStorage);
    // await requestPermission(Permission.photos);
  }

  Future<bool> requestPermission(Permission permission) async {
    PermissionStatus status = await permission.request();
    return [PermissionStatus.granted, PermissionStatus.limited]
        .contains(status);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.white,
        // decoration: BoxDecoration(
        //   image: DecorationImage(
        //       image: AssetImage('assets/images/img-splash.jpg'),
        //       fit: BoxFit.cover),
        // ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Container(
                  margin: EdgeInsets.only(top: 180),
                  child: Center(
                      child: Image.asset(Assets.imagesImgSplashLogo))),
            ),
            SizedBox(height: 120,),
            Column(
              children: [
                Text("Supported By", style: TextStyle(
                  color: Constant.splashText,
                  fontWeight: FontWeight.w600
                )),
                SizedBox(
                    width: 130,
                    child: Image.asset(Assets.iconsIcMspeedRectangle2, scale: 7,)),
                Constant.xSizedBox32,
                Constant.xSizedBox8,
              ],
            )
          ],
        ),
      ),
    );
  }
}
