import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:blue_trace/notification.dart';
import 'package:blue_trace/Scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:blue_trace/auth.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:random_string/random_string.dart';

class LoginScreen extends StatefulWidget {
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  auth.User user;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;

  @override
  void initState() {
    super.initState();
    print(auth.FirebaseAuth.instance);
    //authService.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Sign in',
        home: Scaffold(
            key: _scaffoldKey,
            appBar: AppBar(
              title: Text('Sign in'),
              backgroundColor: Colors.cyan,
            ),
            body: Center(
              child: Column(
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.fromLTRB(12, 25, 0, 0),
                    alignment: Alignment.topLeft,
                    //transformAlignment: Alignment.topLeft,
                    child: Text('Blue',
                        style: TextStyle(
                            fontSize: 80.0, fontWeight: FontWeight.bold)),
                  ),
                  //SizedBox(height: 30.0),
                  Container(
                    padding: const EdgeInsets.fromLTRB(12, 5, 0, 0),
                    alignment: Alignment.topLeft,
                    //padding: EdgeInsets.fromLTRB(15.0, 175.0, 0.0, 0.0),
                    child: Text('Trace',
                        style: TextStyle(
                            fontSize: 80.0, fontWeight: FontWeight.bold)),
                  ),
                  SizedBox(height: 30.0),
                  SizedBox(
                    height: 16,
                  ),
                  StreamBuilder(
                      stream: authService.fireuser,
                      builder: (context, snapshot) {
                        return InkWell(
                          child: Container(
                              width: MediaQuery.of(context).size.width * 0.7,
                              height: MediaQuery.of(context).size.height * 0.1,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(40),
                                  color: Colors.cyan),
                              child: Center(
                                  child: Row(
                                children: <Widget>[
                                  SizedBox(
                                    width: 15,
                                  ),
                                  Container(
                                    height: 35.0,
                                    width: 35.0,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                          image: AssetImage(
                                              'assets/images/google.png'),
                                          fit: BoxFit.scaleDown),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    'Sign In with Google',
                                    style: TextStyle(
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  ),
                                ],
                              ))),
                          onTap: () async {
                            await authService.googleSignIn().then((_) async {
                              // ScaffoldMessenger.of(context)
                              //     .showSnackBar(new SnackBar(
                              //   //duration: new Duration(seconds: 4),
                              //   content: new Row(
                              //     children: <Widget>[
                              //       new CircularProgressIndicator(),
                              //       new Text("  Signing-In...")
                              //     ],
                              //   ),
                              // ));
                              var googleUid =
                                  auth.FirebaseAuth.instance.currentUser.uid;
                              await FirebaseFirestore.instance
                                  .collection("users")
                                  .where('googleUid', isEqualTo: googleUid)
                                  .get()
                                  .then((result) async {
                                if (result.docs.isEmpty) {
                                  var newUuid; // = randomAlphaNumeric(10);
                                  while (true) {
                                    newUuid = randomAlphaNumeric(16);
                                    var res = await FirebaseFirestore.instance
                                        .collection("users")
                                        .where('uuid', isEqualTo: newUuid)
                                        .get();
                                    if (res.docs.isEmpty) {
                                      break;
                                    }
                                  }
                                  DocumentReference ref = FirebaseFirestore
                                      .instance
                                      .collection('users')
                                      .doc(googleUid);
                                  await ref
                                      .set({
                                        'name': auth.FirebaseAuth.instance
                                            .currentUser.displayName,
                                        'googleUid': googleUid,
                                        'cnic': 0,
                                        'covidStatus': false,
                                        'email': auth.FirebaseAuth.instance
                                            .currentUser.email,
                                        'uuid': newUuid,
                                      }, SetOptions(merge: true))
                                      .then((_) {})
                                      .catchError((e) {
                                        print(e);
                                      });
                                }
                              });

                              final pushNotificationService =
                                  PushNotificationService(_firebaseMessaging);
                              pushNotificationService.initialise();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ScanPage(
                                          title: "Bluetooth Tracing",
                                          firstLaunch: true,
                                        )),
                              );
                            });
                          },
                        );
                      }),
                  //LoginButton(),
                  SizedBox(
                    height: 16,
                  ),
                ],
              ),
            )));
  }
}

class LogoutButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: authService.fireuser,
        builder: (context, snapshot) {
          return ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text('Logout'),
              onTap: () async {
                Navigator.popUntil(context, (Route route) {
                  return route.isFirst;
                });
                Navigator.pushReplacement(context, MaterialPageRoute(
                  builder: (BuildContext context) {
                    return LoginScreen();
                  },
                ));
                await Future.delayed(Duration(seconds: 1), () {
                  authService.signOut().then((dynamic) {
                    print("Successful Logout");
                  }).catchError((e, s) {
                    print(e);
                    print(s);
                  });
                });
              });
        });
  }
}
