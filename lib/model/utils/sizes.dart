import 'package:flutter/material.dart';

class MoSizes {
  static double _screenSize(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return (size.width + size.height) / 2;
  }

  static double xs(BuildContext context) => _screenSize(context) * 0.01;
  static double sm(BuildContext context) => _screenSize(context) * 0.02;
  static double md(BuildContext context) => _screenSize(context) * 0.04;
  static double lg(BuildContext context) => _screenSize(context) * 0.06;
  static double xl(BuildContext context) => _screenSize(context) * 0.08;

  static double iconXs(BuildContext context) => _screenSize(context) * 0.03;
  static double iconSm(BuildContext context) => _screenSize(context) * 0.04;
  static double iconMd(BuildContext context) => _screenSize(context) * 0.06;
  static double iconLg(BuildContext context) => _screenSize(context) * 0.08;

  static double fontSizeSm(BuildContext context) => _screenSize(context) * 0.035;
  static double fontSizeMd(BuildContext context) => _screenSize(context) * 0.04;
  static double fontSizeLg(BuildContext context) => _screenSize(context) * 0.045;

  static double buttonHeight(BuildContext context) => _screenSize(context) * 0.045;
  static double buttonRadius(BuildContext context) => _screenSize(context) * 0.03;
  static double buttonWidth(BuildContext context) => _screenSize(context) * 0.3;
  static double buttonElevation(BuildContext context) => _screenSize(context) * 0.01;

  static double appBarHeight(BuildContext context) => _screenSize(context) * 0.15;

  static double defaultSpace(BuildContext context) => _screenSize(context) * 0.06;
  static double spaceBtwItems(BuildContext context) => _screenSize(context) * 0.04;
  static double spaceBtwSections(BuildContext context) => _screenSize(context) * 0.08;

  static double borderRadiusSm(BuildContext context) => _screenSize(context) * 0.01;
  static double borderRadiusMd(BuildContext context) => _screenSize(context) * 0.02;
  static double borderRadiusLg(BuildContext context) => _screenSize(context) * 0.03;

  static double dividerHeight(BuildContext context) => _screenSize(context) * 0.0025;

  static double productImageSize(BuildContext context) => _screenSize(context) * 0.3;
  static double productImageRadius(BuildContext context) => _screenSize(context) * 0.04;
  static double productImageHeight(BuildContext context) => _screenSize(context) * 0.4;

  static double inputFieldRadius(BuildContext context) => _screenSize(context) * 0.03;
  static double spaceBtwInputField(BuildContext context) => _screenSize(context) * 0.04;

  static double cardRadiusLg(BuildContext context) => _screenSize(context) * 0.04;
  static double cardRadiusMd(BuildContext context) => _screenSize(context) * 0.03;
  static double cardRadiusSm(BuildContext context) => _screenSize(context) * 0.025;
  static double cardRadiusXs(BuildContext context) => _screenSize(context) * 0.015;
  static double cardElevation(BuildContext context) => _screenSize(context) * 0.005;

  static double imageCarouselHeight(BuildContext context) => _screenSize(context) * 0.5;

  static double loadingIndicatorSize(BuildContext context) => _screenSize(context) * 0.09;

  static double gridViewSpacing(BuildContext context) => _screenSize(context) * 0.04;
}
