import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mspeed/common/base/base_state.dart';
import 'package:mspeed/common/component/custom_appbar.dart';
import 'package:mspeed/common/component/image_network_widget.dart';
import 'package:mspeed/common/helper/Constant.dart';
import 'package:mspeed/src/buyer/transaction/model/detail_tansaction_buyer_model.dart';
import 'package:mspeed/src/buyer/transaction/provider/transaction_provider.dart';
import 'package:mspeed/utils/Utils.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DetailPesananAdminView extends StatefulWidget {
  const DetailPesananAdminView({super.key, required this.transaction_id});

  final String transaction_id;

  @override
  State<DetailPesananAdminView> createState() => _DetailPesananAdminViewState();
}

class _DetailPesananAdminViewState extends BaseState<DetailPesananAdminView> {
  // Palet Warna Khas Aplikasi
  final Color appRed = const Color(0xFFED1C24);
  final Color oceanBlue = const Color(0xFF0096C7);
  final Color orangeAcc = const Color(0xFFFF9800);
  final Color yellowAcc = const Color(0xFFFFC300);

  String userId = "";
  String buyerName = "";
  String buyerPhone = "";
  bool isExpanded = false;

  @override
  void initState() {
    super.initState();
    initData();
  }

  Future<void> initData() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getString(Constant.kSetPrefId) ?? "";
    buyerName = prefs.getString(Constant.kSetPrefFirstName) ?? "";
    buyerPhone = prefs.getString(Constant.kSetPrefPhone) ?? "";

    if (mounted) {
      context.read<TransactionProvider>().fetchDetailTransaction(
            transaction_id: widget.transaction_id,
            withLoading: true,
          );
    }
  }

  // Mencegah crash jika backend mengirim desimal (cth: "10000.00")
  int _safeParse(String? value) {
    if (value == null || value.isEmpty) return 0;
    final cleanValue = value.split('.')[0];
    return int.tryParse(cleanValue) ?? 0;
  }

  String formatCurrency(String amount) {
    int value = _safeParse(amount);
    final formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return formatter.format(value);
  }

  @override
  Widget build(BuildContext context) {
    final data = context.watch<TransactionProvider>().getDetailTransaksi.data;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: CustomAppBar.appBar(
        context,
        'Detail Pesanan',
        color: Colors.white,
        isCenter: true,
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: data == null
          ? Center(child: CircularProgressIndicator(color: appRed))
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSummaryCard(data),
                  const SizedBox(height: 16),
                  _buildShippingCard(data),
                  const SizedBox(height: 16),
                  _buildProductCard(data),
                  const SizedBox(height: 16),
                  _buildPaymentSummaryCard(data),
                  const SizedBox(height: 32),
                ],
              ),
            ),
      bottomNavigationBar: data != null ? _buildBottomBar(data) : const SizedBox.shrink(),
    );
  }

  // --- KUMPULAN WIDGET CARD --- //

  Widget _buildSummaryCard(DetailTransaksiBuyerModelData data) {
    return _buildCardBase(
      title: 'Ringkasan Order',
      icon: Icons.receipt_long_rounded,
      iconColor: oceanBlue,
      child: Column(
        children: [
          _buildInfoRow('No Order', data.ParentOrderModel?.nomorOrder ?? '-'),
          _buildDivider(),
          _buildInfoRow('Tanggal Order', data.ParentOrderModel?.Created ?? '-'),
          _buildDivider(),
          _buildInfoRow('Rekening', data.detail?.firstOrNull?.noRek ?? '-'),
          _buildDivider(),
          _buildInfoRow('Estimasi Pengiriman', data.ParentOrderModel?.estPengiriman ?? '-'),
        ],
      ),
    );
  }

  Widget _buildShippingCard(DetailTransaksiBuyerModelData data) {
    return _buildCardBase(
      title: 'Informasi Pengiriman',
      icon: Icons.local_shipping_rounded,
      iconColor: orangeAcc,
      child: Column(
        children: [
          _buildInfoRow('PIC Penerima', buyerName),
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

  Widget _buildProductCard(DetailTransaksiBuyerModelData data) {
    final detailList = data.detail ?? [];
    final length = detailList.length;

    return _buildCardBase(
      title: 'Detail Produk',
      icon: Icons.shopping_bag_rounded,
      iconColor: yellowAcc,
      child: length == 0
          ? const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: Text("Tidak ada data produk", style: TextStyle(color: Colors.grey))),
            )
          : Column(
              children: [
                ...List.generate(isExpanded ? length : (length > 0 ? 1 : 0), (index) {
                  final item = detailList[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFEEEEEE)),
                      color: const Color(0xFFFAFAFA),
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
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '${item?.qty ?? '1'} x ${formatCurrency(item?.harga ?? '0')}',
                                style: const TextStyle(fontSize: 13, color: Colors.black54),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text('Total', style: TextStyle(fontSize: 11, color: Colors.black54)),
                            const SizedBox(height: 4),
                            Text(
                              formatCurrency(item?.hargaAkhir ?? '0'),
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: appRed),
                            ),
                          ],
                        )
                      ],
                    ),
                  );
                }),
                if (length > 1)
                  TextButton.icon(
                    onPressed: () => setState(() => isExpanded = !isExpanded),
                    icon: Icon(isExpanded ? Icons.expand_less : Icons.expand_more, color: oceanBlue),
                    label: Text(
                      isExpanded ? 'Tutup Tampilan' : 'Tampilkan ${length - 1} Produk Lainnya',
                      style: TextStyle(color: oceanBlue, fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _buildPaymentSummaryCard(DetailTransaksiBuyerModelData data) {
    return _buildCardBase(
      title: 'Ringkasan Pembayaran',
      icon: Icons.account_balance_wallet_rounded,
      iconColor: appRed,
      child: Column(
        children: [
          _buildPaymentRow('Subtotal', data.ParentOrderModel?.subtotal),
          const SizedBox(height: 8),
          _buildPaymentRow('Ongkos Kirim', data.ParentOrderModel?.ongkir),
          const SizedBox(height: 8),
          _buildPaymentRow('Pajak', data.ParentOrderModel?.pajak),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: Color(0xFFEEEEEE)),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Harga', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text(
                formatCurrency(data.ParentOrderModel?.total ?? '0'),
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: appRed),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- KOMPONEN BANTUAN UI --- //

  Widget _buildCardBase({required String title, required IconData icon, required Color iconColor, required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(icon, size: 20, color: iconColor),
                const SizedBox(width: 8),
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87)),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {int valueMaxLines = 2}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          flex: 2,
          child: Text(label, style: const TextStyle(color: Colors.black54, fontSize: 13)),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 3,
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87),
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
        Text(label, style: const TextStyle(color: Colors.black54, fontSize: 14)),
        Text(
          'Rp ${Utils.thousandSeparator(value, symbol: '')}',
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Divider(height: 1, color: Color(0xFFF5F5F5)),
    );
  }

  // --- BOTTOM NAV BAR (TOLAK / TERIMA) --- //

  Widget _buildBottomBar(DetailTransaksiBuyerModelData data) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), spreadRadius: 0, blurRadius: 10, offset: const Offset(0, -4)),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  if (data.ParentOrderModel?.tglTtdSuratPesanan == null) {
                    // Logika awal Anda
                  } else {}
                },
                icon: const Icon(Icons.close_rounded, size: 18),
                label: const Text('Tolak'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: appRed,
                  side: BorderSide(color: appRed, width: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  if (data.ParentOrderModel?.tglTtdSuratPesanan == null) {
                    // Logika awal Anda
                  } else {}
                },
                icon: const Icon(Icons.check_rounded, size: 18),
                label: const Text('Terima'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: const Color(0xFF1ABC62), // Hijau konfirmasi yang standar & aman
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}