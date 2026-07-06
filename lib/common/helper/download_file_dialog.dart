import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

import 'constant.dart';

class DownloadFileDialog extends StatelessWidget {
  const DownloadFileDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          wBtn(
            'Simpan File',
            onClick: () {
              Navigator.pop(context, 1);
            },
          ),
          Divider(
            height: 8,
          ),
          wBtn(
            'Hanya Buka File',
            onClick: () {
              Navigator.pop(context, 2);
            },
          ),
          Divider(
            height: 24,
            color: Colors.grey,
          ),
          wBtn(
            'Batal',
            primary: false,
            onClick: () {
              Navigator.pop(context);
            },
          )
        ],
      ),
    );
  }

  Widget wBtn(String label, {VoidCallback? onClick, bool primary = true}) {
    return InkWell(
      onTap: onClick,
      child: Container(
        height: 42,
        alignment: Alignment.center,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: primary == false ? Colors.white : Constant.primaryColor,
            border: Border.all(color: Constant.primaryColor)),
        child: AutoSizeText(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
              fontWeight: FontWeight.bold,
              color: primary ? Colors.white : Constant.primaryColor),
        ),
      ),
    );
  }
}
