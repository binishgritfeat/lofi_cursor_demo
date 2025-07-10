import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/track.dart';

class TrackListNotifier extends StateNotifier<List<Track>> {
  TrackListNotifier() : super([]);

  void setTracks(List<Track> tracks) {
    state = tracks;
  }

  void reorder(int oldIndex, int newIndex) {
    final tracks = [...state];
    final track = tracks.removeAt(oldIndex);
    tracks.insert(newIndex > oldIndex ? newIndex - 1 : newIndex, track);
    state = tracks;
  }
}

final trackListProvider = StateNotifierProvider<TrackListNotifier, List<Track>>((ref) {
  return TrackListNotifier();
});

class SelectedTrackNotifier extends StateNotifier<int> {
  SelectedTrackNotifier() : super(0);

  void select(int index) {
    state = index;
  }
}

final selectedTrackProvider = StateNotifierProvider<SelectedTrackNotifier, int>((ref) {
  return SelectedTrackNotifier();
}); 