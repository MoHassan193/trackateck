import 'package:flutter/material.dart';
import 'package:visit_man/model/utils/sizes.dart';

class ApprovalScreen extends StatelessWidget {
  const ApprovalScreen({super.key, required this.approvalData});

  final List<dynamic> approvalData; // Changed from Map to List

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Approvals')),
      body: ListView.builder(
        itemCount: approvalData.length,
        itemBuilder: (context, index) {
          final approvalItem = approvalData[index];
          return Padding(
            padding:  EdgeInsets.all(MoSizes.md(context) / 2),
            child: Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white, // Background color
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.cyan, width: 2),
              ),
              child: Column(
                children: [
                  TitleApprovalWidget(title: "User Name", answer: approvalItem['user']),
                  TitleApprovalWidget(title: "Title", answer: "${approvalItem['title']}"),
                  TitleApprovalWidget(title: "Start Date", answer: approvalItem['start_date']),
                  TitleApprovalWidget(title: "End Date", answer: approvalItem['end_date']),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class TitleApprovalWidget extends StatelessWidget {
  const TitleApprovalWidget({
    super.key, required this.title, required this.answer,
  });

  final String title;
  final String answer;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white, // Background color
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.cyan, width: 2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            Text(
              answer,
              style: TextStyle(
                color: Colors.blue,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
