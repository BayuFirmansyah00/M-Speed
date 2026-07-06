import 'dart:convert';
import 'dart:developer';

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../helper/constant.dart';
import 'flutter_app_badger.dart';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class FirebaseManager {
  StreamSubscription? stream;

  Function(Map)? listener;

  NotificationDetails notifDetail = NotificationDetails(
    android: AndroidNotificationDetails("M-Speed", "M-Speed",
        priority: Priority.max,
        playSound: true,
        importance: Importance.max,
        icon: '@drawable/notif_icon'),
    iOS: DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    ),
  );

  void initNotification() {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@drawable/notif_icon');

    DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      defaultPresentAlert: true,
      defaultPresentBadge: true,
      defaultPresentSound: true,
    );

    flutterLocalNotificationsPlugin.initialize(
      InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsDarwin,
      ),
      onDidReceiveNotificationResponse: selectNotification,
    );

    // ios configuration
    FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true, // Required to display a heads up notification
      badge: true,
      sound: true,
    );

    stream = FirebaseMessaging.onMessage.listen((RemoteMessage event) {
      Map message = event.data;
      FlutterAppBadger.updateBadgeCount(1);
      print("payload =>" + jsonEncode(message));
      try {
        flutterLocalNotificationsPlugin.show(
          0,
          event.notification?.title ?? 'M-Speed',
          event.notification?.body ?? 'Notifikasi Baru',
          notifDetail,
          payload: jsonEncode(message),
        );
      } catch (e) {
        print(e);
      }
    });

    stream = FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage event) {
      Map message = event.data;
      FlutterAppBadger.removeBadge();
      log("MESSAGE FIREBASE" + message.toString());
      print("payload =>" + jsonEncode(message));
      setRoute(jsonEncode(message));
    });
  }

  void setReminder(
      {DateTime? userCheckInTime, DateTime? userCheckOutTime}) async {
    flutterLocalNotificationsPlugin.cancelAll();

    // SharedPreferences pref = await SharedPreferences.getInstance();
    // final work = int.parse(pref.getString(Constant.kWorkingDays) ?? "1");
    // final checkIn = pref.getString(Constant.kCheckIn) ?? "08:00";
    // final checkOut = pref.getString(Constant.kCheckOut) ?? "17:00";
    // final breakStart = pref.getString(Constant.kBreakStart) ?? "12:00";
    // final breakEnd = pref.getString(Constant.kBreakEnd) ?? "13:00";
    // /// Check In
    // setScheduling(
    //   id: 0,
    //   tag: "Waktunya Check In!",
    //   time: checkIn,
    //   workingDays: work,
    // );
    // /// Check Out
    // setScheduling(
    //   id: 1,
    //   tag: "Waktunya Check Out!",
    //   time: checkOut,
    //   workingDays: work,
    // );
    // /// Break Start
    // setScheduling(
    //   id: 2,
    //   tag: "Waktunya Istirahat!",
    //   time: breakStart,
    //   workingDays: work,
    // );
    // /// Break End
    // setScheduling(
    //   id: 3,
    //   tag: "Waktu Istirahat Selesai!",
    //   time: breakEnd,
    //   workingDays: work,
    // );
    // if (userCheckInTime != null && userCheckOutTime == null){
    //   /// Reminder Check Out: If forgot checkout
    //   setScheduling(
    //     id: 4,
    //     tag: "Anda belum melakukan check out!",
    //     time: checkOut,
    //     workingDays: work,
    //   );
    // }
  }

  void setScheduling({
    required int id,
    required String tag,
    required String time,
    required int workingDays,
  }) async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation("Asia/Jakarta"));

    // set timezone datetime
    final now = DateFormat("dd-MM-yyyy").format(DateTime.now());
    final dateTime = DateFormat("dd-MM-yyyy HH:mm:ss").parse("$now $time:00");

    tz.TZDateTime alarmDate = tz.TZDateTime(
      tz.local,
      dateTime.year,
      dateTime.month,
      dateTime.day,
      dateTime.hour,
      (id == 4) ? (dateTime.minute + 60) : dateTime.minute,
      dateTime.second,
    );

    final day = DateFormat("EEEE").format(alarmDate).toLowerCase();

    // working days
    // 1 : Monday - Friday
    // 2 : Monday - Saturday

    final oneDaysOff = workingDays == 2; // Sunday Off
    final twoDaysOff = workingDays == 1; // Saturday & Sunday Off

    /// if propose reminder checkout
    /// add 15 minutes to fire notification
    // if (id == 4) {
    //   minutes = 15;
    // }

    if (alarmDate.isBefore(DateTime.now())) {
      alarmDate = alarmDate.add(Duration(days: 1));
    }

    if (day.contains("sabtu")) {
      if (twoDaysOff) {
        alarmDate = alarmDate.add(Duration(days: 1));
      }
    }

    if (day.contains("minggu")) {
      alarmDate = alarmDate.add(Duration(days: 1));
    }

    final payload = {"id": id.toString(), "type": "absent"};

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      'M-Speed',
      tag,
      alarmDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          '1',
          'M-Speed',
          channelDescription: 'M-Speed',
          priority: Priority.max,
          playSound: true,
        ),
        iOS: DarwinNotificationDetails(
          // sound: 'a_long_cold_sting.wav',
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: jsonEncode(payload),
    );
  }

  dispose() {
    if (stream != null) stream!.cancel();
  }

  void selectNotification(NotificationResponse? payload) async {
    if (payload != null) {
      String? token = (await SharedPreferences.getInstance())
          .getString(Constant.kSetPrefToken);
      if (listener != null) listener!(jsonDecode(payload.payload ?? ''));

      /// payload example
      /// {id: 33, type: warningletter}

      log("payload =>" + (payload.payload ?? ''));

      setRoute(payload.payload ?? '');
    }
  }

  void setRoute(String payload) async {
    final json = jsonDecode(payload);

    final id = int.parse(json["id"]);
    final type = json["type"];
    // final context = NavigationService.navigatorKey.currentContext;

    // if (context != null) {
    //   log("CONTEXT NOT NULL");
    //   // Navigator.of(context)
    //   //     .pushReplacement(MaterialPageRoute(builder: (context) => MainHome()));
    //   // .then((value) async {
    //   switch (json["type"]) {
    //     case "withdrawal_submission":
    //       // Navigator.push(context,
    //       //     MaterialPageRoute(builder: ((context) => KomisiAgenView())));
    //       break;
    //     case "commission_withdrawal":
    //       // Navigator.push(context,
    //       //     MaterialPageRoute(builder: ((context) => KomisiAgenView())));
    //       break;

    //       // case "exit_office":
    //       //   {
    //       //     SharedPreferences prefs = await SharedPreferences.getInstance();
    //       //     final ca = prefs.getBool(Constant.kSetPrefCanAssess)!;
    //       //     if (ca) {
    //       //       Navigator.push(context,
    //       //           MaterialPageRoute(builder: ((context) => Approval())));
    //       //       // Navigator.pushNamed(context, "/approval");
    //       //     } else {
    //       //       Navigator.push(context,
    //       //           MaterialPageRoute(builder: ((context) => LeaveOfficeList())));
    //       //     }
    //       //   }
    //       break;
    //   }
    // }
  }

  /// leave, overtime, loan, payroll, warningletter, performanceassessment, reimbursement, officialvisit, decree, employeeevent
  ///
  /// reimbursement type, persetujuan

  void onDidReceiveLocalNotification(
      int? id, String? title, String? body, String? payload) async {
    // display a dialog with the notification details, tap ok to go to another page
  }

  void setListener(Function(Map message) listener) => this.listener = listener;
}
