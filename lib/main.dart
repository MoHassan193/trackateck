import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visit_man/model_view/cubits/infoCubit/myInfoCubit.dart';
import 'package:visit_man/model_view/cubits/loginCubit/login_cubit.dart';
import 'package:visit_man/model_view/cubits/mainCubitofWidget/behaviorStyleCubit/behaviorStyleCubit.dart';
import 'package:visit_man/model_view/cubits/mainCubitofWidget/cancelVisitReaonCubit/getcancelVisitCubit.dart';
import 'package:visit_man/model_view/cubits/mainCubitofWidget/getActivityType/getActivityCubit.dart';
import 'package:visit_man/model_view/cubits/mainCubitofWidget/partnerInfoCubit/partnerInfoCubit.dart';
import 'package:visit_man/model_view/cubits/postCubit/endVisitCubit/end_visit_cubit.dart';
import 'package:visit_man/model_view/cubits/postCubit/mapCubit/mapCubit.dart';
import 'package:visit_man/view/login/login.dart';
import 'package:visit_man/view/onBoarding/onBoardingScreen.dart';
import 'package:visit_man/model/utils/theme/theme.dart';
import 'package:intl/intl.dart';
import 'package:visit_man/view/visitCard/screens/NavBar.dart';

import 'fin_view/homeScreen/homeScreen.dart';
import 'model_view/cubits/mainCubitofWidget/getSpecialityCubit/getSpecialityCubit.dart';
import 'model_view/cubits/mainCubitofWidget/getSurveyCubit/getSurveyCubit.dart';
import 'model_view/cubits/mainCubitofWidget/getTerritoryCubit/getTerritoryCubit.dart';
import 'model_view/cubits/mainCubitofWidget/getTodayDailyCubit/get_today_daily_cubit.dart';
import 'model_view/cubits/mainCubitofWidget/getTodayVisitCubit/get_today_visit_cubit.dart';
import 'model_view/cubits/mainCubitofWidget/leaveBehindCubit/leaveBehindCubit.dart';
import 'model_view/cubits/mainCubitofWidget/monthlyPlanCubit/monthlyPlanCubit.dart';
import 'model_view/cubits/mainCubitofWidget/visitObjectiveCubit/visitObjectiveCubit.dart';
import 'view/visitCard/widgets/getUsers/cubit/getUsersCubit.dart';

late Size mq;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<Widget> _checkInitialScreen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Check if the user has previously logged in
    bool? keepMeSignedIn = prefs.getBool('keepMeSignedIn') ?? false;

    // Check if the app is being launched for the first time
    bool isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;

    if (isFirstLaunch) {
      // If it's the first launch, set it to false
      await prefs.setBool('isFirstLaunch', false);
      return OnBoardingScreen(); // Show onboarding screen
    } else if (keepMeSignedIn) {
      // If user chose to keep signed in, go to NavBar screen
      return NavBar();
    } else {
      // If user is not signed in or didn't choose to keep signed in, go to LoginScreen
      return LoginScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<LoginCubit>(create: (context) => LoginCubit()),
        BlocProvider<MapCubit>(create: (context) => MapCubit()),
        BlocProvider<EndVisitCubit>(create: (context) => EndVisitCubit()),
        BlocProvider<MyInfoCubit>(create: (context) => MyInfoCubit()),
        BlocProvider<BehavioralStylesCubit>(create: (context) => BehavioralStylesCubit()),
        BlocProvider<VisitCancelReasonCubit>(create: (context) => VisitCancelReasonCubit()),
        BlocProvider<ActivityTypeCubit>(create: (context) => ActivityTypeCubit()),
        BlocProvider<SpecialitiesCubit>(create: (context) => SpecialitiesCubit()),
        BlocProvider<SurveyCubit>(create: (context) => SurveyCubit()),
        BlocProvider<TerritoryCubit>(create: (context) => TerritoryCubit()),
        BlocProvider<TodayDailyCubit>(create: (context) => TodayDailyCubit()),
        BlocProvider<GetTodayVisitCubit>(create: (context) => GetTodayVisitCubit()),
        BlocProvider<LeaveBehindCubit>(create: (context) => LeaveBehindCubit()),
        BlocProvider<MonthlyPlanCubit>(create: (context) => MonthlyPlanCubit()),
        BlocProvider<VisitObjectiveCubit>(create: (context) => VisitObjectiveCubit()),
        BlocProvider<GetUsersCubit>(create: (context) => GetUsersCubit()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Visit Management',
        themeMode: ThemeMode.light,
        theme: TAppTheme.lightTheme,
        darkTheme: TAppTheme.lightTheme,
        home: FutureBuilder<Widget>(
          future: _checkInitialScreen(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator()); // Loading indicator while checking
            }
            return snapshot.data ?? LoginScreen(); // Default to LoginScreen
          },
        ),
      ),
    );
  }
}
