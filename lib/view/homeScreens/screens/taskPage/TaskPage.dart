import 'package:flutter/material.dart';
import 'package:visit_man/view/homeScreens/screens/taskPage/widgets/taskItem.dart';

import '../../../../main.dart';
import '../../../../model/utils/sizes.dart';

class TaskPage extends StatelessWidget {
  const TaskPage({super.key});

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: ListView.separated(
          padding:  EdgeInsets.all(MoSizes.defaultSpace(context)),
          separatorBuilder: (context, index) => SizedBox(height: mq.height * 0.04,),
          itemCount: 3,
          itemBuilder: (context, index) => TaskItem(),
        ),
      ),
    );
  }
}
