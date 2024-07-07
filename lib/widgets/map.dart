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
    target: LatLng(0, 0), // Null Island
    zoom: 2,
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
          'C38yfM2Yvdf5GvIB9MEGjy7EVBi2', //Hardcoded uid but this is the uid of the connected user when using authentification service
          LatLng(position.latitude, position.longitude),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<List<User>>(
        stream: FirestoreService.userCollectionStream(),
        builder: (context, snapshot) {
          print("StreamBuilder update"); // Debug print
          print("Snapshot has data: ${snapshot.hasData}");
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          final Set<Marker> markers = {};
          for (var i = 0; i < snapshot.data!.length; i++) {
            final user = snapshot.data![i];
            print(user.uid);
            print(user.username);
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
                onTap: () => {print('Marker tapped')},
              ),
            );
          }

          print("Number of markers: ${markers.length}"); 
          return SizedBox(
              height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: GoogleMap(
              initialCameraPosition: _initialPosition,
              markers: markers,
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
