import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visit_man/model/dialToast.dart';

import '../../../../model/userModel/userModel.dart';

part 'end_visit_state.dart';

class EndVisitCubit extends Cubit<EndVisitState> {
  EndVisitCubit() : super(EndVisitInitial());

  static EndVisitCubit get(context) => BlocProvider.of(context);

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
      emit(EndVisitError());
    }
  }

  Future<void> updateVisit(
      String inDoom,
      DateTime checkIn,
      DateTime checkOut,
      String state,
      int rankId,
      int behaveStyleId,
      int segmentId,
      int classificationId,
      int surveyId,
      String noPatient,
      String clientAttitude
      ) async {

    await loadUserModel(); // Ensure user data is loaded

    try {
      final dio = Dio();
      final prefs = await SharedPreferences.getInstance();
      final String? url = prefs.getString('storedUrl'); // Get the API URL

      if (url == null || url.isEmpty) {
        emit(EndVisitError());
        print('Error: URL not found in SharedPreferences');
        return;
      }

      print('Sending request to: $url/api/64/update_visit');
      print('Payload: ${jsonEncode({
        'in_doom': inDoom,
        'check_in': checkIn,
        'check_out': checkOut,
        'state': state,
        'rank_id': rankId,
        'behave_style_id': behaveStyleId,
        'segment_id': segmentId,
        'classification_id': classificationId,
        'no_patient': noPatient,
        'client_attitude': clientAttitude,
        'survey_id': surveyId,
      })}');

      // Send visit data to the API
      final response = await dio.post(
        '$url/api/64/update_visit',
        options: Options(
            headers: {
              'User-Agent': 'PostmanRuntime/7.42.0',
              'Accept': '*/*',
              'Accept-Encoding': 'gzip, deflate, br',
              'Connection': 'keep-alive',
              'token': userModel.accessToken,  // Ensure accessToken is loaded
              'charset': 'utf-8',
              'Content-Type': 'application/x-www-form-urlencoded',
            }
        ),
        data: {
          'in_doom': inDoom,
          'check_in': checkIn,
          'check_out': checkOut,
          'state': state,
          'rank_id': rankId,
          'behave_style_id': behaveStyleId,
          'segment_id': segmentId,
          'classification_id': classificationId,
          'no_patient': noPatient,
          'client_attitude': clientAttitude,
          'survey_id' : surveyId,
        },
      );

      // Check the response status
      if (response.statusCode == 200) {
        emit(EndVisitSuccess());
        DialToast.showToast("Visit updated successfully", Colors.green);
        print('Visit updated successfully');
      } else {
        emit(EndVisitError());
        DialToast.showToast("Failed to update visit", Colors.red);
        print('Error: Failed to update visit, status code: ${response.statusCode}');
      }
    } catch (e) {
      emit(EndVisitError());
      print('Error: $e');
    }
  }
}

