import 'dart:io';

import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

import '../../utils/utils.dart';
import '../base/base_state.dart';

class ImagePreview extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return ImagePreviewState();
  }
}

class ImagePreviewState extends BaseState<ImagePreview> {
  late Uri path;
  ImageProvider? img;
  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    if (args() == null || (args() as String).isEmpty) {
      Utils.showToast("Error : Image path not found!");
      Navigator.pop(context);
      return;
    }

    path = Uri.parse(args());
    if (!isFile()) path = path.replace(scheme: 'https');
    img = image() as ImageProvider;

    if ((isFile() && File(path.toString()).existsSync()) || img == null) {
      Utils.showToast("Error : Image not exist!");
      Navigator.pop(context);
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Utils.appBar("Pratinjau Gambar"),
      // extendBodyBehindAppBar: true,
      body: Container(
        color: Colors.black,
        alignment: Alignment.center,
        child: PhotoView(
          imageProvider: img!,
        ),
      ),
    );
  }

  Object? image() {
    return (isFile())
        ? FileImage(File(path.toString()))
        : NetworkImage(path.toString());
  }

  bool isFile() {
    return path.isScheme('file');
  }
}
