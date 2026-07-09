import 'package:flutter/material.dart';
import 'package:mspeed/common/base/base_state.dart';
import 'package:mspeed/common/component/custom_appbar.dart';
import 'package:mspeed/common/component/custom_navigator.dart';
import 'package:mspeed/src/admin/user/view/user_data_admin_view.dart';

class UserAdminView extends StatefulWidget {
  const UserAdminView({super.key});

  @override
  State<UserAdminView> createState() => _UserAdminViewState();
}

class _UserAdminViewState extends BaseState<UserAdminView> {
  // Palet Warna Khas Aplikasi
  final Color appRed = const Color(0xFFED1C24);
  final Color oceanBlue = const Color(0xFF0096C7);
  final Color orangeAcc = const Color(0xFFFF9800);
  final Color yellowAcc = const Color(0xFFFFC300);

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> menus = [
      {'title': 'Buyer', 'type': UserDataType.BUYER, 'icon': Icons.shopping_bag_rounded, 'color': oceanBlue},
      {'title': 'Seller', 'type': UserDataType.SELLER, 'icon': Icons.storefront_rounded, 'color': orangeAcc},
      {'title': 'Data Finance', 'type': UserDataType.FINANCE, 'icon': Icons.account_balance_wallet_rounded, 'color': yellowAcc},
      {'title': 'Data Penerima', 'type': UserDataType.PENERIMA, 'icon': Icons.local_shipping_rounded, 'color': oceanBlue},
      {'title': 'Manager', 'type': UserDataType.MANAGER, 'icon': Icons.manage_accounts_rounded, 'color': appRed},
      {'title': 'Audit', 'type': UserDataType.AUDIT, 'icon': Icons.fact_check_rounded, 'color': orangeAcc},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: CustomAppBar.appBar(
        context,
        'User Data',
        color: Colors.white,
        isCenter: true,
        titleSpacing: 24,
        textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black87),
        isLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
          child: GridView.builder(
            // MATIKAN SCROLL VIEW SESUAI PERMINTAAN
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true, 
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.15,
            ),
            itemCount: menus.length,
            itemBuilder: (context, index) {
              final menu = menus[index];
              return _buildModernCard(
                title: menu['title'],
                icon: menu['icon'],
                accentColor: menu['color'],
                onTap: () {
                  CusNav.nPush(context, UserDataAdminView(userType: menu['type']));
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildModernCard({
    required String title,
    required IconData icon,
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
            // Aksen identitas aplikasi di bagian bawah card
            border: Border(bottom: BorderSide(color: accentColor, width: 4)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 36, color: accentColor),
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