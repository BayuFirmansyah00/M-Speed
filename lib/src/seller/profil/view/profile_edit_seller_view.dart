import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mspeed/common/base/base_state.dart';
import 'package:mspeed/common/component/custom_appbar.dart';
import 'package:mspeed/common/component/custom_button.dart';
import 'package:mspeed/common/component/custom_dropdown.dart';
import 'package:mspeed/common/component/custom_image_picker.dart';
import 'package:mspeed/common/component/custom_navigator.dart';
import 'package:mspeed/common/component/custom_textfield.dart';
import 'package:mspeed/common/helper/constant.dart';
import 'package:mspeed/common/helper/download.dart';
import 'package:mspeed/common/helper/safe_network_image.dart';
import 'package:mspeed/generated/assets.dart';
import 'package:mspeed/src/buyer/address/view/custom_map_view.dart';
import 'package:mspeed/src/buyer/address/view/search_location_view.dart';
import 'package:mspeed/src/buyer/address/view/search_location_view.dart';
import 'package:mspeed/src/buyer/transaction/widget/submit_ttd_widget.dart';
import 'package:mspeed/src/seller/profil/provider/profile_seller_provider.dart';
import 'package:mspeed/utils/utils.dart';
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';
import 'package:mspeed/src/admin/user/view/admin_form_widgets.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class _FileButton extends StatelessWidget {
  final String title;
  final String? fileName;
  final VoidCallback onChoose;
  const _FileButton({required this.title, this.fileName, required this.onChoose});

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xff059669);
    return GestureDetector(
      onTap: onChoose,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: fileName != null && fileName!.isNotEmpty ? accent.withOpacity(0.06) : const Color(0xffF8F9FC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: fileName != null && fileName!.isNotEmpty ? accent.withOpacity(0.3) : const Color(0xffE2E4E9),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: accent.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                fileName != null && fileName!.isNotEmpty ? Icons.check_circle_outline_rounded : Icons.upload_file_outlined,
                color: accent, size: 16,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xff4A5568))),
                  if (fileName != null && fileName!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(fileName!, style: const TextStyle(fontSize: 11, color: accent), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ] else
                    const Text('Tap untuk memilih file', style: TextStyle(fontSize: 11, color: Color(0xffA0AEC0))),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Color(0xffA0AEC0), size: 18),
          ],
        ),
      ),
    );
  }
}

class ProfileEditSellerView extends StatefulWidget {
  const ProfileEditSellerView({super.key});

  @override
  State<ProfileEditSellerView> createState() => _ProfileEditSellerViewState();
}

class _ProfileEditSellerViewState extends BaseState<ProfileEditSellerView> {
  @override
  void initState() {
    getData();
    super.initState();
  }

  getData() async {
    log("GET DATA PROFIL");
    final p = context.read<ProfileSellerProvider>();
    debugPrint('[TRACE PROVIDER INSTANCE] providerHash = ${identityHashCode(p)}');
    p.mapController = MapController();
    loading(true);
    await p.fetchKota();
    debugPrint("Kota fetched");
    await p.fetchProvinsi();
    debugPrint("Provinsi fetched");
    // Fetch full profile data
    await p.fetchProfile(context, withLoading: false);
    debugPrint("Profile fetched");
    // Initialize controllers with fetched data
    await p.initEditProfile();
    debugPrint("Edit profile initialized");
    // p.geolocatorSubscription =
    //     Geolocator.getPositionStream().listen(await p.geolocatorListener);
    
    debugPrint('\n[DEBUG FINAL PROFILE]');
    debugPrint('sellerDataId = ${p.sellerDataId}');
    debugPrint('KTP = ${p.ktpNumberC.text}');
    debugPrint('NPWP = ${p.npwpC.text}');
    debugPrint('NIB = ${p.nibC.text}');
    debugPrint('Bank = ${p.bankTypeC.text}');
    debugPrint('No Rekening = ${p.bankNumberC.text}');
    debugPrint('Atas Nama = ${p.bankNameC.text}\n');
    
    setState(() {});
    loading(false);
  }

  @override
  void dispose() {
    context.read<ProfileSellerProvider>().resetProfileState();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ProfileSellerProvider>();
    debugPrint('[TRACE PROVIDER INSTANCE] providerHash = ${identityHashCode(p)}');
    
    debugPrint('[TRACE UI FIELD]');
    debugPrint('KTP controller = ${p.ktpNumberC.text}');
    debugPrint('NPWP controller = ${p.npwpC.text}');
    debugPrint('NIB controller = ${p.nibC.text}');
    debugPrint('Bank controller = ${p.bankTypeC.text}');
    debugPrint('Rekening controller = ${p.bankNumberC.text}');
    debugPrint('AtasNama controller = ${p.bankNameC.text}');
    
    PreferredSizeWidget appBar() {
      return AppBar(
        title: const Text(
          'Edit Profile',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xff059669),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            p.resetProfileState();
            CusNav.nPop(context);
          },
        ),
      );
    }

    Widget photo() {
      if (p.profileFile != null)
        return SizedBox(
          width: 120,
          height: 120,
          child: Image.file(
            p.profileFile!,
            fit: BoxFit.cover,
          ),
        );
      return SafeNetworkImage(
        width: 120,
        height: 120,
        url: p.profileUrl ?? '',
        errorBuilder: ClipRRect(
          borderRadius: BorderRadius.circular(120),
          child: SizedBox(
            width: 120,
            height: 120,
            child: Image.asset(
              Assets.imagesImgAvatar,
              fit: BoxFit.cover,
            ),
          ),
        ),
      );
    }

    Widget header() {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24),
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
              child: ClipRRect(borderRadius: BorderRadius.circular(120), child: photo()),
            ),
            Constant.xSizedBox16,
            InkWell(
              onTap: () async {
                p.profileFile = await CustomImagePicker.cameraOrGallery(context);
                setState(() {});
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.5)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.camera_alt_rounded, color: Colors.white, size: 16),
                    SizedBox(width: 8),
                    Text(
                      'Ubah Foto Profile',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      );
    }

    Widget map() {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: AspectRatio(
            aspectRatio: 2 / 1,
            child: FlutterMap(
              mapController: p.mapController,
              options: MapOptions(
                initialCenter:
                    p.locationCoordinate ?? LatLng(-7.1144282, 112.4069792),
                initialZoom: 15,
                interactionOptions: InteractionOptions(
                  flags: InteractiveFlag.none,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                  userAgentPackageName: 'com.mspeed.app',
                ),
                MarkerLayer(
                  markers: [
                    if (p.marker != null)
                      Marker(
                        point: LatLng(p.marker!.point.latitude,
                            p.marker!.point.longitude),
                        child: Icon(Icons.location_on, color: Colors.red),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }

    Widget field({
      required TextEditingController controller,
      String? text,
      String? hintText,
      bool useLabel = true,
      EdgeInsetsGeometry? padding,
      bool required = false,
      bool enabled = true,
    }) {
      return CustomTextField.borderTextField(
        padding: padding ?? EdgeInsets.symmetric(horizontal: 20),
        controller: controller,
        required: required,
        enabled: enabled,
        fillColor: Colors.white,
        hintColor: Constant.grayColor,
        labelText: useLabel ? text : '',
        hintText: hintText,
        labelFontSize: 12,
        labelFontWeight: FontWeight.normal,
        labelColor: Color(0xff6D7588),
        borderColor: Color(0xffB9B9B9),
      );
    }

    Widget fieldDropdown({
      required TextEditingController controller,
      required List<String> list,
      Function(String?)? onChanged,
      String? hintText,
      required String? labelText,
      String? selectedItem,
      EdgeInsetsGeometry? padding,
      bool required = false,
      Color? borderColor,
      Color? hintColor,
      EdgeInsetsGeometry? labelPadding,
      TextStyle? labelTextStyle,
      FontWeight? labelFontWeight,
      Color? labelColor,
      double? labelFontSize,
    }) {
      return CustomDropdown.searchDropdown(
        required: required,
        labelText: labelText,
        list: list,
        hintText: hintText,
        onChanged: onChanged,
        selectedItem: selectedItem,
        borderColor: borderColor,
        labelPadding: labelPadding,
        labelTextStyle: labelTextStyle,
        hintColor: hintColor,
      );
      // return CustomTextField.borderTextField(
      //   padding: padding ?? EdgeInsets.symmetric(horizontal: 20),
      //   controller: controller,
      //   required: required,
      //   fillColor: Colors.white,
      //   hintColor: Constant.grayColor,
      //   labelText: text,
      //   hintText: text == '' ? hintText : text,
      //   labelFontSize: 12,
      //   labelFontWeight: FontWeight.normal,
      //   labelColor: Color(0xff6D7588),
      //   borderColor: Color(0xffB9B9B9),
      // );
    }

    Widget fieldFile({
      required TextEditingController controller,
      required String? text,
      Widget? extraLabeltext,
      String? hintText,
      EdgeInsetsGeometry? padding,
      bool required = false,
      bool enabled = true,
      required VoidCallback onTap,
    }) {
      return CustomTextField.borderTextField(
        enabled: enabled,
        padding: padding ?? EdgeInsets.symmetric(horizontal: 20),
        controller: controller,
        required: required,
        readOnly: true,
        onTap: onTap,
        fillColor: Colors.white,
        hintColor: Constant.grayColor,
        labelText: text,
        extraLabelText: Flexible(child: extraLabeltext ?? SizedBox()),
        hintText: 'Browse',
        suffixIcon: InkWell(
          onTap: () async {
            // if (img != null) {
            //   Navigator.pushNamed(context, "/showImage", arguments: img);
            // }
          },
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
            child: SizedBox(
              width: 12,
              height: 12,
              child: FittedBox(
                child: Image.asset(
                  Assets.iconsIcUploadGray,
                  scale: 24,
                  color:
                      controller.text.isNotEmpty ? Constant.primaryColor : null,
                ),
              ),
            ),
          ),
        ),
        labelFontSize: 12,
        labelFontWeight: FontWeight.normal,
        labelColor: Color(0xff6D7588),
        borderColor: Color(0xffB9B9B9),
      );
    }

    Widget btn({
      required String path,
      required String label,
      required Color color,
      required void Function()? onTap,
    }) {
      return Expanded(
        child: InkWell(
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8), color: color),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  path,
                  width: 14,
                  height: 14,
                ),
                SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                  ),
                )
              ],
            ),
          ),
        ),
      );
    }

    Widget selectLocationBtn() {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        width: double.infinity,
        child: CustomButton.secondaryButton(
          "Pilih Lokasi",
          borderRadius: BorderRadius.circular(8),
          () async {
            late LatLng currentPosition;
            if (p.locationCoordinate != null) {
              currentPosition = p.locationCoordinate!;
            } else {
              bool serviceEnabled;
              LocationPermission permission;

              serviceEnabled = await Geolocator.isLocationServiceEnabled();
              if (!serviceEnabled)
                return Future.error('Location services are disabled.');

              permission = await Geolocator.checkPermission();
              if (permission == LocationPermission.denied) {
                await Geolocator.requestPermission();
                if (permission == LocationPermission.deniedForever) {
                  await Geolocator.requestPermission();
                  return Future.error(
                      'Location permissions are permanently denied, we cannot request permissions.');
                }

                if (permission == LocationPermission.denied) {
                  await Geolocator.requestPermission();
                  return Future.error('Location permissions are denied');
                }
              }
              Position? pos;
              try {
                pos = await Geolocator.getCurrentPosition(
                  forceAndroidLocationManager: true,
                  desiredAccuracy: LocationAccuracy.best,
                  timeLimit: Duration(seconds: 3),
                ).timeout(Duration(seconds: 20));
              } catch (e) {
                pos = await Geolocator.getLastKnownPosition(
                    forceAndroidLocationManager: true);
              }
              if (pos != null)
                currentPosition = LatLng(pos.latitude, pos.longitude);
            }
            PickedData? pickedData =
                await Navigator.push(context, MaterialPageRoute(
              builder: (context) {
                return SearchLocationView.create(
                    p.locationCoordinate ?? currentPosition);
              },
            ));

            if (pickedData != null) {
              p.setMapLocation(pickedData).then((value) {
                p.mapController.move(pickedData.latLong, 15);
                setState(() {});
              });
            }
          },
        ),
      );
    }

    void showTtdDialog(BuildContext context) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            insetPadding: const EdgeInsets.symmetric(horizontal: 16),
            child: SubmitTtdWidget(
              onSubmit: (v) async {
                p.ttd = v;
                setState(() {});
                FocusManager.instance.primaryFocus?.unfocus();
                bool result = await p.addTtdNonPkpSeller(withLoading: true);
                if (result)
                  Utils.showSuccess(msg: 'TTD Berhasil');
                else
                  Utils.showFailed(msg: 'TTD Gagal');
              },
            ),
          );
        },
      );
    }

    Widget form() {
      const accent = Color(0xff059669);
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),

            // ── Informasi Toko ──
            AdminFormSection(
              title: 'Informasi Toko',
              icon: Icons.storefront_outlined,
              accentColor: accent,
              children: [
                AdminFormField(controller: p.companyNameC, label: 'Nama Toko / Perusahaan *', hint: 'Nama Toko / Perusahaan', icon: Icons.business_outlined),
                AdminFormField(controller: p.kbliC, label: 'KBLI', hint: 'Kode KBLI', icon: Icons.numbers_rounded),
                AdminFormField(controller: p.ownerNameC, label: 'Nama Pemilik / Direktur *', hint: 'Nama Pemilik / Direktur', icon: Icons.person_rounded),
              ],
            ),
            const SizedBox(height: 16),

            // ── Tipe & Identitas ──
            AdminFormSection(
              title: 'Tipe & Identitas Toko',
              icon: Icons.badge_outlined,
              accentColor: accent,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Jenis Toko *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xff4A5568))),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<int>(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('PKP', style: TextStyle(fontSize: 13)),
                            value: 1,
                            groupValue: p.jenisToko,
                            activeColor: accent,
                            onChanged: (value) {
                              if (p.jenisToko != value) {
                                setState(() => p.jenisToko = 1);
                                if (p.jenisToko == 2) {
                                  p.npwpFile = null;
                                  p.npwpC.clear();
                                  p.npwpFileC.clear();
                                }
                                if (p.jenisToko != 1) {
                                  p.spSkpFile = null;
                                  p.spSkpFileC.clear();
                                }
                                setState(() {});
                              }
                            },
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<int>(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Non PKP (Punya NPWP)', style: TextStyle(fontSize: 13)),
                            value: 2,
                            groupValue: p.jenisToko,
                            activeColor: accent,
                            onChanged: (value) {
                              if (p.jenisToko != value) {
                                setState(() => p.jenisToko = 2);
                                setState(() {});
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    RadioListTile<int>(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Non PKP (Tidak Punya NPWP)', style: TextStyle(fontSize: 13)),
                      value: 3,
                      groupValue: p.jenisToko,
                      activeColor: accent,
                      onChanged: (value) {
                        if (p.jenisToko != value) {
                          setState(() => p.jenisToko = 3);
                          setState(() {});
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                AdminFormField(controller: p.ktpNumberC, label: 'No KTP *', hint: 'No KTP', icon: Icons.credit_card_outlined),
                AdminFormField(controller: p.npwpC, label: 'No NPWP *', hint: 'No NPWP', icon: Icons.receipt_long_outlined, enabled: p.jenisToko != 2),
                AdminFormField(controller: p.nibC, label: 'No NIB *', hint: 'No NIB', icon: Icons.description_outlined),
              ],
            ),
            const SizedBox(height: 16),

            // ── Kontak & Relasi ──
            AdminFormSection(
              title: 'Kontak & Relasi',
              icon: Icons.contact_phone_outlined,
              accentColor: accent,
              children: [
                AdminFormField(controller: p.emailC, label: 'Email', hint: 'Email', icon: Icons.email_outlined, inputType: TextInputType.emailAddress),
                AdminFormField(controller: p.phoneC, label: 'No Telepon', hint: 'No Telepon', icon: Icons.phone_outlined, inputType: TextInputType.phone),
                AdminFormField(controller: p.roleC, label: 'Jabatan', hint: 'Jabatan', icon: Icons.work_outline_rounded),
                AdminFormField(controller: p.salesNameC, label: 'Nama Sales / Kuasa', hint: 'Nama Sales / Kuasa', icon: Icons.support_agent_rounded),
                AdminFormField(controller: p.salesPhoneC, label: 'Telp Sales / Kuasa', hint: 'Telp Sales / Kuasa', icon: Icons.phone_callback_outlined, inputType: TextInputType.phone),
              ],
            ),
            const SizedBox(height: 16),

            // ── Lokasi & Alamat ──
            AdminFormSection(
              title: 'Lokasi & Alamat',
              icon: Icons.location_on_outlined,
              accentColor: accent,
              children: [
                fieldDropdown(
                  required: true,
                  controller: p.provinceC,
                  labelText: 'Provinsi',
                  hintText: 'Pilih Provinsi',
                  selectedItem: p.selectedProvince,
                  list: (p.provinsiModel?.data ?? []).map((e) => e?.nama ?? 'Unknown Province').toList(),
                  onChanged: (v) {
                    var index = p.provinsiModel?.data?.indexWhere((e) => e == v) ?? -1;
                    if (index != -1 && p.provinsiModel?.data?[index]?.nama != null) {
                      setState(() {
                        p.selectedProvince = v;
                        p.selectedProvinceId = p.provinsiModel?.data?[index]?.ID ?? '';
                      });
                    }
                  },
                ),
                const SizedBox(height: 12),
                fieldDropdown(
                  required: true,
                  controller: p.cityC,
                  labelText: 'Kota',
                  hintText: 'Pilih Kota',
                  selectedItem: p.selectedCity,
                  list: (p.kotaModel?.data ?? []).map((e) => e?.kota ?? 'Unknown City').toList(),
                  onChanged: (v) {
                    var index = p.kotaModel?.data?.indexWhere((e) => e == v) ?? -1;
                    if (index != -1 && p.kotaModel?.data?[index]?.kota != null) {
                      setState(() {
                        p.selectedCity = v;
                        p.selectedCityId = p.kotaModel?.data?[index]?.ID ?? '';
                      });
                    }
                  },
                ),
                const SizedBox(height: 12),
                AdminFormField(controller: p.addressC, label: 'Alamat *', hint: 'Alamat Lengkap', icon: Icons.map_outlined, maxLines: 3),
                const SizedBox(height: 16),
                const Text('Pilih Lokasi dari Peta', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xff4A5568))),
                const SizedBox(height: 8),
                map(),
                const SizedBox(height: 12),
                selectLocationBtn(),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: AdminFormField(controller: p.latC, label: 'Latitude', hint: 'Koordinat', icon: Icons.location_searching_rounded)),
                    const SizedBox(width: 12),
                    Expanded(child: AdminFormField(controller: p.lngC, label: 'Longitude', hint: 'Koordinat', icon: Icons.location_searching_rounded)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── Rekening Bank ──
            AdminFormSection(
              title: 'Rekening Bank',
              icon: Icons.account_balance_outlined,
              accentColor: accent,
              children: [
                AdminFormField(controller: p.bankTypeC, label: 'Nama Bank *', hint: 'Nama Bank', icon: Icons.account_balance_rounded),
                AdminFormField(controller: p.bankNumberC, label: 'No Rekening *', hint: 'No Rekening', icon: Icons.numbers_rounded, inputType: TextInputType.number),
                AdminFormField(controller: p.bankNameC, label: 'Rekening Atas Nama *', hint: 'Atas Nama', icon: Icons.person_outline_rounded),
              ],
            ),
            const SizedBox(height: 16),

            // ── Upload Dokumen ──
            AdminFormSection(
              title: 'Upload Dokumen',
              icon: Icons.upload_file_outlined,
              accentColor: accent,
              children: [
                _FileButton(
                  title: 'File KTP / Identitas',
                  fileName: p.ktpFileC.text,
                  onChoose: () async {
                    p.ktpFile = await CustomImagePicker.selectImageFromGallery();
                    if (p.ktpFile != null) p.ktpFileC.text = path.basename(p.ktpFile!.path);
                    setState(() {});
                  },
                ),
                if (p.jenisToko != 2)
                  _FileButton(
                    title: 'File NPWP',
                    fileName: p.npwpFileC.text,
                    onChoose: () async {
                      p.npwpFile = await CustomImagePicker.selectImageFromGallery();
                      if (p.npwpFile != null) p.npwpFileC.text = path.basename(p.npwpFile!.path);
                      setState(() {});
                    },
                  ),
                _FileButton(
                  title: 'File Buku Rekening',
                  fileName: p.bankNumberFileC.text,
                  onChoose: () async {
                    p.bankNumberFile = await CustomImagePicker.selectImageFromGallery();
                    if (p.bankNumberFile != null) p.bankNumberFileC.text = path.basename(p.bankNumberFile!.path);
                    setState(() {});
                  },
                ),
                if (p.jenisToko == 1)
                  _FileButton(
                    title: 'File SP SKP',
                    fileName: p.spSkpFileC.text,
                    onChoose: () async {
                      p.spSkpFile = await CustomImagePicker.selectImageFromGallery();
                      if (p.spSkpFile != null) p.spSkpFileC.text = path.basename(p.spSkpFile!.path);
                      setState(() {});
                    },
                  ),
                _FileButton(
                  title: 'File NIB',
                  fileName: p.nibFileC.text,
                  onChoose: () async {
                    p.nibFile = await CustomImagePicker.selectImageFromGallery();
                    if (p.nibFile != null) p.nibFileC.text = path.basename(p.nibFile!.path);
                    setState(() {});
                  },
                ),
                _FileButton(
                  title: 'Surat Pernyataan',
                  fileName: p.suratPernyataanFileC.text,
                  onChoose: () async {
                    p.suratPernyataanFile = await CustomImagePicker.selectImageFromGallery();
                    if (p.suratPernyataanFile != null) p.suratPernyataanFileC.text = path.basename(p.suratPernyataanFile!.path);
                    setState(() {});
                  },
                ),
                const SizedBox(height: 12),
                // Signature Preview
                if (p.profileSellerModel.data?.signatureUrl != null &&
                    p.profileSellerModel.data!.signatureUrl!.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    width: double.infinity,
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xffE2E8F0)),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: SafeNetworkImage(
                        key: ValueKey(p.profileSellerModel.data!.signatureUrl!),
                        url: p.profileSellerModel.data!.signatureUrl!.replaceAll('localhost', Constant.DOMAIN_LOCAL) + '?v=${DateTime.now().millisecondsSinceEpoch}',
                        width: double.infinity,
                        height: 150,
                        boxFit: BoxFit.contain,
                      ),
                    ),
                  ),
                // Bank Passbook Preview
                if (p.profileSellerModel.data?.bukuRekeningUrl != null &&
                    p.profileSellerModel.data!.bukuRekeningUrl!.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    width: double.infinity,
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xffE2E8F0)),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: SafeNetworkImage(
                        key: ValueKey(p.profileSellerModel.data!.bukuRekeningUrl!),
                        url: p.profileSellerModel.data!.bukuRekeningUrl!
                            .replaceAll('localhost', Constant.DOMAIN_LOCAL) +
                            '?v=${DateTime.now().millisecondsSinceEpoch}',
                        width: double.infinity,
                        height: 150,
                        boxFit: BoxFit.contain,
                      ),
                    ),
                  ),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff10B981),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () async {
                          var url = await p.fetchTemplateNonPKPSeller(withLoading: true);
                          if (url != null && url != '') {
                            downloadFile(context, url, filename: 'TemplatePernyataan.pdf', typeFile: 'pdf');
                          } else {
                            Utils.showFailed(msg: 'URL Download File Tidak Ditemukan');
                          }
                        },
                        icon: const Icon(Icons.download_rounded, size: 16),
                        label: const Text('Template Pernyataan', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff3B82F6),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () => showTtdDialog(context),
                        icon: const Icon(Icons.draw_rounded, size: 16),
                        label: const Text('Ttd Langsung', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      );
    }

    Widget bottomBar() {
      return Container(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
        color: Colors.transparent,
        child: CustomButton.mainButton(
          'Simpan',
          borderRadius: BorderRadius.circular(12),
          () async {
            final p = context.read<ProfileSellerProvider>();
            await p.editProfileSeller(context);
          },
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
          form(),
          bottomBar(),
        ],
      ),
    );
  }
}
