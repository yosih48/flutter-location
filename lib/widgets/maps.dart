import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:template/models/geolocation.dart';
import 'package:template/models/user.dart' as model;
import 'package:template/models/user.dart';
import 'package:template/resources/firestore.dart';

class MapScreenb extends StatefulWidget {
  const MapScreenb({super.key});

  @override
  State<MapScreenb> createState() => MapScreenbState();
}

class MapScreenbState extends State<MapScreenb> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  static const CameraPosition _initialPosition = CameraPosition(
    target:
        LatLng(-18.9216855, 47.5725194), // Antananarivo, Madagascar LatLng 🇲🇬
    zoom: 14.4746,
  );

  late StreamSubscription<Position>? locationStreamSubscription;

  @override
  void initState() {
    print('maps init stateeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee');
    super.initState();
    locationStreamSubscription =
        StreamLocationService.onLocationChanged?.listen(
      (position) async {
        auth.User? user = auth.FirebaseAuth.instance.currentUser;
        if (user != null) {
          print('user is not null');
          print(user.uid);
          await FirestoreService.updateUserLocation(
            user.uid, // Use the authenticated user's ID
            LatLng(position.latitude, position.longitude),
          );
        } else {
          print('user is null');
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<List<User>>(
        stream: FirestoreService.userCollectionStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          final Set<Marker> markers = {};
          for (var i = 0; i < snapshot.data!.length; i++) {
            final user = snapshot.data![i];
            markers.add(
              Marker(
                markerId: MarkerId('${user.username} position $i'),
                icon: user.username == 'stephano'
                    ? BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueRed,
                      )
                    : BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueYellow,
                      ),
                position: LatLng(user.location!.lat, user.location!.lng),
                onTap: () => {print('fdfdfdfdfdf')},
              ),
            );
          }
          return GoogleMap(
            initialCameraPosition: _initialPosition,
            markers: markers,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    locationStreamSubscription?.cancel();
  }
}
