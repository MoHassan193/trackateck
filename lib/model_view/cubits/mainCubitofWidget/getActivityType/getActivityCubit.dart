import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visit_man/model/userModel/activityTypeModel.dart';
import 'package:visit_man/model/userModel/userModel.dart';
import 'package:visit_man/model_view/cubits/mainCubitofWidget/getActivityType/getActivityState.dart';

class ActivityTypeCubit extends Cubit<ActivityTypeState> {
  ActivityTypeCubit() : super(ActivityTypeInitial());

  static ActivityTypeCubit get(context) => BlocProvider.of<ActivityTypeCubit>(context);

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
      emit(ActivityTypeError('Error loading user data: ${e.toString()}'));
    }
  }

  Future<void> fetchActivityTypes() async {
    emit(ActivityTypeLoading());

    await loadUserModel(); // Ensure user model is loaded before fetching data

    try {
      // Get the stored URL from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final String? url = prefs.getString('storedUrl');

      if (url == null || url.isEmpty) {
        emit(ActivityTypeError('URL not found'));
        return;
      }

      final dio = Dio();
      final response = await dio.get('$url/api/get_activity_type',
        options: Options(
          headers: {
            'token': _userModel.accessToken, // Use access token
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as List;

        emit(ActivityTypeLoaded(data));
      } else {
        emit(ActivityTypeError('Failed to fetch data: ${response.statusCode}'));
      }
    } catch (e) {
      emit(ActivityTypeError('Error: ${e.toString()}'));
    }
  }
}