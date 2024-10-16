import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visit_man/model/dialToast.dart';
import '../../../model/userModel/userModel.dart';
import 'cancel_state.dart';

// CancelCubit لإدارة حالة الإلغاء
class CancelCubit extends Cubit<CancelState> {
  CancelCubit() : super(CancelInitial());

  static CancelCubit get(context) => BlocProvider.of<CancelCubit>(context);

  late UserModel _userModel;
  int? selectedId; // المتغير الذي سيحتفظ بالقيمة المختارة
  var cancelReasonController = TextEditingController();

  // تحميل بيانات المستخدم من SharedPreferences
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
      emit(CancelError());
    }
  }

  // تغيير قيمة السبب المختار
  void changeSelectedId(int? newId) {
    selectedId = newId;
    emit(CancelSelectedReasonChanged());
  }

  // إرسال طلب إلغاء الزيارة
  Future<void> sendCancel({required String visitId, required String visitState,}) async {
    emit(CancelLoading());

    await loadUserModel(); // التأكد من تحميل بيانات المستخدم

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? url = prefs.getString('storedUrl');

      if (url == null || url.isEmpty) {
        emit(CancelError());
        return;
      }

      final request = {
        'reason_cancel': int.tryParse(cancelReasonController.text),
        'state': visitState,
      };

      final dio = Dio();
      final response = await dio.post('$url/api/$visitId/cancel_visit',
          options: Options(
            contentType: Headers.formUrlEncodedContentType,
            headers: {
              'token': _userModel.accessToken, // استخدام التوكن من بيانات المستخدم
            },
          ),
          data: request
      );

      if (response.statusCode == 200) {
        emit(CancelSuccess());
        DialToast.showToast("Cancel Successfuly", Colors.green);

      } else {
        emit(CancelError());
      }
    } catch (e) {
      print(e.toString());
      emit(CancelError());
    }
  }

  @override
  Future<void> close() {
    cancelReasonController.dispose();
    return super.close();
  }
}


