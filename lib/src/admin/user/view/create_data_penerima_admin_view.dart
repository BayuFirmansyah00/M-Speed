import 'package:flutter/material.dart';
import 'package:mspeed/common/base/base_state.dart';
import 'package:mspeed/common/component/custom_navigator.dart';
import 'package:mspeed/common/component/custom_dropdown.dart';
import 'package:mspeed/src/admin/user/model/penerima_admin_model.dart';
import 'package:mspeed/src/admin/user/provider/admin_form_penerima_provider.dart';
import 'package:mspeed/src/admin/user/view/admin_form_widgets.dart';
import 'package:mspeed/utils/utils.dart';
import 'package:provider/provider.dart';

class CreateDataPenerimaAdminView extends StatefulWidget {
  const CreateDataPenerimaAdminView({super.key, this.penerima});
  final PenerimaAdminModelData? penerima;

  @override
  State<CreateDataPenerimaAdminView> createState() =>
      _CreateDataPenerimaAdminViewState();
}

class _CreateDataPenerimaAdminViewState
    extends BaseState<CreateDataPenerimaAdminView> {
  static const _gradient = [Color(0xff8B5CF6), Color(0xff7C3AED)];
  static const _accent = Color(0xff8B5CF6);

  bool get isEdit => widget.penerima != null;

  @override
  void initState() {
    getData();
    super.initState();
  }

  getData() async {
    final p = context.read<AdminFormPenerimaProvider>();
    await p.setData(widget.penerima);
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
                .read<AdminFormPenerimaProvider>()
                .sendPenerima(context, penerimaId: widget.penerima?.ID);
          });
        },
        noCallback: () => Navigator.pop(context),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AdminFormPenerimaProvider>();

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
                icon: Icons.person_pin_rounded,
                title: isEdit ? 'Edit Penerima' : 'Tambah Penerima',
                subtitle: isEdit
                    ? 'Perbarui data penerima'
                    : 'Isi data untuk menambah penerima baru',
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
                      const SizedBox(height: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Manager',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xff4A5568),
                            ),
                          ),
                          const SizedBox(height: 6),
                          CustomDropdown.normalDropdown(
                            controller: TextEditingController(), // Not strictly needed
                            hintText: 'Pilih Manager (Opsional)',
                            list: p.allManagers
                                .map(
                                  (e) => DropdownMenuItem(
                                    value: e['id']?.toString() ?? '0',
                                    child: Text(e['name'] ?? ''),
                                  ),
                                )
                                .toList(),
                            selectedItem: p.selectedManagerId,
                            onChanged: (value) {
                              p.selectedManagerId = value;
                              setState(() {});
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  AdminFormSection(
                    title: 'Keamanan & Akses',
                    icon: Icons.lock_outline_rounded,
                    accentColor: _accent,
                    children: [
                      AdminFormField(
                        controller: p.accessC,
                        label: 'Hak Akses',
                        hint: 'Masukkan hak akses (opsional)',
                        icon: Icons.admin_panel_settings_outlined,
                      ),
                      const SizedBox(height: 16),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xffE2E8F0)),
                        ),
                        child: SwitchListTile(
                          title: const Text(
                            'Status Aktif',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xff1E293B),
                            ),
                          ),
                          subtitle: Text(
                            p.isActive ? 'Akun aktif dan dapat login' : 'Akun dinonaktifkan',
                            style: TextStyle(
                              fontSize: 12,
                              color: p.isActive ? Colors.green : Colors.red,
                            ),
                          ),
                          value: p.isActive,
                          onChanged: (val) {
                            setState(() {
                              p.isActive = val;
                            });
                          },
                          activeColor: _accent,
                        ),
                      ),
                      const SizedBox(height: 16),
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
