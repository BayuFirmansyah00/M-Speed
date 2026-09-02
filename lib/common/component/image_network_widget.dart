import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:mspeed/utils/utils.dart';

class ImageNetworkWidget extends StatefulWidget {
  const ImageNetworkWidget(
      {super.key,
      required this.imageUrl,
      this.width = double.infinity,
      this.boxFit = BoxFit.cover,
      this.height,
      this.radius});

  final String imageUrl;
  final double width;
  final double? height;
  final double? radius;
  final BoxFit boxFit;

  @override
  State<ImageNetworkWidget> createState() => _ImageNetworkWidgetState();
}

class _ImageNetworkWidgetState extends State<ImageNetworkWidget> {
  @override
  Widget build(BuildContext context) {
    final resolvedUrl = Utils.resolveImageUrl(widget.imageUrl);

    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.radius ?? 0),
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: resolvedUrl.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: resolvedUrl,
                placeholder: (context, url) => ClipRRect(
                  borderRadius: BorderRadius.circular(widget.radius ?? 0),
                  child: Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      width: widget.width,
                      height: widget.height,
                      color: Colors.white,
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(widget.radius ?? 0),
                      color: Colors.grey[200]!),
                  child: Center(
                    child: Icon(
                      Icons.inventory_2_outlined,
                      size: (widget.height != null && widget.height! < 60) ? 20 : 32,
                      color: Colors.grey[400],
                    ),
                  ),
                ),
                fit: widget.boxFit,
              )
            : Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(widget.radius ?? 0),
                    color: Colors.grey[200]!),
                child: Center(
                  child: Icon(
                    Icons.inventory_2_outlined,
                    size: (widget.height != null && widget.height! < 60) ? 20 : 32,
                    color: Colors.grey[400],
                  ),
                ),
              ),
      ),
    );
  }
}
