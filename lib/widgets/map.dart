import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../models/geolocation.dart';
import '../models/user.dart';

import '../resources/firestore.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => MapScreenState();
}

class MapScreenState extends State<MapScreen> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(31.750832, 35.1857091), // Centered on yosi3's location
    zoom: 12,
  );

  late StreamSubscription<Position>? locationStreamSubscription;

  @override
  void initState() {
    super.initState();
    locationStreamSubscription =
        StreamLocationService.onLocationChanged?.listen(
      (position) async {
        print('updateUserLocation in map');
        await FirestoreService.updateUserLocation(
          'nLbSlJGy7GZrV0EUVfaKwyxggWM2', //Hardcoded uid but this is the uid of the connected user when using authentification service
          LatLng(position.latitude, position.longitude),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    print("Building MapScreen");
    return Scaffold(
      body: StreamBuilder<List<User>>(
        stream: FirestoreService.userCollectionStream(),
        builder: (context, snapshot) {
          print("StreamBuilder update"); // Debug print
          print("Snapshot has data: ${snapshot.hasData}");
          print("Snapshot error: ${snapshot.error}");
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final Set<Marker> markers = {};
          for (var i = 0; i < snapshot.data!.length; i++) {
            final user = snapshot.data![i];
            print(
                "User: ${user.username}, Location: ${user.location?.lat}, ${user.location?.lng}");
            if (user.location != null) {
              markers.add(
                Marker(
                  markerId: MarkerId('${user.username} position $i'),
                  icon: user.username == 'stephano'
                      ? BitmapDescriptor.defaultMarkerWithHue(
                          BitmapDescriptor.hueRed)
                      : BitmapDescriptor.defaultMarkerWithHue(
                          BitmapDescriptor.hueYellow),
                  position: LatLng(user.location!.lat, user.location!.lng),
                  onTap: () => print('Marker tapped: ${user.username}'),
                ),
              );
            } else {
              print('nuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuul');
            }
          }

          print("Number of markers: ${markers.length}");
          return Container(
            color: Colors.red,
            height: 400,
            width: 400,
            child: GoogleMap(
              initialCameraPosition: _initialPosition,
              markers: markers,
              mapType: MapType.normal,
              zoomControlsEnabled: true,
              onMapCreated: (GoogleMapController controller) {
                print("Map created");
                _controller.complete(controller);
              },
              onCameraMove: (_) => print("Camera moved"),
              onCameraIdle: () => print("Camera idle"),
            ),
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
