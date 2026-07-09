import 'package:flutter/material.dart';
import 'package:mspeed/common/component/custom_appbar.dart';
import 'package:mspeed/common/component/custom_button.dart';
import 'package:mspeed/common/component/custom_textfield.dart';
import 'package:mspeed/src/admin/user/model/audit_admin_model.dart';
import 'package:mspeed/src/admin/user/provider/admin_form_audit_provider.dart';
import 'package:mspeed/utils/utils.dart';
import 'package:provider/provider.dart';

class CreateDataAuditAdminView extends StatefulWidget {
  const CreateDataAuditAdminView({super.key, this.audit});

  final AuditAdminModelData? audit;

  @override
  State<CreateDataAuditAdminView> createState() =>
      _CreateDataAuditAdminViewState();
}

class _CreateDataAuditAdminViewState extends State<CreateDataAuditAdminView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminFormAuditProvider>().setData(widget.audit);
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AdminFormAuditProvider>();
    final isEdit = widget.audit != null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar.appBar(
        context,
        "${isEdit ? "Edit" : "Create"} Audit",
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
                controller: p.usernameC,
                labelText: "Username",
                hintText: 'Username',
                enabled: !isEdit, // biasanya username tidak boleh diubah setelah dibuat
              ),
              SizedBox(height: 12),
              CustomTextField.borderTextField(
                controller: p.fullnameC,
                labelText: "Full Name",
                hintText: 'Full Name',
              ),
              SizedBox(height: 12),
              CustomTextField.borderTextField(
                controller: p.passwordC,
                labelText: isEdit
                    ? "Password (kosongkan jika tidak diubah)"
                    : "Password",
                hintText: "Password",
                obscureText: true,
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
              await p.sendAudit(
                context,
                withLoading: false,
                auditId: widget.audit?.ID,
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