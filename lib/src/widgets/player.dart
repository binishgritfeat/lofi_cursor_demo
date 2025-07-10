import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/audio_service.dart';
import 'visualizer.dart';
import 'dart:ui';

class Player extends ConsumerStatefulWidget {
  const Player({super.key});

  @override
  ConsumerState<Player> createState() => _PlayerState();
}

class _PlayerState extends ConsumerState<Player> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final audioService = ref.watch(audioServiceProvider);
    final audioServiceNotifier = ref.read(audioServiceProvider);
    final tracks = audioService.tracks;
    final currentIndex = audioService.currentIndex;
    final track = tracks.isNotEmpty && currentIndex < tracks.length ? tracks[currentIndex] : null;
    final showVisualizer = false;

    return Center(
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovering = true),
        onExit: (_) => setState(() => _hovering = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOut,
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(_hovering ? 0.18 : 0.10),
                blurRadius: _hovering ? 48 : 32,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: Stack(
              children: [
                // Glassmorphic background with hover effect
                Positioned.fill(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeInOut,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: _hovering
                            ? [
                                const Color(0xFFbae6fd),
                                const Color(0xFFfbcfe8),
                                const Color(0xFFa7f3d0),
                                const Color(0xFFddd6fe),
                              ]
                            : [
                                const Color(0xFFfbcfe8),
                                const Color(0xFFddd6fe),
                                const Color(0xFFa7f3d0),
                                const Color(0xFFbae6fd),
                              ],
                        begin: _hovering ? Alignment.bottomRight : Alignment.topLeft,
                        end: _hovering ? Alignment.topLeft : Alignment.bottomRight,
                      ),
                    ),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(
                        sigmaX: _hovering ? 36 : 24,
                        sigmaY: _hovering ? 36 : 24,
                      ),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 350),
                        color: Colors.white.withOpacity(_hovering ? 0.28 : 0.18),
                      ),
                    ),
                  ),
                ),
                // Player content
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (track == null)
                        const Text('No track selected'),
                      if (track != null) ...[
                        GestureDetector(
                          onTap: () {
                            // TODO: Toggle album art/visualizer
                          },
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: showVisualizer
                                ? const Visualizer(key: ValueKey('visualizer'))
                                : ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.08),
                                            blurRadius: 16,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Image.network(
                                        track.cover,
                                        width: 180,
                                        height: 180,
                                        fit: BoxFit.cover,
                                        key: const ValueKey('album'),
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 28),
                        Text(
                          track.title,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.2,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${track.artist} • ${track.album}',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            color: Colors.grey[800],
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 20),
                        // Progress bar
                        _ProgressBar(
                          position: audioService.position,
                          duration: audioService.duration,
                          onSeek: (d) => audioServiceNotifier.seek(d),
                        ),
                        const SizedBox(height: 18),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _GlassIconButton(
                              icon: Icons.skip_previous,
                              onTap: audioServiceNotifier.previous,
                            ),
                            const SizedBox(width: 16),
                            _GlassIconButton(
                              icon: audioService.isPlaying ? Icons.pause : Icons.play_arrow,
                              onTap: () {
                                if (audioService.isPlaying) {
                                  audioServiceNotifier.pause();
                                } else {
                                  audioServiceNotifier.play();
                                }
                              },
                              size: 56,
                            ),
                            const SizedBox(width: 16),
                            _GlassIconButton(
                              icon: Icons.skip_next,
                              onTap: audioServiceNotifier.next,
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final double size;
  const _GlassIconButton({required this.icon, required this.onTap, this.size = 44});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.28),
          borderRadius: BorderRadius.circular(size / 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(color: Colors.white.withOpacity(0.4), width: 1.2),
        ),
        child: Icon(icon, size: size * 0.55, color: Colors.black87),
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final Duration position;
  final Duration duration;
  final ValueChanged<Duration> onSeek;
  const _ProgressBar({required this.position, required this.duration, required this.onSeek});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Slider(
          value: position.inMilliseconds.clamp(0, duration.inMilliseconds).toDouble(),
          min: 0,
          max: duration.inMilliseconds.toDouble().clamp(1, double.infinity),
          onChanged: (v) => onSeek(Duration(milliseconds: v.toInt())),
          activeColor: const Color(0xFFa7f3d0),
          inactiveColor: const Color(0xFFddd6fe),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(_formatDuration(position), style: const TextStyle(fontSize: 13, color: Colors.black54)),
            Text(_formatDuration(duration), style: const TextStyle(fontSize: 13, color: Colors.black54)),
          ],
        ),
      ],
    );
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
} 