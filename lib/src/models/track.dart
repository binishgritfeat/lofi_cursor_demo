class Track {
  final int id;
  final String title;
  final String artist;
  final String album;
  final String cover;
  final String preview;
  final int duration;

  Track({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.cover,
    required this.preview,
    required this.duration,
  });

  factory Track.fromJson(Map<String, dynamic> json) {
    return Track(
      id: json['id'] as int,
      title: json['title'] as String,
      artist: json['artist']['name'] as String,
      album: json['album']['title'] as String,
      cover: json['album']['cover_medium'] as String,
      preview: json['preview'] as String,
      duration: json['duration'] as int,
    );
  }
} 