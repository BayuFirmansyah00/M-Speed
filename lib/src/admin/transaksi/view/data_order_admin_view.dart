import 'package:flutter/material.dart';
import 'package:mspeed/common/component/custom_navigator.dart';
import 'package:mspeed/common/helper/Constant.dart';
import 'package:mspeed/src/admin/transaksi/model/order_admin_model.dart';
import 'package:mspeed/src/admin/transaksi/provider/transaction_admin_provider.dart';
import 'package:mspeed/src/admin/transaksi/view/detail_pesanan_admin_view.dart';
import 'package:mspeed/utils/utils.dart';
import 'package:provider/provider.dart';

class DataOrderAdminView extends StatefulWidget {
  const DataOrderAdminView({super.key});

  @override
  State<DataOrderAdminView> createState() => _DataOrderAdminViewState();
}

class _DataOrderAdminViewState extends State<DataOrderAdminView> {
  static const _gradient = [Color(0xffF97316), Color(0xffEA580C)];

  @override
  void initState() {
    super.initState();
    refresh();
    final p = context.read<TransactionAdminProvider>();
    p.searchOrderC.clear();
  }

  OrderAdminModel data = OrderAdminModel();

  void refresh({String q = ''}) {
    context
        .read<TransactionAdminProvider>()
        .fetchList2(withLoading: true, search: q);
  }

  @override
  Widget build(BuildContext context) {
    data = context.watch<TransactionAdminProvider>().order;
    final searchC = context.read<TransactionAdminProvider>().searchOrderC;

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
                              child: const Icon(Icons.assignment_rounded,
                                  color: Colors.white, size: 22),
                            ),
                            const SizedBox(width: 12),
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Data Order',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Riwayat dan status semua pesanan masuk',
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
                        color: Colors.black.withOpacity(0.04),
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
                      hintText: 'Cari berdasarkan no order atau nama...',
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
                          'Tidak ada data order.',
                          style: TextStyle(color: Color(0xff8A93A3)),
                        ),
                      ),
                    )
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final model = data.data?[index];
                          if (model == null) return const SizedBox.shrink();
                          return _OrderCard(
                            model: model,
                            onTap: () {
                              CusNav.nPush(
                                context,
                                DetailPesananAdminView(
                                  transaction_id: model.ID ?? "",
                                ),
                              );
                            },
                          );
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

// ── Order Card Widget ────────────────────────────────────────────────────────
class _OrderCard extends StatelessWidget {
  final OrderAdminModelData model;
  final VoidCallback onTap;

  const _OrderCard({required this.model, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header (No order & Tanggal)
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
                          color: const Color(0xffF97316).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.assignment_rounded,
                            color: Color(0xffF97316), size: 16),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        model.nomorOrder ?? '-',
                        style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: Color(0xff100629)),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xffF5F6FA),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today_rounded,
                            size: 10, color: Color(0xff8A93A3)),
                        const SizedBox(width: 4),
                        Text(
                          model.tglTtdSuratPesanan ?? '-',
                          style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Color(0xff8A93A3)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xffF0F0F0)),
            // Body Info (Buyer, Seller, Penerima)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      _buildInfoIcon(Icons.person_outline_rounded,
                          Colors.blue, 'Buyer', model.BuyerName ?? '-'),
                      const SizedBox(width: 16),
                      _buildInfoIcon(Icons.storefront_rounded,
                          Colors.green, 'Seller', model.SellerName ?? '-'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: _buildInfoIcon(Icons.person_pin_rounded,
                            Colors.purple, 'Penerima', model.PenerimaName ?? '-'),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            'Total Pembayaran',
                            style: TextStyle(
                                fontSize: 11, color: Color(0xff8A93A3)),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Rp ${Utils.thousandSeparator(
                              int.parse(
                                  model.total?.split('.').firstOrNull ?? '0'),
                              symbol: '',
                            )}',
                            style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                                color: Color(0xffEA580C)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoIcon(
      IconData icon, Color iconColor, String label, String value) {
    return Expanded(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 14),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style:
                      const TextStyle(fontSize: 10, color: Color(0xff8A93A3)),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xff100629)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
