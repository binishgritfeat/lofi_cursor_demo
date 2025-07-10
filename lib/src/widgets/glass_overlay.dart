import 'package:flutter/material.dart';
import 'dart:ui';

class GlassOverlay extends StatelessWidget {
  const GlassOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        backgroundBlendMode: BlendMode.overlay,
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(),
      ),
    );
  }
} 