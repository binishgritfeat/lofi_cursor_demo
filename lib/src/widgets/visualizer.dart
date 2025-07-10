import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_audio_waveforms/flutter_audio_waveforms.dart';
import '../services/audio_service.dart';
import 'dart:math';

class Visualizer extends ConsumerWidget {
  const Visualizer({super.key});

  List<int> _generateSeededWaveform(int seed, int length) {
    final rand = Random(seed);
    return List.generate(length, (i) => 30 + rand.nextInt(70));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioService = ref.watch(audioServiceProvider);
    final tracks = audioService.tracks;
    final currentIndex = audioService.currentIndex;
    if (tracks.isEmpty || currentIndex >= tracks.length) {
      return const SizedBox(height: 120, width: 300);
    }
    final track = tracks[currentIndex];
    // Use track.id as seed for unique waveform per track
    final samples = _generateSeededWaveform(track.id, 240).map((e) => e.toDouble()).toList();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final inactiveGradient = LinearGradient(
      colors: isDark
          ? [
              const Color(0xFF23243a),
              const Color(0xFF3a86ff),
              const Color(0xFF7f5af0),
            ]
          : [
              const Color(0xFFfbcfe8),
              const Color(0xFFbae6fd),
              const Color(0xFFa7f3d0),
            ],
      begin: Alignment.bottomLeft,
      end: Alignment.topRight,
    );
    final activeGradient = LinearGradient(
      colors: isDark
          ? [
              const Color(0xFFffbe0b),
              const Color(0xFF2cb67d),
              const Color(0xFF7f5af0),
            ]
          : [
              const Color(0xFFf472b6),
              const Color(0xFF818cf8),
              const Color(0xFF34d399),
            ],
      begin: Alignment.bottomLeft,
      end: Alignment.topRight,
    );
    return SizedBox(
      width: 300,
      height: 120,
      child: PolygonWaveform(
        samples: samples,
        height: 120,
        width: 300,
        inactiveGradient: inactiveGradient,
        activeGradient: activeGradient,
        showActiveWaveform: true,
        maxDuration: audioService.duration,
        elapsedDuration: audioService.position,
        absolute: false,
        invert: false,
      ),
    );
  }
} 