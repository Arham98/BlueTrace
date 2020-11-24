//import 'package:blue_trace/main.dart';
import 'dart:async';
import 'package:blue_trace/login.dart';
import 'package:convert/convert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:beacon_broadcast/beacon_broadcast.dart';
import 'package:vibration/vibration.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:blue_trace/sidebar.dart';
import 'package:blue_trace/auth.dart';

class ScanPage extends StatefulWidget {
  ScanPage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _ScanPageState createState() => _ScanPageState(key: key, title: title);
}

class _ScanPageState extends State<ScanPage> {
  _ScanPageState({Key key, this.title});
  final String title;
  FlutterBlue flutterBlue = FlutterBlue.instance;
  bool isSwitched = false;
  bool alertboxStatus = false;
  Timer scanInv;
  String blueOnOffStr = 'Start Scanning';

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  var androidInitializationSettings;
  //var initializationSettings;

  static const UUID =
      '7a3973415133734f78564c757957734f'; //'62bdc0ef-7bd3-41eb-9923-59ea8b1241d3';
  static const MAJOR_ID = 1;
  static const MINOR_ID = 1;
  static const TRANSMISSION_POWER = 3;
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
    androidInitializationSettings =
        new AndroidInitializationSettings('mipmap/ic_launcher');
  }

  // Future selectNotification(String payload) async {
  //   if (payload != null) {
  //     debugPrint('notification payload: $payload');
  //   }
  //   await Navigator.push(
  //     context,
  //     MaterialPageRoute<void>(builder: (context) => SecondScreen(payload)),
  //   );
  // }

  Future<void> notificationFunc() async {
    AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
            'your channel id', 'your channel name', 'your channel description',
            importance: Importance.max,
            priority: Priority.high,
            showWhen: false);
    NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
        0,
        'Close Contact',
        'You are within less than 2 metres near someone, please maintain social distancing.',
        platformChannelSpecifics,
        payload: 'item x');
  }

  // void _showNotif() async {
  //   await notificationFunc();
  // }

  Future<void> popup() async {
    if (alertboxStatus == false) {
      alertboxStatus = true;
      showDialog(
        //User friendly error message when the screen has been displayed
        context: context,
        builder: (_) => AlertDialog(
          title: Text(
            "Close Contact Alert",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 28),
          ),
          content: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: ListBody(
              mainAxis: Axis.vertical,
              children: <Widget>[
                Icon(Icons.warning_amber_rounded,
                    color: Colors.red[300], size: 50),
                Text(
                    'Warning: Social Distance Violated!\nYou are at a distance of less than 2 metres from another person.'),
              ],
            ),
          ),
        ),
        barrierDismissible: true,
      ).then((_) => {alertboxStatus = false});
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: SideBar(
        covidbool: false,
      ),
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: new ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.all(8),
          children: <Widget>[
            Center(
              child: FlatButton(
                minWidth: 0.9 * MediaQuery.of(context).size.width,
                color: Colors.blue,
                textColor: Colors.white,
                disabledColor: Colors.grey,
                disabledTextColor: Colors.black,
                padding: EdgeInsets.all(8.0),
                splashColor: Colors.blueAccent,
                onPressed: () async {
                  isSwitched = !isSwitched;
                  if (isSwitched) {
                    stopText();
                    beaconBroadcast
                        .setUUID(UUID)
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
                      for (ScanResult r in results) {
                        int myUniqueKey = 5636; //5636;
                        if (r.advertisementData.manufacturerData
                            .containsKey(myUniqueKey)) {
                          var scanUuid = hex.encode(r
                              .advertisementData.manufacturerData.values
                              .toList()[0]
                              .sublist(2, 18));
                          if (scanUuid == UUID) {
                            await popup();
                            alertboxStatus = true;
                            //print('uuid: $scanUuid');
                          }
                          // print(
                          //     '${r.device} found! rssi: ${r.rssi},key: ${r.advertisementData.manufacturerData.keys},adv_data: ${r.advertisementData.manufacturerData.values.toList()[0]},');
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
                              flutterBlue.scanResults.listen((results) async {
                                // do something with scan results
                                for (ScanResult r in results) {
                                  int myUniqueKey = 5636; //5636;
                                  if (r.advertisementData.manufacturerData
                                      .containsKey(myUniqueKey)) {
                                    var scanUuid = hex.encode(r
                                        .advertisementData
                                        .manufacturerData
                                        .values
                                        .toList()[0]
                                        .sublist(2, 18));
                                    if (scanUuid == UUID) {
                                      await popup();
                                      alertboxStatus = true;
                                      //print('uuid: $scanUuid');
                                    }
                                    // print(
                                    //     '${r.device} found! rssi: ${r.rssi},key: ${r.advertisementData.manufacturerData.keys},adv_data: ${r.advertisementData.manufacturerData.values.toList()[0]},');
                                  }
                                }
                              }).onDone(() {
                                flutterBlue.stopScan();
                              }),
                            });
                  } else {
                    // print(
                    //     'Off_Status: ${await beaconBroadcast.isAdvertising()},${scanInv.isActive},$isSwitched');
                    if (await beaconBroadcast.isAdvertising()) {
                      beaconBroadcast.stop();
                    }
                    if (scanInv.isActive) {
                      scanInv.cancel();
                    }
                    strtText();
                    return null;
                  }
                },
                child: Text(
                  '$blueOnOffStr',
                  style: TextStyle(fontSize: 20.0),
                ),
              ),
            ),
            // Padding(
            //   padding: EdgeInsets.all(16.0),
            // ),
            SizedBox(
              height: 0.2 * MediaQuery.of(context).size.height,
            ),
            Center(
              child: FlatButton(
                minWidth: 0.5 * MediaQuery.of(context).size.width,
                color: Colors.blue,
                textColor: Colors.white,
                disabledColor: Colors.grey,
                disabledTextColor: Colors.black,
                padding: EdgeInsets.all(8.0),
                splashColor: Colors.blueAccent,
                onPressed: () async {
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
                  //await ;
                },
                child: Text(
                  'Sign Out',
                  style: TextStyle(fontSize: 20.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
