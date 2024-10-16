import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:visit_man/view/homeScreens/navigationBarItem.dart';
import 'package:visit_man/view/homeScreens/screens/exploreVisit/exploreVisit.dart';
import 'package:visit_man/view/homeScreens/screens/homePage/homePage.dart';
import 'package:visit_man/view/homeScreens/screens/profile/infoScreen.dart';
import 'package:visit_man/view/homeScreens/screens/taskPage/TaskPage.dart';
import 'package:visit_man/view/visitCard/screens/visitCard/VisitiCard.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> pages = [
    HomePage(),
    MyInfoPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return
      Scaffold(
        bottomNavigationBar: CurvedNavigationBar(
          index: _currentIndex,
          height: 80,
          color: Color(0xFFe8d2ae),
          animationDuration: Duration(milliseconds: 300),
          backgroundColor: Color(0xFF0f898c),
          items: [
            NavigationBarItem(icon: Icons.home, text: "Home"),
            NavigationBarItem(icon: Icons.location_city, text: "Visits"),
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

