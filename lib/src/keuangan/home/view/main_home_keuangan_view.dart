import 'package:flutter/material.dart';
import 'package:mspeed/generated/assets.dart';
import 'package:mspeed/src/keuangan/chat/view/list_chat_pesanan_view.dart';
import 'package:mspeed/src/keuangan/pesanan/view/list_pesanan_view.dart';

class MainHomeKeuanganView extends StatefulWidget {
  const MainHomeKeuanganView({Key? key}) : super(key: key);

  @override
  _MainHomeKeuanganViewState createState() => _MainHomeKeuanganViewState();
}

class _MainHomeKeuanganViewState extends State<MainHomeKeuanganView> {
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

  void dispose() {
    // Hapus sumber daya yang tidak perlu disimpan
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(child: _widgetOptions.elementAt(_selectedIndex)),
      ),
      bottomNavigationBar: SafeArea(
        child: BottomNavigationBar(
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon:
                  _selectedIndex == 0
                      ? Image.asset(Assets.iconsIcPesananKeuanganOn, scale: 2)
                      : Image.asset(Assets.iconsIcPesananKeuanganOff, scale: 2),
              label: 'Pesanan',
            ),
            BottomNavigationBarItem(
              icon:
                  _selectedIndex == 1
                      ? Image.asset(Assets.iconsIcChatOn, scale: 4)
                      : Image.asset(Assets.iconsIcChatOff, scale: 4),
              label: 'Pesan',
            ),
          ],
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
