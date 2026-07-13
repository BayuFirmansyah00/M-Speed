import 'package:flutter/material.dart';
import 'package:mspeed/common/component/custom_appbar.dart';
import 'package:mspeed/src/buyer/cart/view/shopping_cart_view.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  @override
Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar.appBar(context, "Akun Saya", isCenter: true, action: [
        Badge(
          label: Text(
              // (cartP.getShoppingCartModel.data?.countItem ?? 0)
              "0"),
          // textColor: (0
          //     // cartP.getShoppingCartModel.data?.countItem != 0
          // )
          //     ? Color.fromRGBO(11, 30, 64, 1)
          //     : Color.fromRGBO(11, 30, 64, 0),
          backgroundColor:
          // (cartP.getShoppingCartModel.data?.countItem != 0)
          //     ?
          Color.fromRGBO(245, 195, 75, 1),
              // : Color.fromRGBO(11, 30, 64, 0),
          child: InkWell(
            onTap: () async {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ShoppingCartView()));
              },
            child: Container(
              child: Center(
                child: ImageIcon(
                  AssetImage("assets/icons/ic_cart.png"),
                  size: 15,
                ),
              ),
            ),
          ),
        )
      ]),
    );
  }
}