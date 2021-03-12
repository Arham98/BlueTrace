import 'package:flutter/material.dart';

Future<void> popupTerms(var context) async {
  showDialog(
    //User friendly error message when the screen has been displayed
    context: context,
    builder: (_) => AlertDialog(
      title: Text(
        "Terms & Conditions",
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 28),
      ),
      content: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: ListBody(
          mainAxis: Axis.vertical,
          children: <Widget>[
            Text('TBD'),
          ],
        ),
      ),
    ),
    barrierDismissible: true,
  );
}

Future<void> popupHelp(var context) async {
  showDialog(
    //User friendly error message when the screen has been displayed
    context: context,
    builder: (_) => AlertDialog(
      title: Text(
        "Help",
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 28),
      ),
      content: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: ListBody(
          mainAxis: Axis.vertical,
          children: <Widget>[
            Text('Need Further Help? Contact us at bluetrace.help@gmail.com'),
          ],
        ),
      ),
    ),
    barrierDismissible: true,
  );
}
