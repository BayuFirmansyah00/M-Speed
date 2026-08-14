import 'package:flutter/material.dart';
import 'package:mspeed/common/base/base_state.dart';
import 'package:mspeed/common/component/custom_navigator.dart';
import 'package:mspeed/common/helper/constant.dart';

import 'package:mspeed/src/seller/pesanan/model/pesanan_seller_model.dart';
import 'package:mspeed/src/seller/pesanan/provider/seller_pesanan_provider.dart';
import 'package:mspeed/src/seller/pesanan/view/pesanan_seller_detail_view.dart';
import 'package:mspeed/src/seller/pesanan/view/pesanan_seller_item_widget.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ═══════════════════════════════════════════════════════════════════
// M-SPEED Brand Color Palette — Solid Colors Only
// ═══════════════════════════════════════════════════════════════════
const Color _kPrimary = Color(0xFF1565C0);
const Color _kBackground = Color(0xFFF7F8FA);
const Color _kSurface = Color(0xFFFFFFFF);
const Color _kTextPrimary = Color(0xFF1F2937);
const Color _kTextSecondary = Color(0xFF6B7280);
const Color _kBorder = Color(0xFFE5E7EB);

class PesananSellerView extends StatefulWidget {
  const PesananSellerView({super.key});

  @override
  State<PesananSellerView> createState() => _PesananSellerViewState();
}

class _PesananSellerViewState extends BaseState<PesananSellerView> {
  String userId = "", userName = "";
  List<SellerOrderData> listPesanan = [];
  final searchController = TextEditingController();

  @override
  void initState() {
    initData();
    super.initState();
  }

  Future<void> initData() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getString(Constant.kSetPrefId) ?? "";
    userName = prefs.getString(Constant.kSetPrefFirstName) ?? "";
    final p = context.read<SellerPesananProvider>();
    await p.fetchListPesanan(withLoading: false);
    listPesanan = p.pesananSellerModel.data ?? [];
    setState(() {});
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> refresh() async {
    final p = context.read<SellerPesananProvider>();
    await p.fetchListPesanan(withLoading: true);
    listPesanan = p.pesananSellerModel.data ?? [];
    setState(() {});
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      surfaceTintColor: _kSurface,
      backgroundColor: _kSurface,
      foregroundColor: _kTextPrimary,
      elevation: 0,
      centerTitle: true,
      title: const Text(
        'Pesanan',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: _kTextPrimary,
        ),
      ),
    );
  }

  Widget _buildSearchBar(SellerPesananProvider p) {
    return Container(
      color: _kSurface,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: _kBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _kBorder, width: 1),
        ),
        child: Row(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Icon(Icons.search_rounded, color: _kTextSecondary, size: 20),
            ),
            Expanded(
              child: TextField(
                controller: searchController,
                style: const TextStyle(fontSize: 14, color: _kTextPrimary),
                decoration: const InputDecoration(
                  hintText: 'Cari Pesanan',
                  hintStyle: TextStyle(fontSize: 14, color: _kTextSecondary),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
                onChanged: (val) {
                  setState(() {
                    listPesanan = p.pesananSellerModel.data?.where((e) {
                          return e.orderNum?.toUpperCase().contains(
                                val.toUpperCase(),
                              ) ??
                              false;
                        }).toList() ??
                        [];
                  });
                },
              ),
            ),
            if (searchController.text.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.close_rounded, color: _kTextSecondary, size: 18),
                onPressed: () {
                  searchController.clear();
                  setState(() {
                    listPesanan = p.pesananSellerModel.data ?? [];
                  });
                  FocusScope.of(context).unfocus();
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_rounded, size: 48, color: _kTextSecondary.withOpacity(0.3)),
          const SizedBox(height: 16),
          const Text(
            'Belum ada pesanan',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: _kTextSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Pesanan terbaru akan muncul di sini',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: _kTextSecondary.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<SellerPesananProvider>();
    if (listPesanan.isEmpty && searchController.text.isEmpty) {
      listPesanan = p.pesananSellerModel.data ?? [];
    }

    return Scaffold(
      backgroundColor: _kBackground,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchBar(p),
            Expanded(
              child: RefreshIndicator(
                color: _kPrimary,
                onRefresh: refresh,
                child: listPesanan.isEmpty
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          SizedBox(height: MediaQuery.of(context).size.height * 0.25),
                          _buildEmptyState(),
                        ],
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        itemCount: listPesanan.length,
                        itemBuilder: (context, index) {
                          final item = listPesanan[index];

                          return InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () {
                              CusNav.nPush(
                                context,
                                PesananSellerDetailView(
                                  transaction_id: item.id?.toString() ?? "",
                                ),
                              );
                            },
                            child: PesananSellerItemWidget(
                              bgColor: Colors.white,
                              orderNumber: item.orderNum ?? "-",
                              date: item.createdAt ?? "-",
                              alamat: item.buyer?.address ?? "-",
                              totalPesanan: item.items?.length.toString() ?? "-",
                              sellerName: "-", // Kept for compatibility but unused visually
                              status: item.statusEnum,
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
