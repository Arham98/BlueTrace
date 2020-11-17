import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:blue_trace/Mapper.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:rxdart/rxdart.dart';

class AuthService {
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<auth.User> fireuser;
  Stream<Map<String, dynamic>> profile;
  PublishSubject loading = PublishSubject();

  AuthService() {
    fireuser = _auth.authStateChanges();

    profile = fireuser.switchMap((auth.User u) {
      if (u != null) {
        return _firestore
            .collection('users')
            .doc(u.uid)
            .snapshots()
            .map((snap) => snap.data());
      } else {
        return Stream.value({});
      }
    });
  }
  Future<auth.User> googleSignIn() async {
    loading.add(true);
    GoogleSignInAccount googleUser = await _googleSignIn.signIn();

    GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    auth.AuthCredential googlecredential = auth.GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    auth.User fireuser =
        (await _auth.signInWithCredential(googlecredential)).user;
    assert(!fireuser.isAnonymous);
    assert(await fireuser.getIdToken() != null);

    updateUserData(fireuser);

    auth.User currentUser = _auth.currentUser;
    assert(currentUser.uid == fireuser.uid);
    loading.add(false);
    print("signed in " + fireuser.displayName);
    return fireuser;
  }

  void updateUserData(auth.User fireuser) async {
    DocumentReference ref = _firestore.collection('users').doc(fireuser.uid);
    //ref.get().then((value) => null)
    return ref.set({
      'uid': fireuser.uid,
      //'name': '',
      //'cnic': '',
      //'uuid': '',
      'email': fireuser.email,
    }, SetOptions(merge: true));
  }

  void signOut() {
    _auth.signOut();
  }
}

final AuthService authService = AuthService();

class StateModel {
  bool isLoading;
  auth.User user;

  StateModel({
    this.isLoading = false,
    this.user,
  });
}
