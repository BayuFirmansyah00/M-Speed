import 'package:cached_network_image/cached_network_image.dart';
import 'package:mspeed/common/component/skeleton.dart';
import 'package:flutter/material.dart';

import '../base/base_state.dart';

class SafeNetworkImage extends StatefulWidget {
  late double width;
  late double height;
  final String url;
  final Widget? errorBuilder;
  BoxFit boxFit = BoxFit.cover;
  bool circle = false;
  double borderRadius = 0;

  SafeNetworkImage(
      {Key? key,
      required this.width,
      required this.height,
      required this.url,
      this.errorBuilder,
      this.boxFit = BoxFit.cover,
      this.borderRadius = 0,
      imageUrl})
      : super(key: key);

  SafeNetworkImage.circle(
      {required this.url, required double radius, this.errorBuilder}) {
    this.width = radius;
    this.height = radius;
    circle = true;
  }

  @override
  State<SafeNetworkImage> createState() => _SafeNetworkImageState();
}

class _SafeNetworkImageState extends BaseState<SafeNetworkImage> {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: widget.circle
          ? BorderRadius.circular(widget.width / 2)
          : BorderRadius.circular(widget.borderRadius),
      child: Container(
        width: widget.width,
        height: widget.height,
        child: CachedNetworkImage(
          imageUrl: widget.url,
          width: widget.width,
          height: widget.height,
          fit: widget.boxFit,
          progressIndicatorBuilder: (context, url, progress) =>
              Skeleton(child: SizedBox()),
          errorWidget: (context, url, error) {
            if (widget.errorBuilder != null) {
              return widget.errorBuilder!;
            } else {
              return Container(
                width: widget.width,
                height: widget.height,
                color: Colors.grey,
              );
            }
          },
        ),
      ),
    );
  }
}
