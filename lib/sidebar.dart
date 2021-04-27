//import 'dart:ffi';

import 'package:blue_trace/maps.dart';
import 'package:blue_trace/user.dart';
import 'package:blue_trace/Popups.dart';
import 'package:blue_trace/covid.dart';
// import 'package:blue_trace/Scanner.dart' as scannerpgdata;
import 'package:flutter/material.dart';
import 'package:blue_trace/login.dart';
import 'package:blue_trace/main.dart';
//import 'package:firebase_auth/firebase_auth.dart' as auth;

class SideBar extends StatefulWidget {
  SideBar({Key key, this.covidbool});
  final bool covidbool;
  @override
  SideBarProperties createState() =>
      new SideBarProperties(covidbool: covidbool);
}

class LabeledCheckbox extends StatelessWidget {
  const LabeledCheckbox({
    this.label,
    this.padding,
    this.value,
    this.onChanged,
  });

  final String label;
  final EdgeInsets padding;
  final bool value;
  final Function onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CovidPage()),
        );
      },
      child: ListTile(
        leading: Icon(Icons.coronavirus_outlined),
        title: Text(label),
        trailing: Checkbox(
          value: value,
          onChanged: null,
          // (bool newValue) async {
          //   onChanged(newValue);
          // },
        ),
      ),
    );
  }
}

class SideBarProperties extends State<SideBar> {
  SideBarProperties({Key key, this.covidbool});
  bool covidbool;
  String username;
  String curruuid;

  @override
  void initState() {
    super.initState();

    covidbool = savedLocalUsrData.covidStatus;
    username = savedLocalUsrData.name;
    curruuid = savedLocalUsrData.uuid;
    //WidgetsBinding.instance.addPostFrameCallback((_) {});
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                googleImage,
                Padding(padding: EdgeInsets.all(10)),
                Text(
                  savedLocalUsrData.name,
                  style: TextStyle(color: Colors.white, fontSize: 25),
                ),
              ],
            ),
            decoration: BoxDecoration(
              color: Colors.blue,
              // image: DecorationImage(
              //     fit: BoxFit.fill,
              //     image: AssetImage('assets/images/cover.jpg'))
            ),
          ),
          // ListTile(
          //   leading: Icon(Icons.verified_user),
          //   title: Text('Profile'),
          //   onTap: () => {Navigator.of(context).pop()},
          // ),
          ListTile(
            leading: Icon(Icons.coronavirus_outlined),
            title: Text('Update Covid Status'),
            onTap: () => {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CovidPage()),
              )
            },
          ),
          // LabeledCheckbox(
          //   label: 'Update Covid Status',
          //   padding: const EdgeInsets.symmetric(horizontal: 20.0),
          //   value: savedLocalUsrData.covidStatus,
          //   onChanged: null,
          // ),
          ListTile(
            leading: Icon(Icons.location_pin),
            title: Text('Trace Map'),
            onTap: () => {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => Maps(
                          type: "specific",
                          lat: locDataUsr.lat,
                          lon: locDataUsr.lon,
                        )),
              ),
            },
          ),
          ListTile(
            leading: Icon(Icons.help),
            title: Text('Help'),
            onTap: () => {
              Navigator.of(context).pop(),
              popupTerms(context),
            },
          ),
          ListTile(
            leading: Icon(Icons.business_center),
            title: Text('Terms & Conditions'),
            onTap: () => {
              Navigator.of(context).pop(),
              popupTerms(context),
            },
          ),
          LogoutButton(),
          SizedBox(height: 30),
          ListTile(
            leading: Icon(Icons.info),
            enabled: false,
            title: Text(
              'Please note that you cannot uncheck the covid checkbox, and must only enable it if you have received your test results poistive for Covid-19.',
              textScaleFactor: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
