import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../model/dialToast.dart';
import '../../model/userModel/userModel.dart';

class CreateMonthlyDialog extends StatefulWidget {
  const CreateMonthlyDialog({ super.key,});

  @override
  State<CreateMonthlyDialog> createState() => _CreateMonthlyDialogState();
}

class _CreateMonthlyDialogState extends State<CreateMonthlyDialog> {
  late UserModel _userModel;
  DateTime? selectedStartDate;
  DateTime? selectedEndDate;

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

  Future<void> createMonthlyPlan() async {
    await loadUserModel();
    final prefs = await SharedPreferences.getInstance();
    final String? url = prefs.getString('storedUrl');

    if (url == null || url.isEmpty) return;

    final request = {
      'start_date': DateFormat('yyyy-MM-dd').format(selectedStartDate!),
      'end_date': DateFormat('yyyy-MM-dd').format(selectedEndDate!),
    };

    final dio = Dio();
    final response = await dio.put('$url/api/create_monthly_plan',
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          headers: {
            'token': _userModel.accessToken,
          },
        ),
        data: request);

    if (response.statusCode == 200) {
      final newPlanId = response.data['data']['id']; // الحصول على ID الخطة الجديدة
      final name = response.data['data']['name'];
      Navigator.pop(context);
      DialToast.showToast("Monthly Plan Created Successfully"
          "\n$name", Colors.green);
    } else {
      print(response.data);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.all(8.0),  // تقليل الحشوة
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton(
                  onPressed: () {},
                  child: Text(
                    selectedStartDate != null
                        ? DateFormat('yyyy-MM-dd').format(selectedStartDate!).toString()
                        : "Select Start Date",
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
                IconButton(
                  onPressed: () => _selectStartDate(context),
                  icon: Icon(Icons.date_range_outlined, color: Colors.cyan, size: 15),
                ),
              ],
            ),
            SizedBox(height: 8), // تقليل المسافة بين الأزرار
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton(
                  onPressed: () {},
                  child: Text(
                    selectedEndDate != null
                        ? DateFormat('yyyy-MM-dd').format(selectedEndDate!).toString()
                        : "Select End Date",
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
                IconButton(
                  onPressed: () => _selectEndDate(context),
                  icon: Icon(Icons.date_range_outlined, color: Colors.cyan, size: 15),
                ),
              ],
            ),
            SizedBox(height: 15), // تقليل المسافة
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: (){
                  createMonthlyPlan();
                },
                child: Text("Create Monthly Plan"),
              ),
            ),
          ],
        ),
      );
  }
}
