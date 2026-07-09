import 'package:flutter/material.dart';
import 'package:mspeed/common/component/custom_appbar.dart';
import 'package:mspeed/common/component/custom_button.dart';
import 'package:mspeed/common/component/custom_textfield.dart';
import 'package:mspeed/common/helper/constant.dart';
import 'package:mspeed/src/admin/user/model/manager_admin_model.dart';
import 'package:mspeed/src/admin/user/provider/admin_form_manager_provider.dart';
import 'package:mspeed/utils/utils.dart';
import 'package:provider/provider.dart';

class CreateDataManagerAdminView extends StatefulWidget {
  const CreateDataManagerAdminView({super.key, this.manager});

  final ManagerAdminModelData? manager;

  @override
  State<CreateDataManagerAdminView> createState() =>
      _CreateDataManagerAdminViewState();
}

class _CreateDataManagerAdminViewState
    extends State<CreateDataManagerAdminView> {
  @override
  void initState() {
    super.initState();
    // Isi form dengan data lama kalau ini mode Edit
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminFormManagerProvider>().setData(widget.manager);
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AdminFormManagerProvider>();
    final isEdit = widget.manager != null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar.appBar(
        context,
        "${isEdit ? "Edit" : "Create"} Manager",
        color: Colors.white,
        isCenter: true,
        foregroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
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
                enabled: !isEdit,
              ),
              SizedBox(height: 12),
              CustomTextField.borderTextField(
                controller: p.phoneNumberC,
                labelText: "No Telepon",
                hintText: "No Telepon",
                textInputType: TextInputType.phone,
              ),
              SizedBox(height: 12),
              CustomTextField.borderTextArea(
                controller: p.alamatC,
                labelText: "Alamat",
                hintText: "Alamat",
                focusNode: FocusNode(),
              ),
              SizedBox(height: 32),
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
            try {
              Utils.showLoading();
              await p.sendManager(
                context,
                withLoading: false,
                managerId: widget.manager?.ID,
              );
            } catch (e) {
              Utils.showFailed(msg: '$e');
            } finally {
              Utils.dismissLoading();
            }
          },
        ),
      ),
    );
  }
}