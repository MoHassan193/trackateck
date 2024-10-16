import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visit_man/model/userModel/visitAterorityModel.dart';

import '../../../../model/userModel/userModel.dart'; // Import UserModel
import 'get_today_daily_state.dart';

class TodayDailyCubit extends Cubit<TodayDailyState> {
  TodayDailyCubit() : super(TodayDailyInitial());

  static TodayDailyCubit get(context) => BlocProvider.of<TodayDailyCubit>(context);

  late UserModel _userModel; // Add UserModel property

  // Load user model from SharedPreferences
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
      emit(TodayDailyError(message: e.toString()));
    }
  }

  Future<void> fetchTodayDailies({required String userId}) async {
    await loadUserModel(); // Ensure user model is loaded before fetching data

    try {
      final prefs = await SharedPreferences.getInstance();
      final url = prefs.getString('storedUrl');
      if (url == null) {
        emit(TodayDailyError(message: 'URL not found'));
        return;
      }
      emit(TodayDailyLoading());

      // Fetch data from API
      final Dio dio = Dio();
      final response = await dio.get(
        '$url/api/$userId/get_today_daily',
        options: Options(
          headers: {
            'token': '${_userModel.accessToken}', // Ensure this is correct
          },
        ),
      );
      print('Request URL: ${response.requestOptions.uri}');
      print('Request Headers: ${response.requestOptions.headers}');

      if (response.statusCode == 200) {
        final data = response.data['data'] as List;

        emit(TodayDailyLoaded(todayDailies: data));
      } else {
        emit(TodayDailyError(message: 'Failed to fetch data: ${response.statusCode}'));
      }
    } catch (e) {
      emit(TodayDailyError(message: 'Error: ${e.toString()}'));
    }
  }
}
