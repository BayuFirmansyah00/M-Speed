import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import 'constant.dart';

class DownloadingDialog extends StatefulWidget {
  String taskId;
  final Function(String) onCancel;
  DownloadingDialog(this.taskId, this.onCancel, {Key? key}) : super(key: key);

  @override
  State<DownloadingDialog> createState() => DownloadingDialogState();
}

class DownloadingDialogState extends State<DownloadingDialog> {
  double? percentage;
  bool finished = false;
  bool isFailed = false;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Container(
        alignment: Alignment.center,
        child: Container(
            width: double.infinity,
            margin: EdgeInsets.all(24),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8), color: Colors.white),
            constraints: BoxConstraints(maxHeight: 420),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (finished == false) wProgressAnim() else wFinishedAnim(),
                if (isFailed == false) wLabel() else wFailedLabel(),
                if (isFailed == false)
                  LinearProgressIndicator(
                    minHeight: 8,
                    value: percentage,
                    backgroundColor: Colors.grey,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Constant.primaryColor),
                  )
              ],
            )),
      ),
    );
  }

  wLabel() {
    return Container(
      margin: EdgeInsets.only(bottom: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            finished ? 'Berhasil Memuat Berkas!' : 'Sedang Memuat Berkas..',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          if (percentage != null)
            Container(
              margin: EdgeInsets.only(top: 8),
              child: Text(
                '${(percentage! * 100).toStringAsFixed(0)}%',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Constant.primaryColor),
              ),
            ),
          Container(
            margin: EdgeInsets.only(top: 18),
            child: InkWell(
                onTap: () {
                  print(widget.taskId);
                  if (!finished) widget.onCancel(widget.taskId);

                  Navigator.pop(context, (!finished) ? -1 : 1);
                },
                child: Text(
                  finished ? 'Tutup' : 'Batal',
                  style:
                      TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                )),
          )
        ],
      ),
    );
  }

  void finish() {
    setState(() {
      percentage = 1;
      finished = true;
    });
  }

  wProgressAnim() {
    return Card(
        margin: EdgeInsets.symmetric(vertical: 24),
        shape: CircleBorder(),
        color: Constant.primaryColor,
        child: Transform.scale(
          scale: 1.2,
          child: Lottie.asset('assets/lottie/downloading.json',
              repeat: true, width: 100, height: 100),
        ));
  }

  wFinishedAnim() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 24),
      child: Transform.scale(
        scale: 1.2,
        child: Lottie.asset('assets/lottie/success.json',
            repeat: false, width: 100, height: 100),
      ),
    );
  }

  void failed() {
    setState(() {
      isFailed = true;
    });
  }

  wFailedLabel() {
    return Container(
      margin: EdgeInsets.only(bottom: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Gagal Memuat Berkas',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Container(
            margin: EdgeInsets.only(top: 18),
            child: InkWell(
                onTap: () {
                  Navigator.pop(context, -1);
                },
                child: Text(
                  'Tutup',
                  style:
                      TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                )),
          )
        ],
      ),
    );
  }
}
