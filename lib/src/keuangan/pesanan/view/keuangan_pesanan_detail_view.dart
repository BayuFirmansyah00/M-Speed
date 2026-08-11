import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mspeed/common/base/base_state.dart';
import 'package:mspeed/common/component/custom_appbar.dart';
import 'package:mspeed/common/component/custom_button.dart';
import 'package:mspeed/common/component/custom_dialog.dart';
import 'package:mspeed/common/component/custom_image_picker.dart';
import 'package:mspeed/common/component/custom_navigator.dart';
import 'package:mspeed/common/component/custom_textField.dart';
import 'package:mspeed/common/component/image_network_widget.dart';
import 'package:mspeed/common/helper/Constant.dart';
import 'package:mspeed/common/helper/text_editing_formatter.dart';
import 'package:mspeed/common/page/web_view.dart';
import 'package:mspeed/src/buyer/transaction/widget/transaction_status_stepper.dart';
import 'package:mspeed/src/keuangan/pesanan/model/detail_transaksi_keuangan_model.dart';
import 'package:mspeed/src/keuangan/pesanan/provider/keuangan_provider.dart';
import 'package:mspeed/src/keuangan/pesanan/widget/return_receipt_widget.dart';
import 'package:mspeed/utils/Utils.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as path;
import 'package:permission_handler/permission_handler.dart';

class KeuanganPesananDetailView extends StatefulWidget {
  final String transaction_id;

  const KeuanganPesananDetailView({super.key, required this.transaction_id});

  @override
  State<KeuanganPesananDetailView> createState() =>
      _KeuanganPesananDetailViewState();
}

class _KeuanganPesananDetailViewState
    extends BaseState<KeuanganPesananDetailView> {
  // Palet Warna Khas Aplikasi yang Sinkron & Premium
  final Color oceanBlue = const Color(0xFF0096C7);
  final Color orangeAcc = const Color(0xFFFF9800);
  final Color yellowAcc = const Color(0xFFFFC300);
  final Color crimsonRed = const Color(0xFFEA580C);

  @override
  void initState() {
    initData();
    super.initState();
  }

  Future<void> initData() async {
    final prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString(Constant.kSetPrefId) ?? '1';
    context.read<KeuanganProvider>().fetchDetailTransaction(
      transaction_id: widget.transaction_id,
      withLoading: true,
    );
    context.read<KeuanganProvider>().clearData();
    await requestPermission(Permission.manageExternalStorage);
    await requestPermission(Permission.photos);
    await requestPermission(Permission.storage);
  }

  DetailTransaksiKeuanganModelData? data = DetailTransaksiKeuanganModelData();

  void refresh() {
    context.read<KeuanganProvider>().fetchDetailTransaction(
      transaction_id: widget.transaction_id,
      withLoading: true,
    );
  }

  Future<bool> requestPermission(Permission permission) async {
    PermissionStatus status = await permission.request();
    return [
      PermissionStatus.granted,
      PermissionStatus.limited,
    ].contains(status);
  }

  bool isExpanded = false;

  int _safeParse(String? value) {
    if (value == null || value.isEmpty) return 0;
    final cleanValue = value.split('.')[0];
    return int.tryParse(cleanValue) ?? 0;
  }

  String formatCurrency(String amount) {
    int value = _safeParse(amount);
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(value);
  }

  @override
  Widget build(BuildContext context) {
    data = context.watch<KeuanganProvider>().detailTransaksi.data;
    final keuanganP = context.watch<KeuanganProvider>();

    void _lihatLampiranTagihan(BuildContext context) {
      CustomDialog.newDialog(
        context: context,
        titlePadding: EdgeInsets.zero,
        contentPadding: EdgeInsets.symmetric(horizontal: 10),
        title: Row(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                icon: Icon(
                  Icons.arrow_back_outlined,
                  color: Colors.black,
                  size: 20,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
            Text("Lampiran Tagihan", style: Constant.iBlackMedium16),
          ],
        ),
        content: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () async {
                  await keuanganP.fetchLampiranTagihanKeuangan(
                    context,
                    transaction_id: data?.ParentOrderModel?.ID ?? "",
                  );
                  await CusNav.nPush(
                    context,
                    WebViewPage(
                      "Lihat Faktur",
                      (keuanganP.lihatLampiranModel.data?.faktur ?? ""),
                      true,
                    ),
                  );
                },
                child: Text("Lihat Faktur", style: Constant.iBlackMedium13),
              ),
              SizedBox(height: 10),
              InkWell(
                onTap: () async {
                  await keuanganP.fetchLampiranTagihanKeuangan(
                    context,
                    transaction_id: data?.ParentOrderModel?.ID ?? "",
                  );
                  await CusNav.nPush(
                    context,
                    WebViewPage(
                      "Lihat E-Nofa",
                      (keuanganP.lihatLampiranModel.data?.enofa ?? ""),
                      true,
                    ),
                  );
                },
                child: Text("Lihat E-Nofa", style: Constant.iBlackMedium13),
              ),
            ],
          ),
        ),
      );
    }

    void _cetakSurat(BuildContext context) {
      CustomDialog.newDialog(
        context: context,
        titlePadding: EdgeInsets.zero,
        contentPadding: EdgeInsets.symmetric(horizontal: 10),
        title: Row(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                icon: Icon(Icons.close, color: Colors.black, size: 20),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
            Text("Cetak Surat", style: Constant.iBlackMedium16),
          ],
        ),
        content: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () async {
                    await keuanganP.fetchInvoiceKeuangan(
                      context,
                      transaction_id: data?.ParentOrderModel?.ID ?? "",
                    );
                  },
                  child: Text("Cetak Invoice", style: Constant.iBlackMedium13),
                ),
                SizedBox(height: 10),
                InkWell(
                  onTap: () async {
                    await keuanganP.fetchKwitansiKeuangan(
                      context,
                      transaction_id: data?.ParentOrderModel?.ID ?? "",
                    );
                  },
                  child: Text("Cetak Kwitansi", style: Constant.iBlackMedium13),
                ),
                SizedBox(height: 10),
                InkWell(
                  onTap: () async {
                    await keuanganP.fetchPesananKeuangan(
                      context,
                      transaction_id: data?.ParentOrderModel?.ID ?? "",
                    );
                  },
                  child: Text(
                    "Cetak Surat Pesanan",
                    style: Constant.iBlackMedium13,
                  ),
                ),
                SizedBox(height: 10),
                InkWell(
                  onTap: () async {
                    await keuanganP.fetchSuratJalankeuangan(
                      context,
                      transaction_id: data?.ParentOrderModel?.ID ?? "",
                    );
                  },
                  child: Text(
                    "Cetak Surat Jalan",
                    style: Constant.iBlackMedium13,
                  ),
                ),
                SizedBox(height: 10),
                InkWell(
                  onTap: () async {
                    _lihatLampiranTagihan(context);
                  },
                  child: Text(
                    "Lihat Lampiran Tagihan",
                    style: Constant.iBlackMedium13,
                  ),
                ),
                SizedBox(height: 10),
              ],
            ),
          ),
        ),
      );
    }

    void _uploadBukti(BuildContext context, String parentOrderId) {
      CustomDialog.newDialog(
        titlePadding: EdgeInsets.zero,
        contentPadding: EdgeInsets.all(10),
        context: context,
        title: Row(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                icon: Icon(Icons.close, color: Colors.black, size: 24),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
            SizedBox(width: 20),
            Text("Upload Bukti Pembayaran", style: Constant.blackBold13),
          ],
        ),
        content: StatefulBuilder(
          builder: (context, state) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomTextField.borderTextField(
                  controller: keuanganP.uploadC,
                  required: false,
                  labelText: "Upload Bukti Bayar",
                  readOnly: true,
                  suffixIcon: Icon(Icons.cloud_upload, color: Colors.grey),
                  hintText:
                      keuanganP.attachC.text != ""
                          ? keuanganP.attachC.text
                          : "Upload",
                  textInputType: TextInputType.number,
                  textCapitalization: TextCapitalization.words,
                  focusNode: keuanganP.uploadNode,
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    ThousandsSeparatorInputFormatter(),
                  ],
                  onTap: () async {
                    String fileName;
                    final file = await CustomImagePicker.cameraOrGallery(
                      context,
                    );
                    FocusManager.instance.primaryFocus?.unfocus();
                    if (file != null) {
                      fileName = path.basename(file.path);
                      keuanganP.attachC.text = fileName;
                      keuanganP.imageAttachment = file;
                      state(() {});
                      setState(() {});
                    }
                  },
                ),
                SizedBox(height: 20),
                CustomButton.mainButton(
                  "Simpan",
                  borderRadius: BorderRadius.circular(10),
                  () async {
                    await keuanganP.sendBuktiBayar(
                      parent_order_id: parentOrderId,
                      image: keuanganP.imageAttachment!,
                    );
                    await Utils.showSuccess(msg: "Berhasil Upload Pembayaran");
                    initData();
                    await CusNav.nPop(context);
                  },
                ),
              ],
            );
          },
        ),
      );
    }

    void showKembalikanKwitansiDialog(BuildContext context) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: ReturnReceiptWidget(
              onSave: () async {
                final success = await keuanganP.kembalikanKwitansi(
                  parentOrderId: data?.ParentOrderModel?.ID ?? '',
                );

                if (success) {
                  await Utils.showSuccess(msg: "Berhasil Kembalikan Tagihan!");
                  await context.read<KeuanganProvider>().fetchDetailTransaction(
                    transaction_id: widget.transaction_id,
                    withLoading: true,
                  );
                } else {
                  return;
                }
                Navigator.of(context).pop();
              },
            ),
          );
        },
      );
    }

    Widget _buildBottomBar() {
      final isSiapTagih = data?.timeline?.last?.label == 'Siap Tagih';
      final isNotTelahDibayar = data?.ParentOrderModel?.status != "TELAH_DIBAYAR";

      return Container(
        padding: const EdgeInsets.all(16.0),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xffE2E4E9), width: 1)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  if (isSiapTagih) ...[
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          showKembalikanKwitansiDialog(context);
                        },
                        icon: const Icon(Icons.close_rounded, size: 18),
                        label: const Text('Kembalikan Kwitansi'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Constant.primaryColor,
                          side: BorderSide(
                            color: Constant.primaryColor,
                            width: 1.5,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _cetakSurat(context);
                      },
                      icon: const Icon(Icons.print_outlined, size: 18),
                      label: const Text('Cetak Surat'),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: const Color(0xFF1ABC62),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              if (isSiapTagih && isNotTelahDibayar) ...[
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () async {
                    _uploadBukti(context, data?.ParentOrderModel?.ID ?? "");
                  },
                  icon: const Icon(Icons.check_rounded, size: 18),
                  label: const Text('Terima Tagihan'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Constant.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xffF5F6FA),
      appBar: CustomAppBar.appBar(
        context,
        'Detail Pesanan',
        color: Colors.white,
        isCenter: true,
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: Color(0xff100629),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            size: 22,
            color: Color(0xff100629),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body:
          data == null
              ? Center(
                child: CircularProgressIndicator(color: Constant.primaryColor),
              )
              : RefreshIndicator(
                onRefresh: () async {
                  await initData();
                },
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTimelineCard(data!),
                      const SizedBox(height: 14),
                      _buildSummaryCard(data!),
                      const SizedBox(height: 14),
                      _buildShippingCard(data!),
                      const SizedBox(height: 14),
                      _buildProductCard(data!),
                      const SizedBox(height: 14),
                      _buildPaymentSummaryCard(data!),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
      bottomNavigationBar:
          data != null
              ? _buildBottomBar()
              : const SizedBox.shrink(),
    );
  }

  // --- KUMPULAN WIDGET CARD --- //

  Widget _buildCardBase({
    required String title,
    required IconData icon,
    required Color iconColor,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xffE2E4E9), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(14.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 16, color: iconColor),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: Color(0xff100629),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xffF0F0F0)),
          Padding(padding: const EdgeInsets.all(16.0), child: child),
        ],
      ),
    );
  }

  Widget _buildTimelineCard(DetailTransaksiKeuanganModelData data) {
    final list = data.timeline ?? [];
    if (list.isEmpty) return const SizedBox.shrink();
    final isShowMore = context.read<KeuanganProvider>().showMore;
    final length = isShowMore ? list.length : 3;
    final displayLength = length > list.length ? list.length : length;

    return _buildCardBase(
      title: 'Status Pesanan',
      icon: Icons.timeline_rounded,
      iconColor: oceanBlue,
      child: Column(
        children: [
          ...List.generate(displayLength, (i) {
            final item = list[i];
            return TransactionStatusStepper(
              title: item?.label ?? '',
              date: item?.time ?? '',
              note: item?.desc,
              isLast: i == displayLength - 1,
            );
          }),
          if (list.length > 3)
            TextButton.icon(
              onPressed: () {
                context.read<KeuanganProvider>().showMore = !isShowMore;
                setState(() {});
              },
              icon: Icon(
                isShowMore ? Icons.expand_less : Icons.expand_more,
                color: Constant.primaryColor,
                size: 18,
              ),
              label: Text(
                'Tampilkan Lebih ${isShowMore ? 'Sedikit' : 'Banyak'}',
                style: TextStyle(
                  color: Constant.primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(DetailTransaksiKeuanganModelData data) {
    final statusText = (data.ParentOrderModel?.status ?? "-").replaceAll(
      '_',
      ' ',
    );
    final statusColor = Constant.statusColor(
      data.ParentOrderModel?.status ?? "-",
    );

    return _buildCardBase(
      title: 'Ringkasan Order',
      icon: Icons.receipt_long_rounded,
      iconColor: oceanBlue,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Status Pesanan',
                style: TextStyle(color: Color(0xff8A93A3), fontSize: 12),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    color:
                        statusColor == Colors.black ? Colors.grey : statusColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          _buildDivider(),
          _buildInfoRow('No Order', data.ParentOrderModel?.nomorOrder ?? '-'),
          _buildDivider(),
          _buildInfoRow(
            'Tanggal Order',
            Utils.convertDateddMMMMyyyyHHmm(
              data.ParentOrderModel?.Created ?? '-',
            ),
          ),
          _buildDivider(),
          _buildInfoRow(
            'Rekening',
            '${(data.ParentOrderModel?.Rekening ?? '').replaceAll("-", "")} (${data.ParentOrderModel?.bank ?? ''})\n${data.ParentOrderModel?.anRek ?? ''}',
          ),
          _buildDivider(),
          _buildInfoRow(
            'Nama Seller',
            data.ParentOrderModel?.SellerNama ?? '-',
          ),
          _buildDivider(),
          _buildInfoRow(
            'Estimasi Pengiriman',
            '${Utils.convertDateddMMMMyyyy(data.ParentOrderModel?.estPengiriman ?? '-')} s/d ${Utils.convertDateddMMMMyyyy(data.ParentOrderModel?.estPengiriman2 ?? '-')}',
          ),
          _buildDivider(),
          _buildInfoRow('DPP', data.ParentOrderModel?.tglTtdSuratJalan ?? '-'),
        ],
      ),
    );
  }

  Widget _buildShippingCard(DetailTransaksiKeuanganModelData data) {
    return _buildCardBase(
      title: 'Informasi Pengiriman',
      icon: Icons.local_shipping_rounded,
      iconColor: orangeAcc,
      child: Column(
        children: [
          _buildInfoRow('PIC Penerima', data.ParentOrderModel?.nama ?? '-'),
          _buildDivider(),
          _buildInfoRow(
            'Alamat Pengiriman',
            '${data.ParentOrderModel?.alamat ?? '-'}\n${data.ParentOrderModel?.telp ?? ''}',
            valueMaxLines: 4,
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(DetailTransaksiKeuanganModelData data) {
    final detailList = data.detail ?? [];
    final length = detailList.length;

    return _buildCardBase(
      title: 'Detail Produk',
      icon: Icons.shopping_bag_rounded,
      iconColor: yellowAcc,
      child:
          length == 0
              ? const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(
                  child: Text(
                    "Tidak ada data produk",
                    style: TextStyle(color: Color(0xff8A93A3), fontSize: 13),
                  ),
                ),
              )
              : Column(
                children: [
                  ...List.generate(isExpanded ? length : (length > 0 ? 1 : 0), (
                    index,
                  ) {
                    final item = detailList[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xffE2E4E9)),
                        color: const Color(0xffF8F9FA),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: ImageNetworkWidget(
                              width: 60,
                              height: 60,
                              radius: 8,
                              imageUrl: item?.foto ?? '',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item?.nama ?? '-',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xff100629),
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '${item?.qty ?? '1'} x ${formatCurrency(item?.hargaAkhir ?? '0')}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xff8A93A3),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text(
                                'Total Harga',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Color(0xff8A93A3),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                formatCurrency(item?.hargaAkhir ?? '0'),
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: crimsonRed,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),
                  if (length > 1)
                    TextButton.icon(
                      onPressed: () => setState(() => isExpanded = !isExpanded),
                      icon: Icon(
                        isExpanded ? Icons.expand_less : Icons.expand_more,
                        color: oceanBlue,
                        size: 18,
                      ),
                      label: Text(
                        isExpanded
                            ? 'Tutup Tampilan'
                            : 'Tampilkan ${length - 1} Produk Lainnya',
                        style: TextStyle(
                          color: oceanBlue,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                ],
              ),
    );
  }

  Widget _buildPaymentSummaryCard(DetailTransaksiKeuanganModelData data) {
    return _buildCardBase(
      title: 'Ringkasan Pembayaran',
      icon: Icons.account_balance_wallet_rounded,
      iconColor: crimsonRed,
      child: Column(
        children: [
          _buildPaymentRow('Subtotal', data.ParentOrderModel?.subtotal),
          const SizedBox(height: 8),
          _buildPaymentRow('Ongkos Kirim', data.ParentOrderModel?.ongkir),
          const SizedBox(height: 8),
          _buildPaymentRow('Pajak', data.ParentOrderModel?.pajak),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: Color(0xffE2E4E9)),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Harga',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: Color(0xff100629),
                ),
              ),
              Text(
                formatCurrency(data.ParentOrderModel?.subtotal ?? '0'),
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: crimsonRed,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- COMPONENT UI BANTUAN --- //

  Widget _buildInfoRow(String label, String value, {int valueMaxLines = 2}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          flex: 4,
          child: Text(
            label,
            style: const TextStyle(color: Color(0xff8A93A3), fontSize: 12),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 6,
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xff100629),
            ),
            maxLines: valueMaxLines,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentRow(String label, String? rawValue) {
    final value = _safeParse(rawValue);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: Color(0xff8A93A3), fontSize: 13),
        ),
        Text(
          'Rp ${Utils.thousandSeparator(value, symbol: '')}',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xff100629),
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Divider(height: 1, color: Color(0xffF0F0F0)),
    );
  }
}
