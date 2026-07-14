import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_signature_pad/flutter_signature_pad.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mspeed/common/base/base_state.dart';
import 'package:mspeed/common/component/custom_appbar.dart';
import 'package:mspeed/common/component/custom_textField.dart';
import 'package:mspeed/common/helper/Constant.dart';
import 'package:mspeed/src/seller/pesanan/model/detail_pesanan_seller_model.dart';
import 'package:mspeed/src/seller/pesanan/provider/seller_pesanan_provider.dart';
import 'package:mspeed/utils/utils.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:provider/provider.dart';

import 'pesanan_buat_surat_view.dart';

class UploadLampiranView extends StatefulWidget {
  final DetailPesananSellerModel data;

  UploadLampiranView({required this.data});

  @override
  _PdfSignatureScreenState createState() => _PdfSignatureScreenState();
}

class _PdfSignatureScreenState extends BaseState<UploadLampiranView> {
  GlobalKey<SignatureState> signKey = GlobalKey();
  bool productExpanded = false;

  @override
  void initState() {
    super.initState();
  }

  final catatanC = TextEditingController();
  final List<ProductCatatan> products = [];
  final List<OtherFile> files = [OtherFile(), OtherFile()];
  XFile? faktur, eNota;

  @override
  Widget build(BuildContext context) {
    Widget fileButton({String? title, required Function(XFile) onChoose}) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (title != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                title,
                style: Constant.primaryTextStyle.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          InkWell(
            onTap: () async {
              final result = await FilePicker.pickFiles(
                allowMultiple: false,
              );
              if (result != null) {
                final file = result.files.singleOrNull;
                print('Selected file: ${result.files.singleOrNull?.name}');

                if (file != null) {
                  onChoose(file.xFile);
                }
              }
            },
            child: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border.all(
                  width: 0.5,
                  color: Constant.borderSearchColor,
                  style: BorderStyle.solid,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Upload'),
                  Icon(Icons.cloud_upload, color: Colors.grey),
                ],
              ),
            ),
          ),
        ],
      );
    }

    Widget ttd() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tanda Tangan Kwitansi',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      signKey.currentState?.clear();
                    },
                    icon: Icon(Icons.clear, color: Colors.red),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.check, color: Colors.green),
                  ),
                ],
              ),
            ],
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(10),
            ),
            height: 188,
            child: Signature(
              key: signKey,
              color: Colors.black87,
              strokeWidth: 5,
              onSign: () {},
            ),
          ),
        ],
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar.appBar(
        context,
        'Upload Lampiran',
        color: Colors.white,
        isCenter: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            ttd(),
            SizedBox(height: 16),
            FileButton(
              title: 'Upload Faktur',
              onChoose: (v) {
                setState(() {
                  faktur = v;
                });
              },
            ),
            SizedBox(height: 16),
            FileButton(
              title: 'Upload E-Nofa',
              onChoose: (v) {
                setState(() {
                  eNota = v;
                });
              },
            ),
            SizedBox(height: 16.0),
            Text(
              'Upload Dokumen Lain',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            ListView.builder(
              itemBuilder: (ctx, i) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: CustomTextField.borderTextField(
                          required: files[i].file != null,
                          hintText: 'Nama File',
                          controller: files[i].controller,
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: FileButton(
                          onChoose: (v) {
                            setState(() {
                              files[i].file = v;
                            });
                          },
                        ),
                        flex: 1,
                      ),
                      SizedBox(width: 8),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            files.removeAt(i);
                          });
                        },
                        icon: Icon(Icons.delete),
                        color: Constant.primaryColor,
                      ),
                    ],
                  ),
                );
              },
              itemCount: files.length,
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: InkWell(
                onTap: () {
                  setState(() {
                    files.add(OtherFile());
                  });
                },
                child: Row(
                  children: [
                    Icon(Icons.add, color: Constant.primaryColor),
                    SizedBox(width: 8),
                    Text(
                      'Tambah File',
                      style: TextStyle(color: Constant.primaryColor),
                    ),
                  ],
                ),
              ),
            ),
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
              if (faktur == null || eNota == null) {
                showErrorDialog(
                  context,
                  'Lengkapi Faktur & E-Nofa Terlebih Dahulu',
                );
                return;
              }

              final p = context.read<SellerPesananProvider>();
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

                final successTtd = await p.addTtdPemesanan(
                  transaction_id: widget.data.data?.ParentOrderModel?.ID ?? '',
                  nomor_order:
                      widget.data.data?.ParentOrderModel?.nomorOrder ?? '',
                  suratType: SuratType.KWITANSI,
                  image: file,
                );

                if (!successTtd) return;

                // final List<File> others = [];
                // files.forEach((element) {
                //   if (element.file != null) {
                //     others.add(File(element.file!.path));
                //   }
                // });

                final success = await p.uploadLampiran(
                  transaction_id: widget.data.data?.ParentOrderModel?.ID ?? '',
                  faktur: File(faktur?.path ?? ''),
                  eNota: File(eNota?.path ?? ''),
                  lainnya: files,
                );
                if (!success) return;

                // widget.onSubmit(file);
                if (successTtd) {
                  Navigator.pop(context);
                  p.fetchDetailPesanan(
                    parent_id: widget.data.data?.ParentOrderModel?.ID ?? '',
                  );
                }
              } else {
                sign.clear();
              }

              showSuccessDialog(context);
            },
            child: Text('Simpan', style: TextStyle(color: Colors.white)),
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
                    Icon(Icons.check_circle, color: Colors.green, size: 60),
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

class OtherFile {
  XFile? file;
  final controller = TextEditingController();

  OtherFile({this.file});
}

class FileButton extends StatefulWidget {
  const FileButton({super.key, this.title, required this.onChoose});

  final String? title;
  final Function(XFile) onChoose;

  @override
  State<FileButton> createState() => _FileButtonState();
}

class _FileButtonState extends State<FileButton> {
  XFile? file;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.title != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              widget.title!,
              style: Constant.primaryTextStyle.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        InkWell(
          onTap: () async {
            final result = await FilePicker.pickFiles(
              allowMultiple: false,
            );
            if (result != null) {
              final file = result.files.singleOrNull;
              print('Selected file: ${result.files.singleOrNull?.name}');

              if (file != null) {
                setState(() {
                  widget.onChoose(file.xFile);
                  this.file = file.xFile;
                });
              }
            }
          },
          child: Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              border: Border.all(
                width: 0.5,
                color: Constant.borderSearchColor,
                style: BorderStyle.solid,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: AutoSizeText(
                    file == null ? 'Upload' : file!.name,
                    maxLines: 1,
                  ),
                ),
                SizedBox(width: 4),
                Icon(Icons.cloud_upload, color: Colors.grey),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
