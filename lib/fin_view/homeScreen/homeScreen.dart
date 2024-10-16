import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visit_man/fin_view/approval/approvalscreen.dart';
import 'package:visit_man/model_view/cubits/getapprovalCubit/approvalState.dart';
import 'package:visit_man/model_view/cubits/getapprovalCubit/getapproval.dart';
import 'package:visit_man/model_view/cubits/infoCubit/myInfoCubit.dart';
import 'package:visit_man/model_view/cubits/infoCubit/myInfoState.dart';
import 'package:visit_man/model_view/cubits/mainCubitofWidget/getActivityOnly/getActivityCubitOnly.dart';
import 'package:visit_man/model_view/cubits/mainCubitofWidget/getActivityOnly/getActivityStateOnly.dart';
import 'package:visit_man/model_view/cubits/mainCubitofWidget/getTodayVisitCubit/get_today_visit_cubit.dart';
import 'package:visit_man/model_view/cubits/mainCubitofWidget/getTodayVisitCubit/get_today_visit_state.dart';
import 'package:visit_man/model_view/cubits/mainCubitofWidget/monthlyPlanCubit/monthlyPlanCubit.dart';
import 'package:visit_man/model_view/cubits/mainCubitofWidget/monthlyPlanCubit/monthlyPlanState.dart';
import 'package:visit_man/view/visitCard/screens/getTodayVisit/TodayVisitDraftScreen.dart';
import 'package:visit_man/view/visitCard/screens/getTodayVisit/getTodayVisitScreen.dart';
import '../../model/userModel/userModel.dart';
import '../../model/utils/move.dart';
import '../../view/visitCard/widgets/getActivityOnly/getActivityPage.dart';


class FnHomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 20),
              CircleAvatar(
                radius: 55,
                backgroundImage: AssetImage('assets/images/logo.png'),
              ),
              SizedBox(height: 15,),
              FutureBuilder<UserModel>(
                future: _getUserModelFromPrefs(), // جلب بيانات المستخدم من SharedPreferences
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (snapshot.hasData) {
                    final userModel = snapshot.data!;
                    return Column(
                      children: [
                        BlocProvider(
                          create: (context) => GetTodayVisitCubit()
                            ..fetchTodayVisits(userId: userModel.uid.toString()), // استخدام userId من الـ UserModel
                          child: BlocBuilder<GetTodayVisitCubit, GetTodayVisitState>(
                            builder: (context, state) {
                              if (state is GetTodayVisitLoading) {
                                return Center(child: CircularProgressIndicator());
                              } else if (state is GetTodayVisitSuccess) {
                                final numberofVisits = state.visits.length;
                                final numberOfDraftVisits = state.visits.where((visit) => visit['state'] == "draft").length;
                                final numberOfdoneVisits = state.visits.where((visit) => visit['state'] == "done").length;

                                return GestureDetector(
                                  onTap: (){
                                    Move.move(context,TodayVisitDraftScreen());
                                  },
                                  child: _buildInfoCard('Today\'s Planned Visits',"$numberOfDraftVisits/$numberofVisits", context,Icons.place)
                                );
                              } else if (state is GetTodayVisitError) {
                                return Center(child: Text('No Data Found'));
                              } else {
                                return Center(child: Text('No data available'));
                              }
                            },
                          ),
                        ),
                        BlocProvider(
                          create: (context) => ActivityCubit()..fetchActivities(userid: userModel.uid.toString()),
                          child: BlocBuilder<ActivityCubit, ActivityState>(
                            builder: (context, state) {
                              if (state is ActivityLoading) {
                                return Center(child: CircularProgressIndicator());
                              } else if (state is ActivityLoaded) {
                                if(state.activities.length == 0){
                                  return _buildInfoCard("Your Tasks","0", context,Icons.calendar_month);
                                }
                                return GestureDetector(
                                    onTap: () => Move.move(context, ActivityPage(),),
                                    child: _buildInfoCard("Your Tasks",state.activities.length.toString() ?? "0", context,Icons.calendar_month));
                              } else if (state is ActivityError) {
                                print(state.message.toString());
                                return  _buildInfoCard("Your Tasks","0", context,Icons.calendar_month);
                              }
                              return Center(child: Text('No data available', style: TextStyle(color: Colors.grey)));
                            },
                          ),
                        ),
                        BlocProvider(
                          create: (context) => MyInfoCubit()..fetchMyInfo(userId: userModel.uid.toString()),
                          child: BlocBuilder<MyInfoCubit, MyInfoState>(
                            builder: (context, state) {
                              print(userModel.uid.toString());
                              if (state is MyInfoLoading) {
                                return Center(child: CircularProgressIndicator());
                              } else if (state is MyInfoError) {
                                return Center(child: Text(state.message));
                              } else if (state is MyInfoLoaded) {
                                return _buildInfoCard("Your Rank", state.data['rank'].toString(), context,Icons.rate_review_outlined);
                              } else {
                                return Center(child: Text('لم يتم جلب البيانات بعد'));
                              }
                            },
                          ),
                        ),
                        BlocProvider(
                          create: (context) => ApprovalCubit()..fetchApprovals(userId: userModel.uid.toString()),
                          child: BlocBuilder<ApprovalCubit, ApprovalState>(
                            builder: (context, state) {
                              if (state is ApprovalLoading) {
                                return Center(child: CircularProgressIndicator());
                              } else if (state is ApprovalLoaded) {
                                final approvalData = state.approvals;
                                return GestureDetector(
                                    onTap: (){
                                      Move.move(context, ApprovalScreen(
                                        approvalData: approvalData,
                                      ));
                                    },
                                    child: _buildInfoCard(
                                        "Approvals", state.approvals.length.toString(), context,Icons.approval));
                              } else if (state is MonthlyPlanError) {
                                return Center(child: Text('No Data Found'));
                              }
                              return Center(child: Text('No Data'));
                            },
                          ),
                        ),
                      ],
                    );
                  }
                  return Center(child: Text('No data available'));
                },
              ),

            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, BuildContext context,IconData icon) {
    // الحصول على عرض وارتفاع الشاشة باستخدام MediaQuery
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: screenHeight * 0.02, // ضبط التباعد بناءً على ارتفاع الشاشة
        horizontal: screenWidth * 0.05, // ضبط التباعد بناءً على عرض الشاشة
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white, // لون الخلفية
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.cyan, width: 2),
        ),
        // استخدام MediaQuery لتكبير الحجم بناءً على حجم الشاشة
        height: screenHeight * 0.2, // جعل الارتفاع 15% من ارتفاع الشاشة
        width: screenWidth * 0.9, // جعل العرض 90% من عرض الشاشة
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,

                children: [
                  Icon(icon,size:25,color: Colors.cyan,),
                  SizedBox(width: 5,),
                  Text(
                    textAlign: TextAlign.center,
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontSize: screenHeight * 0.023, // تكبير النص بناءً على حجم الشاشة
                    ),
                  ),

                ],
              ),
              SizedBox(height: screenHeight * 0.03), // ضبط المسافة بناءً على حجم الشاشة
              Text(
                value,
                style: TextStyle(
                  color: Colors.cyan,
                  fontSize: screenHeight * 0.04, // تكبير النص بناءً على حجم الشاشة
                ),
              ),
            ],
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
