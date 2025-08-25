import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:spotify_app/models/music.dart';
import 'package:spotify_app/services/database_helper.dart';
import 'package:spotify_app/services/preferences_helper.dart';
import 'package:spotify_app/services/offline_service.dart';
import 'dart:async';

class AudioProvider with ChangeNotifier {
  // Audio player instance
  late AudioPlayer _audioPlayer;

  // Current playback state
  List<Music> _currentPlaylist = [];
  int _currentSongIndex = 0;
  Music? _currentMusic;
  bool _isPlaying = false;
  bool _isLoading = false;
  bool _hasActivePlayer = false;

  // Audio properties
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  double _volume = 1.0;

  // Playback modes
  bool _isShuffleOn = false;
  bool _isRepeatOn = false;
  bool _isOfflineMode = false;

  // Stream subscriptions
  StreamSubscription? _playerStateSubscription;
  StreamSubscription? _durationSubscription;
  StreamSubscription? _positionSubscription;
  Timer? _saveStateTimer;

  // Recently played and favorites
  List<Music> _recentlyPlayed = [];
  List<Music> _likedSongs = [];
  final int _maxRecentlyPlayed = 20;

  // Constructor
  AudioProvider() {
    _initializeAudioPlayer();
    _loadSavedState();
  }

  // Getters
  List<Music> get currentPlaylist => _currentPlaylist;
  int get currentSongIndex => _currentSongIndex;
  Music? get currentMusic => _currentMusic;
  bool get isPlaying => _isPlaying;
  bool get isLoading => _isLoading;
  bool get hasActivePlayer => _hasActivePlayer;
  Duration get currentPosition => _currentPosition;
  Duration get totalDuration => _totalDuration;
  double get volume => _volume;
  bool get isShuffleOn => _isShuffleOn;
  bool get isRepeatOn => _isRepeatOn;
  bool get isOfflineMode => _isOfflineMode;
  List<Music> get recentlyPlayed => _recentlyPlayed;
  List<Music> get likedSongs => _likedSongs;

  void _initializeAudioPlayer() {
    _audioPlayer = AudioPlayer();
    _setupAudioListeners();
    _loadUserPreferences();
  }

  void _setupAudioListeners() {
    // Player state changes
    _playerStateSubscription = _audioPlayer.playerStateStream.listen((state) {
      _isPlaying = state.playing;
      _isLoading = state.processingState == ProcessingState.loading ||
          state.processingState == ProcessingState.buffering;

      // Auto-play next song when current completes
      if (state.processingState == ProcessingState.completed) {
        playNext();
      }

      // Save state periodically
      _savePlaybackState();
      notifyListeners();
    });

    // Duration changes
    _durationSubscription = _audioPlayer.durationStream.listen((duration) {
      if (duration != null) {
        _totalDuration = duration;
        notifyListeners();
      }
    });

    // Position changes
    _positionSubscription = _audioPlayer.positionStream.listen((position) {
      _currentPosition = position;

      // Save position every 10 seconds
      if (position.inSeconds % 10 == 0) {
        PreferencesHelper.setCurrentPlaybackPosition(position);
      }

      notifyListeners();
    });
  }

  // Load user preferences
  Future<void> _loadUserPreferences() async {
    try {
      _volume = await PreferencesHelper.getDefaultVolume();
      _isShuffleOn = await PreferencesHelper.getShuffleMode();
      _isRepeatOn = await PreferencesHelper.getRepeatMode();
      _isOfflineMode = await PreferencesHelper.getOfflineMode();

      await _audioPlayer.setVolume(_volume);
      await _audioPlayer.setLoopMode(_isRepeatOn ? LoopMode.one : LoopMode.off);

      // Load saved data from database
      _likedSongs = await DatabaseHelper.getLikedSongs();
      _recentlyPlayed = await DatabaseHelper.getRecentlyPlayed();

      notifyListeners();
    } catch (e) {
      print('Error loading preferences: $e');
    }
  }

  // Load saved playback state
  Future<void> _loadSavedState() async {
    try {
      Map<String, dynamic>? savedSong =
          await PreferencesHelper.getCurrentSong();
      if (savedSong != null) {
        _currentMusic = Music(
          savedSong['name'],
          savedSong['image'],
          savedSong['desc'],
          savedSong['audioURL'],
        );

        List<Map<String, dynamic>> savedPlaylist =
            await PreferencesHelper.getCurrentPlaylist();
        if (savedPlaylist.isNotEmpty) {
          _currentPlaylist = savedPlaylist
              .map((song) => Music(
                    song['name'],
                    song['image'],
                    song['desc'],
                    song['audioURL'],
                  ))
              .toList();

          _currentSongIndex = _currentPlaylist
              .indexWhere((song) => song.name == _currentMusic!.name);
          if (_currentSongIndex == -1) _currentSongIndex = 0;
        }

        _hasActivePlayer = true;

        // Load saved position
        Duration savedPosition =
            await PreferencesHelper.getCurrentPlaybackPosition();

        // Set up the audio player with saved state
        await _audioPlayer.setUrl(_currentMusic!.audioURL);
        if (savedPosition.inSeconds > 0) {
          await _audioPlayer.seek(savedPosition);
        }
      }
    } catch (e) {
      print('Error loading saved state: $e');
    }
  }

  // Save current playback state
  Future<void> _savePlaybackState() async {
    try {
      if (_currentMusic != null) {
        await PreferencesHelper.setCurrentSong({
          'name': _currentMusic!.name,
          'image': _currentMusic!.image,
          'desc': _currentMusic!.desc,
          'audioURL': _currentMusic!.audioURL,
        });

        List<Map<String, dynamic>> playlistData = _currentPlaylist
            .map((song) => {
                  'name': song.name,
                  'image': song.image,
                  'desc': song.desc,
                  'audioURL': song.audioURL,
                })
            .toList();

        await PreferencesHelper.setCurrentPlaylist(playlistData);
        await PreferencesHelper.setCurrentPlaybackPosition(_currentPosition);
      }
    } catch (e) {
      print('Error saving playback state: $e');
    }
  }

  // Play a single song
  Future<void> playSong(Music music) async {
    try {
      _currentMusic = music;
      _hasActivePlayer = true;
      _isLoading = true;
      notifyListeners();

      // Add to recently played
      await _addToRecentlyPlayed(music);

      // Create single-song playlist
      _currentPlaylist = [music];
      _currentSongIndex = 0;

      // Check if song is available offline
      String? offlinePath;
      if (_isOfflineMode) {
        offlinePath = await OfflineService.getOfflinePath(music.name);
      }

      String audioUrl = offlinePath ?? music.audioURL;
      await _audioPlayer.setUrl(audioUrl);
      await _audioPlayer.play();

      _savePlaybackState();
    } catch (e) {
      print('Error playing song: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  // Play a playlist starting from specific index
  Future<void> playPlaylist(List<Music> playlist, {int startIndex = 0}) async {
    if (playlist.isEmpty) return;

    try {
      _currentPlaylist = List.from(playlist);
      _currentSongIndex = startIndex.clamp(0, playlist.length - 1);
      _currentMusic = playlist[_currentSongIndex];
      _hasActivePlayer = true;
      _isLoading = true;
      notifyListeners();

      // Add to recently played
      await _addToRecentlyPlayed(_currentMusic!);

      // Check if song is available offline
      String? offlinePath;
      if (_isOfflineMode) {
        offlinePath = await OfflineService.getOfflinePath(_currentMusic!.name);
      }

      String audioUrl = offlinePath ?? _currentMusic!.audioURL;
      await _audioPlayer.setUrl(audioUrl);
      await _audioPlayer.play();

      _savePlaybackState();
    } catch (e) {
      print('Error playing playlist: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  // Toggle play/pause
  Future<void> togglePlayPause() async {
    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
      } else {
        await _audioPlayer.play();
      }
    } catch (e) {
      print('Error toggling play/pause: $e');
    }
  }

  // Play next song
  Future<void> playNext() async {
    if (_currentPlaylist.isEmpty) return;

    if (_isShuffleOn) {
      // Shuffle mode: random song
      _currentSongIndex =
          DateTime.now().millisecondsSinceEpoch % _currentPlaylist.length;
    } else {
      // Normal mode: next song
      _currentSongIndex = (_currentSongIndex + 1) % _currentPlaylist.length;
    }

    await _loadCurrentSong();
  }

  // Play previous song
  Future<void> playPrevious() async {
    if (_currentPlaylist.isEmpty) return;

    if (_currentPosition.inSeconds > 3) {
      // Restart current song if more than 3 seconds in
      await seekTo(Duration.zero);
    } else {
      // Go to previous song
      _currentSongIndex = (_currentSongIndex - 1 + _currentPlaylist.length) %
          _currentPlaylist.length;
      await _loadCurrentSong();
    }
  }

  // Load current song in playlist
  Future<void> _loadCurrentSong() async {
    if (_currentPlaylist.isEmpty) return;

    try {
      _currentMusic = _currentPlaylist[_currentSongIndex];
      _isLoading = true;
      notifyListeners();

      await _addToRecentlyPlayed(_currentMusic!);

      // Check if song is available offline
      String? offlinePath;
      if (_isOfflineMode) {
        offlinePath = await OfflineService.getOfflinePath(_currentMusic!.name);
      }

      String audioUrl = offlinePath ?? _currentMusic!.audioURL;
      await _audioPlayer.setUrl(audioUrl);
      if (_isPlaying) {
        await _audioPlayer.play();
      }

      _savePlaybackState();
    } catch (e) {
      print('Error loading current song: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  // Seek to position
  Future<void> seekTo(Duration position) async {
    try {
      await _audioPlayer.seek(position);
    } catch (e) {
      print('Error seeking: $e');
    }
  }

  // Set volume
  Future<void> setVolume(double volume) async {
    try {
      _volume = volume.clamp(0.0, 1.0);
      await _audioPlayer.setVolume(_volume);
      await PreferencesHelper.setDefaultVolume(_volume);
      notifyListeners();
    } catch (e) {
      print('Error setting volume: $e');
    }
  }

  // Toggle shuffle
  void toggleShuffle() {
    _isShuffleOn = !_isShuffleOn;
    PreferencesHelper.setShuffleMode(_isShuffleOn);
    notifyListeners();
  }

  // Toggle repeat
  void toggleRepeat() {
    _isRepeatOn = !_isRepeatOn;
    _audioPlayer.setLoopMode(_isRepeatOn ? LoopMode.one : LoopMode.off);
    PreferencesHelper.setRepeatMode(_isRepeatOn);
    notifyListeners();
  }

  // Toggle offline mode
  void toggleOfflineMode() {
    _isOfflineMode = !_isOfflineMode;
    PreferencesHelper.setOfflineMode(_isOfflineMode);
    notifyListeners();
  }

  // Stop playback
  Future<void> stop() async {
    try {
      await _audioPlayer.stop();
      _hasActivePlayer = false;
      _currentMusic = null;
      _isPlaying = false;
      await PreferencesHelper.setCurrentSong(null);
      notifyListeners();
    } catch (e) {
      print('Error stopping: $e');
    }
  }

  // Add song to recently played
  Future<void> _addToRecentlyPlayed(Music music) async {
    try {
      await DatabaseHelper.addToRecentlyPlayed(music);
      _recentlyPlayed = await DatabaseHelper.getRecentlyPlayed();
      notifyListeners();
      if (_recentlyPlayed.length > _maxRecentlyPlayed){
      _recentlyPlayed = _recentlyPlayed.take(_maxRecentlyPlayed).toList() ;
      }
    } catch (e) {
      print('Error adding to recently played: $e');
    }
  }

  // Like/Unlike song
  Future<void> toggleLike(Music music) async {
    try {
      bool wasLiked = await DatabaseHelper.isSongLiked(music.name);

      if (wasLiked) {
        await DatabaseHelper.removeFromLikedSongs(music.name);
      } else {
        await DatabaseHelper.addToLikedSongs(music);
      }

      _likedSongs = await DatabaseHelper.getLikedSongs();
      notifyListeners();
    } catch (e) {
      print('Error toggling like: $e');
    }
  }

  // Check if song is liked
  bool isLiked(Music music) {
    return _likedSongs.any((song) => song.name == music.name);
  }

  // Clear recently played
  Future<void> clearRecentlyPlayed() async {
    try {
      // Clear from database
      // List<Music> recent = await DatabaseHelper.getRecentlyPlayed();
      // for (Music song in recent) {
      //    // TODO: Clear each from database when method is implemented
      //   // This would require a method to clear all recently played
      //   // For now, we'll implement it differently
      // }
      _recentlyPlayed.clear();
      notifyListeners();
    } catch (e) {
      print('Error clearing recently played: $e');
    }
  }

  // Get formatted time
  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));

    if (duration.inHours > 0) {
      return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
    } else {
      return "$twoDigitMinutes:$twoDigitSeconds";
    }
  }

  // Initialize with some sample data
  void initializeSampleData(List<Music> allMusic) {
    // Sample data will be loaded from database instead
    _loadUserPreferences();
  }

  @override
  void dispose() {
    _saveStateTimer?.cancel();
    _playerStateSubscription?.cancel();
    _durationSubscription?.cancel();
    _positionSubscription?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }
}
