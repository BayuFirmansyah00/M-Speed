import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:path/path.dart';
import 'package:async/async.dart';
import 'package:path/path.dart' as p;
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart';

Future<http.MultipartFile> getMultipart(String field, File? _image) async {
  var imageFile = _image;
  // ignore: deprecated_member_use
  if (_image != null) {
    var stream = http.ByteStream(DelegatingStream.typed(imageFile!.openRead()));
    var length = await _image.length();

    final bytes = await _image.readAsBytes();
    String extension = p.extension(_image.path).toLowerCase();

    // Menentukan contentType berdasarkan ekstensi
    MediaType mediaType;
    switch (extension) {
      case '.jpg':
      case '.jpeg':
        mediaType = MediaType('image', 'jpeg');
        break;
      case '.png':
        mediaType = MediaType('image', 'png');
        break;
      default:
        throw Exception('Tipe file tidak didukung: $extension');
    }

    var multipartFile = http.MultipartFile.fromBytes(
      field,
      bytes,
      filename: basename(_image.path),
      contentType: mediaType,
    );
    // http.MultipartFile(
    //   field,
    //   stream,
    //   length,
    //   filename: basename(imageFile.path),
    // );
    return multipartFile;
  }

  return http.MultipartFile.fromBytes(
    field,
    [],
    contentType: MediaType('image', 'png'),
    filename: '',
  );
}
