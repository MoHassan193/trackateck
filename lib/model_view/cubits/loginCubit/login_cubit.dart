import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visit_man/model/dialToast.dart';
import 'package:visit_man/model/userModel/userModel.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit() : super(LoginInitial()) {
    loadStoredCredentials();
  }

  static LoginCubit get(context) => BlocProvider.of<LoginCubit>(context);

  var urlForSystemController = TextEditingController();
  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  var databasetype = TextEditingController();

  bool keepMeSignedIn = false;

  void toggleKeepMeSignedIn(bool value) {
    keepMeSignedIn = value;
    SharedPreferences.getInstance().then((prefs) {
      prefs.setBool('keepMeSignedIn', value);
    });
    emit(LoginKeepMeSignedInChanged(keepMeSignedIn));
  }

  Future<void> loadStoredCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    urlForSystemController.text = prefs.getString('storedUrl') ?? '';
    emailController.text = prefs.getString('storedEmail') ?? '';
    passwordController.text = prefs.getString('storedPassword') ?? '';
    databasetype.text = prefs.getString('storedDatabase') ?? '';
    keepMeSignedIn = prefs.getString('storedEmail') != null;
    emit(LoginKeepMeSignedInChanged(keepMeSignedIn));
  }

  Future<void> loginFunction() async {
    final String url = urlForSystemController.text.trim();
    final String email = emailController.text.trim();
    final String password = passwordController.text.trim();
    final String databaseName = databasetype.text.trim();

    if (url.isEmpty || email.isEmpty || password.isEmpty || databaseName.isEmpty) {
      emit(LoginErrorState());
      DialToast.showToast('All fields are required', Colors.red);
      return;
    }

    if (!url.startsWith('http')) {
      emit(LoginErrorState());
      DialToast.showToast('Invalid URL', Colors.red);
      return;
    }

    emit(LoginLoadingState());

    try {
      final dio = Dio();

      // لالتقاط الكوكيز بما في ذلك الـ session_id
      dio.interceptors.add(InterceptorsWrapper(
        onResponse: (response, handler) async {
          // استخراج الكوكيز من الاستجابة
          var cookies = response.headers['set-cookie'];
          if (cookies != null) {
            String? sessionId;
            String? cookieString; // متغير لحفظ الـ cookie
            for (var cookie in cookies) {
              if (cookie.contains('session_id')) {
                // استخراج session_id من الكوكيز
                sessionId = cookie.split(';')[0].split('=')[1];
              }
              // احفظ جميع الكوكيز كـ string
              cookieString = cookie; // يمكنك تخصيص كيف تريد حفظ الكوكيز
            }

            if (sessionId != null) {
              // حفظ session_id وcookie في SharedPreferences
              final prefs = await SharedPreferences.getInstance();
              await prefs.setString('session_id', sessionId);
              await prefs.setString('cookie', cookieString!); // حفظ الكوكيز هنا
              DialToast.showToast("All your Data Saved Secure", Colors.green);
            }
          }

          return handler.next(response);
        },
      ));

      final response = await dio.post(
        '$url/api/auth/token',
        data: {
          'login': email,
          'password': password,
          'db': databaseName,
        },
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
        ),
      );

      if (response.statusCode == 200) {
        final userModel = UserModel.fromJson(response.data);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('accessToken', userModel.accessToken);
        await prefs.setString('sessionData', jsonEncode(userModel.toJson()));
        await prefs.setString('storedUrl', url);

        // هنا حفظ الكوكيز بعد الـ response
        final cookie = response.headers['set-cookie']?.first; // استخراج أول cookie
        if (cookie != null) {
          await prefs.setString('cookie', cookie); // حفظ الكوكيز
        }

        if (keepMeSignedIn) {
          await prefs.setString('storedEmail', email);
          await prefs.setString('storedPassword', password);
          await prefs.setString('storedDatabase', databaseName);
        }

        emit(LoginSuccessState());
        DialToast.showToast('Login Successful', Colors.green);
      } else {
        emit(LoginErrorState());
        DialToast.showToast('Login Failed', Colors.red);
      }
    } catch (e) {
      emit(LoginErrorState());
      DialToast.showToast('Login Failed', Colors.red);
    }
  }
}
