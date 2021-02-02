import 'package:flutter/material.dart';
import 'package:blue_trace/auth.dart';

class UserProfile extends StatefulWidget {
  @override
  UserProfileState createState() => UserProfileState();
}

class UserProfileState extends State<UserProfile> {
  Map<String, dynamic> _profile;
  bool _loading = false;

  @override
  initState() {
    super.initState();

    // Subscriptions are created here
    authService.profile.listen((state) => setState(() => _profile = state));

    authService.loading.listen((state) => setState(() => _loading = state));
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      Container(padding: EdgeInsets.all(20), child: Text(_profile.toString())),
      Text(_loading.toString())
    ]);
  }
}

class UserDataLocal {
  int cnic;
  bool covidStatus;
  String email;
  String googleUid;
  String name;
  String uuid;

  UserDataLocal(
      {this.cnic,
      this.covidStatus,
      this.email,
      this.googleUid,
      this.name,
      this.uuid});

  UserDataLocal.fromData(Map<String, dynamic> data)
      : cnic = data['cnic'], //int.parse(data['cnic']),
        covidStatus = data['covidStatus'], //.toLowerCase() == 'true',
        email = data['email'],
        googleUid = data['googleUid'],
        name = data['name'],
        uuid = data['uuid'];
}

UserDataLocal savedLocalUsrData;
