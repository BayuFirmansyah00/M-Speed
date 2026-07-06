import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:mspeed/common/component/custom_appbar.dart';
import 'package:mspeed/common/component/custom_button.dart';
import 'package:mspeed/common/component/custom_navigator.dart';
import 'package:mspeed/common/component/custom_textfield.dart';
import 'package:mspeed/common/helper/constant.dart';
import 'package:mspeed/src/auth/provider/register_provider.dart';
import 'package:provider/provider.dart';

class SellerRegisterView extends StatefulWidget {
  SellerRegisterView({Key? key}) : super(key: key);

  @override
  State<SellerRegisterView> createState() => _SellerRegisterViewState();
}

class _SellerRegisterViewState extends State<SellerRegisterView> {
  void showTermsPopup() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  "Syarat dan Ketentuan",
                  style: TextStyle(fontSize: 14),
                ),
              ),
              InkWell(
                onTap: () => CusNav.nPop(context),
                child: Padding(
                  padding: EdgeInsets.only(left: 16),
                  child: Icon(Icons.close),
                ),
              )
            ],
          ),
          content: SingleChildScrollView(
            child: Text(
              '''SURAT PERNYATAAN DIRI (DISCLAIMER)
SYARAT DAN KETENTUAN PENYEDIA KATALOG ELEKTRONIK (M-SPEED) PT MITRA KARYA PRIMA (M-SPEED)
I. Ketentuan Umum Syarat dan Ketentuan Penyedia Katalog Elektronik (M-Speed)
Syarat dan Ketentuan Penyedia Katalog Elektronik (M-Speed) merupakan syarat – syarat yang harus disetujui oleh Penyedia Katalog Elektronik (M-Speed) pada saat proses Pendaftaran Penyedia Katalog Elektronik (M-Speed).
II. Isi Syarat dan Ketentuan Penyedia Katalog Elektronik (M-Speed) Syarat dan ketentuan yang ditetapkan di bawah ini mengatur tentang tata cara, serta hak dan kewajiban yang menyertai Penyedia Katalog Elektronik (M-Speed) serta para pihak terkait penggunaan Katalog Elektronik (M-Speed). Penyedia Katalog Elektronik (M-Speed) wajib membaca dan memahami secara menyeluruh seluruh ketentuan termasuk konsekuensi yang timbul di bawah hukum yang berlaku. Pelaku Usaha yang menjadi Penyedia Katalog Elektronik (M-Speed) maka dianggap telah membaca, mengerti, memahami dan menyetujui semua isi dalam Syarat dan Ketentuan ini.
 
A. Definisi Istilah-istilah yang digunakan harus mempunyai arti atau tafsiran seperti yang dimaksudkan sebagai berikut:
1. PT Mitra Karya Prima adalah perusahaan yang mengembangkan dan merumuskan kebijakan Pengadaan Barang/Jasa pada Katalog Elektronik (M-Speed).
2. Katalog Elektronik (M-Speed) adalah sistem informasi elektronik yang memuat daftar, jenis, spesifikasi teknis, produk dalam negeri, harga, Penyedia, dan informasi lainnya terkait barang/jasa.
3. Etalase Produk adalah pengelompokan dari kumpulan kategori, dan/atau produk dari Barang/Jasa yang tercantum pada Aplikasi Katalog Elektronik (M-Speed).
4. Pengelola Katalog Elektronik (M-Speed) adalah pihak yang mengelola dan menyelenggarakan layanan Katalog Elektronik (M-Speed) berdasarkan Etalase Produk yang tercantum pada Katalog Elektronik (M-Speed). Pengelola Katalog Elektronik (M-Speed) Nasional adalah bagian Pengadaan PT Mitra Karya Prima.
5. Penyedia Katalog Elektronik (M-Speed) adalah Pelaku Usaha yang menyediakan barang/jasa melalui Katalog Elektronik (M-Speed).
6. Pembelian secara Elektronik yang selanjutnya disebut E-Purchasing adalah tata cara pembelian barang/jasa melalui sistem Katalog Elektronik (M-Speed) atau toko daring.
7. Hari adalah hari kalender, kecuali disebutkan secara eksplisit sebagai hari kerja.
 
B. Umum
1. Penyedia Katalog Elektronik (M-Speed) dapat menggunakan Aplikasi Katalog Elektronik (M-Speed) untuk menjual Barang/Jasa melalui metode E-Purchasing.
2. Pengelola Katalog Elektronik (M-Speed) tidak memungut biaya pendaftaran kepada Penyedia Katalog Elektronik (M-Speed).
 
 
C. Hak dan Kewajiban Penyedia Katalog Elektronik (M-Speed)
1. Hak Penyedia Katalog Elektronik (M-Speed)
a. meminta fasilitas-fasilitas dalam bentuk sarana dan prasarana dari Pengelola Katalog Elektronik (M-Speed) dalam rangka pelaksanaan transaksi E-Purchasing sesuai prosedur yang berlaku;
b. menunjuk Distributor/Reseller/Pelaksana Pekerjaan/ Pengirim Barang dalam rangka pelaksanaan transaksi E-Purchasing sesuai prosedur dan/atau peraturan perundang-undangan yang berlaku;
c. tidak meneruskan/melanjutkan/menyetujui proses E-Purchasing, tidak menindaklanjuti hasil negosiasi antara Pemesan dengan Penyedia Katalog Elektronik (M-Speed) paling lambat 3 (tiga) hari kalender sejak negosiasi dilakukan;
d. Melakukan Penambahan Produk pada Etalase Produk tertentu yang pernah dilakukan pendaftaran dan penayangan oleh Penyedia Katalog Elektronik (M-Speed); dan
e. melakukan proses Pembaruan Informasi pada Katalog Elektronik (M-Speed) sesuai dengan ketentuan yang berlaku.
2. Kewajiban Penyedia Katalog Elektronik (M-Speed)
a. menjamin pemenuhan seluruh kriteria kualifikasi yang dipersyaratkan pada dokumen Pengumuman Pendaftaran;
b. bertanggung jawab atas informasi produk, spesifikasi teknis, gambar dan lampiran yang diunggah pada Aplikasi Katalog Elektronik (M-Speed);
c. memastikan bahwa seluruh materi, konten atau substansi yang diisi dan diunggah pada Aplikasi Katalog Elektronik (M-Speed) bukan termasuk konten yang dilarang dan/atau tidak bertentangan dengan peraturan perundang-undangan;
d. bertanggung jawab atas laporan atau pengaduan mengenai konten yang diunggah;
e. bertanggung jawab atas harga barang/jasa yang tercantum pada Aplikasi Katalog Elektronik (M-Speed) dengan menjamin harga yang tercantum merupakan harga terbaik bagi PT Mitra Karya Prima;
f. menjamin garansi produk (sepanjang memiliki garansi dan tidak dilakukan modifikasi/perubahan yang mengakibatkan hilangnya garansi tersebut);
g. bertanggung jawab atas segala tuntutan atau klaim yang disebabkan penggunaan Kekayaan Intelektual (KI) termasuk hak cipta, merek dagang, hak paten, dan bentuk KI lainnya oleh Penyedia Katalog Elektronik (M-Speed);
h. bertanggung jawab atas pelaksanaan pesanan E-Purchasing katalog dan telah memastikan kesesuaian informasi Barang/Jasa yang diunggah pada Katalog Elektronik (M-Speed) dengan yang dikirimkan ke Pemesan (Bagian Pengadaan Barang/Jasa PT Mitra Karya Prima);
i. mematuhi etika pengadaan dengan tidak menawarkan, atau tidak menjanjikan untuk memberi atau menerima hadiah, imbalan, komisi, rabat, dan apa saja dari atau kepada siapapun yang diketahui atau patut diduga berkaitan dengan pengadaan Barang/Jasa;
j. bertransaksi melalui prosedur transaksi yang telah ditetapkan oleh PT Mitra Karya Prima dan Pengelola Katalog Elektronik (M-Speed);
k. memenuhi pesanan PT Mitra Karya Prima terhadap produk yang tayang pada aplikasi Katalog Elektronik (M-Speed) sesuai dengan spesifikasi teknis dan gambar serta harga sebagaimana tercantum pada Katalog Elektronik (M-Speed);
l. menjamin barang/jasa yang tersedia di dalam Katalog Elektronik (M-Speed) telah memenuhi kualitas dan persyaratan/standar/ pedoman keamanan dan/atau pendistribusian yang ditetapkan oleh instansi yang berwenang;
m. menjamin barang/jasa dalam Katalog Elektronik (M-Speed) memenuhi semua aspek perizinan berdasarkan peraturan perundang-undangan yang berlaku;
n. tidak menjual barang/jasa melalui E-Purchasing dengan harga yang lebih mahal dari harga barang/jasa yang dijual selain melalui E-Purchasing pada periode penjualan, volume produk, tempat (kota/kabupaten) yang sama dan spesifikasi teknis yang sama;
o. memberikan respon atas pesanan dalam proses E-Purchasing kepada Pejabat Pengadaan / PPK paling lambat 1 (satu) hari kalender;
p. memenuhi pesanan sesuai dengan kesepakatan sebagaimana tercantum dalam Surat Pesanan;
q. memberikan keterangan-keterangan yang diperlukan untuk pemeriksaan pelaksanaan Pekerjaan yang dilakukan oleh Auditor dan/atau Aparat Penegak Hukum;
r. menyampaikan laporan/data yang diperlukan dalam rangka monitoring dan evaluasi penyediaan dari pelaksanaan Syarat dan Ketentuan ini kepada Bagian Pengadaan Barang/Jasa PT Mitra Karya Prima atau Pengelola Katalog Elektronik (M-Speed);
s. bertanggung jawab terhadap segala dampak yang ditimbulkan akibat rendahnya kualitas produk yang digunakan oleh Pengguna Barang/Jasa PT Mitra Karya Prima;
t. menyediakan dan mengirimkan produk melalui Distributor/Reseller/Pelaksana Pekerjaan/Pengirim Barang yang terdaftar dalam Aplikasi Katalog Elektronik (M-Speed);
u. bertanggung jawab terhadap segala kesalahan atau kelalaian yang dilakukan Distributor/Reseller/Pelaksana Pekerjaan/Pengirim Barang selama pelaksanaan pekerjaan dilaksanakan melalui E-Purchasing;
v. memperbarui data kualifikasi dan dokumen perizinan yang dimiliki Penyedia Katalog Elektronik (M-Speed) maupun produk yang tercantum pada Katalog Elektronik (M-Speed) (apabila memerlukan pembaruan);
w. tidak membuat dan/atau menyampaikan dokumen dan/atau keterangan lain yang tidak benar untuk memenuhi persyaratan tayang pada Aplikasi Katalog Elektronik (M-Speed);
x. melaporkan kemajuan realisasi transaksi setiap pelaksanaan E-Purchasing yang dilanjutkan sampai dengan Surat Pesanan kepada Pengelola Katalog Elektronik (M-Speed) melalui Aplikasi Katalog Elektronik (M-Speed);
y. memberikan keterangan-keterangan yang diperlukan untuk pemeriksaan pelaksanaan Pekerjaan yang dilakukan melalui E-Purchasing;
z. Bersedia dikenakan sanksi oleh PT Mitra Karya Prima atau Pengelola Katalog Elektronik (M-Speed) sesuai dengan ketentuan peraturan yang berlaku;
aa. Menurunkan produk dari Katalog Elektronik (M-Speed) dalam hal:
1) izin usaha Penyedia dicabut oleh institusi pemerintah yang berwenang;
2) produk yang ditayangkan tidak lagi dapat diedarkan berdasarkan rekomendasi/pemberitahuan/keputusan instansi pemerintah yang berwenang; dan/atau
3) Penyedia Katalog Elektronik (M-Speed) dikenakan sanksi oleh PT Mitra Karya Prima yang mengakibatkan Penyedia Katalog Elektronik (M-Speed) tersebut tidak dapat mengikuti Pengadaan Barang/Jasa di seluruh Unit Kerja PT Mitra Karya Prima dalam jangka waktu tertentu atau produk yang tercantum pada Katalog Elektronik (M-Speed) tidak boleh diperjualbelikan.
 
D. Hak dan Kewajiban PT Mitra Karya Prima dan/atau Pengelola Katalog Elektronik (M-Speed)
1. Hak PT Mitra Karya Prima dan/atau Pengelola Katalog Elektronik (M-Speed)
a. PT Mitra Karya Prima atau Pengelola Katalog Elektronik (M-Speed) berhak meminta dan/atau menerima keterangan dari Penyedia Katalog Elektronik (M-Speed) yang diperlukan dalam rangka pemeriksaan dan/atau audit dari pelaksanaan Syarat dan Ketentuan ini;
b. PT Mitra Karya Prima atau Pengelola Katalog Elektronik (M-Speed) berhak meminta dan/atau menerima laporan/data yang diperlukan dalam rangka monitoring dan evaluasi penyediaan dari pelaksanaan Syarat dan Ketentuan ini;
c. PT Mitra Karya Prima atau Pengelola Katalog Elektronik (M-Speed) berhak menggunakan data Penyedia Katalog Elektronik (M-Speed) untuk penelusuran indikasi manipulasi, pelanggaran maupun pemanfaatan fitur Aplikasi Katalog Elektronik (M-Speed) untuk keuntungan pribadi Penyedia Katalog Elektronik (M-Speed), maupun indikasi kecurangan atau pelanggaran Syarat dan Ketentuan ini, Ketentuan Situs, dan/atau ketentuan hukum yang berlaku di wilayah negara Indonesia.
d. PT Mitra Karya Prima atau Pengelola Katalog Elektronik (M-Speed) berdasarkan pertimbangan sepihak dan tanpa pemberitahuan sebelumnya dapat melakukan tindakan-tindakan yang diperlukan termasuk namun tidak terbatas pada:
1) penghentian Penyedia Katalog Elektronik (M-Speed) dalam pencantuman pada Aplikasi Katalog Elektronik (M-Speed);
2) membekukan transaksi E-Purchasing;
3) menurunkan produk pada Aplikasi Katalog Elektronik (M-Speed);
4) menutup akun; dan/atau
5) hal-hal lainnya;
e. PT Mitra Karya Prima berhak melakukan perubahan atas Syarat dan Ketentuan Penyedia Katalog Elektronik (M-Speed) ini.
f. Pengelola Katalog Elektronik (M-Speed) Mengenakan sanksi kepada Penyedia Katalog Elektronik (M-Speed) sesuai dengan ketentuan peraturan perundang-undangan yang berlaku dan/atau Syarat dan Ketentuan Penyedia Katalog Elektronik (M-Speed).
2. Kewajiban PT Mitra Karya Prima dan Pengelola Katalog Elektronik (M-Speed): Memberikan fasilitas-fasilitas dalam bentuk sarana dan prasarana dalam rangka pelaksanaan transaksi E-Purchasing antara Penyedia Katalog Elektronik (M-Speed) dengan Pengguna Barang/Jasa PT Mitra Karya Prima sesuai prosedur dan/atau peraturan yang berlaku.
E. Perbuatan yang Dilarang
1. Tidak memenuhi kewajiban sebagai Penyedia Katalog Elektronik (M-Speed);
2. Tidak memenuhi permintaan yang merupakan Hak PT Mitra Karya Prima dan/atau Pengelola Katalog Elektronik (M-Speed); dan/atau
3. Membuat dan/atau menyampaikan secara tidak benar dokumen dan/atau keterangan lain yang disyaratkan untuk penyusunan dan pelaksanaan Syarat dan Ketentuan Penyedia Katalog Elektronik (M-Speed).
F. Perpajakan, Bea, Retribusi, dan Pungutan Lainnya Penyedia Katalog Elektronik (M-Speed), Distributor/Reseller/Pelaksana Pekerjaan/Pengirim Barang (apabila ada) yang ditunjuk Penyedia Katalog Elektronik (M-Speed), dan/atau Personil yang bersangkutan berkewajiban untuk membayar semua pajak, bea, retribusi, dan pungutan lain yang dibebankan oleh peraturan perpajakan atas pelaksanaan Syarat dan Ketentuan ini. Semua pengeluaran perpajakan ini telah termasuk dalam harga satuan produk.
G. Pembaruan Informasi dan Penambahan Produk
1. Penyedia Katalog Elektronik (M-Speed) dapat melakukan Pembaruan Informasi dan Penambahan Produk sesuai dengan Ketentuan yang berlaku terkait Katalog Elektronik (M-Speed).
2. Tata Cara Penambahan dan Pembaruan Produk yang dilakukan pada Aplikasi Katalog Elektronik (M-Speed) sebagaimana dimaksud mengacu pada Panduan Penggunaan Aplikasi Katalog Elektronik (M-Speed) PT Mitra Karya Prima beserta perubahannya.
H. Sanksi
1. apabila Penyedia Katalog Elektronik (M-Speed) melanggar kewajiban atas Syarat dan Ketentuan Katalog Elektronik (M-Speed) maka dikenakan surat peringatan pertama;
2. apabila Penyedia Katalog Elektronik (M-Speed) melakukan pelanggaran yang sama dan/atau melakukan pelanggaran lain sebagaimana disebutkan pada kewajiban atas Syarat dan Ketentuan Penyedia Katalog Elektronik (M-Speed) untuk yang kedua kali maka dikenakan surat peringatan kedua dan penghentian sementara dalam sistem transaksi E-Purchasing selama 3 (tiga) bulan;
3. apabila Penyedia Katalog Elektronik (M-Speed) melakukan pelanggaran yang sama dan/atau melakukan pelanggaran lain sebagaimana disebutkan pada kewajiban Syarat dan Ketentuan Penyedia Katalog Elektronik (M-Speed) untuk yang ketiga kali maka dikenakan surat peringatan ketiga dan penurunan pencantuman Penyedia Katalog Elektronik (M-Speed) dari Katalog Elektronik (M-Speed) selama 1 (satu) tahun;
4. apabila Penyedia Katalog Elektronik (M-Speed) melakukan perbuatan yang dilarang sebagaimana tercantum pada huruf E angka 3 akan dikenakan sanksi pencabutan sebagai Penyedia Katalog Elektronik (M-Speed) dan ketentuan sanksi sesuai peraturan yang berlaku; dan
5. apabila Penyedia Katalog Elektronik (M-Speed), berdasarkan hasil pemeriksaan oleh Auditor/PT Mitra Karya Prima/Aparat Penegak Hukum terdapat Kerugian Negara yang timbul akibat Syarat dan Ketentuan Penyedia Katalog Elektronik (M-Speed) maka Penyedia Katalog Elektronik (M-Speed) wajib mengembalikan seluruh Kerugian Perusahaan tersebut dan dikenakan sanksi berdasarkan Peraturan yang berlaku.
I. Pencabutan Status sebagai Penyedia Katalog Elektronik (M-Speed) PT Mitra Karya Prima atau Pengelola Katalog Elektronik (M-Speed) dapat mencabut status sebagai Penyedia Katalog Elektronik (M-Speed) secara sepihak apabila:
1. rekomendasi dan/atau hasil pemantauan/evaluasi/audit/reviu/ pemeriksaan yang dilakukan Auditor PT Mitra Karya Prima/PT Mitra Karya Prima/Bagian Pengadaan Barang/Jasa PT Mitra Karya Prima/Aparat Penegak Hukum berdasarkan peraturan yang berlaku yang merekomendasikan untuk mencabut status sebagai Penyedia Katalog Elektronik (M-Speed);
2. melakukan pelanggaran yang sama dan/atau melakukan pelanggaran lain sebagaimana disebutkan pada kewajiban Syarat dan Ketentuan Penyedia Katalog Elektronik (M-Speed) setelah diberikan sanksi peringatan ketiga kali;
3. membuat dan/atau menyampaikan secara tidak benar dokumen dan/atau keterangan lain yang disyaratkan untuk penyusunan dan pelaksanaan Syarat dan Ketentuan Penyedia Katalog Elektronik (M-Speed);
4. berada dalam keadaan pailit;
5. terbukti melakukan KKN, kecurangan dan/atau pemalsuan dalam proses Pengadaan yang diputuskan oleh instansi yang berwenang;
6. izin usaha dicabut oleh instansi pemerintah yang berwenang; dan/atau
7. dikenakan sanksi oleh PT Mitra Karya Prima atau PLN NP Group. Penyedia Katalog Elektronik (M-Speed) yang dikenakan Pencabutan Status sebagai Penyedia Katalog Elektronik (M-Speed) akan dilakukan penurunan pencantuman dari Katalog Elektronik (M-Speed). Untuk Penyedia Katalog Elektronik (M-Speed) yang dikenakan Pencabutan Status sebagai Penyedia Katalog Elektronik (M-Speed) berdasarkan angka 1, 2, 3 dan 5 tidak diperbolehkan mendaftar menjadi Penyedia Katalog Elektronik (M-Speed) selama 1 (satu) tahun setelah Pencabutan.
J. Pembaruan Syarat dan Ketentuan Penyedia Katalog Elektronik (M-Speed) dapat mengalami perubahan dan/atau diperbaharui dari waktu ke waktu tanpa pemberitahuan sebelumnya. Dengan tetap mengakses dan menggunakan layanan Katalog Elektronik (M-Speed), maka Penyedia Katalog Elektronik (M-Speed) dianggap menyetujui perubahan-perubahan dalam Syarat dan Ketentuan Penyedia Katalog Elektronik (M-Speed).v''',
              textAlign: TextAlign.left,
              style: TextStyle(fontSize: 10),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<RegisterProvider>();
    PreferredSizeWidget appBar = CustomAppBar.appBar(
      context,
      "Daftar Seller",
      color: Colors.white,
      isCenter: true,
      textStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
    );

    Widget form() {
      return Form(
        key: p.registerKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Constant.xSizedBox16,
              CustomTextField.borderTextField(
                labelText: 'Nama Perusahaan / Toko',
                hintText: 'Nama Perusahaan / Toko',
                controller: p.companyNameC,
                required: true,
              ),
              Constant.xSizedBox16,
              CustomTextField.borderTextField(
                labelText: 'Nama Pemilik / Direktur',
                hintText: 'Nama Pemilik / Direktur',
                controller: p.ownerNameC,
                required: true,
              ),
              Constant.xSizedBox16,
              CustomTextField.borderTextField(
                labelText: 'Jabatan',
                hintText: 'Jabatan',
                controller: p.roleC,
                required: true,
              ),
              Constant.xSizedBox16,
              CustomTextField.borderTextArea(
                labelText: 'Alamat Lengkap',
                controller: p.addressC,
                required: true,
              ),
              Constant.xSizedBox16,
              CustomTextField.borderTextField(
                labelText: 'Email',
                hintText: 'Email',
                controller: p.emailC,
                required: true,
              ),
              Constant.xSizedBox16,
              CustomTextField.borderTextField(
                labelText: 'Password',
                hintText: 'Password',
                controller: p.passwordC,
                required: true,
              ),
              Constant.xSizedBox16,
              CustomTextField.borderTextField(
                labelText: 'Konfirmasi Password',
                hintText: 'Konfirmasi Password',
                controller: p.confirmPasswordC,
                required: true,
              ),
              Constant.xSizedBox16,
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Checkbox(
                    value: p.acc,
                    onChanged: (value) {
                      setState(
                        () {
                          p.acc = value!;
                        },
                      );
                    },
                  ),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(fontSize: 14, color: Colors.black),
                        children: [
                          TextSpan(
                            text: "Saya setuju semua pernyataan di ",
                          ),
                          TextSpan(
                            text: "Syarat dan Ketentuan",
                            style: TextStyle(
                              color: const Color.fromRGBO(228, 53, 50, 1),
                              decoration: TextDecoration.underline,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = showTermsPopup,
                          ),
                        ],
                      ),
                      maxLines: null,
                      overflow: TextOverflow.visible,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              CustomButton.mainButton(
                "Daftar",
                () async {
                  await context.read<RegisterProvider>().register(context);
                },
                color: p.acc ? Constant.primaryColor : Constant.grayColor,
                textStyle: TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.w500),
                contentPadding: EdgeInsets.all(16),
                borderRadius: BorderRadius.circular(10),
              ),
              Constant.xSizedBox24,
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: appBar,
      body: SafeArea(
        child: Container(
          color: Colors.white,
          padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: form(),
        ),
      ),
    );
  }
}
