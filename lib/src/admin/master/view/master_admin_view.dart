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
  // Palet Warna Khas
  final Color appRed = const Color(0xFFED1C24);
  final Color oceanBlue = const Color(0xFF0096C7);
  final Color orangeAcc = const Color(0xFFFF9800);
  final Color yellowAcc = const Color(0xFFFFC300);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: CustomAppBar.appBar(
        context,
        'Master Data',
        color: Colors.white,
        isCenter: true,
        titleSpacing: 24,
        textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
        isLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
          child: GridView(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.15,
            ),
            children: [
              _buildMasterCard(title: 'Subdit', iconPath: Assets.svgsIcMasterKategori, color: oceanBlue, onTap: () => CusNav.nPush(context, const DataSubditAdminView())),
              _buildMasterCard(title: 'Alamat', iconPath: Assets.svgsIcMasterAlamat, color: orangeAcc, onTap: () => CusNav.nPush(context, const DataAlamatAdminView())),
              _buildMasterCard(title: 'Pajak', iconPath: Assets.svgsIcMasterPajak, color: appRed, onTap: () => CusNav.nPush(context, const DataPajakAdminView())),
              _buildMasterCard(title: 'Kategori', iconPath: Assets.svgsIcMasterKategori, color: yellowAcc, onTap: () => CusNav.nPush(context, const DataKategoriAdminView())),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMasterCard({required String title, required String iconPath, required Color color, required VoidCallback onTap}) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 3,
      shadowColor: color.withOpacity(0.15),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border(bottom: BorderSide(color: color, width: 4)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
                child: SvgPicture.asset(iconPath, width: 32, height: 32, colorFilter: ColorFilter.mode(color, BlendMode.srcIn)),
              ),
              const SizedBox(height: 12),
              Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87)),
            ],
          ),
        ),
      ),
    );
  }
}