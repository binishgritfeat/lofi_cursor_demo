import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/track_provider.dart';
import '../services/audio_service.dart';
import 'dart:ui';

class Sidebar extends ConsumerWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tracks = ref.watch(trackListProvider);
    final audioService = ref.watch(audioServiceProvider);
    final playingIndex = audioService.currentIndex;

    final glassBg = isDark
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
    final glassOpacity = isDark ? 0.22 : 0.18;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subTextColor = isDark ? Colors.white70 : Colors.grey.shade800;
    final selectedBg = isDark ? Colors.white.withOpacity(0.18) : Colors.white.withOpacity(0.32);
    final unselectedBg = isDark ? Colors.white.withOpacity(0.08) : Colors.white.withOpacity(0.12);
    final selectedShadow = isDark ? Colors.purple.withOpacity(0.18) : Colors.purple.withOpacity(0.10);

    return Drawer(
      child: Stack(
        children: [
          // Glassmorphic pastel gradient background
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: glassBg,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                child: Container(
                  color: isDark ? Colors.black.withOpacity(glassOpacity) : Colors.white.withOpacity(glassOpacity),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              child: Column(
                children: [
                  Text(
                    'Track List',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (tracks.isEmpty)
                    _ShimmerList(isDark: isDark)
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
                        },
                        buildDefaultDragHandles: false,
                        itemBuilder: (context, i) {
                          final track = tracks[i];
                          final isSelected = i == playingIndex;
                          return _SidebarTrackTile(
                            key: ValueKey(track.id),
                            track: track,
                            selected: isSelected,
                            onTap: () async {
                              ref.read(selectedTrackProvider.notifier).select(i);
                              await ref.read(audioServiceProvider).selectTrack(i, autoPlay: true);
                              Navigator.of(context).pop();
                            },
                            dragHandle: ReorderableDragStartListener(
                              index: i,
                              child: Icon(Icons.drag_handle, color: isDark ? Colors.white38 : Colors.grey[400]),
                            ),
                            isDark: isDark,
                            textColor: textColor,
                            subTextColor: subTextColor,
                            selectedBg: selectedBg,
                            unselectedBg: unselectedBg,
                            selectedShadow: selectedShadow,
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
  final bool isDark;
  final Color textColor;
  final Color subTextColor;
  final Color selectedBg;
  final Color unselectedBg;
  final Color selectedShadow;
  const _SidebarTrackTile({Key? key, required this.track, required this.selected, required this.onTap, required this.dragHandle, required this.isDark, required this.textColor, required this.subTextColor, required this.selectedBg, required this.unselectedBg, required this.selectedShadow}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: selected ? selectedBg : unselectedBg,
        borderRadius: BorderRadius.circular(18),
        boxShadow: selected
            ? [
                BoxShadow(
                  color: selectedShadow,
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ]
            : [],
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
            color: textColor,
          ),
        ),
        subtitle: Text(
          '${track.artist} • ${track.album}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 13,
            color: subTextColor,
          ),
        ),
        onTap: onTap,
        trailing: dragHandle,
      ),
    );
  }
}

class _ShimmerList extends StatelessWidget {
  final bool isDark;
  const _ShimmerList({this.isDark = false});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(6, (i) => _AnimatedShimmerTile(delay: i * 120, isDark: isDark)),
    );
  }
}

class _AnimatedShimmerTile extends StatefulWidget {
  final int delay;
  final bool isDark;
  const _AnimatedShimmerTile({required this.delay, this.isDark = false});
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
    final pastel1 = widget.isDark ? const Color(0xFF7f5af0).withOpacity(0.7) : const Color(0xFFfbcfe8).withOpacity(0.7);
    final pastel2 = widget.isDark ? const Color(0xFF2cb67d).withOpacity(0.6) : const Color(0xFFa7f3d0).withOpacity(0.5);
    final pastel3 = widget.isDark ? const Color(0xFF3a86ff).withOpacity(0.6) : const Color(0xFFbae6fd).withOpacity(0.5);
    final pastel4 = widget.isDark ? const Color(0xFFffbe0b).withOpacity(0.5) : const Color(0xFFddd6fe).withOpacity(0.4);
    final base = widget.isDark ? Colors.white.withOpacity(0.10) : Colors.white.withOpacity(0.45);
    final base2 = widget.isDark ? Colors.white.withOpacity(0.08) : Colors.white.withOpacity(0.35);
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
                gradient: LinearGradient(
                  colors: [pastel1, pastel2],
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
                      gradient: LinearGradient(
                        colors: [pastel3, pastel4],
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
                      color: base,
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