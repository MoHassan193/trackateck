import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visit_man/model_view/cubits/postCubit/updateVisitCubit/updateVisitState.dart';

import '../../../../model/userModel/userModel.dart';

class UpdateVisitCubit extends Cubit<UpdateVisitState> {
  UpdateVisitCubit() : super(UpdateVisitInitial());

  static UpdateVisitCubit get(context) => BlocProvider.of(context);

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
      emit(UpdateVisitFailure('Error loading user data: ${e.toString()}'));
    }
  }

  var collaborativeIdController = TextEditingController();
  var surveyIdController = TextEditingController();
  var doubleVisitTypeController = TextEditingController();
  String isDoubleVisit = 'True';

  Future<void> updateVisitNoCheckout({
    required int collaborativeId,
    required bool isDoubleVisit,
    required int surveyId,
    required String doubleVisitType,
  }) async {
    emit(UpdateVisitLoading());

    await loadUserModel();

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? url = prefs.getString('storedUrl');

      if (url == null || url.isEmpty) {
        emit(UpdateVisitFailure('URL not found'));
        return;
      }
      final dio = Dio();
      final response = await dio.post(
        '$url/api/46/visit_update_nocheckout',
        options: Options(headers: {'token': _userModel.accessToken}),
        data: {
          'collaborative_id': collaborativeId,
          'is_double_visit': isDoubleVisit.toString(),
          'survey_id': surveyId,
          'double_visit_type': doubleVisitType,
        },
      );

      if (response.statusCode == 200) {
        emit(UpdateVisitSuccess(response.data));
      } else {
        emit(UpdateVisitFailure('Failed to update visit.'));
      }
    } catch (e) {
      emit(UpdateVisitFailure(e.toString()));
    }
  }
}
