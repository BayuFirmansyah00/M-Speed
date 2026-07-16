import 'package:flutter/material.dart';
import 'package:mspeed/common/component/custom_navigator.dart';
import 'package:mspeed/common/helper/Constant.dart';
import 'package:mspeed/src/buyer/transaction/provider/transaction_provider.dart';
import 'package:mspeed/src/buyer/transaction/provider/transaction_status.dart';
import 'package:mspeed/src/buyer/transaction/view/detail_transaction_view.dart';
import 'package:mspeed/src/buyer/transaction/widget/order_item_widget.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─── Warna lokal ──────────────────────────────────────────────
const _kBg = Color(0xFFF4F6FB);
const _kPrimary = Color(0xFFE50012);

class NewOrderView extends StatefulWidget {
  const NewOrderView({super.key, required this.status});
  final TransactionStatus status;

  @override
  State<NewOrderView> createState() => _NewOrderViewState();
}

class _NewOrderViewState extends State<NewOrderView> {
  String userId = '';

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getString(Constant.kSetPrefId) ?? '';
    userId = '148'; // TODO: remove hardcode after API fix
    await _refresh();
  }

  Future<void> _refresh() async {
    await context
        .read<TransactionProvider>()
        .fetchTransaction(withLoading: false, status: widget.status.indexStatus);
  }

  @override
  Widget build(BuildContext context) {
    final transaksi = context
        .watch<TransactionProvider>()
        .daftarTransaksi[widget.status.indexStatus - 1];
    final items = transaksi.data ?? [];

    return Scaffold(
      backgroundColor: _kBg,
      body: RefreshIndicator(
        color: _kPrimary,
        strokeWidth: 2.5,
        onRefresh: _refresh,
        child: items.isEmpty
            ? _buildEmpty()
            : ListView.builder(
                padding: const EdgeInsets.only(top: 14, bottom: 120),
                itemCount: items.length,
                itemBuilder: (ctx, i) {
                  return InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => CusNav.nPush(
                      ctx,
                      DetailTransactionView(
                        transaction_id: items[i]?.ID ?? '',
                        seller_id: items[i]?.SellerID ?? '',
                      ),
                    ),
                    child: OrderItemWidget(data: items[i]),
                  );
                },
              ),
      ),
    );
  }

  Widget _buildEmpty() {
    return ListView(
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.55,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEBED),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.receipt_long_rounded,
                  color: _kPrimary,
                  size: 40,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Belum Ada Transaksi',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0D1117),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Transaksi pada status ini\nmasih kosong.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF9AA5B1),
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
