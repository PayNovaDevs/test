import 'package:flutter/material.dart';

class GradientButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;
  final Gradient gradient;
  final double height;

  const GradientButton({Key? key, required this.onPressed, required this.child, this.gradient = const LinearGradient(colors: [Color(0xFF00E676), Color(0xFF00BFA5)]), this.height = 52}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: height,
        decoration: BoxDecoration(gradient: gradient, borderRadius: BorderRadius.circular(12)),
        child: Center(child: child),
      ),
    );
  }
}
