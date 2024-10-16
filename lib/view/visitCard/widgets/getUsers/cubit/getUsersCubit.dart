import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../model/userModel/userModel.dart';
import 'getUsersState.dart';

class GetUsersCubit extends Cubit<GetUsersState> {
  GetUsersCubit() : super(GetUsersInitial());

  static GetUsersCubit get(context) => BlocProvider.of<GetUsersCubit>(context);


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
      emit(GetUsersError('Error loading user data: ${e.toString()}'));
    }
  }


  Future<void> fetchUsers() async {
    emit(GetUsersLoading());

    await loadUserModel();
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? url = prefs.getString('storedUrl');

      if (url == null || url.isEmpty) {
        emit(GetUsersError('URL not found'));
        return;
      }

      final dio = Dio();
      final response = await dio.get('$url/api/get_users',
        options: Options(
        headers: {
        'token': _userModel.accessToken, // Use access token
        },
      ),
    );
      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        emit(GetUsersLoaded(data));
      } else {
        emit(GetUsersError('Failed to fetch data: ${response.statusCode}'));
      }
    } catch (e) {
      emit(GetUsersError('Error: ${e.toString()}'));
    }
  }
}
