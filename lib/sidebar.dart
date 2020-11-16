import 'package:flutter/material.dart';

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
  bool _ischecked;
  // void onChanged(bool val){
  //   setState(() {
  //     _ischecked = val;
  //   });
  // }
  @override
  Widget build(BuildContext context) {
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
            onChanged: (val) {
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
            leading: Icon(Icons.settings),
            title: Text('Covid Status'),
            onTap: () => {Navigator.of(context).pop()},
          ),
          ListTile(
            leading: Icon(Icons.border_color),
            title: Text('Feedback'),
            onTap: () => {Navigator.of(context).pop()},
          ),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text('Logout'),
            onTap: () => {Navigator.of(context).pop()},
          ),
          SizedBox(height: 30),
          ListTile(
            leading: Icon(Icons.info),
            enabled: false,
            title: Text(
              'Please note that you cannot uncheck the covid checkbox, and must only enable it if you have received your test results poistive for Covid-19.',
              textScaleFactor: 0.5,
            ),
            //onTap: () => {Navigator.of(context).pop()},
          ),
        ],
      ),
    );
  }
}
