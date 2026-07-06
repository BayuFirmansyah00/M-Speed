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
    return InkWell(
      onTap: isRead != 'Terbaca' ? onClick : null,
      child: Container(
        color: isRead == 'Terbaca'
            ? Colors.white
            : Color(0xFF8B2B0D).withOpacity(.05),
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            SizedBox(
              height: 16,
            ),
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: CachedNetworkImage(
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    imageUrl: image,
                    placeholder: (context, url) => Image.asset(
                      Assets.imagesImgPlaceholder,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                    errorWidget: (context, url, error) => Image.asset(
                      Assets.imagesImgPlaceholder,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: Constant.iBlackMedium16),
                      Text(subtitle, style: Constant.iBlackMedium12),
                      const SizedBox(height: 4),
                      Text(
                        '$datetime',
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 16,
            ),
            Divider(
              color: Colors.blueGrey[100],
            )
          ],
        ),
      ),
    );
  }
}
