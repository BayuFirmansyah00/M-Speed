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
                "tidak ada data",
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ),
        ];
      }

      final iteration = isExpanded ? length : 1;

      for (int i = 0; i < iteration; i++) {
        list.add(
          Container(
            margin: EdgeInsets.symmetric(vertical: 12),
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Color(0xFFF6F6F6)),
            ),
            child: Row(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: Checkbox(
                    value: checks[i],
                    onChanged: (_) {
                      setState(() {
                        checks[i] = !checks[i];
                      });
                    },
                  ),
                ),
                ImageNetworkWidget(
                  width: 50,
                  height: 50,
                  radius: 12,
                  imageUrl: data?.detail?.elementAt(i)?.foto ?? '',
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data?.detail?.elementAt(i)?.nama ?? '',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      Text(
                        data?.detail?.elementAt(i)?.hargaAkhir != null
                            ? '${data?.detail?.elementAt(i)?.qty ?? '1'} x${formatCurrency(data?.detail?.elementAt(i)?.hargaAkhir ?? '0')}'
                            : '${data?.detail?.elementAt(i)?.qty ?? '1'} x${formatCurrency(data?.detail?.elementAt(i)?.harga ?? '0')}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: Constant.grayColor,
                        ),
                      ),
                      Text(
                        formatCurrency(
                          data?.detail?.elementAt(i)?.hargaAkhir ?? '0',
                        ),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
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
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        SvgPicture.asset(
                          Assets.svgsIcChat,
                          color: Constant.primaryColor,
                          width: 12,
                          height: 12,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Komplain',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: Constant.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  )
                else
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
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Icon(Icons.history, color: Colors.grey, size: 12),
                        SizedBox(width: 4),
                        Text(
                          'Dikomplain',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
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

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar.appBar(
        context,
        'Detail Pesanan',
        color: Colors.white,
        isCenter: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            statusW(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'No Order',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      Text(
                        data?.ParentOrderModel?.nomorOrder ?? '-',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Tanggal Order',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      Text(
                        data?.ParentOrderModel?.Created ?? '-',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  // Row(
                  //   crossAxisAlignment: CrossAxisAlignment.start,
                  //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //   children: [
                  //     Text(
                  //       'Departemen',
                  //       style: TextStyle(
                  //         color: Colors.grey,
                  //         fontSize: 12,
                  //         fontWeight: FontWeight.w400,
                  //       ),
                  //     ),
                  //     Text(
                  //       data?.NamaDepartment ?? '-',
                  //       style: TextStyle(
                  //         fontSize: 14,
                  //         fontWeight: FontWeight.w400,
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  // SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Alamat Pengiriman',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      SizedBox(width: 20),
                      Expanded(
                        child: Text(
                          data?.ParentOrderModel?.alamat ?? '-',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Nama Seller',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      Text(
                        data?.ParentOrderModel?.SellerNama ?? '-',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Alamat Seller',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      SizedBox(width: 20),
                      Expanded(
                        child: Text(
                          data?.ParentOrderModel?.alamat ?? '-',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Nama Penerima',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      Text(
                        data?.ParentOrderModel?.nama ?? '-',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'PIC (Kontak Sales)',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      Text(
                        data?.ParentOrderModel?.telp ?? '-',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Estimasi Tanggal Pengiriman',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      SizedBox(width: 20),
                      Expanded(
                        child: Text(
                          '${data?.ParentOrderModel?.estPengiriman != "0000-00-00" ? DateFormat('d MMMM yyyy').format(DateTime.parse(data?.ParentOrderModel?.estPengiriman ?? "0000-00-00")) : ''} - ${data?.ParentOrderModel?.estPengiriman2 != "0000-00-00" ? DateFormat('d MMMM yyyy').format(DateTime.parse(data?.ParentOrderModel?.estPengiriman2 ?? "0000-00-00")) : ''}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ],
                  ),
                  // SizedBox(height: 16),
                  // Row(
                  //   crossAxisAlignment: CrossAxisAlignment.start,
                  //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //   children: [
                  //     Text(
                  //       'DPP',
                  //       style: TextStyle(
                  //         color: Colors.grey,
                  //         fontSize: 12,
                  //         fontWeight: FontWeight.w400,
                  //       ),
                  //     ),
                  //     SizedBox(width: 20),
                  //     Expanded(
                  //       child: Text(
                  //         '${data?.ParentOrderModel?.nomorDpp ?? ''}${data?.ParentOrderModel?.dpp != null ? ' - ${data?.ParentOrderModel?.dpp}' : ''}',
                  //         style: TextStyle(
                  //           fontSize: 14,
                  //           fontWeight: FontWeight.w400,
                  //         ),
                  //         maxLines: 2,
                  //         overflow: TextOverflow.ellipsis,
                  //         textAlign: TextAlign.end,
                  //       ),
                  //     ),
                  //   ],
                  // ),
                ],
              ),
            ),
            Container(
              color: Color(0xFFF6F6F6),
              height: 8,
              width: double.infinity,
            ),
            // Product Info
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Terima Barang',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            for (int i = 0; i < checks.length; i++) {
                              checks[i] = true;
                            }
                          });
                        },
                        child: Text(
                          'Tandai Semua Diterima',
                          style: TextStyle(
                            color:
                                (checks.contains(false)
                                    ? Constant.primaryColor
                                    : Constant.grayColor),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                  ...showListItems(),
                  Container(
                    color: Color(0xFFF6F6F6),
                    height: 1,
                    width: double.infinity,
                  ),
                  Center(
                    child: TextButton(
                      onPressed: () {
                        setState(() {
                          isExpanded = !isExpanded;
                        });
                      },
                      child: Text(
                        isExpanded
                            ? 'Tutup Tampilan'
                            : 'Tampilkan Produk Lainnya',
                        style: TextStyle(color: Constant.grayColor),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              color: Color(0xFFF6F6F6),
              height: 8,
              width: double.infinity,
            ), // Shipping Info
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Info Pengiriman',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PIC Penerima',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      SizedBox(width: 36),
                      Expanded(
                        child: Text(
                          buyerName,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Alamat Pengiriman',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      SizedBox(width: 36),
                      Expanded(
                        child: Text(
                          '${data?.ParentOrderModel?.telp}\n${data?.ParentOrderModel?.alamat ?? '-'}',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 12),
            Container(
              color: Color(0xFFF6F6F6),
              height: 8,
              width: double.infinity,
            ), // Order Summary
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
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 5,
            blurRadius: 7,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 48,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                CusNav.nPush(
                  context,
                  ChatPersonView(
                    id: data?.ParentOrderModel?.SellerID ?? '0',
                    sellerName: data?.ParentOrderModel?.nama ?? '-',
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.red, width: 2),
                ),
                padding: EdgeInsets.zero,
              ),
              child: Center(
                child: SvgPicture.asset(
                  Assets.svgsIcChat,
                  color: Constant.primaryColor,
                  width: 24,
                  height: 24,
                ),
              ),
            ),
          ),
          if (penerimaType != PENERIMA_TYPE.NONE) ...[
            SizedBox(width: 16),
            Expanded(
              child: SizedBox(
                height: 48, // Same height as chat button
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
                          name:
                              '${data?.ParentOrderModel?.nomorOrder?.replaceAll('/', '_')}_surat_jalan',
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      penerimaType.icon!,
                      SizedBox(width: 8),
                      Text(
                        penerimaType.title!,
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
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
