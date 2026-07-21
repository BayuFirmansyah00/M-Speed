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
import 'package:mspeed/src/buyer/transaction/widget/submit_ttd_widget.dart';
import 'package:mspeed/src/seller/profil/provider/profile_seller_provider.dart';
import 'package:mspeed/utils/utils.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart' as path;
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

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
    p.mapController = MapController();
    loading(true);
    await p.fetchKota();
    await p.fetchProvinsi();
    await p.fetchProfile(context, withLoading: false);
    await p.initEditProfile();
    // p.geolocatorSubscription =
    //     Geolocator.getPositionStream().listen(await p.geolocatorListener);
    setState(() {});
    loading(false);
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
        'Edit Profile',
        color: Colors.white,
        isCenter: true,
        onBack: () {
          p.disposeEditProfile();
          CusNav.nPop(context);
        },
        textStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
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
      return Column(
        children: [
          Constant.xSizedBox12,
          ClipRRect(borderRadius: BorderRadius.circular(120), child: photo()),
          Constant.xSizedBox8,
          InkWell(
            onTap: () async {
              p.profileFile = await CustomImagePicker.cameraOrGallery(context);
              setState(() {});
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                    width: 20,
                    height: 20,
                    child: Image.asset(Assets.iconsIcEditBlue)),
                Constant.xSizedBox8,
                Text(
                  'Ubah Foto Profile',
                  style: TextStyle(
                    color: Constant.blueGreenColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          )
        ],
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
                  urlTemplate:
                      "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                  subdomains: ['a', 'b', 'c'],
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
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: SubmitTtdWidget(
              onSubmit: (v) async {
                p.ttd = v;
                setState(() {});
                FocusManager.instance.primaryFocus?.unfocus();
                // Fitur TTD Non-PKP belum tersedia di API baru
                // Endpoint /ttdnonpkpseller tidak ada di Laravel baru
                Utils.showFailed(msg: 'Fitur TTD belum tersedia di versi ini');
              },
            ),
          );
        },
      );
    }

    Widget form() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Constant.xSizedBox16,
          field(
            controller: p.companyNameC,
            hintText: 'Nama Toko / Perusahaan',
            text: 'Nama Toko / Perusahaan',
            required: true,
          ),
          Constant.xSizedBox16,
          field(
            required: true,
            controller: p.ownerNameC,
            text: 'Nama Pemilik / Direktur',
            hintText: 'Nama Pemilik / Direktur',
          ),
          Constant.xSizedBox16,
          field(
            controller: p.emailC,
            text: 'Email',
            hintText: 'Email',
          ),
          Constant.xSizedBox16,
          field(
            controller: p.phoneC,
            text: 'No Telepon',
            hintText: 'No Telepon',
          ),
          Constant.xSizedBox16,
          field(
            controller: p.roleC,
            text: 'Jabatan',
            hintText: 'Jabatan',
          ),
          Constant.xSizedBox16,
          field(
            controller: p.salesNameC,
            text: 'Nama Sales / Kuasa',
            hintText: 'Nama Sales / Kuasa',
          ),
          Constant.xSizedBox16,
          field(
            controller: p.salesPhoneC,
            text: 'Telp Sales / Kuasa',
            hintText: 'Telp Sales / Kuasa',
          ),
          Constant.xSizedBox16,
          field(
            controller: p.kbliC,
            text: 'KBLI',
            hintText: 'KBLI',
          ),
          Constant.xSizedBox16,
          field(
            required: true,
            controller: p.addressC,
            text: 'Alamat',
            hintText: 'Alamat',
          ),
          Constant.xSizedBox16,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: fieldDropdown(
              required: true,
              controller: p.provinceC,
              labelPadding: EdgeInsets.only(bottom: 5),
              labelText: 'Provinsi',
              hintText: 'Pilih Provinsi',
              hintColor: Constant.grayColor,
              selectedItem: p.selectedProvince,
              borderColor: Constant.borderSearchColor.withValues(alpha: 0.5),
              list: (p.provinsiModel?.data ?? [])
                  .map((e) => e?.nama ?? 'Unknown Province')
                  .toList(),
              onChanged: (v) {
                var index =
                    p.provinsiModel?.data?.indexWhere((e) => e?.nama == v) ?? -1;
                if (index != -1 &&
                    p.provinsiModel?.data?[index]?.nama != null) {
                  setState(() {
                    p.selectedProvince = v;
                    p.selectedProvinceId =
                        p.provinsiModel?.data?[index]?.ID ?? '';
                  });
                }
              },
              labelTextStyle: Constant.primaryTextStyle.copyWith(
                color: Color(0xff6D7588),
                fontSize: 12,
              ),
            ),
          ),
          Constant.xSizedBox16,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: fieldDropdown(
              required: true,
              controller: p.cityC,
              labelPadding: EdgeInsets.only(bottom: 5),
              labelText: 'Kota',
              hintText: 'Pilih Kota',
              hintColor: Constant.grayColor,
              selectedItem: p.selectedCity,
              borderColor: Constant.borderSearchColor.withValues(alpha: 0.5),
              list: (p.kotaModel?.data ?? [])
                  .map((e) => e?.kota ?? 'Unknown City')
                  .toList(),
              onChanged: (v) {
                var index = p.kotaModel?.data?.indexWhere((e) => e?.kota == v) ?? -1;
                if (index != -1 && p.kotaModel?.data?[index]?.kota != null) {
                  setState(() {
                    p.selectedCity = v;
                    p.selectedCityId = p.kotaModel?.data?[index]?.ID ?? '';
                  });
                }
              },
              labelTextStyle: Constant.primaryTextStyle.copyWith(
                color: Color(0xff6D7588),
                fontSize: 12,
              ),
            ),
          ),
          Constant.xSizedBox16,
          Padding(
            padding: const EdgeInsets.only(bottom: 10, right: 20, left: 20),
            child: Text(
              'Select from Map',
              style: Constant.primaryTextStyle.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.normal,
                color: Color(0xff6D7588),
              ),
            ),
          ),
          map(),
          Constant.xSizedBox8,
          selectLocationBtn(),
          Constant.xSizedBox16,
          Row(
            children: [
              Expanded(
                  child: field(
                      controller: p.latC,
                      hintText: 'Latitude',
                      text: 'Koordinat',
                      padding: EdgeInsets.only(left: 20, right: 4))),
              Expanded(
                  child: field(
                      controller: p.lngC,
                      hintText: 'Longitude',
                      text: '',
                      useLabel: false,
                      padding: EdgeInsets.only(left: 4, right: 20))),
            ],
          ),
          Constant.xSizedBox16,
          Container(
            height: 8,
            color: Color(0xffF6F6F6),
          ),
          Constant.xSizedBox8,
          Padding(
            padding: const EdgeInsets.only(bottom: 5, left: 20, right: 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Jenis Toko',
                  style: Constant.primaryTextStyle.copyWith(
                    color: Color(0xff6D7588),
                    fontSize: 12,
                  ),
                ),
                Text(
                  '*',
                  style: Constant.primaryTextStyle.copyWith(
                    fontSize: 14,
                    fontWeight: Constant.medium,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Radio(
                        value: 1,
                        groupValue: p.jenisToko,
                        visualDensity:
                            VisualDensity(vertical: -4, horizontal: -4),
                        onChanged: (value) {
                          if (p.jenisToko != value) {
                            setState(() {
                              p.jenisToko = 1;
                            });
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
                      Flexible(
                        child: Text(
                          'PKP',
                          style: TextStyle(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      Radio(
                        value: 2,
                        groupValue: p.jenisToko,
                        visualDensity:
                            VisualDensity(vertical: -4, horizontal: -4),
                        onChanged: (value) {
                          if (p.jenisToko != value) {
                            setState(() {
                              p.jenisToko = 2;
                            });
                            setState(() {});
                          }
                        },
                      ),
                      Flexible(
                        child: Text(
                          'Non PKP (Punya NPWP)',
                          style: TextStyle(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Radio(
                  value: 3,
                  groupValue: p.jenisToko,
                  visualDensity: VisualDensity(vertical: -4, horizontal: -4),
                  onChanged: (value) {
                    if (p.jenisToko != value) {
                      setState(() {
                        p.jenisToko = 3;
                      });
                      setState(() {});
                    }
                  },
                ),
                Flexible(
                  child: Text(
                    'Non PKP (Tidak Punya NPWP)',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
          Constant.xSizedBox16,
          field(
            required: true,
            controller: p.ktpNumberC,
            text: 'No KTP',
            hintText: 'No KTP',
          ),
          Constant.xSizedBox16,
          field(
            required: true,
            enabled: p.jenisToko != 2,
            controller: p.npwpC,
            text: 'No NPWP',
            hintText: 'No NPWP',
          ),
          Constant.xSizedBox16,
          field(
            required: true,
            controller: p.nibC,
            text: 'No NIB',
            hintText: 'No NIB',
          ),
          Constant.xSizedBox16,
          field(
            required: true,
            text: 'Nama Bank',
            hintText: 'Nama Bank',
            controller: p.bankTypeC,
          ),
          Constant.xSizedBox16,
          field(
              required: true,
              text: 'No Rekening',
              hintText: 'No Rekening',
              controller: p.bankNumberC),
          Constant.xSizedBox16,
          field(
            required: true,
            controller: p.bankNameC,
            text: 'Rekening Atas Nama',
            hintText: 'Rekening Atas Nama',
          ),
          Constant.xSizedBox16,
          fieldFile(
            controller: p.ktpFileC,
            text: 'File KTP / Identitas',
            extraLabeltext: Padding(
              padding: EdgeInsets.symmetric(horizontal: 5),
              child: Text(
                'Ext: jpeg, jpg, png     Max file: 100mb',
                style: Constant.primaryTextStyle.copyWith(
                  color: Constant.textColor2,
                  fontSize: 12,
                ),
              ),
            ),
            onTap: () async {
              p.ktpFile = await CustomImagePicker.selectImageFromGallery();
              if (p.ktpFile != null)
                p.ktpFileC.text = path.basename(p.ktpFile!.path);
              setState(() {});
              FocusManager.instance.primaryFocus?.unfocus();
            },
          ),
          Constant.xSizedBox16,
          fieldFile(
            controller: p.npwpFileC,
            text: 'File NPWP',
            enabled: p.jenisToko != 2,
            extraLabeltext: Padding(
              padding: EdgeInsets.symmetric(horizontal: 5),
              child: Text(
                'Ext: jpeg, jpg, png     Max file: 100mb',
                style: Constant.primaryTextStyle.copyWith(
                  color: Constant.textColor2,
                  fontSize: 12,
                ),
              ),
            ),
            onTap: () async {
              if (p.jenisToko != 2) {
                p.npwpFile = await CustomImagePicker.selectImageFromGallery();
                if (p.npwpFile != null)
                  p.npwpFileC.text = path.basename(p.npwpFile!.path);
                setState(() {});
                FocusManager.instance.primaryFocus?.unfocus();
              }
            },
          ),
          Constant.xSizedBox16,
          fieldFile(
            controller: p.bankNumberFileC,
            text: 'File Buku Rekening',
            extraLabeltext: Padding(
              padding: EdgeInsets.symmetric(horizontal: 5),
              child: Text(
                'Ext: jpeg, jpg, png     Max file: 100mb',
                style: Constant.primaryTextStyle.copyWith(
                  color: Constant.textColor2,
                  fontSize: 12,
                ),
              ),
            ),
            onTap: () async {
              p.bankNumberFile =
                  await CustomImagePicker.selectImageFromGallery();
              if (p.bankNumberFile != null)
                p.bankNumberFileC.text = path.basename(p.bankNumberFile!.path);
              setState(() {});
              FocusManager.instance.primaryFocus?.unfocus();
            },
          ),
          Constant.xSizedBox16,
          fieldFile(
            controller: p.spSkpFileC,
            text: 'File SP SKP',
            enabled: p.jenisToko == 1,
            extraLabeltext: Padding(
              padding: EdgeInsets.symmetric(horizontal: 5),
              child: Text(
                'Ext: jpeg, jpg, png     Max file: 100mb',
                style: Constant.primaryTextStyle.copyWith(
                  color: Constant.textColor2,
                  fontSize: 12,
                ),
              ),
            ),
            onTap: () async {
              if (p.jenisToko == 1) {
                p.spSkpFile = await CustomImagePicker.selectImageFromGallery();
                if (p.spSkpFile != null)
                  p.spSkpFileC.text = path.basename(p.spSkpFile!.path);
                setState(() {});
                FocusManager.instance.primaryFocus?.unfocus();
              }
            },
          ),
          Constant.xSizedBox16,
          fieldFile(
            controller: p.nibFileC,
            text: 'File NIB',
            extraLabeltext: Padding(
              padding: EdgeInsets.symmetric(horizontal: 5),
              child: Text(
                'Ext: jpeg, jpg, png     Max file: 100mb',
                style: Constant.primaryTextStyle.copyWith(
                  color: Constant.textColor2,
                  fontSize: 12,
                ),
              ),
            ),
            onTap: () async {
              p.nibFile = await CustomImagePicker.selectImageFromGallery();
              p.nibFileC.text = path.basename(p.nibFile!.path);
              setState(() {});
              FocusManager.instance.primaryFocus?.unfocus();
            },
          ),
          Constant.xSizedBox16,
          fieldFile(
            controller: p.suratPernyataanFileC,
            text: 'Surat Pernyataan',
            extraLabeltext: Padding(
              padding: EdgeInsets.symmetric(horizontal: 5),
              child: Text(
                'Ext: gif, jpg, jpeg, bmp, png, pdf     Max file: 100mb',
                style: Constant.primaryTextStyle.copyWith(
                  color: Constant.textColor2,
                  fontSize: 12,
                ),
              ),
            ),
            onTap: () async {
              p.suratPernyataanFile =
                  await CustomImagePicker.selectImageFromGallery();
              p.suratPernyataanFileC.text =
                  path.basename(p.suratPernyataanFile!.path);
              setState(() {});
              FocusManager.instance.primaryFocus?.unfocus();
            },
          ),
          Constant.xSizedBox16,
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                btn(
                  path: Assets.iconsIcSuratPernyataan,
                  label: 'Template Pernyataan',
                  color: Constant.greenColor,
                  onTap: () async {
                    // Fitur Template Non-PKP belum tersedia di API baru
                    // Endpoint /templatenonpkpseller tidak ada di Laravel baru
                    Utils.showFailed(
                        msg: 'Fitur Template Pernyataan belum tersedia di versi ini');
                  },
                ),
                SizedBox(width: 12),
                btn(
                  path: Assets.iconsIcTtdLangsung,
                  label: 'Ttd Langsung',
                  color: Constant.pesananDikirimColor,
                  onTap: () async {
                    showTtdDialog(context);
                  },
                ),
              ],
            ),
          ),
          Constant.xSizedBox16,
        ],
      );
    }

    Widget bottomBar() {
      return BottomAppBar(
        height: kBottomNavigationBarHeight + 24,
        color: Colors.white,
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
      appBar: appBar(),
      body: ListView(
        shrinkWrap: true,
        children: [
          header(),
          form(),
        ],
      ),
      bottomNavigationBar: bottomBar(),
    );
  }
}
