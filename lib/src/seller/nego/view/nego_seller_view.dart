import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mspeed/common/component/custom_button.dart';
import 'package:mspeed/common/component/custom_dialog.dart';
import 'package:mspeed/common/component/custom_navigator.dart';
import 'package:mspeed/common/component/custom_textfield.dart';
import 'package:mspeed/src/seller/nego/model/nego_seller_model.dart';
import 'package:mspeed/src/seller/nego/provider/nego_seller_provider.dart';
import 'package:mspeed/utils/utils.dart';
import 'package:provider/provider.dart';
import 'package:mspeed/common/helper/app_colors.dart';
import 'package:mspeed/common/helper/text_input_formatter_helper.dart';

// ═══════════════════════════════════════════════════════════════════
// M-SPEED Brand Color Palette — Solid Colors Only
// ═══════════════════════════════════════════════════════════════════
const Color _kPrimary = AppColors.primary;
const Color _kSuccess = Color(0xFF16A765);
const Color _kDanger = Color(0xFFE53935);
const Color _kWarning = Color(0xFFF9A825);
const Color _kBackground = Color(0xFFF7F8FA);
const Color _kSurface = Color(0xFFFFFFFF);
const Color _kTextPrimary = Color(0xFF1F2937);
const Color _kTextSecondary = Color(0xFF6B7280);
const Color _kBorder = Color(0xFFE5E7EB);

class NegoSellerView extends StatefulWidget {
  const NegoSellerView({super.key});

  @override
  State<NegoSellerView> createState() => _NegoSellerViewState();
}

class _NegoSellerViewState extends State<NegoSellerView> {
  List<NegoSellerModelData> negoData = [];
  final searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      refresh();
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> refresh() async {
    final p = context.read<NegoSellerProvider>();
    await p.fetchNego(withLoading: true);
    _filterData(p);
  }

  void _filterData(NegoSellerProvider p) {
    final allData = p.negoSellerModel.data ?? [];
    final search = searchController.text.toLowerCase();
    
    setState(() {
      if (search.isEmpty) {
        negoData = List.from(allData);
      } else {
        negoData = allData.where((element) {
          final productName = (element.product?.name ?? '').toLowerCase();
          final buyerName = (element.buyer?.name ?? '').toLowerCase();
          return productName.contains(search) || buyerName.contains(search);
        }).toList();
      }
    });
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      surfaceTintColor: _kSurface,
      backgroundColor: _kSurface,
      foregroundColor: _kTextPrimary,
      elevation: 0,
      centerTitle: true,
      title: const Text(
        'Permintaan Nego',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: _kTextPrimary,
        ),
      ),
    );
  }

  Widget _buildSearchBar(NegoSellerProvider p) {
    return Container(
      color: _kSurface,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: _kBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _kBorder, width: 1),
        ),
        child: Row(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Icon(Icons.search_rounded, color: _kTextSecondary, size: 20),
            ),
            Expanded(
              child: TextField(
                controller: searchController,
                style: const TextStyle(fontSize: 14, color: _kTextPrimary),
                decoration: const InputDecoration(
                  hintText: 'Cari Produk / Pembeli',
                  hintStyle: TextStyle(fontSize: 14, color: _kTextSecondary),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
                onChanged: (_) => _filterData(p),
              ),
            ),
            if (searchController.text.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.close_rounded, color: _kTextSecondary, size: 18),
                onPressed: () {
                  searchController.clear();
                  FocusScope.of(context).unfocus();
                  _filterData(p);
                },
              ),
          ],
        ),
      ),
    );
  }

  void _showNegoDialog(BuildContext context, String cartId, double hargaAsli, NegoSellerProvider p) {
    CustomDialog.mainDialog(
      context: context,
      title: "",
      content: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.black, size: 24),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              const Text(
                'Ajukan Harga Nego',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _kTextPrimary),
              ),
              const SizedBox(height: 16),
              CustomTextField.borderTextField(
                controller: p.negoHargaC,
                required: false,
                labelText: "Harga Nego",
                hintText: "Masukkan Harga Baru",
                textInputType: TextInputType.number,
                textCapitalization: TextCapitalization.words,
                focusNode: p.negoHargaN,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  ThousandsSeparatorInputFormatter(),
                ],
              ),
              const SizedBox(height: 24),
              CustomButton.mainButton(
                "Ajukan Nego",
                borderRadius: BorderRadius.circular(10),
                () async {
                  final text = p.negoHargaC.text.replaceAll('.', '');
                  if (text.isEmpty) return;
                  final price = double.tryParse(text) ?? 0;
                  
                  if (price > hargaAsli) {
                    await Utils.showFailed(msg: 'Harga nego tidak boleh melebihi harga asli produk');
                  } else {
                    CusNav.nPop(context);
                    final success = await p.requestNegoUlang(cartId: cartId);
                    if (success) {
                      refresh();
                    }
                  }
                },
              ),
            ],
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
          Icon(Icons.handshake_outlined, size: 48, color: _kTextSecondary.withOpacity(0.3)),
          const SizedBox(height: 16),
          const Text(
            'Tidak ada permintaan nego',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: _kTextSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Daftar negosiasi harga akan muncul di sini',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: _kTextSecondary.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNegoItem(NegoSellerModelData data, NegoSellerProvider p) {
    final double hargaAsli = data.product?.price ?? data.cart?.initialPrice ?? 0;
    final double hargaNegoAktif = data.negoValue ?? 0;
    final String statusNego = data.cart?.negoStatus ?? 'PENDING';
    final bool canAction = statusNego != 'DEAL' && statusNego != 'SELLER_AGREED';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
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
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Placeholder Image
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: _kBackground,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _kBorder),
                  ),
                  child: const Icon(Icons.shopping_bag_outlined, color: _kTextSecondary),
                ),
                const SizedBox(width: 16),
                // Product Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.product?.name ?? '-',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _kTextPrimary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Pembeli: ${data.buyer?.name ?? '-'}',
                        style: const TextStyle(fontSize: 12, color: _kTextSecondary),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Jumlah: ${data.cart?.qty ?? '0'} pcs',
                        style: const TextStyle(fontSize: 12, color: _kTextSecondary),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Harga Asli: Rp ${Utils.thousandSeparator(hargaAsli.toInt())}',
                        style: const TextStyle(fontSize: 12, color: _kTextSecondary, decoration: TextDecoration.lineThrough),
                      ),
                      const SizedBox(height: 8),
                      // Harga Nego Highlight
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: _kWarning.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: _kWarning.withOpacity(0.2)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Tawaran Nego Terbaru',
                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: _kWarning),
                                ),
                                Text(
                                  'Rp ${Utils.thousandSeparator(hargaNegoAktif.toInt())}',
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _kWarning),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: _kPrimary,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                statusNego,
                                style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (canAction) ...[
            Divider(height: 1, color: _kBorder.withOpacity(0.6)),
            // Action Buttons
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: _buildActionButton(
                      label: 'Tolak',
                      icon: Icons.close_rounded,
                      color: _kDanger,
                      onTap: () async {
                        if (data.id == null) return;
                        await Utils.showYesNoDialog(
                          context: context,
                          title: 'Tolak Nego',
                          desc: 'Apakah Anda yakin ingin menolak dan menghapus nego ini?',
                          yesCallback: () async {
                            CusNav.nPop(context);
                            final success = await p.acceptOrRejectNego(negoId: data.id!, isAccept: false);
                            if (success) refresh();
                          },
                          noCallback: () => CusNav.nPop(context),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildActionButton(
                      label: 'Nego Ulang',
                      icon: Icons.sync_rounded,
                      color: _kWarning,
                      onTap: () async {
                        if (data.cart?.id == null) return;
                        _showNegoDialog(context, data.cart!.id!, hargaAsli, p);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildActionButton(
                      label: 'Terima',
                      icon: Icons.check_rounded,
                      color: _kSuccess,
                      onTap: () async {
                        if (data.id == null || data.cart?.id == null) return;
                        await Utils.showYesNoDialog(
                          context: context,
                          title: 'Terima Nego',
                          desc: 'Apakah Anda yakin ingin menyetujui harga ini?',
                          yesCallback: () async {
                            CusNav.nPop(context);
                            final success = await p.acceptOrRejectNego(
                              negoId: data.id!,
                              cartId: data.cart!.id!,
                              value: data.negoValue.toString(),
                              isAccept: true,
                            );
                            if (success) refresh();
                          },
                          noCallback: () => CusNav.nPop(context),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<NegoSellerProvider>();

    return Scaffold(
      backgroundColor: _kBackground,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchBar(p),
            Expanded(
              child: RefreshIndicator(
                color: _kPrimary,
                onRefresh: refresh,
                child: negoData.isEmpty
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          SizedBox(height: MediaQuery.of(context).size.height * 0.25),
                          _buildEmptyState(),
                        ],
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        itemCount: negoData.length,
                        itemBuilder: (context, index) {
                          final item = negoData[index];
                          return _buildNegoItem(item, p);
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
