import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';

import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as path;

import 'download_file_dialog.dart';

class DownloadFileHelper2 {
  ReceivePort _port = ReceivePort();
  final Map<String, bool> taskIdDownloadType = {};

  void setdownloadListener(BuildContext context,
      {Function(String, int)? onProgress,
      Function(String)? onFinished,
      Function(String, int)? onRetry,
      Function(String)? onFailed}) {
    IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader2_send_port');
    _port.listen((dynamic data) async {
      String id = data[0];
      DownloadTaskStatus status = data[1];
      int progress = data[2];
      if (progress > 1 && progress < 100 && onProgress != null) {
        onProgress(id, progress);
      }

      if (status == DownloadTaskStatus.failed) {
        if (onFailed != null) {
          onFailed(id);
        }
        return;
      }

      if (status == DownloadTaskStatus.complete) {
        if (onFinished != null) {
          onFinished(id);
        }
        Future.delayed(Duration(seconds: 1)).then((value) {
          if (Platform.isIOS && taskIdDownloadType[id] == true) {
            /// Do nothing
          } else {
            FlutterDownloader.open(taskId: id);
          }
        });
      }
    });
    FlutterDownloader.registerCallback(_downloadCallback);
  }

  @pragma('vm:entry-point')
  static void _downloadCallback(String id, int status, int progress) {
    final SendPort? send =
        IsolateNameServer.lookupPortByName('downloader2_send_port');
    send?.send([id, status, progress]);
  }

  Future<DownloadResult?> download(BuildContext context, String url) async {
    // print(url);
    final status = await Permission.storage.request();
    late String externalDir;
    final androidInfo = await DeviceInfoPlugin().androidInfo;
    if (status.isGranted || androidInfo.version.sdkInt == 33) {
      final result = await showModalBottomSheet(
          context: context,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          builder: (context) {
            return DownloadFileDialog();
          });

      if (result != null) {
        final isOpenOnly = result == 2;

        if (isOpenOnly == false) {
          if (Platform.isAndroid) {
            externalDir = (await getExternalStorageDirectory())?.path ?? "";
          } else {
            externalDir =
                (await getApplicationDocumentsDirectory()).absolute.path;
          }
        } else {
          externalDir =
              (await getTemporaryDirectory()).absolute.path + '/download/';
        }

        final ext = path.extension(url);
        final basename = path.basename(url);
        final filename = basename.substring(0, basename.length - ext.length) +
            '-' +
            DateTime.now().second.toString() +
            ext;
        final id = await FlutterDownloader.enqueue(
          url: url,
          savedDir: externalDir,
          fileName: filename,
          showNotification: isOpenOnly != true,
          openFileFromNotification: true,
        );

        taskIdDownloadType[id!] = isOpenOnly;

        // Handling just open file in iOS
        if (Platform.isIOS && taskIdDownloadType[id] == true) {
          Future.delayed(Duration(seconds: 1)).then((value) {
            OpenFilex.open(externalDir + "/" + filename);
          });
        }

        return DownloadResult(id, isOpenOnly);
      }
    } else {
      throw "Akses Penyimpanan Ditolak!";
    }
    return null;
  }

  void dispose() {
    IsolateNameServer.removePortNameMapping('downloader2_send_port');
  }

  void cancel(String id) {
    FlutterDownloader.cancelAll();
  }

  bool isOpenOnly(String taskId) {
    return taskIdDownloadType[taskId] ?? false;
  }
}

class DownloadResult {
  final String id;
  final bool isOpenOnly;

  DownloadResult(this.id, this.isOpenOnly);
}
