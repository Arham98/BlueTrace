//import 'package:blue_trace/main.dart';
import 'dart:async';
import 'package:convert/convert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:beacon_broadcast/beacon_broadcast.dart';
import 'package:vibration/vibration.dart';
//import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:blue_trace/sidebar.dart';
import 'package:blue_trace/user.dart';
//import 'package:blue_trace/Mapper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:blue_trace/notification.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:location/location.dart';
import 'dart:math' as math;
//import 'package:async/async.dart';

class ScanPage extends StatefulWidget {
  ScanPage({Key key, this.title, this.firstLaunch}) : super(key: key);
  final String title;
  final bool firstLaunch;

  @override
  _ScanPageState createState() =>
      _ScanPageState(key: key, title: title, firstLaunch: firstLaunch);
}

class _ScanPageState extends State<ScanPage> {
  _ScanPageState({Key key, this.title, this.firstLaunch});
  final String title;
  bool firstLaunch;
  final Map<String, DateTime> contactedUsers = {};
  FlutterBlue flutterBlue = FlutterBlue.instance;
  bool isSwitched = false;
  bool alertboxStatus = false;
  Timer scanInv;
  Timer firebaseUpload;
  String blueOnOffStr = 'Start Scanning';
  int sessionId = 0;
  int resCount = 0;
  // var popupCancel1;
  // var popupCancel2;
  double currentLatitude;
  double currentLongitude;
  bool sidebarActivation = false;
  int noiseLevel = 2;

  //var initializationSettings;
  //print(_us);_userData
  static var currUUID;
  static const MAJOR_ID = 1;
  static const MINOR_ID = 1;
  static const TRANSMISSION_POWER = -59;
  static const LAYOUT =
      'm:2-3=beac,i:4-19,i:20-21,i:22-23,p:24-24,d:25-25'; //BeaconBroadcast.ALTBEACON_LAYOUT;

  static const MANUFACTURER_ID = 0x1604; //0x1604
  BeaconBroadcast beaconBroadcast = BeaconBroadcast();
  //BeaconStatus _isTransmissionSupported;
  @override
  void initState() {
    super.initState();
    beaconBroadcast
        .checkTransmissionSupported()
        .then((isTransmissionSupported) {
      setState(() {
        //_isTransmissionSupported = isTransmissionSupported;
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      getData();
    });
  }

  void getData() async {
    // await FirebaseFirestore.instance
    //     .collection('users')
    //     .doc(auth.FirebaseAuth.instance.currentUser.uid)
    //     .get()
    //     .then((usrData) => {
    //           myUserData = UserData.fromData(usrData.data()),
    //           currUUID = hex.encode(myUserData.uuid.codeUnits),
    //         });
  }

//popup notifcation
  Future<void> popup(int futureId) async {
    if (sessionId != futureId) {
      return;
    }
    if (alertboxStatus == false) {
      alertboxStatus = true;
      initializeNotification("String payload")
          .then((value) => {alertboxStatus = false});
      // showDialog(
      //   //User friendly error message when the screen has been displayed
      //   context: context,
      //   builder: (_) => AlertDialog(
      //     title: Text(
      //       "Close Contact Alert",
      //       textAlign: TextAlign.center,
      //       style: TextStyle(fontSize: 28),
      //     ),
      //     content: SingleChildScrollView(
      //       scrollDirection: Axis.vertical,
      //       child: ListBody(
      //         mainAxis: Axis.vertical,
      //         children: <Widget>[
      //           Icon(Icons.warning_amber_rounded,
      //               color: Colors.red[300], size: 50),
      //           Text(
      //               'Warning: Social Distance Violated!\nYou are at a distance of less than 2 metres from another person.'),
      //         ],
      //       ),
      //     ),
      //   ),
      //   barrierDismissible: true,
      // ).then((_) => {alertboxStatus = false});
    }
    Vibration.vibrate(pattern: [500, 1000, 500, 2000]);
  }

  void stopText() {
    setState(() {
      blueOnOffStr = 'Stop Scanning';
    });
  }

  void strtText() {
    setState(() {
      blueOnOffStr = 'Start Scanning';
    });
  }

  Future<String> sideBarWait() async {
    while (!sidebarActivation) {}
    return 'loading complete';
  }

  Future<String> getUserData() async {
    if (firstLaunch) {
      var userLocalData = await FirebaseFirestore.instance
          .collection('users')
          .doc(auth.FirebaseAuth.instance.currentUser.uid)
          .get();

      savedLocalUsrData = UserDataLocal.fromData(userLocalData.data());
      if (auth.FirebaseAuth.instance.currentUser.photoURL != null) {
        googleImage = Container(
            width: 80.0,
            height: 80.0,
            decoration: new BoxDecoration(
                shape: BoxShape.circle,
                image: new DecorationImage(
                    fit: BoxFit.fill,
                    image: new NetworkImage(
                        auth.FirebaseAuth.instance.currentUser.photoURL))));
      } else {
        googleImage = Container(
          width: 80.0,
          height: 80.0,
          child: Icon(
            Icons.account_circle,
            size: 100,
          ),
        );
      }

      currUUID = hex.encode(savedLocalUsrData.uuid.codeUnits);
      print(savedLocalUsrData.email);
      setState(() {
        firstLaunch = false;
      });
      print("LL");
    }
    print("RR");
    return "RR";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: SideBar(
        covidbool: false,
      ),
      // FutureBuilder(
      //     future: sideBarWait(),
      //     builder: (context, snapshot) {
      //       if (snapshot.hasData) {
      //         SideBar(
      //           covidbool: false,
      //         );
      //       }
      //       return Container(
      //         width: 10,
      //         height: 10,
      //       );
      //     }),

      // (sidebarActivation)
      //  SideBar(
      //     covidbool: false,
      //   )
      //     : null,

      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
          child: FutureBuilder(
              future: getUserData(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  //setState(() {
                  sidebarActivation = true;
                  //});

                  return new ListView(
                    shrinkWrap: true,
                    padding: const EdgeInsets.all(8),
                    children: <Widget>[
                      Center(
                        child: TextButton(
                          style: TextButton.styleFrom(
                            primary: Colors.white,
                            backgroundColor: Colors.blue,
                            onSurface: Colors.white,
                          ),
                          child: Container(
                              width: 0.7 * MediaQuery.of(context).size.width,
                              height: 28 +
                                  0.05 *
                                      MediaQuery.of(context).size.height, //28,
                              child: Center(
                                child: Text(
                                  '$blueOnOffStr',
                                  style: TextStyle(fontSize: 26),
                                  //textScaleFactor: 1.0,
                                ),
                              )
                              //padding: EdgeInsets.all(8.0)
                              ),

                          // Row(
                          //     mainAxisAlignment: MainAxisAlignment.end,
                          //     children: <Widget>[

                          //       Padding(
                          //         padding: const EdgeInsets.only(
                          //             right: 9.5, top: 1.6),
                          //         child: Icon(Icons.arrow_back,
                          //             color: Colors.blue),
                          //       ),
                          //       Text(
                          //           "$blueOnOffStr") //, style: Theme.of(context).textTheme.bodyText2.merge(TextStyle(color: Colors.blue))),
                          //     ]),
                          // minWidth: 0.9 * MediaQuery.of(context).size.width,
                          // color: Colors.blue,
                          // textColor: Colors.white,
                          // disabledColor: Colors.grey,
                          // disabledTextColor: Colors.black,
                          // padding: EdgeInsets.all(8.0),
                          // splashColor: Colors.blueAccent,
                          onPressed: () async {
                            bool serviceCheck =
                                    await Location().serviceEnabled(),
                                locationEnabled = true;
                            if (!serviceCheck) {
                              if (!(await Location().requestService())) {
                                locationEnabled = false;
                              }
                            }
                            if (PermissionStatus.denied ==
                                await Location().hasPermission()) {
                              if (PermissionStatus.granted !=
                                  await Location().requestPermission()) {
                                locationEnabled = false;
                              }
                            }

                            isSwitched = !isSwitched;
                            if (isSwitched) {
                              stopText();
                              beaconBroadcast
                                  .setUUID(currUUID)
                                  .setMajorId(MAJOR_ID)
                                  .setMinorId(MINOR_ID)
                                  .setTransmissionPower(TRANSMISSION_POWER)
                                  .setIdentifier('Unique')
                                  .setLayout(LAYOUT)
                                  .setManufacturerId(MANUFACTURER_ID);
                              beaconBroadcast
                                  .start(); //.timeout(Duration(milliseconds: 3)){};
                              flutterBlue.startScan(
                                timeout: Duration(seconds: 4),
                                allowDuplicates: false,
                                scanMode: ScanMode.lowLatency,
                              );
                              flutterBlue.scanResults.listen((results) async {
                                // do something with scan results
                                resCount = results.length;
                                if (resCount <= 5) {
                                  noiseLevel = 2;
                                } else if (resCount > 5 && resCount <= 10) {
                                  noiseLevel = 3;
                                } else {
                                  noiseLevel = 4;
                                }
                                for (ScanResult r in results) {
                                  int myUniqueKey = 5636; //5636;
                                  if (r.advertisementData.manufacturerData
                                      .containsKey(myUniqueKey)) {
                                    double deviceDistance = math.pow(
                                        10,
                                        (r.rssi - TRANSMISSION_POWER) /
                                            (10 * noiseLevel));
                                    print(deviceDistance);
                                    if (deviceDistance < 2.0 && false) {
                                      if (locationEnabled) {
                                        LocationData locationData =
                                            await Location().getLocation();
                                        currentLatitude =
                                            locationData.latitude /
                                                (180 / math.pi);
                                        currentLongitude =
                                            locationData.longitude /
                                                (180 / math.pi);
                                      }
                                      var scanUuid = hex.encode(r
                                          .advertisementData
                                          .manufacturerData
                                          .values
                                          .toList()[0]
                                          .sublist(2, 18));
                                      var contactUuid = String.fromCharCodes(r
                                          .advertisementData
                                          .manufacturerData
                                          .values
                                          .toList()[0]
                                          .sublist(2, 18));
                                      print("$scanUuid, $currUUID");
                                      if (scanUuid != currUUID) {
                                        if (contactedUsers
                                            .containsKey(contactUuid)) {
                                          contactedUsers.update(contactUuid,
                                              (value) => DateTime.now());
                                        } else {
                                          contactedUsers[contactUuid] =
                                              DateTime.now();
                                        }
                                        // popupCancel1 = CancelableOperation
                                        //         .fromFuture(popup(sessionId))
                                        //     .then((_) => );
                                        popup(sessionId).then(
                                            (_) => {alertboxStatus = true});
                                        // await popup().then((_) => {
                                        //       alertboxStatus = true,
                                        //     });
                                      }
                                    }
                                  }
                                }
                              }).onDone(() {
                                flutterBlue.stopScan();
                              });
                              if (await flutterBlue.isOn) {
                                print("Open Bluetooth");
                              }
                              scanInv = new Timer.periodic(
                                  Duration(seconds: 6),
                                  (Timer t) => {
                                        flutterBlue.startScan(
                                          timeout: Duration(seconds: 4),
                                          allowDuplicates: false,
                                          scanMode: ScanMode.lowLatency,
                                        ),
                                        flutterBlue.scanResults
                                            .listen((results) async {
                                          // do something with scan results
                                          resCount = results.length;
                                          if (resCount <= 5) {
                                            noiseLevel = 2;
                                          } else if (resCount > 5 &&
                                              resCount <= 10) {
                                            noiseLevel = 3;
                                          } else {
                                            noiseLevel = 4;
                                          }
                                          for (ScanResult r in results) {
                                            int myUniqueKey = 5636; //5636;
                                            if (r.advertisementData
                                                .manufacturerData
                                                .containsKey(myUniqueKey)) {
                                              double deviceDistance = math.pow(
                                                  10,
                                                  (r.rssi -
                                                          TRANSMISSION_POWER) /
                                                      (10 * noiseLevel));
                                              print(deviceDistance);
                                              if (deviceDistance < 2.0 &&
                                                  false) {
                                                if (locationEnabled) {
                                                  LocationData locationData =
                                                      await Location()
                                                          .getLocation();
                                                  currentLatitude =
                                                      locationData.latitude /
                                                          (180 / math.pi);
                                                  currentLongitude =
                                                      locationData.longitude /
                                                          (180 / math.pi);
                                                }
                                                print("$myUniqueKey");
                                                var scanUuid = hex.encode(r
                                                    .advertisementData
                                                    .manufacturerData
                                                    .values
                                                    .toList()[0]
                                                    .sublist(2, 18));
                                                var contactUuid =
                                                    String.fromCharCodes(r
                                                        .advertisementData
                                                        .manufacturerData
                                                        .values
                                                        .toList()[0]
                                                        .sublist(2, 18));
                                                if (scanUuid != currUUID) {
                                                  if (contactedUsers
                                                      .containsKey(
                                                          contactUuid)) {
                                                    contactedUsers.update(
                                                        contactUuid,
                                                        (value) =>
                                                            DateTime.now());
                                                  } else {
                                                    contactedUsers[
                                                            contactUuid] =
                                                        DateTime.now();
                                                  }
                                                  popup(sessionId).then((_) =>
                                                      {alertboxStatus = true});
                                                }
                                                // print(
                                                //     '${r.device} found! rssi: ${r.rssi},key: ${r.advertisementData.manufacturerData.keys},adv_data: ${r.advertisementData.manufacturerData.values.toList()[0]},');
                                              }
                                            }
                                          }
                                        }).onDone(() {
                                          flutterBlue.stopScan();
                                        }),
                                      });

                              firebaseUpload = new Timer.periodic(
                                  Duration(seconds: 10),
                                  (Timer t) => {
                                        contactedUsers
                                            .forEach((key, value) async {
                                          print("$key, $value");
                                          await FirebaseFirestore.instance
                                              .collection('userCloseContact')
                                              .add({
                                            'uuid1': savedLocalUsrData.uuid,
                                            'name': savedLocalUsrData.name,
                                            'uuid2': key,
                                            'timestamp': Timestamp
                                                .fromMillisecondsSinceEpoch(value
                                                    .millisecondsSinceEpoch),
                                            'location': GeoPoint(
                                                currentLatitude,
                                                currentLongitude),
                                          });
                                        }),
                                        contactedUsers.clear(),
                                      });
                            } else {
                              // print(
                              //     'Off_Status: ${await beaconBroadcast.isAdvertising()},${scanInv.isActive},$isSwitched');
                              if (await beaconBroadcast.isAdvertising()) {
                                beaconBroadcast.stop();
                                print("stop");
                              }
                              // if (!popupCancel2.isCompleted) {
                              //   popupCancel2.cancel();
                              // }
                              // if (!popupCancel1.isCompleted) {
                              //   popupCancel1.cancel();
                              // }
                              if (scanInv.isActive) {
                                scanInv.cancel();
                              }
                              if (await flutterBlue.isOn) {
                                flutterBlue.stopScan();
                              }
                              if (firebaseUpload.isActive) {
                                firebaseUpload.cancel();
                              }
                              alertboxStatus = false;
                              strtText();
                              sessionId = sessionId + 1;
                              return null;
                            }
                          },
                          // child: Text(
                          //   '$blueOnOffStr',
                          //   style: TextStyle(fontSize: 20.0),
                          // ),
                        ),
                      ),
                      SizedBox(
                        height: 0.2 * MediaQuery.of(context).size.height,
                      ),
                    ],
                  );
                } else if (snapshot.hasError) {
                  return Text("${snapshot.error}");
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
