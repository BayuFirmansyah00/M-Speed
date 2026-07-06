import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:mspeed/common/base/base_state.dart';
import 'package:mspeed/common/helper/Constant.dart';
import 'package:mspeed/src/buyer/transaction/provider/transaction_status.dart';
import 'package:mspeed/src/buyer/transaction/view/new_order_view.dart';

class TransactionListView extends StatefulWidget {
  final int? initialRoute;
  const TransactionListView({super.key, this.initialRoute});

  @override
  State<TransactionListView> createState() => _TransactionListViewState();
}

class _TransactionListViewState extends BaseState<TransactionListView> with TickerProviderStateMixin {
  late TabController _tabController;
  int _initialRoute = 0;
  // Default route

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _initialRoute = widget.initialRoute ?? 0;

    // Otomatis pindah ke tab yang ke 2 jika dari halaman B
    if (_initialRoute == 1) {
      _tabController.animateTo(1);
    }

    // Otomatis pindah ke tab yang ke 3 jika dari halaman C
    else if (_initialRoute == 2) {
      _tabController.animateTo(2);
    }
    else if (_initialRoute == 3) {
      _tabController.animateTo(3);
    }
    else if (_initialRoute == 4) {
      _tabController.animateTo(4);
    }
    else if (_initialRoute == 5) {
      _tabController.animateTo(5);
    }
  }
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 6,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          bottom: TabBar(
            controller: _tabController,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            indicatorSize: TabBarIndicatorSize.label,
            tabs: [
              Tab(
                child: AutoSizeText(
                  "Pesanan Baru",
                  style: TextStyle(fontWeight: FontWeight.w400),
                  maxLines: 1,
                  minFontSize: 8,
                ),
              ),
              Tab(
                child: AutoSizeText(
                  "Pesanan Diterima",
                  style: TextStyle(fontWeight: FontWeight.w400),
                  maxLines: 1,
                  minFontSize: 8,
                ),
              ),
              Tab(
                child: AutoSizeText(
                  "Pesanan Dikirim",
                  style: TextStyle(fontWeight: FontWeight.w400),
                  maxLines: 1,
                  minFontSize: 8,
                ),
              ),
              Tab(
                child: AutoSizeText(
                  "Barang Diterima",
                  style: TextStyle(fontWeight: FontWeight.w400),
                  maxLines: 1,
                  minFontSize: 8,
                ),
              ),
              Tab(
                child: AutoSizeText(
                  "Proses Pembayaran",
                  style: TextStyle(fontWeight: FontWeight.w400),
                  maxLines: 1,
                  minFontSize: 8,
                ),
              ),
              Tab(
                child: AutoSizeText(
                  "Telah Dibayar",
                  style: TextStyle(fontWeight: FontWeight.w400),
                  maxLines: 1,
                  minFontSize: 8,
                ),
              ),
            ],
          ),
          leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(Icons.arrow_back)),
          centerTitle: true,
          title: Text(
            'Daftar Transaksi',
            style: TextStyle(
              fontWeight: Constant.semibold,
              color: Colors.black,
              fontSize: 17,
            ),
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            NewOrderView(status: TransactionStatus.PESANAN_BARU),
            NewOrderView(status: TransactionStatus.PESANAN_DITERIMA),
            NewOrderView(status: TransactionStatus.PESANAN_DIKIRIM),
            NewOrderView(status: TransactionStatus.BARANG_DITERIMA),
            NewOrderView(status: TransactionStatus.PROSES_PEMBAYARAN),
            NewOrderView(status: TransactionStatus.TELAH_DIBAYAR),
          ],
        ),
      ),
    );
  }
}
