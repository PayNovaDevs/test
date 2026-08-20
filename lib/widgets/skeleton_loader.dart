import 'package:flutter/material.dart';

class SkeletonLoader extends StatelessWidget {
  final double height;
  final double width;
  final BorderRadius borderRadius;

  const SkeletonLoader({Key? key, this.height = 12, this.width = double.infinity, this.borderRadius = const BorderRadius.all(Radius.circular(8))}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: borderRadius,
      ),
    );
  }
}
