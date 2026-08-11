import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:mspeed/common/base/base_state.dart';
import 'package:mspeed/common/component/custom_appbar.dart';
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

  getData() async {
    final p = context.read<ProfileSellerProvider>();
    p.locationCoordinate = LatLng(-7.1144282, 112.4069792);
    await p.setMapLocation(PickedData(LatLng(-7.1144282, 112.4069792), ''));
    p.geolocatorSubscription =
        Geolocator.getPositionStream().listen(await p.geolocatorListener);
    await p.fetchProfile(context);
    setState(() {});
  }

  @override
  void dispose() {
    final p = context.read<ProfileSellerProvider>();
    p.geolocatorSubscription.cancel();
    // p.mapController = Completer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ProfileSellerProvider>();
    PreferredSizeWidget appBar() {
      return AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xff059669),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      );
    }

    Widget header() {
      final data = p.profileSellerModel.data?.getSeller;
      return Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xff059669), Color(0xff10B981)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(32),
            bottomRight: Radius.circular(32),
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(120),
                child: SafeNetworkImage(
                  width: 100,
                  height: 100,
                  url: p.profileSellerModel.data?.fotoUrl ?? '-',
                  boxFit: BoxFit.cover,
                  errorBuilder: ClipRRect(
                    borderRadius: BorderRadius.circular(120),
                    child: Image.asset(Assets.imagesImgAvatar, fit: BoxFit.cover, width: 100, height: 100),
                  ),
                ),
              ),
            ),
            Constant.xSizedBox16,
            Text(
              data?.nama ?? '-',
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 20,
                color: Colors.white,
              ),
            ),
            Constant.xSizedBox4,
            Text(
              data?.email ?? '-',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
            const SizedBox(height: 20),
            InkWell(
              onTap: () {
                CusNav.nPush(context, ProfileEditSellerView());
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.5)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.edit_rounded, color: Colors.white, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Edit Profile',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    Widget contentItem({
      required String title,
      required String description,
      bool isBoxDecoration = false,
    }) {
      return Container(
        padding: isBoxDecoration ? EdgeInsets.only(top: 10) : null,
        decoration: isBoxDecoration
            ? BoxDecoration(
                border: Border(top: BorderSide(width: 0.5, color: Colors.grey)))
            : null,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(color: Constant.textColor2, fontSize: 12),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Text(
                description,
                style: TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
      );
    }

    Widget contact() {
      final data = p.profileSellerModel.data?.getSeller;
      return Container(
        margin: const EdgeInsets.fromLTRB(20, 24, 20, 0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: ExpansionTile(
          shape: const Border(),
          collapsedShape: const Border(),
          iconColor: const Color(0xff059669),
          collapsedIconColor: Colors.grey,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
          title: const Text(
            'Contact',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Color(0xff100629),
            ),
          ),
          children: [
            contentItem(title: 'Nama Pemilik', description: data?.namaPemilik ?? '-', isBoxDecoration: true),
            Constant.xSizedBox8,
            contentItem(title: 'Nama Contact Person', description: data?.namaCp ?? '-'),
            Constant.xSizedBox8,
            contentItem(title: 'Telp Contact Person', description: data?.telpCp ?? '-'),
            Constant.xSizedBox8,
            contentItem(title: 'No Telepon Perusahaan', description: data?.telp ?? '-'),
            Constant.xSizedBox8,
            contentItem(title: 'KBLI', description: data?.kbli ?? '-'),
          ],
        ),
      );
    }

    Widget alamat() {
      final data = p.profileSellerModel.data?.getSeller;
      return Container(
        margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: ExpansionTile(
          shape: const Border(),
          collapsedShape: const Border(),
          iconColor: const Color(0xff059669),
          collapsedIconColor: Colors.grey,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
          title: const Text(
            'Alamat',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Color(0xff100629),
            ),
          ),
          children: [
            contentItem(title: 'Alamat Perusahaan', description: data?.alamat ?? '-', isBoxDecoration: true),
            Constant.xSizedBox8,
            contentItem(title: 'Kota', description: data?.kota ?? '-'),
            Constant.xSizedBox8,
            contentItem(title: 'Lokasi', description: data?.lokasi ?? '-'),
            Constant.xSizedBox8,
            contentItem(title: 'Koordinat', description: '${data?.lattitude ?? '-'}, ${data?.longitude ?? '-'}'),
            Constant.xSizedBox8,
          ],
        ),
      );
    }

    Widget textDownload({required String text, required String url}) {
      return InkWell(
        onTap: () async {
          await launch(url);
        },
        child: Text(
          'Download $text',
          style: TextStyle(
            color: Constant.textHyperlinkColor,
            decoration: TextDecoration.underline,
          ),
        ),
      );
    }

    Widget lain() {
      final data = p.profileSellerModel.data?.getSeller;
      final attachment = p.profileSellerModel.data;
      return Container(
        margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: ExpansionTile(
          shape: const Border(),
          collapsedShape: const Border(),
          iconColor: const Color(0xff059669),
          collapsedIconColor: Colors.grey,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
          title: const Text(
            'Lain-Lain',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Color(0xff100629),
            ),
          ),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          children: [
            contentItem(title: 'No. NPWP', description: data?.noNpwp ?? '-', isBoxDecoration: true),
            Constant.xSizedBox8,
            contentItem(title: 'No. KTP / Identitas', description: data?.ktp ?? '-'),
            Constant.xSizedBox8,
            contentItem(title: 'Bank Account', description: data?.bank ?? '-'),
            Constant.xSizedBox8,
            if (attachment?.npwpUrl != null) textDownload(text: 'NPWP', url: attachment?.npwpUrl ?? '-'),
            if (attachment?.npwpUrl != null) Constant.xSizedBox8,
            if (attachment?.bukuRekeningUrl != null)
              textDownload(text: 'Buku Rekening', url: attachment?.bukuRekeningUrl ?? '-'),
            if (attachment?.bukuRekeningUrl != null) Constant.xSizedBox8,
            if (attachment?.ktpUrl != null)
              textDownload(text: 'No. KTP / Identitas', url: attachment?.ktpUrl ?? '-'),
            if (attachment?.ktpUrl != null) Constant.xSizedBox8,
            if (attachment?.spPkpUrl != null)
              textDownload(text: 'SP PKP', url: attachment?.spPkpUrl ?? '-'),
            if (attachment?.spPkpUrl != null) Constant.xSizedBox24,
          ],
        ),
      );
    }

    Widget data() {
      return Column(
        children: [
          contact(),
          alamat(),
          lain(),
        ],
      );
    }

    Widget _buildOption(String title, String path, GestureTapCallback? onTap, {bool isDestructive = false}) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
          decoration: BoxDecoration(
            color: isDestructive ? const Color(0xffFEF2F2) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDestructive ? const Color(0xffFECACA) : const Color(0xffE2E8F0),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDestructive ? const Color(0xffFEE2E2) : const Color(0xffF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: Image.asset(
                    path,
                    color: isDestructive ? const Color(0xffEF4444) : const Color(0xff0F172A),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDestructive ? const Color(0xffEF4444) : const Color(0xff0F172A),
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: isDestructive ? const Color(0xffF87171) : const Color(0xff94A3B8),
              ),
            ],
          ),
        ),
      );
    }

    void _showLogoutBottomSheet(BuildContext context) {
      showModalBottomSheet(
        backgroundColor: Colors.white,
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (BuildContext modalContext) {
          return SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xffE2E8F0),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Opsi Keluar',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff0F172A),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Pilih tindakan yang ingin Anda lakukan',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xff64748B),
                  ),
                ),
                const SizedBox(height: 24),
                _buildOption(
                  'Kembali ke Admin',
                  Assets.imagesIcLoginAdmin,
                  () async {
                    Navigator.pop(modalContext);
                    showDialog(
                      context: context,
                      builder: (ctx) => Dialog(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        backgroundColor: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: const Color(0xffEFF6FF),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.admin_panel_settings_rounded, color: Color(0xff3B82F6), size: 32),
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                'Kembali ke Admin?',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xff0F172A)),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Anda akan beralih dari dashboard Seller kembali ke dashboard Admin.',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 14, color: Color(0xff64748B), height: 1.5),
                              ),
                              const SizedBox(height: 24),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        side: const BorderSide(color: Color(0xffE2E8F0)),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      ),
                                      onPressed: () => Navigator.pop(ctx),
                                      child: const Text('Batal', style: TextStyle(color: Color(0xff64748B), fontWeight: FontWeight.w600)),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        backgroundColor: const Color(0xff3B82F6),
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      ),
                                      onPressed: () async {
                                        Navigator.pop(ctx);
                                        handleTap(() async {
                                          await context.read<AdminUserProvider>().backToAdmin(context);
                                        });
                                      },
                                      child: const Text('Ya, Beralih', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                _buildOption(
                  'Keluar Akun (Logout)',
                  Assets.imagesIcLogoutToAdmin,
                  () async {
                    Navigator.pop(modalContext);
                    Utils.showYesNoDialog(
                      context: context,
                      title: "Konfirmasi",
                      desc: "Apakah Anda yakin ingin keluar?",
                      yesCallback: () async {
                        handleTap(() async {
                          await context.read<AuthProvider>().logout();
                          Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                        });
                      },
                      noCallback: () => Navigator.pop(context),
                    );
                  },
                  isDestructive: true,
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      );
    }

    Widget bottomBar() {
      return Container(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            final isAdmin = await prefs.getBool(Constant.kSetPrefIsAdmin) ?? false;
            if (isAdmin) {
              _showLogoutBottomSheet(context);
            } else {
              Utils.showYesNoDialog(
                context: context,
                title: "Konfirmasi",
                desc: "Apakah Anda yakin ingin keluar?",
                yesCallback: () async {
                  await context.read<AuthProvider>().logout();
                  Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                },
                noCallback: () => Navigator.pop(context),
              );
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xffFEF2F2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xffFECACA)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.logout_rounded, color: Color(0xffEF4444)),
                SizedBox(width: 8),
                Text(
                  'Logout',
                  style: TextStyle(
                    color: Color(0xffEF4444),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xffF5F6FA),
      appBar: appBar(),
      body: ListView(
        shrinkWrap: true,
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          header(),
          data(),
          bottomBar(),
        ],
      ),
    );
  }
}
