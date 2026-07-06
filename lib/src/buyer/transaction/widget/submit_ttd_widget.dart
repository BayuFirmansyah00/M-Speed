import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_signature_pad/flutter_signature_pad.dart';
import 'package:path_provider/path_provider.dart';

class SubmitTtdWidget extends StatefulWidget {
  const SubmitTtdWidget({
    Key? key,
    required this.onSubmit,
  }) : super(key: key);
  final Function(File) onSubmit;

  @override
  State<SubmitTtdWidget> createState() => _SubmitTtdWidgetState();
}

class _SubmitTtdWidgetState extends State<SubmitTtdWidget> {
  GlobalKey<SignatureState> signKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: Icon(Icons.close),
            ),
          ),
          SizedBox(height: 16.0),
          Container(
            decoration: BoxDecoration(color: Colors.white, boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 5,
              ),
            ]),
            height: 188,
            child: Signature(
              key: signKey,
              color: Colors.black87,
              strokeWidth: 5,
              onSign: () {},
            ),
          ),
          SizedBox(height: 16.0),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
            onPressed: () async {
              final sign = signKey.currentState!;
              final image = await sign.getData();
              var data = await image.toByteData(format: ImageByteFormat.png);
              final dir = await getTemporaryDirectory();

              if (data != null) {
                final file = File('${dir.path}/signature.png');
                if (file.existsSync()) {
                  file.deleteSync();
                }
                file.writeAsBytesSync(data.buffer.asUint8List(), flush: true);
                sign.clear();
                widget.onSubmit(file);
                Navigator.pop(context, file.path);
              } else {
                sign.clear();
              }

              // if (_image != null) {
              //   widget.onSubmit(_image!);
              //   Navigator.of(context).pop();
              // }
            },
            child: Text(
              'Submit Tanda Tangan',
              style: TextStyle(color: Colors.white),
            ),
          ),
          SizedBox(height: 8.0),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: BorderSide(color: Colors.red),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
            onPressed: () {
              final sign = signKey.currentState!;
              sign.clear();
            },
            child: Text('Hapus Tanda Tangan'),
          ),
        ],
      ),
    );
  }
}
