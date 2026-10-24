import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import '../data/music_tracks.dart';
import '../utils/launcher.dart';

/// Calming instrumentals, grouped by what they are good for.
class MusicScreen extends StatefulWidget {
  const MusicScreen({super.key});

  @override
  State<MusicScreen> createState() => _MusicScreenState();
}

class _MusicScreenState extends State<MusicScreen> {
  final AudioPlayer _player = AudioPlayer();
  StreamSubscription<PlayerState>? _sub;

  MusicTrack? _current;
  bool _playing = false;
  double _volume = 0.5;
  MusicCategory? _filter; // null = all

  @override
  void initState() {
    super.initState();
    _player.setReleaseMode(ReleaseMode.loop);
    _sub = _player.onPlayerStateChanged.listen((state) {
      if (mounted) setState(() => _playing = state == PlayerState.playing);
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    _player.dispose(); // music stops when you leave this screen
    super.dispose();
  }

  Future<void> _toggle(MusicTrack track) async {
    try {
      if (_current?.id == track.id) {
        _playing ? await _player.pause() : await _player.resume();
        return;
      }
      setState(() => _current = track);
      await _player.setVolume(_volume);
      await _player.play(AssetSource(track.assetSource));
    } catch (_) {
      if (!mounted) return;
      setState(() => _current = null);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not play this track on your device.')),
      );
    }
  }

  Future<void> _stop() async {
    await _player.stop();
    if (mounted) setState(() => _current = null);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tracks = [
      for (final t in musicTracks)
        if (_filter == null || t.category == _filter) t,
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Calming music')),
      bottomNavigationBar: _current == null ? null : _nowPlaying(theme),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Row(
                  children: [
                    Icon(Icons.headphones_outlined, color: theme.colorScheme.primary),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Gentle instrumentals for relaxing, focusing and '
                        'sleeping. Keep the volume low.',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  children: [
                    ChoiceChip(
                      label: const Text('All'),
                      selected: _filter == null,
                      onSelected: (_) => setState(() => _filter = null),
                    ),
                    for (final c in MusicCategory.values)
                      ChoiceChip(
                        label: Text(c.label),
                        selected: _filter == c,
                        onSelected: (_) => setState(() => _filter = c),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                for (final t in tracks) _trackCard(theme, t),
                const SizedBox(height: 8),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.travel_explore),
                    title: const Text('Find more music'),
                    subtitle: const Text('Opens a YouTube search'),
                    trailing: const Icon(Icons.open_in_new, size: 18),
                    onTap: () => Launcher.open(
                      context,
                      Launcher.youtubeSearch('calming instrumental music for kids'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _trackCard(ThemeData theme, MusicTrack t) {
    final active = _current?.id == t.id;
    final playing = active && _playing;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: active ? theme.colorScheme.primary : const Color(0xFFDCE8EC),
          width: active ? 1.5 : 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primaryContainer,
          child: Icon(t.icon, color: theme.colorScheme.onPrimaryContainer),
        ),
        title: Text(t.title),
        subtitle: Text('${t.category.label}  |  ${t.description}'),
        trailing: IconButton.filledTonal(
          tooltip: playing ? 'Pause' : 'Play',
          icon: Icon(playing ? Icons.pause : Icons.play_arrow),
          onPressed: () => _toggle(t),
        ),
        onTap: () => _toggle(t),
      ),
    );
  }

  Widget _nowPlaying(ThemeData theme) {
    return Material(
      color: Colors.white,
      elevation: 8,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(Icons.graphic_eq, color: theme.colorScheme.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _current!.title,
                      style: theme.textTheme.titleSmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    tooltip: _playing ? 'Pause' : 'Play',
                    icon: Icon(_playing ? Icons.pause_circle : Icons.play_circle),
                    iconSize: 36,
                    onPressed: () => _toggle(_current!),
                  ),
                  IconButton(
                    tooltip: 'Stop',
                    icon: const Icon(Icons.stop_circle_outlined),
                    iconSize: 32,
                    onPressed: _stop,
                  ),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.volume_down, size: 20),
                  Expanded(
                    child: Slider(
                      value: _volume,
                      onChanged: (v) {
                        setState(() => _volume = v);
                        _player.setVolume(v);
                      },
                    ),
                  ),
                  const Icon(Icons.volume_up, size: 20),
                  const SizedBox(width: 8),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}