import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:visit_man/fin_view/homeScreen/homeScreen.dart';
import 'package:visit_man/fin_view/homeScreen/partners.dart';
import 'package:visit_man/view/homeScreens/navigationBarItem.dart';
import 'package:visit_man/view/homeScreens/screens/exploreVisit/exploreVisit.dart';
import 'package:visit_man/view/homeScreens/screens/homePage/homePage.dart';
import 'package:visit_man/view/homeScreens/screens/profile/infoScreen.dart';
import 'package:visit_man/view/homeScreens/screens/taskPage/TaskPage.dart';
import 'package:visit_man/view/visitCard/screens/visitCard/VisitiCard.dart';
import 'package:visit_man/view/visitCard/screens/welcomePage.dart';
import '../../../fin_view/dailyPlans/dailyPlan.dart';
import 'getTodayVisit/getTodayVisitScreen.dart';

class NavBar extends StatefulWidget {
  const NavBar({Key? key});

  @override
  State<NavBar> createState() => NavBarState();
}

class NavBarState extends State<NavBar> {
  int _currentIndex = 0;

  final List<Widget> pages = [
    FnHomeScreen(),
    TodayVisitsScreen(),
    FnPatnersScreen(),
    DailyPlanScreen(),
    MyInfoPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: CurvedNavigationBar(
          index: _currentIndex,
          height: 50,
          color: Color(0xFFe8d2ae),
          animationDuration: Duration(milliseconds: 300),
          backgroundColor: Color(0xFF0f898c),
          items: [
            NavigationBarItem(icon: Icons.home,text: "Home"),
            NavigationBarItem(icon: Icons.location_on_outlined,text: "Visits"),
            NavigationBarItem(icon: Icons.groups,text: "Contacts"),
            NavigationBarItem(icon: Icons.date_range,text: "Daily Plan"),
            NavigationBarItem(icon: Icons.person, text: "Profile"),
          ],
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
        ),
        body: pages[_currentIndex],
      );

  }
}
