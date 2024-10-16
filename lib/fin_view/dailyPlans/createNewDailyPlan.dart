import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visit_man/model/utils/sizes.dart';
import '../../model/dialToast.dart';
import '../../model/userModel/userModel.dart';
import '../../model_view/cubits/mainCubitofWidget/getTerritoryCubit/getTerritoryCubit.dart';
import '../../model_view/cubits/mainCubitofWidget/getTerritoryCubit/getTerritoryState.dart';
import '../../model_view/cubits/mainCubitofWidget/monthlyPlanCubit/monthlyPlanCubit.dart';
import '../../model_view/cubits/mainCubitofWidget/monthlyPlanCubit/monthlyPlanState.dart';
import 'package:dropdown_search/dropdown_search.dart';

class CreateNewDailyPlan extends StatefulWidget {
  const CreateNewDailyPlan({super.key});

  @override
  State<CreateNewDailyPlan> createState() => _CreateNewDailyPlanState();
}

class _CreateNewDailyPlanState extends State<CreateNewDailyPlan> {
  final TextEditingController _monthlyPlanIdController = TextEditingController();
  final TextEditingController _attendanceController = TextEditingController();
  List<int> _territoryIds = [];
  final List<String> _attendanceOptions = ['office', 'field', 'dayoff', 'halfday'];
  DateTime? selectedDate;

  late UserModel _userModel; // إضافة UserModel

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
  Future<List<int>> getSavedObjectiveIds() async {
    final prefs = await SharedPreferences.getInstance();
    final savedObjectiveIds = prefs.getStringList('savedObjectiveIds') ?? [];
    return savedObjectiveIds.map((id) => int.parse(id)).toList(); // تحويل القائمة إلى قائمة أعداد
  }
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }
  Future<void> createDailyPlan()async{
    await loadUserModel(); // تأكد من تحميل بيانات المستخدم قبل الجلب
    final prefs = await SharedPreferences.getInstance();
    final String? url = prefs.getString('storedUrl');

    if (url == null || url.isEmpty) {
      return;
    }

    final request = {
      'month_plan_id' : int.tryParse(_monthlyPlanIdController.text),
      'territory_ids' : '[${_territoryIds.join(',')}]',
      'attendance' : _attendanceController.text,
      'date' : DateFormat('yyyy-MM-dd').format(selectedDate!),

    };
    final dio = Dio();
    final response = await dio.put('$url/api/create_daily',
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          headers: {
            'token': _userModel.accessToken, // استخدام رمز التحقق
          },
        ),
        data: request);
    if(response.statusCode == 200){
      final data = response.data['data'];
      Navigator.pop(context);
      DialToast.showToast("Daily Plan Created Successfuly", Colors.green);
    }else {
      print(response.data);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Create Daily Plan"),
      ),
  body: FutureBuilder(
    future: _getUserModelFromPrefs(),
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        return Center(child: Text('Error: ${snapshot.error}'));
      } else if (snapshot.hasData) {
        final userModel = snapshot.data!;
        return Padding(
          padding:  EdgeInsets.all(MoSizes.md(context)),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 40,),
                _buildMonthlyPlanDropdown(userModel.uid.toString()),
                SizedBox(height: 10,),
                _buildTerritoryDropdown(),
                SizedBox(height: 10,),
                _buildAttendenceDropDown(),
                SizedBox(height: 10,),
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
                SizedBox(height: 10,),
                SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(onPressed: (){createDailyPlan();}, child: Text("Create Daily Plan"))),
                SizedBox(height: 10,),
              ],
            ),
          ),
        );
      }else {
        return Center(child: Text("No Data Found"),);
      }
    }
)
    );
  }

  Widget _buildMonthlyPlanDropdown(String userId) {
    return BlocProvider(
      create: (context) => MonthlyPlanCubit()..fetchMonthlyPlans(userId: userId),
      child: BlocBuilder<MonthlyPlanCubit, MonthlyPlanState>(
        builder: (context, state) {
          if (state is MonthlyPlanLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (state is MonthlyPlanLoaded) {
            DateTime today = DateTime.now();
            String formattedDate = DateFormat('yyyy-MM-dd').format(today);

            List<Map<String, dynamic>> monthlyPlans = (state.monthlyPlans as List<dynamic>)
                .cast<Map<String, dynamic>>();

            // Filter monthly plans by date
            List<Map<String, dynamic>> filteredPlans = monthlyPlans.where((plan) {
              return (formattedDate.compareTo(plan['start_date']) >= 0) &&
                  (formattedDate.compareTo(plan['end_date']) <= 0);
            }).toList();

            return DropdownButtonFormField<int>(
              decoration: InputDecoration(labelText: 'Select Monthly Plan'),
              value: int.tryParse(_monthlyPlanIdController.text),
              items: filteredPlans.map((plan) {
                return DropdownMenuItem<int>(
                  value: plan['id'],
                  child: Text(plan['title']),
                );
              }).toList(),
              onChanged: (int? newValue) {
                setState(() {
                  _monthlyPlanIdController.text = newValue.toString();
                });
              },
            );
          } else if (state is MonthlyPlanError) {
            return Center(child: Text('No Data Found'));
          }
          return Center(child: Text('No Data'));
        },
      ),
    );
  }

  // تأكد من تعريف _territoryIds في مكان ما في الكلاس

  final GlobalKey<DropdownSearchState<int>> dropDownKey = GlobalKey();

  Widget _buildTerritoryDropdown() {
    return BlocProvider(
      create: (context) => TerritoryCubit()..fetchTerritories(),
      child: BlocBuilder<TerritoryCubit, TerritoryState>(
        builder: (context, state) {
          if (state is TerritoryLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (state is TerritoryLoaded) {
            return Column(
              children: [
                DropdownButtonFormField<int>(
                  decoration: InputDecoration(labelText: 'Select Territory'),
                  value: _territoryIds.isNotEmpty ? _territoryIds.first : null,
                  onChanged: (int? newValue) {
                    setState(() {
                      if (newValue != null && !_territoryIds.contains(newValue)) {
                        _territoryIds.add(newValue);
                      }
                    });
                  },
                  items: state.territories.map((territory) {
                    return DropdownMenuItem<int>(
                      value: territory.id,
                      child: Text(territory.name),
                    );
                  }).toList(),
                ),
                // قائمة العناصر المحددة
                Column(
                  children: _territoryIds.map((id) {
                    final territory = state.territories.firstWhere((t) => t.id == id);
                    return ListTile(
                      title: Text(territory.name),
                      trailing: IconButton(
                        icon: Icon(Icons.remove_circle),
                        onPressed: () {
                          setState(() {
                            _territoryIds.remove(id);
                          });
                        },
                      ),
                    );
                  }).toList(),
                ),
              ],
            );
          } else if (state is TerritoryError) {
            return Center(child: Text('No Data Found'));
          }
          return Center(child: Text('No data available'));
        },
      ),
    );
  }

  Widget _buildAttendenceDropDown(){
    return  DropdownButtonFormField<String>(
      decoration: InputDecoration(labelText: 'Attendance'),
      value: _attendanceController.text.isNotEmpty ? _attendanceController.text : null,
      onChanged: (String? newValue) {
        setState(() {
          if (newValue != null) {
            _attendanceController.text = newValue; // حفظ القيمة المختارة في الcontroller
          }
        });
      },
      items: _attendanceOptions.map((option) {
        return DropdownMenuItem<String>(
          value: option,
          child: Text(option),
        );
      }).toList(),
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
