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
                onChanged: (_) => setState(() {}),
              ),
            ),
            if (searchController.text.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.close_rounded, color: _kTextSecondary, size: 18),
                onPressed: () {
                  searchController.clear();
                  FocusScope.of(context).unfocus();
                  setState(() {});
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
                  if (p.isProcessingAction) return;

                  final price = NegoSellerProvider.parsePriceInput(p.negoHargaC.text);
                  if (price == null || price <= 0) {
                    await Utils.showFailed(msg: 'Masukkan nominal harga nego yang valid (lebih dari 0)');
                    return;
                  }

                  CusNav.nPop(context);
                  final success = await p.requestNegoUlang(cartId: cartId);
                  if (success) {
                    refresh();
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
    final String statusNego = (data.cart?.negoStatus ?? 'PENDING').trim();
    final String upperStatus = statusNego.toUpperCase();

    // Tentukan badge status & warna
    Color badgeColor;
    String badgeText;
    if (upperStatus == 'DEAL' || upperStatus == 'SELLER_AGREED') {
      badgeColor = _kSuccess;
      badgeText = 'DEAL';
    } else if (upperStatus == 'SUBMITTED_BY_BUYER') {
      badgeColor = _kWarning;
      badgeText = 'Tawaran Buyer';
    } else if (upperStatus == 'COUNTER_BY_SELLER') {
      badgeColor = _kPrimary;
      badgeText = 'Menunggu Buyer';
    } else {
      badgeColor = _kTextSecondary;
      badgeText = statusNego;
    }

    // Action hanya aktif jika status SUBMITTED_BY_BUYER atau belum deal/counter
    final bool canAction = upperStatus == 'SUBMITTED_BY_BUYER' ||
        (upperStatus != 'DEAL' && upperStatus != 'SELLER_AGREED' && upperStatus != 'COUNTER_BY_SELLER');

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
                // Product Image / Placeholder
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: _kBackground,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _kBorder),
                    ),
                    child: (data.product?.imageUrl != null && data.product!.imageUrl!.isNotEmpty)
                        ? Image.network(
                            data.product!.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(Icons.shopping_bag_outlined, color: _kTextSecondary),
                          )
                        : const Icon(Icons.shopping_bag_outlined, color: _kTextSecondary),
                  ),
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
                        'Harga Asli: ${Utils.thousandSeparator(hargaAsli.toInt())}',
                        style: const TextStyle(fontSize: 12, color: _kTextSecondary, decoration: TextDecoration.lineThrough),
                      ),
                      const SizedBox(height: 8),
                      // Harga Nego Highlight
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: badgeColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: badgeColor.withOpacity(0.2)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  upperStatus == 'DEAL' ? 'Harga Deal' : 'Tawaran Nego Terbaru',
                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: badgeColor),
                                ),
                                Text(
                                  Utils.thousandSeparator(hargaNegoAktif.toInt()),
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: badgeColor),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: badgeColor,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                badgeText,
                                style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            )
                          ],
                        ),
                      ),
                      if (data.cart?.buyerNote != null &&
                          data.cart!.buyerNote!.trim().isNotEmpty &&
                          data.cart!.buyerNote!.trim().toLowerCase() != 'null') ...[
                        const SizedBox(height: 6),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.blue.shade100),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.chat_bubble_outline_rounded, size: 14, color: _kPrimary),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  'Catatan Buyer: "${data.cart!.buyerNote!.trim()}"',
                                  style: const TextStyle(fontSize: 11, color: _kTextPrimary, fontStyle: FontStyle.italic),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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
                      onTap: () {
                        if (data.id == null) return;
                        Utils.showYesNoDialog(
                          context: context,
                          title: 'Tolak Nego',
                          desc: 'Apakah Anda yakin ingin menolak pengajuan harga nego ini?',
                          yesCallback: () async {
                            CusNav.nPop(context);
                            final success = await p.acceptOrRejectNego(
                              withLoading: true,
                              negoId: data.id!,
                              isAccept: false,
                            );
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
                      icon: Icons.edit_note_rounded,
                      color: _kPrimary,
                      onTap: () {
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
                      onTap: () {
                        if (data.id == null) return;
                        Utils.showYesNoDialog(
                          context: context,
                          title: 'Terima Nego',
                          desc: 'Setujui penawaran harga sebesar ${Utils.thousandSeparator(hargaNegoAktif.toInt())}?',
                          yesCallback: () async {
                            CusNav.nPop(context);
                            final success = await p.acceptOrRejectNego(
                              withLoading: true,
                              negoId: data.id!,
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
    final allData = p.negoSellerModel.data ?? [];
    final search = searchController.text.toLowerCase().trim();
    final displayedData = search.isEmpty
        ? allData
        : allData.where((element) {
            final productName = (element.product?.name ?? '').toLowerCase();
            final buyerName = (element.buyer?.name ?? '').toLowerCase();
            return productName.contains(search) || buyerName.contains(search);
          }).toList();

    return Scaffold(
      backgroundColor: _kBackground,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchBar(p),
            Expanded(
              child: p.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      color: _kPrimary,
                      onRefresh: refresh,
                      child: displayedData.isEmpty
                          ? ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              children: [
                                SizedBox(height: MediaQuery.of(context).size.height * 0.25),
                                _buildEmptyState(),
                              ],
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              itemCount: displayedData.length,
                              itemBuilder: (context, index) {
                                final item = displayedData[index];
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
