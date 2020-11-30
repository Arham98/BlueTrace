import 'package:blue_trace/Mapper.dart';
import 'package:blue_trace/services.dart';
import 'package:blue_trace/Scanner.dart' as scannerpgdata;
import 'package:flutter/material.dart';
import 'package:blue_trace/login.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart';

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
        onChanged(!value);
      },
      child: ListTile(
        leading: Icon(Icons.coronavirus_outlined),
        title: Text('Feedback1'),
        trailing: Checkbox(
          value: value,
          onChanged: (bool newValue) async {
            onChanged(newValue);
          },
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
  bool covidFlag;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _asyncMethod();
    });
  }

  _asyncMethod() async {
    UserData dat = scannerpgdata.myUserData;
    covidbool = dat.covidStatus;
    username = dat.name;
    curruuid = dat.uuid;
    covidFlag = dat.covidStatus;
    // print(scannerpgdata.myUserData.email);
    // print(scannerpgdata.myUserData.covidStatus);
    // print(scannerpgdata.myUserData.googleUid);
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            child: Text(
              scannerpgdata.myUserData.name,
              style: TextStyle(color: Colors.white, fontSize: 25),
            ),
            decoration: BoxDecoration(
              color: Colors.blue,
              // image: DecorationImage(
              //     fit: BoxFit.fill,
              //     image: AssetImage('assets/images/cover.jpg'))
            ),
          ),
          ListTile(
            leading: Icon(Icons.verified_user),
            title: Text('Profile'),
            onTap: () => {Navigator.of(context).pop()},
          ),
          LabeledCheckbox(
            label: 'This is the label text',
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            value: covidbool,
            onChanged: (bool newValue) async {
              //print("$covidbool,$newValue");
              if (newValue == true) {
                await FirebaseFirestore.instance
                    .collection('covidPositive')
                    .add({
                  'uuid': curruuid,
                  'timestamp': Timestamp.fromMillisecondsSinceEpoch(
                      DateTime.now().millisecondsSinceEpoch),
                  'user': username,
                });
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(auth.FirebaseAuth.instance.currentUser.uid)
                    .set({
                  'covidStatus': true,
                }, SetOptions(merge: true));
                //await WebAppServices.sendCovidSignal(
                //    scannerpgdata.myUserData.uuid);
              } else {
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(auth.FirebaseAuth.instance.currentUser.uid)
                    .set({
                  'covidStatus': false,
                }, SetOptions(merge: true));
              }
              setState(() {
                scannerpgdata.myUserData.covidStatus = newValue;
                covidbool = newValue;
              });
            },
          ),
          ListTile(
            leading: Icon(Icons.border_color),
            title: Text('Feedback1'),
            onTap: () => {Navigator.of(context).pop()},
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
