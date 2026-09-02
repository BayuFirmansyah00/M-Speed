import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mspeed/src/admin/user/provider/admin_user_provider.dart';
import 'package:mspeed/utils/utils.dart';

class ImpersonationBannerWidget extends StatefulWidget {
  final String roleName;
  final EdgeInsetsGeometry? margin;

  const ImpersonationBannerWidget({
    Key? key,
    required this.roleName,
    this.margin,
  }) : super(key: key);

  @override
  State<ImpersonationBannerWidget> createState() => _ImpersonationBannerWidgetState();
}

class _ImpersonationBannerWidgetState extends State<ImpersonationBannerWidget> {
  bool _isImpersonated = false;

  @override
  void initState() {
    super.initState();
    _checkImpersonateState();
  }

  Future<void> _checkImpersonateState() async {
    final prefs = await SharedPreferences.getInstance();
    final bool isImp = prefs.getBool('is_impersonated') ?? false;
    final String origToken = prefs.getString('admin_original_token') ?? '';
    final bool active = isImp || origToken.isNotEmpty;
    if (mounted && _isImpersonated != active) {
      setState(() {
        _isImpersonated = active;
      });
    }
  }

  Future<void> _handleBackToAdmin() async {
    await Utils.showYesNoDialog(
      context: context,
      title: 'Kembali ke Admin',
      desc: 'Apakah Anda yakin ingin mengakhiri sesi impersonate ${widget.roleName} dan kembali ke dashboard admin?',
      yesCallback: () async {
        Navigator.pop(context);
        await context.read<AdminUserProvider>().backToAdmin(context);
      },
      noCallback: () => Navigator.pop(context),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isImpersonated) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: widget.margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFCD34D), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withValues(alpha: 0.15),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFFF59E0B),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.swap_horiz_rounded,
              color: Colors.white,
              size: 16,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Mode Impersonate Aktif',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF92400E),
                  ),
                ),
                Text(
                  'Sesi: ${widget.roleName}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFFB45309),
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: _handleBackToAdmin,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB45309),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Kembali ke Admin',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
