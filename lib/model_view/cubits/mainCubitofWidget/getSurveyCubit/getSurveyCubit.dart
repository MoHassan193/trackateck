import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visit_man/model/userModel/surveyModel.dart';
import 'package:visit_man/model_view/cubits/mainCubitofWidget/getSurveyCubit/getSurveyState.dart';

import '../../../../model/userModel/userModel.dart';


class SurveyCubit extends Cubit<SurveyState> {
  SurveyCubit() : super(SurveyInitial());

  static SurveyCubit get(context) => BlocProvider.of<SurveyCubit>(context);

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
      emit(SurveyError('Error loading user data: ${e.toString()}'));
    }
  }

  Future<void> fetchSurveys() async {
    emit(SurveyLoading());
    await loadUserModel(); // Ensure user model is loaded before fetching data

    try {
      // Get the stored URL from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final String? url = prefs.getString('storedUrl');

      if (url == null || url.isEmpty) {
        emit(SurveyError('URL not found'));
        return;
      }

      final dio = Dio();
      final response = await dio.get('$url/api/get_surveys',options: Options(
        headers: {
          'token': _userModel.accessToken, // Use access token
        },
      ));

      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        final surveys = data.map((item) => SurveyModel.fromJson(item)).toList();
        emit(SurveyLoaded(surveys));
      } else {
        emit(SurveyError('Failed to fetch surveys: ${response.statusCode}'));
      }
    } catch (e) {
      emit(SurveyError('Error: ${e.toString()}'));
    }
  }
}
