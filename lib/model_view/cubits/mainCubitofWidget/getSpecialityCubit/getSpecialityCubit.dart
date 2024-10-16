import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visit_man/model/userModel/userModel.dart';

import '../../../../model/userModel/specialityModel.dart';
import 'getSpecialityState.dart';


class SpecialitiesCubit extends Cubit<SpecialitiesState> {
  SpecialitiesCubit() : super(SpecialitiesInitial());

  static SpecialitiesCubit get(context) => BlocProvider.of<SpecialitiesCubit>(context);

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
      emit(SpecialitiesError('Error loading user data: ${e.toString()}'));
    }
  }

  Future<void> fetchSpecialities() async {
    emit(SpecialitiesLoading());

    await loadUserModel();

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? url = prefs.getString('storedUrl');

      if (url == null || url.isEmpty) {
        emit(SpecialitiesError('URL not found'));
        return;
      }

      final dio = Dio();
      final response = await dio.get(
        '$url/api/get_specialities',
        options: Options(
          headers: {
            'token': _userModel.accessToken,
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        final specialities = data.map((item) => SpecialityModel.fromJson(item)).toList();
        emit(SpecialitiesLoaded(specialities));
      } else {
        emit(SpecialitiesError('Failed to fetch specialities: ${response.statusCode}'));
      }
    } catch (e) {
      emit(SpecialitiesError('Error: ${e.toString()}'));
    }
  }
}
