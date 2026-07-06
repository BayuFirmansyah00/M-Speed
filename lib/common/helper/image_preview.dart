import 'package:flutter/material.dart';
// import 'package:mspeed/helper/constant.dart';
// import '../../helper/widgets.dart';

class ImagePreview extends StatefulWidget {
  final Widget image;
  const ImagePreview({Key? key, required this.image}) : super(key: key);

  @override
  State<ImagePreview> createState() => _ImagePreviewState();
}

class _ImagePreviewState extends State<ImagePreview> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // appBar: Widgets.xAppBar("Bukti Bayar", backgroundColor: black),
        body: widget.image);
  }
}
