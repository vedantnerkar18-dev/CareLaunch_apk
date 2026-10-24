import 'package:flutter/material.dart';

enum MusicCategory {
  calm('Calm'),
  focus('Focus'),
  sleep('Sleep');

  final String label;
  const MusicCategory(this.label);
}

class MusicTrack {
  final String id;
  final String title;
  final String description;
  final MusicCategory category;
  final IconData icon;

  const MusicTrack({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.icon,
  });

  /// Relative to the assets folder (the player adds "assets/" itself).
  String get assetSource => 'audio/$id.mp3';

  /// Where the file lives in the project (used by tests).
  String get projectPath => 'assets/audio/$id.mp3';
}

/// Original instrumentals made for CareLaunch. Each is a 48-second loop.
const List<MusicTrack> musicTracks = [
  MusicTrack(
    id: 'soft_clouds',
    title: 'Soft Clouds',
    description: 'A slow, warm pad that drifts gently',
    category: MusicCategory.calm,
    icon: Icons.cloud_outlined,
  ),
  MusicTrack(
    id: 'ocean_waves',
    title: 'Ocean Waves',
    description: 'Waves rolling in and out',
    category: MusicCategory.calm,
    icon: Icons.waves,
  ),
  MusicTrack(
    id: 'singing_bowls',
    title: 'Singing Bowls',
    description: 'Soft bowl tones that ring and fade',
    category: MusicCategory.calm,
    icon: Icons.spa_outlined,
  ),
  MusicTrack(
    id: 'steady_focus',
    title: 'Steady Focus',
    description: 'A low hum with a slow, gentle pulse',
    category: MusicCategory.focus,
    icon: Icons.center_focus_strong_outlined,
  ),
  MusicTrack(
    id: 'soft_keys',
    title: 'Soft Keys',
    description: 'Sparse, quiet piano-like notes',
    category: MusicCategory.focus,
    icon: Icons.piano,
  ),
  MusicTrack(
    id: 'gentle_rain',
    title: 'Gentle Rain',
    description: 'Steady rain to settle the mind',
    category: MusicCategory.sleep,
    icon: Icons.water_drop_outlined,
  ),
  MusicTrack(
    id: 'music_box',
    title: 'Music Box Lullaby',
    description: 'A slow, tinkling bedtime tune',
    category: MusicCategory.sleep,
    icon: Icons.nightlight_outlined,
  ),
];