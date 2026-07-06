import 'package:flutter/material.dart';
import 'package:mspeed/common/base/base_state.dart';
import 'package:mspeed/common/component/custom_appbar.dart';
import 'package:mspeed/common/helper/Constant.dart';
import 'package:mspeed/src/admin/transaksi/model/dpp_admin_model.dart';
import 'package:mspeed/src/admin/transaksi/provider/transaction_admin_provider.dart';
import 'package:mspeed/utils/Utils.dart';
import 'package:provider/provider.dart';

class DataDppAdminView extends StatefulWidget {
  const DataDppAdminView({super.key});

  @override
  State<DataDppAdminView> createState() => _DataDppAdminViewState();
}

class _DataDppAdminViewState extends BaseState<DataDppAdminView> {
  @override
  void initState() {
    super.initState();
    refresh();
    final p = context.read<TransactionAdminProvider>();
    p.searchC.clear();
  }

  DppAdminModel data = DppAdminModel();

  void refresh({String q = ''}) {
    context
        .read<TransactionAdminProvider>()
        .fetchList(withLoading: true, search: q);
  }

  @override
  Widget build(BuildContext context) {
    data = context.watch<TransactionAdminProvider>().dpp;

    PreferredSizeWidget appBar() {
      return CustomAppBar.appBar(
        context,
        'Data DPP',
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
        // action: [
        //   InkWell(
        //     onTap: () {
        //       refresh();
        //     },
        //     child: Container(
        //       margin: EdgeInsets.symmetric(horizontal: 8),
        //       padding: EdgeInsets.all(4),
        //       decoration: BoxDecoration(
        //         shape: BoxShape.circle,
        //         color: Color(0xffED1C24),
        //       ),
        //       child: Icon(
        //         Icons.restart_alt,
        //         size: 32,
        //         color: Colors.white,
        //       ),
        //     ),
        //   )
        // ],
      );
    }

    final searchC = context.read<TransactionAdminProvider>().searchC;
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
                        // CusNav.nPush(
                        //     context,
                        //     KeuanganPesananDetailView(
                        //       transaction_id: transactions[index]?.ID ?? '0',
                        //     ));
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
                                Flexible(
                                  flex: 1,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Nomor',
                                        style: TextStyle(
                                            color: Constant.grayColor,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w400),
                                      ),
                                      Text(
                                        model?.nomorPermintaan ?? '-',
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400),
                                      ),
                                    ],
                                  ),
                                ),
                                Flexible(
                                  flex: 1,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Sub Jumlah',
                                        style: TextStyle(
                                            color: Constant.grayColor,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w400),
                                      ),
                                      Text(
                                        Utils.thousandSeparator(
                                            int.parse(model?.nilaiPrk
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
                                Flexible(
                                  flex: 1,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Sisa',
                                        style: TextStyle(
                                            color: Constant.grayColor,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w400),
                                      ),
                                      Text(
                                        Utils.thousandSeparator(
                                            int.parse(model?.sisa
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
                                Flexible(
                                  flex: 1,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Status',
                                        style: TextStyle(
                                            color: Constant.grayColor,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w400),
                                      ),
                                      Text(
                                        model?.status == '1'
                                            ? 'Aktif'
                                            : 'Tidak Aktif',
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
