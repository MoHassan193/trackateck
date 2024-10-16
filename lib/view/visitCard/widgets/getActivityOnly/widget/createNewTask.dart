import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visit_man/model/dialToast.dart';
import 'package:visit_man/model/userModel/userModel.dart';
import 'package:visit_man/model_view/cubits/mainCubitofWidget/getActivityType/getActivityCubit.dart';
import 'package:visit_man/model_view/cubits/mainCubitofWidget/getTodayVisitCubit/get_today_visit_state.dart';
import '../../../../../model/utils/move.dart';
import '../../../../../model/utils/sizes.dart';
import '../../../../../model_view/cubits/mainCubitofWidget/getActivityType/getActivityState.dart';
import '../../../../../model_view/cubits/mainCubitofWidget/getTodayVisitCubit/get_today_visit_cubit.dart';
import '../../getUsers/cubit/getUsersCubit.dart';
import '../../getUsers/cubit/getUsersState.dart';


class CreateNewTask extends StatefulWidget {
  const CreateNewTask({super.key,});

  @override
  State<CreateNewTask> createState() => _CreateNewTaskState();
}

class _CreateNewTaskState extends State<CreateNewTask> {
  late UserModel userModel;

  TextEditingController noteController = TextEditingController();
  TextEditingController activityTypeIdController = TextEditingController();
  TextEditingController summaryController = TextEditingController();
  TextEditingController todayVisitsController = TextEditingController();
  DateTime? selectedDate;
  String? selectedUserName;
  String? selectedId;

  @override
  void initState(){
    super.initState();
    loadUserModel();
  }
  Future<void> loadUserModel() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionData = prefs.getString('sessionData');
      if (sessionData != null) {
        userModel = UserModel.fromJson(jsonDecode(sessionData));
      } else {
        throw Exception('No user data found');
      }
    } catch (e) {
      DialToast.showToast('Error loading user data: ${e.toString()}', Colors.red);
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  bool _isLoading = false;
  Future<void> createTask() async {
    try {
      await loadUserModel();
      final dio = Dio();
      final prefs = await SharedPreferences.getInstance();
      final String? url = prefs.getString('storedUrl'); // Get the API URL

      if (url == null || url.isEmpty) {
        DialToast.showToast('URL not found', Colors.red);
        print('Error: URL not found in SharedPreferences');
        return;
      }

      final request = {
        'note': noteController.text ,
        'activity_type_id': int.parse(activityTypeIdController.text),
        'summary': summaryController.text,
        'date_deadline': DateFormat('yyyy-MM-dd').format(selectedDate!),
        'visit_id': int.parse(todayVisitsController.text),
      };

      final response = await dio.post(
        '$url/api/create_activity',
        options: Options(
          ///   contentType: Headers.formUrlEncodedContentType,
          headers: {
            'Accept': '*/*',
            'Accept-Encoding': 'gzip, deflate, br',
            'Connection': 'keep-alive',
            'token': userModel.accessToken,  // Ensure token is fetched correctly
            'charset': 'utf-8',
            'Content-Type': 'application/x-www-form-urlencoded',
          },
        ),
        data: request,
      );

      if (response.statusCode == 200) {
        print('Task edited successfully');
        DialToast.showToast("Task Added Successfully", Colors.green);
        Navigator.of(context).pop();
      } else {
        DialToast.showToast('Failed to edit, status code: ${response.statusCode}', Colors.red);
        print('Error: Failed to edit, status code: ${response.statusCode}');
      }
    } catch (e) {
      DialToast.showToast(e.toString(), Colors.red);
      print('Error: $e');
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding:  EdgeInsets.all(MoSizes.defaultSpace(context)),
        child: SingleChildScrollView(
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Create Task',textAlign: TextAlign.center,style: TextStyle(color: Colors.blue,fontSize: 25),),
                SizedBox(height: 12,),
                TextFormField(
                  controller: noteController,
                  decoration: InputDecoration(labelText: 'Note'),
                ),
                SizedBox(height: 8,),
                TextFormField(
                  controller: summaryController,
                  decoration: InputDecoration(labelText: 'Summary'),
                ),
                SizedBox(height: 12,),
                BlocProvider(
                  create: (context) => ActivityTypeCubit()..fetchActivityTypes(),
                  child: BlocBuilder<ActivityTypeCubit, ActivityTypeState>(
                    builder: (context, state) {
                      if (state is ActivityTypeLoading) {
                        return Center(child: CircularProgressIndicator());
                      } else if (state is ActivityTypeLoaded) {
                        int? selectedActivityTypeId; // نوع البيانات `int` بدلاً من `String`
                        return Column(
                          children: [
                            DropdownButtonFormField<int>( // تغيير نوع البيانات في Dropdown إلى `int`
                              decoration: InputDecoration(labelText: 'Activity Type'),
                              value: selectedActivityTypeId, // القيمة الافتراضية
                              items: state.activityTypes.map((activityType) {
                                return DropdownMenuItem<int>( // التأكد أن القيمة هي `int`
                                  value: activityType['id'], // القيمة التي سيتم تعيينها
                                  child: Text(activityType['name']), // النص الظاهر في القائمة
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedActivityTypeId = value; // حفظ الـ ID المختار
                                  activityTypeIdController.text = value.toString(); // تحويل الـ int إلى String وتعيينه في TextField
                                });
                              },
                            ),
                          ],
                        );
                      } else if (state is ActivityTypeError) {
                        return Center(child: Text('No Data Found'));
                      }
                      return Center(child: Text('لا توجد بيانات'));
                    },
                  ),
                ),
                SizedBox(height: 12,),
                FutureBuilder(
                  future: _getUserModelFromPrefs(),
                  builder:(context, snapshot) {
                    if(snapshot.hasError){
                      return Center(child: Text(snapshot.error.toString()),);
                    }else if (snapshot.hasData){
                      userModel = snapshot.data!;
                      return BlocProvider(
                        create: (context) => GetTodayVisitCubit()..fetchTodayVisits(userId: userModel.uid.toString()),
                        child: BlocBuilder<GetTodayVisitCubit, GetTodayVisitState>(
                          builder: (context, state) {
                            if (state is GetTodayVisitLoading) {
                              return Center(child: CircularProgressIndicator());
                            } else if (state is GetTodayVisitError) {
                              return Center(child: Text(state.message));
                            } else if (state is GetTodayVisitSuccess) {
                              int? selectedId; // نوع البيانات `int` بدلاً من `String`
                              return Column(
                                children: [
                                  // DropdownButton لعرض أسماء المستخدمين
                                  DropdownButtonFormField<int>( // تغيير نوع البيانات في Dropdown إلى `int`
                                    value: selectedId,
                                    hint: Text('Visits',style: TextStyle(color: Colors.black),),
                                    items: state.visits.map<DropdownMenuItem<int>>((visit) {
                                      return DropdownMenuItem<int>(
                                        value: visit['visit_id'], // استخدام الـ `id` كقيمة
                                        child: Text(visit['partner_id']),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        selectedId = value; // حفظ الـ ID المختار
                                        todayVisitsController.text = value.toString(); // تحويل الـ int إلى String وتعيينه في TextField
                                      });
                                    },
                                  ),
                                ],
                              );
                            }
                            return Center(child: Text('No Data'));
                          },
                        ),
                      );
                    }return Center(child: Text("No Data Found"),);
                  }
                ),
                SizedBox(height: 8),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    OutlinedButton(
                        onPressed: (){},child: Text(
                        selectedDate != null ? DateFormat('yyyy-MM-dd').format(selectedDate!).toString() : "Select Date",
                        style:TextStyle(color: Colors.blue))),
                    IconButton(
                      onPressed: () => _selectDate(context),
                      icon: Icon(Icons.date_range_outlined,color: Colors.cyan,size: 30,),
                    ),
                  ],
                ),
                SizedBox(height: 35,),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      // استدعاء دالة editTask لإرسال البيانات بعد التعديل
                      createTask();
                      setState(() {
                        _isLoading = true; // ابدأ التحميل
                      });

                      // محاكاة عملية التحميل لمدة 5 ثوانٍ
                      Future.delayed(Duration(seconds: 5), () {
                        // بعد انتهاء عملية التحميل
                        setState(() {
                          _isLoading = false; // إنهاء التحميل
                        });

                        // يمكنك إضافة الكود الخاص بإرسال البيانات بعد انتهاء التحميل هنا
                        print('Task created'); // مثال لطباعة رسالة في الكونسول
                      });
                    },
                    child: Text('Create'),
                  ),
                ),
                SizedBox(height: 20,),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.red.shade800
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('Cancel',style: TextStyle(color: Colors.white),),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

    );
  }
  Future<UserModel> _getUserModelFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionData = prefs.getString('sessionData');
    if (sessionData != null) {
      return UserModel.fromJson(jsonDecode(sessionData));
    }
    throw Exception('No user data found');
  }
}
