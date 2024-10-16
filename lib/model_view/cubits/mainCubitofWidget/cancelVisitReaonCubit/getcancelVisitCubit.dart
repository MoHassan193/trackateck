import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../model/userModel/cancelVisitReason.dart';
import '../../../../model/userModel/userModel.dart';
import 'getcancelVisitState.dart';


class VisitCancelReasonCubit extends Cubit<VisitCancelReasonState> {
  VisitCancelReasonCubit() : super(VisitCancelReasonInitial());

  static VisitCancelReasonCubit get(context) => BlocProvider.of(context);
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
      emit(VisitCancelReasonError('Error loading user data: ${e.toString()}'));
    }
  }

  Future<void> fetchVisitCancelReasons() async {
    emit(VisitCancelReasonLoading());

    await loadUserModel();

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? url = prefs.getString('storedUrl');
      if (url == null || url.isEmpty) {
        emit(VisitCancelReasonError('URL not found'));
        return;
      }
      final dio = Dio();
      final response = await dio.get('$url/api/get_visit_cancel_reasons',
      options: Options(headers: {'token': _userModel.accessToken}),
      );
      final List<dynamic> data = response.data['data'];

      emit(VisitCancelReasonLoaded(data));
    } catch (e) {
      emit(VisitCancelReasonError('Error loading data: ${e.toString()}'));
    }
  }
}
