import 'package:flutter/material.dart';
import 'package:mspeed/common/component/custom_appbar.dart';
import 'package:mspeed/common/component/custom_navigator.dart';
import 'package:mspeed/src/admin/transaksi/model/order_admin_model.dart';
import 'package:mspeed/src/admin/transaksi/provider/transaction_admin_provider.dart';
import 'package:mspeed/src/admin/transaksi/view/detail_pesanan_admin_view.dart';
import 'package:mspeed/utils/utils.dart';
import 'package:provider/provider.dart';

class DataOrderAdminView extends StatefulWidget {
  const DataOrderAdminView({super.key});

  @override
  State<DataOrderAdminView> createState() => _DataOrderAdminViewState();
}

class _DataOrderAdminViewState extends State<DataOrderAdminView> {
  // Palet Warna Identitas
  final Color appRed = const Color(0xFFED1C24);
  final Color oceanBlue = const Color(0xFF0096C7);
  final Color orangeAcc = const Color(0xFFFF9800);

  OrderAdminModel data = OrderAdminModel();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final p = context.read<TransactionAdminProvider>();
      p.searchOrderC.clear();
      refresh();
    });
  }

  Future<void> refresh({String q = ''}) async {
    setState(() => _isLoading = true);
    try {
      // Kita matikan withLoading (global blocker) agar UX lebih baik
      await context.read<TransactionAdminProvider>().fetchList2(withLoading: false, search: q);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    data = context.watch<TransactionAdminProvider>().order;
    final searchC = context.read<TransactionAdminProvider>().searchOrderC;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: CustomAppBar.appBar(
        context,
        'Data Order',
        color: Colors.white,
        isCenter: true,
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          _buildSearchBar(searchC),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator(color: appRed))
                : (data.data == null || data.data!.isEmpty)
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        color: appRed,
                        onRefresh: () => refresh(),
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          itemCount: data.data?.length ?? 0,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final model = data.data?[index];
                            return _buildOrderCard(model);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(TextEditingController controller) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: TextField(
          controller: controller,
          onSubmitted: (val) => refresh(q: val),
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: "Cari nomor order...",
            hintStyle: const TextStyle(color: Colors.black45, fontSize: 14),
            prefixIcon: Icon(Icons.search, color: appRed),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined, size: 72, color: orangeAcc.withOpacity(0.5)),
          const SizedBox(height: 16),
          const Text(
            "Belum ada pesanan",
            style: TextStyle(fontSize: 16, color: Colors.black54, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(dynamic model) {
    final totalOrderStr = model?.total ?? '0';
    final totalOrder = int.tryParse(totalOrderStr.split('.')[0]) ?? 0;

    return InkWell(
      onTap: () {
        CusNav.nPush(context, DetailPesananAdminView(transaction_id: model?.ID ?? ""));
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ],
          border: Border(left: BorderSide(color: oceanBlue, width: 4)),
        ),
        child: Column(
          children: [
            // Baris Atas: No Order & Total (Informasi paling penting)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Nomor Order', style: TextStyle(color: Colors.black54, fontSize: 11)),
                      const SizedBox(height: 2),
                      Text(
                        model?.nomorOrder ?? '-',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('Total Harga', style: TextStyle(color: Colors.black54, fontSize: 11)),
                    const SizedBox(height: 2),
                    Text(
                      'Rp ${Utils.thousandSeparator(totalOrder, symbol: '')}',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: appRed),
                    ),
                  ],
                ),
              ],
            ),
            
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(height: 1, color: Color(0xFFEEEEEE)),
            ),

            // Baris Bawah: Buyer, Seller, Tanggal
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: _buildInfoColumn(Icons.person_outline, 'Buyer / Penerima', '${model?.BuyerName ?? '-'}\n${model?.PenerimaName ?? '-'}'),
                ),
                Expanded(
                  flex: 2,
                  child: _buildInfoColumn(Icons.storefront_outlined, 'Seller', model?.SellerName ?? '-'),
                ),
                Expanded(
                  flex: 1,
                  child: _buildInfoColumn(Icons.calendar_today_outlined, 'Tanggal', model?.tglTtdSuratPesanan ?? '-'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoColumn(IconData icon, String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 12, color: orangeAcc),
            const SizedBox(width: 4),
            Text(title, style: const TextStyle(color: Colors.black54, fontSize: 11)),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.black87),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}