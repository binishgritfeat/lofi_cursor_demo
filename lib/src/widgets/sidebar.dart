import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/track_provider.dart';
import '../services/audio_service.dart';
import 'dart:ui';

class Sidebar extends ConsumerWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tracks = ref.watch(trackListProvider);
    final audioService = ref.watch(audioServiceProvider);
    final playingIndex = audioService.currentIndex;

    return Drawer(
      child: Stack(
        children: [
          // Glassmorphic pastel gradient background
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFFfbcfe8), // pastel pink
                    Color(0xFFddd6fe), // pastel purple
                    Color(0xFFa7f3d0), // pastel teal
                    Color(0xFFbae6fd), // pastel light blue
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                child: Container(
                  color: Colors.white.withOpacity(0.18),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              child: Column(
                children: [
                  const Text(
                    'Track List',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (tracks.isEmpty)
                    const _ShimmerList()
                  else
                    Expanded(
                      child: ReorderableListView.builder(
                        itemCount: tracks.length,
                        onReorder: (oldIndex, newIndex) {
                          ref.read(trackListProvider.notifier).reorder(oldIndex, newIndex);
                          final audioService = ref.read(audioServiceProvider);
                          final wasPlaying = audioService.isPlaying;
                          final currentTrack = audioService.tracks[audioService.currentIndex];
                          final newTracks = ref.read(trackListProvider);
                          audioService.setTracks(newTracks);
                          final newIndexOfCurrent = newTracks.indexWhere((t) => t.id == currentTrack.id);
                          if (newIndexOfCurrent != -1 && audioService.currentIndex != newIndexOfCurrent) {
                            audioService.selectTrack(newIndexOfCurrent);
                            if (wasPlaying) {
                              audioService.play();
                            }
                          }
                          // If the index didn't change, do nothing: playback continues at the same position!
                        },
                        buildDefaultDragHandles: false,
                        itemBuilder: (context, i) {
                          final track = tracks[i];
                          final isSelected = i == playingIndex;
                          return _SidebarTrackTile(
                            key: ValueKey(track.id),
                            track: track,
                            selected: isSelected,
                            onTap: () {
                              ref.read(selectedTrackProvider.notifier).select(i);
                              ref.read(audioServiceProvider).selectTrack(i);
                              Navigator.of(context).pop();
                            },
                            dragHandle: ReorderableDragStartListener(
                              index: i,
                              child: Icon(Icons.drag_handle, color: Colors.grey[400]),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarTrackTile extends StatelessWidget {
  final dynamic track;
  final bool selected;
  final VoidCallback onTap;
  final Widget dragHandle;
  const _SidebarTrackTile({Key? key, required this.track, required this.selected, required this.onTap, required this.dragHandle}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: selected ? Colors.white.withOpacity(0.32) : Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(18),
        boxShadow: selected
            ? [
                BoxShadow(
                  color: Colors.purple.withOpacity(0.10),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ]
            : [],
        // Removed border for cleaner look
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: CircleAvatar(
          backgroundImage: NetworkImage(track.cover),
          radius: 22,
        ),
        title: Text(
          track.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            fontSize: 16,
            color: selected ? Colors.black : Colors.black87,
          ),
        ),
        subtitle: Text(
          '${track.artist} • ${track.album}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 13,
            color: Colors.grey[800],
          ),
        ),
        onTap: onTap,
        trailing: dragHandle,
      ),
    );
  }
}

class _ShimmerList extends StatelessWidget {
  const _ShimmerList();
  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(6, (i) => _AnimatedShimmerTile(delay: i * 120)),
    );
  }
}

class _AnimatedShimmerTile extends StatefulWidget {
  final int delay;
  const _AnimatedShimmerTile({required this.delay});
  @override
  State<_AnimatedShimmerTile> createState() => _AnimatedShimmerTileState();
}

class _AnimatedShimmerTileState extends State<_AnimatedShimmerTile> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnim = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFfbcfe8),
                    Color(0xFFa7f3d0),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
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
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFddd6fe),
                          Color(0xFFbae6fd),
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    height: 10,
                    width: 100,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 