// Cubit Definition
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visit_man/model_view/cubits/postCubit/createActivityCubit/createActivityState.dart';

import '../../../../model/userModel/userModel.dart';

class CreateActivityCubit extends Cubit<CreateActivityState> {
  CreateActivityCubit() : super(CreateActivityInitial());

  static CreateActivityCubit get(context) => BlocProvider.of(context);

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
      emit(CreateActivityFailure('Error loading user data: ${e.toString()}'));
    }
  }


  Future<void> createActivity({required int visitId, required String summary, required String dateDeadline, required int activityTypeId,}) async {
    emit(CreateActivityLoading());

    await loadUserModel();

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? url = prefs.getString('storedUrl');

      if (url == null || url.isEmpty) {
        emit(CreateActivityFailure('URL not found'));
        return;
      }

      final dio = Dio();
      final response = await dio.post(
        '$url/api/create_activity',
        options: Options(headers: {'token': _userModel.accessToken}),
        data: {
          'visit_id': visitId,
          'summary': summary,
          'date_deadline': dateDeadline,
          'activity_type_id': activityTypeId,
        },
      );

      if (response.statusCode == 200) {
        emit(CreateActivitySuccess("Activity Created Successfully"));
      } else {
        emit(CreateActivityFailure("Failed to create activity"));
      }
    } catch (e) {
      emit(CreateActivityFailure(e.toString()));
    }
  }
}