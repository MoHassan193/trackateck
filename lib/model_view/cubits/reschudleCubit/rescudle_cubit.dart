import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visit_man/model/dialToast.dart';
import 'package:visit_man/model_view/cubits/reschudleCubit/rescudle_state.dart';

import '../../../model/userModel/userModel.dart';


class RescudleCubit extends Cubit<RescudleState> {
  RescudleCubit() : super(RescudleInitial());

  static RescudleCubit get(context) => BlocProvider.of<RescudleCubit>(context);


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
      emit(RescudleError());
    }
  }
  var reschudleReasonController = TextEditingController();
  var reschudleDateController = TextEditingController();
  DateTime? date;
  Future<void> sendReschudle({required String visitId,required String visitState,}) async {
    emit(RescudleLoading());

    await loadUserModel(); // Ensure user model is loaded before fetching data

    try {
      // Get the stored URL from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final String? url = prefs.getString('storedUrl');

      if (url == null || url.isEmpty) {
        emit(RescudleError());
        return;
      }
      print(_userModel.accessToken);

      final request = {
        'reschedule_reason' : reschudleReasonController.text,
        'reschedule_date': DateFormat('yyyy-MM-dd').format(date!),
        'state' : visitState,
      };
      final dio = Dio();
      final response = await dio.post('$url/api/$visitId/reschedule_visit',
        options: Options(
          headers: {
            'token': _userModel.accessToken, // Use access token
          },
        ),
        data: request
      );

      if (response.statusCode == 200) {
        DialToast.showToast("Reschudle Sent", Colors.green);
        emit(RescudleSuccess());
      } else {
        emit(RescudleError());
      }
    } catch (e) {
      emit(RescudleError());
    }
  }

}
