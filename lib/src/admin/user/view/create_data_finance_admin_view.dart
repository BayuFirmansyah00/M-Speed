import 'package:flutter/material.dart';
import 'package:mspeed/common/base/base_state.dart';
import 'package:mspeed/common/component/custom_appbar.dart';
import 'package:mspeed/common/component/custom_button.dart';
import 'package:mspeed/common/component/custom_navigator.dart';
import 'package:mspeed/common/component/custom_textField.dart';
import 'package:mspeed/generated/assets.dart';
import 'package:mspeed/src/admin/user/model/keuangan_admin_model.dart';
import 'package:mspeed/src/admin/user/provider/admin_form_keuangan_provider.dart';
import 'package:mspeed/utils/utils.dart';
import 'package:provider/provider.dart';

class CreateDataFinanceAdminView extends StatefulWidget {
  const CreateDataFinanceAdminView({super.key, this.keuangan});
  final KeuanganAdminModelData? keuangan;

  @override
  State<CreateDataFinanceAdminView> createState() =>
      _CreateDataFinanceAdminViewState();
}

class _CreateDataFinanceAdminViewState
    extends BaseState<CreateDataFinanceAdminView> {
  @override
  void initState() {
    getData();
    super.initState();
  }

  getData() async {
    final p = context.read<AdminFormKeuanganProvider>();
    await p.setData(widget.keuangan);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AdminFormKeuanganProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar.appBar(
        context,
        "${widget.keuangan == null ? "Create" : "Edit"} Finance",
        color: Colors.white,
        isCenter: true,
        foregroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        action: [
          if (widget.keuangan != null)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: InkWell(
                onTap: () async {
                  await handleTap(() async {
                    Utils.showYesNoDialog(
                      context: context,
                      title: "Konfirmasi",
                      desc: "Apakah Anda yakin ingin simpan data ini",
                      yesCallback: () async {
                        handleTap(() async {
                          CusNav.nPop(context);
                          await context
                              .read<AdminFormKeuanganProvider>()
                              .sendKeuangan(context,
                                  keuanganId: widget.keuangan?.ID);
                        });
                      },
                      noCallback: () {
                        Navigator.pop(context);
                      },
                    );
                  });
                },
                child: Image.asset(Assets.iconsIcDeleteOutlined, scale: 4),
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
                controller: p.firstNameC,
                labelText: "First Name",
                hintText: 'First Name',
              ),
              SizedBox(height: 12),
              CustomTextField.borderTextField(
                controller: p.lastNameC,
                labelText: "Last Name",
                hintText: 'Last Name',
              ),
              SizedBox(height: 12),
              CustomTextField.borderTextField(
                controller: p.emailC,
                labelText: "Email",
                hintText: "Email",
              ),
              SizedBox(height: 12),
              CustomTextField.borderTextField(
                  controller: p.phoneNumberC,
                  labelText: "Telp / No HP",
                  hintText: "No Telepon",
                  textInputType: TextInputType.phone),
              SizedBox(height: 12),
              CustomTextField.borderTextArea(
                  controller: p.alamatC,
                  labelText: "Alamat",
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
              CustomTextField.borderTextField(
                controller: p.passwordC,
                labelText: "Password",
                hintText: "password",
                textInputType: TextInputType.visiblePassword,
                obscureText: true,

                // hintText: "Enter your name",
              ),
              SizedBox(height: 12),
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
                desc: "Apakah Anda Yakin Ingin Menyimpan Data Ini",
                yesCallback: () async {
                  handleTap(() async {
                    CusNav.nPop(context);
                    await context
                        .read<AdminFormKeuanganProvider>()
                        .sendKeuangan(context, keuanganId: widget.keuangan?.ID);
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
