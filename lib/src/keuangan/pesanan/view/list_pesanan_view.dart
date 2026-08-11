import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:mspeed/common/base/base_state.dart';
import 'package:mspeed/common/component/custom_navigator.dart';
import 'package:mspeed/common/helper/Constant.dart';
import 'package:mspeed/generated/assets.dart';
import 'package:mspeed/src/admin/user/provider/admin_user_provider.dart';
import 'package:mspeed/src/auth/provider/auth_provider.dart';
import 'package:mspeed/src/auth/view/login_view.dart';

import 'package:mspeed/src/buyer/transaction/provider/transaction_status.dart';
import 'package:mspeed/src/keuangan/notifikasi/provider/notifikasi_keuangan_provider.dart';
import 'package:mspeed/src/keuangan/notifikasi/view/notifikasi_keuangan_view.dart';
import 'package:mspeed/src/keuangan/pesanan/model/daftar_transaksi_keuangan_model.dart';
import 'package:mspeed/src/keuangan/pesanan/provider/keuangan_provider.dart';
import 'package:mspeed/src/keuangan/pesanan/view/order_item_widget.dart';
import 'package:mspeed/src/keuangan/pesanan/view/keuangan_pesanan_detail_view.dart';
import 'package:mspeed/utils/utils.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ListPesananView extends StatefulWidget {
  const ListPesananView({super.key});

  @override
  State<ListPesananView> createState() => _ListPesananViewState();
}

class _ListPesananViewState extends BaseState<ListPesananView> {
  String fullName = "";
  String userId = "";
  bool isCollapsed = false;

  @override
  void initState() {
    initData();
    super.initState();
  }

  Future<void> initData() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getString(Constant.kSetPrefId) ?? "";
    final firstName = prefs.getString(Constant.kSetPrefFirstName) ?? "";
    final lastName = prefs.getString(Constant.kSetPrefLastName) ?? "";
    fullName = "$firstName $lastName";
    log("Isinya name : $fullName");

    loading(true);
    try {
      await Future.wait([
        context.read<KeuanganProvider>().fetchTransaction(withLoading: false),
        context
            .read<NotifikasiKeuanganProvider>()
            .fetchNotification(withLoading: false),
      ]);
    } finally {
      loading(false);
    }
  }

  String? filterStatus;
  int? filterBulan;
  int? filterTahun;
  final searchController = TextEditingController();

  void refresh() async {
    loading(true);
    try {
      await Future.wait([
        context.read<KeuanganProvider>().fetchTransaction(withLoading: false),
        context
            .read<NotifikasiKeuanganProvider>()
            .fetchNotification(withLoading: false),
      ]);
    } finally {
      loading(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<KeuanganProvider>();
    final allTransactions = p.daftarTransaksi.data ?? [];

    // Computational dynamic filtering
    final filteredTransactions = allTransactions.where((trans) {
      if (trans == null) return false;

      // 1. Filter Search Text
      if (searchController.text.isNotEmpty) {
        final matchesSearch = trans.nomorOrder
                ?.toLowerCase()
                .contains(searchController.text.toLowerCase()) ??
            false;
        if (!matchesSearch) return false;
      }

      // 2. Filter Status
      if (filterStatus != null) {
        if (trans.status != filterStatus) return false;
      }

      // 3. Filter Bulan & Tahun
      if (trans.Created != null) {
        try {
          final date = DateTime.parse(trans.Created!);
          if (filterBulan != null && date.month != filterBulan) return false;
          if (filterTahun != null && date.year != filterTahun) return false;
        } catch (_) {
          // Skip date filter if parsing fails, unless filter is active
          if (filterBulan != null || filterTahun != null) return false;
        }
      } else if (filterBulan != null || filterTahun != null) {
        return false;
      }

      return true;
    }).toList();

    Widget _buildOption(String title, String path, GestureTapCallback? onTap) {
      return InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              SizedBox(
                  width: 20,
                  height: 20,
                  child: FittedBox(child: Image.asset(path))),
              const SizedBox(width: 14),
              Text(
                title,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xff100629)),
              ),
            ],
          ),
        ),
      );
    }

    void _showLogoutBottomSheet(BuildContext context) {
      showModalBottomSheet(
        backgroundColor: Colors.white,
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(24),
          ),
        ),
        builder: (BuildContext modalContext) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Center(
                  child: Container(
                    width: 38,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xffE4E6EF),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Color(0xff8A93A3)),
                      onPressed: () {
                        CusNav.nPop(modalContext);
                      },
                    ),
                    const Text(
                      'Pilihan Akun',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xff100629),
                      ),
                    ),
                  ],
                ),
                const Divider(color: Color(0xffF0F0F0)),
                const SizedBox(height: 8),
                _buildOption(
                  'Kembali ke Admin',
                  Assets.imagesIcLoginAdmin,
                  () async {
                    Navigator.pop(modalContext);
                    await Utils.showYesNoDialog(
                      context: context,
                      title: "Kembali ke Admin",
                      desc: "Apakah Anda yakin ingin kembali ke dashboard admin?",
                      yesCallback: () async {
                        CusNav.nPop(context);
                        await context
                            .read<AdminUserProvider>()
                            .backToAdmin(context);
                      },
                      noCallback: () => CusNav.nPop(context),
                    );
                  },
                ),
                _buildOption(
                  'Keluar dari Aplikasi',
                  Assets.imagesIcLogoutToAdmin,
                  () async {
                    Navigator.pop(modalContext);
                    await Utils.showYesNoDialog(
                    context: context,
                    title: 'Konfirmasi',
                    desc: 'Apakah Anda yakin?',
                    noCallback: () => Navigator.pop(context),
                    yesCallback: () async {
                        CusNav.nPop(context);
                        Navigator.pushNamedAndRemoveUntil(
                            context, '/login', (route) => false);
                      },
                    );
                  },
                ),
                const SizedBox(height: 12),
              ],
            ),
          );
        },
      );
    }

    void _showFilterBottomSheet(BuildContext context) {
      String? tempStatus = filterStatus;
      int? tempBulan = filterBulan;
      int? tempTahun = filterTahun;

      showModalBottomSheet(
        backgroundColor: Colors.white,
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (BuildContext modalContext) {
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setModalState) {
              final listStatus = [
                {'value': null, 'label': 'Semua'},
                {'value': 'PROSES_PEMBAYARAN', 'label': 'Siap Tagih'},
                {'value': 'TELAH_DIBAYAR', 'label': 'Telah Dibayar'},
                {'value': 'PESANAN_SELESAI', 'label': 'Pesanan Selesai'},
                {'value': 'PESANAN_TELAH_DITERIMA', 'label': 'Pesanan Telah Diterima'},
                {'value': 'BARANG_DITERIMA', 'label': 'Barang Diterima'},
                {'value': 'PESANAN_DITOLAK', 'label': 'Pesanan Ditolak'},
                {'value': 'DIBATALKAN', 'label': 'Dibatalkan'},
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
                padding: EdgeInsets.fromLTRB(16, 8, 16, MediaQuery.of(context).viewInsets.bottom + 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 38,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xffE4E6EF),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Filter Pesanan',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xff100629),
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
                            'Reset Filter',
                            style: TextStyle(
                              color: Color(0xffED1C24),
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(color: Color(0xffF0F0F0)),
                    const SizedBox(height: 12),
                    
                    const Text(
                      'Status Pesanan',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xff100629),
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
                              color: isSelected ? Colors.white : const Color(0xff6D7588),
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              fontSize: 11,
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: const Color(0xffF59E0B),
                          backgroundColor: const Color(0xffF5F6FA),
                          checkmarkColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(
                              color: isSelected ? const Color(0xffF59E0B) : const Color(0xffE2E4E9),
                            ),
                          ),
                          onSelected: (selected) {
                            setModalState(() {
                              tempStatus = status['value'] as String?;
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),

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
                                  color: Color(0xff100629),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                decoration: BoxDecoration(
                                  color: const Color(0xffF5F6FA),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xffE2E4E9)),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<int?>(
                                    value: tempBulan,
                                    isExpanded: true,
                                    icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xff8A93A3)),
                                    items: listBulan.map((bulan) {
                                      return DropdownMenuItem<int?>(
                                        value: bulan['value'] as int?,
                                        child: Text(
                                          bulan['label'] as String,
                                          style: const TextStyle(fontSize: 13, color: Color(0xff100629)),
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
                                  color: Color(0xff100629),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                decoration: BoxDecoration(
                                  color: const Color(0xffF5F6FA),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xffE2E4E9)),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<int?>(
                                    value: tempTahun,
                                    isExpanded: true,
                                    icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xff8A93A3)),
                                    items: listTahun.map((tahun) {
                                      return DropdownMenuItem<int?>(
                                        value: tahun['value'] as int?,
                                        child: Text(
                                          tahun['label'] as String,
                                          style: const TextStyle(fontSize: 13, color: Color(0xff100629)),
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
                    const SizedBox(height: 28),

                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          filterStatus = tempStatus;
                          filterBulan = tempBulan;
                          filterTahun = tempTahun;
                        });
                        Navigator.pop(modalContext);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xffF59E0B),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Terapkan Filter',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
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

    final isAnyFilterActive = filterStatus != null || filterBulan != null || filterTahun != null;

    return Scaffold(
      backgroundColor: const Color(0xffF5F6FA),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await context
                .read<KeuanganProvider>()
                .fetchTransaction(withLoading: true);
          },
          color: const Color(0xffF59E0B),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xffF59E0B), Color(0xffD97706)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xffF59E0B).withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(Icons.account_balance_rounded, color: Colors.white, size: 22),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Selamat datang,',
                              style: TextStyle(
                                  color: Color(0xff8A93A3),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500)),
                          const SizedBox(height: 2),
                          Text(fullName.isNotEmpty ? fullName : 'Finance User',
                              style: const TextStyle(
                                  color: Color(0xff100629),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.2)),
                        ],
                      ),
                    ),
                    
                    Consumer<NotifikasiKeuanganProvider>(
                      builder: (context, nkProvider, child) {
                        final count = nkProvider.unreadCount;
                        return IconButton(
                          style: IconButton.styleFrom(
                            backgroundColor: const Color(0xffF5F6FA),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const NotifikasiKeuanganView(),
                              ),
                            );
                          },
                          icon: Badge(
                            isLabelVisible: count > 0,
                            label: Text(count.toString()),
                            offset: const Offset(6, -2),
                            backgroundColor: const Color(0xffED1C24),
                            child: const Icon(Icons.notifications_outlined, color: Color(0xff100629), size: 22),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    
                    IconButton(
                      style: IconButton.styleFrom(
                        backgroundColor: const Color(0xffED1C24).withOpacity(0.08),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.logout_rounded, color: Color(0xffED1C24), size: 20),
                      onPressed: () async {
                        SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        final isAdmin =
                            prefs.getBool(Constant.kSetPrefIsAdmin) ??
                                false;
                        if (isAdmin) {
                           _showLogoutBottomSheet(context);
                        } else {
                          Utils.showYesNoDialog(
                    context: context,
                    title: 'Konfirmasi',
                    desc: 'Apakah Anda yakin?',
                    noCallback: () => Navigator.pop(context),
                    yesCallback: () async {
                              handleTap(() async {
                                await context.read<AuthProvider>().logout();
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => LoginView()),
                                  (Route<dynamic> route) => false,
                                );
                              });
                            },
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
              
              // Search Bar & Filter Section
              Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 46,
                        decoration: BoxDecoration(
                          color: const Color(0xffF5F6FA),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xffE2E4E9)),
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 12),
                            Icon(Icons.search_rounded, color: Constant.grayColor, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                controller: searchController,
                                style: const TextStyle(fontSize: 13),
                                onChanged: (value) {
                                  setState(() {});
                                },
                                textInputAction: TextInputAction.search,
                                decoration: InputDecoration(
                                  hintText: 'Cari nomor order...',
                                  hintStyle: TextStyle(color: Constant.grayColor, fontSize: 13),
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                            ),
                            if (searchController.text.isNotEmpty)
                              GestureDetector(
                                onTap: () {
                                  searchController.clear();
                                  setState(() {});
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 10),
                                  child: Icon(Icons.close_rounded, color: Constant.grayColor, size: 18),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Elegant Filter Button
                    GestureDetector(
                      onTap: () => _showFilterBottomSheet(context),
                      child: Container(
                        height: 46,
                        width: 46,
                        decoration: BoxDecoration(
                          color: isAnyFilterActive
                              ? const Color(0xffF59E0B).withOpacity(0.1)
                              : const Color(0xffF5F6FA),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isAnyFilterActive
                                ? const Color(0xffF59E0B)
                                : const Color(0xffE2E4E9),
                            width: 1.5,
                          ),
                        ),
                        child: Icon(
                          Icons.filter_list_rounded,
                          color: isAnyFilterActive
                              ? const Color(0xffD97706)
                              : const Color(0xff100629),
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  children: [
                    Container(
                      width: 3,
                      height: 16,
                      decoration: BoxDecoration(
                        color: const Color(0xffF59E0B),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Daftar Pesanan',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xff100629),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xffF59E0B).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${filteredTransactions.length} pesanan',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xffD97706),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              Expanded(
                child: filteredTransactions.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.inbox_rounded, size: 64, color: Colors.grey.shade300),
                            const SizedBox(height: 12),
                            Text(
                              'Tidak ada pesanan ditemukan',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey.shade400),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
                        itemCount: filteredTransactions.length,
                        itemBuilder: (context, index) {
                          final trans = filteredTransactions[index];
                          if (trans == null) return const SizedBox();
                          return InkWell(
                            onTap: () {
                              CusNav.nPush(
                                  context,
                                  KeuanganPesananDetailView(
                                    transaction_id: trans.ID ?? '0',
                                  ));
                            },
                            borderRadius: BorderRadius.circular(18),
                            child: OrderItem(
                              bgColor: Colors.white,
                              orderNumber: trans.nomorOrder ?? "-",
                              date: trans.Created ?? "-",
                              total: trans.total ?? "0",
                              sellerName: trans.nama ?? "-",
                              status: TransactionStatus.fromString(
                                  trans.status ?? "PESANAN_BARU"),
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
