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

  static const CameraPosition _defaultPosition = CameraPosition(
    target:
        LatLng(-18.9216855, 47.5725194), // Antananarivo, Madagascar LatLng 🇲🇬
    zoom: 5,
  );
  CameraPosition? _initialPosition;
  late StreamSubscription<Position>? locationStreamSubscription;

  @override
  void initState() {
    print('maps init stateeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee');
    super.initState();
      _setInitialLocation();
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

  Future<void> _setInitialLocation() async {
    bool hasPermission = await StreamLocationService.askLocationPermission();
    
    if (hasPermission) {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _initialPosition = CameraPosition(
          target: LatLng(position.latitude, position.longitude),
          zoom: 5,
        );
      });
    } else {
      setState(() {
        _initialPosition = _defaultPosition;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _initialPosition == null
          ? Center(child: CircularProgressIndicator())
          : StreamBuilder<List<User>>(
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
                      icon: user.username == 'yosi3'
                          ? BitmapDescriptor.defaultMarkerWithHue(
                              BitmapDescriptor.hueRed,
                            )
                          : BitmapDescriptor.defaultMarkerWithHue(
                              BitmapDescriptor.hueYellow,
                            ),
                      position: LatLng(user.location!.lat, user.location!.lng),
                                infoWindow: InfoWindow(
                        title: user.username,
                      ),
                      onTap: () async {
         final GoogleMapController controller = await _controller.future;
                        controller.animateCamera(
                          CameraUpdate.newCameraPosition(
                            CameraPosition(
                              target: LatLng(user.location!.lat, user.location!.lng),
                              zoom: 18.0, // Zoom level to focus on the user
                            ),
                          ),
                        );
                        print('Marker tapped: ${user.username}');

                      },
                    ),
                  );
                }
                return GoogleMap(
                  initialCameraPosition: _initialPosition!,
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
