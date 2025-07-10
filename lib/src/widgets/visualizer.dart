import 'package:flutter/material.dart';

class Visualizer extends StatelessWidget {
  const Visualizer({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Integrate with audio playback state for visualization
    return Container(
      width: 300,
      height: 120,
      color: Colors.purple.withOpacity(0.1),
      alignment: Alignment.center,
      child: const Text('Audio Visualizer (coming soon)'),
    );
  }
} 