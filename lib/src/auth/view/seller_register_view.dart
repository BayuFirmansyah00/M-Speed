import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:mspeed/common/component/custom_button.dart';
import 'package:mspeed/common/component/custom_navigator.dart';
import 'package:mspeed/common/component/custom_textfield.dart';
import 'package:mspeed/common/helper/constant.dart';
import 'package:mspeed/src/auth/provider/register_provider.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class _RegisterHeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 40);
    path.quadraticBezierTo(
      size.width / 2,
      size.height,
      size.width,
      size.height - 40,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class SellerRegisterView extends StatefulWidget {
  SellerRegisterView({Key? key}) : super(key: key);

  @override
  State<SellerRegisterView> createState() => _SellerRegisterViewState();
}

class _SellerRegisterViewState extends State<SellerRegisterView> {
  void showTermsPopup() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Dialog Header ──
              Container(
                padding: const EdgeInsets.fromLTRB(20, 20, 16, 16),
                decoration: BoxDecoration(
                  color: Constant.primaryColor.withOpacity(0.07),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Constant.primaryColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.description_rounded,
                          color: Constant.primaryColor, size: 18),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Syarat dan Ketentuan',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Color(0xff100629)),
                      ),
                    ),
                    InkWell(
                      onTap: () => CusNav.nPop(context),
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(Icons.close_rounded,
                            color: Constant.grayColor, size: 20),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0xffF0F0F0)),
              // ── Dialog Content ──
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                  child: Text(
                    '''SURAT PERNYATAAN DIRI (DISCLAIMER)
SYARAT DAN KETENTUAN PENYEDIA KATALOG ELEKTRONIK (M-SPEED) PT MITRA KARYA PRIMA (M-SPEED)
I. Ketentuan Umum Syarat dan Ketentuan Penyedia Katalog Elektronik (M-Speed)
Syarat dan Ketentuan Penyedia Katalog Elektronik (M-Speed) merupakan syarat – syarat yang harus disetujui oleh Penyedia Katalog Elektronik (M-Speed) pada saat proses Pendaftaran Penyedia Katalog Elektronik (M-Speed).
II. Isi Syarat dan Ketentuan Penyedia Katalog Elektronik (M-Speed) Syarat dan ketentuan yang ditetapkan di bawah ini mengatur tentang tata cara, serta hak dan kewajiban yang menyertai Penyedia Katalog Elektronik (M-Speed) serta para pihak terkait penggunaan Katalog Elektronik (M-Speed). Penyedia Katalog Elektronik (M-Speed) wajib membaca dan memahami secara menyeluruh seluruh ketentuan termasuk konsekuensi yang timbul di bawah hukum yang berlaku. Pelaku Usaha yang menjadi Penyedia Katalog Elektronik (M-Speed) maka dianggap telah membaca, mengerti, memahami dan menyetujui semua isi dalam Syarat dan Ketentuan ini.

A. Definisi
1. PT Mitra Karya Prima adalah perusahaan yang mengembangkan dan merumuskan kebijakan Pengadaan Barang/Jasa pada Katalog Elektronik (M-Speed).
2. Katalog Elektronik (M-Speed) adalah sistem informasi elektronik yang memuat daftar, jenis, spesifikasi teknis, produk dalam negeri, harga, Penyedia, dan informasi lainnya terkait barang/jasa.

B. Umum
1. Penyedia Katalog Elektronik (M-Speed) dapat menggunakan Aplikasi untuk menjual Barang/Jasa melalui metode E-Purchasing.
2. Pengelola tidak memungut biaya pendaftaran kepada Penyedia.

C. Hak dan Kewajiban Penyedia
1. Penyedia wajib menjamin pemenuhan seluruh kriteria kualifikasi yang dipersyaratkan.
2. Bertanggung jawab atas informasi produk, spesifikasi teknis, gambar dan lampiran yang diunggah.
3. Mematuhi etika pengadaan dengan tidak menawarkan atau menerima hadiah yang berkaitan dengan pengadaan.

H. Sanksi
1. Pelanggaran pertama: surat peringatan pertama.
2. Pelanggaran kedua: surat peringatan kedua dan penghentian sementara selama 3 bulan.
3. Pelanggaran ketiga: surat peringatan ketiga dan penurunan pencantuman selama 1 tahun.

J. Pembaruan
Syarat dan Ketentuan dapat mengalami perubahan tanpa pemberitahuan sebelumnya. Dengan tetap menggunakan layanan, Penyedia dianggap menyetujui perubahan tersebut.''',
                    textAlign: TextAlign.left,
                    style: const TextStyle(
                        fontSize: 12,
                        height: 1.6,
                        color: Color(0xff4A4A5A)),
                  ),
                ),
              ),
              // ── Dialog Footer ──
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => CusNav.nPop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Constant.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: const Text('Saya Mengerti',
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600)),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<RegisterProvider>();

    Widget header() {
      return ClipPath(
        clipper: _RegisterHeaderClipper(),
        child: Container(
          height: 20.h,
          width: 100.w,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Constant.primaryColor,
                Constant.primaryColor.withOpacity(0.8),
              ],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: -30,
                right: -30,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.07),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                top: 20,
                left: -20,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    Widget logoBadge() {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Image.asset(
          'assets/icons/ic-mspeed-rectangle2.png',
          scale: 6,
        ),
      );
    }

    Widget sectionLabel(String text) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12, top: 4),
        child: Row(
          children: [
            Container(
              width: 3,
              height: 14,
              decoration: BoxDecoration(
                color: Constant.primaryColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 8),
            Text(text,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Constant.primaryColor)),
          ],
        ),
      );
    }

    Widget form() {
      return Form(
        key: p.registerKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Title ──
            const Text(
              'Daftar Sebagai Vendor',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xff100629),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Lengkapi data berikut untuk bergabung dengan M-Speed',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 13,
                  color: Constant.grayColor,
                  fontWeight: FontWeight.normal),
            ),
            const SizedBox(height: 28),

            // ── Informasi Perusahaan ──
            sectionLabel('Informasi Perusahaan'),
            CustomTextField.borderTextField(
              controller: p.companyNameC,
              fillColor: const Color(0xffF5F6FA),
              hintColor: Constant.grayColor,
              hintText: 'Nama perusahaan / toko',
              labelText: 'Nama Perusahaan / Toko',
              labelFontSize: 13,
              labelFontWeight: FontWeight.w600,
              labelColor: Colors.black,
              borderColor: const Color(0xffE2E4E9),
              required: true,
              borderRadius: BorderRadius.circular(14),
              prefix: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Icon(Icons.business_rounded,
                    color: Constant.grayColor, size: 20),
              ),
            ),
            const SizedBox(height: 14),
            CustomTextField.borderTextField(
              controller: p.ownerNameC,
              fillColor: const Color(0xffF5F6FA),
              hintColor: Constant.grayColor,
              hintText: 'Nama pemilik / direktur',
              labelText: 'Nama Pemilik / Direktur',
              labelFontSize: 13,
              labelFontWeight: FontWeight.w600,
              labelColor: Colors.black,
              borderColor: const Color(0xffE2E4E9),
              required: true,
              borderRadius: BorderRadius.circular(14),
              prefix: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Icon(Icons.person_rounded,
                    color: Constant.grayColor, size: 20),
              ),
            ),
            const SizedBox(height: 14),
            CustomTextField.borderTextField(
              controller: p.roleC,
              fillColor: const Color(0xffF5F6FA),
              hintColor: Constant.grayColor,
              hintText: 'Jabatan di perusahaan',
              labelText: 'Jabatan',
              labelFontSize: 13,
              labelFontWeight: FontWeight.w600,
              labelColor: Colors.black,
              borderColor: const Color(0xffE2E4E9),
              required: true,
              borderRadius: BorderRadius.circular(14),
              prefix: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Icon(Icons.badge_rounded,
                    color: Constant.grayColor, size: 20),
              ),
            ),
            const SizedBox(height: 14),
            CustomTextField.borderTextArea(
              controller: p.addressC,
              labelText: 'Alamat Lengkap',
              required: true,
            ),
            const SizedBox(height: 22),

            // ── Akun ──
            sectionLabel('Informasi Akun'),
            CustomTextField.borderTextField(
              controller: p.emailC,
              fillColor: const Color(0xffF5F6FA),
              hintColor: Constant.grayColor,
              hintText: 'Masukkan email kamu',
              labelText: 'Email',
              labelFontSize: 13,
              labelFontWeight: FontWeight.w600,
              labelColor: Colors.black,
              borderColor: const Color(0xffE2E4E9),
              required: true,
              borderRadius: BorderRadius.circular(14),
              prefix: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Icon(Icons.mail_outline_rounded,
                    color: Constant.grayColor, size: 20),
              ),
            ),
            const SizedBox(height: 14),
            CustomTextField.borderTextField(
              controller: p.passwordC,
              fillColor: const Color(0xffF5F6FA),
              hintColor: Constant.grayColor,
              hintText: 'Buat password kamu',
              labelText: 'Password',
              labelFontSize: 13,
              labelFontWeight: FontWeight.w600,
              labelColor: Colors.black,
              borderColor: const Color(0xffE2E4E9),
              required: true,
              obscureText: true,
              borderRadius: BorderRadius.circular(14),
              prefix: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Icon(Icons.lock_outline_rounded,
                    color: Constant.grayColor, size: 20),
              ),
            ),
            const SizedBox(height: 14),
            CustomTextField.borderTextField(
              controller: p.confirmPasswordC,
              fillColor: const Color(0xffF5F6FA),
              hintColor: Constant.grayColor,
              hintText: 'Ulangi password kamu',
              labelText: 'Konfirmasi Password',
              labelFontSize: 13,
              labelFontWeight: FontWeight.w600,
              labelColor: Colors.black,
              borderColor: const Color(0xffE2E4E9),
              required: true,
              obscureText: true,
              borderRadius: BorderRadius.circular(14),
              prefix: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Icon(Icons.lock_reset_rounded,
                    color: Constant.grayColor, size: 20),
              ),
            ),
            const SizedBox(height: 20),

            // ── Terms checkbox ──
            GestureDetector(
              onTap: () => setState(() => p.acc = !p.acc),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: p.acc
                      ? Constant.primaryColor.withOpacity(0.06)
                      : const Color(0xffF5F6FA),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: p.acc
                        ? Constant.primaryColor.withOpacity(0.3)
                        : const Color(0xffE2E4E9),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: p.acc ? Constant.primaryColor : Colors.white,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: p.acc
                              ? Constant.primaryColor
                              : const Color(0xffCDD0D5),
                          width: 1.5,
                        ),
                      ),
                      child: p.acc
                          ? const Icon(Icons.check_rounded,
                              color: Colors.white, size: 14)
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(
                              fontSize: 13, color: Color(0xff4A4A5A)),
                          children: [
                            const TextSpan(
                                text: 'Saya menyetujui semua '),
                            TextSpan(
                              text: 'Syarat dan Ketentuan',
                              style: TextStyle(
                                color: Constant.primaryColor,
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.underline,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = showTermsPopup,
                            ),
                            const TextSpan(
                                text: ' yang berlaku di M-Speed.'),
                          ],
                        ),
                        maxLines: null,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ── Daftar Button ──
            CustomButton.mainButton(
              'Daftar Sekarang',
              () async {
                await context.read<RegisterProvider>().register(context);
              },
              color: p.acc ? Constant.primaryColor : Constant.grayColor,
              textStyle: const TextStyle(
                  fontSize: 15,
                  color: Colors.white,
                  fontWeight: FontWeight.w600),
              contentPadding: const EdgeInsets.symmetric(vertical: 15),
              borderRadius: BorderRadius.circular(14),
              margin: EdgeInsets.zero,
            ),
            const SizedBox(height: 16),

            // ── Back to Login ──
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Sudah punya akun? ',
                    style: TextStyle(
                        fontSize: 13, color: Constant.grayColor)),
                GestureDetector(
                  onTap: () => CusNav.nPop(context),
                  child: Text(
                    'Masuk di sini',
                    style: TextStyle(
                        fontSize: 13,
                        color: Constant.primaryColor,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Stack(
              alignment: Alignment.bottomCenter,
              clipBehavior: Clip.none,
              children: [
                header(),
                Positioned(
                  bottom: -32,
                  child: logoBadge(),
                ),
              ],
            ),
            const SizedBox(height: 52),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
              child: form(),
            ),
          ],
        ),
      ),
    );
  }
}
