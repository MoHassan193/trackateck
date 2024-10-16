// MyMapPage.dart
import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visit_man/model_view/cubits/mainCubitofWidget/getTodayVisitCubit/get_today_visit_cubit.dart';
import 'package:visit_man/model_view/cubits/mainCubitofWidget/getTodayVisitCubit/get_today_visit_state.dart';
import '../../../../model/dialToast.dart';
import '../../../../model/userModel/userModel.dart';


class MyMapPage extends StatefulWidget {
  MyMapPage({Key? key, required this.idPartner, required this.partnerlong, required this.partnerlatit}) : super(key: key);
  final int idPartner;
  final double partnerlong;
  final double partnerlatit;

  @override
  _MyMapPageState createState() => _MyMapPageState();
}

class _MyMapPageState extends State<MyMapPage> {
  // Method to save latitude and longitude to SharedPreferences
  Future<void> _saveCoordinates(double latitude, double longitude) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('latitude', latitude);
    await prefs.setDouble('longitude', longitude);
  }

  GoogleMapController? mapController;

  final LatLng _initialPosition = const LatLng(31.9848220, 35.8600043); // Jordan
  LatLng? _manualLocation;
  LatLng? _currentLocation;
  Marker? _currentLocationMarker;
  Marker? _partnerLocationMarker;

  // Method to get the current location
  Future<void> _getCurrentLocation() async {
    // Check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location services are disabled.')),
      );
      return;
    }

    // Check and request location permissions
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permission is denied.')),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location permissions are permanently denied.'),
        ),
      );
      return;
    }

    // Get the current location
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    // Update the map with the current location
    setState(() {
      _manualLocation = null;
      _currentLocation = LatLng(position.latitude, position.longitude);
      _currentLocationMarker = Marker(
        markerId: const MarkerId("current_location_marker"),
        position: _currentLocation!,
        infoWindow: const InfoWindow(title: "Your Current Location"),
      );

      // Move the camera to the current location
      mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(_currentLocation!, 14.0),
      );
    });

    await _saveCoordinates(_currentLocation!.latitude, _currentLocation!.longitude);
  }

  // Method to handle tapping on the map and update _manualLocation
  void _onMapTapped(LatLng position) {
    setState(() {
      _currentLocation = null;
      _manualLocation = position;
      _currentLocationMarker = Marker(
        markerId: const MarkerId("manual_location_marker"),
        position: position,
        infoWindow: const InfoWindow(title: "Selected Location"),
      );
    });
  }

  // Method to move the camera to the partner's location
  void _goToPartnerLocation() {
    LatLng partnerLocation = LatLng(widget.partnerlatit, widget.partnerlong);
    mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(partnerLocation, 14.0),
    );
    print(widget.partnerlatit);
    print(widget.partnerlong);
  }

  @override
  void initState() {
    super.initState();
    // Initialize the partner's marker when the map page is loaded
    _partnerLocationMarker = Marker(
      markerId: const MarkerId("partner_location_marker"),
      position: LatLng(widget.partnerlatit, widget.partnerlong),
      infoWindow: const InfoWindow(title: "Partner's Location"),
    );
    loadUserModel();
  }
  late UserModel userModel;

  Future<void> loadUserModel() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionData = prefs.getString('sessionData');
      if (sessionData != null) {
        userModel = UserModel.fromJson(jsonDecode(sessionData));
      } else {
        throw Exception('No user data found');
      }
    } catch (e) {
      DialToast.showToast('Error loading user data: ${e.toString()}', Colors.red);
    }
  }

  Future<void> sendCoordinates() async {
    try {
      final dio = Dio();
      final prefs = await SharedPreferences.getInstance();
      final String? url = prefs.getString('storedUrl'); // Get the API URL

      if (url == null || url.isEmpty) {
        DialToast.showToast('URL not found', Colors.red);
        print('Error: URL not found in SharedPreferences');
        return;
      }

      print('Sending request to: $url/api/${widget.idPartner}/update_partner_location');
      print('Payload: ${jsonEncode({
        'partner_latitude': _currentLocation!.latitude,
        'partner_longitude': _currentLocation!.longitude
      })}');

      // Send coordinates to the API
      final response = await dio.post(
        '$url/api/${widget.idPartner}/update_partner_location',
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          headers: {
            'Accept': '*/*',
            'Accept-Encoding': 'gzip, deflate, br',
            'Connection': 'keep-alive',
            'token': userModel.accessToken,  // Ensure token is fetched correctly
            'charset': 'utf-8',
            'Content-Type': 'application/x-www-form-urlencoded',
          },
        ),
        data: {
          'partner_latitude': _currentLocation!.latitude,
          'partner_longitude': _currentLocation!.longitude,
          'website': null,
          'zip': null,
          'vat': null,
          'type': 'contact',
          'title': null,
          'territory_id': null,
          'suitable_time': null,
          'suitable_day': null,
          'street2': null,
          'street': null,
          'state_id': null,
          'speciality': null,
          'ref': null,
          'rank': null,
          'phone': null,
          'name': null,
          'mobile': null,
          'file_path': null, // يمكنك ترك الحقل هذا كما هو في حال أردت استخدام الصورة الافتراضية أو تعيينه `null`
          'function': null,
          'country_id': null,
          'comment': null,
          'client_type': null,
          'client_kind': null,
          'client_attitude': null,
          'classification': null,
          'city': null,
          'behave_style_id': null,
          'barcode': null,
        },
      );

      // Check the response status
      if (response.statusCode == 200) {
        print('Coordinates sent successfully');
        DialToast.showToast("Location sent successfully", Colors.green);
      } else {
        DialToast.showToast('Failed to send coordinates, status code: ${response.statusCode}', Colors.red);
        print('Error: Failed to send coordinates, status code: ${response.statusCode}');
      }
    } catch (e) {
      DialToast.showToast(e.toString(), Colors.red);
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: GoogleMap(
              onMapCreated: (GoogleMapController controller) {
                mapController = controller;
              },
              initialCameraPosition: CameraPosition(
                target: _initialPosition,
                zoom: 12.0,
              ),
              markers: {
                if (_currentLocationMarker != null) _currentLocationMarker!,
                if (_partnerLocationMarker != null) _partnerLocationMarker!,
              },
              onTap: _onMapTapped, // Update the map with a new location on tap
            ),
          ),
          if (_manualLocation != null && _currentLocation == null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Latitude: ${_manualLocation!.latitude},\nLongitude: ${_manualLocation!.longitude}",
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          if (_currentLocation != null && _manualLocation == null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Latitude: ${_currentLocation!.latitude},\nLongitude: ${_currentLocation!.longitude}",
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () async {
              await _getCurrentLocation(); // Get current location
              _saveCoordinates(_currentLocation!.latitude, _currentLocation!.longitude);
            },
            child: const Icon(Icons.location_on),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            onPressed: _goToPartnerLocation, // Navigate to partner's location
            child: const Icon(Icons.person_pin_circle),
            heroTag: 'partner_location_button',
          ),
        ],
      ),
      appBar: AppBar(
          leading: IconButton(
          onPressed: () {
            Navigator.pop(context);  // Go back one page
            Navigator.pop(context);  // Go back another page
          },
            icon: Icon(Icons.arrow_back),
         ),

    actions:[
            SizedBox(width: 10,),
            widget.partnerlatit == 0 && widget.partnerlong == 0 ? IconButton(
                onPressed: (){
                  sendCoordinates();
                  _saveCoordinates(
                    _currentLocation!.latitude,
                    _currentLocation!.longitude,
                  );
                },
                icon: Icon(Icons.send,color: Colors.white,)) : SizedBox(),
            SizedBox(width: 10,),
          ]
      ),
    );
  }
  Future<UserModel> _getUserModelFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionData = prefs.getString('sessionData');
    if (sessionData != null) {
      return UserModel.fromJson(jsonDecode(sessionData));
    }
    throw Exception('No user data found');
  }
}


// class MyMapPage extends StatefulWidget {
//   MyMapPage({Key? key, required this.idPartner, required this.partnerlong, required this.partnerlatit}) : super(key: key);
//   final int idPartner;
//   final double partnerlong;
//   final double partnerlatit;
//
//   @override
//   _MyMapPageState createState() => _MyMapPageState();
// }
//
// class _MyMapPageState extends State<MyMapPage> {
//   // Method to save latitude and longitude to SharedPreferences
//   Future<void> _saveCoordinates(double latitude, double longitude) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.setDouble('latitude', latitude);
//     await prefs.setDouble('longitude', longitude);
//   }
//
//   GoogleMapController? mapController;
//
//   final LatLng _initialPosition = const LatLng(28.1194, 30.7444); // Minia, Egypt
//   LatLng? _manualLocation;
//   LatLng? _currentLocation;
//   Marker? _currentLocationMarker;
//   Marker? _partnerLocationMarker;
//
//   // Method to get the current location
//   Future<void> _getCurrentLocation() async {
//     // Check if location services are enabled
//     bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Location services are disabled.')),
//       );
//       return;
//     }
//
//     // Check and request location permissions
//     LocationPermission permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Location permission is denied.')),
//         );
//         return;
//       }
//     }
//
//     if (permission == LocationPermission.deniedForever) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Location permissions are permanently denied.'),
//         ),
//       );
//       return;
//     }
//
//     // Get the current location
//     Position position = await Geolocator.getCurrentPosition(
//       desiredAccuracy: LocationAccuracy.high,
//     );
//
//     // Update the map with the current location
//     setState(() {
//       _manualLocation = null;
//       _currentLocation = LatLng(position.latitude, position.longitude);
//       _currentLocationMarker = Marker(
//         markerId: const MarkerId("current_location_marker"),
//         position: _currentLocation!,
//         infoWindow: const InfoWindow(title: "Your Current Location"),
//       );
//
//       // Move the camera to the current location
//       mapController?.animateCamera(
//         CameraUpdate.newLatLngZoom(_currentLocation!, 14.0),
//       );
//     });
//
//     await _saveCoordinates(_currentLocation!.latitude, _currentLocation!.longitude);
//   }
//
//   // Method to handle tapping on the map and update _manualLocation
//   void _onMapTapped(LatLng position) {
//     setState(() {
//       _currentLocation = null;
//       _manualLocation = position;
//       _currentLocationMarker = Marker(
//         markerId: const MarkerId("manual_location_marker"),
//         position: position,
//         infoWindow: const InfoWindow(title: "Selected Location"),
//       );
//     });
//   }
//
//   // Method to move the camera to the partner's location
//   void _goToPartnerLocation() {
//     LatLng partnerLocation = LatLng(widget.partnerlatit, widget.partnerlong);
//     mapController?.animateCamera(
//       CameraUpdate.newLatLngZoom(partnerLocation, 14.0),
//     );
//   }
//   late UserModel userModel;
//
//   @override
//   void initState() {
//     super.initState();
//     // Initialize the partner's marker when the map page is loaded
//     _partnerLocationMarker = Marker(
//       markerId: const MarkerId("partner_location_marker"),
//       position: LatLng(widget.partnerlatit, widget.partnerlong),
//       infoWindow: const InfoWindow(title: "Partner's Location"),
//     );
//     loadUserModel();
//   }
//
//   Future<void> loadUserModel() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final sessionData = prefs.getString('sessionData');
//       if (sessionData != null) {
//         userModel = UserModel.fromJson(jsonDecode(sessionData));
//       } else {
//         throw Exception('No user data found');
//       }
//     } catch (e) {
//       DialToast.showToast('Error loading user data: ${e.toString()}', Colors.red);
//     }
//   }
//
//   Future<void> sendCoordinates() async {
//     try {
//       final dio = Dio();
//       final prefs = await SharedPreferences.getInstance();
//       final String? url = prefs.getString('storedUrl'); // Get the API URL
//
//       if (url == null || url.isEmpty) {
//         DialToast.showToast('URL not found', Colors.red);
//         print('Error: URL not found in SharedPreferences');
//         return;
//       }
//
//       print('Sending request to: $url/api/${widget.idPartner}/update_partner_location');
//       print('Payload: ${jsonEncode({
//         'partner_latitude': _currentLocation!.latitude,
//         'partner_longitude': _currentLocation!.longitude
//       })}');
//
//       // Send coordinates to the API
//       final response = await dio.post(
//         '$url/api/${widget.idPartner}/update_partner_location',
//         options: Options(
//           headers: {
//             'User-Agent': 'PostmanRuntime/7.42.0',
//             'Accept': '*/*',
//             'Accept-Encoding': 'gzip, deflate, br',
//             'Connection': 'keep-alive',
//             'token': userModel.accessToken,  // Ensure token is fetched correctly
//             'charset': 'utf-8',
//             'Content-Type': 'application/x-www-form-urlencoded',
//           },
//         ),
//         data: {
//           'partner_latitude': _currentLocation!.latitude,
//           'partner_longitude': _currentLocation!.longitude
//         },
//       );
//
//       // Check the response status
//       if (response.statusCode == 200) {
//         print('Coordinates sent successfully');
//         DialToast.showToast("Location sent successfully", Colors.green);
//       } else {
//         DialToast.showToast('Failed to send coordinates, status code: ${response.statusCode}', Colors.red);
//         print('Error: Failed to send coordinates, status code: ${response.statusCode}');
//       }
//     } catch (e) {
//       DialToast.showToast(e.toString(), Colors.red);
//       print('Error: $e');
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//           actions:[
//             SizedBox(width: 10,),
//             IconButton(
//                 onPressed: (){
//                   sendCoordinates();
//                   _saveCoordinates(
//                     _currentLocation!.latitude,
//                     _currentLocation!.longitude,
//                   );
//                 },
//                 icon: Icon(Icons.send,color: Colors.white,)),
//             SizedBox(width: 10,),
//           ]
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: GoogleMap(
//               onMapCreated: (GoogleMapController controller) {
//                 mapController = controller;
//               },
//               initialCameraPosition: CameraPosition(
//                 target: _initialPosition,
//                 zoom: 12.0,
//               ),
//               markers: {
//                 if (_currentLocationMarker != null) _currentLocationMarker!,
//                 if (_partnerLocationMarker != null) _partnerLocationMarker!,
//               },
//               onTap: _onMapTapped, // Update the map with a new location on tap
//             ),
//           ),
//           if (_manualLocation != null && _currentLocation == null)
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Text(
//                 "Latitude: ${_manualLocation!.latitude},\nLongitude: ${_manualLocation!.longitude}",
//                 style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//               ),
//             ),
//           if (_currentLocation != null && _manualLocation == null)
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Text(
//                 "Latitude: ${_currentLocation!.latitude},\nLongitude: ${_currentLocation!.longitude}",
//                 style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//               ),
//             ),
//         ],
//       ),
//       floatingActionButton: Column(
//         mainAxisAlignment: MainAxisAlignment.end,
//         children: [
//           FloatingActionButton(
//             onPressed: () async {
//               await _getCurrentLocation(); // Get current location
//             },
//             child: const Icon(Icons.location_on),
//           ),
//           const SizedBox(height: 10),
//           FloatingActionButton(
//             onPressed: _goToPartnerLocation, // Navigate to partner's location
//             child: const Icon(Icons.person_pin_circle),
//             heroTag: 'partner_location_button',
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// // MyMapPage.dart
// import 'dart:async';
//
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../../../../model/dialToast.dart';
// import '../../../../model_view/cubits/postCubit/mapCubit/mapCubit.dart';
// import '../../../../model_view/cubits/postCubit/mapCubit/mapState.dart';
