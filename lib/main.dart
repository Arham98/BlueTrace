import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
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
    if (auth.FirebaseAuth.instance.currentUser == null) {
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
    } else {
      return Provider(
        create: (context) => AuthService(),
        child: MaterialApp(
          title: 'Google Login',
          theme: ThemeData(
            primarySwatch: Colors.blue,
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          home: ScanPage(
            title: "Bluetooth Tracing",
          ),
        ),
      );
    }
  }
}
