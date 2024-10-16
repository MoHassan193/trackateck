import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visit_man/model/userModel/visitObjectiveModel.dart';
import 'package:visit_man/model_view/cubits/mainCubitofWidget/visitObjectiveCubit/visitObjectiveState.dart';

import '../../../../model/userModel/userModel.dart';


class VisitObjectiveCubit extends Cubit<VisitObjectiveState> {
  VisitObjectiveCubit() : super(VisitObjectiveInitial());

  static VisitObjectiveCubit get(context) => BlocProvider.of<VisitObjectiveCubit>(context);

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
      emit(VisitObjectiveError('Error loading user data: ${e.toString()}'));
    }
  }

  Future<void> fetchVisitObjectives() async {
    emit(VisitObjectiveLoading());

    await loadUserModel(); // Ensure user model is loaded before fetching data

    try {
      // Get the stored URL from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final String? url = prefs.getString('storedUrl');

      if (url == null || url.isEmpty) {
        emit(VisitObjectiveError('URL not found'));
        return;
      }

      final dio = Dio();
      final response = await dio.get('$url/api/get_visit_objective',
        options: Options(
          headers: {
            'token': _userModel.accessToken,
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        final visitObjectives = data
            .map((item) => VisitObjectiveModel.fromJson(item))
            .toList();

        emit(VisitObjectiveLoaded(visitObjectives));
      } else {
        emit(VisitObjectiveError('Failed to fetch data: ${response.statusCode}'));
      }
    } catch (e) {
      emit(VisitObjectiveError('Error: ${e.toString()}'));
    }
  }
}
