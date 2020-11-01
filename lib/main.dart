//import 'dart:async';
//import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:beacon_broadcast/beacon_broadcast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_ble_peripheral/data.dart';
import 'package:flutter_ble_peripheral/main.dart';
import 'package:flutter/services.dart';
import 'package:background_fetch/background_fetch.dart';

void backgroundFetchHeadlessTask(String taskId) async {
  print('[BackgroundFetch] Headless event received.');
  BackgroundFetch.finish(taskId);
}

void main() {
  runApp(MyApp2());
  BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _enabled = true;
  int _status = 0;
  List<DateTime> _events = [];

  //void
  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    // Configure BackgroundFetch.
    BackgroundFetch.configure(BackgroundFetchConfig(minimumFetchInterval: 15, stopOnTerminate: false, enableHeadless: true, requiresBatteryNotLow: false, requiresCharging: false, requiresStorageNotLow: false, requiresDeviceIdle: false, requiredNetworkType: NetworkType.NONE), (String taskId) async {
      // This is the fetch-event callback.
      print("[BackgroundFetch] Event received $taskId");
      setState(() {
        _events.insert(0, new DateTime.now());
      });
      // IMPORTANT:  You must signal completion of your task or the OS can punish your app
      // for taking too long in the background.
      BackgroundFetch.finish(taskId);
    }).then((int status) {
      print('[BackgroundFetch] configure success: $status');
      setState(() {
        _status = status;
      });
    }).catchError((e) {
      print('[BackgroundFetch] configure ERROR: $e');
      setState(() {
        _status = e;
      });
    });

    // Optionally query the current BackgroundFetch status.
    int status = await BackgroundFetch.status;
    setState(() {
      _status = status;
    });

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;
  }

  void _onClickEnable(enabled) {
    setState(() {
      _enabled = enabled;
    });
    if (enabled) {
      BackgroundFetch.start().then((int status) {
        print('[BackgroundFetch] start success: $status');
      }).catchError((e) {
        print('[BackgroundFetch] start FAILURE: $e');
      });
    } else {
      BackgroundFetch.stop().then((int status) {
        print('[BackgroundFetch] stop success: $status');
      });
    }
  }

  void _onClickStatus() async {
    int status = await BackgroundFetch.status;
    print('[BackgroundFetch] status: $status');
    setState(() {
      _status = status;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(title: const Text('BackgroundFetch Example', style: TextStyle(color: Colors.black)), backgroundColor: Colors.amberAccent, brightness: Brightness.light, actions: <Widget>[
          Switch(value: _enabled, onChanged: _onClickEnable),
        ]),
        body: Container(
          color: Colors.black,
          child: new ListView.builder(
              itemCount: _events.length,
              itemBuilder: (BuildContext context, int index) {
                DateTime timestamp = _events[index];
                return InputDecorator(decoration: InputDecoration(contentPadding: EdgeInsets.only(left: 10.0, top: 10.0, bottom: 0.0), labelStyle: TextStyle(color: Colors.amberAccent, fontSize: 20.0), labelText: "[background fetch event]"), child: new Text(timestamp.toString(), style: TextStyle(color: Colors.white, fontSize: 16.0)));
              }),
        ),
        bottomNavigationBar: BottomAppBar(child: Row(children: <Widget>[RaisedButton(onPressed: _onClickStatus, child: Text('Status')), Container(child: Text("$_status"), margin: EdgeInsets.only(left: 20.0))])),
      ),
    );
  }
}

class MyApp2 extends StatelessWidget {
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
  bool _trackingenabled = false;
  //final value = "XPTOXXSFXBAC"
  //    .replaceAllMapped(RegExp(r".{4}"), (match) => "${match.group(0)} ");
  static const UUID = '7a3973415133734f78564c757957734f'; //'62bdc0ef-7bd3-41eb-9923-59ea8b1241d3';
  static const MAJOR_ID = 1;
  static const MINOR_ID = 1;
  static const TRANSMISSION_POWER = 3;
  static const LAYOUT = 'm:2-3=beac,i:4-19,i:20-21,i:22-23,p:24-24,d:25-25'; //BeaconBroadcast.ALTBEACON_LAYOUT;

  static const MANUFACTURER_ID = 0x1604; //0x1604
  BeaconBroadcast beaconBroadcast = BeaconBroadcast();
  BeaconStatus _isTransmissionSupported;
  //bool _isAdvertising = false;

  // FlutterBlePeripheral blePeripheral = FlutterBlePeripheral();
  // AdvertiseData _data = AdvertiseData();
  // bool _isBroadcasting = false;

  @override
  void initState() {
    super.initState();
    beaconBroadcast.checkTransmissionSupported().then((isTransmissionSupported) {
      setState(() {
        _isTransmissionSupported = isTransmissionSupported;
      });
    });
    // setState(() {
    //   _data.includeDeviceName = false;
    //   _data.uuid = 'bf27730d-860a-4e09-889c-2d8b6a9e0fe7';
    //   _data.manufacturerId = 1234;
    //   _data.manufacturerData = [1, 2, 3, 4, 5, 6];
    //   _data.transmissionPowerIncluded = true;
    // });
    // initPlatformState();
  }

  // Future<void> initPlatformState() async {
  //   bool isAdvertising = await blePeripheral.isAdvertising();
  //   setState(() {
  //     _isBroadcasting = isAdvertising;
  //   });
  // }

  // void _toggleAdvertise() async {
  //   if (false) {
  //     //await blePeripheral.isAdvertising()) {
  //     blePeripheral.stop();
  //     setState(() {
  //       _isBroadcasting = false;
  //     });
  //   } else {
  //     blePeripheral.start(_data);
  //     setState(() {
  //       _isBroadcasting = true;
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        title: Text("Bluetooth App"),
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
                onPressed: () {
                  //=> _toggleAdvertise(),
                  beaconBroadcast.setUUID(UUID).setMajorId(MAJOR_ID).setMinorId(MINOR_ID).setTransmissionPower(TRANSMISSION_POWER).setIdentifier('Unique').setLayout(LAYOUT).setManufacturerId(MANUFACTURER_ID);
                  beaconBroadcast.start(); //.timeout(Duration(milliseconds: 3)){};
                  flutterBlue.startScan(timeout: Duration(seconds: 4), allowDuplicates: false, scanMode: ScanMode.lowLatency
                      //withServices: []
                      );

                  flutterBlue.scanResults.listen((results) {
                    // do something with scan results
                    for (ScanResult r in results) {
                      if (r.advertisementData.manufacturerData.containsKey(6)) {
                        //5636)) {
                        print('${r.device} found! rssi: ${r.rssi},${r.device.name},adv_data: ${r.advertisementData},');
                        print(beaconBroadcast.checkTransmissionSupported());
                      }
                    }
                  });

                  //beaconBroadcast.stop();
                },
                child: Text(
                  "Broadcast Advertisements",
                  style: TextStyle(fontSize: 20.0),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16.0),
            ),
            Center(
              child: FlatButton(
                minWidth: 0.9 * MediaQuery.of(context).size.width,
                color: Colors.blue,
                textColor: Colors.white,
                disabledColor: Colors.grey,
                disabledTextColor: Colors.black,
                padding: EdgeInsets.all(8.0),
                splashColor: Colors.blueAccent,
                onPressed: () {
                  flutterBlue.stopScan();
                  beaconBroadcast.stop();
                },
                child: Text(
                  "Scan Advertisements",
                  style: TextStyle(fontSize: 20.0),
                ),
              ),
            ),
            Switch(
              value: _trackingenabled,
              onChanged: (bool value) {},
            )
          ],
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   //onPressed:
      //   tooltip: 'Increment',
      //   child: Icon(Icons.add),
      // ),
    );
  }
}
