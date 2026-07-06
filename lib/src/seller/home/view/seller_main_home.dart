import 'dart:io';

import 'package:mspeed/src/buyer/home/model/home_model.dart';
import 'package:flutter/material.dart';
import 'package:mspeed/src/seller/home/view/home_seller_view.dart';
import 'package:mspeed/src/seller/nego/view/nego_seller_view.dart';
import 'package:mspeed/src/seller/pesanan/view/pesanan_seller_view.dart';
import 'package:mspeed/src/seller/produk/view/produk_seller_view.dart';

import 'package:shared_preferences/shared_preferences.dart';
import '../../../../common/helper/constant.dart';

class SellerMainHome extends StatefulWidget {
  final int? index;

  const SellerMainHome({super.key, this.index});

  @override
  State<SellerMainHome> createState() => _SellerMainHomeState();
}

class _SellerMainHomeState extends State<SellerMainHome> {
  int currentIndex = 0;
  late HomeModel homeModel;
  String? roles;

  @override
  void initState() {
    getData();
    // setIndex();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    roles = ModalRoute.of(context)?.settings.arguments as String?;
    // getData();
    super.didChangeDependencies();
  }

  getData() async {
    setIndex();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // roles = prefs.getString(Constant.kSetPrefRoles);
    // await Utils.showLoading();
    // await context.read<HomeProvider>().fetchHome();
    // await context.read<ProfileProvider>().fetchProfile(context: context);
    // await context.read<JamaahProvider>().fetchJamaah();
    // if (roles == "agen") await context.read<SubAgenProvider>().fetchSubAgen();
    // await context.read<ProfileProvider>().fetchSosmed();
    // await context.read<PesananProvider>().fetchNotif();
    // await Utils.dismissLoading();
    setState(() {});
  }

  setIndex() {
    setState(() {
      if (widget.index != null) {
        currentIndex = widget.index ?? 0;
      }
    });
  }

  void jumpToJamaah() {
    setState(() {
      currentIndex = 1;
    });
  }

  void jumpToSubAgen() {
    setState(() {
      currentIndex = 2;
    });
  }

  void jumpToProfile() {
    setState(() {
      if (roles == "agen") {
        currentIndex = 4;
      } else {
        currentIndex = 3;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget customBottomNav() {
      return SafeArea(
        child: Container(
          height: Platform.isAndroid ? 70 : 105,
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 4,
                blurRadius: 7,
                offset: Offset(0, 1), // changes position of shadow
              ),
            ],
          ),
          child: BottomNavigationBar(
            backgroundColor: Colors.white,
            selectedFontSize: 13,
            unselectedFontSize: 13,
            unselectedItemColor: Constant.textHintColor2,
            currentIndex: currentIndex,
            onTap: (index) {
              // context.read<PaketProvider>().clearFilter();
              setState(() => currentIndex = index);
            },
            type: BottomNavigationBarType.fixed,
            selectedIconTheme: IconThemeData(color: Constant.primaryColor),
            selectedItemColor: Constant.primaryColor,
            selectedLabelStyle: Constant.primaryBold15.copyWith(fontSize: 13),
            unselectedLabelStyle: TextStyle(
              fontSize: 13,
              color: Constant.textHintColor2,
            ),
            items: [
              BottomNavigationBarItem(
                icon: Container(
                  padding: EdgeInsets.only(bottom: 4),
                  width: 25,
                  height: 25,
                  child: FittedBox(
                    child: Image.asset(
                      currentIndex == 0
                          ? 'assets/icons/ic-home-red.png'
                          : 'assets/icons/ic-home-black.png',
                    ),
                  ),
                ),
                label: 'Beranda',
              ),
              BottomNavigationBarItem(
                icon: Container(
                  padding: EdgeInsets.only(bottom: 4),
                  width: 25,
                  height: 25,
                  child: FittedBox(
                    child: Image.asset(
                      currentIndex == 1
                          ? 'assets/icons/ic-produk-red.png'
                          : 'assets/icons/ic-produk-black.png',
                    ),
                  ),
                ),
                label: 'Produk',
              ),
              BottomNavigationBarItem(
                icon: Container(
                  padding: EdgeInsets.only(bottom: 4),
                  width: 25,
                  height: 25,
                  child: FittedBox(
                    child: Image.asset(
                      currentIndex == 2
                          ? 'assets/icons/ic-pesanan-red.png'
                          : 'assets/icons/ic-pesanan-black.png',
                    ),
                  ),
                ),
                label: 'Pesanan',
              ),
              BottomNavigationBarItem(
                icon: Container(
                  padding: EdgeInsets.only(bottom: 4),
                  width: 25,
                  height: 25,
                  child: FittedBox(
                    child: Image.asset(
                      currentIndex == 3
                          ? 'assets/icons/ic-request-nego-red.png'
                          : 'assets/icons/ic-request-nego-black.png',
                    ),
                  ),
                ),
                label: 'Permintaan Nego',
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      primary: true,
      bottomNavigationBar: customBottomNav(),
      body: SafeArea(
        child: WillPopScope(
          onWillPop: () async {
            if (currentIndex != 0) {
              setState(() => currentIndex = 0);
              return false;
            }
            // kalau sudah ada api maka muncul konfirm exit dua kali
            return true;
          },
          child:
              [
                HomeSellerView(
                  jumpToPesanan: () {
                    setState(() {
                      currentIndex = 2;
                    });
                  },
                ),
                ProdukSellerView(),
                PesananSellerView(),
                NegoSellerView(),
              ][currentIndex],
        ),
      ),
    );
  }
}
