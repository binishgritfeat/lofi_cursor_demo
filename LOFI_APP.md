# LofiMusic Flutter App – Architecture & Features

## Overview
LofiMusic is a modern, glassmorphic, and interactive music player focused on lofi tracks. The Flutter version features a beautiful, animated UI, a responsive player, a sidebar (drawer or modal) for track selection and reordering, and a real-time audio visualizer. The app uses Dart and Flutter, leveraging packages for audio playback, visualization, and glassmorphic UI.

---

## Features

- **Lofi Track Streaming:** Fetch lofi tracks from the Deezer API (using a CORS proxy if needed), displaying cover art, artist, album, and a 30-second preview.
- **Animated Visualizer:** Real-time audio spectrum visualizer using a Flutter package (e.g., `flutter_audio_visualizer` or custom painter).
- **Glassmorphic UI:** Uses `BackdropFilter`, translucency, and animated pastel blobs for a modern, frosted-glass look.
- **Responsive Design:** Works on both mobile and desktop, with a collapsible sidebar (Drawer/Modal) for track selection.
- **Track Reordering:** Users can reorder tracks in the sidebar using drag-and-drop or up/down arrows; the order persists in local state.
- **Auto-Play Next Track:** When a track ends, the next track auto-plays (wraps around at the end).
- **Rain Sound Toggle:** Optional rain ambience can be toggled on/off, playing in the background.
- **Album Art/Visualizer Toggle:** Users can switch between album art and the visualizer view.
- **Progress Bar & Seeking:** Interactive progress bar allows seeking within the track.
- **Track Info:** Displays current track's cover, title, artist, and album.
- **Sidebar Sheet/Drawer:** Track list is shown in a Drawer or Modal on all screen sizes.
- **Glassmorphic Overlay:** A translucent overlay sits above the animated blobs, enhancing the glass effect.
- **Pastel Animated Blobs:** Multiple animated SVG or custom-painted blobs move in the background, using a pastel palette (pink, purple, teal, light blue).
- **Theme Toggle:** Light and dark mode support via Flutter’s theme system.

---

## Architecture & Folder Structure

```
lib/
  main.dart                # App entry point
  src/
    widgets/
      player.dart          # Main player UI and logic
      sidebar.dart         # Sidebar/Drawer for track list
      visualizer.dart      # Audio visualizer widget
      animated_blobs.dart  # Animated pastel blobs
      glass_overlay.dart   # Glassmorphic overlay
    models/
      track.dart           # Track data model
    services/
      deezer_api.dart      # Deezer API integration
      audio_service.dart   # Audio playback and rain sound
    providers/
      theme_provider.dart  # Theme (light/dark) provider
      track_provider.dart  # Track list, selection, reordering
    assets/
      rain.mp3             # Local rain ambience audio
      ...
    theme/
      app_theme.dart       # Theme data, pastel palette
  ...
assets/
  rain.mp3
  ...
```

---

## Main Components

### Player Widget
- Manages track list, selected track, play/pause, progress, rain toggle, view (album/visualizer), and reordering.
- Uses `just_audio` or `audioplayers` for playback.
- Uses a visualizer widget (e.g., `flutter_audio_visualizer` or custom painter).
- Sidebar (Drawer/Modal) for track list, selection, and reordering.
- Controls: Play/pause, next/prev, rain toggle, progress bar.
- Animated pastel blobs and glass overlay for background.

### Sidebar/Drawer
- Shows track list with cover, title, artist, album, and up/down arrows or drag handles for reordering.
- Clicking a track selects and plays it.

### Visualizer
- Uses a package or custom painter for pastel gradient audio visualization.
- Responsive: Sized to fit main content area, only visible in visualizer view.

### Rain Sound
- Plays `rain.mp3` in loop at low volume using a separate audio player instance.

### Theme Provider
- Light/dark mode toggle using Flutter’s theme system and a provider/state management solution.

---

## Example: Rain Sound Toggle Logic (Flutter)

```dart
bool rainOn = false;
final AudioPlayer rainPlayer = AudioPlayer();

void toggleRain() async {
  if (rainOn) {
    await rainPlayer.stop();
  } else {
    await rainPlayer.setVolume(0.3);
    await rainPlayer.setReleaseMode(ReleaseMode.loop);
    await rainPlayer.play(AssetSource('assets/rain.mp3'));
  }
  setState(() => rainOn = !rainOn);
}
```

---

## Example: Track Reordering (Flutter)

```dart
ReorderableListView(
  onReorder: (oldIndex, newIndex) {
    setState(() {
      final track = tracks.removeAt(oldIndex);
      tracks.insert(newIndex > oldIndex ? newIndex - 1 : newIndex, track);
      // Update selected index if needed
    });
  },
  children: [
    for (final track in tracks)
      ListTile(
        key: ValueKey(track.id),
        title: Text(track.title),
        // ... other info
      ),
  ],
)
```

---

## Example: Fetching Lofi Tracks (Flutter/Dart)

```dart
Future<List<Track>> fetchLofiTracks(int limit) async {
  final url = 'https://api.deezer.com/search?q=lofi&limit=$limit';
  final proxyUrl = 'https://corsproxy.io/?${Uri.encodeComponent(url)}';
  final response = await http.get(Uri.parse(proxyUrl));
  if (response.statusCode != 200) throw Exception('Failed to fetch tracks');
  final data = jsonDecode(response.body);
  return (data['data'] as List).map((track) => Track.fromJson(track)).toList();
}
```

---

## UI Libraries & Design Language

- **Flutter** (Dart, widgets, state management)
- **just_audio** or **audioplayers** (audio playback)
- **flutter_audio_visualizer** or custom painter (audio visualization)
- **provider** or **riverpod** (state management)
- **glassmorphism_ui** or custom (glassmorphic effects)
- **flutter_svg** (SVG blobs)
- **animated_widgets** (for blob animations)
- **Material Icons** or **Lucide Icons** (icon set)
- **Custom Theme** for pastel palette and glassmorphism

### Design Language

- **Glassmorphism:** Uses `BackdropFilter`, semi-transparent backgrounds, and soft borders.
- **Pastel Colors:** Pink, purple, teal, and light blue dominate the palette.
- **Animated Blobs:** SVG or custom-painted blobs with blur and opacity animate in the background.
- **Modern UI:** Rounded corners, soft shadows, and smooth transitions.
- **Accessibility:** Uses semantic widgets and accessible controls.

---

## Notable Details

- No genre filtering (tracks do not have genre info from Deezer API).
- Track reordering is local to the session (not persisted).
- Auto-play next track wraps to the first track at the end.
- Visualizer and album art are toggled via UI buttons.
- All network requests are proxied for CORS.
- No authentication or user accounts.
- No server-side code; all client-side.

---

## How to Recreate in Flutter

- Use Flutter with Dart.
- Use just_audio or audioplayers for audio playback.
- Use a visualizer package or custom painter for the audio spectrum.
- Use glassmorphism_ui or BackdropFilter for glass effects.
- Use provider/riverpod for state management.
- Fetch tracks from Deezer API (with CORS proxy).
- Implement animated pastel blobs and glass overlay in the background.
- Implement all features and UI as described above. 