import 'package:flutter/material.dart';

class BuildButtonWidget extends StatelessWidget {
  final IconData icon;
  final String text;
  final String answer;
  final Widget widget;
  final BuildContext context;
  final VoidCallback? onPressed;

  const BuildButtonWidget({
    Key? key,
    required this.icon,
    required this.text,
    required this.answer,
    required this.widget,
    required this.context, this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(text, style: TextStyle(color: Colors.blue, fontSize: 14)),
      trailing: ElevatedButton(
        style: ElevatedButton.styleFrom(
          maximumSize: Size(100, 40),
          backgroundColor: Colors.white24,
          padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        ),
        onPressed: onPressed ?? () => showModalBottomSheet(
          context: context,
          builder: (context) => widget,
        ),
        child: Center(
          child: Text('  $answer  ', style: TextStyle(color: Colors.blue, fontSize: 8)),
        ),
      ),
    );
  }
}
