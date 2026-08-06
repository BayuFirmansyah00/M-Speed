import 'package:flutter/material.dart';
import 'package:mspeed/common/base/base_state.dart';
import 'package:mspeed/common/component/custom_appbar.dart';
import 'package:mspeed/common/component/custom_button.dart';
import 'package:mspeed/common/component/custom_navigator.dart';
import 'package:mspeed/common/component/custom_textField.dart';
import 'package:mspeed/src/admin/master/model/subdit_admin_model.dart';
import 'package:mspeed/src/admin/master/provider/master_provider.dart';
import 'package:mspeed/utils/utils.dart';
import 'package:provider/provider.dart';

class AddSubditAdminView extends StatefulWidget {
  const AddSubditAdminView({super.key, this.subdit});

  final SubditAdminModelData? subdit;

  @override
  State<AddSubditAdminView> createState() => _AddSubditAdminViewState();
}

class _AddSubditAdminViewState extends BaseState<AddSubditAdminView> {
  @override
  void initState() {
    getData();
    super.initState();
  }

  getData() async {
    final p = context.read<MasterProvider>();
    await p.setDataSubdit(widget.subdit);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<MasterProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar.appBar(
        context,
        "${widget.subdit == null ? "Buat" : "Edit"} Sub Direktorat",
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
                  controller: p.subditCodeC,
                  labelText: "Kode Subdit",
                  hintText: 'Kode Subdit',
                ),
                SizedBox(height: 12),
                CustomTextField.borderTextField(
                  controller: p.subditNameC,
                  labelText: "Nama Subdit",
                  hintText: 'Nama Subdit',
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16),
        child: SafeArea(
          child: SizedBox(
            height: 50,
            child: CustomButton.mainButton('Simpan', () async {
              await handleTap(() async {
                Utils.showYesNoDialog(
                  context: context,
                  title: "Konfirmasi",
                  desc: "Apakah Anda Yakin Ingin Menyimpan Data Ini",
                  yesCallback: () async {
                    handleTap(() async {
                      CusNav.nPop(context);
                      await context.read<MasterProvider>().sendSubdit(
                        context,
                        subditId: widget.subdit?.id?.toString(),
                      );
                    });
                  },
                  noCallback: () {
                    Navigator.pop(context);
                  },
                );
              });
            }, borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
    );
  }
}
