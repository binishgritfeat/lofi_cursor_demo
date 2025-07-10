// FOLDER STRUCTURE SETUP (see LOFI_APP.md)
// lib/
//   main.dart                # App entry point
//   src/
//     widgets/
//       player.dart          # Main player UI and logic
//       sidebar.dart         # Sidebar/Drawer for track list
//       visualizer.dart      # Audio visualizer widget
//       animated_blobs.dart  # Animated pastel blobs
//       glass_overlay.dart   # Glassmorphic overlay
//     models/
//       track.dart           # Track data model
//     services/
//       deezer_api.dart      # Deezer API integration
//       audio_service.dart   # Audio playback and rain sound
//     providers/
//       theme_provider.dart  # Theme (light/dark) provider
//       track_provider.dart  # Track list, selection, reordering
//     theme/
//       app_theme.dart       # Theme data, pastel palette
//
// assets/
//   rain.mp3

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui'; // Required for ImageFilter
import 'src/widgets/sidebar.dart';
import 'src/widgets/player.dart';
import 'src/widgets/animated_blobs.dart';
import 'src/widgets/glass_overlay.dart';
import 'src/providers/theme_provider.dart';
import 'src/providers/track_provider.dart';
import 'src/services/deezer_api.dart';
import 'src/services/audio_service.dart';

void main() {
  runApp(const ProviderScope(child: LofiMusicApp()));
}

class LofiMusicApp extends ConsumerWidget {
  const LofiMusicApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    return MaterialApp(
      title: 'LofiMusic Flutter',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: themeMode,
      home: const MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  bool _fetched = false;
  bool _loading = true;
  @override
  void initState() {
    super.initState();
    _fetchTracks();
  }

  Future<void> _fetchTracks() async {
    if (_fetched) return;
    _fetched = true;
    setState(() { _loading = true; });
    try {
      final tracks = await DeezerApi.fetchLofiTracks(limit: 10);
      ref.read(trackListProvider.notifier).setTracks(tracks);
      ref.read(audioServiceProvider).setTracks(tracks);
      if (tracks.isNotEmpty) {
        ref.read(selectedTrackProvider.notifier).select(0);
        ref.read(audioServiceProvider).selectTrack(0);
      }
    } catch (e) {
      // Optionally handle error globally
    } finally {
      setState(() { _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final tracks = ref.watch(trackListProvider);
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
                  
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.brightness_6),
                        onPressed: () {
                          ref.read(themeModeProvider.notifier).toggleTheme();
                        },
                      ),
                    ],
                  ),
      drawer: const Sidebar(),
      body: Stack(
        children: [
          // Animated blobs and glass overlay
         
          const GlassOverlay(),
           const AnimatedBlobs(),
          // Soft vignette/gradient overlay for depth
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      Colors.transparent,
                      Color(0xFFfbcfe8),
                      Colors.transparent,
                    ],
                    center: Alignment.center,
                    radius: 1.1,
                    stops: [0.5, 0.95, 1.0],
                  ),
                ),
              ),
            ),
          ),
          Center(
            child: _loading
              ? const _PlayerShimmer()
              : (tracks.isEmpty
                  ? const Text('No tracks found.')
                  : const Player()),
          ),
        ],
      ),
    );
  }
}

// Shimmer widgets (copied from Sidebar)
class _ShimmerList extends StatelessWidget {
  const _ShimmerList();
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(6, (i) => const _ShimmerTile()),
    );
  }
}

class _ShimmerTile extends StatelessWidget {
  const _ShimmerTile();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 12,
                  width: double.infinity,
                  color: Colors.grey.shade300,
                ),
                const SizedBox(height: 6),
                Container(
                  height: 10,
                  width: 100,
                  color: Colors.grey.shade200,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Add a new shimmer widget for the player area
class _PlayerShimmer extends StatefulWidget {
  const _PlayerShimmer();
  @override
  State<_PlayerShimmer> createState() => _PlayerShimmerState();
}

class _PlayerShimmerState extends State<_PlayerShimmer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _shimmerAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _shimmerAnim = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(24),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: Stack(
            children: [
              // Glassmorphic background
              Positioned.fill(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFFfbcfe8),
                        Color(0xFFddd6fe),
                        Color(0xFFa7f3d0),
                        Color(0xFFbae6fd),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                    child: Container(
                      color: Colors.white.withOpacity(0.22),
                    ),
                  ),
                ),
              ),
              // Shimmer content
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: FadeTransition(
                  opacity: _shimmerAnim,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Album art shimmer
                      Container(
                        width: 180,
                        height: 180,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.white.withOpacity(0.45),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.purple.withOpacity(0.08),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withOpacity(0.7),
                              const Color(0xFFbae6fd).withOpacity(0.5),
                              Colors.white.withOpacity(0.7),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      // Title shimmer
                      Container(
                        height: 22,
                        width: 180,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.white.withOpacity(0.55),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Subtitle shimmer
                      Container(
                        height: 16,
                        width: 120,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.white.withOpacity(0.35),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Progress bar shimmer
                      Container(
                        height: 8,
                        width: 220,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: Colors.white.withOpacity(0.25),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Controls shimmer
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          for (int i = 0; i < 3; i++)
                            Container(
                              width: i == 1 ? 56 : 44,
                              height: i == 1 ? 56 : 44,
                              margin: const EdgeInsets.symmetric(horizontal: 8),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withOpacity(0.32),
                                gradient: LinearGradient(
                                  colors: [
                                    const Color(0xFFfbcfe8).withOpacity(0.5),
                                    const Color(0xFFa7f3d0).withOpacity(0.5),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
