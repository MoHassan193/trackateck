import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../model_view/cubits/postCubit/mapCubit/mapCubit.dart';
import '../mapPartner.dart';


class MapPage extends StatelessWidget {
  final List<LatLng> yourlocation;
  final List<LatLng> latlong;

  const MapPage(this.yourlocation, this.latlong, {super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MapCubit(),
      child: Scaffold(
        appBar: AppBar(title: Text('Google Map')),
        body: Column(
          children: [
            Expanded(
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: yourlocation[0],
                  zoom: 15.0,
                ),
                markers: latlong
                    .map(
                      (LatLng latLng) => Marker(
                    markerId: MarkerId(latLng.toString()),
                    position: latLng,
                    infoWindow: InfoWindow(title: 'Location'),
                  ),
                )
                    .toSet()
                    .union(
                  {
                    Marker(
                      markerId: MarkerId('your_location'),
                      position: yourlocation[0],
                      infoWindow: InfoWindow(title: 'Your Location'),
                    ),
                  },
                ),
                polylines: {
                  Polyline(
                    polylineId: PolylineId('path'),
                    points: latlong,
                    color: Colors.blue,
                    width: 5,
                  ),
                },
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MyMapPage(yourlocation, latlong),
                  ),
                );
              },
              child: Text('Go to My Map Page'),
            ),
          ],
        ),
      ),
    );
  }
}
