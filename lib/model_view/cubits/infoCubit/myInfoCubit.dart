import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visit_man/model/userModel/userModel.dart';
import 'package:visit_man/model_view/cubits/infoCubit/myInfoState.dart';

class MyInfoCubit extends Cubit<MyInfoState> {
  MyInfoCubit() : super(MyInfoInitial());

  static MyInfoCubit get(context) => BlocProvider.of<MyInfoCubit>(context);

  late UserModel _userModel;

  // تحميل بيانات المستخدم من SharedPreferences
  Future<void> loadUserModel() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionData = prefs.getString('sessionData');
      if (sessionData != null) {
        _userModel = UserModel.fromJson(jsonDecode(sessionData));
      } else {
        throw Exception('لم يتم العثور على بيانات المستخدم');
      }
    } catch (e) {
      emit(MyInfoError('حدث خطأ أثناء تحميل بيانات المستخدم: ${e.toString()}'));
    }
  }

  // جلب البيانات من API وحفظها في SharedPreferences
  Future<void> fetchMyInfo({required String userId}) async {
    emit(MyInfoLoading());

    await loadUserModel();

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? url = prefs.getString('storedUrl');

      if (url == null || url.isEmpty) {
        emit(MyInfoError('لم يتم العثور على URL'));
        return;
      }

      final dio = Dio();
      final response = await dio.get(
        '$url/api/$userId/my_info',
        options: Options(
          headers: {
            'token': _userModel.accessToken,
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data['data'];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userName', data['name']);
        // حفظ البيانات في SharedPreferences
        await prefs.setString('userInfo', jsonEncode(data));

        emit(MyInfoLoaded(data));
      } else {
        emit(MyInfoError('فشل في جلب البيانات: ${response.statusCode}'));
      }
    } catch (e) {
      emit(MyInfoError('حدث خطأ: ${e.toString()}'));
    }
  }
}