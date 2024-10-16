import 'package:flutter/material.dart';
import 'package:visit_man/model/userModel/visitAterorityModel.dart';

class TodayDailyItem extends StatelessWidget {
  final TodayDailyModel daily;

  TodayDailyItem({required this.daily});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              daily.title,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            SizedBox(height: 8),
            Text('Date: ${daily.date}'),
            Text('User: ${daily.userName}'),
            Text('Month Plan: ${daily.monthPlanName}'),
            Text('Territories: ${daily.territories.map((t) => t.name).join(', ')}'),
          ],
        ),
      ),
    );
  }
}
