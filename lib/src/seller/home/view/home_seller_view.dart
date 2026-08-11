import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mspeed/common/base/base_state.dart';
import 'package:mspeed/common/component/custom_button.dart';
import 'package:mspeed/common/component/custom_dropdown.dart';
import 'package:mspeed/common/component/custom_navigator.dart';
import 'package:mspeed/common/helper/constant.dart';
import 'package:mspeed/generated/assets.dart';
import 'package:mspeed/src/seller/chat/view/chat_list_seller_view.dart';
import 'package:mspeed/src/seller/home/model/home_seller_model.dart' as s;
import 'package:mspeed/src/seller/home/model/home_seller_model.dart';
import 'package:mspeed/src/seller/home/view/home_seller_graph_view.dart';
import 'package:mspeed/src/seller/notifikasi/provider/notifikasi_seller_provider.dart';
import 'package:mspeed/src/seller/notifikasi/view/notifikasi__seller_view.dart';
import 'package:mspeed/src/seller/profil/provider/profile_seller_provider.dart';
import 'package:mspeed/src/seller/profil/view/profile_seller_view.dart';
import 'package:mspeed/utils/utils.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../provider/seller_home_provider.dart';

// ═══════════════════════════════════════════════════════════════════
// M-SPEED Brand Color Palette — Solid Colors Only
// ═══════════════════════════════════════════════════════════════════
const Color _kPrimaryBlue = Color(0xFF1565C0);
const Color _kSecondaryBlue = Color(0xFF2E7DAB);
const Color _kDanger = Color(0xFFE53935);
const Color _kAccentYellow = Color(0xFFF9A825);
const Color _kSuccess = Color(0xFF16A765);
const Color _kBackground = Color(0xFFF7F8FA);
const Color _kSurface = Color(0xFFFFFFFF);
const Color _kTextPrimary = Color(0xFF1F2937);
const Color _kTextSecondary = Color(0xFF6B7280);
const Color _kBorder = Color(0xFFE5E7EB);

// ═══════════════════════════════════════════════════════════════════
// Reusable Card Decoration
// ═══════════════════════════════════════════════════════════════════
BoxDecoration _cardDecoration() => BoxDecoration(
      color: _kSurface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: _kBorder, width: 1),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );

class HomeSellerView extends StatefulWidget {
  final VoidCallback jumpToPesanan;

  const HomeSellerView({super.key, required this.jumpToPesanan});
  @override
  State<HomeSellerView> createState() => _HomeSellerViewState();
}

class _HomeSellerViewState extends BaseState<HomeSellerView> {
  final scrollController = ScrollController();
  bool isCollapsed = false;

  @override
  void initState() {
    getData();
    super.initState();
    scrollController.addListener(() {
      if (scrollController.offset > 200 && !isCollapsed) {
        setState(() {
          isCollapsed = true;
        });
      } else if (scrollController.offset <= 200 && isCollapsed) {
        setState(() {
          isCollapsed = false;
        });
      }
    });
    final p = context.read<SellerHomeProvider>();
    List<String> years =
        List.generate(2024 - 1900 + 1, (index) => (1900 + index).toString());
    for (int i = years.length - 1; i >= 0; i--) {
      p.timeList?.add(years[i]);
    }
    context
        .read<NotifikasiSellerProvider>()
        .fetchNotification(withLoading: true);
  }

  Future<bool> requestPermission(Permission permission) async {
    PermissionStatus status = await permission.request();
    return [PermissionStatus.granted, PermissionStatus.limited]
        .contains(status);
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  Future<void> getData() async {
    Utils.showLoading();
    await context
        .read<ProfileSellerProvider>()
        .fetchProfile(context, withLoading: false);
    await context
        .read<SellerHomeProvider>()
        .fetchSellerHome(withLoading: false);
    Utils.dismissLoading();
    // await requestPermission(Permission.location);
    // await requestPermission(Permission.accessMediaLocation);
    // await requestPermission(Permission.manageExternalStorage);
    // await requestPermission(Permission.photos);
    // await requestPermission(Permission.storage);
    if (Platform.isAndroid) {
      await requestPermission(Permission.manageExternalStorage);
      await requestPermission(Permission.storage);
    } else if (Platform.isIOS) {}
  }

  // ═════════════════════════════════════════════════════════════════
  // Status color helper
  // ═════════════════════════════════════════════════════════════════
  Color _statusColor(String status) {
    switch (status) {
      case 'PESANAN_BARU':
        return _kAccentYellow;
      case 'PESANAN_DITERIMA':
        return _kPrimaryBlue;
      case 'PESANAN_DIKIRIM':
        return _kAccentYellow;
      case 'BARANG_DITERIMA':
        return _kSuccess;
      case 'PROSES_PEMBAYARAN':
        return _kDanger;
      case 'TELAH_DIBAYAR':
        return _kSuccess;
      case 'PESANAN_DITOLAK':
        return _kDanger;
      default:
        return _kTextSecondary;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'PESANAN_BARU':
        return 'Pesanan Baru';
      case 'PESANAN_DITERIMA':
        return 'Diterima';
      case 'PESANAN_DIKIRIM':
        return 'Dikirim';
      case 'BARANG_DITERIMA':
        return 'Brg Diterima';
      case 'PROSES_PEMBAYARAN':
        return 'Proses Bayar';
      case 'TELAH_DIBAYAR':
        return 'Dibayar';
      case 'PESANAN_DITOLAK':
        return 'Ditolak';
      default:
        return status
            .replaceAll('_', ' ')
            .toLowerCase()
            .split(' ')
            .map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '')
            .join(' ');
    }
  }

  // ═════════════════════════════════════════════════════════════════
  // Period picker dialogs (logic unchanged)
  // ═════════════════════════════════════════════════════════════════
  Future<void> _showTahunan(SellerHomeProvider p) async {
    await showCupertinoModalPopup<void>(
      context: context,
      builder: (_) {
        final size = MediaQuery.of(context).size;
        return Container(
          color: Colors.white,
          height: size.height * 0.55,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: Constant.grayColor.withOpacity(0.5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Per Tahun', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    InkWell(
                      onTap: () => CusNav.nPop(context),
                      child: Text('Batal', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Constant.grayColor)),
                    ),
                  ],
                ),
              ),
              Constant.xSizedBox12,
              SizedBox(
                height: 200.0,
                child: Flex(
                  direction: Axis.horizontal,
                  children: <Widget>[
                    Flexible(
                      flex: 10,
                      child: CupertinoPicker(
                        itemExtent: 38,
                        onSelectedItemChanged: (int index) {
                          setState(() {
                            p.selectedYear = p.timeList![index];
                          });
                        },
                        children: (p.timeList ?? [])
                            .map((item) => Center(child: Text(item, style: const TextStyle(fontSize: 20))))
                            .toList(),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: CustomButton.mainButton('Konfirmasi',
                    borderRadius: BorderRadius.circular(10), () async {
                  handleTap(() async {
                    CusNav.nPop(context);
                  });
                }),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showHarian(SellerHomeProvider p) async {
    await showCupertinoModalPopup<void>(
      context: context,
      builder: (_) {
        final size = MediaQuery.of(context).size;
        return Container(
          color: Colors.white,
          height: size.height * 0.55,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: Constant.grayColor.withOpacity(0.5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Per Hari', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    InkWell(
                      onTap: () => CusNav.nPop(context),
                      child: Text('Batal', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Constant.grayColor)),
                    ),
                  ],
                ),
              ),
              Constant.xSizedBox12,
              SizedBox(
                height: 200,
                child: CupertinoDatePicker(
                  initialDateTime: DateTime.now(),
                  mode: CupertinoDatePickerMode.date,
                  use24hFormat: true,
                  onDateTimeChanged: (DateTime newTime) {
                    setState(() => p.selectedDate = newTime);
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: CustomButton.mainButton('Konfirmasi',
                    borderRadius: BorderRadius.circular(10), () async {
                  handleTap(() async {
                    CusNav.nPop(context);
                  });
                }),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showBulanan(SellerHomeProvider p) async {
    await showCupertinoModalPopup<void>(
      context: context,
      builder: (_) {
        final size = MediaQuery.of(context).size;
        return Container(
          color: Colors.white,
          height: size.height * 0.55,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: Constant.grayColor.withOpacity(0.5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Per Bulan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    InkWell(
                      onTap: () => CusNav.nPop(context),
                      child: Text('Batal', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Constant.grayColor)),
                    ),
                  ],
                ),
              ),
              Constant.xSizedBox12,
              SizedBox(
                height: 200,
                child: CupertinoDatePicker(
                  initialDateTime: DateTime.now(),
                  mode: CupertinoDatePickerMode.monthYear,
                  use24hFormat: true,
                  onDateTimeChanged: (DateTime newTime) {
                    setState(() {
                      p.selectedDate = newTime;
                      p.selectedMonth = newTime.month.toString();
                      p.selectedYear = newTime.year.toString();
                    });
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: CustomButton.mainButton('Konfirmasi',
                    borderRadius: BorderRadius.circular(10), () async {
                  handleTap(() async {
                    CusNav.nPop(context);
                  });
                }),
              ),
            ],
          ),
        );
      },
    );
  }

  // ═════════════════════════════════════════════════════════════════
  // SECTION BUILDERS
  // ═════════════════════════════════════════════════════════════════

  // ── Section Title ─────────────────────────────────────────────
  Widget _sectionTitle(String title, {String? actionText, VoidCallback? onAction}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: _kTextPrimary,
            ),
          ),
          if (actionText != null)
            GestureDetector(
              onTap: onAction,
              child: Row(
                children: [
                  Text(
                    actionText,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: _kPrimaryBlue,
                    ),
                  ),
                  const SizedBox(width: 2),
                  const Icon(Icons.chevron_right_rounded, size: 18, color: _kPrimaryBlue),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // ── Empty State ───────────────────────────────────────────────
  Widget _emptyState(String message, {String? subtitle, IconData icon = Icons.inbox_rounded}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Column(
          children: [
            Icon(icon, size: 36, color: _kTextSecondary.withOpacity(0.35)),
            const SizedBox(height: 8),
            Text(
              message,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: _kTextSecondary),
            ),
            if (subtitle != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  subtitle,
                  style: TextStyle(fontSize: 11, color: _kTextSecondary.withOpacity(0.7)),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ── Compact Period Filter ─────────────────────────────────────
  Widget _buildPeriodFilter(SellerHomeProvider p) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: _kSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _kBorder, width: 1),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: p.selectedPeriodeData,
            isExpanded: true,
            icon: const Icon(Icons.keyboard_arrow_down_rounded, color: _kPrimaryBlue, size: 20),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: _kPrimaryBlue,
            ),
            items: p.periodeData.map((e) => DropdownMenuItem(
              value: e,
              child: Text(e, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: _kPrimaryBlue)),
            )).toList(),
            onChanged: (v) async {
              if (v == null) return;
              if (v == 'Harian') await _showHarian(p);
              if (v == 'Bulanan') await _showBulanan(p);
              if (v == 'Tahunan') await _showTahunan(p);
              p.selectedPeriodeData = v;
              await getData();
            },
          ),
        ),
      ),
    );
  }

  // ── KPI Summary Cards ─────────────────────────────────────────
  Widget _buildKpiSection(HomeSellerModelData? data) {
    final items = [
      _KpiItem(
        icon: Icons.inventory_2_rounded,
        label: 'Total Produk',
        value: data?.produk ?? '0',
        valueColor: _kPrimaryBlue,
      ),
      _KpiItem(
        icon: Icons.shopping_cart_rounded,
        label: 'Total Pesanan',
        value: Utils.thousandSeparator(int.parse(data?.totalPermintaanPesanan ?? '0')),
        valueColor: _kPrimaryBlue,
      ),
      _KpiItem(
        icon: Icons.account_balance_wallet_rounded,
        label: 'Pendapatan',
        value: Utils.thousandSeparator(int.parse(data?.totalPendapatan ?? '0')),
        valueColor: _kSuccess,
      ),
      _KpiItem(
        icon: Icons.pending_actions_rounded,
        label: 'Belum Lunas',
        value: Utils.thousandSeparator(int.parse(data?.totalBelumLunas ?? '0')),
        valueColor: _kDanger,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ringkasan Penjualan',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: _kTextPrimary),
          ),
          const SizedBox(height: 12),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.7,
            children: items.map((item) => _buildKpiCard(item)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildKpiCard(_KpiItem item) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: item.valueColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(item.icon, size: 16, color: item.valueColor),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item.label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: _kTextSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          Text(
            item.value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: item.valueColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // ── Order Status Section ──────────────────────────────────────
  Widget _buildOrderStatusSection(HomeSellerModelData? data) {
    final statuses = [
      _OrderStatus(icon: Icons.fiber_new_rounded, label: 'Pesanan Baru', count: data?.pesananBaru ?? '0', color: _kPrimaryBlue),
      _OrderStatus(icon: Icons.check_circle_outline_rounded, label: 'Diterima', count: '${data?.pesananDiterima ?? 0}', color: _kPrimaryBlue),
      _OrderStatus(icon: Icons.local_shipping_rounded, label: 'Dikirim', count: data?.pesananDikirim ?? '0', color: _kAccentYellow),
      _OrderStatus(icon: Icons.move_to_inbox_rounded, label: 'Brg Diterima', count: '${data?.barangDiterima ?? 0}', color: _kSuccess),
      _OrderStatus(icon: Icons.payments_rounded, label: 'Proses Bayar', count: '${data?.prosesPembayaran ?? 0}', color: _kDanger),
      _OrderStatus(icon: Icons.price_check_rounded, label: 'Dibayar', count: data?.pesananDibayar ?? '0', color: _kSuccess),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: _cardDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Status Pesanan',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: _kTextPrimary),
            ),
            const SizedBox(height: 14),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.1,
              children: statuses.map((s) => _buildOrderStatusItem(s)).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderStatusItem(_OrderStatus status) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: status.color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(status.icon, size: 18, color: status.color),
        ),
        const SizedBox(height: 6),
        Text(
          status.count,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: status.color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          status.label,
          style: const TextStyle(fontSize: 11, color: _kTextSecondary),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  // ── Sales Chart Section ───────────────────────────────────────
  Widget _buildChartSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: _cardDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Penjualan Produk',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: _kTextPrimary),
            ),
            const SizedBox(height: 4),
            const HomeSellerGraphView(),
          ],
        ),
      ),
    );
  }

  // ── Produk Terlaris Section ───────────────────────────────────
  Widget _buildTopProductsSection(List<HomeSellerModelDataTablePalingLaris?>? products) {
    final hasProducts = products != null && products.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: _cardDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Produk Terlaris',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: _kTextPrimary),
            ),
            const SizedBox(height: 12),
            if (!hasProducts)
              _emptyState(
                'Belum ada produk terlaris',
                subtitle: 'Data akan muncul setelah transaksi tersedia',
                icon: Icons.star_border_rounded,
              )
            else
              ...List.generate(products!.length, (i) {
                final item = products[i];
                if (item == null) return const SizedBox.shrink();
                return _buildTopProductItem(i, item);
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildTopProductItem(int index, HomeSellerModelDataTablePalingLaris item) {
    return Column(
      children: [
        if (index > 0)
          Divider(color: _kBorder.withOpacity(0.6), height: 1),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              // Ranking badge
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: index == 0
                      ? _kPrimaryBlue
                      : index == 1
                          ? _kSecondaryBlue
                          : _kTextSecondary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '#${index + 1}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: index < 2 ? Colors.white : _kTextSecondary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Product info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.nama ?? '-',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: _kTextPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${item.qty ?? '0'} terjual',
                      style: const TextStyle(fontSize: 12, color: _kTextSecondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Price
              Text(
                Utils.thousandSeparator(int.parse(item.harga ?? '0')),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _kTextPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Pesanan Terbaru Section ───────────────────────────────────
  Widget _buildRecentOrdersSection(List<HomeSellerModelDataTablePesananTerbaru?>? orders) {
    final hasOrders = orders != null && orders.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: _cardDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Pesanan Terbaru',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: _kTextPrimary),
                ),
                GestureDetector(
                  onTap: widget.jumpToPesanan,
                  child: const Row(
                    children: [
                      Text(
                        'Lihat Semua',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: _kPrimaryBlue),
                      ),
                      SizedBox(width: 2),
                      Icon(Icons.chevron_right_rounded, size: 18, color: _kPrimaryBlue),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (!hasOrders)
              _emptyState(
                'Belum ada pesanan',
                subtitle: 'Pesanan terbaru akan muncul di sini',
                icon: Icons.receipt_long_rounded,
              )
            else
              ...List.generate(orders!.length, (i) {
                final item = orders[i];
                if (item == null) return const SizedBox.shrink();
                return _buildRecentOrderItem(i, item);
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentOrderItem(int index, HomeSellerModelDataTablePesananTerbaru item) {
    final statusRaw = item.status ?? '';
    final statusLabel = _statusLabel(statusRaw);
    final statusClr = _statusColor(statusRaw);

    return Column(
      children: [
        if (index > 0)
          Divider(color: _kBorder.withOpacity(0.6), height: 1),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order icon
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: _kPrimaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.receipt_outlined, size: 16, color: _kPrimaryBlue),
              ),
              const SizedBox(width: 12),
              // Order details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.nomorOrder ?? '-',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _kTextPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.nama ?? '-',
                      style: const TextStyle(fontSize: 12, color: _kTextSecondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      Utils.thousandSeparator(int.parse(item.total ?? '0')),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _kTextPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Status badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusClr.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: statusClr,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ═════════════════════════════════════════════════════════════════
  // MAIN BUILD
  // ═════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final p = context.watch<SellerHomeProvider>();
    final data = p.homeSellerModel?.data;
    final notifP = context.watch<NotifikasiSellerProvider>();
    final profileP = context.watch<ProfileSellerProvider>();

    return Scaffold(
      backgroundColor: _kBackground,
      appBar: _buildAppBar(profileP, notifP),
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          color: _kPrimaryBlue,
          onRefresh: () async => getData(),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.only(bottom: 100),
            children: [
              const SizedBox(height: 12),
              // Period filter
              _buildPeriodFilter(p),
              const SizedBox(height: 16),
              // KPI Summary
              _buildKpiSection(data),
              const SizedBox(height: 16),
              // Order Status
              _buildOrderStatusSection(data),
              const SizedBox(height: 16),
              // Sales Chart
              _buildChartSection(),
              const SizedBox(height: 16),
              // Produk Terlaris
              _buildTopProductsSection(data?.tablePalingLaris),
              const SizedBox(height: 16),
              // Pesanan Terbaru
              _buildRecentOrdersSection(data?.tablePesananTerbaru),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  // ── Compact AppBar ────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar(ProfileSellerProvider profileP, NotifikasiSellerProvider notifP) {
    final sellerData = profileP.profileSellerModel.data?.getSeller;
    final sellerName = sellerData?.nama ?? '';
    final initials = sellerName.isNotEmpty
        ? sellerName.split(' ').take(2).map((w) => w.isNotEmpty ? w[0].toUpperCase() : '').join()
        : 'S';

    return AppBar(
      surfaceTintColor: _kSurface,
      backgroundColor: _kSurface,
      foregroundColor: _kTextPrimary,
      toolbarHeight: 72,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.only(left: 16),
        child: Center(
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _kPrimaryBlue,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                initials,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ),
      leadingWidth: 56,
      titleSpacing: 12,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Selamat datang,',
            style: TextStyle(fontSize: 12, color: _kTextSecondary, fontWeight: FontWeight.w400),
          ),
          const SizedBox(height: 1),
          Text(
            sellerName.isNotEmpty ? sellerName : '-',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: _kTextPrimary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 1),
          const Text(
            'Seller M-SPEED',
            style: TextStyle(fontSize: 11, color: _kTextSecondary, fontWeight: FontWeight.w400),
          ),
        ],
      ),
      actions: <Widget>[
        // Notification
        IconButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => NotificationSellerView()));
          },
          icon: Badge(
            isLabelVisible: notifP.unreadCount > 0,
            label: Text(notifP.unreadCount.toString(), style: const TextStyle(fontSize: 10)),
            offset: const Offset(6, -4),
            backgroundColor: _kDanger,
            child: const Icon(Icons.notifications_none_rounded, size: 24, color: _kTextPrimary),
          ),
        ),
        // Chat
        IconButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => ChatListSellerView()));
          },
          icon: const Icon(Icons.chat_bubble_outline_rounded, size: 22, color: _kTextPrimary),
        ),
        // Profile
        IconButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileSellerView()));
          },
          icon: const Icon(Icons.person_outline_rounded, size: 24, color: _kTextPrimary),
        ),
        const SizedBox(width: 4),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Data Classes
// ═══════════════════════════════════════════════════════════════════
class _KpiItem {
  final IconData icon;
  final String label;
  final String value;
  final Color valueColor;
  const _KpiItem({required this.icon, required this.label, required this.value, required this.valueColor});
}

class _OrderStatus {
  final IconData icon;
  final String label;
  final String count;
  final Color color;
  const _OrderStatus({required this.icon, required this.label, required this.count, required this.color});
}
