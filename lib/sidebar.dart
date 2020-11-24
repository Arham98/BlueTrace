import 'package:blue_trace/Mapper.dart';
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

class SideBarProperties extends State<SideBar> {
  SideBarProperties({Key key, this.covidbool});
  bool covidbool;
  String username;
  String curruuid;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _asyncMethod();
    });
  }

  _asyncMethod() async {
    await FirebaseFirestore.instance
        .collection("users")
        .where('googleUid',
            isEqualTo: auth.FirebaseAuth.instance.currentUser.uid)
        .get()
        .then((val) async {
      UserData dat = UserData.fromData(val.docs.first.data());
      covidbool = dat.covidStatus;
      username = dat.name;
      curruuid = dat.uuid;
      print(dat.email);
    }).catchError((e) {
      print(e);
    });
  }

  @override
  Widget build(BuildContext context) {
    //await initstate();
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            child: Text(
              'Side menu',
              style: TextStyle(color: Colors.white, fontSize: 25),
            ),
            decoration: BoxDecoration(
              color: Colors.blueGrey,
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
          CheckboxListTile(
            title: const Text('Tested Covid Positive'),
            secondary: const Icon(Icons.coronavirus_outlined),
            value: covidbool,
            onChanged: (val) async {
              await FirebaseFirestore.instance
                  .collection('userCloseContact')
                  .add({
                'uuid': curruuid,
                'timestamp': Timestamp.fromMillisecondsSinceEpoch(
                    DateTime.now().millisecondsSinceEpoch),
                'user': username,
              });
              if (val && covidbool == false) {
                setState(() {
                  covidbool = true;
                });
              } else if (val) {
                return null;
              } else {
                val = true;
              }
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
