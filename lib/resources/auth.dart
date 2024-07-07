import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:template/models/user.dart' as model;
import 'package:geolocator/geolocator.dart';


class AuthMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;






  // get user details
  Future<model.User> getUserDetails() async {
     User currentUser = _auth.currentUser!;

    DocumentSnapshot documentSnapshot =
        await _firestore.collection('user').doc(currentUser.uid).get();

    return model.User.fromSnap(documentSnapshot);
  }

  //signupo user
  Future<String> signUpUser({
    required String email,
    required String password,
    required String username,
  }) async {
    String res = "some error occurred";
    try {
      if (email.isNotEmpty || password.isNotEmpty || username.isNotEmpty) {
        //regisrer user
        UserCredential cred = await _auth.createUserWithEmailAndPassword(
            email: email, password: password);
        print(cred.user!.uid);

        // Initialize location as null
        model.Location? userLocation;


    // Get current location
        try {
          // Try to get current location
          Position position = await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.high);
          userLocation =
              model.Location(lat: position.latitude, lng: position.longitude);
        } catch (e) {
          print("Error getting location: $e");
          // If there's an error getting location, we'll leave it as null
        }
        //add user to db
        //new way:
        model.User user = model.User(
          username: username,
          uid: cred.user!.uid,
          email: email,
          location: userLocation,
        );
        _firestore.collection('user').doc(cred.user!.uid).set(
              user.toJson(),
            );
//old way:
        // _firestore.collection('user').doc(cred.user!.uid).set({
        //   'username': username,
        //   'uid': cred.user!.uid,
        //   "email": email,
        //   'bio': bio,
        //   'followers': [],
        //   'following': [],
        //   'photoUrl': photoUrl,
        // });

        res = "success";
      }
    } on FirebaseAuthException catch (err) {
      if (err.code == 'invalid-email') {
        res = 'The email is badly formatted';
      } else if (err.code == 'week-password') {
        res = 'Password shuld be at least 6 characters';
      }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  //login in user
  Future<String> loginUser({
    required String email,
    required String password,
  }) async {
    String res = "Some error Occurred";
    try {
      if (email.isNotEmpty || password.isNotEmpty) {
        // logging in user with email and password
        await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        res = "success";
      } else {
        res = "Please enter all the fields";
      }
    } catch (err) {
      return err.toString();
    }
    return res;
  }

  Future<void> signOut() async {
    await _auth.signOut();
    //  await _auth.currentUser?.delete();
  }
}
