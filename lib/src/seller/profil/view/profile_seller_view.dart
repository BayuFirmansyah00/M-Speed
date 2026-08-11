import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:mspeed/common/base/base_state.dart';
import 'package:mspeed/common/component/custom_button.dart';
import 'package:mspeed/common/component/custom_navigator.dart';
import 'package:mspeed/common/helper/constant.dart';
import 'package:mspeed/common/helper/safe_network_image.dart';
import 'package:mspeed/generated/assets.dart';
import 'package:mspeed/src/admin/user/provider/admin_user_provider.dart';
import 'package:mspeed/src/auth/provider/auth_provider.dart';
import 'package:mspeed/src/buyer/address/view/custom_map_view.dart';
import 'package:mspeed/src/seller/profil/provider/profile_seller_provider.dart';
import 'package:mspeed/src/seller/profil/view/profile_edit_seller_view.dart';
import 'package:mspeed/utils/utils.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

// ═══════════════════════════════════════════════════════════════════
// M-SPEED Brand Color Palette — Solid Colors Only
// ═══════════════════════════════════════════════════════════════════
const Color _kPrimaryBlue = Color(0xFF1565C0);
const Color _kDanger = Color(0xFFE53935);
const Color _kBackground = Color(0xFFF7F8FA);
const Color _kSurface = Color(0xFFFFFFFF);
const Color _kTextPrimary = Color(0xFF1F2937);
const Color _kTextSecondary = Color(0xFF6B7280);
const Color _kBorder = Color(0xFFE5E7EB);

class ProfileSellerView extends StatefulWidget {
  const ProfileSellerView({super.key});

  @override
  State<ProfileSellerView> createState() => _ProfileSellerViewState();
}

class _ProfileSellerViewState extends BaseState<ProfileSellerView> {
  @override
  void initState() {
    getData();
    super.initState();
  }

  Future<void> getData() async {
    final p = context.read<ProfileSellerProvider>();
    p.locationCoordinate = const LatLng(-7.1144282, 112.4069792);
    await p.setMapLocation(PickedData(const LatLng(-7.1144282, 112.4069792), ''));
    p.geolocatorSubscription = Geolocator.getPositionStream().listen(await p.geolocatorListener);
    await p.fetchProfile(context);
    setState(() {});
  }

  @override
  void dispose() {
    final p = context.read<ProfileSellerProvider>();
    p.geolocatorSubscription.cancel();
    super.dispose();
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      surfaceTintColor: _kSurface,
      backgroundColor: _kSurface,
      foregroundColor: _kTextPrimary,
      elevation: 0,
      centerTitle: true,
      title: const Text(
        'Profile',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: _kTextPrimary,
        ),
      ),
      actions: [
        IconButton(
          onPressed: () {
            CusNav.nPush(context, const ProfileEditSellerView());
          },
          icon: const Icon(Icons.edit_rounded, color: _kPrimaryBlue, size: 24),
        )
      ],
    );
  }

  Widget _buildHeaderCard(ProfileSellerProvider p) {
    final data = p.profileSellerModel.data?.getSeller;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: _kPrimaryBlue.withOpacity(0.2), width: 2),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: SafeNetworkImage(
                width: 100,
                height: 100,
                url: p.profileSellerModel.data?.fotoUrl ?? '-',
                errorBuilder: Image.asset(Assets.imagesImgAvatar, fit: BoxFit.cover),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            data?.nama ?? '-',
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 18,
              color: _kTextPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            data?.email ?? '-',
            style: const TextStyle(fontSize: 14, color: _kTextSecondary),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _kPrimaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Seller Account',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _kPrimaryBlue),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentItem({required String title, required String description}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              title,
              style: const TextStyle(color: _kTextSecondary, fontSize: 13),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 3,
            child: Text(
              description,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: _kTextPrimary),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardExpansion({required String title, required IconData icon, required List<Widget> children}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kBorder, width: 1),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _kPrimaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: _kPrimaryBlue, size: 20),
          ),
          iconColor: _kTextPrimary,
          collapsedIconColor: _kTextSecondary,
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: _kTextPrimary),
          ),
          children: children,
        ),
      ),
    );
  }

  Widget _buildContactSection(ProfileSellerProvider p) {
    final data = p.profileSellerModel.data?.getSeller;
    return _buildCardExpansion(
      title: 'Contact',
      icon: Icons.contact_phone_rounded,
      children: [
        _buildContentItem(title: 'Nama Pemilik', description: data?.namaPemilik ?? '-'),
        _buildContentItem(title: 'Nama Contact Person', description: data?.namaCp ?? '-'),
        _buildContentItem(title: 'Telp Contact Person', description: data?.telpCp ?? '-'),
        _buildContentItem(title: 'No Telepon Perusahaan', description: data?.telp ?? '-'),
        _buildContentItem(title: 'KBLI', description: data?.kbli ?? '-'),
      ],
    );
  }

  Widget _buildAlamatSection(ProfileSellerProvider p) {
    final data = p.profileSellerModel.data?.getSeller;
    return _buildCardExpansion(
      title: 'Alamat',
      icon: Icons.location_on_rounded,
      children: [
        _buildContentItem(title: 'Alamat Perusahaan', description: data?.alamat ?? '-'),
        _buildContentItem(title: 'Kota', description: data?.kota ?? '-'),
        _buildContentItem(title: 'Lokasi', description: data?.lokasi ?? '-'),
        _buildContentItem(title: 'Koordinat', description: '${data?.lattitude ?? '-'}, ${data?.longitude ?? '-'}'),
      ],
    );
  }

  Widget _buildTextDownload({required String text, required String url}) {
    return InkWell(
      onTap: () async {
        await launchUrl(Uri.parse(url));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: _kBorder.withOpacity(0.5))),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Download $text',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: _kTextPrimary),
            ),
            const Icon(Icons.file_download_outlined, color: _kPrimaryBlue, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildLainLainSection(ProfileSellerProvider p) {
    final data = p.profileSellerModel.data?.getSeller;
    final attachment = p.profileSellerModel.data;
    return _buildCardExpansion(
      title: 'Lain-Lain',
      icon: Icons.inventory_2_rounded,
      children: [
        _buildContentItem(title: 'No. NPWP', description: data?.noNpwp ?? '-'),
        _buildContentItem(title: 'No. KTP / Identitas', description: data?.ktp ?? '-'),
        _buildContentItem(title: 'Bank Account', description: data?.bank ?? '-'),
        const SizedBox(height: 8),
        if (attachment?.npwpUrl != null) _buildTextDownload(text: 'NPWP', url: attachment!.npwpUrl!),
        if (attachment?.bukuRekeningUrl != null) _buildTextDownload(text: 'Buku Rekening', url: attachment!.bukuRekeningUrl!),
        if (attachment?.ktpUrl != null) _buildTextDownload(text: 'No. KTP / Identitas', url: attachment!.ktpUrl!),
        if (attachment?.spPkpUrl != null) _buildTextDownload(text: 'SP PKP', url: attachment!.spPkpUrl!),
      ],
    );
  }

  Widget _buildOption(String title, String path, GestureTapCallback? onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: FittedBox(child: Image.asset(path)),
            ),
            const SizedBox(width: 12),
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: _kTextPrimary)),
          ],
        ),
      ),
    );
  }

  void _showLogoutBottomSheet(BuildContext context) {
    showModalBottomSheet(
      backgroundColor: _kSurface,
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: _kBorder,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Opsi Akun',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _kTextPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildOption(
                'Stop Impersonate (Kembali ke Admin)',
                Assets.imagesIcLoginAdmin,
                () async {
                  handleTap(() async {
                    Utils.showYesNoDialog(
                      context: context,
                      title: "Konfirmasi",
                      desc: "Apakah Anda yakin ingin kembali ke Admin?",
                      yesCallback: () async {
                        handleTap(() async {
                          await context.read<AdminUserProvider>().backToAdmin(context);
                        });
                      },
                      noCallback: () => CusNav.nPop(context),
                    );
                  });
                },
              ),
              const Divider(color: _kBorder),
              _buildOption(
                'Logout',
                Assets.imagesIcLogoutToAdmin,
                () async {
                  handleTap(() async {
                    Utils.showYesNoDialog(
                      context: context,
                      title: "Konfirmasi",
                      desc: "Apakah Anda yakin ingin keluar?",
                      yesCallback: () async {
                        handleTap(() async {
                          Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                        });
                      },
                      noCallback: () => CusNav.nPop(context),
                    );
                  });
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      decoration: BoxDecoration(
        color: _kSurface,
        border: Border(top: BorderSide(color: _kBorder, width: 1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomButton.mainButtonWithIcon(
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: Image.asset(Assets.iconsIcLogout, color: Colors.white),
                ),
              ),
              'Logout',
              borderRadius: BorderRadius.circular(12),
              color: _kDanger,
              mainAxisAlignment: MainAxisAlignment.center,
              () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                final isOriginalAdmin = prefs.getString('admin_original_token') != null && prefs.getString('admin_original_token')!.isNotEmpty;
                final isAdmin = (prefs.getBool(Constant.kSetPrefIsAdmin) ?? false) || isOriginalAdmin;
                
                if (isAdmin) {
                  _showLogoutBottomSheet(context);
                } else {
                  Utils.showYesNoDialog(
                    context: context,
                    title: "Konfirmasi Logout",
                    desc: "Apakah Anda yakin ingin keluar dari akun ini?",
                    yesCallback: () async {
                      await context.read<AuthProvider>().logout();
                      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                    },
                    noCallback: () => Navigator.pop(context),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ProfileSellerProvider>();
    return Scaffold(
      backgroundColor: _kBackground,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            _buildHeaderCard(p),
            const SizedBox(height: 8),
            _buildContactSection(p),
            _buildAlamatSection(p),
            _buildLainLainSection(p),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }
}
