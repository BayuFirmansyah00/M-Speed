import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart' as path;

import '../../../common/component/custom_button.dart';
import '../../../common/component/custom_dropdown.dart';
import '../../../common/component/custom_image_picker.dart';
import '../../../common/component/custom_navigator.dart';
import '../../../common/component/custom_textfield.dart';
import '../../../common/helper/constant.dart';
import '../../../common/helper/app_colors.dart';
import '../../../common/helper/download.dart';
import '../../../utils/utils.dart';
import '../../admin/user/view/admin_form_widgets.dart';
import '../../buyer/address/view/search_location_view.dart';
import '../../buyer/address/view/custom_map_view.dart';
import '../../buyer/transaction/widget/submit_ttd_widget.dart';
import '../provider/register_provider.dart';

// --- Private Components (Reused from Profile) ---
class _FileButton extends StatelessWidget {
  final String title;
  final String? fileName;
  final VoidCallback onChoose;
  const _FileButton({required this.title, this.fileName, required this.onChoose});

  @override
  Widget build(BuildContext context) {
    const accent = AppColors.primary;
    return GestureDetector(
      onTap: onChoose,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: fileName != null && fileName!.isNotEmpty ? accent.withOpacity(0.06) : AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: fileName != null && fileName!.isNotEmpty ? accent.withOpacity(0.3) : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: accent.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                fileName != null && fileName!.isNotEmpty ? Icons.check_circle_outline_rounded : Icons.upload_file_outlined,
                color: accent, size: 16,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                  if (fileName != null && fileName!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(fileName!, style: const TextStyle(fontSize: 11, color: accent), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ] else
                    const Text('Tap untuk memilih file', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary, size: 18),
          ],
        ),
      ),
    );
  }
}

class SellerRegisterView extends StatefulWidget {
  const SellerRegisterView({Key? key}) : super(key: key);

  @override
  State<SellerRegisterView> createState() => _SellerRegisterViewState();
}

class _SellerRegisterViewState extends State<SellerRegisterView> {
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final p = context.read<RegisterProvider>();
      p.fetchProvinsi();
      p.fetchKota();
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<RegisterProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Daftar Vendor', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.black87),
          onPressed: () {
            if (p.currentStep > 0) {
              p.previousStep();
              _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.ease);
            } else {
              CusNav.nPop(context);
            }
          },
        ),
      ),
      body: Column(
        children: [
          // Stepper Indicator
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(7, (index) {
                return Container(
                  width: 32,
                  height: 4,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: index <= p.currentStep ? AppColors.primary : AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                );
              }),
            ),
          ),
          
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildStepAccount(p),
                _buildStepStore(p),
                _buildStepContact(p),
                _buildStepAddress(p),
                _buildStepBank(p),
                _buildStepLegality(p),
                _buildStepReview(p),
              ],
            ),
          ),

          // Bottom Buttons
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))
              ]
            ),
            child: Row(
              children: [
                if (p.currentStep > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        p.previousStep();
                        _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.ease);
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        side: BorderSide(color: AppColors.primary),
                      ),
                      child: Text('Kembali', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                    ),
                  ),
                if (p.currentStep > 0) const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (p.currentStep < 6) {
                        int beforeStep = p.currentStep;
                        p.nextStep();
                        if (p.currentStep > beforeStep) {
                           _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.ease);
                        }
                      } else {
                        await p.submitRegistration(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      p.currentStep == 6 ? 'Submit Registrasi' : 'Selanjutnya', 
                      style: const TextStyle(fontWeight: FontWeight.bold)
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- STEPS ---

  Widget _buildStepAccount(RegisterProvider p) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: p.formKeyAccount,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Langkah 1 dari 7', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Informasi Akun', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
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
              validator: (v) => v!.isEmpty ? 'Password harus diisi' : null,
            ),
            const SizedBox(height: 16),
            AdminFormField(
              controller: p.confirmPasswordC, 
              label: 'Konfirmasi Password *', 
              hint: 'Ulangi Password', 
              icon: Icons.lock_reset, 
              obscure: true,
              validator: (v) => v!.isEmpty ? 'Konfirmasi Password harus diisi' : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepStore(RegisterProvider p) {
    const accent = AppColors.primary;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: p.formKeyStore,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Langkah 2 dari 7', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Informasi Toko / Perusahaan', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
            const SizedBox(height: 24),
            AdminFormField(
              controller: p.companyNameC, 
              label: 'Nama Toko / Perusahaan *', 
              hint: 'Nama Toko', 
              icon: Icons.business,
              validator: (v) => v!.isEmpty ? 'Nama Toko wajib diisi' : null,
            ),
            const SizedBox(height: 16),
            AdminFormField(
              controller: p.ownerNameC, 
              label: 'Nama Pemilik / Direktur *', 
              hint: 'Nama Pemilik', 
              icon: Icons.person,
              validator: (v) => v!.isEmpty ? 'Nama Pemilik wajib diisi' : null,
            ),
            const SizedBox(height: 16),
            AdminFormField(
              controller: p.roleC, 
              label: 'Jabatan *', 
              hint: 'Jabatan (cth: Direktur)', 
              icon: Icons.badge,
              validator: (v) => v!.isEmpty ? 'Jabatan wajib diisi' : null,
            ),
            const SizedBox(height: 16),
            AdminFormField(
              controller: p.kbliC, 
              label: 'KBLI *', 
              hint: 'Kode KBLI', 
              icon: Icons.numbers,
              validator: (v) => v!.isEmpty ? 'KBLI wajib diisi' : null,
            ),
            const SizedBox(height: 16),
            const Text('Jenis Toko *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<int>(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('PKP', style: TextStyle(fontSize: 13)),
                    value: 1,
                    groupValue: p.jenisToko,
                    activeColor: accent,
                    onChanged: (value) {
                      setState(() => p.jenisToko = 1);
                    },
                  ),
                ),
                Expanded(
                  child: RadioListTile<int>(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Non PKP (Punya NPWP)', style: TextStyle(fontSize: 13)),
                    value: 2,
                    groupValue: p.jenisToko,
                    activeColor: accent,
                    onChanged: (value) {
                      setState(() => p.jenisToko = 2);
                    },
                  ),
                ),
              ],
            ),
            RadioListTile<int>(
              contentPadding: EdgeInsets.zero,
              title: const Text('Non PKP (Tidak Punya NPWP)', style: TextStyle(fontSize: 13)),
              value: 3,
              groupValue: p.jenisToko,
              activeColor: accent,
              onChanged: (value) {
                setState(() => p.jenisToko = 3);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepContact(RegisterProvider p) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: p.formKeyContact,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Langkah 3 dari 7', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Kontak & Relasi', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
            const SizedBox(height: 24),
            AdminFormField(
              controller: p.phoneC, 
              label: 'No Telepon Perusahaan *', 
              hint: 'No Telepon', 
              icon: Icons.phone, 
              inputType: TextInputType.phone,
              validator: (v) => v!.isEmpty ? 'No Telepon wajib diisi' : null,
            ),
            const SizedBox(height: 16),
            AdminFormField(
              controller: p.salesNameC, 
              label: 'Nama Sales / Kuasa *', 
              hint: 'Nama Sales', 
              icon: Icons.support_agent,
              validator: (v) => v!.isEmpty ? 'Nama Sales wajib diisi' : null,
            ),
            const SizedBox(height: 16),
            AdminFormField(
              controller: p.salesPhoneC, 
              label: 'Telp Sales / Kuasa *', 
              hint: 'No Telp Sales', 
              icon: Icons.phone_callback, 
              inputType: TextInputType.phone,
              validator: (v) => v!.isEmpty ? 'Telp Sales wajib diisi' : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepAddress(RegisterProvider p) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: p.formKeyAddress,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Langkah 4 dari 7', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Lokasi & Alamat', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
            const SizedBox(height: 24),
            
            CustomDropdown.searchDropdown(
              required: true,
              labelText: 'Provinsi',
              hintText: 'Pilih Provinsi',
              selectedItem: p.selectedProvince,
              list: (p.provinsiModel?.data ?? []).map((e) => e?.nama ?? '').where((e) => e.isNotEmpty).toList(),
              onChanged: (v) {
                var index = p.provinsiModel?.data?.indexWhere((e) => e?.nama == v) ?? -1;
                if (index != -1) {
                  setState(() {
                    p.selectedProvince = v;
                    p.selectedProvinceId = p.provinsiModel?.data?[index]?.ID ?? '';
                    // Reset City
                    p.selectedCity = null;
                    p.selectedCityId = null;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            CustomDropdown.searchDropdown(
              required: true,
              labelText: 'Kota',
              hintText: 'Pilih Kota',
              selectedItem: p.selectedCity,
              enabled: p.selectedProvinceId != null,
              list: (p.kotaModel?.data ?? [])
                  .where((e) => p.selectedProvinceId != null && e?.provinceId == p.selectedProvinceId)
                  .map((e) => e?.kota ?? '').where((e) => e.isNotEmpty).toList(),
              onChanged: (v) {
                var index = p.kotaModel?.data?.indexWhere((e) => e?.kota == v) ?? -1;
                if (index != -1) {
                  setState(() {
                    p.selectedCity = v;
                    p.selectedCityId = p.kotaModel?.data?[index]?.ID ?? '';
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            AdminFormField(
              controller: p.addressC, 
              label: 'Alamat Lengkap *', 
              hint: 'Alamat Detail', 
              icon: Icons.map, 
              maxLines: 3,
              validator: (v) => v!.isEmpty ? 'Alamat wajib diisi' : null,
            ),
            const SizedBox(height: 24),
            const Text('Titik Koordinat Peta', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            
            // Map Preview
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: AspectRatio(
                aspectRatio: 2 / 1,
                child: FlutterMap(
                  mapController: p.mapController,
                  options: MapOptions(
                    initialCenter: p.locationCoordinate ?? const LatLng(-7.1144282, 112.4069792),
                    initialZoom: 15,
                    interactionOptions: const InteractionOptions(flags: InteractiveFlag.none),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                      userAgentPackageName: 'com.mspeed.app',
                    ),
                    MarkerLayer(
                      markers: [
                        if (p.marker != null)
                          Marker(
                            point: LatLng(p.marker!.point.latitude, p.marker!.point.longitude),
                            child: const Icon(Icons.location_on, color: Colors.red),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            CustomButton.secondaryButton("Pilih Lokasi di Peta", borderRadius: BorderRadius.circular(8), () async {
              late LatLng currentPosition;
              if (p.locationCoordinate != null) {
                currentPosition = p.locationCoordinate!;
              } else {
                bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
                if (!serviceEnabled) {
                  Utils.showFailed(msg: 'Location services disabled.');
                  return;
                }
                LocationPermission permission = await Geolocator.checkPermission();
                if (permission == LocationPermission.denied) {
                  permission = await Geolocator.requestPermission();
                  if (permission == LocationPermission.denied) return;
                }
                Position? pos;
                try {
                  pos = await Geolocator.getCurrentPosition(
                      forceAndroidLocationManager: true, desiredAccuracy: LocationAccuracy.best, timeLimit: const Duration(seconds: 3));
                } catch (e) {
                  pos = await Geolocator.getLastKnownPosition(forceAndroidLocationManager: true);
                }
                currentPosition = pos != null ? LatLng(pos.latitude, pos.longitude) : const LatLng(-7.1144282, 112.4069792);
              }

              PickedData? pickedData = await Navigator.push(context, MaterialPageRoute(
                builder: (context) => SearchLocationView.create(p.locationCoordinate ?? currentPosition),
              ));

              if (pickedData != null) {
                await p.setMapLocation(pickedData);
                p.mapController.move(pickedData.latLong, 15);
              }
            }),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: AdminFormField(controller: p.latC, label: 'Latitude', hint: 'Lat', icon: Icons.location_searching)),
                const SizedBox(width: 12),
                Expanded(child: AdminFormField(controller: p.lngC, label: 'Longitude', hint: 'Lng', icon: Icons.location_searching)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepBank(RegisterProvider p) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: p.formKeyBank,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Langkah 5 dari 7', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Rekening Bank', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
            const SizedBox(height: 24),
            AdminFormField(
              controller: p.bankTypeC, 
              label: 'Nama Bank *', 
              hint: 'Contoh: BCA', 
              icon: Icons.account_balance,
              validator: (v) => v!.isEmpty ? 'Nama Bank wajib diisi' : null,
            ),
            const SizedBox(height: 16),
            AdminFormField(
              controller: p.bankNumberC, 
              label: 'No Rekening *', 
              hint: 'No Rekening', 
              icon: Icons.numbers, 
              inputType: TextInputType.number,
              validator: (v) => v!.isEmpty ? 'No Rekening wajib diisi' : null,
            ),
            const SizedBox(height: 16),
            AdminFormField(
              controller: p.bankNameC, 
              label: 'Atas Nama Rekening *', 
              hint: 'Pemilik Rekening', 
              icon: Icons.person_outline,
              validator: (v) => v!.isEmpty ? 'Atas Nama wajib diisi' : null,
            ),
            const SizedBox(height: 24),
            _FileButton(
              title: 'File Buku Rekening *',
              fileName: p.bankNumberFileC.text,
              onChoose: () async {
                p.bankNumberFile = await CustomImagePicker.selectImageFromGallery();
                if (p.bankNumberFile != null) {
                  p.bankNumberFileC.text = path.basename(p.bankNumberFile!.path);
                }
                setState(() {});
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepLegality(RegisterProvider p) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: p.formKeyLegality,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Langkah 6 dari 7', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Legalitas & Dokumen', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
            const SizedBox(height: 24),
            AdminFormField(
              controller: p.ktpNumberC, 
              label: 'No KTP *', 
              hint: 'Nomor KTP', 
              icon: Icons.credit_card,
              validator: (v) => v!.isEmpty ? 'KTP wajib diisi' : null,
            ),
            const SizedBox(height: 12),
            _FileButton(
              title: 'Upload File KTP *',
              fileName: p.ktpFileC.text,
              onChoose: () async {
                p.ktpFile = await CustomImagePicker.selectImageFromGallery();
                if (p.ktpFile != null) p.ktpFileC.text = path.basename(p.ktpFile!.path);
                setState(() {});
              },
            ),
            const SizedBox(height: 16),
            
            AdminFormField(
              controller: p.npwpC, 
              label: 'No NPWP ${p.jenisToko == 2 ? '*' : ''}', 
              hint: 'Nomor NPWP', 
              icon: Icons.receipt_long,
              enabled: p.jenisToko != 2,
              validator: (v) => (p.jenisToko != 2 && v!.isEmpty) ? 'NPWP wajib diisi' : null,
            ),
            const SizedBox(height: 12),
            if (p.jenisToko != 2)
              _FileButton(
                title: 'Upload File NPWP *',
                fileName: p.npwpFileC.text,
                onChoose: () async {
                  p.npwpFile = await CustomImagePicker.selectImageFromGallery();
                  if (p.npwpFile != null) p.npwpFileC.text = path.basename(p.npwpFile!.path);
                  setState(() {});
                },
              ),
            
            const SizedBox(height: 16),
            AdminFormField(
              controller: p.nibC, 
              label: 'No NIB *', 
              hint: 'Nomor NIB', 
              icon: Icons.description,
              validator: (v) => v!.isEmpty ? 'NIB wajib diisi' : null,
            ),
            const SizedBox(height: 12),
            _FileButton(
              title: 'Upload File NIB *',
              fileName: p.nibFileC.text,
              onChoose: () async {
                p.nibFile = await CustomImagePicker.selectImageFromGallery();
                if (p.nibFile != null) p.nibFileC.text = path.basename(p.nibFile!.path);
                setState(() {});
              },
            ),

            if (p.jenisToko == 1) ...[
              const SizedBox(height: 16),
              _FileButton(
                title: 'Upload File SP SKP *',
                fileName: p.spSkpFileC.text,
                onChoose: () async {
                  p.spSkpFile = await CustomImagePicker.selectImageFromGallery();
                  if (p.spSkpFile != null) p.spSkpFileC.text = path.basename(p.spSkpFile!.path);
                  setState(() {});
                },
              ),
            ],

            const SizedBox(height: 16),
            _FileButton(
              title: 'Surat Pernyataan *',
              fileName: p.suratPernyataanFileC.text,
              onChoose: () async {
                p.suratPernyataanFile = await CustomImagePicker.selectImageFromGallery();
                if (p.suratPernyataanFile != null) p.suratPernyataanFileC.text = path.basename(p.suratPernyataanFile!.path);
                setState(() {});
              },
            ),
            
            const SizedBox(height: 24),
            const Text('Tanda Tangan *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
            const SizedBox(height: 12),
            if (p.ttd == null)
              OutlinedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return Dialog(
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        insetPadding: const EdgeInsets.symmetric(horizontal: 16),
                        child: SubmitTtdWidget(
                          onSubmit: (v) async {
                            p.ttd = v;
                            setState(() {});
                            FocusManager.instance.primaryFocus?.unfocus();
                          },
                        ),
                      );
                    },
                  );
                },
                icon: const Icon(Icons.draw),
                label: const Text('Buat Tanda Tangan'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              )
            else
              Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Stack(
                  children: [
                    Center(child: Image.file(p.ttd!, fit: BoxFit.contain)),
                    Positioned(
                      top: 8, right: 8,
                      child: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => setState(() => p.ttd = null),
                      ),
                    )
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepReview(RegisterProvider p) {
    Widget reviewItem(String label, String value) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
            const SizedBox(height: 2),
            Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87)),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Langkah 7 dari 7', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Review Data', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
          const SizedBox(height: 16),
          
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.withOpacity(0.5)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline, color: Colors.orange, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: const Text(
                    'Informasi tambahan seperti rekening, legalitas, dan dokumen akan tersedia setelah backend mendukung penyimpanan data tersebut.',
                    style: TextStyle(fontSize: 12, color: Colors.deepOrange),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Informasi Akun', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                const Divider(),
                reviewItem('Email', p.emailC.text),
                
                const SizedBox(height: 16),
                const Text('Informasi Toko', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                const Divider(),
                reviewItem('Nama Toko', p.companyNameC.text),
                reviewItem('Pemilik', p.ownerNameC.text),
                reviewItem('Jabatan', p.roleC.text),
                reviewItem('KBLI', p.kbliC.text),
                reviewItem('Jenis Toko', p.jenisToko == 1 ? 'PKP' : (p.jenisToko == 2 ? 'Non PKP (Punya NPWP)' : 'Non PKP (Tanpa NPWP)')),

                const SizedBox(height: 16),
                const Text('Kontak & Lokasi', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                const Divider(),
                reviewItem('No Telp', p.phoneC.text),
                reviewItem('Sales', '${p.salesNameC.text} (${p.salesPhoneC.text})'),
                reviewItem('Provinsi/Kota', '${p.selectedProvince ?? '-'} / ${p.selectedCity ?? '-'}'),
                reviewItem('Alamat', p.addressC.text),
                
                const SizedBox(height: 16),
                const Text('Rekening Bank', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                const Divider(),
                reviewItem('Bank', p.bankTypeC.text),
                reviewItem('No Rekening', p.bankNumberC.text),
                reviewItem('Atas Nama', p.bankNameC.text),

                const SizedBox(height: 16),
                const Text('Dokumen (Terlampir)', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                const Divider(),
                if (p.ktpFile != null) reviewItem('KTP', p.ktpNumberC.text),
                if (p.npwpFile != null) reviewItem('NPWP', p.npwpC.text),
                if (p.nibFile != null) reviewItem('NIB', p.nibC.text),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Terms checkbox
          GestureDetector(
            onTap: () => setState(() => p.acc = !p.acc),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: p.acc ? AppColors.primary.withOpacity(0.06) : AppColors.background,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: p.acc ? AppColors.primary.withOpacity(0.3) : AppColors.border),
              ),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 20, height: 20,
                    decoration: BoxDecoration(
                      color: p.acc ? AppColors.primary : Colors.white,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: p.acc ? AppColors.primary : AppColors.border, width: 1.5),
                    ),
                    child: p.acc ? const Icon(Icons.check_rounded, color: Colors.white, size: 12) : null,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text('Saya memastikan semua data yang dimasukkan sudah benar dan valid.', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
