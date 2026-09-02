import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mspeed/common/base/base_state.dart';
import 'package:mspeed/common/component/custom_navigator.dart';
import 'package:mspeed/common/helper/constant.dart';
import 'package:mspeed/src/admin/master/model/banner_admin_model.dart';
import 'package:mspeed/src/admin/master/provider/admin_banner_provider.dart';
import 'package:mspeed/src/admin/master/view/form_banner_admin_view.dart';
import 'package:mspeed/utils/utils.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

class DataBannerAdminView extends StatefulWidget {
  const DataBannerAdminView({super.key});

  @override
  State<DataBannerAdminView> createState() => _DataBannerAdminViewState();
}

class _DataBannerAdminViewState extends BaseState<DataBannerAdminView> {
  static const _gradient = [Color(0xff8B5CF6), Color(0xff6D28D9)];
  static const _accent = Color(0xff8B5CF6);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminBannerProvider>().fetchBanners(withLoading: true);
    });
  }

  void _onCreate() {
    CusNav.nPush(context, const FormBannerAdminView());
  }

  void _onEdit(BannerAdminModelData banner) {
    CusNav.nPush(context, FormBannerAdminView(banner: banner));
  }

  Future<void> _onDelete(String id) async {
    await Utils.showYesNoDialog(
      context: context,
      title: 'Konfirmasi Hapus',
      desc: 'Yakin ingin menghapus banner ini?',
      yesCallback: () async {
        CusNav.nPop(context);
        await context.read<AdminBannerProvider>().deleteBanner(id);
      },
      noCallback: () => CusNav.nPop(context),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AdminBannerProvider>();
    final model = p.bannerList;

    return Scaffold(
      backgroundColor: const Color(0xffF5F6FA),
      body: CustomScrollView(
        slivers: [
          // ── Gradient SliverAppBar ──
          SliverAppBar(
            expandedHeight: 130,
            floating: false,
            pinned: true,
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
                  onTap: _onCreate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add_rounded, color: Colors.white, size: 18),
                        SizedBox(width: 4),
                        Text('Tambah', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
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
                      right: -30, top: -30,
                      child: Container(
                        width: 140, height: 140,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.07),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 68, 20, 16),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.view_carousel_rounded, color: Colors.white, size: 22),
                          ),
                          const SizedBox(width: 12),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('Banner',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
                              SizedBox(height: 2),
                              Text('Kelola banner promosi aplikasi',
                                style: TextStyle(fontSize: 12, color: Colors.white70)),
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

          // ── Count label ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
              child: Row(
                children: [
                  Container(width: 3, height: 14,
                    decoration: BoxDecoration(color: _accent, borderRadius: BorderRadius.circular(4))),
                  const SizedBox(width: 8),
                  const Text('Daftar Banner',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xff100629))),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _accent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('${model.length} data',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _accent)),
                  ),
                ],
              ),
            ),
          ),

          // ── List ──
          model.isEmpty
              ? SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.image_not_supported_rounded, size: 60, color: Colors.grey.shade300),
                        const SizedBox(height: 12),
                        Text('Belum ada banner',
                          style: TextStyle(fontSize: 14, color: Colors.grey.shade400, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                )
              : SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 100),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) {
                        final item = model[i];
                        return _BannerCard(
                          banner: item,
                          onEdit: () => _onEdit(item),
                          onDelete: () => _onDelete(item.id ?? ''),
                        );
                      },
                      childCount: model.length,
                    ),
                  ),
                ),
        ],
      ),
      floatingActionButton: FloatingActionButton.small(
        heroTag: 'refresh_banner',
        backgroundColor: _accent,
        onPressed: () => context.read<AdminBannerProvider>().fetchBanners(withLoading: true),
        child: const Icon(Icons.refresh_rounded, color: Colors.white, size: 20),
      ),
    );
  }
}

class _BannerCard extends StatelessWidget {
  final BannerAdminModelData banner;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _BannerCard({
    required this.banner,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    Widget imageWidget;
    if (banner.imageUrl != null && banner.imageUrl!.startsWith('http')) {
      imageWidget = CachedNetworkImage(
        imageUrl: banner.imageUrl!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: 160,
        placeholder: (context, url) => Container(color: Colors.grey.shade200),
        errorWidget: (context, url, error) => Container(color: Colors.grey.shade300, child: const Icon(Icons.error, color: Colors.grey)),
      );
    } else if (banner.imageUrl != null) {
      imageWidget = Image.file(
        File(banner.imageUrl!),
        fit: BoxFit.cover,
        width: double.infinity,
        height: 160,
      );
    } else {
      imageWidget = Container(
        width: double.infinity,
        height: 160,
        color: Colors.grey.shade200,
        child: const Icon(Icons.image, color: Colors.grey, size: 40),
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              imageWidget,
              Positioned(
                top: 10,
                right: 10,
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: onEdit,
                      child: Container(
                        width: 32, height: 32,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4)],
                        ),
                        child: const Icon(Icons.edit_rounded, color: Colors.blue, size: 16),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: onDelete,
                      child: Container(
                        width: 32, height: 32,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4)],
                        ),
                        child: const Icon(Icons.delete_rounded, color: Colors.red, size: 16),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  banner.judul ?? '-',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xff100629)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  banner.deskripsi ?? '-',
                  style: const TextStyle(fontSize: 13, color: Color(0xff8A93A3)),
                  maxLines: 2,
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
