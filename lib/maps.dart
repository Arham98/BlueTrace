import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'dart:io';
import 'dart:async';

//adding to maps api to the application for the location info
class Maps extends StatefulWidget {
  @override
  MapsFunc createState() => MapsFunc();
}

class MapsFunc extends State<Maps> {
  LatLng coord;
  Completer<GoogleMapController> _controller = Completer();
  Marker marker = Marker(
      markerId: MarkerId("1"),
      draggable: true); //storing position coordinates in the variable
  Set<Marker> markerSet = {};
  var scaffoldKey = GlobalKey<ScaffoldState>();
  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        key: scaffoldKey,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: Text("Contact Map"),
        ),
        body: GoogleMap(
          //using the google map api
          onTap: (LatLng coordinates) {
            //This gesture function will place a marker whereever the user taps on the map
            final Marker marker1 = Marker(
              markerId: MarkerId('1'),
              draggable: true,
              position: coordinates,
            );
            setState(() {
              markerSet.clear();
              markerSet.add(marker1);
              marker = marker1;
              coord =
                  coordinates; //coordinates (latitude and longitude) are saved in coord which is LatLng variable
            });
          },
          markers: markerSet,
          onMapCreated: _onMapCreated,
          initialCameraPosition: CameraPosition(
            //Initial Position of Google Maps
            target: LatLng(30, 68),
            zoom: 5,
          ),
          mapType: MapType.hybrid,
          rotateGesturesEnabled: true,
          scrollGesturesEnabled: true,
          tiltGesturesEnabled: true,
          myLocationEnabled: true,
        ),
      ),
    );
  }
}
