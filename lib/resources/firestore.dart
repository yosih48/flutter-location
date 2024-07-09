import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:template/models/user.dart';


class FirestoreService {
  static final _firestore = FirebaseFirestore.instance;

  static Future<void> updateUserLocation(String userId, LatLng location) async {
     print('Updating location for user: $userId');
    try {
      await _firestore.collection('user').doc(userId).update({
        'location': {'lat': location.latitude, 'lng': location.longitude},
      });
      print('Location updated successfully');
      print(location.latitude);
      print(location.longitude);
    } on FirebaseException catch (e) {
      print('Ann error due to firebase occured $e');
    } catch (err) {
      print('Ann error occured $err');
    }
  }

static Stream<List<User>> userCollectionStream() {
  return _firestore.collection('user').snapshots().map((snapshot) =>
      snapshot.docs.map((doc) => User.fromSnap(doc)).toList());
}
}