import 'package:cloud_firestore/cloud_firestore.dart';

class UserId {
  final String uid;
  UserId({this.uid});
}

class UserData {
  String googleUid;
  String name;
  int cnic;
  String uuid;
  String email;
  bool covidStatus;

  UserData(
      {this.googleUid,
      this.name,
      this.cnic,
      this.uuid,
      this.email,
      this.covidStatus});

  UserData.fromData(Map<String, dynamic> data)
      : googleUid = data['googleUid'],
        name = data['name'],
        cnic = data['cnic'],
        uuid = data['uuid'],
        email = data['email'],
        covidStatus = data['coivdStatus'];

  Map<String, dynamic> toJSON() {
    return {
      'googleUid': googleUid,
      'name': name,
      'cnic': cnic,
      'uuid': uuid,
      'email': email,
      'coivdStatus': covidStatus,
    };
  }

  // void update(String _name, int _cnic, String _uuid, String _email) {
  //   if (_name.isNotEmpty) {
  //     this.name = _name;
  //   }
  //   if (_cnic.isNotEmpty) {
  //     this.cnic = _cnic;
  //   }
  //   if (_email.isNotEmpty) {
  //     this.email = _email;
  //   }
  //   if (_uuid.isNotEmpty) {
  //     this.uuid = _uuid;
  //   }
  // }
}

class ContactData {
  String uuid1;
  String uuid2;
  String name1;
  String name2;
  Timestamp timestamp;

  ContactData({this.uuid1, this.uuid2, this.timestamp});

  ContactData.fromData(Map<String, dynamic> data)
      : uuid1 = data['uuid1'],
        uuid2 = data['uuid2'],
        name1 = data['name1'],
        name2 = data['name2'],
        timestamp = data['timestamp'];

  Map<String, dynamic> toJSON() {
    return {
      'uuid1': uuid1,
      'uuid2': uuid2,
      'name1': name1,
      'name2': name2,
      'timestamp': timestamp,
    };
  }

  void update(String _uuid1, String _uuid2, String _name1, String _name2,
      Timestamp _timestamp) {
    if (_uuid1.isNotEmpty) {
      this.uuid1 = _uuid1;
    }
    if (_uuid2.isNotEmpty) {
      this.uuid2 = _uuid2;
    }
    if (_name1.isNotEmpty) {
      this.name1 = _name1;
    }
    if (_name2.isNotEmpty) {
      this.name2 = _name2;
    }
  }
}

class CovidData {
  String uuid;
  String name;
  Timestamp timestamp;

  CovidData({this.uuid, this.name, this.timestamp});

  CovidData.fromData(Map<String, dynamic> data)
      : uuid = data['uuid'],
        name = data['name'],
        timestamp = data['timestamp'];

  Map<String, dynamic> toJSON() {
    return {
      'uuid': uuid,
      'name': name,
      'timestamp': timestamp,
    };
  }

  void update(String _uuid, String _name, Timestamp _timestamp) {
    if (_uuid.isNotEmpty) {
      this.uuid = _uuid;
    }
    if (_name.isNotEmpty) {
      this.name = _name;
    }
  }
}
