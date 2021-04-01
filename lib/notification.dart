//import 'dart:ffi';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:blue_trace/Mapper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

const ROOT =
    'obscure-plateau-63653.herokuapp.com'; // '10.0.2.2:8080'; // 'https://obscure-plateau-63653.herokuapp.com'

Future sendToken(String title) async {
  var currUUID = "";
  if (auth.FirebaseAuth.instance.currentUser.uid != null) {
    var tempData;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(auth.FirebaseAuth.instance.currentUser.uid)
        .get()
        .then((usrData) => {
              tempData = UserData.fromData(usrData.data()),
              currUUID = tempData.uuid,
            });
  }

  final response = await http.post(
    Uri.https(
      ROOT,
      '',
    ),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{
      'callType': "noti_token_provision",
      'token': title,
      'uuid': currUUID,
    }),
  );
  print("RESPONSE:${response.statusCode} L ${response.body} L");
}

Future selectNotification(String payload) async {
  if (payload != null) {
    print('notification payload: $payload');
  }
  // await Navigator.push(
  //   context,
  //   MaterialPageRoute<void>(builder: (context) => SecondScreen(payload)),
  // );
}

Future initializeNotification(String payload) async {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('noti_icon');
  final InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onSelectNotification: selectNotification);

  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
          'your channel id', 'your channel name', 'your channel description',
          importance: Importance.max, priority: Priority.high, showWhen: false);
  const NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);
  await flutterLocalNotificationsPlugin.show(
      0,
      'Social Distancing Violation',
      'You are too near another person, PLease maintain social distancing.',
      platformChannelSpecifics,
      payload: 'item x');
}

Future pushNotificationForeground(
    String payload, int id, RemoteNotification noti) async {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('noti_icon');
  final InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onSelectNotification: selectNotification);

  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
          '160498', 'blue trace channel', 'just delivering notifications',
          importance: Importance.max, priority: Priority.high, showWhen: false);
  const NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);
  await flutterLocalNotificationsPlugin.show(
      id, noti.title, noti.body, platformChannelSpecifics,
      payload: payload);
}

class PushNotificationService {
  final FirebaseMessaging _firbaseNotification;
  int i = 0;
  PushNotificationService(this._firbaseNotification);

  Future initialise() async {
    // If you want to test the push notification locally,
    // you need to get the token and input to the Firebase console
    // https://console.firebase.google.com/project/YOUR_PROJECT_ID/notification/compose
    String token = await _firbaseNotification.getToken(
        vapidKey: auth.FirebaseAuth.instance.currentUser.uid);

    print("FirebaseMessaging token: $token");
    await sendToken(token);
    _firbaseNotification.setAutoInitEnabled(true);

    _firbaseNotification.setForegroundNotificationPresentationOptions(
        alert: true, badge: true, sound: true);
    FirebaseMessaging.onBackgroundMessage((message) async {
      print("onBackgroundMessage: $message");
      return Future<void>.value();
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification notification = message.notification;
      AndroidNotification android = message.notification?.android;
      if (notification != null && android != null) {
        i = i + 1;
        pushNotificationForeground("App Payload", i, notification);
      }
    });
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      RemoteNotification notification = message.notification;
      AndroidNotification android = message.notification?.android;
      if (notification != null && android != null) {
        i = i + 1;
        pushNotificationForeground("App Payload", i, notification);
      }
    });
    // _firbaseNotification.configure(
    //   onMessage: (Map<String, dynamic> message) async {
    //     print("onMessage: $message");
    //   },
    //   onLaunch: (Map<String, dynamic> message) async {
    //     print("onLaunch: $message");
    //   },
    //   onResume: (Map<String, dynamic> message) async {
    //     print("onResume: $message");
    //   },
    // );
  }
}
