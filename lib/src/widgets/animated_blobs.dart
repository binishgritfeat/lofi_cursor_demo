import 'package:flutter/material.dart';
import 'dart:math';

class AnimatedBlobs extends StatefulWidget {
  const AnimatedBlobs({super.key});

  @override
  State<AnimatedBlobs> createState() => _AnimatedBlobsState();
}

class _AnimatedBlobsState extends State<AnimatedBlobs> with TickerProviderStateMixin {
  late final AnimationController _controller1 = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 18),
  )..repeat(reverse: true);
  late final AnimationController _controller2 = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 22),
  )..repeat(reverse: true);
  late final AnimationController _controller3 = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 26),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller1.dispose();
    _controller2.dispose();
    _controller3.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          // Blob 1
          AnimatedBuilder(
            animation: _controller1,
            builder: (context, child) {
              return Positioned(
                left: 60 + 40 * sin(_controller1.value * 2 * pi),
                top: 80 + 30 * cos(_controller1.value * 2 * pi),
                child: _Blob(
                  size: 320,
                  color: const Color(0xFFfbcfe8).withOpacity(0.38),
                  blur: 60,
                ),
              );
            },
          ),
          // Blob 2
          AnimatedBuilder(
            animation: _controller2,
            builder: (context, child) {
              return Positioned(
                right: 40 + 30 * cos(_controller2.value * 2 * pi),
                top: 180 + 40 * sin(_controller2.value * 2 * pi),
                child: _Blob(
                  size: 260,
                  color: const Color(0xFFa7f3d0).withOpacity(0.34),
                  blur: 48,
                ),
              );
            },
          ),
          // Blob 3
          AnimatedBuilder(
            animation: _controller3,
            builder: (context, child) {
              return Positioned(
                left: 100 + 60 * cos(_controller3.value * 2 * pi),
                bottom: 60 + 30 * sin(_controller3.value * 2 * pi),
                child: _Blob(
                  size: 280,
                  color: const Color(0xFFbae6fd).withOpacity(0.36),
                  blur: 54,
                ),
              );
            },
          ),
          // Blob 4 (extra vibrant)
          AnimatedBuilder(
            animation: _controller2,
            builder: (context, child) {
              return Positioned(
                right: 120 + 50 * sin(_controller2.value * 2 * pi),
                bottom: 100 + 40 * cos(_controller2.value * 2 * pi),
                child: _Blob(
                  size: 200,
                  color: const Color(0xFFddd6fe).withOpacity(0.32),
                  blur: 40,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _Blob extends StatelessWidget {
  final double size;
  final Color color;
  final double blur;
  const _Blob({required this.size, required this.color, required this.blur});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color,
            blurRadius: blur,
            spreadRadius: blur / 2,
          ),
        ],
      ),
    );
  }
} 