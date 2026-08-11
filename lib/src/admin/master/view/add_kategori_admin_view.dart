import 'package:flutter/material.dart';
import 'package:mspeed/common/base/base_state.dart';
import 'package:mspeed/common/component/custom_appbar.dart';
import 'package:mspeed/common/component/custom_button.dart';
import 'package:mspeed/common/component/custom_navigator.dart';
import 'package:mspeed/common/component/custom_textField.dart';
import 'package:mspeed/src/admin/master/model/kategori_admin_model.dart';
import 'package:mspeed/src/admin/master/provider/master_provider.dart';
import 'package:mspeed/utils/utils.dart';
import 'package:provider/provider.dart';

class AddKategoriAdminView extends StatefulWidget {
  const AddKategoriAdminView({super.key, this.kategori});

  final KategoriAdminModelData? kategori;

  @override
  State<AddKategoriAdminView> createState() => _AddKategoriAdminViewState();
}

class _AddKategoriAdminViewState extends BaseState<AddKategoriAdminView> {
  @override
  void initState() {
    getData();
    super.initState();
  }

  getData() async {
    final p = context.read<MasterProvider>();
    await p.setDataKategori(widget.kategori);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<MasterProvider>();

    return Scaffold(
      backgroundColor: const Color(0xffF5F6FA),
      appBar: CustomAppBar.appBar(
        context,
        "${widget.kategori == null ? "Buat" : "Edit"} Kategori",
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
                    CustomTextField.borderTextField(
                      controller: p.namaKategoriC,
                      labelText: "Nama Kategori",
                      hintText: 'Contoh: Elektronik, Pakaian',
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
                    await context.read<MasterProvider>().sendKategori(
                          context,
                          kategoriid: widget.kategori?.ID,
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
