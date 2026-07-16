import 'package:flutter/material.dart';
import 'package:mspeed/common/component/custom_navigator.dart';
import 'package:mspeed/common/helper/Constant.dart';
import 'package:mspeed/src/buyer/transaction/provider/transaction_provider.dart';
import 'package:mspeed/src/buyer/transaction/provider/transaction_status.dart';
import 'package:mspeed/src/buyer/transaction/view/detail_transaction_view.dart';
import 'package:mspeed/src/buyer/transaction/widget/order_item_widget.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NewOrderView extends StatefulWidget {
  const NewOrderView({super.key, required this.status});

  final TransactionStatus status;

  @override
  State<NewOrderView> createState() => _NewOrderViewState();
}

class _NewOrderViewState extends State<NewOrderView> {
  String userId = "";

  @override
  void initState() {
    initData();
    super.initState();
  }

  Future<void> initData() async {
    final prefs = await SharedPreferences.getInstance();
    userId = await prefs.getString(Constant.kSetPrefId) ?? "";
    userId = "148";

    await refresh();
  }

  Future<void> refresh() async {
    await context.read<TransactionProvider>().fetchTransaction(
        withLoading: false, status: widget.status.indexStatus);
  }

  @override
  Widget build(BuildContext context) {
    final transaksi = context
        .watch<TransactionProvider>()
        .daftarTransaksi[widget.status.indexStatus - 1];

    return Scaffold(
      backgroundColor: Color(0xFFF6F6F6),
      body: RefreshIndicator(
        onRefresh: refresh,
        child: ListView.builder(
          itemCount: transaksi.data?.length ?? 0,
          itemBuilder: (context, index) {
            return InkWell(
                onTap: () {
                  CusNav.nPush(
                      context,
                      DetailTransactionView(
                          transaction_id: transaksi.data?[index]?.ID ?? '',
                          seller_id: transaksi.data?[index]?.SellerID ?? ''
                      ));
                },
                child: OrderItemWidget(data: transaksi.data?[index]));
          },
        ),
      ),
    );
  }
}
