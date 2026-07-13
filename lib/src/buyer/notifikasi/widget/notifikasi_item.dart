import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mspeed/generated/assets.dart';

// ─── Palet Warna ─────────────────────────────────────────────
class _C {
  static const primary   = Color(0xFFE50012);
  static const secondary = Color(0xFF0B4177);
  static const bg        = Color(0xFFF5F5F7);
  static const card      = Color(0xFFFFFFFF);
  static const txt1      = Color(0xFF111827);
  static const txt2      = Color(0xFF6B7280);
  static const txt3      = Color(0xFF9CA3AF);
  static const border    = Color(0xFFEEEEEE);
}

class NotifikasiItem extends StatelessWidget {
  final String image;
  final String title;
  final String subtitle;
  final String datetime;
  final VoidCallback onClick;
  final String isRead;

  const NotifikasiItem({
    Key? key,
    required this.isRead,
    required this.image,
    required this.title,
    required this.subtitle,
    required this.onClick,
    required this.datetime,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool read = isRead == 'Terbaca';

    return GestureDetector(
      onTap: !read ? onClick : null,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: read ? _C.card : _C.secondary.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: read
                ? _C.border
                : _C.secondary.withValues(alpha: 0.25),
            width: read ? 1 : 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: read ? 0.02 : 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Gambar produk dengan indicator unread
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                      imageUrl: image,
                      placeholder: (context, url) => Image.asset(
                        Assets.imagesImgPlaceholder,
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                      ),
                      errorWidget: (context, url, error) => Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: _C.bg,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.image_not_supported_rounded,
                          color: _C.txt3,
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                  // Dot indicator unread
                  if (!read)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: _C.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 14),
              // Konten
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Judul + chip unread
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: TextStyle(
                              color: read
                                  ? _C.txt1.withValues(alpha: 0.8)
                                  : _C.txt1,
                              fontSize: 14,
                              fontWeight:
                                  read ? FontWeight.w500 : FontWeight.w700,
                              height: 1.4,
                            ),
                          ),
                        ),
                        if (!read) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: _C.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'Baru',
                              style: TextStyle(
                                color: _C.primary,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 5),
                    // Pesan
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: read
                            ? _C.txt2
                            : _C.txt1.withValues(alpha: 0.75),
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Waktu
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 12,
                          color: _C.txt3,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          datetime,
                          style: const TextStyle(
                            color: _C.txt3,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
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
    );
  }
}
