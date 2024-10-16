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
import 'package:dropdown_search/dropdown_search.dart';

class CreateDailyDialog extends StatefulWidget {
  const CreateDailyDialog({super.key, required this.monthlyPlanId});
final String monthlyPlanId;

  @override
  State<CreateDailyDialog> createState() => _CreateDailyDialogState();
}

class _CreateDailyDialogState extends State<CreateDailyDialog> {
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
      'month_plan_id' : int.tryParse(widget.monthlyPlanId),
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
      final newPlanId = data['id'];
      final name = data['name'];
      Navigator.pop(context);
      DialToast.showToast("Daily Plan Created Successfuly\n$name", Colors.green);
    }else {
      print(response.data);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:  EdgeInsets.all(4),
      child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 40,),
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
                child: OutlinedButton(onPressed: (){
                  createDailyPlan();
                  }, child: Text("Create Daily Plan"))),
            SizedBox(height: 10,),
          ],
        ),
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
                  decoration: InputDecoration(labelText: ' Territory'),
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
                      child: Text(territory.name,style: TextStyle(fontSize: 9),),
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
