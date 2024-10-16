

import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visit_man/model_view/cubits/partnerVisitsCubit/partnerVisitsState.dart';
import '../../../../model/userModel/userModel.dart';

class PartnerVisitCubit extends Cubit<PartnerVisitState> {
  PartnerVisitCubit() : super(PartnerVisitInitial());

  static PartnerVisitCubit get(context) => BlocProvider.of<PartnerVisitCubit>(context);

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
      emit(PartnerVisitError('Error loading user data: ${e.toString()}'));
    }
  }

  Future<void> fetchTodayVisits({required String partnerId}) async {
    emit(PartnerVisitLoading());

    await loadUserModel();
    try {
      // Get the stored URL from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final String? url = prefs.getString('storedUrl');

      if (url == null || url.isEmpty) {
        emit(PartnerVisitError('URL not found'));
        return;
      }

      final dio = Dio();
      final response = await dio.get('$url/api/$partnerId/get_client_visits',
          options: Options(
            headers: {
              'token': _userModel.accessToken, // Use access token
            },
          ),
    );

      if (response.statusCode == 200) {
        final data = response.data['data'];
        final int numberOfVisits = data.length;
        final count = response.data['count'];
        // Extract number of visits
        emit(PartnerVisitSuccess(response.data['data']));
      } else {
        emit(PartnerVisitError('Failed to fetch data: ${response.statusCode}'));
      }
    } catch (e) {
    }
  }
}

