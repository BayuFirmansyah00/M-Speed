import 'package:flutter/material.dart';
import 'package:mspeed/common/base/base_state.dart';
import 'package:mspeed/common/component/custom_appbar.dart';
import 'package:mspeed/common/component/custom_navigator.dart';
import 'package:mspeed/common/helper/Constant.dart';

import 'package:mspeed/src/buyer/transaction/provider/transaction_status.dart';
import 'package:mspeed/src/seller/pesanan/model/pesanan_seller_model.dart';
import 'package:mspeed/src/seller/pesanan/provider/seller_pesanan_provider.dart';
import 'package:mspeed/src/seller/pesanan/view/pesanan_seller_detail_view.dart';
import 'package:mspeed/src/seller/pesanan/view/pesanan_seller_item_widget.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PesananSellerView extends StatefulWidget {
  const PesananSellerView({super.key});

  @override
  State<PesananSellerView> createState() => _PesananSellerViewState();
}

class _PesananSellerViewState extends BaseState<PesananSellerView> {
  String userId = "", userName = "";

  @override
  void initState() {
    initData();
    super.initState();
  }

  Future<void> initData() async {
    final prefs = await SharedPreferences.getInstance();
    userId = await prefs.getString(Constant.kSetPrefId) ?? "";
    userName = await prefs.getString(Constant.kSetPrefFirstName) ?? "";
    final p = context.read<SellerPesananProvider>();
    await p.fetchListPesanan(withLoading: false, sellerId: userId);
    listPesanan = p.pesananSellerModel.data ?? [];
    setState(() {});
  }

  List<PesananSellerModelData?> listPesanan = [];
  final searchController = TextEditingController();

  refresh() async {
    final p = context.read<SellerPesananProvider>();
    await p.fetchListPesanan(withLoading: true, sellerId: userId);
    listPesanan = p.pesananSellerModel.data ?? [];
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<SellerPesananProvider>();
    if (listPesanan.isEmpty && searchController.text.isEmpty) {
      listPesanan = p.pesananSellerModel.data ?? [];
    }

    PreferredSizeWidget appBar() {
      return CustomAppBar.appBar(
        context,
        'Pesanan',
        isLeading: false,
        titleSpacing: 24,
        color: Colors.white,
        isCenter: true,
        textStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: appBar(),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 12),
              TextField(
                controller: searchController,
                onChanged: (String value) {
                  setState(() {
                    listPesanan =
                        p.pesananSellerModel.data?.where((e) {
                          return e?.nomorOrder?.toUpperCase().contains(
                                value.toUpperCase(),
                              ) ??
                              false;
                        }).toList() ??
                        [];
                  });
                },
                textInputAction: TextInputAction.search, // This
                decoration: InputDecoration(
                  hintText: 'Cari',
                  hintStyle: TextStyle(color: Color(0xFF6D7588)),
                  prefixIcon: Icon(Icons.search, color: Color(0xFF6D7588)),
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
              SizedBox(height: 12),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    refresh();
                  },
                  child: ListView.builder(
                    itemCount: listPesanan.length,
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () {
                          CusNav.nPush(
                            context,
                            PesananSellerDetailView(
                              transaction_id: listPesanan[index]?.ID ?? "",
                            ),
                          );
                        },
                        child: PesananSellerItemWidget(
                          bgColor:
                              index % 2 == 0 ? Color(0xFFF6F6F6) : Colors.white,
                          orderNumber: listPesanan[index]?.nomorOrder ?? "-",
                          date: listPesanan[index]?.tglTtdSuratPesanan ?? "-",
                          alamat: listPesanan[index]?.alamat ?? "-",
                          totalPesanan: listPesanan[index]?.jum ?? "-",
                          sellerName: "-",
                          status: TransactionStatus.fromString(
                            listPesanan[index]?.status ?? "PESANAN_BARU",
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
