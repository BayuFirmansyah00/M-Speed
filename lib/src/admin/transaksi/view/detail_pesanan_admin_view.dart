import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mspeed/common/base/base_state.dart';
import 'package:mspeed/common/component/custom_appbar.dart';
import 'package:mspeed/common/component/image_network_widget.dart';
import 'package:mspeed/common/helper/constant.dart';
import 'package:mspeed/src/buyer/transaction/model/detail_tansaction_buyer_model.dart';
import 'package:mspeed/src/admin/transaksi/provider/transaction_admin_provider.dart';
import 'package:mspeed/src/buyer/transaction/provider/transaction_provider.dart';
import 'package:mspeed/utils/utils.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DetailPesananAdminView extends StatefulWidget {
  const DetailPesananAdminView({super.key, required this.transaction_id});

  final String transaction_id;

  @override
  State<DetailPesananAdminView> createState() => _DetailPesananAdminViewState();
}

class _DetailPesananAdminViewState extends BaseState<DetailPesananAdminView> {
  // Palet Warna Khas Aplikasi yang Sinkron & Premium
  final Color oceanBlue = const Color(0xFF0096C7);
  final Color orangeAcc = const Color(0xFFFF9800);
  final Color yellowAcc = const Color(0xFFFFC300);
  final Color crimsonRed = const Color(0xFFEA580C);

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
      backgroundColor: const Color(0xffF5F6FA),
      appBar: CustomAppBar.appBar(
        context,
        'Detail Pesanan',
        color: Colors.white,
        isCenter: true,
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xff100629)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, size: 22, color: Color(0xff100629)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: data == null
          ? Center(child: CircularProgressIndicator(color: Constant.primaryColor))
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSummaryCard(data),
                  const SizedBox(height: 14),
                  _buildShippingCard(data),
                  const SizedBox(height: 14),
                  _buildProductCard(data),
                  const SizedBox(height: 14),
                  _buildPaymentSummaryCard(data),
                  const SizedBox(height: 32),
                ],
              ),
            ),
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
              child: Center(child: Text("Tidak ada data produk", style: TextStyle(color: Color(0xff8A93A3), fontSize: 13))),
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
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xff100629)),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '${item?.qty ?? '1'} x ${formatCurrency(item?.harga ?? '0')}',
                                style: const TextStyle(fontSize: 12, color: Color(0xff8A93A3)),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text('Total', style: TextStyle(fontSize: 10, color: Color(0xff8A93A3))),
                            const SizedBox(height: 4),
                            Text(
                              formatCurrency(item?.hargaAkhir ?? '0'),
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: crimsonRed),
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
                    icon: Icon(isExpanded ? Icons.expand_less : Icons.expand_more, color: oceanBlue, size: 18),
                    label: Text(
                      isExpanded ? 'Tutup Tampilan' : 'Tampilkan ${length - 1} Produk Lainnya',
                      style: TextStyle(color: oceanBlue, fontWeight: FontWeight.bold, fontSize: 13),
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
              const Text('Total Harga', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Color(0xff100629))),
              Text(
                formatCurrency(data.ParentOrderModel?.total ?? '0'),
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: crimsonRed),
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
        border: Border.all(color: const Color(0xffE2E4E9), width: 1),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 2))
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
                Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Color(0xff100629))),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xffF0F0F0)),
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
          child: Text(label, style: const TextStyle(color: Color(0xff8A93A3), fontSize: 12)),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 3,
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xff100629)),
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
        Text(label, style: const TextStyle(color: Color(0xff8A93A3), fontSize: 13)),
        Text(
          'Rp ${Utils.thousandSeparator(value, symbol: '')}',
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xff100629)),
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

  // --- BOTTOM NAV BAR (TOLAK / TERIMA) --- //

  Widget _buildBottomBar(DetailTransaksiBuyerModelData data) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(top: BorderSide(color: Color(0xffE2E4E9), width: 1)),
      ),
      child: SafeArea(
        child: Consumer<TransactionAdminProvider>(
          builder: (context, p, _) {
            return Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      if (data.ParentOrderModel?.ID != null) {
                        p.verifyOrder(context, data.ParentOrderModel!.ID!);
                      }
                    },
                    icon: const Icon(Icons.verified_user_rounded, size: 18),
                    label: const Text('Verifikasi'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Constant.primaryColor,
                      side: BorderSide(color: Constant.primaryColor, width: 1.5),
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
                      if (data.ParentOrderModel?.ID != null) {
                        p.payOrder(context, data.ParentOrderModel!.ID!);
                      }
                    },
                    icon: const Icon(Icons.payment_rounded, size: 18),
                    label: const Text('Bayar'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: const Color(0xFF1ABC62),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ),
                ),
              ],
            );
          }
        ),
      ),
    );
  }
}