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
  // Palet Warna Brand
  final Color appRed = const Color(0xFFED1C24);
  final Color oceanBlue = const Color(0xFF0096C7);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Latar yang lebih lembut
      appBar: CustomAppBar.appBar(
        context,
        'Menu Transaksi',
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
              _buildTransactionCard(
                title: 'Data DPP',
                iconPath: Assets.svgsIcAdminTransaksi, // Pastikan path ini benar di assets.dart
                accentColor: oceanBlue,
                onTap: () => CusNav.nPush(context, const DataDppAdminView()),
              ),
              _buildTransactionCard(
                title: 'Data Order',
                iconPath: Assets.svgsIcAdminTransaksi,
                accentColor: appRed,
                onTap: () => CusNav.nPush(context, const DataOrderAdminView()),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionCard({
    required String title,
    required String iconPath,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 3,
      shadowColor: accentColor.withOpacity(0.15),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border(bottom: BorderSide(color: accentColor, width: 4)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: SvgPicture.asset(
                  iconPath,
                  width: 32,
                  height: 32,
                  colorFilter: ColorFilter.mode(accentColor, BlendMode.srcIn),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}