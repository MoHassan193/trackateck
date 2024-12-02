
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../../main.dart';

class DialToast {
  static void showToast(String msg,Color? color) {
    Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 2,
        backgroundColor:  color,
        textColor: Colors.white,
        fontSize: 16.0
    );
  }

  static void showProgressBar(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Center(child: CircularProgressIndicator()),
    );
  }

}