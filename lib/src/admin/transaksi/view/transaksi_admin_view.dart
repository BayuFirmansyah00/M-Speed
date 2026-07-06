import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mspeed/common/component/custom_appbar.dart';
import 'package:mspeed/common/component/custom_navigator.dart';
import 'package:mspeed/generated/assets.dart';
import 'package:mspeed/src/admin/transaksi/view/data_dpp_admin_view.dart';
import 'package:mspeed/src/admin/transaksi/view/data_order_admin_view.dart';

class TransaksiAdminView extends StatefulWidget {
  const TransaksiAdminView({super.key});

  @override
  State<TransaksiAdminView> createState() => _TransaksiAdminViewState();
}

class _TransaksiAdminViewState extends State<TransaksiAdminView> {
  @override
  Widget build(BuildContext context) {
    PreferredSizeWidget appBar() {
      return CustomAppBar.appBar(
        context,
        'Transaksi',
        color: Colors.white,
        isCenter: true,
        titleSpacing: 24,
        textStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        isLeading: false,
      );
    }

    Widget userCard({required String title, required VoidCallback onTap}) {
      return Card(
        color: Color(0xFFFFEBE2),
        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: InkWell(
          onTap: onTap,
          child: Container(
              padding: EdgeInsets.all(30),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SvgPicture.asset(
                    Assets.svgsIcAdminTransaksi,
                    width: 24,
                    height: 24,
                    color: Colors.black,
                  ),
                  SizedBox(
                    width: 12,
                  ),
                  Text(
                    title,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
                  )
                ],
              )),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: appBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            userCard(
                title: 'Data DPP',
                onTap: () {
                  CusNav.nPush(context, DataDppAdminView());
                }),
            userCard(
                title: 'Data Order',
                onTap: () {
                  CusNav.nPush(context, DataOrderAdminView());

                }),
          ],
        ),
      ),
    );
  }
}
