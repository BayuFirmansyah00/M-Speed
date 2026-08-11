import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mspeed/common/helper/constant.dart';
import 'package:mspeed/generated/assets.dart';

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
    final bool unread = isRead != 'Terbaca';
    final bool hasValidImage = image.isNotEmpty &&
        image != '-' &&
        (image.startsWith('http://') || image.startsWith('https://'));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: unread
                ? Constant.primaryColor.withOpacity(0.4)
                : const Color(0xffE2E4E9),
            width: unread ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: unread
                  ? Constant.primaryColor.withOpacity(0.04)
                  : Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: unread ? onClick : null,
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Avatar / Foto Notifikasi
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xffE2E4E9),
                            width: 1,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(11),
                          child: hasValidImage
                              ? CachedNetworkImage(
                                  width: 52,
                                  height: 52,
                                  fit: BoxFit.cover,
                                  imageUrl: image,
                                  memCacheWidth: 150,
                                  memCacheHeight: 150,
                                  maxWidthDiskCache: 150,
                                  maxHeightDiskCache: 150,
                                  placeholder: (context, url) => Image.asset(
                                    Assets.imagesImgPlaceholder,
                                    width: 52,
                                    height: 52,
                                    fit: BoxFit.cover,
                                  ),
                                  errorWidget: (context, url, error) => Image.asset(
                                    Assets.imagesImgPlaceholder,
                                    width: 52,
                                    height: 52,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Image.asset(
                                  Assets.imagesImgPlaceholder,
                                  width: 52,
                                  height: 52,
                                  fit: BoxFit.cover,
                                ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      // Text Contents
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Color(0xff100629),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              subtitle,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xff4A5568),
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.access_time_rounded,
                                  size: 13,
                                  color: Colors.grey[500],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  datetime,
                                  style: TextStyle(
                                    color: Colors.grey[500],
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
                // Indicator Dot jika Belum Dibaca
                if (unread)
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: Constant.primaryColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Constant.primaryColor.withOpacity(0.4),
                            blurRadius: 4,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
