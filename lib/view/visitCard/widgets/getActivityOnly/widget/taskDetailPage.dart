import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visit_man/model/dialToast.dart';
import 'package:visit_man/model/userModel/userModel.dart';
import 'package:visit_man/model_view/cubits/mainCubitofWidget/getActivityType/getActivityCubit.dart';
import 'package:visit_man/view/visitCard/widgets/getActivityOnly/widget/createNewTask.dart';
import '../../../../../model/utils/move.dart';
import '../../../../../model/utils/sizes.dart';
import '../../../../../model_view/cubits/mainCubitofWidget/getActivityType/getActivityState.dart';
import '../../getUsers/cubit/getUsersCubit.dart';
import '../../getUsers/cubit/getUsersState.dart';

class TaskDetailsPage extends StatefulWidget {
  const TaskDetailsPage({
    super.key,
    required this.screenHeight,
    required this.resname,
    required this.date,
    required this.summary,
    required this.activityTypeId,
    required this.user,
    required this.note,
    required this.resModel,required this.id,
  });
  final String id;
  final double screenHeight;
  final dynamic resname;
  final dynamic date;
  final dynamic summary;
  final dynamic activityTypeId;
  final dynamic user;
  final dynamic note;
  final dynamic resModel;

  @override
  State<TaskDetailsPage> createState() => _TaskDetailsPageState();
}

class _TaskDetailsPageState extends State<TaskDetailsPage> {
  late UserModel userModel;

  TextEditingController noteController = TextEditingController();
  TextEditingController activityTypeIdController = TextEditingController();
  TextEditingController summaryController = TextEditingController();
  TextEditingController userIdController = TextEditingController();
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

  Future<void> editTask({required String id}) async {
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
        'user_id': int.parse(userIdController.text),
      };

      final response = await dio.post(
        '$url/api/$id/edit_activity',
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
        DialToast.showToast("Edit successfully", Colors.green);
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

  bool _isLoading1 = false;
  bool _isLoading = false;
  Future<void> cancelTask({required String id}) async {
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

      final response = await dio.post(
        '$url/api/$id/cancel_activity',
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
      );

      if (response.statusCode == 200) {
        print('Task Canceled successfully');
        DialToast.showToast("Task Canceled successfully", Colors.green);
        Navigator.of(context).pop();
      } else {
        DialToast.showToast('Failed to Cancel, status code: ${response.statusCode}', Colors.red);
        print('Error: Failed to edit, status code: ${response.statusCode}');
      }
    } catch (e) {
      DialToast.showToast(e.toString(), Colors.red);
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    String note = widget.note;
    List<String> splitText = note.split('<p>');

// إعادة تحويل القائمة إلى سلسلة نصية بدون أي فاصل
    String resultNote = splitText.join('');
    return Scaffold(
      appBar: AppBar(

        title: Text("Edit Task Details", style: TextStyle(color: Colors.white)),
        automaticallyImplyLeading: true,
        centerTitle: true,
      ),
      body: Padding(
        padding:  EdgeInsets.all(MoSizes.md(context)),
        child: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.cyan, width: 2),
          ),
          height: widget.screenHeight * 0.42,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "${widget.resname}",
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: widget.screenHeight * 0.018,
                    ),
                  ),
                  Text(
                    widget.date,
                    textAlign: TextAlign.end,
                    style: TextStyle(
                      color: Colors.cyan,
                      fontSize: widget.screenHeight * 0.015,
                    ),
                  ),
                ],
              ),
              SizedBox(height: widget.screenHeight * 0.02),
              Divider(color: Colors.cyan, thickness: 1),
              SizedBox(height: widget.screenHeight * 0.02),
              Text(
                widget.summary,
                textAlign: TextAlign.start,
                style: TextStyle(
                  color: Colors.cyan,
                  fontSize: widget.screenHeight * 0.018,
                ),
              ),
              SizedBox(height: widget.screenHeight * 0.01),
              Text(
                resultNote.toString(),
                textAlign: TextAlign.start,
                softWrap: true, // يسمح بتكسر النص إلى سطر جديد
                maxLines: null, // يسمح للنص بالانتقال إلى عدد غير محدد من السطور
                style: TextStyle(
                  overflow: TextOverflow.visible,
                  color: Colors.cyan,
                  fontSize: widget.screenHeight * 0.015,
                ),
              ),
              SizedBox(height: widget.screenHeight * 0.01),
              Text(
                widget.resModel,
                textAlign: TextAlign.start,
                style: TextStyle(
                  color: Colors.cyan,
                  fontSize: widget.screenHeight * 0.018,
                ),
              ),
              SizedBox(height: widget.screenHeight * 0.05),
              // زر الضغط الذي يظهر الدايلوج
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => showDialog(
                    context: context,
                    builder: (context) => StatefulBuilder(builder: (context, setState) => Scaffold(
                      body: Padding(
                        padding:  EdgeInsets.all(MoSizes.defaultSpace(context) / 2),
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Edit Task Details',textAlign: TextAlign.center,style: TextStyle(color: Colors.blue,fontSize: 25),),
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
                              BlocProvider(
                                create: (context) => GetUsersCubit()..fetchUsers(),
                                child: BlocBuilder<GetUsersCubit, GetUsersState>(
                                  builder: (context, state) {
                                    if (state is GetUsersLoading) {
                                      return Center(child: CircularProgressIndicator());
                                    } else if (state is GetUsersError) {
                                      return Center(child: Text(state.message));
                                    } else if (state is GetUsersLoaded) {
                                      int? selectedId; // نوع البيانات `int` بدلاً من `String`
                                      return Column(
                                        children: [
                                          // DropdownButton لعرض أسماء المستخدمين
                                          DropdownButtonFormField<int>( // تغيير نوع البيانات في Dropdown إلى `int`
                                            value: selectedId,
                                            hint: Text('User'),
                                            items: state.users.map<DropdownMenuItem<int>>((user) {
                                              return DropdownMenuItem<int>(
                                                value: user['id'], // استخدام الـ `id` كقيمة
                                                child: Text(user['name']),
                                              );
                                            }).toList(),
                                            onChanged: (value) {
                                              setState(() {
                                                selectedId = value; // حفظ الـ ID المختار
                                                userIdController.text = value.toString(); // تحويل الـ int إلى String وتعيينه في TextField
                                              });
                                            },
                                          ),
                                        ],
                                      );
                                    }
                                    return Center(child: Text('No Data'));
                                  },
                                ),
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
                                    editTask(id: widget.id);
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
                                  child: _isLoading ? CircularProgressIndicator() : Text('Done'),
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
                                  child: Text('Cancel',style: TextStyle(color: Colors.white),
                                ),
                              )
                              ),
                                ],
                          ),
                        ),
                      ),

                    ),),
                  ),
                  child: Text('Edit Task',style: TextStyle(color: Colors.blue),),
                ),
              ),
              SizedBox(height: widget.screenHeight * 0.01),
              // زر الضغط الذي يظهر الدايلوج
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    cancelTask(id: widget.id);
                    setState(() {
                      _isLoading1 = true; // ابدأ التحميل
                    });

                    // محاكاة عملية التحميل لمدة 5 ثوانٍ
                    Future.delayed(Duration(seconds: 5), () {
                      // بعد انتهاء عملية التحميل
                      setState(() {
                        _isLoading1 = false; // إنهاء التحميل
                      });

                      // يمكنك إضافة الكود الخاص بإرسال البيانات بعد انتهاء التحميل هنا
                      print('Task created'); // مثال لطباعة رسالة في الكونسول
                    });
                  },
                  child: _isLoading1 ? CircularProgressIndicator() : Text('Cancel Task',style: TextStyle(color: Colors.blue),),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}