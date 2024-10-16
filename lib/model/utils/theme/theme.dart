

import 'package:visit_man/model/utils/theme/custom_themes/appbar_theme.dart';
import 'package:visit_man/model/utils/theme/custom_themes/bottom_sheet_theme.dart';
import 'package:visit_man/model/utils/theme/custom_themes/checkbox_theme.dart';
import 'package:visit_man/model/utils/theme/custom_themes/chip_theme.dart';
import 'package:visit_man/model/utils/theme/custom_themes/elevated_button_theme.dart';
import 'package:visit_man/model/utils/theme/custom_themes/outlined_button_theme.dart';
import 'package:visit_man/model/utils/theme/custom_themes/text_field_theme.dart';
import 'package:visit_man/model/utils/theme/custom_themes/text_themes.dart';
import 'package:flutter/material.dart';


class TAppTheme {
  TAppTheme._();

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: Colors.white,
    primaryColor: Colors.blue,
    fontFamily: 'Poppins',
    textTheme: TTextTheme.lightTextTheme,
    elevatedButtonTheme: TElevatedButtonTheme.lightElevatedButtonTheme,
    appBarTheme: TAppBarTheme.lightAppBarTheme,
    bottomSheetTheme: TBottomSheetTheme.lightBottomSheetTheme,
    checkboxTheme: TCheckBoxTheme.lightCheckBoxTheme,
    chipTheme: TChipTheme.lightChipTheme,
    outlinedButtonTheme: TOutlinedButtonTheme.lightOutlinedButtonTheme,
    inputDecorationTheme: TTextFormFieldTheme.lightInputDecorationTheme

  );
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Colors.black,
    primaryColor: Colors.blue,
    fontFamily: 'Poppins',
    textTheme: TTextTheme.darkTextTheme,
    elevatedButtonTheme: TElevatedButtonTheme.darkElevatedButtonTheme,
    appBarTheme: TAppBarTheme.darkAppBarTheme,
    bottomSheetTheme: TBottomSheetTheme.darkBottomSheetTheme,
    checkboxTheme: TCheckBoxTheme.darkCheckBoxTheme,
    chipTheme: TChipTheme.darkChipTheme,
    outlinedButtonTheme: TOutlinedButtonTheme.darkOutlinedButtonTheme,
    inputDecorationTheme: TTextFormFieldTheme.darkInputDecorationTheme
  );
}