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
    
    // Add listener for rain player state changes
    _rainPlayer.playerStateStream.listen((state) {
      notifyListeners();
    });
  }

  AudioPlayer get player => _player;
  AudioPlayer get rainPlayer => _rainPlayer;
  int get currentIndex => _currentIndex;
  bool get isPlaying => _player.playing;
  bool get rainOn => _rainOn;
  bool get isRainPlaying => _rainPlayer.playing;
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

  Future<void> _initializeRainPlayer() async {
    try {
      print('Initializing rain player...');
      await _rainPlayer.setAsset('assets/sounds/rain.mp3');
      await _rainPlayer.setLoopMode(LoopMode.one);
      await _rainPlayer.setVolume(0.3);
      print('Rain player initialized successfully');
    } catch (e) {
      print('Error initializing rain player: $e');
    }
  }

  Future<void> toggleRain() async {
    try {
      print('Toggle rain called. Current state: $_rainOn, isRainPlaying: ${_rainPlayer.playing}');
      
      if (_rainOn) {
        // Turn off rain
        print('Turning off rain...');
        await _rainPlayer.pause();
        await _rainPlayer.seek(Duration.zero);
        _rainOn = false;
        print('Rain turned off');
      } else {
        // Turn on rain
        print('Turning on rain...');
        
        // If this is the first time, initialize the player
        if (_rainPlayer.audioSource == null) {
          await _initializeRainPlayer();
        }
        
        print('Playing rain...');
        await _rainPlayer.play();
        
        // Wait a moment and check if it's actually playing
        await Future.delayed(const Duration(milliseconds: 300));
        if (_rainPlayer.playing) {
          print('Rain is playing successfully');
          _rainOn = true;
        } else {
          print('Rain failed to start playing');
          _rainOn = false;
        }
      }
      notifyListeners();
    } catch (e) {
      print('Error in toggleRain: $e');
      _rainOn = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _player.dispose();
    _rainPlayer.dispose();
    super.dispose();
  }
}

final audioServiceProvider = ChangeNotifierProvider<AudioService>((ref) => AudioService()); 