import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../libraries/compress_image.dart';
import 'custom_button.dart';
import 'custom_container.dart';

class CustomImagePicker {
  static Future<XFile?> takeSelfie() async {
    XFile? f = await ImagePicker().pickImage(
      source: ImageSource.camera,
      maxWidth: 480,
      maxHeight: 480,
      imageQuality: Platform.isAndroid ? 55 : 1,
      preferredCameraDevice: CameraDevice.front,
    );
    return f;
  }

  static Future<XFile?> selectImageFromGallery() async {
    XFile? f = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 480,
      maxHeight: 480,
      imageQuality: Platform.isAndroid ? 55 : 1,
    );
    return f;
  }

  static Future<File?> cameraOrGallery(BuildContext context) async {
    File? f;
    await CustomContainer.showModalBottom(
      initialChildSize: 0.39,
      context: context,
      child: Column(
        children: [
          Text(
            "Pilihan",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24),
          CustomButton.mainButton("Ambil Dari Kamera", () async {
            final image = await takeSelfie();
            if (image == null) return;
            f = await compressImage(File(image.path));
            log("FILE COMPRESS : ${f?.path}");
            Navigator.pop(context);
          }),
          SizedBox(height: 8),
          CustomButton.mainButton("Ambil Dari Galeri", () async {
            final image = await selectImageFromGallery();
            if (image == null) return;
            f = File(image.path);
            Navigator.pop(context);
          }),
          SizedBox(height: 24),
        ],
      ),
    );
    return f;
  }
}
