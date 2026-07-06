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
      return CustomAppBar.appBar(
        context,
        'Profile',
        color: Colors.white,
        isCenter: true,
        textStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
      );
    }

    Widget header() {
      final data = p.profileSellerModel.data?.getSeller;
      return Column(
        children: [
          Constant.xSizedBox12,
          ClipRRect(
            borderRadius: BorderRadius.circular(120),
            child: SafeNetworkImage(
              width: 120,
              height: 120,
              url: p.profileSellerModel.data?.fotoUrl ?? '-',
              errorBuilder: ClipRRect(
                borderRadius: BorderRadius.circular(120),
                child: Image.asset(Assets.imagesImgAvatar),
              ),
            ),
          ),
          Constant.xSizedBox16,
          Text(
            data?.nama ?? '-',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          Constant.xSizedBox4,
          Text(
            data?.email ?? '-',
            style: TextStyle(fontSize: 12),
          ),
        ],
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
        margin: EdgeInsets.fromLTRB(24, 16, 24, 0),
        child: ExpansionTile(
          dense: true,
          tilePadding: EdgeInsets.zero,
          childrenPadding: EdgeInsets.zero,
          collapsedShape:
              Border(bottom: BorderSide(width: 0.5, color: Colors.grey)),
          iconColor: Colors.black,
          title: Text(
            'Contact',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          children: [
            contentItem(
              title: 'Nama Pemilik',
              description: data?.namaPemilik ?? '-',
              isBoxDecoration: true,
            ),
            Constant.xSizedBox4,
            contentItem(
                title: 'Nama Contact Person', description: data?.namaCp ?? '-'),
            Constant.xSizedBox4,
            contentItem(
                title: 'Telp Contact Person', description: data?.telpCp ?? '-'),
            Constant.xSizedBox4,
            contentItem(
                title: 'No Telepon Perusahaan', description: data?.telp ?? '-'),
            Constant.xSizedBox4,
            contentItem(title: 'KBLI', description: data?.kbli ?? '-'),
          ],
        ),
      );
    }

    Widget alamat() {
      final data = p.profileSellerModel.data?.getSeller;
      return Container(
        margin: EdgeInsets.fromLTRB(24, 16, 24, 0),
        child: ExpansionTile(
          dense: true,
          tilePadding: EdgeInsets.zero,
          childrenPadding: EdgeInsets.zero,
          collapsedShape:
              Border(bottom: BorderSide(width: 0.5, color: Colors.grey)),
          iconColor: Colors.black,
          title: Text(
            'Alamat',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          children: [
            contentItem(
              title: 'Alamat Perusahaan',
              description: data?.alamat ?? '-',
              isBoxDecoration: true,
            ),
            Constant.xSizedBox4,
            contentItem(title: 'Kota', description: data?.kota ?? '-'),
            Constant.xSizedBox4,
            contentItem(title: 'Lokasi', description: data?.lokasi ?? '-'),
            Constant.xSizedBox4,
            contentItem(
                title: 'Koordinat',
                description:
                    '${data?.lattitude ?? '-'}, ${data?.longitude ?? '-'}'),
            Constant.xSizedBox8,
            // map(),
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
        margin: EdgeInsets.fromLTRB(24, 16, 24, 0),
        child: ExpansionTile(
          dense: true,
          tilePadding: EdgeInsets.zero,
          childrenPadding: EdgeInsets.zero,
          collapsedShape:
              Border(bottom: BorderSide(width: 0.5, color: Colors.grey)),
          iconColor: Colors.black,
          title: Text(
            'Lain-Lain',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          children: [
            contentItem(
              title: 'No. NPWP',
              description: data?.noNpwp ?? '-',
              isBoxDecoration: true,
            ),
            Constant.xSizedBox4,
            contentItem(
                title: 'No. KTP / Identitas', description: data?.ktp ?? '-'),
            Constant.xSizedBox4,
            contentItem(title: 'Bank Account', description: data?.bank ?? '-'),
            Constant.xSizedBox8,
            if (attachment?.npwpUrl != null)
              textDownload(text: 'NPWP', url: attachment?.npwpUrl ?? '-'),
            if (attachment?.npwpUrl != null) Constant.xSizedBox8,
            if (attachment?.bukuRekeningUrl != null)
              textDownload(
                  text: 'Buku Rekening',
                  url: attachment?.bukuRekeningUrl ?? '-'),
            if (attachment?.bukuRekeningUrl != null) Constant.xSizedBox8,
            if (attachment?.ktpUrl != null)
              textDownload(
                  text: 'No. KTP / Identitas', url: attachment?.ktpUrl ?? '-'),
            if (attachment?.ktpUrl != null) Constant.xSizedBox8,
            if (attachment?.spPkpUrl != null)
              textDownload(text: 'SP PKP', url: attachment?.spPkpUrl ?? '-'),
            if (attachment?.spPkpUrl != null) Constant.xSizedBox24,
          ],
        ),
      );
    }

    Widget editProfile() {
      return InkWell(
        onTap: () async {
          CusNav.nPush(context, ProfileEditSellerView());
        },
        child: Padding(
          padding: const EdgeInsets.only(top: 16, right: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SizedBox(
                  width: 20,
                  height: 20,
                  child: Image.asset(Assets.iconsIcEditRed)),
              Constant.xSizedBox8,
              Text(
                'Edit Profile',
                style: TextStyle(
                  color: Constant.redColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );
    }

    Widget data() {
      return Column(
        children: [
          contact(),
          alamat(),
          lain(),
          editProfile(),
        ],
      );
    }

    Widget _buildOption(String title, String path, GestureTapCallback? onTap) {
      return InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              SizedBox(
                  width: 18,
                  height: 18,
                  child: FittedBox(child: Image.asset(path))),
              Constant.xSizedBox8,
              Text(title),
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(16), // Adjust this value as needed
          ),
        ),
        builder: (BuildContext context) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 12),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () {
                        CusNav.nPop(context);
                      },
                    ),
                    Text(
                      'Opsi',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                _buildOption(
                  'Login Admin',
                  Assets.imagesIcLoginAdmin,
                  () async {
                    handleTap(() async {
                      Utils.showYesNoDialog(
                        context: context,
                        title: "Konfirmasi",
                        desc: "Apakah Anda Yakin ingin kembali ke Admin",
                        yesCallback: () async {
                          handleTap(() async {
                            await context
                                .read<AdminUserProvider>()
                                .backToAdmin(context);
                          });
                        },
                        noCallback: () => CusNav.nPop(context),
                      );
                    });
                  },
                ),
                _buildOption(
                  'Logout',
                  Assets.imagesIcLogoutToAdmin,
                  () async {
                    handleTap(() async {
                      Utils.showYesNoDialog(
                        context: context,
                        title: "Konfirmasi",
                        desc: "Apakah Anda Yakin ingin keluar",
                        yesCallback: () async {
                          handleTap(() async {
                            Navigator.pushNamedAndRemoveUntil(
                                context, '/login', (route) => false);
                          });
                        },
                        noCallback: () => CusNav.nPop(context),
                      );
                    });
                  },
                ),
                SizedBox(height: 20),
              ],
            ),
          );
        },
      );
    }

    Widget bottomBar() {
      return BottomAppBar(
        height: kBottomNavigationBarHeight + 16,
        color: Colors.white,
        child: CustomButton.mainButtonWithIcon(
          Expanded(
            flex: 5,
            child: Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: EdgeInsets.only(right: 8),
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: Image.asset(
                    Assets.iconsIcLogout,
                  ),
                ),
              ),
            ),
          ),
          'Logout',
          borderRadius: BorderRadius.circular(12),
          flexText: 6,
          stretched: true,
          mainAxisAlignment: MainAxisAlignment.start,
          () async {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            final isAdmin =
                await prefs.getBool(Constant.kSetPrefIsAdmin) ?? false;
            if (isAdmin) {
              _showLogoutBottomSheet(context);
            } else {
              Utils.showYesNoDialog(
                context: context,
                title: "Konfirmasi",
                desc: "Apakah Anda Yakin ingin Keluar",
                yesCallback: () async {
                  await context.read<AuthProvider>().logout();
                  Navigator.pushNamedAndRemoveUntil(
                      context, '/login', (route) => false);
                },
                noCallback: () {
                  Navigator.pop(context);
                },
              );
            }
          },
          // margin: EdgeInsets.symmetric(horizontal: 16),
        ),
      );
    }

    return Scaffold(
      appBar: appBar(),
      body: ListView(
        shrinkWrap: true,
        children: [header(), data()],
      ),
      bottomNavigationBar: bottomBar(),
    );
  }
}
