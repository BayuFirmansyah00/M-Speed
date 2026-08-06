import 'package:flutter/material.dart';
import 'package:mspeed/common/base/base_state.dart';
import 'package:mspeed/common/component/custom_appbar.dart';
import 'package:mspeed/common/component/custom_button.dart';
import 'package:mspeed/common/component/custom_navigator.dart';
import 'package:mspeed/common/component/custom_textField.dart';
import 'package:mspeed/src/admin/master/model/materai_admin_model.dart';
import 'package:mspeed/src/admin/master/provider/master_provider.dart';
import 'package:mspeed/utils/utils.dart';
import 'package:provider/provider.dart';

class AddMateraiAdminView extends StatefulWidget {
  const AddMateraiAdminView({super.key, this.materai});

  final MateraiAdminModelData? materai;

  @override
  State<AddMateraiAdminView> createState() => _AddMateraiAdminViewState();
}

class _AddMateraiAdminViewState extends BaseState<AddMateraiAdminView> {
  @override
  void initState() {
    getData();
    super.initState();
  }

  getData() async {
    final p = context.read<MasterProvider>();
    await p.setDataMaterai(widget.materai);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<MasterProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar.appBar(
        context,
        "${widget.materai == null ? "Buat" : "Edit"} Materai",
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
                  controller: p.typeMateraiC,
                  labelText: "Tipe Materai",
                  hintText: 'Tipe Materai',
                ),
                SizedBox(height: 12),
                CustomTextField.borderTextField(
                  controller: p.nominalMateraiC,
                  labelText: "Nominal Materai",
                  hintText: 'Nominal Materai',
                ),
                SizedBox(height: 12),
                CustomTextField.borderTextField(
                  controller: p.pathMateraiC,
                  labelText: "Path",
                  hintText: 'Misal: materai.pdf',
                ),
                SizedBox(height: 12),
                CustomTextField.borderTextField(
                  controller: p.orderDocumentIdMateraiC,
                  labelText: "Order Document ID",
                  hintText: 'ID',
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
                      await context.read<MasterProvider>().sendMaterai(
                        context,
                        materaiId: widget.materai?.id?.toString(),
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
