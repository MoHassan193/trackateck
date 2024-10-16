import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visit_man/model/utils/sizes.dart';
import '../../model/dialToast.dart';
import '../../model/userModel/userModel.dart';


class CreateMonthlyPlan extends StatefulWidget {
  const CreateMonthlyPlan({super.key});

  @override
  State<CreateMonthlyPlan> createState() => _CreateMonthlyPlanState();
}

class _CreateMonthlyPlanState extends State<CreateMonthlyPlan> {
  late UserModel _userModel; // إضافة UserModel
  DateTime? selectedStartDate;
  DateTime? selectedEndDate;

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

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedStartDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedStartDate) {
      setState(() {
        selectedStartDate = picked;
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedEndDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedEndDate) {
      setState(() {
        selectedEndDate = picked;
      });
    }
  }
  // استرجاع الـ objectiveIds المحفوظة من SharedPreferences
  Future<void> createMonthlyPlan()async{
    await loadUserModel(); // تأكد من تحميل بيانات المستخدم قبل الجلب
    final prefs = await SharedPreferences.getInstance();
    final String? url = prefs.getString('storedUrl');

    if (url == null || url.isEmpty) {
      return;
    }

    final request = {
      'start_date' : DateFormat('yyyy-MM-dd').format(selectedStartDate!),
      'end_date' : DateFormat('yyyy-MM-dd').format(selectedEndDate!),
    };
    final dio = Dio();
    final response = await dio.put('$url/api/create_monthly_plan',
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
      DialToast.showToast("Monthly Plan Created Successfuly\n$name", Colors.green);
    }else {
      print(response.data);
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: true,title: Text('Create Monthly Plan'),),
      body: Padding(
        padding: EdgeInsets.all(MoSizes.md(context)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 15,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton(
                    onPressed: (){},child: Text(
                    selectedStartDate != null ? DateFormat('yyyy-MM-dd').format(selectedStartDate!).toString() : "Select Date",
                    style:TextStyle(color: Colors.blue))),
                IconButton(
                  onPressed: () => _selectStartDate(context),
                  icon: Icon(Icons.date_range_outlined,color: Colors.cyan,size: 30,),
                ),
              ],
            ),
            SizedBox(height: 15,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton(
                    onPressed: (){},child: Text(
                    selectedEndDate != null ? DateFormat('yyyy-MM-dd').format(selectedEndDate!).toString() : "Select Date",
                    style:TextStyle(color: Colors.blue))),
                IconButton(
                  onPressed: () => _selectEndDate(context),
                  icon: Icon(Icons.date_range_outlined,color: Colors.cyan,size: 30,),
                ),
              ],
            ),
            SizedBox(height: 25,),
            SizedBox(
                width: double.infinity,
                child: OutlinedButton(onPressed: (){createMonthlyPlan();}, child: Text("Create Monthly Plan"))),
            SizedBox(height: 15,),
        
          ],
        ),
      ),
    );
  }
}
