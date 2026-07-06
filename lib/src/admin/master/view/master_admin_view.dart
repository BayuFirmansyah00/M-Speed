import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mspeed/common/component/custom_appbar.dart';
import 'package:mspeed/common/component/custom_navigator.dart';
import 'package:mspeed/generated/assets.dart';
import 'package:mspeed/src/admin/master/view/data_alamat_admin.dart';
import 'package:mspeed/src/admin/master/view/data_kategori_admin.dart';
import 'package:mspeed/src/admin/master/view/data_pajak_admin.dart';
import 'package:mspeed/src/admin/master/view/data_subdit_admin_view.dart';

class MasterAdminView extends StatefulWidget {
  const MasterAdminView({super.key});

  @override
  State<MasterAdminView> createState() => _MasterAdminViewState();
}

class _MasterAdminViewState extends State<MasterAdminView> {
  @override
  Widget build(BuildContext context) {
    PreferredSizeWidget appBar() {
      return CustomAppBar.appBar(
        context,
        'Master',
        color: Colors.white,
        isCenter: true,
        titleSpacing: 24,
        textStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        isLeading: false,
      );
    }

    Widget userCard({required String title, required VoidCallback onTap, String? image}) {
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
                    image ?? Assets.svgsIcSettings,
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
                title: 'Subdit',
                image: Assets.svgsIcMasterKategori,
                onTap: () {
                  CusNav.nPush(context, DataSubditAdminView());
                }),
            userCard(
                title: 'Alamat',
                image: Assets.svgsIcMasterAlamat,
                onTap: () {
                  CusNav.nPush(context, DataAlamatAdminView());
                }),
            userCard(
                title: 'Pajak',
                image: Assets.svgsIcMasterPajak,
                onTap: () {
                  CusNav.nPush(context, DataPajakAdminView());
                }),
            userCard(
                title: 'Kategori',
                image: Assets.svgsIcMasterKategori,
                onTap: () {
                  CusNav.nPush(context, DataKategoriAdminView());
                }),
          ],
        ),
      ),
    );
  }
}
