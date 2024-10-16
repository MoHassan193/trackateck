import 'package:flutter/material.dart';
import 'package:visit_man/model/commonWidget/elevatedButton/elevatedButtonCustom.dart';
import 'package:visit_man/model/utils/move.dart';
import 'package:visit_man/model/utils/sizes.dart';
import 'package:visit_man/view/homeScreens/screens/homePage/widgets/showResult.dart';

import '../../postsMethods/postsMethods.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Define the lists of names and page destinations
    final List<String> buttonTexts = [
      "Posts Methods"
      // "Today's Daily",
      // "Today's Visits",
      // "Activity Types",
      // "Leave Behinds",
      // "Visit Objectives",
      // "Products",
      // "Monthly Plans",
      // "Territories",
      // "Surveys",
      // "Activities",
      // "Behavioral Styles",
      // "Segmentations",
      // "Specialities",
      // "Classification",
      // "Partner Info",
      // "Visit Cancel Reasons",
    ];

    final List<Widget> pageDestinations = [
      PostsMethodsPage(),
      // GetTodayDailyPage(),
      // GetTodayVisitPage(),
      // GetActivityTypePage(),
      // LeaveBehindPage(),
      // VisitObjectivePage(),
      // ProductPage(),
      // MonthlyPlanPage(),
      // GetTerritoryPage(),
      // SurveyPage(),
      // ActivityPage(),
      // BehavioralStylesPage(),
      // SegmentationPage(),
      // SpecialitiesPage(),
      // GetClassificationPage(),
      // PartnerInfoPage(),
      // VisitCancelReasonPage(),

    ];

    return Scaffold(
      body: SafeArea(
        child: ListView.separated(
          padding: EdgeInsets.all(MoSizes.defaultSpace(context)),
          itemCount: buttonTexts.length,
          separatorBuilder: (context, index) => SizedBox(height: MoSizes.spaceBtwItems(context)),
          itemBuilder: (context, index) {
            return CustomButton(
              onPressed: () {
                Move.move(context, pageDestinations[index]);
              },
              text: buttonTexts[index],
            );
          },
        ),
      ),
    );
  }
}
