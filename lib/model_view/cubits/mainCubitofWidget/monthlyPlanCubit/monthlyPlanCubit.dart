import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visit_man/model/userModel/monthlyPlanModel.dart';
import 'package:visit_man/model_view/cubits/mainCubitofWidget/monthlyPlanCubit/monthlyPlanState.dart';

import '../../../../model/userModel/userModel.dart';


class MonthlyPlanCubit extends Cubit<MonthlyPlanState> {
  MonthlyPlanCubit() : super(MonthlyPlanInitial());

  static MonthlyPlanCubit get(context) => BlocProvider.of<MonthlyPlanCubit>(context);

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
      emit(MonthlyPlanError('Error loading user data: ${e.toString()}'));
    }
  }

  Future<void> fetchMonthlyPlans({required String userId}) async {
    emit(MonthlyPlanLoading());

    await loadUserModel(); // Ensure user model is loaded before fetching data

    try {
      // Get the stored URL from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final String? url = prefs.getString('storedUrl');

      if (url == null || url.isEmpty) {
        emit(MonthlyPlanError('URL not found'));
        return;
      }

      final dio = Dio();
      final response = await dio.get('$url/api/$userId/get_monthly_plans',
        options: Options(
          headers: {
            'token': _userModel.accessToken, // Use access token
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as List;

        emit(MonthlyPlanLoaded(data));
      } else {
        emit(MonthlyPlanError('Failed to fetch data: ${response.statusCode}'));
      }
    } catch (e) {
      emit(MonthlyPlanError('Error: ${e.toString()}'));
    }
  }
}
