import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({super.key, this.onPressed, required this.text});
final void Function()? onPressed;
final String text;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
          onPressed: onPressed ?? () {},
          child: Text(text, style: Theme.of(context).textTheme.titleLarge,)),
    );
  }
}
