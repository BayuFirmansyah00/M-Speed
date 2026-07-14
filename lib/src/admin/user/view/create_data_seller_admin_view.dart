import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:mspeed/common/component/custom_appbar.dart';
import 'package:mspeed/common/component/custom_button.dart';
import 'package:mspeed/common/helper/Constant.dart';
import 'package:mspeed/src/admin/home/model/seller_admin_model.dart';
import 'package:mspeed/src/admin/user/provider/admin_form_seller_provider.dart';
import 'package:mspeed/src/buyer/address/view/custom_map_view.dart';
import 'package:mspeed/src/buyer/address/view/search_location_view.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';

import '../../../../common/component/custom_textfield.dart';

class CreateDataSellerAdminView extends StatefulWidget {
  const CreateDataSellerAdminView({super.key, this.seller});

  final SellerAdminModelData? seller;

  @override
  State<CreateDataSellerAdminView> createState() =>
      _CreateDataSellerAdminViewState();
}

class _CreateDataSellerAdminViewState extends State<CreateDataSellerAdminView> {
  // Initial location
  final LatLng _initialPosition = LatLng(37.42796133580664, -122.085749655962);

  // Marker and camera position
  LatLng _currentPosition = LatLng(37.42796133580664, -122.085749655962);
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _currentPosition = _initialPosition;
  }

  void _onMapTapped(LatLng location) {
    setState(() {
      _currentPosition = location;
      latC.text = location.latitude.toString();
      lonC.text = location.longitude.toString();
      _markers.clear();
      _markers.add(
        Marker(
          // markerId: MarkerId('selected_location'),
          point: location,
          child: Icon(
            Icons.location_on,
            color: Colors.red,
          ),
        ),
      );
    });
  }

  Widget splitTextField(TextEditingController controller, String hint) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        hoverColor: Constant.primaryColor,
        focusColor: Constant.primaryColor,
        errorStyle: TextStyle(color: Colors.red),
        hintStyle: TextStyle(color: Constant.textHintColor2),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            width: 0.5,
            color: Constant.borderSearchColor,
            style: BorderStyle.solid,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            width: 0.5,
            color: Constant.borderSearchColor,
            style: BorderStyle.solid,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            width: 1,
            color: Constant.primaryColor,
            style: BorderStyle.solid,
          ),
        ),
      ),
      validator: (value) {
        if ((value == null || value.isEmpty)) {
          return "Maaf, Lokasi wajib diisi";
        }
        return null;
      },
    );
  }

  final latC = TextEditingController();
  final lonC = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AdminFormSellerProvider>();

    Widget fileButton(
        {required String title, required Function(XFile) onChoose}) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              title,
              style: Constant.primaryTextStyle.copyWith(
                fontSize: 14,
                fontWeight: Constant.medium,
              ),
            ),
          ),
          InkWell(
            onTap: () async {
              final result =
                  await FilePicker.pickFiles(allowMultiple: false);
              if (result != null) {
                final file = result.files.singleOrNull;
                print('Selected file: ${result.files.singleOrNull?.name}');

                if (file != null) {
                  onChoose(file.xFile);
                }
              }
            },
            child: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border.all(
                  width: 0.5,
                  color: Constant.borderSearchColor,
                  style: BorderStyle.solid,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Browse'),
                  Icon(
                    Icons.cloud_upload,
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
          ),
        ],
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
                return SearchLocationView.create(currentPosition);
              },
            ));

            if (pickedData != null) {
              p.setMapLocation(pickedData).then((value) {
                setState(() {});
              });
            }
          },
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar.appBar(
        context,
        "${widget.seller == null ? "Create" : "Edit"} Seller",
        color: Colors.white,
        isCenter: true,
        foregroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        action: [
          if (widget.seller != null)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: InkWell(
                onTap: () {},
                child: Icon(
                  Icons.delete_outline,
                  size: 27,
                  color: Constant.primaryColor,
                ),
              ),
            )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextField.borderTextField(
                controller: p.companyNameC,
                labelText: "Nama Toko / Perusahaan",
                hintText: 'Nama Toko',
              ),
              SizedBox(height: 12),
              CustomTextField.borderTextField(
                  controller: p.emailC,
                  labelText: "Email",
                  hintText: "Email",
                  enabled: widget.seller == null),
              SizedBox(height: 12),
              CustomTextField.borderTextField(
                  controller: p.ownerNameC,
                  labelText: "Nama Pemilik",
                  hintText: "Nama Pemilik"
                  // hintText: "Enter your name",
                  ),
              SizedBox(height: 12),
              CustomTextField.borderTextField(
                  controller: p.cpNameC,
                  labelText: "Nama Contact Person",
                  hintText: "Nama Contact Person"),
              SizedBox(height: 12),
              CustomTextField.borderTextField(
                  controller: p.cpPhoneNumberC,
                  labelText: "Telp Contact Person",
                  hintText: "Telp Contact Person",
                  textInputType: TextInputType.phone),
              SizedBox(height: 12),
              CustomTextField.borderTextField(
                  controller: p.phoneNumberC,
                  labelText: "No Telepon",
                  hintText: "No Telepon",
                  textInputType: TextInputType.phone),
              SizedBox(height: 12),
              CustomTextField.borderTextField(
                  controller: p.kbliC, labelText: "KBLI", hintText: "KBLI"
                  // hintText: "Enter your name",
                  ),
              SizedBox(height: 12),
              CustomTextField.borderTextArea(
                  controller: p.alamatC,
                  labelText: "Alamat perusahaan",
                  hintText: "alamat",
                  focusNode: FocusNode()
                  // hintText: "Enter your name",
                  ),
              SizedBox(height: 12),
              CustomTextField.borderTextField(
                  controller: p.cityC, labelText: "Kota", hintText: "Kota"
                  // hintText: "Enter your name",
                  ),
              SizedBox(height: 12),
              Text(
                'Koordinat',
                style: Constant.primaryTextStyle.copyWith(
                  fontSize: 14,
                  fontWeight: Constant.medium,
                ),
              ),
              SizedBox(
                height: 8,
              ),
              Row(
                children: [
                  Expanded(child: splitTextField(latC, 'latitude')),
                  SizedBox(
                    width: 12,
                  ),
                  Expanded(child: splitTextField(lonC, 'longitude')),
                ],
              ),
              SizedBox(height: 12),
              Text(
                'Select From Map',
                style: Constant.primaryTextStyle.copyWith(
                  fontSize: 14,
                  fontWeight: Constant.medium,
                ),
              ),
              SizedBox(
                height: 8,
              ),
              SizedBox(
                height: 186,
                width: double.infinity,
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: _initialPosition,
                    initialZoom: 14.4746,
                    onTap: (tapPosition, point) {
                      _onMapTapped(point);
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                      subdomains: ['a', 'b', 'c'],
                    ),
                    MarkerLayer(markers: _markers.toList())
                  ],
                ),
              ),
              SizedBox(height: 12),
              CustomTextField.borderTextField(
                controller: p.npwpC,
                labelText: "No NPWP",
                hintText: "NPWP",
                // hintText: "Enter your name",
              ),
              SizedBox(height: 12),
              CustomTextField.borderTextField(
                controller: p.ktpC,
                labelText: "No. KTP / Identitas",
                hintText: "KTP",
                // hintText: "Enter your name",
              ),
              SizedBox(height: 12),
              Text(
                'Rekening Bank',
                style: Constant.primaryTextStyle.copyWith(
                  fontSize: 14,
                  fontWeight: Constant.medium,
                ),
              ),
              SizedBox(
                height: 8,
              ),
              Row(
                children: [
                  Expanded(flex: 1, child: splitTextField(latC, 'Bank')),
                  SizedBox(
                    width: 4,
                  ),
                  Expanded(flex: 2, child: splitTextField(lonC, 'No Rekening')),
                ],
              ),
              SizedBox(height: 12),
              CustomTextField.borderTextField(
                controller: p.bankAccountC,
                labelText: "Rekening Atas Nama",
                hintText: "Atas Nama",
                // hintText: "Enter your name",
              ),
              SizedBox(
                height: 12,
              ),
              fileButton(title: 'File NPWP', onChoose: (_) {}),
              SizedBox(
                height: 12,
              ),
              fileButton(title: 'File No. KTP / Identitas', onChoose: (_) {}),
              SizedBox(
                height: 12,
              ),
              fileButton(title: 'File Buku Rekening', onChoose: (_) {}),
              SizedBox(
                height: 12,
              ),
              fileButton(title: 'File SP SKP', onChoose: (_) {}),
              SizedBox(
                height: 32,
              )
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        child: CustomButton.mainButton(
          'Simpan',
          borderRadius: BorderRadius.circular(12),
          () async {
            // await context
            //     .read<AddressProvider>()
            //     .sendAddress(withLoading: true, isEdit: widget.isEdit)
            //     .then((value) async {
            //   Utils.showSuccess(
            //       msg: "Sukses ${widget.isEdit ? "Edit" : "Tambah"} Alamat");
            //   await Future.delayed(Duration(seconds: 2));
            //
            //   Navigator.pop(context, true);
            //   p.clearAddressForm();
            //   return true;
            // }).onError((error, stackTrace) async {
            //   Utils.showFailed(
            //       msg: "Gagal ${widget.isEdit ? "Edit" : "Tambah"} Alamat");
            //   await Future.delayed(Duration(seconds: 2));
            //   return false;
            // });
          },
          // margin: EdgeInsets.symmetric(horizontal: 16),
        ),
      ),
    );
  }
}
