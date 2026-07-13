import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mspeed/common/base/base_state.dart';
import 'package:mspeed/common/component/custom_appbar.dart';
import 'package:mspeed/common/component/custom_navigator.dart';
import 'package:mspeed/common/component/image_network_widget.dart';
import 'package:mspeed/common/helper/Constant.dart';
import 'package:mspeed/generated/assets.dart';
import 'package:mspeed/src/buyer/chat/view/chat_person_view.dart';
import 'package:mspeed/src/penerima/chat/view/chat_pesanan_komplain_view.dart';
import 'package:mspeed/src/penerima/pesanan/provider/penerima_pesanan_provider.dart';
import 'package:mspeed/src/penerima/pesanan/view/cetak_surat_view.dart';
import 'package:mspeed/src/penerima/pesanan/view/ttd_surat_perjalanan_view.dart';
import 'package:mspeed/src/penerima/pesanan/widget/transaction_status_stepper.dart';
import 'package:mspeed/src/seller/pesanan/model/detail_pesanan_seller_model.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';

class PenerimaPesananDetailView extends StatefulWidget {
  final String transaction_id, seller_id;

  const PenerimaPesananDetailView({
    super.key,
    required this.transaction_id,
    required this.seller_id,
  });

  @override
  State<PenerimaPesananDetailView> createState() =>
      _PenerimaPesananDetailViewState();
}

class _PenerimaPesananDetailViewState
    extends BaseState<PenerimaPesananDetailView> {
  String userId = "";
  String buyerName = "";
  String buyerPhone = "";

  @override
  void initState() {
    initData();

    super.initState();
  }

  Future<void> initData() async {
    final prefs = await SharedPreferences.getInstance();
    userId = await prefs.getString(Constant.kSetPrefId) ?? "";
    buyerName = await prefs.getString(Constant.kSetPrefFirstName) ?? "";
    buyerPhone = await prefs.getString(Constant.kSetPrefPhone) ?? "";

    refresh();
    await requestPermission(Permission.manageExternalStorage);
    await requestPermission(Permission.photos);
    await requestPermission(Permission.storage);
  }

  Future<bool> requestPermission(Permission permission) async {
    PermissionStatus status = await permission.request();
    return [
      PermissionStatus.granted,
      PermissionStatus.limited,
    ].contains(status);
  }

  Future<void> showSuccessDialog(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 60),
                    SizedBox(height: 10),
                    Text(
                      'Berhasil',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              Divider(),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  refresh();
                },
                child: Text(
                  'Oke',
                  style: TextStyle(
                    color: Constant.primaryColor,
                    fontWeight: FontWeight.w400,
                    fontSize: 20,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  DetailPesananSellerModelData? data = DetailPesananSellerModelData();

  void refresh() {
    context.read<PenerimaPesananProvider>().fetchDetailPesananNew(
      withLoading: true,
      parent_id: widget.transaction_id,
      seller_id: widget.seller_id,
    );
  }

  bool isExpanded = false;
  List<bool> checks = [];

  @override
  Widget build(BuildContext context) {
    data = context.watch<PenerimaPesananProvider>().detailPesananNew.data;
    if (checks.isEmpty) {
      for (int i = 0; i < (data?.detail?.length ?? 0); i++) {
        checks.add(false);
      }
    }

    final p = context.read<PenerimaPesananProvider>();
    if (p.isTtdSuccess == true) {
      p.isTtdSuccess = null;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await showSuccessDialog(context);
        refresh();
      });
    }

    List<Widget> showListItems() {
      List<Widget> list = [];
      final length = data?.detail?.length ?? 0;
      if (length == 0) {
        return [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                "Tidak ada data produk",
                style: TextStyle(color: Colors.black45, fontSize: 14),
              ),
            ),
          ),
        ];
      }

      final iteration = isExpanded ? length : 1;

      for (int i = 0; i < iteration; i++) {
        list.add(
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  spreadRadius: 0,
                  offset: const Offset(0, 4),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 2,
                  spreadRadius: 0,
                  offset: const Offset(0, 1),
                ),
              ],
              border: Border.all(color: Colors.grey.withOpacity(0.1)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Custom Checkbox
                GestureDetector(
                  onTap: () {
                    setState(() {
                      checks[i] = !checks[i];
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                    width: 24,
                    height: 24,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: checks[i] ? Constant.primaryColor : Colors.white,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: checks[i] ? Constant.primaryColor : Colors.grey.shade300,
                        width: 1.5,
                      ),
                      boxShadow: checks[i]
                          ? [
                              BoxShadow(
                                color: Constant.primaryColor.withOpacity(0.3),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              )
                            ]
                          : [],
                    ),
                    child: checks[i]
                        ? const Icon(Icons.check, size: 16, color: Colors.white)
                        : null,
                  ),
                ),
                ImageNetworkWidget(
                  width: 60,
                  height: 60,
                  radius: 12,
                  imageUrl: data?.detail?.elementAt(i)?.foto ?? '',
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data?.detail?.elementAt(i)?.nama ?? '',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        data?.detail?.elementAt(i)?.hargaAkhir != null
                            ? '${data?.detail?.elementAt(i)?.qty ?? '1'} x ${formatCurrency(data?.detail?.elementAt(i)?.hargaAkhir ?? '0')}'
                            : '${data?.detail?.elementAt(i)?.qty ?? '1'} x ${formatCurrency(data?.detail?.elementAt(i)?.harga ?? '0')}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        formatCurrency(
                          data?.detail?.elementAt(i)?.hargaAkhir ?? '0',
                        ),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Constant.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                if (data?.detail?.elementAt(i)?.dikomplain != 'YES')
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => ChatPesananKomplainView(
                                id: data?.detail?.elementAt(i)?.SellerID ?? "",
                                orderNo:
                                    data?.detail?.elementAt(i)?.IDOrder ?? '',
                              ),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: Constant.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SvgPicture.asset(
                            Assets.svgsIcChat,
                            color: Constant.primaryColor,
                            width: 14,
                            height: 14,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Komplain',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Constant.primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.history, color: Colors.grey, size: 14),
                        SizedBox(width: 6),
                        Text(
                          'Dikomplain',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      }

      return list;
    }

    List<Widget> status() {
      final list = data?.timeline ?? [];
      if (list.isEmpty) return [SizedBox()];
      final length =
          p.showMore ? list.length : (list.length >= 3 ? 3 : list.length);
      var widgets = List<Widget>.generate(length, (i) {
        final item = list[i];
        return TransactionStatusStepper(
          title: item?.label ?? '',
          date: item?.time ?? '',
          note: item?.desc,
          isLast: i == length - 1,
        );
      });
      if (list.isNotEmpty && list.length > 3)
        widgets.add(
          InkWell(
            onTap: () async {
              context.read<PenerimaPesananProvider>().showMore = !p.showMore;
              setState(() {});
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
              child: Center(
                child: Text(
                  'Tampilkan Lebih ${p.showMore ? 'Sedikit' : 'Banyak'}',
                  style: TextStyle(color: Constant.redColor, fontSize: 12),
                ),
              ),
            ),
          ),
        );
      return widgets;
    }

    Widget statusW() {
      if (data?.ParentOrderModel?.status != "PESANAN_DITOLAK")
        return Container(
          color: Color(0xFFFEF9F4),
          padding: EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 20),
          child: Column(
            children: [
              if (data?.timeline?.isNotEmpty ?? false) ...[
                Container(
                  color: Color(0xfffff9f4),
                  child: Column(children: status()),
                ),
              ] else ...[
                SizedBox(
                  child: Center(
                    child: Text(
                      'Timeline Kosong',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      return SizedBox();
    }

    Widget _buildInfoRow(String label, String value, {bool isBold = false}) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 13,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isBold ? FontWeight.w600 : FontWeight.w500,
                  color: Colors.black87,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.end,
              ),
            ),
          ],
        ),
      );
    }

    Widget _buildStatusRow(String status) {
      Color baseColor = Constant.statusColor(status);
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Status Pesanan',
              style: TextStyle(
                color: Colors.black54,
                fontSize: 13,
                fontWeight: FontWeight.w400,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: baseColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                status.replaceAll('_', ' '),
                style: TextStyle(
                  color: baseColor == Colors.black ? Colors.grey : baseColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      );
    }

    Widget _buildSectionCard({required String title, required Widget child, Widget? trailing}) {
      return Container(
        margin: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 16,
              spreadRadius: 0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                      letterSpacing: 0.2,
                    ),
                  ),
                  if (trailing != null) trailing,
                ],
              ),
              const SizedBox(height: 20),
              child,
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7), // Apple style background
      appBar: CustomAppBar.appBar(
        context,
        'Detail Pesanan',
        color: Colors.white,
        isCenter: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Colors.black87),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            statusW(),
            const SizedBox(height: 16),
            
            // ORDER INFO SECTION
            _buildSectionCard(
              title: 'Informasi Pesanan',
              child: Column(
                children: [
                  _buildStatusRow(data?.ParentOrderModel?.status ?? '-'),
                  _buildInfoRow('No Order', data?.ParentOrderModel?.nomorOrder ?? '-', isBold: true),
                  _buildInfoRow('Tanggal Order', data?.ParentOrderModel?.Created ?? '-'),
                  _buildInfoRow('Nama Seller', data?.ParentOrderModel?.SellerNama ?? '-'),
                  _buildInfoRow('Alamat Seller', data?.ParentOrderModel?.alamat ?? '-'),
                  _buildInfoRow('Nama Penerima', data?.ParentOrderModel?.nama ?? '-'),
                  _buildInfoRow('PIC (Kontak Sales)', data?.ParentOrderModel?.telp ?? '-'),
                  _buildInfoRow('Estimasi Pengiriman', '${data?.ParentOrderModel?.estPengiriman != "0000-00-00" ? DateFormat('d MMMM yyyy').format(DateTime.parse(data?.ParentOrderModel?.estPengiriman ?? "0000-00-00")) : ''} - ${data?.ParentOrderModel?.estPengiriman2 != "0000-00-00" ? DateFormat('d MMMM yyyy').format(DateTime.parse(data?.ParentOrderModel?.estPengiriman2 ?? "0000-00-00")) : ''}'),
                ],
              ),
            ),

            // PRODUCT INFO SECTION
            _buildSectionCard(
              title: 'Terima Barang',
              trailing: TextButton(
                onPressed: () {
                  setState(() {
                    for (int i = 0; i < checks.length; i++) {
                      checks[i] = true;
                    }
                  });
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Tandai Semua',
                  style: TextStyle(
                    color: (checks.contains(false)
                        ? Constant.primaryColor
                        : Colors.grey),
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...showListItems(),
                  if ((data?.detail?.length ?? 0) > 1)
                    Center(
                      child: TextButton(
                        onPressed: () {
                          setState(() {
                            isExpanded = !isExpanded;
                          });
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              isExpanded ? 'Tutup Tampilan' : 'Tampilkan Produk Lainnya',
                              style: TextStyle(color: Constant.primaryColor, fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                              color: Constant.primaryColor,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // SHIPPING INFO SECTION
            _buildSectionCard(
              title: 'Info Pengiriman',
              child: Column(
                children: [
                  _buildInfoRow('PIC Penerima', buyerName, isBold: true),
                  _buildInfoRow('Alamat Pengiriman', '${data?.ParentOrderModel?.telp}\n${data?.ParentOrderModel?.alamat ?? '-'}'),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: buildBottomBar(),
    );
  }

  Widget buildBottomBar() {
    final ttdPesananBuyer = data?.ParentOrderModel?.ttdPesananBuyer != null;
    final ttdPesananSeller = data?.ParentOrderModel?.ttdPesananSeller != null;
    final ttdSuratJalanSeller =
        data?.ParentOrderModel?.ttdSuratjalanSeller != null;
    final ttdSuratJalanPenerima =
        data?.ParentOrderModel?.ttdSuratjalanPenerima != null;
    final lampiran = data?.ParentOrderModel?.lampiran != null;
    final status = data?.ParentOrderModel?.status ?? '';

    PENERIMA_TYPE penerimaType = PENERIMA_TYPE.NONE;
    if (status == 'PESANAN_DIKIRIM' &&
        ttdSuratJalanSeller &&
        !ttdSuratJalanPenerima &&
        !checks.contains(false)) {
      print('SIKLUS: 8');
      penerimaType = PENERIMA_TYPE.SURAT_JALAN;
    } else if (status == 'PESANAN_TELAH_DITERIMA' &&
        ttdSuratJalanSeller &&
        ttdSuratJalanPenerima) {
      print('SIKLUS: 9');
      penerimaType = PENERIMA_TYPE.CETAK_SURAT;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Container(
              height: 52,
              width: 52,
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.red.shade100, width: 1.5),
              ),
              child: IconButton(
                onPressed: () {
                  CusNav.nPush(
                    context,
                    ChatPersonView(
                      id: data?.ParentOrderModel?.SellerID ?? '0',
                      sellerName: data?.ParentOrderModel?.nama ?? '-',
                    ),
                  );
                },
                icon: SvgPicture.asset(
                  Assets.svgsIcChat,
                  color: Constant.primaryColor,
                  width: 22,
                  height: 22,
                ),
                padding: EdgeInsets.zero,
                splashRadius: 24,
              ),
            ),
            if (penerimaType != PENERIMA_TYPE.NONE) ...[
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: const LinearGradient(
                      colors: [Color(0xFFE53935), Color(0xFFC62828)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () async {
                      final p = context.read<PenerimaPesananProvider>();
                      final pdf = await p.getPdf(
                        parent_id: data?.ParentOrderModel?.ID ?? '',
                      );

                      if (penerimaType == PENERIMA_TYPE.SURAT_JALAN) {
                        CusNav.nPush(
                          context,
                          TtdSuratPerjalananView(
                            name: '${data?.ParentOrderModel?.nomorOrder?.replaceAll('/', '_')}_surat_jalan',
                            pdfUrl: pdf.toString(),
                            noOrder: data?.ParentOrderModel?.nomorOrder ?? '',
                            parentId: data?.ParentOrderModel?.ID ?? '',
                          ),
                        );
                      } else {
                        CusNav.nPush(
                          context,
                          CetakSuratView(
                            pdfUrl: pdf.toString(),
                            title: 'Cetak Surat Jalan',
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        penerimaType.icon!,
                        const SizedBox(width: 8),
                        Text(
                          penerimaType.title!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String formatCurrency(String amount) {
    // Mengonversi string ke integer
    int value = int.parse(amount);

    // Membuat format untuk Rupiah
    final formatCurrency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );

    // Mengonversi integer ke format mata uang
    return formatCurrency.format(value);
  }
}

enum PENERIMA_TYPE {
  CETAK_SURAT(
    "Cetak Surat Jalan",
    Icon(Icons.print_outlined, color: Colors.white),
  ),
  SURAT_JALAN("TTD Surat Jalan", Icon(Icons.check, color: Colors.white)),
  NONE(null, null);

  final String? title;
  final Icon? icon;

  const PENERIMA_TYPE(this.title, this.icon);
}
