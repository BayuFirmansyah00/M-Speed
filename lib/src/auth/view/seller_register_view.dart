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
    path.lineTo(0, size.height - 30);
    path.quadraticBezierTo(
      size.width / 2,
      size.height,
      size.width,
      size.height - 30,
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
                  color: Constant.secondaryColor.withOpacity(0.07),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Constant.secondaryColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.description_rounded,
                          color: Constant.secondaryColor, size: 18),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Syarat dan Ketentuan',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
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
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFF15A24),
                          Color(0xFFFF8C00),
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ElevatedButton(
                      onPressed: () => CusNav.nPop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: const Text('Saya Mengerti',
                          style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w800)),
                    ),
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
        child: Container(
          height: 15.h,
          width: 100.w,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF051C3F),
                Constant.secondaryColor,
                Color(0xFF1E5C99),
              ],
            ),
          ),
          child: Stack(
            children: [
              // Efek Cahaya Oranye
              Positioned(
                top: -60,
                left: -60,
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Color(0xFFF15A24).withOpacity(0.25),
                        Color(0xFFF15A24).withOpacity(0.0),
                      ],
                    ),
                  ),
                ),
              ),
              // Efek Cahaya Kuning Emas
              Positioned(
                top: -30,
                right: -30,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Color(0xFFF7931E).withOpacity(0.2),
                        Color(0xFFF7931E).withOpacity(0.0),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        clipper: _RegisterHeaderClipper(),
      );
    }

    Widget logoBadge() {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(
            color: Colors.white,
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: Color(0xFF0B4177).withOpacity(0.14),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Logo MKP (Diperbesar)
            Image.asset(
              'assets/icons/ic-mspeed-rectangle2.png',
              height: 34,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 16),
            // Garis Pembatas (Diperbesar)
            Container(
              width: 1.5,
              height: 26,
              color: Colors.grey.shade300,
            ),
            const SizedBox(width: 16),
            // Logo M-Speed (Diperbesar)
            Image.asset(
              'assets/images/ic-mspeed.png',
              height: 34,
              fit: BoxFit.contain,
            ),
          ],
        ),
      );
    }

    Widget sectionLabel(String text) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12, top: 4),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 16,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF0B4177),
                    Color(0xFFF15A24),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 8),
            Text(text,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Constant.secondaryColor)),
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
            Text(
              'Daftar Sebagai Vendor',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Constant.secondaryColor,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Lengkapi data berikut untuk bergabung dengan M-Speed',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 12,
                  color: Constant.grayColor,
                  height: 1.4),
            ),
            const SizedBox(height: 24),

            // ── Informasi Perusahaan ──
            sectionLabel('Informasi Perusahaan'),
            CustomTextField.borderTextField(
              controller: p.companyNameC,
              fillColor: const Color(0xffF8FAFC),
              hintColor: Constant.grayColor.withOpacity(0.8),
              hintText: 'Nama perusahaan / toko',
              labelText: 'Nama Perusahaan / Toko',
              labelFontSize: 12,
              labelFontWeight: FontWeight.w700,
              labelColor: Colors.black87,
              borderColor: const Color(0xffE2E8F0),
              activeBorderColor: Constant.secondaryColor,
              required: true,
              borderRadius: BorderRadius.circular(14),
              prefix: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Icon(Icons.business_rounded,
                    color: Constant.secondaryColor.withOpacity(0.85), size: 20),
              ),
            ),
            const SizedBox(height: 14),
            CustomTextField.borderTextField(
              controller: p.ownerNameC,
              fillColor: const Color(0xffF8FAFC),
              hintColor: Constant.grayColor.withOpacity(0.8),
              hintText: 'Nama pemilik / direktur',
              labelText: 'Nama Pemilik / Direktur',
              labelFontSize: 12,
              labelFontWeight: FontWeight.w700,
              labelColor: Colors.black87,
              borderColor: const Color(0xffE2E8F0),
              activeBorderColor: Constant.secondaryColor,
              required: true,
              borderRadius: BorderRadius.circular(14),
              prefix: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Icon(Icons.person_rounded,
                    color: Constant.secondaryColor.withOpacity(0.85), size: 20),
              ),
            ),
            const SizedBox(height: 14),
            CustomTextField.borderTextField(
              controller: p.roleC,
              fillColor: const Color(0xffF8FAFC),
              hintColor: Constant.grayColor.withOpacity(0.8),
              hintText: 'Jabatan di perusahaan',
              labelText: 'Jabatan',
              labelFontSize: 12,
              labelFontWeight: FontWeight.w700,
              labelColor: Colors.black87,
              borderColor: const Color(0xffE2E8F0),
              activeBorderColor: Constant.secondaryColor,
              required: true,
              borderRadius: BorderRadius.circular(14),
              prefix: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Icon(Icons.badge_rounded,
                    color: Constant.secondaryColor.withOpacity(0.85), size: 20),
              ),
            ),
            const SizedBox(height: 14),
            CustomTextField.borderTextArea(
              controller: p.addressC,
              labelText: 'Alamat Lengkap',
              required: true,
            ),
            const SizedBox(height: 20),

            // ── Akun ──
            sectionLabel('Informasi Akun'),
            CustomTextField.borderTextField(
              controller: p.emailC,
              fillColor: const Color(0xffF8FAFC),
              hintColor: Constant.grayColor.withOpacity(0.8),
              hintText: 'Masukkan email kamu',
              labelText: 'Email',
              labelFontSize: 12,
              labelFontWeight: FontWeight.w700,
              labelColor: Colors.black87,
              borderColor: const Color(0xffE2E8F0),
              activeBorderColor: Constant.secondaryColor,
              required: true,
              borderRadius: BorderRadius.circular(14),
              prefix: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Icon(Icons.mail_outline_rounded,
                    color: Constant.secondaryColor.withOpacity(0.85), size: 20),
              ),
            ),
            const SizedBox(height: 14),
            CustomTextField.borderTextField(
              controller: p.passwordC,
              fillColor: const Color(0xffF8FAFC),
              hintColor: Constant.grayColor.withOpacity(0.8),
              hintText: 'Buat password kamu',
              labelText: 'Password',
              labelFontSize: 12,
              labelFontWeight: FontWeight.w700,
              labelColor: Colors.black87,
              borderColor: const Color(0xffE2E8F0),
              activeBorderColor: Constant.secondaryColor,
              required: true,
              obscureText: true,
              borderRadius: BorderRadius.circular(14),
              prefix: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Icon(Icons.lock_outline_rounded,
                    color: Constant.secondaryColor.withOpacity(0.85), size: 20),
              ),
            ),
            const SizedBox(height: 14),
            CustomTextField.borderTextField(
              controller: p.confirmPasswordC,
              fillColor: const Color(0xffF8FAFC),
              hintColor: Constant.grayColor.withOpacity(0.8),
              hintText: 'Ulangi password kamu',
              labelText: 'Konfirmasi Password',
              labelFontSize: 12,
              labelFontWeight: FontWeight.w700,
              labelColor: Colors.black87,
              borderColor: const Color(0xffE2E8F0),
              activeBorderColor: Constant.secondaryColor,
              required: true,
              obscureText: true,
              borderRadius: BorderRadius.circular(14),
              prefix: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Icon(Icons.lock_reset_rounded,
                    color: Constant.secondaryColor.withOpacity(0.85), size: 20),
              ),
            ),
            const SizedBox(height: 20),

            // ── Terms checkbox ──
            GestureDetector(
              onTap: () => setState(() => p.acc = !p.acc),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: p.acc
                      ? const Color(0xFFF15A24).withOpacity(0.06)
                      : const Color(0xffF8FAFC),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: p.acc
                        ? const Color(0xFFF15A24).withOpacity(0.3)
                        : const Color(0xffE2E8F0),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: p.acc ? const Color(0xFFF15A24) : Colors.white,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: p.acc
                              ? const Color(0xFFF15A24)
                              : const Color(0xffCDD0D5),
                          width: 1.5,
                        ),
                      ),
                      child: p.acc
                          ? const Icon(Icons.check_rounded,
                              color: Colors.white, size: 12)
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(
                              fontSize: 12, color: Color(0xff4A4A5A), height: 1.4),
                          children: [
                            const TextSpan(
                                text: 'Saya menyetujui semua '),
                            TextSpan(
                              text: 'Syarat dan Ketentuan',
                              style: const TextStyle(
                                color: Color(0xFFF15A24),
                                fontWeight: FontWeight.w700,
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

            // ── Daftar Button (Premium Gradient) ──
            Container(
              height: 50,
              decoration: BoxDecoration(
                gradient: p.acc
                    ? const LinearGradient(
                        colors: [
                          Color(0xFFF15A24),
                          Color(0xFFFF8C00),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: p.acc ? null : Constant.grayColor.withOpacity(0.5),
                borderRadius: BorderRadius.circular(14),
                boxShadow: p.acc
                    ? [
                        BoxShadow(
                          color: const Color(0xFFF15A24).withOpacity(0.3),
                          blurRadius: 14,
                          offset: const Offset(0, 5),
                        ),
                      ]
                    : null,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: p.acc
                      ? () async {
                          await context.read<RegisterProvider>().register(context);
                        }
                      : null,
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    alignment: Alignment.center,
                    child: const Text(
                      'Daftar Sekarang',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ── Back to Login ──
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Sudah punya akun? ',
                    style: TextStyle(
                        fontSize: 12, color: Constant.grayColor, fontWeight: FontWeight.w500)),
                GestureDetector(
                  onTap: () => CusNav.nPop(context),
                  child: const Text(
                    'Masuk di sini',
                    style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFFF15A24),
                        fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFE),
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
                  bottom: -24,
                  child: logoBadge(),
                ),
              ],
            ),
            const SizedBox(height: 38),
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
