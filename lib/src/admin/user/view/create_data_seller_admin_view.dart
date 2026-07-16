import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:mspeed/src/admin/home/model/seller_admin_model.dart';
import 'package:mspeed/src/admin/user/provider/admin_form_seller_provider.dart';
import 'package:mspeed/src/admin/user/view/admin_form_widgets.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:mspeed/utils/utils.dart';
import 'package:mspeed/common/component/custom_navigator.dart';

class CreateDataSellerAdminView extends StatefulWidget {
  const CreateDataSellerAdminView({super.key, this.seller});
  final SellerAdminModelData? seller;

  @override
  State<CreateDataSellerAdminView> createState() => _CreateDataSellerAdminViewState();
}

class _CreateDataSellerAdminViewState extends State<CreateDataSellerAdminView> {
  static const _gradient = [Color(0xff10B981), Color(0xff059669)];
  static const _accent = Color(0xff10B981);

  bool get isEdit => widget.seller != null;

  @override
  void initState() {
    super.initState();
    // Pre-fill if editing
    final p = context.read<AdminFormSellerProvider>();
    p.setData(widget.seller);
  }

  Future<void> _save() async {
    Utils.showYesNoDialog(
      context: context,
      title: 'Konfirmasi Simpan',
      desc: 'Pastikan data sudah benar sebelum disimpan.',
      yesCallback: () async {
        CusNav.nPop(context);
        await context.read<AdminFormSellerProvider>().sendSeller(
              context,
              withLoading: true,
              sellerId: widget.seller?.ID,
            );
      },
      noCallback: () => Navigator.pop(context),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AdminFormSellerProvider>();

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
                icon: Icons.storefront_rounded,
                title: isEdit ? 'Edit Seller' : 'Tambah Seller',
                subtitle: isEdit ? 'Perbarui data vendor / seller' : 'Isi data untuk mendaftarkan seller baru',
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
              child: Column(
                children: [
                  // ── Informasi Toko ──
                  AdminFormSection(
                    title: 'Informasi Toko',
                    icon: Icons.storefront_outlined,
                    accentColor: _accent,
                    children: [
                      AdminFormField(controller: p.companyNameC, label: 'Nama Toko / Perusahaan', hint: 'Nama toko atau perusahaan', icon: Icons.business_outlined),
                      AdminFormField(controller: p.emailC, label: 'Email', hint: 'Email toko', icon: Icons.email_outlined, inputType: TextInputType.emailAddress, enabled: !isEdit),
                      AdminFormField(controller: p.kbliC, label: 'KBLI', hint: 'Kode KBLI', icon: Icons.numbers_rounded),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // ── Pemilik & Kontak ──
                  AdminFormSection(
                    title: 'Pemilik & Kontak',
                    icon: Icons.person_outline_rounded,
                    accentColor: _accent,
                    children: [
                      AdminFormField(controller: p.ownerNameC, label: 'Nama Pemilik', hint: 'Nama pemilik toko', icon: Icons.person_rounded),
                      AdminFormField(controller: p.cpNameC, label: 'Nama Contact Person', hint: 'Nama contact person', icon: Icons.contact_phone_outlined),
                      AdminFormField(controller: p.cpPhoneNumberC, label: 'Telepon Contact Person', hint: 'No. telepon CP', icon: Icons.phone_callback_outlined, inputType: TextInputType.phone),
                      AdminFormField(controller: p.phoneNumberC, label: 'No. Telepon Toko', hint: 'No. telepon toko', icon: Icons.phone_outlined, inputType: TextInputType.phone),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // ── Lokasi ──
                  AdminFormSection(
                    title: 'Lokasi',
                    icon: Icons.location_on_outlined,
                    accentColor: _accent,
                    children: [
                      AdminFormField(controller: p.cityC, label: 'Kota', hint: 'Masukkan kota', icon: Icons.location_city_outlined),
                      AdminFormField(controller: p.alamatC, label: 'Alamat Perusahaan', hint: 'Masukkan alamat lengkap', icon: Icons.map_outlined, maxLines: 3),

                    ],
                  ),
                  const SizedBox(height: 14),

                  // ── Dokumen Hukum ──
                  AdminFormSection(
                    title: 'Dokumen & Legalitas',
                    icon: Icons.description_outlined,
                    accentColor: _accent,
                    children: [
                      AdminFormField(controller: p.npwpC, label: 'No. NPWP', hint: 'Nomor NPWP perusahaan', icon: Icons.receipt_long_outlined),
                      AdminFormField(controller: p.ktpC, label: 'No. KTP / Identitas', hint: 'Nomor KTP pemilik', icon: Icons.credit_card_outlined),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // ── Rekening ──
                  AdminFormSection(
                    title: 'Rekening Bank',
                    icon: Icons.account_balance_outlined,
                    accentColor: _accent,
                    children: [
                      _BankRow(bankNameC: p.bankNameC, bankNumberC: p.bankNumberC),
                      AdminFormField(controller: p.bankAccountC, label: 'Rekening Atas Nama', hint: 'Nama pemilik rekening', icon: Icons.person_outline_rounded),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // ── Upload Dokumen ──
                  AdminFormSection(
                    title: 'Upload Dokumen',
                    icon: Icons.upload_file_outlined,
                    accentColor: _accent,
                    children: [
                      _FileButton(title: 'File NPWP', accent: _accent, onChoose: (_) {}, gradient: _gradient),
                      _FileButton(title: 'File No. KTP / Identitas', accent: _accent, onChoose: (_) {}, gradient: _gradient),
                      _FileButton(title: 'File Buku Rekening', accent: _accent, onChoose: (_) {}, gradient: _gradient),
                      _FileButton(title: 'File SP SKP', accent: _accent, onChoose: (_) {}, gradient: _gradient),
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


// ── Bank Row ──────────────────────────────────────────────────────────────────
class _BankRow extends StatelessWidget {
  final TextEditingController bankNameC, bankNumberC;
  const _BankRow({required this.bankNameC, required this.bankNumberC});

  @override
  Widget build(BuildContext context) {
    InputDecoration _dec(String hint) => InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 12, color: Color(0xffA0AEC0)),
      filled: true,
      fillColor: const Color(0xffF8F9FC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xffE2E4E9))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xffE2E4E9))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xff10B981), width: 1.5)),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Bank & No. Rekening', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xff4A5568))),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(flex: 1, child: TextFormField(controller: bankNameC, style: const TextStyle(fontSize: 13), decoration: _dec('Nama Bank'))),
            const SizedBox(width: 10),
            Expanded(flex: 2, child: TextFormField(controller: bankNumberC, style: const TextStyle(fontSize: 13), decoration: _dec('No. Rekening'))),
          ],
        ),
      ],
    );
  }
}

// ── File Button ───────────────────────────────────────────────────────────────
class _FileButton extends StatefulWidget {
  final String title;
  final Color accent;
  final List<Color> gradient;
  final Function(XFile) onChoose;
  const _FileButton({required this.title, required this.accent, required this.gradient, required this.onChoose});

  @override
  State<_FileButton> createState() => _FileButtonState();
}

class _FileButtonState extends State<_FileButton> {
  String? _fileName;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final result = await FilePicker.pickFiles(allowMultiple: false);
        if (result != null) {
          final file = result.files.singleOrNull;
          if (file != null) {
            setState(() => _fileName = file.name);
            widget.onChoose(file.xFile);
          }
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: _fileName != null ? widget.accent.withOpacity(0.06) : const Color(0xffF8F9FC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _fileName != null ? widget.accent.withOpacity(0.3) : const Color(0xffE2E4E9),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: widget.accent.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _fileName != null ? Icons.check_circle_outline_rounded : Icons.upload_file_outlined,
                color: widget.accent, size: 16,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xff4A5568))),
                  if (_fileName != null) ...[
                    const SizedBox(height: 2),
                    Text(_fileName!, style: TextStyle(fontSize: 11, color: widget.accent), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ] else
                    const Text('Tap untuk memilih file', style: TextStyle(fontSize: 11, color: Color(0xffA0AEC0))),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: const Color(0xffA0AEC0), size: 18),
          ],
        ),
      ),
    );
  }
}
