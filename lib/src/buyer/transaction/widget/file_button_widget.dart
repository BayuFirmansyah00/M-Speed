import 'package:flutter/material.dart';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mspeed/common/component/custom_navigator.dart';
import 'package:mspeed/common/helper/Constant.dart';
import 'package:mspeed/src/buyer/transaction/provider/transaction_provider.dart';
import 'package:mspeed/utils/utils.dart';
import 'package:provider/provider.dart';

class FileButtonWidget extends StatefulWidget {
  const FileButtonWidget({super.key, required this.onSave});

  final Function() onSave;

  @override
  State<FileButtonWidget> createState() => _FileButtonWidgetState();
}

class _FileButtonWidgetState extends State<FileButtonWidget> {
  XFile? file;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 8),
          Row(
            children: [
              InkWell(
                  onTap: () => CusNav.nPop(context),
                  child: Icon(Icons.keyboard_arrow_left)),
              Expanded(
                child: Text(
                  'Upload E-Materai',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: Constant.semibold,
                    color: Colors.black,
                    fontSize: 17,
                  ),
                ),
              )
            ],
          ),
          SizedBox(height: 24),
          InkWell(
            onTap: () async {
              final result =
                  await FilePicker.platform.pickFiles(allowMultiple: false);
              if (result != null) {
                final file = result.files.singleOrNull;
                print('Selected file: ${result.files.singleOrNull?.name}');

                if (file != null) {
                  setState(() {
                    // widget.onChoose(file.xFile);
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
                  )),
                  SizedBox(
                    width: 4,
                  ),
                  Icon(
                    Icons.cloud_upload,
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
            onPressed: () async {
              final provider = context.read<TransactionProvider>();
              provider.ematerai = file;
              if (provider.ematerai == null) {
                Utils.showFailed(msg: 'Upload File Dulu');
                return;
              }
              widget.onSave();
            },
            child: Text(
              'Simpan',
              style: TextStyle(color: Colors.white),
            ),
          ),
          SizedBox(height: 16),
        ],
      ),
    );
  }
}
