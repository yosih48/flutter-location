

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Location {
  final double lat;
  final double lng;

  Location({
    required this.lat,
    required this.lng,
  });
    Map<String, dynamic> toJson() => {
        "lat": lat,
        "lng": lng,
      };
  static Location fromJson(Map<String, dynamic> json) => Location(
        lat: json["lat"],
        lng: json["lng"],
      );
}
class User {
  final String email;
  final String uid;
   final Location? location; 
  final String username;


  const User(
      {required this.username,
      required this.uid,
  this.location,
      required this.email,
 
      }
      );

  Map<String, dynamic> toJson() => {
        "username": username,
        "uid": uid,
        "email": email,
    "location": location?.toJson(), 
      };

static User fromSnap(DocumentSnapshot snap) {
  print('snap in model $snap');

  var snapshot = snap.data() as Map<String, dynamic>;

  // Default location if not provided
  Location location = Location(lat: 0.0, lng: 0.0);

  // Check if location exists and has the expected structure
  if (snapshot.containsKey('location') && 
      snapshot['location'] is Map<String, dynamic>) {
    var locationData = snapshot['location'] as Map<String, dynamic>;
    if (locationData.containsKey('lat') && locationData.containsKey('lng')) {
      location = Location(
        lat: (locationData['lat'] as num).toDouble(),
        lng: (locationData['lng'] as num).toDouble(),
      );
    }
  }

  return User(
    username: snapshot["username"] ?? '',
    uid: snapshot["uid"] ?? '',
    email: snapshot["email"] ?? '',
    location: location,
  );
}
}
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class User {
//   final String email;
//   final String uid;

//   final String username;


//   const User(
//       {required this.username,
//       required this.uid,

//       required this.email,
 
//       }
//       );

//   static User fromSnap(DocumentSnapshot snap) {
//     print(  'snap in model ${snap}');
//     print(snap['email']);
//     var snapshot = snap.data() as Map<String, dynamic>;

//     return User(
//       username: snapshot["username"],
//       uid: snapshot["uid"],
//       email: snapshot["email"],

//     );
//   }

//   Map<String, dynamic> toJson() => {
//         "username": username,
//         "uid": uid,
//         "email": email,

//       };
// }
