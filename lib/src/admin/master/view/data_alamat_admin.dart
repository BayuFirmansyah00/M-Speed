import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mspeed/common/base/base_state.dart';
import 'package:mspeed/common/component/custom_appbar.dart';
import 'package:mspeed/common/component/custom_navigator.dart';
import 'package:mspeed/generated/assets.dart';
import 'package:mspeed/src/admin/master/model/alamat_admin_model.dart';
import 'package:mspeed/src/admin/master/provider/master_provider.dart';
import 'package:mspeed/src/admin/master/view/add_addres_admin_view.dart';
import 'package:provider/provider.dart';
import 'package:mspeed/utils/utils.dart'; // Ditambahkan untuk Utils.showYesNoDialog

class DataAlamatAdminView extends StatefulWidget {
  const DataAlamatAdminView({super.key});

  @override
  State<DataAlamatAdminView> createState() => _DataAlamatAdminViewState();
}

class _DataAlamatAdminViewState extends BaseState<DataAlamatAdminView> {
  final Color appRed = const Color(0xFFED1C24);
  final Color orangeAcc = const Color(0xFFFF9800);
  final Color oceanBlue = const Color(0xFF0096C7);

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final p = context.read<MasterProvider>();
      p.searchAlamatC.clear();
      refresh();
    });
  }

  Future<void> refresh({String q = ''}) async {
    setState(() => _isLoading = true);
    try {
      await context.read<MasterProvider>().fetchAlamatAdmin(withLoading: false, search: q);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final masterP = context.watch<MasterProvider>();
    final model = masterP.getAlamatAdminModel.data;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: CustomAppBar.appBar(
        context,
        'Data Alamat Penerima',
        color: Colors.white,
        isCenter: true,
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        action: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => CusNav.nPush(context, const AddAddressAdminView()),
              child: CircleAvatar(
                radius: 16,
                backgroundColor: appRed,
                child: const Icon(Icons.add, size: 22, color: Colors.white),
              ),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(masterP.searchAlamatC),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator(color: orangeAcc))
                : (model == null || model.isEmpty)
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        color: orangeAcc,
                        onRefresh: () => refresh(),
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          itemCount: model.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final alamat = model[index];
                            return _buildAlamatCard(alamat, index, masterP);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(TextEditingController controller) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: TextField(
          controller: controller,
          onSubmitted: (val) => refresh(q: val),
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: "Cari alamat...",
            hintStyle: const TextStyle(color: Colors.black45, fontSize: 14),
            prefixIcon: Icon(Icons.search, color: orangeAcc),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.location_off_rounded, size: 72, color: orangeAcc.withOpacity(0.5)),
          const SizedBox(height: 16),
          const Text("Data alamat kosong", style: TextStyle(fontSize: 16, color: Colors.black54, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildAlamatCard(AlamatAdminModelData? alamat, int index, MasterProvider p) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 4))],
        border: Border(left: BorderSide(color: orangeAcc, width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      alamat?.prov ?? '-',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      alamat?.kota ?? '-',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.black54),
                    ),
                  ],
                ),
              ),
              _buildPopupMenu(alamat, p),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: Color(0xFFEEEEEE)),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.location_on_rounded, size: 16, color: appRed),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  alamat?.nama ?? '-',
                  style: const TextStyle(fontSize: 13, color: Colors.black87, height: 1.4),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildPopupMenu(AlamatAdminModelData? alamat, MasterProvider p) {
    return SizedBox(
      height: 24,
      width: 24,
      child: PopupMenuButton<String>(
        padding: EdgeInsets.zero,
        icon: const Icon(Icons.more_vert, color: Colors.black45, size: 22),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onSelected: (value) async {
          if (value == 'ubah') {
            CusNav.nPush(context, AddAddressAdminView(alamat: alamat));
          } else if (value == 'hapus') {
            await Utils.showYesNoDialog(
              context: context,
              title: 'Konfirmasi',
              desc: 'Apakah Anda yakin ingin menghapus alamat ini?',
              yesCallback: () async {
                CusNav.nPop(context);
                await p.deleteAlamat(alamatId: alamat?.id);
                refresh();
              },
              noCallback: () => CusNav.nPop(context),
            );
          }
        },
        itemBuilder: (context) => [
          PopupMenuItem(value: 'ubah', child: _menuItem(Icons.edit_rounded, oceanBlue, 'Ubah')),
          PopupMenuItem(value: 'hapus', child: _menuItem(Icons.delete_rounded, appRed, 'Hapus')),
        ],
      ),
    );
  }

  Widget _menuItem(IconData icon, Color color, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 12),
        Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      ],
    );
  }
}