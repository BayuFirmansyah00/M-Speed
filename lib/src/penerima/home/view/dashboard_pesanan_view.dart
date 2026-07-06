import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mspeed/common/helper/Constant.dart';
import 'package:mspeed/generated/assets.dart';
import 'package:mspeed/src/penerima/chat/view/list_chat_pesanan_view.dart';
import 'package:mspeed/src/penerima/pesanan/view/list_pesanan_view.dart';

class DashboardPesananView extends StatefulWidget {
  const DashboardPesananView({Key? key}) : super(key: key);

  @override
  _DashboardPesananViewState createState() => _DashboardPesananViewState();
}

class _DashboardPesananViewState extends State<DashboardPesananView> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    ListPesananView(),
    ListChatPesananView(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Image.asset(
              Assets.iconsIcPesananRed,
              width: 24,
              height: 24,
              color: _selectedIndex == 0 ? Constant.primaryColor : Colors.black,
            ),
            label: 'Pesanan',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              Assets.svgsIcChat,
              width: 24,
              height: 24,
              color: _selectedIndex == 1 ? Constant.primaryColor : Colors.black,
            ),
            label: 'Chat',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
