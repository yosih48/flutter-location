import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:template/screens/googleMaps.dart';
import 'package:template/widgets/maps.dart';

import '../screens/afterLogin.dart';
import '../screens/login_screen.dart';
import '../screens/signup_screen.dart';
import '../widgets/map.dart';


const webScreenSize = 600;

List<Widget> homeScreenItems = [
  

  // const SignupScreen(),
  const MyWidget(),
  // const LoginScreen(),
  const MapScreenb(),
  // const GoogleMaps(),
  // const FeedScreen(),
  // const SearchScreen(),
  // const AddPostScreen(),
  //  const Text('screen2'),
//  ProfileScreen(uid:  FirebaseAuth.instance.currentUser!.uid,)
  // ProfileScreen(
  //   uid: FirebaseAuth.instance.currentUser!.uid,
  // ),
];
