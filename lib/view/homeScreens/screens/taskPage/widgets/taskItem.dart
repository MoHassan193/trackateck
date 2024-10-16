import 'package:flutter/material.dart';
import 'package:visit_man/main.dart';

import '../../../../../model/utils/sizes.dart';

class TaskItem extends StatelessWidget {
  const TaskItem({super.key,  this.taskName,  this.taskDate,  this.taskDescription,  this.taskType});
final String? taskName;
final String? taskDate;
final String? taskDescription;
final String? taskType;
  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.white
        ),
      ),
      padding: EdgeInsets.all(MoSizes.md(context)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(taskName ?? 'Task Name', style: Theme.of(context).textTheme.titleLarge,),
              SizedBox(width: mq.width * 0.02,),
              Text(taskDate ?? 'Task Date', style: Theme.of(context).textTheme.bodyLarge!.apply(color: Colors.green),),
            ],
          ),
          SizedBox(height: mq.height * 0.01,),
          Divider(color: Colors.white,thickness: 1,),
          SizedBox(height: mq.height * 0.01,),
          Text(taskDescription ?? "Description", style: Theme.of(context).textTheme.bodyLarge,),
          SizedBox(height: mq.height * 0.05,),
          Row(
            children: [
              Icon(Icons.call, color: Colors.green,size: mq.height * 0.03,),
              SizedBox(width: mq.width * 0.02,),
              Text(taskType ?? 'Type', style: Theme.of(context).textTheme.bodyLarge!.apply(color: Colors.grey),),
            ],
          ),
        ],
      ),
    );
  }
}
