import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/track.dart';

class AudioService extends ChangeNotifier {
  final AudioPlayer _player = AudioPlayer();
  final AudioPlayer _rainPlayer = AudioPlayer();
  List<Track> _tracks = [];
  int _currentIndex = 0;
  bool _rainOn = false;

  AudioService() {
    _player.positionStream.listen((_) => notifyListeners());
    _player.durationStream.listen((_) => notifyListeners());
    _player.playerStateStream.listen((state) {
      notifyListeners();
      if (state.processingState == ProcessingState.completed) {
        next();
      }
    });
  }

  AudioPlayer get player => _player;
  AudioPlayer get rainPlayer => _rainPlayer;
  int get currentIndex => _currentIndex;
  bool get isPlaying => _player.playing;
  bool get rainOn => _rainOn;
  Duration get position => _player.position;
  Duration get duration => _player.duration ?? Duration.zero;
  List<Track> get tracks => _tracks;

  void setTracks(List<Track> tracks) async {
    final wasPlaying = _player.playing;
    final currentTrack = _tracks.isNotEmpty && _currentIndex < _tracks.length ? _tracks[_currentIndex] : null;
    final currentPosition = _player.position;
    _tracks = tracks;
    int newIndex = 0;
    if (currentTrack != null) {
      newIndex = _tracks.indexWhere((t) => t.id == currentTrack.id);
      if (newIndex == -1) newIndex = 0;
    }
    final trackChanged = _currentIndex != newIndex;
    _currentIndex = newIndex;
    if (_tracks.isNotEmpty) {
      if (trackChanged) {
        await _loadTrack(_tracks[_currentIndex], position: currentPosition, autoPause: !wasPlaying);
        if (wasPlaying) {
          await _player.play();
        }
      }
      // If the track didn't change, do nothing: playback continues!
    }
    notifyListeners();
  }

  Future<void> selectTrack(int index, {bool autoPlay = false}) async {
    if (index >= 0 && index < _tracks.length) {
      _currentIndex = index;
      await _loadTrack(_tracks[index], autoPause: !autoPlay);
      if (autoPlay) {
        await _player.play();
      }
      notifyListeners();
    }
  }

  Future<void> _loadTrack(Track track, {Duration? position, bool autoPause = true}) async {
    await _player.setUrl(track.preview);
    await _player.seek(position ?? Duration.zero);
    if (autoPause) {
      await _player.pause();
    }
    notifyListeners();
  }

  Future<void> play() async {
    await _player.play();
    notifyListeners();
  }

  Future<void> pause() async {
    await _player.pause();
    notifyListeners();
  }

  Future<void> next() async {
    if (_tracks.isEmpty) return;
    _currentIndex = (_currentIndex + 1) % _tracks.length;
    await _loadTrack(_tracks[_currentIndex]);
    await play();
    notifyListeners();
  }

  Future<void> previous() async {
    if (_tracks.isEmpty) return;
    _currentIndex = (_currentIndex - 1 + _tracks.length) % _tracks.length;
    await _loadTrack(_tracks[_currentIndex]);
    await play();
    notifyListeners();
  }

  Future<void> seek(Duration position) async {
    await _player.seek(position);
    notifyListeners();
  }

  Future<void> toggleRain() async {
    if (_rainOn) {
      await _rainPlayer.pause();
      await _rainPlayer.seek(Duration.zero);
    } else {
      await _rainPlayer.setAsset('assets/rain.mp3');
      await _rainPlayer.setLoopMode(LoopMode.one);
      await _rainPlayer.setVolume(0.3);
      await _rainPlayer.play();
    }
    _rainOn = !_rainOn;
    notifyListeners();
  }

  @override
  void dispose() {
    _player.dispose();
    _rainPlayer.dispose();
    super.dispose();
  }
}

final audioServiceProvider = ChangeNotifierProvider<AudioService>((ref) => AudioService()); 