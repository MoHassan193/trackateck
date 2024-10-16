import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visit_man/model/userModel/userModel.dart';
import 'package:visit_man/model/utils/sizes.dart';
import 'package:visit_man/model_view/cubits/mainCubitofWidget/getActivityOnly/getActivityCubitOnly.dart';
import 'package:visit_man/model_view/cubits/mainCubitofWidget/getActivityOnly/getActivityStateOnly.dart';
import 'package:visit_man/model_view/cubits/mainCubitofWidget/getActivityType/getActivityState.dart';
import 'package:visit_man/view/visitCard/widgets/getActivityOnly/widget/createNewTask.dart';
import 'package:visit_man/view/visitCard/widgets/getActivityOnly/widget/taskDetailPage.dart';
import 'package:visit_man/view/visitCard/widgets/getUsers/cubit/getUsersState.dart';

import '../../../../model/dialToast.dart';
import '../../../../model/utils/move.dart';
import '../../../../model_view/cubits/mainCubitofWidget/getActivityType/getActivityCubit.dart';
import '../getUsers/cubit/getUsersCubit.dart';

class ActivityPage extends StatelessWidget {
  const ActivityPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _getUserModelFromPrefs(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          final userModel = snapshot.data!;
          return BlocProvider(
            create: (context) => ActivityCubit()..fetchActivities(userid: userModel.uid.toString()),
            child: BlocBuilder<ActivityCubit, ActivityState>(
              builder: (context, state) {
                if (state is ActivityLoading) {
                  return Center(child: CircularProgressIndicator());
                } else if (state is ActivityLoaded) {
                  final tasks = state.activities;
                  final todayTasks = [];
                  final overcomeTasks = [];
                  final lastTasks = [];

                  final today = DateTime.now();
                  final dateFormat = DateFormat('yyyy-MM-dd');

                  bool isSameDay(DateTime date1, DateTime date2) {
                    return date1.year == date2.year &&
                        date1.month == date2.month &&
                        date1.day == date2.day;
                  }

                  tasks.forEach((task) {
                    final taskDate = dateFormat.parse(task['date_deadline']);
                    if (isSameDay(taskDate, today)) {
                      todayTasks.add(task);
                    } else if (taskDate.isAfter(today)) {
                      overcomeTasks.add(task);
                    } else {
                      lastTasks.add(task);
                    }
                  });

                  return DefaultTabController(
                    length: 3,
                    child: Scaffold(
                      appBar: AppBar(
                        actions: [
                          IconButton(
                              onPressed: () => Move.move(context, CreateNewTask()),
                              icon: Icon(Icons.add, color: Colors.white, size: 30)),
                          SizedBox(width: 10),
                        ],
                        title: Text('Tasks'),
                        centerTitle: true,
                        bottom: TabBar(
                          labelStyle: TextStyle(color: Colors.white),
                          tabs: [
                            Tab(text: 'Today'),
                            Tab(text: 'Upcoming'),
                            Tab(text: 'Overdue'),
                          ],
                        ),
                      ),
                      body: TabBarView(
                        children: [
                          buildTaskList(todayTasks, 'No tasks today', context),
                          buildTaskList(overcomeTasks, 'No tasks upcoming', context),
                          buildTaskList(lastTasks, 'No tasks overdue', context),
                        ],
                      ),
                    ),
                  );
                } else if (state is ActivityError) {
                  return Center(child: Text(state.message, style: TextStyle(color: Colors.red)));
                }
                return Center(child: Text('لا توجد بيانات متاحة', style: TextStyle(color: Colors.grey)));
              },
            ),
          );
        }
        return Center(child: Text('No data available', style: TextStyle(color: Colors.grey)));
      },
    );
  }

  Widget buildTaskList(List tasks, String emptyMessage, BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;

    if (tasks.isEmpty) {
      return Center(child: Text(emptyMessage));
    }

    return RefreshIndicator(
      onRefresh: () async {
        // إعادة تحميل النشاطات عند السحب لتحديث البيانات
        final userModel = await _getUserModelFromPrefs();
        context.read<ActivityCubit>().fetchActivities(userid: userModel.uid.toString());
      },
      child: ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final task = tasks[index];
          final resname = task['res_name'];
          final date = task['date_deadline'];
          final activityTypeId = task['activity_type_id'];
          final summary = task['summary'];
          final user = task['user_id'];
          final resModel = task['res_model'];
          final note = task['note'];
          final id = task['id'].toString();
          return GestureDetector(
            onTap: () => showDialog(
              context: context,
              builder: (context) => TaskDetailsPage(
                id: id,
                screenHeight: screenHeight,
                resname: resname,
                date: date,
                summary: summary,
                activityTypeId: activityTypeId,
                user: user,
                note: note,
                resModel: resModel,
              ),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                vertical: screenHeight * 0.02,
                horizontal: screenWidth * 0.05,
              ),
              child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.cyan, width: 2),
                ),
                height: screenHeight * 0.22,
                width: screenWidth * 0.9,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          resname,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: screenHeight * 0.021,
                          ),
                        ),
                        Text(
                          date,
                          style: TextStyle(
                            color: Colors.cyan,
                            fontSize: screenHeight * 0.016,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    Divider(color: Colors.cyan, thickness: 1),
                    SizedBox(height: screenHeight * 0.01),
                    Row(
                      children: [
                        Text(
                          summary,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: screenHeight * 0.021,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.03),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(Icons.done, color: Colors.cyan, size: 30),
                        SizedBox(width: 10),
                        Text(
                          activityTypeId,
                          style: TextStyle(
                            color: Colors.cyan,
                            fontSize: screenHeight * 0.016,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
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
