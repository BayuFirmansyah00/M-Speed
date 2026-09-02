import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mspeed/common/base/base_state.dart';
import 'package:mspeed/src/keuangan/pesanan/model/finance_order_model.dart';
import 'package:mspeed/src/keuangan/pesanan/provider/keuangan_provider.dart';
import 'package:mspeed/utils/utils.dart';
import 'package:provider/provider.dart';

// ── Color Constants ────────────────────────────────────────────────────────
const Color _kPrimary = Color(0xFFD97706);
const Color _kPrimaryDark = Color(0xFFB45309);
const Color _kSuccess = Color(0xFF10B981);
const Color _kDanger = Color(0xFFEF4444);
const Color _kBg = Color(0xFFF8FAFC);
const Color _kSurface = Color(0xFFFFFFFF);
const Color _kTextPrimary = Color(0xFF1F2937);
const Color _kTextSecondary = Color(0xFF6B7280);
const Color _kBorder = Color(0xFFE5E7EB);

class KeuanganPesananDetailView extends StatefulWidget {
  final String? transactionId;
  final String? transaction_id; // backward compatibility

  const KeuanganPesananDetailView({
    super.key,
    this.transactionId,
    this.transaction_id,
  });

  String get id => transactionId ?? transaction_id ?? '0';

  @override
  State<KeuanganPesananDetailView> createState() => _KeuanganPesananDetailViewState();
}

class _KeuanganPesananDetailViewState extends BaseState<KeuanganPesananDetailView> {
  final _currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  final _picker = ImagePicker();
  File? _pickedProofFile;
  final TextEditingController _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDetail();
    });
  }

  Future<void> _loadDetail() async {
    final orderId = int.tryParse(widget.id) ?? 0;
    if (orderId > 0) {
      await context.read<KeuanganProvider>().fetchOrderDetail(orderId, withLoading: true);
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        imageQuality: 85,
      );
      if (picked != null) {
        setState(() {
          _pickedProofFile = File(picked.path);
        });
      }
    } catch (e) {
      Utils.showFailed(msg: 'Gagal memilih gambar: $e');
    }
  }

  void _showProcessPaymentDialog(BuildContext context, FinanceOrderData order) {
    _noteController.clear();
    _pickedProofFile = null;

    showModalBottomSheet(
      backgroundColor: _kSurface,
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext modalContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            final p = context.watch<KeuanganProvider>();

            return Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                12,
                20,
                MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE4E6EF),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _kSuccess.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.payments_rounded, color: _kSuccess, size: 22),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Konfirmasi Pembayaran Pesanan',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: _kTextPrimary,
                              ),
                            ),
                            Text(
                              'Catat dan validasi pembayaran pesanan',
                              style: TextStyle(fontSize: 11, color: _kTextSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Divider(color: _kBorder),
                  const SizedBox(height: 12),

                  // Total Tagihan Info
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: _kBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _kBorder),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Nominal Tagihan:',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _kTextSecondary),
                        ),
                        Text(
                          _currencyFormat.format(order.grandTotal),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: _kPrimaryDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Note Field
                  const Text(
                    'Catatan Pembayaran (Opsional)',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _kTextPrimary),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _noteController,
                    maxLines: 2,
                    style: const TextStyle(fontSize: 13, color: _kTextPrimary),
                    decoration: InputDecoration(
                      hintText: 'Masukkan no. referensi transfer atau catatan...',
                      hintStyle: const TextStyle(color: _kTextSecondary, fontSize: 12),
                      fillColor: _kBg,
                      filled: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: _kBorder),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: _kBorder),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: _kPrimary, width: 1.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Upload Bukti Pembayaran Section
                  const Text(
                    'Unggah Bukti Transfer / Pembayaran (Opsional)',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _kTextPrimary),
                  ),
                  const SizedBox(height: 6),

                  if (_pickedProofFile != null)
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _kBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _kBorder),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              _pickedProofFile!,
                              width: 48,
                              height: 48,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Bukti Terpilih',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _kTextPrimary),
                                ),
                                Text(
                                  _pickedProofFile!.path.split(Platform.pathSeparator).last,
                                  style: const TextStyle(fontSize: 11, color: _kTextSecondary),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close_rounded, color: _kDanger, size: 20),
                            onPressed: () {
                              setModalState(() {
                                _pickedProofFile = null;
                              });
                            },
                          ),
                        ],
                      ),
                    )
                  else
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              await _pickImage(ImageSource.gallery);
                              setModalState(() {});
                            },
                            icon: const Icon(Icons.photo_library_rounded, size: 18),
                            label: const Text('Dari Galeri', style: TextStyle(fontSize: 12)),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: _kTextPrimary,
                              side: const BorderSide(color: _kBorder),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              await _pickImage(ImageSource.camera);
                              setModalState(() {});
                            },
                            icon: const Icon(Icons.camera_alt_rounded, size: 18),
                            label: const Text('Ambil Foto', style: TextStyle(fontSize: 12)),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: _kTextPrimary,
                              side: const BorderSide(color: _kBorder),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 20),

                  // Submit Payment Button
                  ElevatedButton(
                    onPressed: p.isProcessing
                        ? null
                        : () async {
                            final success = await context.read<KeuanganProvider>().processPayment(
                                  orderId: order.id,
                                  note: _noteController.text.trim(),
                                  proofFile: _pickedProofFile,
                                );
                            if (success && mounted) {
                              Navigator.pop(modalContext);
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _kSuccess,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: p.isProcessing
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Text(
                            'Konfirmasi Pembayaran Selesai',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
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

  void _showRejectDialog(BuildContext context, FinanceOrderData order) {
    _noteController.clear();

    showModalBottomSheet(
      backgroundColor: _kSurface,
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext modalContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            final p = context.watch<KeuanganProvider>();

            return Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                12,
                20,
                MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE4E6EF),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _kDanger.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.cancel_rounded, color: _kDanger, size: 22),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tolak Pembayaran Pesanan',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: _kTextPrimary,
                              ),
                            ),
                            Text(
                              'Beri alasan penolakan pembayaran tagihan',
                              style: TextStyle(fontSize: 11, color: _kTextSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Divider(color: _kBorder),
                  const SizedBox(height: 12),

                  const Text(
                    'Alasan Penolakan',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _kTextPrimary),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _noteController,
                    maxLines: 3,
                    style: const TextStyle(fontSize: 13, color: _kTextPrimary),
                    decoration: InputDecoration(
                      hintText: 'Tuliskan alasan mengapa pembayaran ditolak...',
                      hintStyle: const TextStyle(color: _kTextSecondary, fontSize: 12),
                      fillColor: _kBg,
                      filled: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: _kBorder),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: _kBorder),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: _kDanger, width: 1.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: p.isProcessing
                        ? null
                        : () async {
                            if (_noteController.text.trim().isEmpty) {
                              Utils.showFailed(msg: 'Harap masukkan alasan penolakan.');
                              return;
                            }
                            final success = await context.read<KeuanganProvider>().rejectPayment(
                                  orderId: order.id,
                                  note: _noteController.text.trim(),
                                );
                            if (success && mounted) {
                              Navigator.pop(modalContext);
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _kDanger,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: p.isProcessing
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Text(
                            'Tolak Pembayaran',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
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

  @override
  Widget build(BuildContext context) {
    final p = context.watch<KeuanganProvider>();
    final order = p.selectedOrder;

    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        backgroundColor: _kSurface,
        surfaceTintColor: _kSurface,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: _kTextPrimary, size: 22),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Detail Transaksi Keuangan',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: _kTextPrimary,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: _kBorder),
        ),
      ),
      body: p.isLoadingDetail
          ? const Center(
              child: CircularProgressIndicator(color: _kPrimary),
            )
          : order == null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.receipt_long_rounded, size: 60, color: Colors.grey.shade300),
                      const SizedBox(height: 12),
                      const Text(
                        'Data pesanan tidak ditemukan',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _kTextSecondary),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: _loadDetail,
                        child: const Text('Muat Ulang', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  color: _kPrimary,
                  onRefresh: _loadDetail,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                    children: [
                      // ── Card 1: Order Header ───────────────────────
                      _buildHeaderCard(order),
                      const SizedBox(height: 14),

                      // ── Card 2: Buyer & Recipient Info ─────────────
                      _buildBuyerCard(order),
                      const SizedBox(height: 14),

                      // ── Card 3: Seller Info ────────────────────────
                      _buildSellerCard(order),
                      const SizedBox(height: 14),

                      // ── Card 4: Order Items List ───────────────────
                      _buildItemsCard(order),
                      const SizedBox(height: 14),

                      // ── Card 5: Payment Summary ────────────────────
                      _buildPaymentSummaryCard(order),
                      const SizedBox(height: 14),

                      // ── Card 6: Order Tracking History ─────────────
                      _buildTimelineCard(order),
                      const SizedBox(height: 14),

                      // ── Card 7: Payment Proofs (if any) ────────────
                      if (order.paymentProofs.isNotEmpty) ...[
                        _buildPaymentProofCard(order),
                        const SizedBox(height: 14),
                      ],
                    ],
                  ),
                ),

      // ── Bottom Action Bar ──────────────────────────────────────────
      bottomNavigationBar: (order != null) ? _buildBottomActionBar(context, order) : null,
    );
  }

  // ── Header Card ─────────────────────────────────────────────────────────
  Widget _buildHeaderCard(FinanceOrderData order) {
    final statusColor = order.statusBadgeColor;
    final statusLabel = order.statusDisplayLabel;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Nomor Order',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _kTextSecondary),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      order.orderNum,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: _kTextPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: _kBorder),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                order.createdAt != null ? _formatDate(order.createdAt!) : '-',
                style: const TextStyle(fontSize: 12, color: _kTextSecondary),
              ),
              if (order.prkSubmissionId != null)
                Text(
                  'PRK ID: #${order.prkSubmissionId}',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _kTextSecondary),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Buyer & Recipient Card ──────────────────────────────────────────────
  Widget _buildBuyerCard(FinanceOrderData order) {
    final buyer = order.buyer;
    if (buyer == null) return const SizedBox();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.person_rounded, color: Color(0xFF3B82F6), size: 16),
              ),
              const SizedBox(width: 8),
              const Text(
                'Informasi Buyer & Penerima',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: _kTextPrimary),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoRow('Nama Buyer', buyer.buyerName.isNotEmpty ? buyer.buyerName : '-'),
          if (buyer.recipientName.isNotEmpty && buyer.recipientName != buyer.buyerName)
            _buildInfoRow('Nama Penerima', buyer.recipientName),
          if (buyer.recipientPhone.isNotEmpty)
            _buildInfoRow('Telepon Penerima', buyer.recipientPhone),
          if (buyer.recipientAddress.isNotEmpty)
            _buildInfoRow('Alamat Pengiriman', buyer.recipientAddress),
        ],
      ),
    );
  }

  // ── Seller Card ─────────────────────────────────────────────────────────
  Widget _buildSellerCard(FinanceOrderData order) {
    final seller = order.seller;
    if (seller == null) return const SizedBox();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: _kPrimary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.storefront_rounded, color: _kPrimary, size: 16),
              ),
              const SizedBox(width: 8),
              const Text(
                'Informasi Seller / Rekening',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: _kTextPrimary),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoRow('Perusahaan Seller', seller.companyName.isNotEmpty ? seller.companyName : '-'),
          if (seller.phone.isNotEmpty) _buildInfoRow('Telepon Seller', seller.phone),
          if (seller.email.isNotEmpty) _buildInfoRow('Email Seller', seller.email),
          if (seller.address.isNotEmpty) _buildInfoRow('Alamat Seller', seller.address),
        ],
      ),
    );
  }

  // ── Order Items Card ────────────────────────────────────────────────────
  Widget _buildItemsCard(FinanceOrderData order) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.inventory_2_rounded, color: Color(0xFF10B981), size: 16),
              ),
              const SizedBox(width: 8),
              Text(
                'Daftar Produk (${order.orderItems.length})',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: _kTextPrimary),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (order.orderItems.isEmpty)
            const Text(
              'Tidak ada item dalam pesanan ini.',
              style: TextStyle(fontSize: 12, color: _kTextSecondary),
            )
          else
            ...order.orderItems.map((item) {
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _kBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _kBorder),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.productName,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: _kTextPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${item.qty} x ${_currencyFormat.format(item.initialPrice)}',
                            style: const TextStyle(fontSize: 11, color: _kTextSecondary),
                          ),
                          if (item.tax > 0)
                            Text(
                              'Pajak: ${_currencyFormat.format(item.tax)}',
                              style: const TextStyle(fontSize: 11, color: _kTextSecondary),
                            ),
                        ],
                      ),
                    ),
                    Text(
                      _currencyFormat.format(item.finalPrice),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: _kTextPrimary,
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  // ── Payment Summary Card ────────────────────────────────────────────────
  Widget _buildPaymentSummaryCard(FinanceOrderData order) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: _kPrimary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.account_balance_wallet_rounded, color: _kPrimary, size: 16),
              ),
              const SizedBox(width: 8),
              const Text(
                'Rincian Pembayaran',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: _kTextPrimary),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildSummaryRow('Subtotal Produk', _currencyFormat.format(order.subtotalItems)),
          _buildSummaryRow('Ongkos Kirim', _currencyFormat.format(order.shippingCost)),
          const Divider(height: 16, color: _kBorder),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Tagihan',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: _kTextPrimary),
              ),
              Text(
                _currencyFormat.format(order.grandTotal),
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: _kPrimaryDark,
                ),
              ),
            ],
          ),
          if (order.finance?.financeName != null && order.finance!.financeName!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: _kSuccess.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.verified_user_rounded, color: _kSuccess, size: 16),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Diproses oleh Finance: ${order.finance!.financeName}',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: _kSuccess),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Timeline Card ───────────────────────────────────────────────────────
  Widget _buildTimelineCard(FinanceOrderData order) {
    final logs = order.orderLogs;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.history_rounded, color: Color(0xFF6366F1), size: 16),
              ),
              const SizedBox(width: 8),
              const Text(
                'Riwayat Status Pesanan',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: _kTextPrimary),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (logs.isEmpty)
            const Text(
              'Belum ada riwayat aktivitas.',
              style: TextStyle(fontSize: 12, color: _kTextSecondary),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: logs.length,
              itemBuilder: (context, index) {
                final log = logs[index];
                final isLast = index == logs.length - 1;

                return IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: index == 0 ? _kPrimary : const Color(0xFF9CA3AF),
                              shape: BoxShape.circle,
                            ),
                          ),
                          if (!isLast)
                            Expanded(
                              child: Container(
                                width: 2,
                                color: const Color(0xFFE5E7EB),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                log.status.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: index == 0 ? _kTextPrimary : _kTextSecondary,
                                ),
                              ),
                              if (log.note != null && log.note!.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(
                                  log.note!,
                                  style: const TextStyle(fontSize: 11, color: _kTextSecondary),
                                ),
                              ],
                              if (log.createdAt != null) ...[
                                const SizedBox(height: 2),
                                Text(
                                  _formatDate(log.createdAt!),
                                  style: const TextStyle(fontSize: 10, color: Color(0xFF9CA3AF)),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  // ── Payment Proof Card ──────────────────────────────────────────────────
  Widget _buildPaymentProofCard(FinanceOrderData order) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: _kSuccess.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.receipt_rounded, color: _kSuccess, size: 16),
              ),
              const SizedBox(width: 8),
              const Text(
                'Bukti Pembayaran Terlampir',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: _kTextPrimary),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...order.paymentProofs.map((proof) {
            return InkWell(
              onTap: () {
                if (proof.fileUrl != null && proof.fileUrl!.isNotEmpty) {
                  Navigator.pushNamed(
                    context,
                    '/showImage',
                    arguments: proof.fileUrl!,
                  );
                }
              },
              borderRadius: BorderRadius.circular(10),
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _kBg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _kBorder),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.image_rounded, color: _kPrimary, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        proof.title.isNotEmpty ? proof.title : 'Bukti Pembayaran',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _kTextPrimary),
                      ),
                    ),
                    const Icon(Icons.open_in_new_rounded, size: 16, color: _kTextSecondary),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // ── Bottom Action Bar ───────────────────────────────────────────────────
  Widget _buildBottomActionBar(BuildContext context, FinanceOrderData order) {
    final canPay = order.canProcessPayment;

    if (canPay) {
      return Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
        decoration: const BoxDecoration(
          color: _kSurface,
          border: Border(top: BorderSide(color: _kBorder, width: 1)),
        ),
        child: SafeArea(
          child: Row(
            children: [
              // Reject Payment
              Expanded(
                flex: 2,
                child: OutlinedButton(
                  onPressed: () => _showRejectDialog(context, order),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _kDanger,
                    side: const BorderSide(color: _kDanger, width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text(
                    'Tolak',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Process Payment (Approve & Pay)
              Expanded(
                flex: 3,
                child: ElevatedButton.icon(
                  onPressed: () => _showProcessPaymentDialog(context, order),
                  icon: const Icon(Icons.payments_rounded, size: 18),
                  label: const Text(
                    'Bayar Pesanan',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kSuccess,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (order.isPaid) {
      return Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
        decoration: const BoxDecoration(
          color: _kSurface,
          border: Border(top: BorderSide(color: _kBorder, width: 1)),
        ),
        child: SafeArea(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: _kSuccess.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _kSuccess.withValues(alpha: 0.3)),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle_rounded, color: _kSuccess, size: 18),
                SizedBox(width: 8),
                Text(
                  'Pesanan Telah Selesai Dibayar',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: _kSuccess),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return const SizedBox();
  }

  // ── Helper Widgets ──────────────────────────────────────────────────────
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontSize: 11, color: _kTextSecondary),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _kTextPrimary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: _kTextSecondary)),
          Text(
            value,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _kTextPrimary),
          ),
        ],
      ),
    );
  }

  static String _formatDate(String isoString) {
    try {
      final dt = DateTime.parse(isoString);
      return DateFormat('dd MMMM yyyy, HH:mm', 'id_ID').format(dt);
    } catch (_) {
      return isoString;
    }
  }
}
