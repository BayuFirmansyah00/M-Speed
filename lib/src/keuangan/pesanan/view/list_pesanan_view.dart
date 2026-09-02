import 'package:flutter/material.dart';
import 'package:mspeed/common/base/base_state.dart';
import 'package:mspeed/common/component/custom_navigator.dart';
import 'package:mspeed/src/keuangan/pesanan/provider/keuangan_provider.dart';
import 'package:mspeed/src/keuangan/pesanan/view/keuangan_pesanan_detail_view.dart';
import 'package:mspeed/src/keuangan/pesanan/view/order_item_widget.dart';
import 'package:provider/provider.dart';

// ── Color Constants ────────────────────────────────────────────────────────
const Color _kPrimary = Color(0xFFD97706);
const Color _kPrimaryDark = Color(0xFFB45309);
const Color _kBg = Color(0xFFF8FAFC);
const Color _kSurface = Color(0xFFFFFFFF);
const Color _kTextPrimary = Color(0xFF1F2937);
const Color _kTextSecondary = Color(0xFF6B7280);
const Color _kBorder = Color(0xFFE5E7EB);

class ListPesananView extends StatefulWidget {
  const ListPesananView({super.key});

  @override
  State<ListPesananView> createState() => _ListPesananViewState();
}

class _ListPesananViewState extends BaseState<ListPesananView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final p = context.read<KeuanganProvider>();
    await p.fetchOrders(withLoading: true);
  }

  void _showFilterBottomSheet(BuildContext context) {
    final p = context.read<KeuanganProvider>();
    String? tempStatus = p.selectedStatus;
    int? tempBulan = p.selectedMonth;
    int? tempTahun = p.selectedYear;

    showModalBottomSheet(
      backgroundColor: _kSurface,
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext modalContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            final listStatus = [
              {'value': null, 'label': 'Semua Status'},
              {'value': 'penerimaan & verifikasi', 'label': 'Siap Dibayar (Perlu Tindakan)'},
              {'value': 'pesanan dibayar', 'label': 'Telah Dibayar'},
              {'value': 'pembayaran ditolak finance', 'label': 'Ditolak Finance'},
              {'value': 'siap tagih by manager', 'label': 'Siap Tagih'},
              {'value': 'barang dikirim', 'label': 'Barang Dikirim'},
              {'value': 'pesanan disetujui manager', 'label': 'Disetujui Manager'},
              {'value': 'pesanan selesai', 'label': 'Pesanan Selesai'},
              {'value': 'dibatalkan', 'label': 'Dibatalkan'},
            ];

            final listBulan = [
              {'value': null, 'label': 'Semua Bulan'},
              {'value': 1, 'label': 'Januari'},
              {'value': 2, 'label': 'Februari'},
              {'value': 3, 'label': 'Maret'},
              {'value': 4, 'label': 'April'},
              {'value': 5, 'label': 'Mei'},
              {'value': 6, 'label': 'Juni'},
              {'value': 7, 'label': 'Juli'},
              {'value': 8, 'label': 'Agustus'},
              {'value': 9, 'label': 'September'},
              {'value': 10, 'label': 'Oktober'},
              {'value': 11, 'label': 'November'},
              {'value': 12, 'label': 'Desember'},
            ];

            final currentYear = DateTime.now().year;
            final listTahun = [
              {'value': null, 'label': 'Semua Tahun'},
              for (int y = currentYear + 1; y >= currentYear - 3; y--)
                {'value': y, 'label': y.toString()}
            ];

            return Padding(
              padding: EdgeInsets.fromLTRB(20, 12, 20, MediaQuery.of(context).viewInsets.bottom + 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE4E6EF),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Filter Transaksi Finance',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: _kTextPrimary,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setModalState(() {
                            tempStatus = null;
                            tempBulan = null;
                            tempTahun = null;
                          });
                        },
                        child: const Text(
                          'Reset',
                          style: TextStyle(
                            color: Color(0xFFDC2626),
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(color: _kBorder),
                  const SizedBox(height: 10),

                  const Text(
                    'Status Log Pesanan',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _kTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: listStatus.map((status) {
                      final isSelected = tempStatus == status['value'];
                      return ChoiceChip(
                        label: Text(
                          status['label'] as String,
                          style: TextStyle(
                            color: isSelected ? Colors.white : _kTextSecondary,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            fontSize: 11,
                          ),
                        ),
                        selected: isSelected,
                        selectedColor: _kPrimary,
                        backgroundColor: _kBg,
                        checkmarkColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(
                            color: isSelected ? _kPrimary : _kBorder,
                          ),
                        ),
                        onSelected: (selected) {
                          setModalState(() {
                            tempStatus = status['value'];
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 18),

                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Bulan',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: _kTextPrimary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: _kBg,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: _kBorder),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<int?>(
                                  value: tempBulan,
                                  isExpanded: true,
                                  icon: const Icon(Icons.keyboard_arrow_down_rounded, color: _kTextSecondary),
                                  items: listBulan.map((bulan) {
                                    return DropdownMenuItem<int?>(
                                      value: bulan['value'] as int?,
                                      child: Text(
                                        bulan['label'] as String,
                                        style: const TextStyle(fontSize: 12, color: _kTextPrimary),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    setModalState(() {
                                      tempBulan = val;
                                    });
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Tahun',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: _kTextPrimary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: _kBg,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: _kBorder),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<int?>(
                                  value: tempTahun,
                                  isExpanded: true,
                                  icon: const Icon(Icons.keyboard_arrow_down_rounded, color: _kTextSecondary),
                                  items: listTahun.map((tahun) {
                                    return DropdownMenuItem<int?>(
                                      value: tahun['value'] as int?,
                                      child: Text(
                                        tahun['label'] as String,
                                        style: const TextStyle(fontSize: 12, color: _kTextPrimary),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    setModalState(() {
                                      tempTahun = val;
                                    });
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  ElevatedButton(
                    onPressed: () {
                      p.setFilterStatus(tempStatus);
                      p.setFilterMonth(tempBulan);
                      p.setFilterYear(tempTahun);
                      p.applyFilters();
                      Navigator.pop(modalContext);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _kPrimary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Terapkan Filter',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<KeuanganProvider>();
    final orders = p.orders;
    final isAnyFilterActive = p.selectedStatus != null || p.selectedMonth != null || p.selectedYear != null;

    return Scaffold(
      backgroundColor: _kBg,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top Bar with Search & Filter ──────────────────────────
            Container(
              color: _kSurface,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.receipt_long_rounded, color: _kPrimary, size: 22),
                      const SizedBox(width: 8),
                      const Text(
                        'Daftar Pesanan & Tagihan',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: _kTextPrimary,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _kPrimary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${orders.length} pesanan',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: _kPrimaryDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Search Box & Filter Button
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 44,
                          decoration: BoxDecoration(
                            color: _kBg,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: _kBorder),
                          ),
                          child: Row(
                            children: [
                              const SizedBox(width: 12),
                              const Icon(Icons.search_rounded, color: _kTextSecondary, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  controller: p.searchController,
                                  style: const TextStyle(fontSize: 13, color: _kTextPrimary),
                                  textInputAction: TextInputAction.search,
                                  onSubmitted: (_) => p.applyFilters(),
                                  decoration: const InputDecoration(
                                    hintText: 'Cari nomor order / buyer / seller...',
                                    hintStyle: TextStyle(color: _kTextSecondary, fontSize: 12),
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                ),
                              ),
                              if (p.searchController.text.isNotEmpty)
                                GestureDetector(
                                  onTap: () {
                                    p.searchController.clear();
                                    p.applyFilters();
                                  },
                                  child: const Padding(
                                    padding: EdgeInsets.only(right: 10),
                                    child: Icon(Icons.close_rounded, color: _kTextSecondary, size: 18),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Filter Button
                      GestureDetector(
                        onTap: () => _showFilterBottomSheet(context),
                        child: Container(
                          height: 44,
                          width: 44,
                          decoration: BoxDecoration(
                            color: isAnyFilterActive
                                ? _kPrimary.withValues(alpha: 0.12)
                                : _kBg,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isAnyFilterActive ? _kPrimary : _kBorder,
                              width: 1.5,
                            ),
                          ),
                          child: Icon(
                            Icons.tune_rounded,
                            color: isAnyFilterActive ? _kPrimaryDark : _kTextPrimary,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Active Filter Indicator
                  if (isAnyFilterActive) ...[
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Text(
                          'Filter Aktif: ',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _kTextSecondary),
                        ),
                        if (p.selectedStatus != null)
                          Container(
                            margin: const EdgeInsets.only(right: 6),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: _kPrimary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              p.selectedStatus!,
                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: _kPrimaryDark),
                            ),
                          ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () => p.resetFilters(),
                          child: const Text(
                            'Reset Semua',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFFDC2626)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            // ── Orders List ──────────────────────────────────────────
            Expanded(
              child: RefreshIndicator(
                color: _kPrimary,
                onRefresh: () async => p.fetchOrders(withLoading: true),
                child: p.isLoadingOrders
                    ? const Center(
                        child: CircularProgressIndicator(color: _kPrimary),
                      )
                    : orders.isEmpty
                        ? Center(
                            child: SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.inbox_rounded, size: 64, color: Colors.grey.shade300),
                                  const SizedBox(height: 12),
                                  const Text(
                                    'Tidak ada pesanan ditemukan',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: _kTextSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  const Text(
                                    'Tarik ke bawah untuk memuat ulang',
                                    style: TextStyle(fontSize: 12, color: _kTextSecondary),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                            itemCount: orders.length,
                            itemBuilder: (context, index) {
                              final order = orders[index];
                              return InkWell(
                                onTap: () {
                                  CusNav.nPush(
                                    context,
                                    KeuanganPesananDetailView(
                                      transactionId: order.id.toString(),
                                    ),
                                  );
                                },
                                borderRadius: BorderRadius.circular(18),
                                child: OrderItem(order: order),
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
