import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import 'firebase_and_notif.dart';

downloadFile(
  BuildContext context,
  String link, {
  required String filename,
  bool openAfterDownload = false,
  required String typeFile,
}) async {
  try {
    var initializationSettingsAndroid = new AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    await Permission.storage.request();
    await Permission.manageExternalStorage.request();
    var request = await HttpClient().getUrl(Uri.parse(link));
    var response = await request.close();
    if (response.statusCode == 200) {
      var bytes = await consolidateHttpClientResponseBytes(response);
      Directory? d;
      if (Platform.isAndroid && d != null) {
        await Permission.manageExternalStorage.request();
        await Permission.storage.request();
        await Permission.photos.request();
        // d = await DownloadsPathProvider.downloadsDirectory;
        d = await getExternalStorageDirectory();
        bool dExists = Directory("${d!.path}/MSpeed").existsSync();
        if (!dExists) {
          Directory("${d.path}/MSpeed").createSync();
        }
        File f = await File(
          d.path + "/MSpeed/$filename.$typeFile",
        ).writeAsBytes(bytes);
        FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
            FlutterLocalNotificationsPlugin();
        if (openAfterDownload) {
          await flutterLocalNotificationsPlugin.initialize(
            initializationSettings,
            onDidReceiveNotificationResponse:
                (NotificationResponse? payload) {},
          );
          await flutterLocalNotificationsPlugin.show(
            0,
            filename,
            "Download berhasil disimpan di ${f.path}",
            notificationDetails,
          );
          await OpenFilex.open(f.path);
        } else {
          await flutterLocalNotificationsPlugin.initialize(
            initializationSettings,
            onDidReceiveNotificationResponse: (NotificationResponse? payload) {
              if (payload != null) OpenFilex.open(f.path);
            },
          );
          await flutterLocalNotificationsPlugin.show(
            0,
            filename,
            "Download berhasil, Ketuk untuk buka file",
            notificationDetails,
          );
        }
      } else {
        d = await getApplicationDocumentsDirectory();
        log("APP DIR : $d");
        bool dExists = Directory("${d.path}/MSpeed").existsSync();
        if (!dExists) {
          Directory("${d.path}/MSpeed").createSync();
        }
        File f = await File(
          d.path + "/MSpeed/$filename.$typeFile",
        ).writeAsBytes(bytes);
        FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
            FlutterLocalNotificationsPlugin();
        if (openAfterDownload) {
          await flutterLocalNotificationsPlugin.initialize(
            initializationSettings,
            onDidReceiveNotificationResponse:
                (NotificationResponse? payload) {},
          );
          await flutterLocalNotificationsPlugin.show(
            0,
            filename,
            "Download berhasil",
            notificationDetails,
          );
          await OpenFilex.open(f.path);
        } else {
          await flutterLocalNotificationsPlugin.initialize(
            initializationSettings,
            onDidReceiveNotificationResponse: (NotificationResponse? payload) {
              if (payload != null) OpenFilex.open(f.path);
            },
          );
          await flutterLocalNotificationsPlugin.show(
            0,
            filename,
            "Download berhasil, Ketuk untuk buka file",
            notificationDetails,
          );
        }
      }
    } else {
      // Widgets.showSnackBar(
      //     context, "Gagal Download ${response.statusCode}", true);
      log('Error code: ' + response.statusCode.toString());
    }
  } catch (e) {
    // Widgets.showSnackBar(context, "Gagal Download $e", true);
    log('Can not fetch url $e');
  }
}
