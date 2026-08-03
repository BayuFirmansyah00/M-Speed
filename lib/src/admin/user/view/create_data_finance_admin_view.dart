import 'package:flutter/material.dart';
import 'package:mspeed/common/base/base_state.dart';
import 'package:mspeed/common/component/custom_dropdown.dart';
import 'package:mspeed/common/component/custom_navigator.dart';
import 'package:mspeed/src/admin/user/model/keuangan_admin_model.dart';
import 'package:mspeed/src/admin/user/provider/admin_form_keuangan_provider.dart';
import 'package:mspeed/src/admin/user/view/admin_form_widgets.dart';
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
  static const _gradient = [Color(0xffF59E0B), Color(0xffD97706)];
  static const _accent = Color(0xffF59E0B);

  bool get isEdit => widget.keuangan != null;

  @override
  void initState() {
    getData();
    super.initState();
  }

  getData() async {
    final p = context.read<AdminFormKeuanganProvider>();
    await p.setData(widget.keuangan);
  }

  Future<void> _save() async {
    await handleTap(() async {
      Utils.showYesNoDialog(
        context: context,
        title: 'Konfirmasi Simpan',
        desc: 'Pastikan data sudah benar sebelum disimpan.',
        yesCallback: () async {
          handleTap(() async {
            CusNav.nPop(context);
            await context
                .read<AdminFormKeuanganProvider>()
                .sendKeuangan(context, keuanganId: widget.keuangan?.ID);
          });
        },
        noCallback: () => Navigator.pop(context),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AdminFormKeuanganProvider>();

    return Scaffold(
      backgroundColor: const Color(0xffF5F6FA),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 120,
            backgroundColor: _gradient[1],
            surfaceTintColor: Colors.transparent,
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon:
                  const Icon(Icons.arrow_back_rounded, color: Colors.white),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: AdminFormHeader(
                gradient: _gradient,
                icon: Icons.account_balance_rounded,
                title: isEdit ? 'Edit Finance' : 'Tambah Finance',
                subtitle: isEdit
                    ? 'Perbarui data pengguna finance'
                    : 'Isi data untuk menambah finance baru',
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
              child: Column(
                children: [
                  AdminFormSection(
                    title: 'Informasi Dasar',
                    icon: Icons.person_outline_rounded,
                    accentColor: _accent,
                    children: [
                      AdminFormField(
                          controller: p.firstNameC,
                          label: 'First Name',
                          hint: 'Masukkan nama depan',
                          icon: Icons.badge_outlined),
                      AdminFormField(
                          controller: p.lastNameC,
                          label: 'Last Name',
                          hint: 'Masukkan nama belakang',
                          icon: Icons.badge_outlined),
                      AdminFormField(
                          controller: p.emailC,
                          label: 'Email',
                          hint: 'Masukkan alamat email',
                          icon: Icons.email_outlined,
                          inputType: TextInputType.emailAddress),
                      AdminFormField(
                          controller: p.phoneNumberC,
                          label: 'No. Telepon',
                          hint: 'Masukkan no. HP',
                          icon: Icons.phone_outlined,
                          inputType: TextInputType.phone),
                    ],
                  ),
                  const SizedBox(height: 14),
                  AdminFormSection(
                    title: 'Data Organisasi',
                    icon: Icons.corporate_fare_rounded,
                    accentColor: _accent,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Sub Direktorat',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xff4A5568),
                            ),
                          ),
                          const SizedBox(height: 6),
                          CustomDropdown.normalDropdown(
                            controller: p.subditC,
                            hintText: 'Pilih Subdit',
                            list: p.subdirektorates
                                .map(
                                  (e) => DropdownMenuItem(
                                    value: e['id']?.toString() ?? '0',
                                    child: Text(e['subdit_name'] ?? ''),
                                  ),
                                )
                                .toList(),
                            selectedItem: p.selectedSubditId,
                            onChanged: (value) {
                              p.selectedSubditId = value;
                              p.selectedDepartmentId = null; // reset department when subdit changes
                              setState(() {});
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Departemen',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xff4A5568),
                            ),
                          ),
                          const SizedBox(height: 6),
                          CustomDropdown.normalDropdown(
                            controller: p.departmentC,
                            hintText: 'Pilih Departemen',
                            list: p.filteredDepartments
                                .map(
                                  (e) => DropdownMenuItem(
                                    value: e['id']?.toString() ?? '0',
                                    child: Text(e['name'] ?? e['department_name'] ?? ''),
                                  ),
                                )
                                .toList(),
                            selectedItem: p.selectedDepartmentId,
                            onChanged: (value) {
                              p.selectedDepartmentId = value;
                              setState(() {});
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  AdminFormSection(
                    title: 'Keamanan',
                    icon: Icons.lock_outline_rounded,
                    accentColor: _accent,
                    children: [
                      AdminFormField(
                          controller: p.passwordC,
                          label: 'Password',
                          hint: 'Masukkan password',
                          icon: Icons.lock_outline_rounded,
                          obscure: true,
                          inputType: TextInputType.visiblePassword),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar:
          AdminSaveBar(accentColor: _accent, gradient: _gradient, onSave: _save),
    );
  }
}
