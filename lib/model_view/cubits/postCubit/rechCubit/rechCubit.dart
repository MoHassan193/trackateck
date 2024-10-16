import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visit_man/model/userModel/userModel.dart';
import 'package:visit_man/model_view/cubits/postCubit/rechCubit/rechState.dart';

import '../../../../model/userModel/rechModel.dart';

class RescheduleVisitCubit extends Cubit<RescheduleVisitState> {
  RescheduleVisitCubit() : super(RescheduleVisitInitial());

  static RescheduleVisitCubit get(context) => BlocProvider.of(context);


  var rescheduleReasonController = TextEditingController();
  var rescheduleDateController = TextEditingController();


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
      emit(RescheduleVisitFailure('Error loading user data: ${e.toString()}'));
    }
  }

  Future<void> rescheduleVisit({
    required String rescheduleReason,
    required String rescheduleDate,
    required String state,
  }) async {
    emit(RescheduleVisitLoading());
    await loadUserModel();


    try {

      final prefs = await SharedPreferences.getInstance();
      final String? url = prefs.getString('storedUrl');

      if (url == null || url.isEmpty) {
        emit(RescheduleVisitFailure('URL not found'));
        return;
      }


      final dio = Dio();
      final response = await dio.post(
        '$url/api/74/reschedule_visit',
        data: {
          'reschedule_reason': rescheduleReason,
          'reschedule_date': rescheduleDate,
          'state': state,
        },
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          headers: {'token': _userModel.accessToken},
        ),
      );

      if (response.statusCode == 200) {
        final rescheduleVisit = RescheduleVisitModel.fromJson(response.data['data']);
        emit(RescheduleVisitSuccess(rescheduleVisit));
      } else {
        emit(RescheduleVisitFailure('Failed to reschedule visit.'));
      }
    } catch (error) {
      emit(RescheduleVisitFailure(error.toString()));
    }
  }
}
