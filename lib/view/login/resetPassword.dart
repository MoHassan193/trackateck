import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../model/dialToast.dart';
import '../../model/userModel/userModel.dart';
import '../../model/utils/sizes.dart';
import '../../model_view/cubits/mainCubitofWidget/getTerritoryCubit/getTerritoryCubit.dart';
import '../../model_view/cubits/mainCubitofWidget/getTerritoryCubit/getTerritoryState.dart';

class ResetPassword extends StatefulWidget {
  const ResetPassword({super.key});

  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  late UserModel _userModel; // إضافة UserModel

  final TextEditingController emailController = TextEditingController();

  // وظيفة لتحميل بيانات المستخدم من SharedPreferences
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
      print(e.toString());
    }
  }
  // استرجاع الـ objectiveIds المحفوظة من SharedPreferences
  Future<void> resetPassword()async{
    await loadUserModel(); // تأكد من تحميل بيانات المستخدم قبل الجلب
    final prefs = await SharedPreferences.getInstance();
    final String? url = prefs.getString('storedUrl');

    if (url == null || url.isEmpty) {
      return;
    }

    final request = {
      'login' : emailController.text,

    };
    final dio = Dio();
    final response = await dio.put('$url/api/${emailController.text}/reset_password',
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          headers: {
            'token': _userModel.accessToken, // استخدام رمز التحقق
          },
        ),
        data: request);
    if(response.statusCode == 200){
      final data = response.data['data'];
      final name = data['name'];
      Navigator.pop(context);
      DialToast.showToast("Reset Password Successfuly\n$name", Colors.green);
    }else {
      print(response.data);
    }
  }

  @override
  void initState() {
    super.initState();
    loadUserModel();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: true,title: Text('Reset Password'),),
      body: Padding(
        padding:  EdgeInsets.all(MoSizes.md(context)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 15,),
            TextFormField(
              controller: emailController,
              decoration: InputDecoration(hintText: "Enter Email"),
            ),
            SizedBox(height: 25,),
            SizedBox(
                width: double.infinity,
                child: OutlinedButton(onPressed: (){
                  resetPassword();
                  }, child: Text("Reset Password"))),
            SizedBox(height: 15,),

          ],
        ),
      ),
    );
  }

}