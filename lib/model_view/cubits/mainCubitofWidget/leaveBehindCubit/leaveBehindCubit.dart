import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visit_man/model/userModel/leaveBehindModel.dart';
import 'package:visit_man/model_view/cubits/mainCubitofWidget/leaveBehindCubit/leaveBehindState.dart';

import '../../../../model/userModel/userModel.dart';


class LeaveBehindCubit extends Cubit<LeaveBehindState> {
  LeaveBehindCubit() : super(LeaveBehindInitial());

  static LeaveBehindCubit get(context) => BlocProvider.of<LeaveBehindCubit>(context);

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
      emit(LeaveBehindError('Error loading user data: ${e.toString()}'));
    }
  }

  Future<void> fetchLeaveBehinds() async {
    emit(LeaveBehindLoading());

    await loadUserModel(); // Ensure user model is loaded before fetching data

    try {
      // Get the stored URL from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final String? url = prefs.getString('storedUrl');

      if (url == null || url.isEmpty) {
        emit(LeaveBehindError('URL not found'));
        return;
      }

      final dio = Dio();
      final response = await dio.get('$url/api/get_leave_behind',
        options: Options(
          headers: {
            'token': _userModel.accessToken, // Use access token
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as List;

        emit(LeaveBehindLoaded(data));
      } else {
        emit(LeaveBehindError('Failed to fetch data: ${response.statusCode}'));
      }
    } catch (e) {
      emit(LeaveBehindError('Error: ${e.toString()}'));
    }
  }
}
