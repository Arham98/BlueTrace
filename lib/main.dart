import 'dart:async';
//import 'dart:math';
import 'package:convert/convert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:beacon_broadcast/beacon_broadcast.dart';
import 'package:vibration/vibration.dart';
//import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  FlutterBlue flutterBlue = FlutterBlue.instance;
  bool isSwitched = false;
  bool alertbox_status = false;
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

  Future<void> popup() async {
    if (alertbox_status == false) {
      alertbox_status = true;
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
      ).then((_) => {alertbox_status = false});
    }
    Vibration.vibrate(pattern: [500, 1000, 500, 2000]);
  }

  void _showNotif() async {
    await notificationFunc();
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
      appBar: AppBar(
        title: Text("Bluetooth Tracing App"),
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

                    scanInv = new Timer.periodic(
                        Duration(milliseconds: 4200),
                        (Timer t) => {
                              flutterBlue.startScan(
                                  timeout: Duration(seconds: 4),
                                  allowDuplicates: false,
                                  scanMode: ScanMode.lowLatency
                                  //withServices: []
                                  ),
                              flutterBlue.scanResults.listen((results) async {
                                // do something with scan results
                                for (ScanResult r in results) {
                                  int myUniqueKey = 5636; //5636;
                                  if (r.advertisementData.manufacturerData
                                      .containsKey(myUniqueKey)) {
                                    var scanUuid = hex.encode(r
                                        .advertisementData
                                        .manufacturerData[myUniqueKey]);
                                    if (scanUuid == UUID) {
                                      await popup();
                                      alertbox_status = true;
                                      print('uuid: $scanUuid');
                                    }
                                    // print(
                                    //     '${r.device} found! rssi: ${r.rssi},${r.device.name},adv_data: ${r.advertisementData},');
                                  }
                                }
                              }).onDone(() {
                                flutterBlue.stopScan();
                              }),
                            });
                  } else {
                    print(
                        'Off_Status: ${await beaconBroadcast.isAdvertising()},${scanInv.isActive},$isSwitched');
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
            Padding(
              padding: EdgeInsets.all(16.0),
            ),
          ],
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () async {
      //     popup();
      //     //_showNotif();
      //     // Add your onPressed code here!
      //   },
      //   child: Icon(Icons.notification_important),
      //   backgroundColor: Colors.green,
      // ),
    );
  }
}
