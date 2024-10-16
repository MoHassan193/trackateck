import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../../../model/userModel/userModel.dart';
import '../../../model_view/cubits/mainCubitofWidget/getTodayDailyCubit/get_today_daily_cubit.dart';
import '../../../model_view/cubits/mainCubitofWidget/getTodayDailyCubit/get_today_daily_state.dart';
import 'items/TodayDailyItem.dart';

class GetTodayDailyPage extends StatelessWidget {
  const GetTodayDailyPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Today\'s Daily'),
      ),
      body: FutureBuilder<UserModel>(
        future: _getUserModelFromPrefs(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final userModel = snapshot.data!;
            return BlocProvider(
              create: (context) => TodayDailyCubit()..fetchTodayDailies(),
              child: BlocBuilder<TodayDailyCubit, TodayDailyState>(
                builder: (context, state) {
                  if (state is TodayDailyLoading) {
                    return Center(child: CircularProgressIndicator());
                  } else if (state is TodayDailyLoaded) {
                    return ListView.builder(
                      itemCount: state.todayDailies.length,
                      itemBuilder: (context, index) {
                        final daily = state.todayDailies[index];
                        final dailyId = daily.id;
                         saveDailyPlan(dailyId);
                        return TodayDailyItem(daily: daily);
                      },
                    );
                  } else if (state is TodayDailyError) {
                    print('Error: ${state.message}');
                    return Center(child: Text('No Data Found'));
                  }
                  return Container();
                },
              ),
            );
          }
          return Center(child: Text('No Data'));
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

  Future<void> saveDailyPlan(int id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('dailyPlanId', id); // حفظ المعرف في SharedPreferences
  }
}
