import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mspeed/src/buyer/transaction/model/daftar_transaksi_buyer_model.dart';

// ─── Token warna lokal ────────────────────────────────────────
class _OC {
  static const primary   = Color(0xFFE50012);
  static const bg        = Color(0xFFF4F6FB);
  static const card      = Color(0xFFFFFFFF);
  static const txt1      = Color(0xFF0D1117);
  static const txt2      = Color(0xFF4A5568);
  static const txt3      = Color(0xFF9AA5B1);
  static const border    = Color(0xFFEEF0F5);

  static BoxShadow get shadow => const BoxShadow(
    color: Color(0x0C000000),
    blurRadius: 14,
    offset: Offset(0, 5),
  );
}

class OrderItemWidget extends StatelessWidget {
  final DaftarTransaksiBuyerModelData? data;
  const OrderItemWidget({super.key, required this.data});

  String _formatCurrency(String amount) {
    final value = int.tryParse(amount) ?? 0;
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0)
        .format(value);
  }

  String _formatDate(String? raw) {
    if (raw == null || raw.length < 10) return '-';
    try {
      final dt = DateTime.parse(raw);
      return DateFormat('d MMM yyyy', 'id_ID').format(dt);
    } catch (_) {
      return raw.substring(0, 10);
    }
  }

  @override
  Widget build(BuildContext context) {
    final detail    = data?.detail?.firstOrNull;
    final sellerName = detail?.SellerNama ?? '-';
    final nomorOrder = data?.nomorOrder ?? '';
    final produkNama = detail?.nama ?? '-';
    final fotoUrl    = detail?.foto ?? '';
    final qty        = detail?.qty ?? '0';
    final harga      = detail?.hargaAkhir ?? detail?.harga ?? '0';
    final total      = data?.total ?? '0';
    final jumlah     = data?.jum ?? '0';
    final created    = _formatDate(data?.Created);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      decoration: BoxDecoration(
        color: _OC.card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [_OC.shadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header: Toko + Nomor Order ───────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0B1F4E).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.storefront_rounded,
                      size: 15, color: Color(0xFF0B1F4E)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    sellerName,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _OC.txt1,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _OC.bg,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    nomorOrder,
                    style: const TextStyle(
                      fontSize: 10,
                      color: _OC.txt3,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Divider ──────────────────────────────────────
          Container(height: 1, color: _OC.border),

          // ── Produk ───────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Foto produk
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: CachedNetworkImage(
                    imageUrl: fotoUrl,
                    width: 58,
                    height: 58,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                      color: _OC.bg,
                      child: const Center(child: SizedBox(
                        width: 16, height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )),
                    ),
                    errorWidget: (_, __, ___) => Container(
                      color: _OC.bg,
                      child: const Icon(Icons.image_not_supported_rounded,
                          color: _OC.txt3, size: 20),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        produkNama,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _OC.txt1,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        created,
                        style: const TextStyle(
                          fontSize: 11,
                          color: _OC.txt3,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _OC.bg,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'x$qty',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _OC.txt2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _formatCurrency(harga),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _OC.txt1,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── "Tampilkan Produk Lainnya" ────────────────────
          if (int.tryParse(jumlah) != null && int.parse(jumlah) > 1)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: const BoxDecoration(
                color: _OC.bg,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.expand_more_rounded, size: 14, color: _OC.txt3),
                  const SizedBox(width: 4),
                  Text(
                    '+ ${int.parse(jumlah) - 1} produk lainnya',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: _OC.txt3,
                    ),
                  ),
                ],
              ),
            ),

          // ── Footer: Total & Aksi ─────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: _OC.bg.withValues(alpha: 0.5),
              border: const Border(top: BorderSide(color: _OC.border)),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total Belanja',
                      style: TextStyle(
                        fontSize: 10,
                        color: _OC.txt3,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatCurrency(total),
                      style: const TextStyle(
                        fontSize: 14,
                        color: _OC.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: _OC.primary.withValues(alpha: 0.3)),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: _OC.primary.withValues(alpha: 0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Text(
                    'Lihat Detail',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: _OC.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
