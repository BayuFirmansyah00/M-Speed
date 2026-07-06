import 'dart:developer';
import 'dart:io';
import 'dart:math' as m;

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

Future<File> compressImage(File file) async {
  log("UKURAN SEBELUM : ${file.lengthSync()}");
  final tempDir = await getTemporaryDirectory();
  // if (tempDir.existsSync()) {
  //   tempDir.deleteSync(recursive: true);
  // }
  String pathTemp = tempDir.path;
  // String fileName = m.Random().nextInt(100000).toString();
  var r = m.Random();
  String fileName =
      String.fromCharCodes(List.generate(10, (index) => r.nextInt(33) + 89));
  // String fileName = "tmp";
  var result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path, "$pathTemp/$fileName.jpg",
      quality: 20);
  int afterSize = await result!.length();
  log("UKURAN SESUDAH $afterSize");
  return File(result.path);
}
