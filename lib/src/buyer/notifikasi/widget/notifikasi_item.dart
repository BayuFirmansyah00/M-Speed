import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mspeed/generated/assets.dart';

import 'package:mspeed/common/helper/constant.dart';

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
        margin: const EdgeInsets.symmetric(horizontal: Constant.space16, vertical: 4),
        decoration: BoxDecoration(
          color: read ? Constant.dsSurface : Constant.dsPrimary.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(Constant.radiusLg),
          border: Border.all(
            color: read
                ? Constant.dsBorder
                : Constant.dsPrimary.withValues(alpha: 0.25),
            width: 1,
          ),
          boxShadow: [
            Constant.shadowSmall,
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
                          color: Constant.dsBackground,
                          borderRadius: BorderRadius.circular(Constant.radiusMd),
                        ),
                        child: const Icon(
                          Icons.image_not_supported_rounded,
                          color: Constant.dsTextSecondary,
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
                          color: Constant.dsPrimary,
                          shape: BoxShape.circle,
                          border: Border.all(color: Constant.dsSurface, width: 1.5),
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
                              fontFamily: Constant.primaryTextStyle.fontFamily,
                              color: read
                                  ? Constant.dsTextPrimary.withValues(alpha: 0.8)
                                  : Constant.dsTextPrimary,
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
                              color: Constant.dsPrimary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'Baru',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                color: Constant.dsPrimary,
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
                        fontFamily: Constant.primaryTextStyle.fontFamily,
                        color: read
                            ? Constant.dsTextSecondary
                            : Constant.dsTextPrimary.withValues(alpha: 0.75),
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Waktu
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time_rounded,
                          size: 12,
                          color: Constant.dsTextSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          datetime,
                          style: TextStyle(
                            fontFamily: Constant.primaryTextStyle.fontFamily,
                            color: Constant.dsTextSecondary,
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
