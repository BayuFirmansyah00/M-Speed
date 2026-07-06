import 'package:flutter/material.dart';
import 'package:mspeed/common/base/base_state.dart';
import 'package:mspeed/common/component/custom_appbar.dart';
import 'package:mspeed/common/component/custom_button.dart';
import 'package:mspeed/common/component/custom_navigator.dart';
import 'package:mspeed/common/component/custom_textField.dart';
import 'package:mspeed/src/admin/master/model/pajak_admin_model.dart';
import 'package:mspeed/src/admin/master/provider/master_provider.dart';
import 'package:mspeed/utils/utils.dart';
import 'package:provider/provider.dart';

class AddPajakAdminView extends StatefulWidget {
  const AddPajakAdminView({super.key, this.pajak});

  final PajakAdminModelData? pajak;

  @override
  State<AddPajakAdminView> createState() => _AddPajakAdminViewState();
}

class _AddPajakAdminViewState extends BaseState<AddPajakAdminView> {
  @override
  void initState() {
    getData();
    super.initState();
  }

  getData() async {
    final p = context.read<MasterProvider>();
    await p.setDataPajak(widget.pajak);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<MasterProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar.appBar(
        context,
        "${widget.pajak == null ? "Buat" : "Edit"} Pajak",
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
                CustomTextField.borderTextField(
                  controller: p.pajakC,
                  labelText: "Nama Pajak",
                  hintText: 'Nama Pajak',
                ),
                SizedBox(height: 12),
                CustomTextField.borderTextField(
                  controller: p.prosentaseC,
                  labelText: "Prosentase",
                  hintText: 'Prosentase',
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
                        .sendAlamat(context, alamatId: widget.pajak?.id);
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
