//local notifications
import 'dart:convert';
import 'dart:developer';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'dart:io';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
AndroidFlutterLocalNotificationsPlugin? androidFlutterLocalNotificationsPlugin;
const AndroidNotificationChannel androidChannel = AndroidNotificationChannel(
    'MedicineApp common', 'Common',
    importance: Importance.high, enableVibration: true, playSound: true);
IOSFlutterLocalNotificationsPlugin? iosFlutterLocalNotificationPlugin;

final NotificationDetails notificationDetails = NotificationDetails(
  android: AndroidNotificationDetails(
    androidChannel.id,
    androidChannel.name,
    icon: '@mipmap/ic_launcher',
    enableVibration: true,
    autoCancel: true,
    importance: Importance.max,
    priority: Priority.max,
    playSound: true,
  ),
  iOS: const DarwinNotificationDetails(
    presentAlert: true,
    presentBadge: true,
    presentSound: true,
  ),
);

/// INITIALIZATION SETTINGS ///
AndroidInitializationSettings initializationSettingsAndroid =
    const AndroidInitializationSettings('@mipmap/ic_launcher');
DarwinInitializationSettings initializationSettingsDarwin =
    const DarwinInitializationSettings(
        requestBadgePermission: true,
        requestAlertPermission: true,
        requestSoundPermission: true);
final InitializationSettings initializationSettings = InitializationSettings(
  android: initializationSettingsAndroid,
  iOS: initializationSettingsDarwin,
);

@pragma('vm:entry-point')
listenForegroundNotificationPayload(BuildContext context) async {
  ///
  /// handle foreground notification
  ///
  void _consumePayload(String? payloadJsonStr, bool isAppLaunchDetails) {
    try {
      log("PAYLOAD FG : $payloadJsonStr");
      if (payloadJsonStr != null && payloadJsonStr != "{}") {
        // context
        //     .read<MainPresenter>()
        //     .fcmRouting(context, jsonDecode(payloadJsonStr));
      }
    } catch (e, s) {
      FirebaseCrashlytics.instance.recordError(e, s, information: [
        DiagnosticsNode.message("Foreground Notification Click"),
        DiagnosticsNode.message("Is App Launch Detail: $isAppLaunchDetails"),
        DiagnosticsNode.message(
            'Payload: ${payloadJsonStr ?? 'payload is null'}'),
      ]);
    }
  }

  await flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onDidReceiveNotificationResponse: (payload) async {
    _consumePayload(
        jsonEncode(jsonDecode((payload.payload) ?? '{}')['data'] ?? '{}'),
        false);
  });
  // ios configuration
  FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true, // Required to display a heads up notification
    badge: true,
    sound: true,
  );
  flutterLocalNotificationsPlugin
      .getNotificationAppLaunchDetails()
      .then((details) {
    _consumePayload(details?.notificationResponse?.payload ?? '', true);
  });

  FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
    if (message != null) {
      _consumePayload(jsonEncode(message.data), false);
    }
  });
  FirebaseMessaging.onMessage.listen((RemoteMessage event) {
    Map message = event.data;
    log("payload listen fg =>" + jsonEncode(message));
    _consumePayload(jsonEncode(message), false);
    // try {
    //   flutterLocalNotificationsPlugin.show(
    //     0,
    //     event.notification?.title ?? 'Ragasport',
    //     event.notification?.body ?? 'Notifikasi Baru',
    //     notificationDetails,
    //     payload: jsonEncode(message),
    //   );
    // } catch (e) {
    //   log("$e");
    // }
  });
  FirebaseMessaging.onMessageOpenedApp.listen(
    (event) {
      log("payload open fg =>" + jsonEncode(event.data));
      // _consumePayload(jsonEncode(event.data), false);
    },
  );
}

@pragma('vm:entry-point')
initLocalNotification(BuildContext context) async {
  void _consumePayload(String? payloadJsonStr, bool isAppLaunchDetails) {
    try {
      log("PAYLOAD INIT : $payloadJsonStr");
      if (payloadJsonStr != null && payloadJsonStr != "{}") {
        // context
        //     .read<MainPresenter>()
        //     .fcmRouting(context, jsonDecode(payloadJsonStr));
      }
    } catch (e, s) {
      FirebaseCrashlytics.instance.recordError(e, s, information: [
        DiagnosticsNode.message("Foreground Notification Click"),
        DiagnosticsNode.message("Is App Launch Detail: $isAppLaunchDetails"),
        DiagnosticsNode.message(
            'Payload: ${payloadJsonStr ?? 'payload is null'}'),
      ]);
    }
  }

  //android 13 or higher
  flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>()
      ?.requestPermissions();
  iosFlutterLocalNotificationPlugin =
      flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
  //android 13 or higher
  flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.requestNotificationsPermission();
  androidFlutterLocalNotificationsPlugin =
      flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

  await androidFlutterLocalNotificationsPlugin
      ?.createNotificationChannel(androidChannel);

  androidFlutterLocalNotificationsPlugin
      ?.initialize(initializationSettingsAndroid);

  await flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onDidReceiveNotificationResponse: (payload) async {
    _consumePayload(
        jsonEncode(jsonDecode(payload.payload ?? '{}')['data'] ?? '{}'), false);
  });
  // ios configuration
  FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true, // Required to display a heads up notification
    badge: true,
    sound: true,
  );
  flutterLocalNotificationsPlugin
      .getNotificationAppLaunchDetails()
      .then((details) {
    _consumePayload(details?.notificationResponse?.payload ?? '', true);
  });

  FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
    if (message != null) {
      _consumePayload(jsonEncode(message.data), false);
    }
  });
  FirebaseMessaging.onMessage.listen((RemoteMessage event) async {
    Map message = event.data;
    log("payload listen init =>" + jsonEncode(message));
    try {
      await flutterLocalNotificationsPlugin.show(
        0,
        event.notification?.title ?? 'Ragasport',
        event.notification?.body ?? 'Notifikasi Baru',
        notificationDetails,
        payload: jsonEncode(message),
      );
      // if (message != null) {
      //   _consumePayload(jsonEncode(message), false);
      // }
    } catch (e) {
      log("$e");
    }
  });
  FirebaseMessaging.onMessageOpenedApp.listen(
    (event) {
      log("payload open init =>" + jsonEncode(event.data));
      _consumePayload(jsonEncode(event.data), false);
    },
  );
}

subscribeRoleTopic() {
  FirebaseMessaging.instance.subscribeToTopic('public');
}

unsubscribeRoleTopic() {
  FirebaseMessaging.instance.unsubscribeFromTopic('public');
}

@pragma('vm:entry-point')
Future<void> firebaseBackgroundMsgHandler(RemoteMessage event) async {
  String title =
      event.notification?.title ?? event.data['title'] ?? "MedicineApp";
  String desc = event.notification?.body ?? event.data['desc'] ?? "Notifikasi";

  if (androidFlutterLocalNotificationsPlugin != null && Platform.isAndroid) {
    androidFlutterLocalNotificationsPlugin?.show(
      event.hashCode,
      title,
      desc,
      notificationDetails: notificationDetails.android,
      payload: jsonEncode({'data': event.data}),
    );
  } else {
    iosFlutterLocalNotificationPlugin?.show(
      event.hashCode,
      title,
      desc,
      notificationDetails: notificationDetails.iOS,
      payload: jsonEncode({'data': event.data}),
    );
  }
}

@pragma('vm:entry-point')
firebaseForegroundMsgHandler(RemoteMessage event) async {
  log('Open Foreground: ${event.data}');

  String title =
      event.notification?.title ?? event.data['title'] ?? "MedicineApp";
  String desc = event.notification?.body ?? event.data['desc'] ?? "Notifikasi";

  if (androidFlutterLocalNotificationsPlugin != null && Platform.isAndroid) {
    androidFlutterLocalNotificationsPlugin?.show(
      event.hashCode,
      title,
      desc,
      notificationDetails: notificationDetails.android,
      payload: jsonEncode({'data': event.data}),
    );
  } else {
    iosFlutterLocalNotificationPlugin?.show(
      event.hashCode,
      title,
      desc,
      notificationDetails: notificationDetails.iOS,
      payload: jsonEncode({'data': event.data}),
    );
  }
}
