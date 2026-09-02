import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mspeed/common/base/base_state.dart';
import 'package:mspeed/common/component/custom_appbar.dart';
import 'package:mspeed/common/component/custom_button.dart';
import 'package:mspeed/common/component/custom_dialog.dart';
import 'package:mspeed/common/component/custom_navigator.dart';
import 'package:mspeed/common/helper/constant.dart';

import 'package:mspeed/src/seller/pesanan/model/pesanan_seller_model.dart';
import 'package:mspeed/src/seller/pesanan/provider/seller_pesanan_provider.dart';
import 'package:mspeed/utils/utils.dart';
import 'package:provider/provider.dart';

// ═══════════════════════════════════════════════════════════════════
// M-SPEED Brand Color Palette
// ═══════════════════════════════════════════════════════════════════
const Color _kPrimary = Color(0xFF1565C0);
const Color _kBackground = Color(0xFFF7F8FA);
const Color _kSurface = Color(0xFFFFFFFF);
const Color _kTextPrimary = Color(0xFF1F2937);
const Color _kTextSecondary = Color(0xFF6B7280);
const Color _kBorder = Color(0xFFE5E7EB);

class PesananSellerDetailView extends StatefulWidget {
  final String transaction_id;

  const PesananSellerDetailView({super.key, required this.transaction_id});

  @override
  State<PesananSellerDetailView> createState() =>
      _PesananSellerDetailViewState();
}

class _PesananSellerDetailViewState extends BaseState<PesananSellerDetailView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      refresh();
    });
  }

  void refresh() {
    context.read<SellerPesananProvider>().fetchDetailPesanan(
      parent_id: widget.transaction_id,
      withLoading: true,
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: _kTextPrimary,
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value, {
    bool isStatus = false,
    Color? statusColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, color: _kTextSecondary),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 6,
            child: isStatus
                ? Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: (statusColor ?? _kPrimary).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        value,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: statusColor ?? _kPrimary,
                        ),
                      ),
                    ),
                  )
                : Text(
                    value,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: _kTextPrimary,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(color: _kBorder.withOpacity(0.5), height: 32, thickness: 1);
  }

  Widget _buildOrderInfo(SellerOrderData data) {
    return Container(
      color: _kSurface,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Informasi Pesanan'),
          _buildInfoRow(
            'Status Pesanan',
            data.statusEnum.displayTitle,
            isStatus: true,
            statusColor: data.statusEnum.color,
          ),
          _buildInfoRow('Nomor Pesanan', data.orderNum ?? '-'),
          _buildInfoRow('Nomor Resi', data.receiptNum ?? '-'),
          _buildInfoRow('Tanggal Pesanan', data.createdAt ?? '-'),
          _buildInfoRow('Status Pembayaran', data.paymentStatus ?? '-'),
        ],
      ),
    );
  }

  Widget _buildBuyerInfo(SellerOrderData data) {
    final buyer = data.buyer;
    if (buyer == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(top: 8),
      color: _kSurface,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Informasi Pembeli & Pengiriman'),
          _buildInfoRow('Nama Pembeli', buyer.name ?? '-'),
          _buildInfoRow('Nama Penerima', buyer.recipientName ?? '-'),
          _buildInfoRow('No. Telepon', buyer.phone ?? '-'),
          _buildInfoRow('Alamat Pengiriman', buyer.address ?? '-'),
          _buildDivider(),
          _buildInfoRow(
            'Estimasi Pengiriman',
            '${data.shipping?.estStart ?? '-'} s/d ${data.shipping?.estEnd ?? '-'}',
          ),
          _buildInfoRow(
            'Ongkos Kirim',
            Utils.thousandSeparator((data.shipping?.cost ?? 0).toInt()),
          ),
        ],
      ),
    );
  }

  Widget _buildProductList(SellerOrderData data) {
    final items = data.items ?? [];

    return Container(
      margin: const EdgeInsets.only(top: 8),
      color: _kSurface,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Daftar Produk'),
          if (items.isEmpty)
            const Text(
              "Tidak ada produk",
              style: TextStyle(color: _kTextSecondary),
            ),
          ...items.map((item) {
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: _kBackground,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _kBorder),
                    ),
                    child: const Icon(
                      Icons.inventory_2_outlined,
                      color: _kTextSecondary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.productName ?? '-',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _kTextPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${item.qty ?? 0} x ${Utils.thousandSeparator((item.finalPrice ?? 0).toInt())}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: _kTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'Total Harga',
                        style: TextStyle(fontSize: 11, color: _kTextSecondary),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        Utils.thousandSeparator(
                          ((item.finalPrice ?? 0) * (item.qty ?? 0)).toInt(),
                        ),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: _kPrimary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildPaymentSummary(SellerOrderData data) {
    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 24),
      color: _kSurface,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Rincian Pembayaran'),
          _buildInfoRow(
            'Total Harga Produk',
            Utils.thousandSeparator(data.totalProductPrice.toInt()),
          ),
          _buildInfoRow(
            'Ongkos Kirim',
            Utils.thousandSeparator((data.shipping?.cost ?? 0).toInt()),
          ),
          _buildDivider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Pesanan',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: _kTextPrimary,
                ),
              ),
              Text(
                Utils.thousandSeparator(data.totalOrderPrice.toInt()),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: _kPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showKirimBarangDialog(BuildContext context, SellerOrderData data, SellerPesananProvider p) {
    final receiptController = TextEditingController();
    final noteController = TextEditingController();

    CustomDialog.mainDialog(
      context: context,
      title: "",
      content: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Kirim Barang Pesanan',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _kTextPrimary),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.black54, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'Masukkan nomor resi pengiriman kurir (opsional) beserta catatan.',
                style: TextStyle(fontSize: 12, color: _kTextSecondary),
              ),
              TextField(
                controller: receiptController,
                style: const TextStyle(fontSize: 14, color: _kTextPrimary),
                decoration: InputDecoration(
                  labelText: "Nomor Resi (Opsional)",
                  hintText: "Contoh: JNT123456789",
                  hintStyle: const TextStyle(fontSize: 13, color: _kTextSecondary),
                  labelStyle: const TextStyle(fontSize: 13, color: _kTextSecondary),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: noteController,
                style: const TextStyle(fontSize: 14, color: _kTextPrimary),
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: "Catatan Pengiriman (Opsional)",
                  hintText: "Catatan tambahan...",
                  hintStyle: const TextStyle(fontSize: 13, color: _kTextSecondary),
                  labelStyle: const TextStyle(fontSize: 13, color: _kTextSecondary),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: CustomButton.secondaryButton(
                      "Batal",
                      () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: CustomButton.mainButton(
                      "Kirim Sekarang",
                      () async {
                        Navigator.pop(context);
                        bool success = await p.kirimBarang(
                          parent_id: data.id.toString(),
                          receiptNum: receiptController.text,
                          note: noteController.text,
                        );
                        if (success) refresh();
                      },
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(SellerOrderData data) {
    final p = context.read<SellerPesananProvider>();
    final status = data.statusEnum;

    if (status.canAccept) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _kSurface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              Utils.showYesNoDialog(
                context: context,
                title: 'Terima Pesanan',
                desc: 'Apakah Anda yakin ingin menerima dan memproses pesanan #${data.orderNum ?? ''} ini?',
                yesCallback: () async {
                  CusNav.nPop(context);
                  bool success = await p.fetchActionPesananBaru(
                    parent_id: data.id.toString(),
                    terima: true,
                  );
                  if (success) refresh();
                },
                noCallback: () => CusNav.nPop(context),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF16A765),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Terima Pesanan',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Colors.white,
              ),
            ),
          ),
        ),
      );
    }

    if (status.canShip) {
      return Container(
        padding: const EdgeInsets.all(16),
        color: _kSurface,
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => _showKirimBarangDialog(context, data, p),
            style: ElevatedButton.styleFrom(
              backgroundColor: _kPrimary,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Kirim Barang / Input Resi',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Colors.white,
              ),
            ),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<SellerPesananProvider>();
    final data = p.detailPesanan;

    return Scaffold(
      backgroundColor: _kBackground,
      appBar: AppBar(title: const Text('Detail Pesanan')),
      body: SafeArea(
        child: (data.id == null)
            ? const Center(child: Text('Data tidak ditemukan'))
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildOrderInfo(data),
                    _buildBuyerInfo(data),
                    _buildProductList(data),
                    _buildPaymentSummary(data),
                  ],
                ),
              ),
      ),
      bottomNavigationBar: (data.id != null)
          ? _buildActionButtons(data)
          : null,
    );
  }
}
