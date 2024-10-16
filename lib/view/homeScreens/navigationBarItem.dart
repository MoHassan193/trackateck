import 'package:flutter/material.dart';

class NavigationBarItem extends StatelessWidget {
  const NavigationBarItem({super.key, required this.icon, required this.text});
final IconData icon;
final String text;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Color(0xFF0f898c), size: 25,),
        SizedBox(height: 5,),
        Text(text, style: TextStyle(color: Color(0xFF0f898c), fontSize: 12),)
      ],
    );
  }
}
