//import 'package:blue_trace/main.dart';
import 'dart:async';
import 'package:flutter/material.dart';
//import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:blue_trace/sidebar.dart';
import 'package:blue_trace/user.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:blue_trace/notification.dart' as notification;
import 'package:cloud_firestore/cloud_firestore.dart';

class CovidPage extends StatefulWidget {
  CovidPage({
    Key key,
  }) : super(key: key);

  @override
  _CovidPageState createState() => _CovidPageState(key: key);
}

class _CovidPageState extends State<CovidPage> {
  _CovidPageState({Key key});

  String submissionMsg = "";

//CODE FOR COVID ALERT  directly to Firebase - Now to be done through Server//
  // (bool newValue) async {
  //   //print("$covidbool,$newValue");
  //   if (newValue == true) {
  //     await FirebaseFirestore.instance
  //         .collection('covidPositive')
  //         .add({
  //       'uuid': curruuid,
  //       'timestamp': Timestamp.fromMillisecondsSinceEpoch(
  //           DateTime.now().millisecondsSinceEpoch),
  //       'user': username,
  //     });
  //     await FirebaseFirestore.instance
  //         .collection('users')
  //         .doc(auth.FirebaseAuth.instance.currentUser.uid)
  //         .set({
  //       'covidStatus': true,
  //     }, SetOptions(merge: true));
  //     //await WebAppServices.sendCovidSignal(
  //     //    scannerpgdata.myUserData.uuid);
  //   } else {
  //     await FirebaseFirestore.instance
  //         .collection('users')
  //         .doc(auth.FirebaseAuth.instance.currentUser.uid)
  //         .set({
  //       'covidStatus': false,
  //     }, SetOptions(merge: true));
  //     var docid;
  //     await FirebaseFirestore.instance
  //         .collection('covidPositive')
  //         .where('uuid', isEqualTo: savedLocalUsrData.uuid)
  //         .get()
  //         .then((value) => {docid = value.docs.first.id});
  //     await FirebaseFirestore.instance
  //         .collection('covidPositive')
  //         .doc(docid)
  //         .delete();
  //   }
  //   setState(() {
  //     savedLocalUsrData.covidStatus = newValue;
  //     covidbool = newValue;
  //   });
  // },
//          END       //

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      getData();
    });
  }

  void getData() async {}

  Future sendCovidAlert() async {
    final response = await http.post(
      Uri.https(
        notification.ROOT,
        '',
      ),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'callType': "updated_covid_pos",
        'timestamp': //Timestamp.fromMillisecondsSinceEpoch(
            DateTime.now()
                .millisecondsSinceEpoch
                //)
                .toString(),
        'token': savedLocalUsrData.name,
        'uuid': savedLocalUsrData.uuid,
      }),
    );
    print(response);
    return;
  }

  Future<String> getUserData() async {
    return "RR";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: SideBar(
        covidbool: false,
      ),
      appBar: AppBar(
        title: Text("COVID Status"),
      ),
      body: Center(
          child: FutureBuilder(
              future: getUserData(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return new ListView(
                    shrinkWrap: true,
                    padding: const EdgeInsets.all(8),
                    children: <Widget>[
                      (savedLocalUsrData.covidStatus)
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text("Status: ",
                                          style: TextStyle(fontSize: 32)),
                                      Text("Positive",
                                          style: TextStyle(
                                              fontSize: 32, color: Colors.red))
                                    ],
                                  ),
                                ])
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text("Status: ",
                                          style: TextStyle(fontSize: 32)),
                                      Text("Negative",
                                          style: TextStyle(
                                              fontSize: 32,
                                              color: Colors.green))
                                    ],
                                  ),
                                  Padding(padding: EdgeInsets.all(20)),
                                  TextButton(
                                    style: TextButton.styleFrom(
                                      primary: Colors.white,
                                      backgroundColor: Colors.blue,
                                      onSurface: Colors.white,
                                    ),
                                    child: Container(
                                        width: 0.45 *
                                            MediaQuery.of(context).size.width,
                                        height: 24,
                                        child: Center(
                                          child: Text(
                                            'Submit',
                                            style: TextStyle(fontSize: 22),
                                            //textScaleFactor: 1.0,
                                          ),
                                        )
                                        //padding: EdgeInsets.all(8.0)
                                        ),
                                    onPressed: () async {
                                      setState(() {
                                        submissionMsg =
                                            "Your Request is been Processed.";
                                      });

                                      await sendCovidAlert()
                                          .whenComplete(() => {
                                                submissionMsg =
                                                    "Your Request has been Submitted for Approval, If you want you can send another request.",
                                              });
                                    },
                                  ),
                                  Padding(padding: EdgeInsets.all(8)),
                                  Text(
                                    submissionMsg,
                                    style: TextStyle(fontSize: 18),
                                    textAlign: TextAlign.center,
                                  )
                                ]),
                    ],
                  );
                } else if (snapshot.hasError) {
                  return Text(
                    "${snapshot.error}",
                  );
                }
                // By default, show a loading spinner
                return SpinKitFadingCircle(
                  color: Colors.cyan,
                  size: 75.0,
                );
              })),
    );
  }
}
