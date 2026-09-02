import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mspeed/common/base/base_state.dart';
import 'package:mspeed/src/penerima/pesanan/model/receiver_order_model.dart';
import 'package:mspeed/src/penerima/pesanan/provider/penerima_pesanan_provider.dart';
import 'package:provider/provider.dart';

// ── Color Constants ────────────────────────────────────────────────────────
const Color _kPrimary = Color(0xFF0284C7);
const Color _kPrimaryDark = Color(0xFF0369A1);
const Color _kSuccess = Color(0xFF10B981);
const Color _kBg = Color(0xFFF8FAFC);
const Color _kSurface = Color(0xFFFFFFFF);
const Color _kTextPrimary = Color(0xFF1F2937);
const Color _kTextSecondary = Color(0xFF6B7280);
const Color _kBorder = Color(0xFFE5E7EB);

class PenerimaPesananDetailView extends StatefulWidget {
  final String? transactionId;
  final String? transaction_id; // backward compatibility

  const PenerimaPesananDetailView({
    super.key,
    this.transactionId,
    this.transaction_id,
  });

  String get id => transactionId ?? transaction_id ?? '0';

  @override
  State<PenerimaPesananDetailView> createState() => _PenerimaPesananDetailViewState();
}

class _PenerimaPesananDetailViewState extends BaseState<PenerimaPesananDetailView> {
  final _currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  final TextEditingController _titleController = TextEditingController();
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
      await context.read<PenerimaPesananProvider>().fetchOrderDetail(orderId, withLoading: true);
    }
  }

  void _showVerifyModal(BuildContext context, ReceiverOrderData order) {
    _titleController.text = 'Verifikasi Penerimaan Barang';
    _noteController.text = 'Pesanan telah diterima dan diverifikasi oleh Penerima (Receiver).';

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
            final p = context.watch<PenerimaPesananProvider>();

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
                        child: const Icon(Icons.fact_check_rounded, color: _kSuccess, size: 22),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Konfirmasi Penerimaan Barang',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: _kTextPrimary,
                              ),
                            ),
                            Text(
                              'Pastikan fisik barang telah diterima dalam kondisi baik',
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

                  // Order items brief count
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _kBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _kBorder),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Item: ${order.orderItems.length} produk (${order.totalQty} unit)',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _kTextSecondary),
                        ),
                        Text(
                          order.orderNum,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: _kPrimaryDark),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Title Field
                  const Text(
                    'Judul Verifikasi',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _kTextPrimary),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _titleController,
                    style: const TextStyle(fontSize: 13, color: _kTextPrimary),
                    decoration: InputDecoration(
                      hintText: 'Contoh: Verifikasi Penerimaan Barang',
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

                  // Note Field
                  const Text(
                    'Catatan Penerimaan (Kondisi Barang, dll.)',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _kTextPrimary),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _noteController,
                    maxLines: 3,
                    style: const TextStyle(fontSize: 13, color: _kTextPrimary),
                    decoration: InputDecoration(
                      hintText: 'Tuliskan catatan kondisi paket atau fisik barang...',
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
                  const SizedBox(height: 20),

                  // Confirm Button
                  ElevatedButton(
                    onPressed: p.isProcessing
                        ? null
                        : () async {
                            final success = await context.read<PenerimaPesananProvider>().verifyOrderReceipt(
                                  orderId: order.id,
                                  title: _titleController.text.trim(),
                                  note: _noteController.text.trim(),
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
                            'Konfirmasi Barang Telah Diterima',
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
    final p = context.watch<PenerimaPesananProvider>();
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
          'Detail Penerimaan Barang',
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
                      Icon(Icons.inventory_2_outlined, size: 60, color: Colors.grey.shade300),
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

                      // ── Card 2: Recipient Information ──────────────
                      _buildRecipientCard(order),
                      const SizedBox(height: 14),

                      // ── Card 3: Buyer Information ──────────────────
                      _buildBuyerCard(order),
                      const SizedBox(height: 14),

                      // ── Card 4: Seller Information ─────────────────
                      _buildSellerCard(order),
                      const SizedBox(height: 14),

                      // ── Card 5: Order Items List ───────────────────
                      _buildItemsCard(order),
                      const SizedBox(height: 14),

                      // ── Card 6: Order Tracking History ─────────────
                      _buildTimelineCard(order),
                      const SizedBox(height: 14),
                    ],
                  ),
                ),

      // ── Bottom Action Bar ──────────────────────────────────────────
      bottomNavigationBar: (order != null) ? _buildBottomActionBar(context, order) : null,
    );
  }

  // ── Header Card ─────────────────────────────────────────────────────────
  Widget _buildHeaderCard(ReceiverOrderData order) {
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
              Text(
                '${order.orderItems.length} Produk (${order.totalQty} Unit)',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _kTextSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Recipient Information Card ──────────────────────────────────────────
  Widget _buildRecipientCard(ReceiverOrderData order) {
    final recipient = order.recipient;
    if (recipient == null) return const SizedBox();

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
                  color: const Color(0xFF0284C7).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.location_on_rounded, color: Color(0xFF0284C7), size: 16),
              ),
              const SizedBox(width: 8),
              const Text(
                'Alamat & Data Penerima',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: _kTextPrimary),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoRow('Nama Penerima', recipient.recipientName.isNotEmpty ? recipient.recipientName : '-'),
          if (recipient.recipientPhone.isNotEmpty)
            _buildInfoRow('Nomor Telepon', recipient.recipientPhone),
          if (recipient.recipientEmail.isNotEmpty)
            _buildInfoRow('Email', recipient.recipientEmail),
          if (recipient.recipientAddress.isNotEmpty)
            _buildInfoRow('Alamat Pengiriman', recipient.recipientAddress),
        ],
      ),
    );
  }

  // ── Buyer Information Card ──────────────────────────────────────────────
  Widget _buildBuyerCard(ReceiverOrderData order) {
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
                'Informasi Buyer (Pemesan)',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: _kTextPrimary),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoRow('Nama Pemesan', buyer.buyerName.isNotEmpty ? buyer.buyerName : '-'),
        ],
      ),
    );
  }

  // ── Seller Information Card ─────────────────────────────────────────────
  Widget _buildSellerCard(ReceiverOrderData order) {
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
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.storefront_rounded, color: Color(0xFFF59E0B), size: 16),
              ),
              const SizedBox(width: 8),
              const Text(
                'Informasi Seller / Toko Pengirim',
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
  Widget _buildItemsCard(ReceiverOrderData order) {
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
                'Daftar Fisik Produk (${order.orderItems.length})',
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
                            'Kuantitas: ${item.qty} unit',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _kPrimaryDark),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      _currencyFormat.format(item.finalPrice),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _kTextPrimary,
                      ),
                    ),
                  ],
                ),
              );
            }),
          const Divider(height: 16, color: _kBorder),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Nilai Pengiriman',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _kTextPrimary),
              ),
              Text(
                _currencyFormat.format(order.grandTotal),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: _kPrimaryDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Timeline Card ───────────────────────────────────────────────────────
  Widget _buildTimelineCard(ReceiverOrderData order) {
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
                'Riwayat Status & Pengiriman',
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

  // ── Bottom Action Bar ───────────────────────────────────────────────────
  Widget _buildBottomActionBar(BuildContext context, ReceiverOrderData order) {
    final canVerify = order.canVerifyReception;

    if (canVerify) {
      return Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
        decoration: const BoxDecoration(
          color: _kSurface,
          border: Border(top: BorderSide(color: _kBorder, width: 1)),
        ),
        child: SafeArea(
          child: ElevatedButton.icon(
            onPressed: () => _showVerifyModal(context, order),
            icon: const Icon(Icons.fact_check_rounded, size: 20),
            label: const Text(
              'Konfirmasi Penerimaan Barang',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
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
      );
    }

    if (order.isReceived) {
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
                  'Barang Telah Berhasil Diterima & Diverifikasi',
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

  static String _formatDate(String isoString) {
    try {
      final dt = DateTime.parse(isoString);
      return DateFormat('dd MMMM yyyy, HH:mm', 'id_ID').format(dt);
    } catch (_) {
      return isoString;
    }
  }
}
