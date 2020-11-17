import 'dart:async';
import 'package:convert/convert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:beacon_broadcast/beacon_broadcast.dart';
import 'package:vibration/vibration.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:blue_trace/Scanner.dart';
import 'package:blue_trace/login.dart';
import 'package:blue_trace/auth.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Provider(
      create: (context) => AuthService(),
      child: MaterialApp(
        title: 'Google Login',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: LoginScreen(),
      ),
    );
  }
}
//void main()
// {
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Blue Trace',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home:
//       ScanPage(
//         title: "Bluetooth Tracing",
//       ),
//     );
//   }
// }
