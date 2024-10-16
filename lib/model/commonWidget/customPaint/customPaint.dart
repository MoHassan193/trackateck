import 'package:flutter/material.dart';

class BlueClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();

    // بدء المثلث من النقطة اليسرى السفلى
    path.lineTo(0, size.height);
    // الانتقال إلى النقطة اليمنى السفلى
    path.lineTo(size.width, size.height);
    // الانتقال إلى النقطة العلوية في المنتصف
    path.lineTo(size.width / 2, 0);

    path.close(); // إغلاق المسار
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}
