import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:visit_man/view/postsScreens/rechVisit/rechPage.dart';


import '../../../model/commonWidget/elevatedButton/elevatedButtonCustom.dart';
import '../../../model/utils/move.dart';
import '../../../model/utils/sizes.dart';
import '../../postsScreens/createActivity/createActivity.dart';
import '../../postsScreens/updateVisitScreen/updateVisit.dart';

class PostsMethodsPage extends StatefulWidget {
  const PostsMethodsPage({super.key});

  @override
  State<PostsMethodsPage> createState() => _PostsMethodsPageState();
}

class _PostsMethodsPageState extends State<PostsMethodsPage> {


  @override
  Widget build(BuildContext context) {


    final List<String> buttonTexts = [
      "Create Activity",
      "Update Visit",
      "Rechedule Visit",
    ];

    final List<Widget> pageDestinations = [
      CreateActivityPage(),
      UpdateVisitPage(),
      // You can handle the case where `yourLocation` is empty if needed
      RescheduleVisitPage(),

    ];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
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
          ],
        ),
      ),
    );
  }
}
