import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visit_man/model/userModel/userModel.dart';

import '../../../../model/userModel/behaviorStyleModel.dart';
import 'behaviorStyleState.dart';


class BehavioralStylesCubit extends Cubit<BehavioralStylesState> {
  BehavioralStylesCubit() : super(BehavioralStylesInitial());

  static BehavioralStylesCubit get(context) => BlocProvider.of<BehavioralStylesCubit>(context);

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
      emit(BehavioralStylesError('Error loading user data: ${e.toString()}'));
    }
  }

  Future<void> fetchBehavioralStyles() async {
    emit(BehavioralStylesLoading());

    await loadUserModel();

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? url = prefs.getString('storedUrl');

      if (url == null || url.isEmpty) {
        emit(BehavioralStylesError('URL not found'));
        return;
      }

      final dio = Dio();
      final response = await dio.get(
        '$url/api/get_behavioral_styles',
        options: Options(
          headers: {
            'token': _userModel.accessToken,
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        final styles = data.map((item) => BehavioralStyleModel.fromJson(item)).toList();
        emit(BehavioralStylesLoaded(styles));
      } else {
        emit(BehavioralStylesError('Failed to fetch behavioral styles: ${response.statusCode}'));
      }
    } catch (e) {
      emit(BehavioralStylesError('Error: ${e.toString()}'));
    }
  }
}
