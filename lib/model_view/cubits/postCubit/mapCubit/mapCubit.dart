// mapCubit.dart
import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../model/dialToast.dart';
import '../../../../model/userModel/userModel.dart';
import 'mapState.dart';

class MapCubit extends Cubit<MapState> {
  MapCubit() : super(MapInitial()) {
    loadAndSendCoordinates(); // Call the method on initialization
  }

  static MapCubit get(context) => BlocProvider.of(context);

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
      emit(MapError('Error loading user data: ${e.toString()}'));
    }
  }

  Future<void> loadAndSendCoordinates() async {
    await loadUserModel(); // Ensure user data is loaded

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      double? savedLatitude = prefs.getDouble('latitude');
      double? savedLongitude = prefs.getDouble('longitude');

      // Check if coordinates are available
      if (savedLatitude != null && savedLongitude != null) {
        // Send coordinates to the API

      } else {
        print('No saved coordinates found.');
      }
    } catch (e) {
      emit(MapError('Error retrieving coordinates: ${e.toString()}'));
    }
  }

  Future<void> sendCoordinates(double latitude, double longitude,int id) async {
    try {
      final dio = Dio();
      final prefs = await SharedPreferences.getInstance();
      final String? url = prefs.getString('storedUrl'); // Get the API URL

      if (url == null || url.isEmpty) {
        emit(MapError('URL not found'));
        print('Error: URL not found in SharedPreferences');
        return;
      }

      print('Sending request to: $url/api/$id/update_partner_location');
      print('Payload: ${jsonEncode({
        'partner_latitude': latitude,
        'partner_longitude': longitude
      })}');

      // Send coordinates to the API
      final response = await dio.post(
        '$url/api/$id/update_partner_location',
        options: Options(
          headers: {
            'User-Agent': 'PostmanRuntime/7.42.0',
            'Accept': '*/*',
            'Accept-Encoding': 'gzip, deflate, br',
            'Connection': 'keep-alive',
            'token': userModel.accessToken,  // Ensure token is fetched correctly
            'charset': 'utf-8',
            'Content-Type': 'application/x-www-form-urlencoded',
          },
        ),
        data: {
          'partner_latitude': latitude,
          'partner_longitude': longitude,
        },
      );

      // Check the response status
      if (response.statusCode == 200) {
        print('Coordinates sent ');

        final data = response.data['data'][0];  // Assuming data contains an array, we take the first item
        final String partnerId = data['partner_id'].toString();
        final String partnerName = data['partner_name'];
        final String partnerLatitude = data['partner_latitude'].toString();
        final String partnerLongitude = data['partner_longitude'].toString();
        emit(MapSuccess(data: data));
        DialToast.showToast("Location sent successfully", Colors.green);
        print('Coordinates sent successfully');
      } else {
        emit(MapError('Failed to send coordinates, status code: ${response.statusCode}'));
        print('Error: Failed to send coordinates, status code: ${response.statusCode}');
      }
    } catch (e) {
      emit(MapError(e.toString()));
      print('Error: $e');
    }
  }
}
