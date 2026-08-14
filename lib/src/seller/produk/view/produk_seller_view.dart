import 'package:flutter/material.dart';
import 'package:mspeed/common/base/base_state.dart';
import 'package:mspeed/common/component/custom_button.dart';
import 'package:mspeed/common/component/custom_navigator.dart';
import 'package:mspeed/common/helper/safe_network_image.dart';
import 'package:mspeed/generated/assets.dart';
import 'package:mspeed/src/seller/produk/model/produk_detail_seller_model.dart';
import 'package:mspeed/src/seller/produk/provider/produk_seller_provider.dart';
import 'package:mspeed/src/seller/produk/view/produk_add_seller_view.dart';
import 'package:mspeed/src/seller/produk/view/produk_detail_seller_view.dart';
import 'package:mspeed/utils/utils.dart';
import 'package:provider/provider.dart';
import 'package:mspeed/common/helper/app_colors.dart';

// ═══════════════════════════════════════════════════════════════════
// M-SPEED Brand Color Palette — Solid Colors Only
// ═══════════════════════════════════════════════════════════════════
const Color _kPrimary = AppColors.primary;
const Color _kDanger = Color(0xFFE53935);
const Color _kBackground = Color(0xFFF7F8FA);
const Color _kSurface = Color(0xFFFFFFFF);
const Color _kTextPrimary = Color(0xFF1F2937);
const Color _kTextSecondary = Color(0xFF6B7280);
const Color _kBorder = Color(0xFFE5E7EB);

class ProdukSellerView extends StatefulWidget {
  const ProdukSellerView({super.key});

  @override
  State<ProdukSellerView> createState() => _ProdukSellerViewState();
}

class _ProdukSellerViewState extends BaseState<ProdukSellerView> {
  late ScrollController scrollC;
  List<ProdukDetailSellerModelData?> listProdukModel = [];
  final searchController = TextEditingController();

  @override
  void initState() {
    scrollC = ScrollController()..addListener(() {
      setState(() {});
    });
    refresh();
    super.initState();
  }

  @override
  void dispose() {
    scrollC.dispose();
    searchController.dispose();
    super.dispose();
  }

  Future<void> refresh() async {
    final p = context.read<ProdukSellerProvider>();
    await p.fetchProductListSeller(withLoading: true);
    listProdukModel = p.produkSellerListModel.data ?? [];
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
        'Produk',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: _kTextPrimary,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () async {
              final p = context.read<ProdukSellerProvider>();
              p.fotoProduk.clear();
              p.fotoProduk.add(null);
              p.namaC.clear();
              p.hargaC.clear();
              p.stokC.clear();
              p.selectedKategori = null;
              p.deskripsiC.clear();
              await CusNav.nPush(context, ProdukAddSellerView());
              refresh();
            },
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: _kPrimary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add_rounded, size: 24, color: _kPrimary),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar(ProdukSellerProvider p) {
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
                  hintText: 'Cari Produk',
                  hintStyle: TextStyle(fontSize: 14, color: _kTextSecondary),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
                onChanged: (val) {
                  setState(() {
                    listProdukModel = p.produkSellerListModel.data
                            ?.where((element) =>
                                element.name?.toLowerCase().contains(
                                      val.toLowerCase(),
                                    ) ??
                                false)
                            .toList() ??
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
                    listProdukModel = p.produkSellerListModel.data ?? [];
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
          Icon(Icons.inventory_2_outlined, size: 48, color: _kTextSecondary.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          const Text(
            'Tidak ada produk',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: _kTextSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Produk yang Anda tambahkan\nakan muncul di sini',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: _kTextSecondary.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProdukItem(ProdukDetailSellerModelData? data) {
    if (data == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () async {
          await CusNav.nPush(
            context,
            ProdukDetailSellerView(productId: data.id?.toString() ?? ''),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _kSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _kBorder, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SafeNetworkImage(
                      width: 72,
                      height: 72,
                      url: data.images?.isNotEmpty == true ? (data.images![0].imgUrl ?? '') : '',
                      errorBuilder: Image.asset(Assets.imagesImgPlaceholder, fit: BoxFit.cover),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Product Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data.name ?? '-',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _kTextPrimary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          Utils.thousandSeparator((data.price ?? 0).toInt()),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: _kPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.inventory_2_outlined, size: 14, color: _kTextSecondary.withValues(alpha: 0.8)),
                            const SizedBox(width: 4),
                            Text(
                              'Stok: ${data.qty ?? 0}',
                              style: const TextStyle(fontSize: 12, color: _kTextSecondary),
                            ),
                            const SizedBox(width: 12),
                            Icon(Icons.qr_code_rounded, size: 14, color: _kTextSecondary.withValues(alpha: 0.8)),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                data.productCode ?? '-',
                                style: const TextStyle(fontSize: 12, color: _kTextSecondary),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Divider(height: 1, color: _kBorder.withValues(alpha: 0.6)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: CustomButton.secondaryButton(
                      'Hapus',
                      () async {
                        await Utils.showYesNoDialog(
                          context: context,
                          title: 'Hapus Produk',
                          desc: 'Apakah Anda yakin ingin hapus produk ini?',
                          yesCallback: () async {
                            CusNav.nPop(context);
                            await context.read<ProdukSellerProvider>().hapusProduk(
                                  productId: data.id?.toString() ?? '0',
                                  withLoading: true,
                                );
                            scrollC.jumpTo(0);
                            await context.read<ProdukSellerProvider>().fetchProductListSeller(withLoading: true);
                          },
                          noCallback: () => CusNav.nPop(context),
                        );
                      },
                      contentPadding: const EdgeInsets.symmetric(vertical: 8),
                      color: _kDanger,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomButton.mainButton(
                      'Ubah',
                      () async {
                        await CusNav.nPush(
                          context,
                          ProdukAddSellerView(
                            isEdit: true,
                            productId: data.id?.toString(),
                          ),
                        );
                      },
                      contentPadding: const EdgeInsets.symmetric(vertical: 8),
                      color: _kPrimary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ProdukSellerProvider>();
    if (listProdukModel.isEmpty && searchController.text.isEmpty) {
      listProdukModel = p.produkSellerListModel.data ?? [];
    }

    return Scaffold(
      backgroundColor: _kBackground,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchBar(p),
            Expanded(
              child: RefreshIndicator(
                color: _kPrimary,
                onRefresh: refresh,
                child: listProdukModel.isEmpty
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          SizedBox(height: MediaQuery.of(context).size.height * 0.25),
                          _buildEmptyState(),
                        ],
                      )
                    : ListView.builder(
                        controller: scrollC,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        itemCount: listProdukModel.length,
                        itemBuilder: (c, i) => _buildProdukItem(listProdukModel[i]),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
