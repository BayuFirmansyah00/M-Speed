import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mspeed/common/base/base_state.dart';
import 'package:mspeed/common/component/image_network_widget.dart';
import 'package:mspeed/src/manager/dashboard/model/manager_dashboard_model.dart';
import 'package:mspeed/src/manager/pesanan/provider/manager_provider.dart';
import 'package:provider/provider.dart';

// ── Palette & Typography ──────────────────────────────────────────────────
const Color _kPrimary = Color(0xFF1D4ED8);
const Color _kRed = Color(0xFFE31C25);
const Color _kTeal = Color(0xFF0D9488);
const Color _kBg = Color(0xFFF8FAFC);
const Color _kSurface = Color(0xFFFFFFFF);
const Color _kTextPrimary = Color(0xFF1F2937);
const Color _kTextSecondary = Color(0xFF6B7280);
const Color _kBorder = Color(0xFFE5E7EB);

final _currencyFmt = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

class ManagerDashboardView extends StatefulWidget {
  final Function(String statusFilter)? onNavigateToOrdersWithFilter;

  const ManagerDashboardView({
    super.key,
    this.onNavigateToOrdersWithFilter,
  });

  @override
  State<ManagerDashboardView> createState() => _ManagerDashboardViewState();
}

class _ManagerDashboardViewState extends BaseState<ManagerDashboardView> {
  final PageController _bannerController = PageController();
  int _currentBannerPage = 0;
  Timer? _bannerTimer;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initData();
    });
  }

  Future<void> _initData() async {
    final p = context.read<ManagerProvider>();
    await Future.wait([
      p.loadProfile(),
      p.fetchDashboard(withLoading: true),
    ]);
    _startBannerTimer();
  }

  void _startBannerTimer() {
    _bannerTimer?.cancel();
    _bannerTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      final banners = context.read<ManagerProvider>().dashboard.banners ?? [];
      if (banners.length > 1 && _bannerController.hasClients) {
        _currentBannerPage = (_currentBannerPage + 1) % banners.length;
        _bannerController.animateToPage(
          _currentBannerPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _bannerController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      context.read<ManagerProvider>().searchDashboard(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ManagerProvider>();
    final dashboard = p.dashboard;

    return Scaffold(
      backgroundColor: _kBg,
      body: RefreshIndicator(
        color: _kPrimary,
        onRefresh: () async {
          await p.fetchDashboard(
            categoryId: p.selectedCategoryId,
            search: p.dashboardSearchController.text,
            withLoading: true,
          );
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // ── App Header ───────────────────────────────────────────────
            SliverToBoxAdapter(
              child: _buildHeader(p),
            ),

            // ── Banner Carousel ──────────────────────────────────────────
            if (dashboard.banners != null && dashboard.banners!.isNotEmpty)
              SliverToBoxAdapter(
                child: _buildBannerCarousel(dashboard.banners!),
              ),

            // ── KPI Summary Cards ────────────────────────────────────────
            SliverToBoxAdapter(
              child: _buildKpiSection(p),
            ),

            // ── Product Catalog Section ──────────────────────────────────
            SliverToBoxAdapter(
              child: _buildCatalogHeader(p),
            ),

            // ── Category Filter Bar ──────────────────────────────────────
            if (dashboard.categories != null && dashboard.categories!.isNotEmpty)
              SliverToBoxAdapter(
                child: _buildCategoryStrip(p, dashboard.categories!),
              ),

            // ── Product Grid ─────────────────────────────────────────────
            if (p.isLoadingDashboard)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(child: CircularProgressIndicator(color: _kPrimary)),
                ),
              )
            else if (dashboard.products == null || dashboard.products!.isEmpty)
              SliverToBoxAdapter(
                child: _buildEmptyProducts(),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    mainAxisExtent: 280,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) => _buildProductCard(dashboard.products![i]),
                    childCount: dashboard.products!.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ── Header Greeting ───────────────────────────────────────────────────────
  Widget _buildHeader(ManagerProvider p) {
    return Container(
      color: _kSurface,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hi, ${p.managerName}!',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: _kTextPrimary,
                        letterSpacing: -0.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Berikut Ringkasan Transaksi Tim Subordinate Anda',
                      style: TextStyle(
                        fontSize: 12,
                        color: _kTextSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              if (p.isImpersonated)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.amber.shade300),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.swap_horiz_rounded, size: 14, color: Colors.amber.shade900),
                      const SizedBox(width: 4),
                      Text(
                        'Mode Sesi',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.amber.shade900,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Banner Carousel ───────────────────────────────────────────────────────
  Widget _buildBannerCarousel(List<ManagerBannerItem> banners) {
    return Container(
      color: _kSurface,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              height: 140,
              child: PageView.builder(
                controller: _bannerController,
                onPageChanged: (idx) {
                  setState(() => _currentBannerPage = idx);
                },
                itemCount: banners.length,
                itemBuilder: (ctx, i) {
                  final b = banners[i];
                  return ImageNetworkWidget(
                    imageUrl: b.imgUrl ?? '',
                    boxFit: BoxFit.cover,
                  );
                },
              ),
            ),
          ),
          if (banners.length > 1) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                banners.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: _currentBannerPage == i ? 16 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: _currentBannerPage == i ? _kPrimary : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── KPI Summary Cards ─────────────────────────────────────────────────────
  Widget _buildKpiSection(ManagerProvider p) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(16),
      color: _kSurface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ringkasan Status Pesanan',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: _kTextPrimary,
            ),
          ),
          const SizedBox(height: 12),

          // Primary Row: Total Pesanan & Pesanan Ditolak
          Row(
            children: [
              Expanded(
                child: _KpiCard(
                  title: 'Total Pesanan',
                  count: p.kpiTotalPesanan,
                  bgColor: const Color(0xFFEFF6FF),
                  textColor: _kPrimary,
                  onTap: () => widget.onNavigateToOrdersWithFilter?.call(''),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _KpiCard(
                  title: 'Pesanan Ditolak',
                  count: p.kpiPesananDitolak,
                  bgColor: const Color(0xFFFEF2F2),
                  textColor: _kRed,
                  onTap: () => widget.onNavigateToOrdersWithFilter?.call('reject pesanan by manager'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Grid of Status Cards
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 2.3,
            children: [
              _KpiCard(
                title: 'Pesanan Baru',
                count: p.kpiPesananBaru,
                bgColor: const Color(0xFFF0FDF4),
                textColor: _kTeal,
                onTap: () => widget.onNavigateToOrdersWithFilter?.call('pesanan baru'),
              ),
              _KpiCard(
                title: 'Pesanan Diterima',
                count: p.kpiPesananDiterima,
                bgColor: const Color(0xFFF0FDF4),
                textColor: _kTeal,
                onTap: () => widget.onNavigateToOrdersWithFilter?.call('approve pesanan by manager'),
              ),
              _KpiCard(
                title: 'Pesanan Dikirim',
                count: p.kpiPesananDikirim,
                bgColor: const Color(0xFFF0FDF4),
                textColor: _kTeal,
                onTap: () => widget.onNavigateToOrdersWithFilter?.call('dikirim'),
              ),
              _KpiCard(
                title: 'Barang Diterima',
                count: p.kpiBarangDiterima,
                bgColor: const Color(0xFFF0FDF4),
                textColor: _kTeal,
                onTap: () => widget.onNavigateToOrdersWithFilter?.call('diterima seller'),
              ),
              _KpiCard(
                title: 'Tagihan',
                count: p.kpiTagihan,
                bgColor: const Color(0xFFFEF2F2),
                textColor: _kRed,
                onTap: () => widget.onNavigateToOrdersWithFilter?.call('tagihan'),
              ),
              _KpiCard(
                title: 'Siap Tagih',
                count: p.kpiSiapTagih,
                bgColor: const Color(0xFFFEF2F2),
                textColor: _kRed,
                onTap: () => widget.onNavigateToOrdersWithFilter?.call('siap tagih by manager'),
              ),
              _KpiCard(
                title: 'Verifikasi',
                count: p.kpiProsesPembayaran,
                bgColor: const Color(0xFFFEF2F2),
                textColor: _kRed,
                onTap: () => widget.onNavigateToOrdersWithFilter?.call('tagihan'),
              ),
              _KpiCard(
                title: 'Telah Dibayar',
                count: p.kpiTelahDibayar,
                bgColor: const Color(0xFFECFDF5),
                textColor: const Color(0xFF059669),
                onTap: () => widget.onNavigateToOrdersWithFilter?.call('selesai'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Catalog Header & Search ───────────────────────────────────────────────
  Widget _buildCatalogHeader(ManagerProvider p) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      color: _kSurface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Katalog Produk',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: _kTextPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 44,
            decoration: BoxDecoration(
              color: _kBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _kBorder),
            ),
            child: Row(
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Icon(Icons.search_rounded, size: 20, color: _kTextSecondary),
                ),
                Expanded(
                  child: TextField(
                    controller: p.dashboardSearchController,
                    style: const TextStyle(fontSize: 13, color: _kTextPrimary),
                    decoration: const InputDecoration(
                      hintText: 'Cari nama produk / seller...',
                      hintStyle: TextStyle(fontSize: 13, color: _kTextSecondary),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onChanged: _onSearchChanged,
                  ),
                ),
                if (p.dashboardSearchController.text.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 18, color: _kTextSecondary),
                    onPressed: () {
                      p.dashboardSearchController.clear();
                      p.searchDashboard('');
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Category Strip ────────────────────────────────────────────────────────
  Widget _buildCategoryStrip(ManagerProvider p, List<ManagerCategoryItem> categories) {
    final selectedId = p.selectedCategoryId;

    return Container(
      color: _kSurface,
      height: 44,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: categories.length + 1,
        itemBuilder: (ctx, i) {
          final isAll = i == 0;
          final isSelected = isAll ? selectedId == null : selectedId == categories[i - 1].id;
          final name = isAll ? 'Semua Kategori' : (categories[i - 1].name ?? '-');

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(
                name,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? Colors.white : _kTextSecondary,
                ),
              ),
              selected: isSelected,
              onSelected: (_) {
                p.selectCategoryFilter(isAll ? null : categories[i - 1].id);
              },
              selectedColor: _kRed,
              backgroundColor: _kBg,
              checkmarkColor: Colors.white,
              showCheckmark: false,
              side: BorderSide(
                color: isSelected ? _kRed : _kBorder,
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
              visualDensity: VisualDensity.compact,
            ),
          );
        },
      ),
    );
  }

  // ── Product Card ──────────────────────────────────────────────────────────
  Widget _buildProductCard(ManagerProductItem item) {
    final priceStr = _currencyFmt.format(item.price ?? 0);
    final sellerName = item.seller?.companyName ?? 'Vendor';
    final city = item.seller?.cityName;
    final catName = item.category?.name ?? '-';

    return Container(
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _kBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
            child: SizedBox(
              height: 125,
              width: double.infinity,
              child: ImageNetworkWidget(
                imageUrl: item.primaryImageUrl ?? '',
                boxFit: BoxFit.cover,
              ),
            ),
          ),

          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        item.name ?? '-',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: _kTextPrimary,
                          height: 1.25,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        priceStr,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color: _kRed,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.storefront_rounded, size: 11, color: Colors.grey.shade500),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              sellerName,
                              style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      if (city != null && city.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            city,
                            style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      const SizedBox(height: 4),
                      Text(
                        'Stok ${item.qty ?? 0} • $catName',
                        style: const TextStyle(
                          fontSize: 10,
                          color: _kTeal,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Empty State ───────────────────────────────────────────────────────────
  Widget _buildEmptyProducts() {
    return Container(
      color: _kSurface,
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.inventory_2_outlined, size: 48, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            const Text(
              'Tidak ada produk ditemukan',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _kTextSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

// ── KPI Card Widget ────────────────────────────────────────────────────────
class _KpiCard extends StatelessWidget {
  final String title;
  final int count;
  final Color bgColor;
  final Color textColor;
  final VoidCallback? onTap;

  const _KpiCard({
    required this.title,
    required this.count,
    required this.bgColor,
    required this.textColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              NumberFormat.decimalPattern('id_ID').format(count),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: textColor,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF4B5563),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
