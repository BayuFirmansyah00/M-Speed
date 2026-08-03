import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mspeed/common/base/base_state.dart';
import 'package:mspeed/common/component/custom_navigator.dart';
import 'package:mspeed/src/admin/master/model/banner_admin_model.dart';
import 'package:mspeed/src/admin/master/provider/admin_banner_provider.dart';
import 'package:mspeed/src/admin/user/view/admin_form_widgets.dart';
import 'package:mspeed/utils/utils.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

class FormBannerAdminView extends StatefulWidget {
  final BannerAdminModelData? banner;
  const FormBannerAdminView({super.key, this.banner});

  @override
  State<FormBannerAdminView> createState() => _FormBannerAdminViewState();
}

class _FormBannerAdminViewState extends BaseState<FormBannerAdminView> {
  static const _gradient = [Color(0xff8B5CF6), Color(0xff6D28D9)];
  static const _accent = Color(0xff8B5CF6);

  bool get isEdit => widget.banner != null;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminBannerProvider>().setData(widget.banner);
    });
  }

  Future<void> _save() async {
    await handleTap(() async {
      Utils.showYesNoDialog(
        context: context,
        title: 'Konfirmasi Simpan',
        desc: 'Pastikan data banner sudah benar.',
        yesCallback: () async {
          CusNav.nPop(context);
          await context.read<AdminBannerProvider>().saveBanner(
            context,
            id: widget.banner?.id,
          );
        },
        noCallback: () => Navigator.pop(context),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AdminBannerProvider>();

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
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: AdminFormHeader(
                gradient: _gradient,
                icon: Icons.view_carousel_rounded,
                title: isEdit ? 'Edit Banner' : 'Tambah Banner',
                subtitle: isEdit
                    ? 'Perbarui data banner'
                    : 'Isi data untuk menambah banner baru',
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
              child: Column(
                children: [
                  // ── Gambar Banner ──
                  AdminFormSection(
                    title: 'Gambar Banner',
                    icon: Icons.image_outlined,
                    accentColor: _accent,
                    children: [
                      const Text(
                        'Unggah gambar banner (Maks 2MB, JPG/PNG/WEBP)',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color(0xff4A5568),
                        ),
                      ),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: () => p.pickImage(),
                        child: Container(
                          width: double.infinity,
                          height: 180,
                          decoration: BoxDecoration(
                            color: const Color(0xffF8FAFC),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xffCBD5E1),
                              width: 2,
                              style: BorderStyle.solid,
                            ),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Stack(
                            children: [
                              if (p.selectedImage != null)
                                Positioned.fill(
                                  child: Image.file(
                                    p.selectedImage!,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              else if (p.existingImageUrl != null)
                                Positioned.fill(
                                  child: p.existingImageUrl!.startsWith('http')
                                      ? CachedNetworkImage(
                                          imageUrl: p.existingImageUrl!,
                                          fit: BoxFit.cover,
                                        )
                                      : Image.file(
                                          File(p.existingImageUrl!),
                                          fit: BoxFit.cover,
                                        ),
                                )
                              else
                                const Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.add_photo_alternate_rounded, size: 40, color: Color(0xff94A3B8)),
                                      SizedBox(height: 8),
                                      Text(
                                        'Ketuk untuk memilih gambar',
                                        style: TextStyle(fontSize: 12, color: Color(0xff64748B)),
                                      ),
                                    ],
                                  ),
                                ),
                              if (p.selectedImage != null || p.existingImageUrl != null)
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: GestureDetector(
                                    onTap: () => p.removeImage(),
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.close_rounded, size: 18, color: Colors.red),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // ── Informasi Banner ──
                  AdminFormSection(
                    title: 'Informasi Banner',
                    icon: Icons.info_outline_rounded,
                    accentColor: _accent,
                    children: [
                      AdminFormField(
                        controller: p.judulC,
                        label: 'Judul Banner',
                        hint: 'Masukkan judul banner',
                        icon: Icons.title_rounded,
                      ),
                      AdminFormField(
                        controller: p.deskripsiC,
                        label: 'Deskripsi Banner',
                        hint: 'Masukkan deskripsi banner',
                        icon: Icons.description_outlined,
                        maxLines: 4,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: AdminSaveBar(
        accentColor: _accent,
        gradient: _gradient,
        onSave: _save,
      ),
    );
  }
}
