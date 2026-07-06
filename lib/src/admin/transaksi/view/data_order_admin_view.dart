import 'package:flutter/material.dart';
import 'package:mspeed/common/component/custom_appbar.dart';
import 'package:mspeed/common/component/custom_navigator.dart';
import 'package:mspeed/common/helper/Constant.dart';
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
  @override
  void initState() {
    super.initState();
    refresh();
    final p = context.read<TransactionAdminProvider>();
    p.searchOrderC.clear();
  }

  OrderAdminModel data = OrderAdminModel();

  void refresh({String q = ''}) {
    context
        .read<TransactionAdminProvider>()
        .fetchList2(withLoading: true, search: q);
  }

  @override
  Widget build(BuildContext context) {
    data = context.watch<TransactionAdminProvider>().order;

    PreferredSizeWidget appBar() {
      return CustomAppBar.appBar(
        context,
        'Data Order',
        color: Colors.white,
        isCenter: true,
        titleSpacing: 24,
        textStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      );
    }

    final searchC = context.read<TransactionAdminProvider>().searchOrderC;
    return Scaffold(
      appBar: appBar(),
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: () async {
          refresh();
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: searchC,
                onSubmitted: (_) {
                  refresh(q: searchC.text);
                },
                textInputAction: TextInputAction.search, // This
                decoration: InputDecoration(
                  hintText: 'Cari',
                  hintStyle: TextStyle(color: Color(0xFF6D7588)),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Color(0xFF6D7588),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Color(0xFFEEF0F8)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Color(0xFFEEF0F8)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Color(0xFFEEF0F8)),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              SizedBox(
                height: 12,
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: data.data?.length ?? 0,
                  itemBuilder: (context, index) {
                    final model = data.data?[index];

                    return InkWell(
                      onTap: () {
                        CusNav.nPush(
                            context,
                            DetailPesananAdminView(
                              transaction_id: model?.ID ?? "",
                            ));
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 16.0, horizontal: 8),
                        color:
                            index % 2 == 0 ? Color(0xFFF6F6F6) : Colors.white,
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'No order',
                                        style: TextStyle(
                                            color: Constant.grayColor,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w400),
                                      ),
                                      Text(
                                        model?.nomorOrder ?? '-',
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Tanggal',
                                        style: TextStyle(
                                            color: Constant.grayColor,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w400),
                                      ),
                                      Text(
                                        model?.tglTtdSuratPesanan ?? '-',
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Buyer',
                                        style: TextStyle(
                                            color: Constant.grayColor,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w400),
                                      ),
                                      Text(
                                        model?.BuyerName ?? '-',
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Constant.xSizedBox8,
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Penerima',
                                        style: TextStyle(
                                            color: Constant.grayColor,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w400),
                                      ),
                                      Text(
                                        model?.PenerimaName ?? '-',
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Seller',
                                        style: TextStyle(
                                            color: Constant.grayColor,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w400),
                                      ),
                                      Text(
                                        model?.SellerName ?? '-',
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Total',
                                        style: TextStyle(
                                            color: Constant.grayColor,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w400),
                                      ),
                                      Text(
                                        Utils.thousandSeparator(
                                            int.parse(model?.total
                                                    ?.split('.')
                                                    .firstOrNull ??
                                                '0'),
                                            symbol: ''),
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
