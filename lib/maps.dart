import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/widgets.dart';
import 'dart:async';
import 'package:blue_trace/user.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:blue_trace/Mapper.dart';
import 'dart:math' as math;
//import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class MarkerText {
  String title;
  String name;
  DateTime date;

  MarkerText({this.title, this.name, this.date});
}

//adding to maps api to the application for the location info
class Maps extends StatefulWidget {
  Maps({Key key, this.type, this.lat, this.lon}) : super(key: key);
  final String type;
  final double lat;
  final double lon;

  @override
  MapsFunc createState() => MapsFunc(key: key, type: type, lat: lat, lon: lon);
}

class MapsFunc extends State<Maps> {
  MapsFunc({Key key, this.type, this.lat, this.lon});
  final String type;
  final double lat;
  final double lon;

  LatLng coord;
  LatLng initialCoordinates = LatLng(31.471909323235746, 74.40681226551533);
  List<ContactData> contactsData = [];

  Completer<GoogleMapController> _controller = Completer();
  Marker marker = Marker(
      markerId: MarkerId("1"),
      draggable: true); //storing position coordinates in the variable
  Set<Marker> markerSet = {};
  Set<MarkerText> markerTextSet = {};

  var scaffoldKey = GlobalKey<ScaffoldState>();
  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  Future<void> getMapDatahelper(
      BuildContext context, MarkerText mrkrDat) async {
    await showModalBottomSheet(
        context: context,
        builder: (context) => Container(
              height: MediaQuery.of(context).size.height * 0.25,
              color: Colors.white,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      mrkrDat.title,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                    Text("Contact with: ${mrkrDat.name}",
                        style: TextStyle(fontSize: 16)),
                    Text("Time: ${mrkrDat.date}",
                        style: TextStyle(fontSize: 16)),
                    ElevatedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.clear),
                        label: Text("Dismiss")),
                  ],
                ),
              ),
            ));
  }

  Future<String> getMapData(BuildContext context) async {
    if (type == "specific") {
      initialCoordinates = LatLng(lat, lon);
    }
    var userMapData = await FirebaseFirestore.instance
        .collection('contactData')
        .where('uuid', isEqualTo: savedLocalUsrData.uuid)
        .get();
    int ind = 0;
    if (userMapData.docs.isNotEmpty) {
      userMapData.docs.forEach((element) {
        //print(element.data());
        ContactData tempMapData = ContactData.fromData(element.data());
        contactsData.add(tempMapData);
        DateTime timess = DateTime.fromMillisecondsSinceEpoch(
            tempMapData.timestamp.millisecondsSinceEpoch);
        MarkerText mrkrDat = MarkerText(
            date: timess,
            title: (tempMapData.covidStatus)
                ? "Contact with COVID patient"
                : "Close Contact with person",
            name: tempMapData.sndUserName);
        Marker tmpMarker = Marker(
          markerId: MarkerId(ind.toString()),
          infoWindow: InfoWindow(
            title:
                (tempMapData.covidStatus) ? "COVID Contact" : "Normal Contact",
            //snippet:
            //     "Came in Contact with: ${tempMapData.sndUserName}\nAt Time: $timess",
          ),
          icon: (tempMapData.covidStatus)
              ? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed)
              : BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueYellow),
          flat: true,
          position: LatLng((tempMapData.location.latitude / math.pi) * 180,
              (tempMapData.location.longitude / math.pi) * 180),
          onTap: () async {
            await getMapDatahelper(context, mrkrDat);
          },
        );
        print(
            "${(tempMapData.location.latitude / math.pi) * 180},${(tempMapData.location.longitude / math.pi) * 180}");
        markerSet.add(tmpMarker);
        ind = ind + 1;
      });
    }
    // .doc(auth.FirebaseAuth.instance.currentUser.uid)
    // .get();
    //print(userLocalData);
    // contactsData = UserDataLocal.fromData(userLocalData.data());
    // print(savedLocalUsrData.email);
    return "End";
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          key: scaffoldKey,
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () => {Navigator.of(context).pop()},
            ),
            title: Text("Contact Map"),
          ),
          body: Center(
            child: FutureBuilder(
                future: getMapData(context),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return GoogleMap(
                      //using the google map api
                      // onTap: (LatLng coordinates) {
                      //   //This gesture function will place a marker whereever the user taps on the map
                      //   final Marker marker1 = Marker(
                      //     markerId: MarkerId('1'),
                      //     draggable: true,
                      //     position: coordinates,
                      //   );
                      //   setState(() {
                      //     markerSet.clear();
                      //     markerSet.add(marker1);
                      //     marker = marker1;
                      //     print(
                      //         "${contactsData.length},${coordinates.latitude},${coordinates.longitude}");
                      //     coord =
                      //         coordinates; //coordinates (latitude and longitude) are saved in coord which is LatLng variable
                      //   });
                      // },
                      markers: markerSet,
                      onMapCreated: _onMapCreated,
                      initialCameraPosition: CameraPosition(
                        //Initial Position of Google Maps
                        target: initialCoordinates,
                        zoom: 15,
                      ),
                      mapType: MapType.hybrid,
                      rotateGesturesEnabled: true,
                      scrollGesturesEnabled: true,
                      tiltGesturesEnabled: true,
                      myLocationEnabled: true,
                    );
                  } else if (snapshot.hasError) {
                    return Text("${snapshot.error}");
                  }
                  // By default, show a loading spinner
                  return SpinKitFadingCircle(
                    color: Colors.cyan,
                    size: 75.0,
                  );
                }),
          )),
    );
  }
}
