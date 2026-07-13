import 'package:flutter/material.dart';
import 'package:mspeed/common/base/base_state.dart';
import 'package:mspeed/common/component/custom_dropdown.dart';
import 'package:mspeed/common/component/custom_navigator.dart';
import 'package:mspeed/src/admin/home/model/buyer_admin_model.dart';
import 'package:mspeed/src/admin/user/provider/admin_form_buyer_provider.dart';
import 'package:mspeed/src/admin/user/view/admin_form_widgets.dart';
import 'package:mspeed/utils/utils.dart';
import 'package:provider/provider.dart';

class CreateDataBuyerAdminView extends StatefulWidget {
  const CreateDataBuyerAdminView({super.key, this.buyer});
  final BuyerAdminModelData? buyer;

  @override
  State<CreateDataBuyerAdminView> createState() =>
      _CreateDataBuyerAdminViewState();
}

class _CreateDataBuyerAdminViewState
    extends BaseState<CreateDataBuyerAdminView> {
  static const _gradient = [Color(0xff3B82F6), Color(0xff1D4ED8)];
  static const _accent = Color(0xff3B82F6);

  bool get isEdit => widget.buyer != null;

  @override
  void initState() {
    getData();
    super.initState();
  }

  getData() async {
    final p = context.read<AdminFormBuyerProvider>();
    await p.setData(widget.buyer);
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
                .read<AdminFormBuyerProvider>()
                .sendBuyer(context, buyerId: widget.buyer?.ID);
          });
        },
        noCallback: () => Navigator.pop(context),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AdminFormBuyerProvider>();

    return Scaffold(
      backgroundColor: const Color(0xffF5F6FA),
      body: CustomScrollView(
        slivers: [
          // ── Gradient AppBar ──
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
                icon: Icons.shopping_bag_rounded,
                title: isEdit ? 'Edit Buyer' : 'Tambah Buyer',
                subtitle: isEdit
                    ? 'Perbarui data buyer'
                    : 'Isi data untuk menambah buyer baru',
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
              child: Column(
                children: [
                  // ── Informasi Dasar ──
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

                  // ── Organisasi ──
                  AdminFormSection(
                    title: 'Organisasi',
                    icon: Icons.business_outlined,
                    accentColor: _accent,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Subdit',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xff4A5568))),
                          const SizedBox(height: 6),
                          CustomDropdown.normalDropdown(
                            controller: p.subditC,
                            hintText: 'Pilih Subdit',
                            list: (p.subditAdminModel.data ?? [])
                                .map((e) => DropdownMenuItem(
                                      value: e?.id ?? '0',
                                      child: Text(e?.subditName ?? ''),
                                    ))
                                .toList(),
                            selectedItem: p.selectedSubdit,
                            onChanged: (value) {
                              p.selectedSubdit = value;
                              setState(() {});
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // ── Lokasi ──
                  AdminFormSection(
                    title: 'Lokasi',
                    icon: Icons.location_on_outlined,
                    accentColor: _accent,
                    children: [
                      AdminFormField(
                          controller: p.cityC,
                          label: 'Kota',
                          hint: 'Masukkan kota',
                          icon: Icons.location_city_outlined),
                      AdminFormField(
                          controller: p.alamatC,
                          label: 'Alamat Lengkap',
                          hint: 'Masukkan alamat lengkap',
                          icon: Icons.map_outlined,
                          maxLines: 3),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // ── Keamanan ──
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
