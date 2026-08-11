import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mspeed/common/helper/Constant.dart';
import 'package:mspeed/generated/assets.dart';

class NotifikasiItem extends StatelessWidget {
  final String image;
  final String title;
  final String subtitle;
  final String datetime;
  final VoidCallback onClick;
  final String isRead;

  const NotifikasiItem({
    super.key,
    required this.isRead,
    required this.image,
    required this.title,
    required this.subtitle,
    required this.onClick,
    required this.datetime,
  });

  bool get _isRead => isRead == 'Terbaca';

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _isRead ? null : onClick,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: _isRead ? Colors.white : Constant.primaryColor.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 16,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Accent bar untuk notifikasi belum dibaca
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 4,
              height: 92,
              decoration: BoxDecoration(
                color: _isRead ? Colors.transparent : Constant.primaryColor,
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(16),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
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
                        errorWidget: (context, url, error) => Image.asset(
                          Assets.imagesImgPlaceholder,
                          width: 56,
                          height: 56,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  title,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: _isRead
                                        ? FontWeight.w600
                                        : FontWeight.w700,
                                    color: Colors.black87,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (!_isRead)
                                Container(
                                  width: 8,
                                  height: 8,
                                  margin: const EdgeInsets.only(left: 6),
                                  decoration: BoxDecoration(
                                    color: Constant.primaryColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: _isRead
                                  ? FontWeight.w400
                                  : FontWeight.w500,
                              color: _isRead
                                  ? Colors.black.withValues(alpha: 0.5)
                                  : Colors.black.withValues(alpha: 0.7),
                              height: 1.4,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.access_time_rounded,
                                size: 12,
                                color: Colors.black.withValues(alpha: 0.35),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                datetime,
                                style: TextStyle(
                                  color: Colors.black.withValues(alpha: 0.4),
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
          ],
        ),
      ),
    );
  }
}
