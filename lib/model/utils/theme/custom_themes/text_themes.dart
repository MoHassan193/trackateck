

import 'package:flutter/material.dart';

class TTextTheme {
  TTextTheme._();

  static TextTheme lightTextTheme = TextTheme(
    displayLarge: TextStyle().copyWith(color: Colors.black, fontSize:32, fontWeight: FontWeight.bold),
    displayMedium: TextStyle().copyWith(color: Colors.black, fontSize:24, fontWeight: FontWeight.w600),
    displaySmall: TextStyle().copyWith(color: Colors.black, fontSize:18, fontWeight: FontWeight.w500),

    titleLarge: TextStyle().copyWith(color: Colors.black, fontSize:16, fontWeight: FontWeight.w600),
    titleMedium: TextStyle().copyWith(color: Colors.black, fontSize:14, fontWeight: FontWeight.w500),
    titleSmall: TextStyle().copyWith(color: Colors.black, fontSize:12, fontWeight: FontWeight.w400),

    bodyLarge: TextStyle().copyWith(color: Colors.black, fontSize:14, fontWeight: FontWeight.w500),
    bodyMedium: TextStyle().copyWith(color: Colors.black, fontSize:12, fontWeight: FontWeight.normal),
    bodySmall: TextStyle().copyWith(color: Colors.black, fontSize:10, fontWeight: FontWeight.w400),

    labelLarge: TextStyle().copyWith(color: Colors.black, fontSize:14, fontWeight: FontWeight.w600),
    labelMedium: TextStyle().copyWith(color: Colors.black, fontSize:12, fontWeight: FontWeight.w500),
    labelSmall: TextStyle().copyWith(color: Colors.black, fontSize:10, fontWeight: FontWeight.w400),


  );
  static TextTheme darkTextTheme = TextTheme(
    displayLarge: TextStyle().copyWith(color: Colors.white, fontSize:32, fontWeight: FontWeight.bold),
    displayMedium: TextStyle().copyWith(color: Colors.white, fontSize:24, fontWeight: FontWeight.w600),
    displaySmall: TextStyle().copyWith(color: Colors.white, fontSize:18, fontWeight: FontWeight.w500),

    titleLarge: TextStyle().copyWith(color: Colors.white, fontSize:16, fontWeight: FontWeight.w600),
    titleMedium: TextStyle().copyWith(color: Colors.white, fontSize:14, fontWeight: FontWeight.w500),
    titleSmall: TextStyle().copyWith(color: Colors.white, fontSize:12, fontWeight: FontWeight.w400),

    bodyLarge: TextStyle().copyWith(color: Colors.white, fontSize:14, fontWeight: FontWeight.w500),
    bodyMedium: TextStyle().copyWith(color: Colors.white, fontSize:12, fontWeight: FontWeight.normal),
    bodySmall: TextStyle().copyWith(color: Colors.white, fontSize:10, fontWeight: FontWeight.w400),

    labelLarge: TextStyle().copyWith(color: Colors.white, fontSize:14, fontWeight: FontWeight.w600),
    labelMedium: TextStyle().copyWith(color: Colors.white, fontSize:12, fontWeight: FontWeight.w500),
    labelSmall: TextStyle().copyWith(color: Colors.white, fontSize:10, fontWeight: FontWeight.w400),
  );
}