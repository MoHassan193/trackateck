import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:visit_man/model/utils/images.dart';
import 'package:visit_man/view/onBoarding/widgets/modelView.dart';

import '../login/login.dart';

class OnBoardingScreen extends StatelessWidget {
  OnBoardingScreen({super.key});

  final List<PageViewModel> pages = [
    PageViewModel(
      title: "",
      bodyWidget: Builder(
        builder: (context) {
          var screenHeight = MediaQuery.of(context).size.height;
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: screenHeight * 0.05, // Reduced size
                ),
                CircleAvatar(
                  backgroundImage: AssetImage("assets/images/logo.png"),
                  radius: screenHeight * 0.15, // Reduced size
                ),
                SizedBox(
                  height: screenHeight * 0.05, // Reduced size
                ),
              ],
            ),
          );
        },
      ),
    ),
    PageViewModel(
      title: "",
      bodyWidget: Builder(
        builder: (context) {
          var screenHeight = MediaQuery.of(context).size.height;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ModelOnBoarding(
                image: AppImages.OnBoardingImage1,
                title: "Win is a lifestyle",
                text: "Try VMS and do your best, it will help you to achieve more",
              ),
              SizedBox(height: screenHeight * 0.03), // Adjusted size
            ],
          );
        },
      ),
    ),
    PageViewModel(
      title: "",
      bodyWidget: Builder(
        builder: (context) {
          var screenHeight = MediaQuery.of(context).size.height;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              ModelOnBoarding(
                image: AppImages.OnBoardingImage2,
                title: "Planning is the best strategy",
                text: "With VMS execute all your visits accurately",
              ),
              SizedBox(height: screenHeight * 0.03), // Adjusted size
            ],
          );
        },
      ),
    ),
    PageViewModel(
      title: "",
      bodyWidget: Builder(
        builder: (context) {
          var screenHeight = MediaQuery.of(context).size.height;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              ModelOnBoarding(
                image: AppImages.OnBoardingImage3,
                title: "Check your rank always",
                text: "Be on top",
              ),
              SizedBox(height: screenHeight * 0.03), // Adjusted size
            ],
          );
        },
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return IntroductionScreen(
      dotsDecorator: DotsDecorator(activeColor: Colors.blue),
      controlsPadding: const EdgeInsets.all(0),
      pages: pages,
      onDone: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => LoginScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              var begin = Offset(1.0, 0.0);
              var end = Offset.zero;
              var curve = Curves.ease;

              var tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

              return SlideTransition(
                position: animation.drive(tween),
                child: child,
              );
            },
          ),
        );
      },
      showSkipButton: false,
      showNextButton: false,
      done: Text(
        "done",
        style: TextStyle(color: Colors.blue),
      ),
    );
  }
}
