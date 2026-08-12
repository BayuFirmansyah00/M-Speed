import 'package:flutter/material.dart';
import 'package:mspeed/common/base/base_state.dart';
import 'package:mspeed/common/component/custom_navigator.dart';
import 'package:mspeed/src/admin/user/provider/admin_form_subdirektorat_provider.dart';
import 'package:mspeed/src/admin/user/view/admin_form_widgets.dart';
import 'package:mspeed/utils/utils.dart';
import 'package:provider/provider.dart';

class CreateDataSubDirektoratAdminView extends StatefulWidget {
  const CreateDataSubDirektoratAdminView({super.key, this.subdit});
  final dynamic subdit;

  @override
  State<CreateDataSubDirektoratAdminView> createState() =>
      _CreateDataSubDirektoratAdminViewState();
}

class _CreateDataSubDirektoratAdminViewState
    extends BaseState<CreateDataSubDirektoratAdminView> {
  static const _gradient = [Color(0xff8B5CF6), Color(0xff6D28D9)];
  static const _accent = Color(0xff14B8A6);

  bool get isEdit => widget.subdit != null;

  @override
  void initState() {
    getData();
    super.initState();
  }

  getData() async {
    final p = context.read<AdminFormSubDirektoratProvider>();
    await p.setData(widget.subdit);
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
                .read<AdminFormSubDirektoratProvider>()
                .sendSubDirektorat(context, subditId: widget.subdit?['id']?.toString());
          });
        },
        noCallback: () => Navigator.pop(context),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AdminFormSubDirektoratProvider>();

    return Scaffold(
      backgroundColor: const Color(0xffF5F6FA),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 140,
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
                icon: Icons.account_tree_rounded,
                title: isEdit ? 'Edit Sub-Direktorat' : 'Tambah Sub-Direktorat',
                subtitle: isEdit
                    ? 'Perbarui data sub-direktorat'
                    : 'Isi data untuk menambah sub-direktorat baru',
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
                    icon: Icons.info_outline_rounded,
                    accentColor: _accent,
                    children: [
                      AdminFormField(
                          controller: p.subditCodeC,
                          label: 'Kode Sub-Direktorat',
                          hint: 'Masukkan kode unik (contoh: SUB01)',
                          icon: Icons.qr_code_2_outlined),
                      AdminFormField(
                          controller: p.subditNameC,
                          label: 'Nama Sub-Direktorat',
                          hint: 'Masukkan nama sub-direktorat',
                          icon: Icons.badge_outlined),
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
