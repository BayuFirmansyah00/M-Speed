
import 'package:flutter/material.dart';
import 'package:mspeed/common/base/base_state.dart';
import 'package:mspeed/common/component/custom_appbar.dart';
import 'package:mspeed/common/component/custom_button.dart';
import 'package:mspeed/common/component/custom_dropdown.dart';
import 'package:mspeed/common/component/custom_navigator.dart';
import 'package:mspeed/common/component/custom_textField.dart';
import 'package:mspeed/src/admin/master/model/alamat_admin_model.dart';
import 'package:mspeed/src/admin/master/provider/master_provider.dart';
import 'package:mspeed/utils/utils.dart';
import 'package:provider/provider.dart';

class AddAddressAdminView extends StatefulWidget {
  const AddAddressAdminView({super.key, this.alamat});

  final AlamatAdminModelData? alamat;

  @override
  State<AddAddressAdminView> createState() =>
      _AddAddressAdminViewState();
}

class _AddAddressAdminViewState
    extends BaseState<AddAddressAdminView> {
  @override
  void initState() {
    getData();
    super.initState();
  }

  getData() async {
    final p = context.read<MasterProvider>();
    await p.setData(widget.alamat);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<MasterProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar.appBar(
        context,
        "${widget.alamat == null ? "Buat" : "Ubah"} Alamat",
        color: Colors.white,
        isCenter: true,
        foregroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: WillPopScope(
        onWillPop: () async {
          return true;
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomDropdown.normalDropdown(
                  controller: p.provinceC,
                  hintText: 'Pilih Provinsi',
                  list: (p.provinsiAdminModel.data ?? [])
                      .map(
                        (e) => DropdownMenuItem(
                      child: Text(e?.nama ?? ''),
                      value: e?.ID ?? '0',
                    ),
                  )
                      .toList(),
                  selectedItem: p.selectedProvince,
                  labelText: 'Provinsi',
                  onChanged: (value) async {
                    p.selectedProvince = value;
                    await p.fetchKotaAdmin();
                    setState(() {});
                  },
                ),
                SizedBox(height: 12),
                CustomDropdown.normalDropdown(
                  controller: p.cityC,
                  hintText: 'Pilih Kota',
                  list: (p.kotaAdminModel.data ?? [])
                      .map(
                        (e) => DropdownMenuItem(
                      child: Text(e?.nama ?? ''),
                      value: e?.ID ?? '0',
                    ),
                  )
                      .toList(),
                  selectedItem: p.selectedCity,
                  labelText: 'Kota',
                  onChanged: (value) {
                    p.selectedCity = value;
                    setState(() {});
                  },
                ),
                SizedBox(height: 12),
                CustomTextField.borderTextArea(
                  controller: p.alamatC,
                  labelText: "Alamat",
                  hintText: "Alamat",
                  focusNode: FocusNode(),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        child: CustomButton.mainButton(
          'Simpan',
          borderRadius: BorderRadius.circular(12),
              () async {
            await handleTap(() async {
              Utils.showYesNoDialog(
                context: context,
                title: "Konfirmasi",
                desc: "Apakah Anda Yakin Ingin Menyimpan Data Ini",
                yesCallback: () async {
                  handleTap(() async {
                    CusNav.nPop(context);
                    await context
                        .read<MasterProvider>()
                        .sendAlamat(context, alamatId: widget.alamat?.id);
                  });
                },
                noCallback: () {
                  Navigator.pop(context);
                },
              );
            });
          },
          // margin: EdgeInsets.symmetric(horizontal: 16),
        ),
      ),
    );
  }
}
