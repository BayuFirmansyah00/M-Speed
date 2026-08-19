import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../common/component/custom_navigator.dart';
import '../../../common/helper/app_colors.dart';
import '../../admin/user/view/admin_form_widgets.dart';
import '../provider/register_provider.dart';

class SellerRegisterView extends StatefulWidget {
  const SellerRegisterView({Key? key}) : super(key: key);

  @override
  State<SellerRegisterView> createState() => _SellerRegisterViewState();
}

class _SellerRegisterViewState extends State<SellerRegisterView> {
  @override
  Widget build(BuildContext context) {
    final p = context.watch<RegisterProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Daftar Vendor',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.black87),
          onPressed: () {
            CusNav.nPop(context);
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: p.formKeyAccount,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Informasi Dasar Vendor',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Mohon isi data dasar berikut untuk mendaftarkan akun vendor Anda.',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 24),
                    AdminFormField(
                      controller: p.emailC,
                      label: 'Email Aktif *',
                      hint: 'Email',
                      icon: Icons.email_outlined,
                      inputType: TextInputType.emailAddress,
                      validator: (v) => v!.isEmpty ? 'Email harus diisi' : null,
                    ),
                    const SizedBox(height: 16),
                    AdminFormField(
                      controller: p.passwordC,
                      label: 'Password *',
                      hint: 'Buat Password',
                      icon: Icons.lock_outline,
                      obscure: true,
                      validator: (v) =>
                          v!.isEmpty ? 'Password harus diisi' : null,
                    ),
                    const SizedBox(height: 16),
                    AdminFormField(
                      controller: p.confirmPasswordC,
                      label: 'Konfirmasi Password *',
                      hint: 'Ulangi Password',
                      icon: Icons.lock_reset,
                      obscure: true,
                      validator: (v) =>
                          v!.isEmpty ? 'Konfirmasi Password harus diisi' : null,
                    ),
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 16),
                    AdminFormField(
                      controller: p.companyNameC,
                      label: 'Nama Toko / Perusahaan *',
                      hint: 'Nama Toko',
                      icon: Icons.business,
                      validator: (v) =>
                          v!.isEmpty ? 'Nama Toko wajib diisi' : null,
                    ),
                    const SizedBox(height: 16),
                    AdminFormField(
                      controller: p.ownerNameC,
                      label: 'Nama Pemilik / Direktur *',
                      hint: 'Nama Pemilik',
                      icon: Icons.person,
                      validator: (v) =>
                          v!.isEmpty ? 'Nama Pemilik wajib diisi' : null,
                    ),
                    const SizedBox(height: 16),
                    AdminFormField(
                      controller: p.addressC,
                      label: 'Alamat Detail *',
                      hint: 'Alamat',
                      icon: Icons.map,
                      maxLines: 3,
                      validator: (v) =>
                          v!.isEmpty ? 'Alamat wajib diisi' : null,
                    ),
                    const SizedBox(height: 24),
                    // Syarat & Ketentuan Checkbox
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: Checkbox(
                            value: p.acc,
                            onChanged: (v) {
                              setState(() {
                                p.acc = v ?? false;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              text: 'Saya menyetujui ',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black87,
                              ),
                              children: [
                                TextSpan(
                                  text: 'Syarat dan Ketentuan',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const TextSpan(text: ' yang berlaku.'),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),

          // Bottom Buttons
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () async {
                await p.submitRegistration(context);
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Submit Registrasi',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
