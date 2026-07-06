import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';

import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as path;

import '../component/custom_alert.dart';

class DownloadFileHelper {
  ReceivePort _port = ReceivePort();

  String externalDir = "";

  String filename = "";

  var isDownloaded = false;

  var count = 0;

  void setdownloadListener(
      BuildContext context, VoidCallback setProgress, VoidCallback setDone) {
    IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port');
    _port.listen((dynamic data) async {
      String id = data[0];
      DownloadTaskStatus status = data[1];
      int progress = data[2];

      if (progress > 1 && progress < 100) {
        if (!isDownloaded) {
          isDownloaded = true;
          setProgress();
        }
      }
      if (progress == -1) {
        Future.delayed(Duration(seconds: 2)).then((value) {
          FlutterDownloader.retry(taskId: id);
        });
        return;
      }

      if (status.toString() == "DownloadTaskStatus(3)" && progress == 100) {
        count = 0;
        isDownloaded = false;
        setDone();
        Future.delayed(Duration(seconds: 2)).then((value) {
          FlutterDownloader.open(taskId: id);
        });
      }
    });
    FlutterDownloader.registerCallback(downloadCallback);
  }

  static void downloadCallback(String id, int status, int progress) {
    final SendPort? send =
        IsolateNameServer.lookupPortByName('downloader_send_port');
    send?.send([id, status, progress]);
  }

  void startDownloading(
      BuildContext context, String url, String urlPath, String name) async {
    // print(url);
    final status = await Permission.storage.request();
    if (status.isGranted) {
      if (Platform.isAndroid) {
        externalDir = (await getExternalStorageDirectory())?.path ?? "";
      } else {
        externalDir = (await getApplicationDocumentsDirectory()).absolute.path;
      }
      final filename = url.replaceAll(urlPath, "");
      this.filename = filename;
      final id = await FlutterDownloader.enqueue(
        url: url,
        savedDir: externalDir,
        fileName: filename,
        showNotification: true,
        openFileFromNotification: true,
      );
    } else {
      CustomAlert.showSnackBar(
        context,
        "Akses Penyimpanan Ditolak!",
        true,
      );
    }
  }

  void download(BuildContext context, String url) async {
    // print(url);
    final status = await Permission.storage.request();
    if (status.isGranted) {
      if (Platform.isAndroid) {
        externalDir = (await getExternalStorageDirectory())?.path ?? "";
      } else {
        externalDir = (await getApplicationDocumentsDirectory()).absolute.path;
      }

      this.filename = path.basename(url) +
          '-' +
          DateTime.now().second.toString() +
          '.' +
          path.extension(url);
      final id = await FlutterDownloader.enqueue(
        url: url,
        savedDir: externalDir,
        fileName: filename,
        showNotification: true,
        openFileFromNotification: true,
      );
    } else {
      CustomAlert.showSnackBar(
        context,
        "Akses Penyimpanan Ditolak!",
        true,
      );
    }
  }

  void setDispose() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
  }
}
