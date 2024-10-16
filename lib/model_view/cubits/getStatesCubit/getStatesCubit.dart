
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visit_man/model/userModel/userModel.dart';

import 'getSatesState.dart';

class StatesCubit extends Cubit<StatesState> {
  StatesCubit() : super(StatesInitial());

  static StatesCubit get(context) => BlocProvider.of<StatesCubit>(context);

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
      emit(StatesError('Error loading user data: ${e.toString()}'));
    }
  }

  Future<void> fetchStates() async {
    emit(StatesLoading());

    await loadUserModel();

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? url = prefs.getString('storedUrl');

      if (url == null || url.isEmpty) {
        emit(StatesError('URL not found'));
        return;
      }

      final dio = Dio();
      final response = await dio.get(
        '$url/api/get_states',
        options: Options(
          headers: {
            'token': _userModel.accessToken,
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        emit(StatesLoaded(data));
      } else {
        emit(StatesError('Failed to fetch states: ${response.statusCode}'));
      }
    } catch (e) {
      emit(StatesError('Error: ${e.toString()}'));
    }
  }
}