import 'dart:io';

import 'package:excel/excel.dart' hide Border;
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';

import 'package:flutter/material.dart';
import 'package:mspeed/common/base/base_state.dart';
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
  static const _gradient = [Color(0xff06B6D4), Color(0xff0284C7)];

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

  void _showExportBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Export Data DPP',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Pilih format file yang ingin Anda unduh:',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        _exportToPdf();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                        ),
                        child: const Column(
                          children: [
                            Icon(Icons.picture_as_pdf_rounded, color: Colors.red, size: 32),
                            SizedBox(height: 8),
                            Text(
                              'Export PDF',
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        _exportToExcel();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                        ),
                        child: const Column(
                          children: [
                            Icon(Icons.table_view_rounded, color: Colors.green, size: 32),
                            SizedBox(height: 8),
                            Text(
                              'Export Excel',
                              style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Future<void> _exportToPdf() async {
    Utils.showLoading();
    try {
      final p = context.read<TransactionAdminProvider>();
      final dataList = p.dpp.data ?? [];

      final pdfDoc = pw.Document();

      pdfDoc.addPage(
        pw.MultiPage(
          build: (context) => [
            pw.Header(
              level: 0,
              child: pw.Text('Data DPP', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
            ),
            pw.TableHelper.fromTextArray(
              context: context,
              data: <List<String>>[
                ['No', 'No Permintaan', 'Jumlah PRK', 'Nilai PRK', 'Sisa', 'Status'],
                ...dataList.asMap().entries.map((e) => [
                      '${e.key + 1}',
                      e.value?.nomorPermintaan ?? '-',
                      e.value?.jumlahPrk ?? '-',
                      'Rp ${Utils.thousandSeparator(int.tryParse(e.value?.nilaiPrk?.split('.').first ?? '0') ?? 0, symbol: '')}',
                      'Rp ${Utils.thousandSeparator(int.tryParse(e.value?.sisa?.split('.').first ?? '0') ?? 0, symbol: '')}',
                      e.value?.status == '1' ? 'Selesai' : 'Aktif',
                    ])
              ],
            ),
          ],
        ),
      );

      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/Data_DPP_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File(path);
      await file.writeAsBytes(await pdfDoc.save());

      Utils.dismissLoading();
      await OpenFilex.open(path);
    } catch (e) {
      Utils.dismissLoading();
      Utils.showFailed(msg: 'Gagal export PDF: $e');
    }
  }

  Future<void> _exportToExcel() async {
    Utils.showLoading();
    try {
      final p = context.read<TransactionAdminProvider>();
      final dataList = p.dpp.data ?? [];
      
      var excel = Excel.createExcel();
      Sheet sheetObject = excel['Data DPP'];
      excel.setDefaultSheet('Data DPP');
      
      // Header
      sheetObject.appendRow([
        TextCellValue('No'),
        TextCellValue('No Permintaan'),
        TextCellValue('Jumlah PRK'),
        TextCellValue('Nilai PRK'),
        TextCellValue('Sisa'),
        TextCellValue('Status'),
      ]);

      // Data
      for (int i = 0; i < dataList.length; i++) {
        final item = dataList[i];
        sheetObject.appendRow([
          IntCellValue(i + 1),
          TextCellValue(item?.nomorPermintaan ?? '-'),
          TextCellValue(item?.jumlahPrk ?? '-'),
          TextCellValue('Rp ${Utils.thousandSeparator(int.tryParse(item?.nilaiPrk?.split('.').first ?? '0') ?? 0, symbol: '')}'),
          TextCellValue('Rp ${Utils.thousandSeparator(int.tryParse(item?.sisa?.split('.').first ?? '0') ?? 0, symbol: '')}'),
          TextCellValue(item?.status == '1' ? 'Selesai' : 'Aktif'),
        ]);
      }

      var fileBytes = excel.save();
      if (fileBytes != null) {
        final directory = await getApplicationDocumentsDirectory();
        final path = '${directory.path}/Data_DPP_${DateTime.now().millisecondsSinceEpoch}.xlsx';
        File(path)
          ..createSync(recursive: true)
          ..writeAsBytesSync(fileBytes);
        Utils.dismissLoading();
        await OpenFilex.open(path);
      }
    } catch (e) {
      Utils.dismissLoading();
      Utils.showFailed(msg: 'Gagal export Excel: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    data = context.watch<TransactionAdminProvider>().dpp;
    final searchC = context.read<TransactionAdminProvider>().searchC;

    return Scaffold(
      backgroundColor: const Color(0xffF5F6FA),
      body: RefreshIndicator(
        onRefresh: () async {
          refresh(q: searchC.text);
        },
        child: CustomScrollView(
          slivers: [
            // ── Gradient SilverAppBar ──
            SliverAppBar(
              pinned: true,
              expandedHeight: 120,
              backgroundColor: _gradient[1],
              surfaceTintColor: Colors.transparent,
              leading: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: GestureDetector(
                    onTap: _showExportBottomSheet,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.download_rounded, color: Colors.white, size: 18),
                          SizedBox(width: 4),
                          Text('Export', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: _gradient,
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        right: -20,
                        top: -20,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.08),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 60, 20, 16),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.18),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.receipt_long_rounded,
                                  color: Colors.white, size: 22),
                            ),
                            const SizedBox(width: 12),
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Data DPP',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Kelola dasar pengenaan pajak transaksi',
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.white70),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Search Bar ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: searchC,
                    onSubmitted: (val) {
                      refresh(q: val);
                    },
                    textInputAction: TextInputAction.search,
                    style: const TextStyle(fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Cari berdasarkan nomor permintaan...',
                      hintStyle:
                          const TextStyle(color: Color(0xffA0AEC0), fontSize: 13),
                      prefixIcon: const Icon(Icons.search_rounded,
                          color: Color(0xffA0AEC0), size: 20),
                      suffixIcon: searchC.text.isNotEmpty
                          ? GestureDetector(
                              onTap: () {
                                searchC.clear();
                                refresh();
                              },
                              child: const Icon(Icons.close_rounded,
                                  color: Color(0xffA0AEC0), size: 18),
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                    ),
                  ),
                ),
              ),
            ),

            // ── Data List ──
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              sliver: (data.data?.isEmpty ?? true)
                  ? const SliverFillRemaining(
                      child: Center(
                        child: Text(
                          'Tidak ada data DPP.',
                          style: TextStyle(color: Color(0xff8A93A3)),
                        ),
                      ),
                    )
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final model = data.data?[index];
                          if (model == null) return const SizedBox.shrink();
                          return _DppCard(model: model);
                        },
                        childCount: data.data?.length ?? 0,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Card Widget ──────────────────────────────────────────────────────────────
class _DppCard extends StatelessWidget {
  final DppAdminModelData model;
  const _DppCard({required this.model});

  @override
  Widget build(BuildContext context) {
    final statusActive = model.status == '1';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header (Nomor & Status)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xff06B6D4).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.receipt_long_rounded,
                          color: Color(0xff06B6D4), size: 16),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      model.nomorPermintaan ?? '-',
                      style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: Color(0xff100629)),
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusActive
                        ? const Color(0xff10B981).withValues(alpha: 0.1)
                        : const Color(0xffEF4444).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    statusActive ? 'Aktif' : 'Tidak Aktif',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: statusActive
                          ? const Color(0xff10B981)
                          : const Color(0xffEF4444),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xffF0F0F0)),
          // Content Values
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Sub Jumlah',
                        style:
                            TextStyle(fontSize: 11, color: Color(0xff8A93A3)),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Rp ${Utils.thousandSeparator(
                          int.parse(
                              model.nilaiPrk?.split('.').firstOrNull ?? '0'),
                          symbol: '',
                        )}',
                        style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: Color(0xff100629)),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Sisa',
                        style:
                            TextStyle(fontSize: 11, color: Color(0xff8A93A3)),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Rp ${Utils.thousandSeparator(
                          int.parse(model.sisa?.split('.').firstOrNull ?? '0'),
                          symbol: '',
                        )}',
                        style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: Color(0xff0284C7)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
