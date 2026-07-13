import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mspeed/common/base/base_state.dart';
import 'package:mspeed/common/component/custom_navigator.dart';
import 'package:mspeed/common/helper/Constant.dart';
import 'package:mspeed/generated/assets.dart';
import 'package:mspeed/src/admin/master/model/alamat_admin_model.dart';
import 'package:mspeed/src/admin/master/provider/master_provider.dart';
import 'package:mspeed/src/admin/master/view/add_addres_admin_view.dart';
import 'package:provider/provider.dart';

class DataAlamatAdminView extends StatefulWidget {
  const DataAlamatAdminView({super.key});

  @override
  State<DataAlamatAdminView> createState() => _DataAlamatAdminViewState();
}

class _DataAlamatAdminViewState extends BaseState<DataAlamatAdminView> {
  static const _gradient = [Color(0xff059669), Color(0xff047857)];

  @override
  void initState() {
    super.initState();
    refresh();
  }

  void refresh({String q = ''}) {
    context
        .read<MasterProvider>()
        .fetchAlamatAdmin(withLoading: true, search: q);
  }

  void _showButtonBottomSheet(BuildContext context, int i, List<AlamatAdminModelData?>? model, MasterProvider masterP) {
    showModalBottomSheet(
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Pilihan Aksi',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xff100629)),
                  ),
                  GestureDetector(
                    onTap: () => CusNav.nPop(context),
                    child: const Icon(Icons.close_rounded, color: Color(0xffA0AEC0)),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xff059669).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: SvgPicture.asset(Assets.svgsIcAdminEdit, color: const Color(0xff059669), width: 18, height: 18),
                ),
                title: const Text('Ubah Alamat', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                onTap: () {
                  CusNav.nPop(context);
                  CusNav.nPush(
                    context,
                    AddAddressAdminView(alamat: model![i]),
                  );
                },
              ),
              const Divider(color: Color(0xffF0F0F0)),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xffEF4444).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: SvgPicture.asset(Assets.svgsIcAdminDelete, color: const Color(0xffEF4444), width: 18, height: 18),
                ),
                title: const Text('Hapus Alamat', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xffEF4444))),
                onTap: () {
                  CusNav.nPop(context);
                  masterP.deleteAlamat(alamatId: model![i]?.id);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final masterP = context.watch<MasterProvider>();
    final data = context.watch<MasterProvider>().getAlamatAdminModel;
    final model = data.data;
    final searchC = context.read<MasterProvider>().searchAlamatC;

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
                IconButton(
                  onPressed: () {
                    CusNav.nPush(context, AddAddressAdminView());
                  },
                  icon: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
                  ),
                ),
                const SizedBox(width: 8),
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
                              child: const Icon(Icons.location_on_rounded,
                                  color: Colors.white, size: 22),
                            ),
                            const SizedBox(width: 12),
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Data Alamat',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Kelola alamat pengiriman barang',
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
                      hintText: 'Cari berdasarkan alamat...',
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
              sliver: (model?.isEmpty ?? true)
                  ? const SliverFillRemaining(
                      child: Center(
                        child: Text(
                          'Tidak ada data alamat.',
                          style: TextStyle(color: Color(0xff8A93A3)),
                        ),
                      ),
                    )
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final item = model?[index];
                          if (item == null) return const SizedBox.shrink();
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
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
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(16, 10, 10, 8),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: const Color(0xff059669).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Icon(Icons.map_rounded,
                                            color: Color(0xff059669), size: 16),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          item.prov ?? '-',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 13,
                                              color: Color(0xff100629)),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () => _showButtonBottomSheet(context, index, model, masterP),
                                        icon: const Icon(Icons.more_vert_rounded, color: Color(0xff8A93A3)),
                                      ),
                                    ],
                                  ),
                                ),
                                const Divider(height: 1, color: Color(0xffF0F0F0)),
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Kabupaten / Kota',
                                              style: TextStyle(fontSize: 11, color: Color(0xff8A93A3)),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              item.kota ?? '-',
                                              style: const TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                  color: Color(0xff100629)),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        flex: 3,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Alamat Lengkap',
                                              style: TextStyle(fontSize: 11, color: Color(0xff8A93A3)),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              item.nama ?? '-',
                                              style: const TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w500,
                                                  color: Color(0xff4A5568)),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
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
                        },
                        childCount: model?.length ?? 0,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
