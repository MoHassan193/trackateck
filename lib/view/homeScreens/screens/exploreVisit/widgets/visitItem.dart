import 'package:flutter/material.dart';
import 'package:visit_man/main.dart';

import '../../../../../model/utils/sizes.dart';

class VisitItem extends StatelessWidget {
  const VisitItem({super.key,  this.doctorName,  this.visitDrDate,  this.visitDrDescription,  this.visitDrType});
  final String? doctorName;
  final String? visitDrDate;
  final String? visitDrDescription;
  final String? visitDrType;

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
              Text(doctorName ?? 'Doctor Name', style: Theme.of(context).textTheme.titleLarge,),
              SizedBox(width: mq.width * 0.02,),
              Text(visitDrDate ?? 'Visit Date', style: Theme.of(context).textTheme.bodyLarge!.apply(color: Colors.green),),
            ],
          ),
          SizedBox(height: mq.height * 0.01,),
          Divider(color: Colors.white,thickness: 1,),
          SizedBox(height: mq.height * 0.01,),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  Text(visitDrType ?? "Visit Type", style: Theme.of(context).textTheme.bodyLarge,),
                  Text(visitDrDescription ?? "Description", style: Theme.of(context).textTheme.bodyLarge,),
                ],
              ),
              IconButton(onPressed: (){}, icon: Icon(Icons.location_on, color: Colors.grey,size: mq.height * 0.05,),)
            ],
          ),
        ],
      ),
    );
  }
}
