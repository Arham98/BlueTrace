import 'package:blue_trace/user.dart';
import 'package:blue_trace/auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Sign in',
        home: Scaffold(
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
                    transformAlignment: Alignment.topLeft,
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
                  LoginButton(),
                  SizedBox(
                    height: 16,
                  ),
                  InkWell(
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
                                    image:
                                        AssetImage('assets/images/google.png'),
                                    fit: BoxFit.scaleDown),
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              'Sign Up with Google',
                              style: TextStyle(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                          ],
                        ))),
                    onTap: () async {},
                  ),
                  SizedBox(height: 30.0),
                ],
              ),
            )));
  }
}

class LoginButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
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
                            image: AssetImage('assets/images/google.png'),
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
              authService.googleSignIn();
            },
          );
        });
  }
}
