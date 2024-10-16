import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visit_man/model/userModel/userModel.dart';

import 'getTitlesState.dart';

class TitlesCubit extends Cubit<TitlesState> {
  TitlesCubit() : super(TitlesInitial());

  static TitlesCubit get(context) => BlocProvider.of<TitlesCubit>(context);

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
      emit(TitlesError('Error loading user data: ${e.toString()}'));
    }
  }

  Future<void> fetchTitles() async {
    emit(TitlesLoading());

    await loadUserModel();

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? url = prefs.getString('storedUrl');

      if (url == null || url.isEmpty) {
        emit(TitlesError('URL not found'));
        return;
      }

      final dio = Dio();
      final response = await dio.get(
        '$url/api/get_titles',
        options: Options(
          headers: {
            'token': _userModel.accessToken,
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as List;


        emit(TitlesLoaded(data));
      } else {
        emit(TitlesError('Failed to fetch titles: ${response.statusCode}'));
      }
    } catch (e) {
      emit(TitlesError('Error: ${e.toString()}'));
    }
  }

}
