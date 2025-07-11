import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/audio_service.dart';
import 'visualizer.dart';
import 'dart:ui';
import 'dart:math' as math;

class Player extends ConsumerStatefulWidget {
  const Player({super.key});

  @override
  ConsumerState<Player> createState() => _PlayerState();
}

class _PlayerState extends ConsumerState<Player> with TickerProviderStateMixin {
  bool _hovering = false;
  bool _showVisualizer = false;
  late AnimationController _timeAnimationController;
  late AnimationController _pulseAnimationController;
  late Animation<double> _timeAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    // Time-based animation controller
    _timeAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    // Pulse animation controller for subtle breathing effect
    _pulseAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);

    _timeAnimation = Tween<double>(begin: 0, end: 2 * math.pi).animate(
      CurvedAnimation(
        parent: _timeAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(
        parent: _pulseAnimationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _timeAnimationController.dispose();
    _pulseAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final audioService = ref.watch(audioServiceProvider);
    final audioServiceNotifier = ref.read(audioServiceProvider);
    final tracks = audioService.tracks;
    final currentIndex = audioService.currentIndex;
    final track =
        tracks.isNotEmpty && currentIndex < tracks.length
            ? tracks[currentIndex]
            : null;

    final glassBg =
        isDark
            ? [
              const Color(0xFF23243a),
              const Color(0xFF23243a),
              const Color(0xFF23243a),
              const Color(0xFF23243a),
            ]
            : [
              const Color(0xFFfbcfe8),
              const Color(0xFFddd6fe),
              const Color(0xFFa7f3d0),
              const Color(0xFFbae6fd),
            ];
    final glassOpacity =
        isDark ? (_hovering ? 0.32 : 0.22) : (_hovering ? 0.28 : 0.18);
    final textColor = isDark ? Colors.white : Colors.black87;
    final subTextColor = isDark ? Colors.white70 : Colors.grey[800];
    final cardShadow =
        isDark
            ? Colors.black.withOpacity(_hovering ? 0.32 : 0.18)
            : Colors.black.withOpacity(_hovering ? 0.18 : 0.10);

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
                color: cardShadow,
                blurRadius: _hovering ? 48 : 32,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: Stack(
              children: [
                // Time-based animated background
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: Listenable.merge([
                      _timeAnimation,
                      _pulseAnimation,
                    ]),
                    builder: (context, child) {
                      final timeValue = _timeAnimation.value;
                      final pulseValue = _pulseAnimation.value;

                      return Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: glassBg,
                            begin: Alignment(
                              math.cos(timeValue) * 0.5,
                              math.sin(timeValue) * 0.5,
                            ),
                            end: Alignment(
                              math.cos(timeValue + math.pi) * 0.5,
                              math.sin(timeValue + math.pi) * 0.5,
                            ),
                          ),
                        ),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(
                            sigmaX: _hovering ? 36 : 24,
                            sigmaY: _hovering ? 36 : 24,
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              color:
                                  isDark
                                      ? Colors.black.withOpacity(
                                        glassOpacity * pulseValue,
                                      )
                                      : Colors.white.withOpacity(
                                        glassOpacity * pulseValue,
                                      ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // Animated floating orbs behind track details
                if (track != null) ...[
                  // Orb 1 - Top left
                  Positioned(
                    left: 20 + math.sin(_timeAnimation.value * 0.5) * 10,
                    top: 20 + math.cos(_timeAnimation.value * 0.3) * 8,
                    child: AnimatedBuilder(
                      animation: _timeAnimation,
                      builder: (context, child) {
                        return Container(
                          width: 60 + math.sin(_timeAnimation.value * 2) * 20,
                          height: 60 + math.sin(_timeAnimation.value * 2) * 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                const Color(0xFFfbcfe8).withOpacity(0.3),
                                const Color(0xFFddd6fe).withOpacity(0.1),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  // Orb 2 - Bottom right
                  Positioned(
                    right: 20 + math.cos(_timeAnimation.value * 0.4) * 12,
                    bottom: 20 + math.sin(_timeAnimation.value * 0.6) * 10,
                    child: AnimatedBuilder(
                      animation: _timeAnimation,
                      builder: (context, child) {
                        return Container(
                          width: 80 + math.cos(_timeAnimation.value * 1.5) * 25,
                          height:
                              80 + math.cos(_timeAnimation.value * 1.5) * 25,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                const Color(0xFFa7f3d0).withOpacity(0.25),
                                const Color(0xFFbae6fd).withOpacity(0.15),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  // Orb 3 - Center (subtle)
                  Positioned(
                    left: 50 + math.sin(_timeAnimation.value * 0.2) * 5,
                    top: 120 + math.cos(_timeAnimation.value * 0.4) * 3,
                    child: AnimatedBuilder(
                      animation: _timeAnimation,
                      builder: (context, child) {
                        return Container(
                          width: 40 + math.sin(_timeAnimation.value * 3) * 15,
                          height: 40 + math.sin(_timeAnimation.value * 3) * 15,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                const Color(0xFFddd6fe).withOpacity(0.2),
                                const Color(0xFFfbcfe8).withOpacity(0.1),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
                // Player content
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (track == null)
                        Text(
                          'No track selected',
                          style: TextStyle(color: textColor),
                        ),
                      if (track != null) ...[
                        // Toggle button
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton.icon(
                              style: TextButton.styleFrom(
                                backgroundColor:
                                    isDark
                                        ? Colors.white.withOpacity(0.08)
                                        : Colors.white.withOpacity(0.18),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                              ),
                              icon: Icon(
                                _showVisualizer
                                    ? Icons.image
                                    : Icons.graphic_eq,
                                color: textColor,
                              ),
                              label: Text(
                                _showVisualizer ? 'Album Art' : 'Visualizer',
                                style: TextStyle(color: textColor),
                              ),
                              onPressed: () {
                                setState(
                                  () => _showVisualizer = !_showVisualizer,
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child:
                              _showVisualizer
                                  ? const Visualizer(
                                    key: ValueKey('visualizer'),
                                  )
                                  : ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.08,
                                            ),
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
                        const SizedBox(height: 28),
                        Text(
                          track.title,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.2,
                            color: textColor,
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
                            color: subTextColor,
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
                          isDark: isDark,
                        ),
                        const SizedBox(height: 18),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _GlassIconButton(
                              icon: Icons.skip_previous,
                              onTap: audioServiceNotifier.previous,
                              isDark: isDark,
                            ),
                            const SizedBox(width: 16),
                            _GlassIconButton(
                              icon:
                                  audioService.isPlaying
                                      ? Icons.pause
                                      : Icons.play_arrow,
                              onTap: () {
                                if (audioService.isPlaying) {
                                  audioServiceNotifier.pause();
                                } else {
                                  audioServiceNotifier.play();
                                }
                              },
                              size: 56,
                              isDark: isDark,
                            ),
                            const SizedBox(width: 16),
                            _GlassIconButton(
                              icon: Icons.skip_next,
                              onTap: audioServiceNotifier.next,
                              isDark: isDark,
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
  final bool isDark;
  const _GlassIconButton({
    required this.icon,
    required this.onTap,
    this.size = 44,
    this.isDark = false,
  });
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color:
              isDark
                  ? Colors.white.withOpacity(0.10)
                  : Colors.white.withOpacity(0.28),
          borderRadius: BorderRadius.circular(size / 2),
          boxShadow: [
            BoxShadow(
              color:
                  isDark
                      ? Colors.black.withOpacity(0.18)
                      : Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          size: size * 0.55,
          color: isDark ? Colors.white : Colors.black87,
        ),
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final Duration position;
  final Duration duration;
  final ValueChanged<Duration> onSeek;
  final bool isDark;
  const _ProgressBar({
    required this.position,
    required this.duration,
    required this.onSeek,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Slider(
          value:
              position.inMilliseconds
                  .clamp(0, duration.inMilliseconds)
                  .toDouble(),
          min: 0,
          max: duration.inMilliseconds.toDouble().clamp(1, double.infinity),
          onChanged: (v) => onSeek(Duration(milliseconds: v.toInt())),
          activeColor:
              isDark ? const Color(0xFFa7f3d0) : const Color(0xFFa7f3d0),
          inactiveColor:
              isDark ? const Color(0xFF23243a) : const Color(0xFFddd6fe),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _formatDuration(position),
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
            Text(
              _formatDuration(duration),
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
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
