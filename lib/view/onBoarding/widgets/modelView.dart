import 'package:flutter/material.dart';

import '../../../main.dart';

class ModelOnBoarding extends StatelessWidget {
  final String image;
  final String title;
  final String text;

  const ModelOnBoarding({
    required this.image,
    required this.title,
    required this.text,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image(
          image: AssetImage(image),
          width: mq.width * 0.6, // Adjusted size
          height: mq.height * 0.25, // Adjusted size
        ),
        SizedBox(
          height: mq.height * 0.05, // Adjusted size
        ),
        Center(
          child: Container(
            width: mq.width * 0.9, // Adjusted size
            child: Card(
              elevation: 10, // Adjusted elevation
              shadowColor: Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(
                  color: Colors.blue,
                  width: 1,
                ),
              ),
              child: Container(
                padding: EdgeInsets.all(mq.width * 0.05), // Adjusted padding
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: mq.height * 0.03, // Adjusted font size
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Divider(
                      height: 10,
                      thickness: 1,
                      color: Colors.blue,
                      indent: 0,
                    ),
                    SizedBox(height: mq.height * 0.02),
                    Text(
                      text,
                      style: TextStyle(
                        fontSize: mq.height * 0.025, // Adjusted font size
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
