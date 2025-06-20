import 'package:flutter/material.dart';
import 'dart:ui';

class ContainerVerre extends StatelessWidget {
  final Widget child;
  final double height;
  final double width;
  final BorderRadius borderRadius;
  final double opacite;

  const ContainerVerre({
    super.key,
    required this.child,
    required this.height,
    required this.width,
    required this.borderRadius,
    this.opacite = 0.12,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        color: Colors.white.withOpacity(opacite),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: child,
        ),
      ),
    );
  }
}