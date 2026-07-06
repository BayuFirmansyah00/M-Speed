import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:flutter_signature_pad/flutter_signature_pad.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mspeed/common/base/base_state.dart';
import 'package:mspeed/common/component/custom_appbar.dart';
import 'package:mspeed/common/helper/Constant.dart';
import 'package:mspeed/common/helper/download.dart';
import 'package:mspeed/generated/assets.dart';
import 'package:mspeed/src/penerima/pesanan/provider/penerima_pesanan_provider.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class TtdSuratPerjalananView extends StatefulWidget {
  final String name, pdfUrl, noOrder, parentId;

  TtdSuratPerjalananView(
      {required this.name,
      required this.pdfUrl,
      required this.noOrder,
      required this.parentId});

  @override
  _PdfSignatureScreenState createState() => _PdfSignatureScreenState();
}

class _PdfSignatureScreenState extends BaseState<TtdSuratPerjalananView> {
  GlobalKey<SignatureState> signKey = GlobalKey();

  String? localPdfPath;

  @override
  void initState() {
    super.initState();
    _downloadPdf();
  }

  Future<void> _downloadPdf() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/${widget.name}.pdf');
      if (!await file.exists()) {
        final response = await http.get(Uri.parse(widget.pdfUrl));
        if (response.statusCode == 200) {
          await file.writeAsBytes(response.bodyBytes);
        } else {
          throw Exception('Failed to load PDF');
        }
      }
      setState(() {
        localPdfPath = file.path;
      });
    } catch (e) {
      print('Error downloading PDF: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar.appBar(
        context,
        'Surat Jalan',
        color: Colors.white,
        isCenter: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        action: [
          IconButton(
            icon: SvgPicture.asset(Assets.svgsIcDownload),
            onPressed: () {
              downloadFile(context, widget.pdfUrl,
                  filename: widget.pdfUrl.split('/').last, typeFile: 'pdf');
            },
          ),
        ],
      ),
      body: localPdfPath == null
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  Container(
                    height: 400,
                    decoration: BoxDecoration(boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        spreadRadius: 5,
                      ),
                    ]),
                    child: PDFView(
                      filePath: localPdfPath,
                    ),
                  ),
                  SizedBox(
                    height: 32,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Tanda Tangan',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      Row(
                        children: [
                          IconButton(
                              onPressed: () {},
                              icon: Icon(
                                Icons.clear,
                                color: Colors.red,
                              )),
                          IconButton(
                              onPressed: () {},
                              icon: Icon(
                                Icons.check,
                                color: Colors.green,
                              )),
                        ],
                      )
                    ],
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(10)),
                    height: 188,
                    child: Signature(
                      key: signKey,
                      color: Colors.black87,
                      strokeWidth: 5,
                      onSign: () {},
                    ),
                  ),
                  SizedBox(height: 16.0),
                ],
              ),
            ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Constant.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
            onPressed: () async {
              final p = context.read<PenerimaPesananProvider>();
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

                if(await p.addTtdSuratJalan(
                    transaction_id: widget.parentId,
                    nomor_order: widget.noOrder,
                    image: file)) {

                  Navigator.pop(context);
                  p.fetchDetailTransaction(transaction_id: widget.parentId,);
                }
              } else {
                sign.clear();
              }

            },
            child: Text(
              'Simpan',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  void showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 60,
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Berhasil',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              Divider(),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  'Oke',
                  style: TextStyle(
                    color: Constant.primaryColor,
                    fontWeight: FontWeight.w400,
                    fontSize: 20,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
