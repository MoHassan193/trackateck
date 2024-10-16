
import 'package:visit_man/model/utils/theme/custom_themes/text_themes.dart';
import 'package:flutter/material.dart';

class TElevatedButtonTheme{
  TElevatedButtonTheme._();

  static final lightElevatedButtonTheme = ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        foregroundColor: Colors.white,
        backgroundColor: Colors.blue,
        disabledBackgroundColor: Colors.grey,
        disabledForegroundColor: Colors.grey,
        side: BorderSide(color: Colors.blue),
        padding: EdgeInsets.symmetric(vertical: 18),
        textStyle: TextStyle(fontSize: 16,color: Colors.white,fontWeight: FontWeight.w600),
        shape:  RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      )
  );
  static final darkElevatedButtonTheme = ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        foregroundColor: Colors.white,
        backgroundColor: Colors.blue,
        disabledBackgroundColor: Colors.grey,
        disabledForegroundColor: Colors.grey,
        side: BorderSide(color: Colors.blue),
        padding: EdgeInsets.symmetric(vertical: 18),
        textStyle: TextStyle(fontSize: 16,color: Colors.white,fontWeight: FontWeight.w600),
        shape:  RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      )
  );
}