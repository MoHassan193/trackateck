

import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../model/userModel/userModel.dart';
import 'get_today_visit_state.dart';

class GetTodayVisitCubit extends Cubit<GetTodayVisitState> {
  GetTodayVisitCubit() : super(GetTodayVisitInitial());

  static GetTodayVisitCubit get(context) => BlocProvider.of<GetTodayVisitCubit>(context);

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
      emit(GetTodayVisitError('Error loading user data: ${e.toString()}'));
    }
  }

  Future<void> fetchTodayVisits({required String userId}) async {
    emit(GetTodayVisitLoading());

    await loadUserModel();
    try {
      // Get the stored URL from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final String? url = prefs.getString('storedUrl');

      if (url == null || url.isEmpty) {
        emit(GetTodayVisitError('URL not found'));
        return;
      }

      final dio = Dio();
      final response = await dio.get('$url/api/$userId/get_today_visits',
options: Options(
headers: {
'token': _userModel.accessToken, // Use access token
},
),
  queryParameters: {'user_id': userId});

  if (response.statusCode == 200) {
        final data = response.data['data'];
        final int numberOfVisits = data.length;
        final count = response.data['count'];
        // Extract number of visits
        emit(GetTodayVisitSuccess(response.data['data']));
      } else {
        emit(GetTodayVisitError('Failed to fetch data: ${response.statusCode}'));
      }
    } catch (e) {
    }
  }
}

