import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../model/userModel/calssificationModel.dart';
import '../../../../model/userModel/userModel.dart';
import 'getClassificationState.dart';


class ClassificationsCubit extends Cubit<ClassificationsState> {
  ClassificationsCubit() : super(ClassificationsInitial());

  static ClassificationsCubit get(context) => BlocProvider.of(context);

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
      emit(ClassificationsError('Error loading user data: ${e.toString()}'));
    }
  }

  Future<void> fetchClassifications() async {
    emit(ClassificationsLoading());

    await loadUserModel();
    try {
      final dio = Dio();
      final prefs = await SharedPreferences.getInstance();
      final String? url = prefs.getString('storedUrl');
      if (url == null || url.isEmpty) {
        emit(ClassificationsError('URL not found'));
        return;
      }

      final response = await dio.get(
        '$url/api/get_classifications',
        options: Options(
          headers: {'token': _userModel.accessToken},
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        final classifications = data
            .map((json) => ClassificationModel.fromJson(json))
            .toList();
        emit(ClassificationsLoaded(classifications));
      } else {
        emit(ClassificationsError('Failed to fetch classifications'));
      }
    } catch (e) {
      emit(ClassificationsError(e.toString()));
    }
  }
}
