import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visit_man/model/userModel/activityModel.dart';
import 'package:visit_man/model/userModel/userModel.dart';
import 'package:visit_man/model_view/cubits/mainCubitofWidget/getActivityOnly/getActivityStateOnly.dart';

class ActivityCubit extends Cubit<ActivityState> {
  ActivityCubit() : super(ActivityInitial());

  static ActivityCubit get(BuildContext context) => BlocProvider.of(context);

  late UserModel _userModel;

  Future<void> loadUserModel() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionData = prefs.getString('sessionData');
      if (sessionData != null) {
        _userModel = UserModel.fromJson(jsonDecode(sessionData));
      } else {
        throw Exception('No user data found');
      }
    } catch (e) {
      print('Error loading user data: ${e.toString()}');
      emit(ActivityError('Error loading user data: ${e.toString()}'));
    }
  }

  Future<void> fetchActivities({required String userid}) async {
    emit(ActivityLoading());
    await loadUserModel();

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? url = prefs.getString('storedUrl');

      if (url == null || url.isEmpty) {
        emit(ActivityError('URL not found'));
        return;
      }

      final dio = Dio();
      final response = await dio.get(
        '$url/api/$userid/get_activity',
        options: Options(
          headers: {
            'token': _userModel.accessToken,
          },
        ),
      );

      if (response.statusCode == 200) {
        final activities = response.data['data'];
        emit(ActivityLoaded(activities));
      } else {
        emit(ActivityError('Unexpected response status: ${response.statusCode}'));
      }
    } catch (e) {
      print('Error fetching activities: $e'); // Detailed print for debugging
      emit(ActivityError('Failed to load activities: ${e.toString()}')); // Detailed error message
    }
  }
}
