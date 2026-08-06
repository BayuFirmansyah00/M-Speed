import 'package:flutter/material.dart';
import 'package:mspeed/common/base/base_state.dart';
import 'package:mspeed/src/admin/master/provider/master_provider.dart';
import 'package:mspeed/src/admin/master/view/add_materai_admin_view.dart';
import 'package:mspeed/common/component/custom_navigator.dart';
import 'package:provider/provider.dart';

class DataMateraiAdminView extends StatefulWidget {
  const DataMateraiAdminView({super.key});

  @override
  State<DataMateraiAdminView> createState() => _DataMateraiAdminViewState();
}

class _DataMateraiAdminViewState extends BaseState<DataMateraiAdminView> {
  static const _gradient = [Color(0xffDC2626), Color(0xffB91C1C)];

  @override
  void initState() {
    super.initState();
    refresh();
  }

  void refresh({String q = ''}) {
    context.read<MasterProvider>().fetchMateraiAdmin(
      withLoading: true,
      search: q,
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = context.watch<MasterProvider>().getMateraiAdminModel;
    final model = data.data;
    final searchC = context.read<MasterProvider>().searchMateraiC;

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
              actions: [const SizedBox(width: 8)],
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
                            color: Colors.white.withValues(alpha: 0.08),
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
                                color: Colors.white.withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.percent_rounded,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Data Materai',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Konfigurasi tarif dan data Materai',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white70,
                                  ),
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
                      hintText: 'Cari berdasarkan nama Materai...',
                      hintStyle: const TextStyle(
                        color: Color(0xffA0AEC0),
                        fontSize: 13,
                      ),
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        color: Color(0xffA0AEC0),
                        size: 20,
                      ),
                      suffixIcon: searchC.text.isNotEmpty
                          ? GestureDetector(
                              onTap: () {
                                searchC.clear();
                                refresh();
                              },
                              child: const Icon(
                                Icons.close_rounded,
                                color: Color(0xffA0AEC0),
                                size: 18,
                              ),
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // ── Data List ──
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              sliver: (model?.isEmpty ?? true)
                  ? const SliverFillRemaining(
                      child: Center(
                        child: Text(
                          'Tidak ada data Materai.',
                          style: TextStyle(color: Color(0xff8A93A3)),
                        ),
                      ),
                    )
                  : SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final item = model?[index];
                        if (item == null) return const SizedBox.shrink();
                        return GestureDetector(
                          onTap: () {
                            CusNav.nPush(
                              context,
                              AddMateraiAdminView(materai: item),
                            );
                          },
                          child: Container(
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
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    16,
                                    10,
                                    10,
                                    8,
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: const Color(
                                            0xffDC2626,
                                          ).withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.percent_rounded,
                                          color: Color(0xffDC2626),
                                          size: 16,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          item.type ?? '-',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 13,
                                            color: Color(0xff100629),
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Divider(
                                  height: 1,
                                  color: Color(0xffF0F0F0),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Harga E-Materai',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Color(0xff8A93A3),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            item.nominal ?? '-',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xff100629),
                                            ),
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
                      }, childCount: model?.length ?? 0),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
