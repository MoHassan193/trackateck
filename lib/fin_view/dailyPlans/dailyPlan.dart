import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visit_man/fin_view/dailyPlans/createNewDailyPlan.dart';
import 'package:visit_man/model/utils/move.dart';
import 'package:visit_man/model/utils/sizes.dart';
import 'package:visit_man/model_view/cubits/mainCubitofWidget/getTodayDailyCubit/get_today_daily_state.dart';
import 'package:visit_man/view/visitCard/screens/visitCard/VisitiCard.dart';

import '../../model/dialToast.dart';
import '../../model/userModel/userModel.dart';
import '../../model_view/cubits/mainCubitofWidget/getTerritoryCubit/getTerritoryCubit.dart';
import '../../model_view/cubits/mainCubitofWidget/getTerritoryCubit/getTerritoryState.dart';
import '../../model_view/cubits/mainCubitofWidget/getTodayDailyCubit/get_today_daily_cubit.dart';
import '../../model_view/cubits/mainCubitofWidget/monthlyPlanCubit/monthlyPlanCubit.dart';
import '../../model_view/cubits/mainCubitofWidget/monthlyPlanCubit/monthlyPlanState.dart';
import 'createMonthlyPlan.dart';

class DailyPlanScreen extends StatefulWidget {
  const DailyPlanScreen({super.key});

  @override
  State<DailyPlanScreen> createState() => _DailyPlanScreenState();
}

class _DailyPlanScreenState extends State<DailyPlanScreen> {
  final TextEditingController _monthlyPlanController = TextEditingController();
  final TextEditingController _dailyPlanIdController = TextEditingController();
  bool _isMonthlyPlanSelected = false; // Track if a monthly plan is selected

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () => Move.move(context, CreateNewDailyPlan()),
            icon: Icon(Icons.add, color: Colors.white),
          ),
          SizedBox(height: 10),
        ],
      ),
      body: FutureBuilder(
          future: _getUserModelFromPrefs(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (snapshot.hasData) {
              final userModel = snapshot.data!;
              return RefreshIndicator(
                onRefresh: ()async => await _getUserModelFromPrefs(),
                child: Padding(
                  padding:  EdgeInsets.all(MoSizes.md(context)),
                  child: Column(
                    children: [
                      OutlinedButton(
                          onPressed: () => Move.move(context, CreateMonthlyPlan()),
                          child: Text("Create Monthly Plan", style: TextStyle(color: Colors.blue))),
                      SizedBox(height: 10),
                      _buildMonthlyPlanDropdown(userModel.uid.toString()),
                      SizedBox(height: 20),
                      if (_isMonthlyPlanSelected) // Conditionally show the daily plan list
                        Expanded(child: _buildDailyPlanList(_monthlyPlanController.text))
                    ],
                  ),
                ),
              );
            } else {
              return Center(child: Text("No Data Found"));
            }
          }),
    );
  }

  TextEditingController _monthlyPlanSearchController = TextEditingController();

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

            // Apply search filter based on the search query
            String searchQuery = _monthlyPlanSearchController.text.toLowerCase();
            List<Map<String, dynamic>> searchedPlans = filteredPlans.where((plan) {
              return plan['title'].toLowerCase().contains(searchQuery);
            }).toList();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10),
                CenterTitleWidget(title: 'Today\'s Date: $formattedDate'),
                SizedBox(height: 10),
                DropdownButtonFormField<int>(
                  decoration: InputDecoration(labelText: 'Select Monthly Plan'),
                  value: int.tryParse(_monthlyPlanController.text),
                  items: searchedPlans.map((plan) {
                    return DropdownMenuItem<int>(
                      value: plan['id'],
                      child: Text(plan['title']),
                    );
                  }).toList(),
                  onChanged: (int? newValue) {
                    setState(() {
                      _monthlyPlanController.text = newValue.toString();
                      _isMonthlyPlanSelected = newValue != null;
                      if (_isMonthlyPlanSelected) {
                        _buildDailyPlanList(_monthlyPlanController.text); // تحديث قائمة الخطط اليومية
                      }
                    });
                  },
                ),
              ],
            );
          } else if (state is MonthlyPlanError) {
            return Center(child: Text('No Data Found'));
          }
          return Center(child: Text('No Data'));
        },
      ),
    );
  }

  TextEditingController _dailyPlanSearchController = TextEditingController();

  Widget _buildDailyPlanList(String id) {
    return BlocProvider(
      create: (context) => TodayDailyCubit()..fetchTodayDailies(userId: id),
      child: BlocBuilder<TodayDailyCubit, TodayDailyState>(
        builder: (context, state) {
          if (state is TodayDailyLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (state is TodayDailyLoaded) {
            DateTime today = DateTime.now();
            String formattedDate = DateFormat('yyyy-MM-dd').format(today);
            DateTime formattedDateTime = DateTime.parse(formattedDate);

            List<Map<String, dynamic>> todayDailies = (state.todayDailies as List<dynamic>)
                .cast<Map<String, dynamic>>();

            // Filter daily plans by date
            List<Map<String, dynamic>> filteredDailies = todayDailies.where((daily) {
              DateTime dailyDate = DateTime.parse(daily['date']);
              return dailyDate.isAtSameMomentAs(formattedDateTime) || dailyDate.isAfter(formattedDateTime);
            }).toList();

            // Apply search filter based on the search query
            String searchQuery = _dailyPlanSearchController.text.toLowerCase();
            List<Map<String, dynamic>> searchedDailies = filteredDailies.where((daily) {
              return daily['title'].toLowerCase().contains(searchQuery) ||
                  daily['user_name'].toLowerCase().contains(searchQuery);
            }).toList();

            return Column(
              children: [
                TextField(
                  controller: _dailyPlanSearchController,
                  decoration: InputDecoration(
                    labelText: 'Search Daily Plans',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (value) {
                    // Trigger UI rebuild to apply search filter
                    setState(() {});
                  },
                ),
                Expanded(
                  child: searchedDailies.isNotEmpty
                      ? ListView.builder(
                    itemCount: searchedDailies.length,
                    itemBuilder: (context, index) {
                      final daily = searchedDailies[index];
                      return Padding(
                        padding: const EdgeInsets.all(12),
                        child: Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.cyan, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.cyan.withOpacity(0.7),
                                spreadRadius: 3,
                                blurRadius: 15,
                                offset: Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              TitelDailyWidget(title: "User Name", answer: daily['user_name']),
                              TitelDailyWidget(title: "Title", answer: "${daily['title']}"),
                              TitelDailyWidget(title: "Date", answer: daily['date']),
                              TitelDailyWidget(title: "Month Plan", answer: daily['month_plan_name']),
                              Container(
                                  padding: EdgeInsets.all(10), // Padding for the entire container
                                  decoration: BoxDecoration(
                                    color: Colors.white, // Background color
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: Colors.cyan, width: 2),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.cyan.withOpacity(0.7), // Shadow color
                                        spreadRadius: 3, // Spread radius
                                        blurRadius: 15, // Blur radius
                                        offset: Offset(0, 5), // Offset for shadow
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: daily['territories'].map<Widget>((territory) {
                                      return Padding(
                                        padding: const EdgeInsets.only(bottom: 5.0), // Space between each territory
                                        child: Text(
                                          territory['name'],
                                          style: TextStyle(
                                            color: Colors.blue,
                                            fontSize: 12,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),


                            ],
                          ),
                        ),
                      );
                    },
                  )
                      : Center(child: Text('No data available for today or future dates')),
                ),
              ],
            );
          } else if (state is TodayDailyError) {
            return Center(child: Text('No Data Found'));
          }
          return Center(child: Text('No data available'));
        },
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

class TitelDailyWidget extends StatelessWidget {
  const TitelDailyWidget({
    super.key, required this.title, required this.answer,
  });

  final String title;
  final String answer;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(1),
      child: Container(
        padding: EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: Colors.white, // لون الخلفية
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.cyan, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.cyan.withOpacity(0.7), // لون الظل
              spreadRadius: 3, // انتشار الظل
              blurRadius: 15, // ضبابية الظل
              offset: Offset(0, 5), // تعويض الظل
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              answer,
              style: TextStyle(
                color: Colors.blue,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}