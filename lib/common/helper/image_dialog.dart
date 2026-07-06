import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ImageDialog extends StatelessWidget {
  String imageString = "";
  bool isAsset = false;

  ImageDialog({
    Key? key,
    required this.imageString,
    required this.isAsset,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: isAsset
            ? Image.file(
                File(imageString),
                width: 200,
              )
            : CachedNetworkImage(
                imageUrl: imageString,
                width: 200,
              ),
      ),
    );
  }
}