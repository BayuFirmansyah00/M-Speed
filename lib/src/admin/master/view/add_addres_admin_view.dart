import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:mspeed/common/base/base_state.dart';
import 'package:mspeed/common/component/custom_appbar.dart';
import 'package:mspeed/common/component/custom_button.dart';
import 'package:mspeed/common/component/custom_dropdown.dart';
import 'package:mspeed/common/component/custom_navigator.dart';
import 'package:mspeed/common/component/custom_textField.dart';
import 'package:mspeed/src/admin/master/model/alamat_admin_model.dart';
import 'package:mspeed/src/admin/master/model/provinsi_admin_model.dart';
import 'package:mspeed/src/admin/master/model/kota_admin_model.dart';
import 'package:mspeed/src/admin/master/provider/master_provider.dart';
import 'package:mspeed/utils/utils.dart';
import 'package:provider/provider.dart';

class AddAddressAdminView extends StatefulWidget {
  const AddAddressAdminView({super.key, this.alamat});

  final AlamatAdminModelData? alamat;

  @override
  State<AddAddressAdminView> createState() => _AddAddressAdminViewState();
}

class _AddAddressAdminViewState extends BaseState<AddAddressAdminView> {
  final _cityDropdownKey = GlobalKey<DropdownSearchState<String>>();

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
      backgroundColor: const Color(0xffF5F6FA),
      appBar: CustomAppBar.appBar(
        context,
        "${widget.alamat == null ? "Tambah" : "Ubah"} Alamat",
        color: Colors.white,
        isCenter: true,
        foregroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: WillPopScope(
        onWillPop: () async {
          return true;
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xffE2E4E9), width: 1),
                ),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomDropdown.searchDropdown(
                      labelText: 'Provinsi',
                      hintText: 'Pilih Provinsi',
                      selectedItem:
                          p.provinceC.text.isNotEmpty ? p.provinceC.text : null,
                      list:
                          (p.provinsiAdminModel.data ?? [])
                              .map((e) => e?.nama ?? '')
                              .where((nama) => nama.isNotEmpty)
                              .toList(),
                      onChanged: (value) async {
                        if (value != null && value != p.provinceC.text) {
                          final selectedProvObj =
                              (p.provinsiAdminModel.data ?? []).cast<ProvinsiAdminModelData?>().firstWhere(
                                (e) => e?.nama == value,
                                orElse: () => null,
                              );
                          p.selectedProvince = selectedProvObj?.ID;
                          p.provinceC.text = value;
                          p.selectedCity = null;
                          p.cityC.clear();
                          await p.fetchKotaAdmin();
                          setState(() {});

                          Future.delayed(const Duration(milliseconds: 300), () {
                            _cityDropdownKey.currentState?.openDropDownSearch();
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    CustomDropdown.searchDropdown(
                      enabled: p.selectedProvince != null,
                      dropdownKey: _cityDropdownKey,
                      labelText: 'Kota',
                      hintText: 'Pilih Kota',
                      selectedItem:
                          p.cityC.text.isNotEmpty ? p.cityC.text : null,
                      list:
                          (p.kotaAdminModel.data ?? [])
                              .map((e) => e?.nama ?? '')
                              .where((nama) => nama.isNotEmpty)
                              .toList(),
                      onChanged: (value) {
                        if (value != null && value != p.cityC.text) {
                          final selectedCityObj = (p.kotaAdminModel.data ?? []).where((e) => e?.nama == value).firstOrNull;
                          p.selectedCity = selectedCityObj?.id;
                          p.cityC.text = value;
                          setState(() {});
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    CustomTextField.borderTextArea(
                      controller: p.alamatC,
                      labelText: "Alamat Lengkap",
                      hintText: "Masukkan alamat lengkap",
                      focusNode: FocusNode(),
                    ),
                  ],
                ),
              ),
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
            await handleTap(() async {
              Utils.showYesNoDialog(
                context: context,
                title: "Konfirmasi",
                desc: "Apakah Anda Yakin Ingin Menyimpan Data Ini?",
                yesCallback: () async {
                  handleTap(() async {
                    CusNav.nPop(context);
                    await context.read<MasterProvider>().sendAlamat(
                      context,
                      alamatId: widget.alamat?.id,
                    );
                  });
                },
                noCallback: () {
                  Navigator.pop(context);
                },
              );
            });
          },
        ),
      ),
    );
  }
}
