import 'package:flutter/material.dart';

import '../../../../../main.dart';

class ShowResult extends StatelessWidget {
  const ShowResult({super.key, required this.color, required this.color1, required this.color2, required this.title, required this.result});
final Color color;
final Color color1;
final Color color2;
final String title;
final String result;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: [
              color,
              color1,
              color2
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight
        ),
        borderRadius: BorderRadius.circular(25),
      ),
      width: double.infinity,
      height: mq.height * 0.1,
      child: Column(
        children: [
          Center(
            child: Text(title, style: Theme.of(context).textTheme.titleLarge,),
          ),
          SizedBox(height: mq.height * 0.01,),
          Text(result, style: Theme.of(context).textTheme.titleLarge,),
          SizedBox(height: mq.height * 0.01,),
        ],
      ),
    );
  }
}
