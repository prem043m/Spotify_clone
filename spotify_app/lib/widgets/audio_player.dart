import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:spotify_app/models/music.dart';
import 'dart:async';

class EnhancedAudioPlayer extends StatefulWidget {
  final List<Music> playlist;
  final int currentIndex;
  final Function(Music?, {bool stop}) onMusicChanged;

  const EnhancedAudioPlayer({
    Key? key,
    required this.playlist,
    required this.currentIndex,
    required this.onMusicChanged,
  }) : super(key: key);

  @override
  State<EnhancedAudioPlayer> createState() => _EnhancedAudioPlayerState();
}

class _EnhancedAudioPlayerState extends State<EnhancedAudioPlayer> {
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  bool _isLoading = false;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  double _volume = 1.0;
  bool _isShuffleOn = false;
  bool _isRepeatOn = false;
  int _currentSongIndex = 0;
  Timer? _positionTimer;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _currentSongIndex = widget.currentIndex;
    _setupAudioPlayer();
    _loadCurrentSong();
  }

  @override
  void dispose() {
    _positionTimer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _setupAudioPlayer() {
    // Listen to player state changes
    _audioPlayer.playerStateStream.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state.playing;
          _isLoading = state.processingState == ProcessingState.loading ||
                      state.processingState == ProcessingState.buffering;
        });
        
        // Auto-play next song when current song completes
        if (state.processingState == ProcessingState.completed) {
          _playNext();
        }
      }
    });

    // Listen to duration changes
    _audioPlayer.durationStream.listen((duration) {
      if (mounted && duration != null) {
        setState(() {
          _totalDuration = duration;
        });
      }
    });

    // Listen to position changes
    _audioPlayer.positionStream.listen((position) {
      if (mounted) {
        setState(() {
          _currentPosition = position;
        });
      }
    });
  }

  Future<void> _loadCurrentSong() async {
    if (widget.playlist.isEmpty) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      Music currentSong = widget.playlist[_currentSongIndex];
      await _audioPlayer.setUrl(currentSong.audioURL);
      widget.onMusicChanged(currentSong);
    } catch (e) {
      print('Error loading song: $e');
      _showErrorSnackBar('Failed to load song');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _togglePlayPause() async {
    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
      } else {
        await _audioPlayer.play();
      }
    } catch (e) {
      print('Error toggling play/pause: $e');
      _showErrorSnackBar('Playback error occurred');
    }
  }

  Future<void> _playNext() async {
    if (widget.playlist.isEmpty) return;
    
    if (_isShuffleOn) {
      // Shuffle mode: play random song
      _currentSongIndex = DateTime.now().millisecondsSinceEpoch % widget.playlist.length;
    } else {
      // Normal mode: play next song
      _currentSongIndex = (_currentSongIndex + 1) % widget.playlist.length;
    }
    
    await _loadCurrentSong();
    if (_isPlaying) {
      await _audioPlayer.play();
    }
  }

  Future<void> _playPrevious() async {
    if (widget.playlist.isEmpty) return;
    
    if (_currentPosition.inSeconds > 3) {
      // If more than 3 seconds into song, restart current song
      await _audioPlayer.seek(Duration.zero);
    } else {
      // Otherwise, go to previous song
      _currentSongIndex = (_currentSongIndex - 1 + widget.playlist.length) % widget.playlist.length;
      await _loadCurrentSong();
      if (_isPlaying) {
        await _audioPlayer.play();
      }
    }
  }

  Future<void> _seekTo(Duration position) async {
    try {
      await _audioPlayer.seek(position);
    } catch (e) {
      print('Error seeking: $e');
    }
  }

  Future<void> _setVolume(double volume) async {
    try {
      await _audioPlayer.setVolume(volume);
      setState(() {
        _volume = volume;
      });
    } catch (e) {
      print('Error setting volume: $e');
    }
  }

  void _toggleShuffle() {
    setState(() {
      _isShuffleOn = !_isShuffleOn;
    });
  }

  void _toggleRepeat() {
    setState(() {
      _isRepeatOn = !_isRepeatOn;
    });
    
    // Set repeat mode
    _audioPlayer.setLoopMode(_isRepeatOn ? LoopMode.one : LoopMode.off);
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  Widget _buildMiniPlayer() {
    if (widget.playlist.isEmpty) return SizedBox.shrink();
    
    Music currentSong = widget.playlist[_currentSongIndex];
    
    return GestureDetector(
      onTap: () => _showFullPlayer(),
      child: Container(
        height: 60,
        color: Colors.grey.shade900,
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            // Song artwork
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Image.network(
                currentSong.image,
                width: 40,
                height: 40,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 40,
                    height: 40,
                    color: Colors.grey.shade600,
                    child: Icon(Icons.music_note, color: Colors.white, size: 20),
                  );
                },
              ),
            ),
            SizedBox(width: 12),
            
            // Song info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    currentSong.name,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    currentSong.desc,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            
            // Control buttons
            IconButton(
              icon: Icon(Icons.skip_previous, color: Colors.white),
              onPressed: _playPrevious,
            ),
            IconButton(
              icon: _isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Icon(
                      _isPlaying ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                    ),
              onPressed: _isLoading ? null : _togglePlayPause,
            ),
            IconButton(
              icon: Icon(Icons.skip_next, color: Colors.white),
              onPressed: _playNext,
            ),
          ],
        ),
      ),
    );
  }

  void _showFullPlayer() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildFullPlayer(),
    );
  }

  Widget _buildFullPlayer() {
    if (widget.playlist.isEmpty) return SizedBox.shrink();
    
    Music currentSong = widget.playlist[_currentSongIndex];
    
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.blueGrey.shade800,
            Colors.black,
          ],
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade600,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Header with close button
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.keyboard_arrow_down, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Text(
                    'Now Playing',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.more_vert, color: Colors.white),
                    onPressed: () {
                      // TODO: Show options menu
                    },
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 20),
            
            // Large artwork
            Container(
              width: 300,
              height: 300,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  currentSong.image,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey.shade600,
                      child: Icon(Icons.music_note, color: Colors.white, size: 100),
                    );
                  },
                ),
              ),
            ),
            
            SizedBox(height: 30),
            
            // Song info
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  Text(
                    currentSong.name,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8),
                  Text(
                    currentSong.desc,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 30),
            
            // Progress bar
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: Colors.white,
                      inactiveTrackColor: Colors.grey.shade600,
                      thumbColor: Colors.white,
                      overlayColor: Colors.white.withOpacity(0.2),
                      trackHeight: 3,
                    ),
                    child: Slider(
                      value: _currentPosition.inMilliseconds.toDouble(),
                      max: _totalDuration.inMilliseconds.toDouble(),
                      onChanged: (value) {
                        _seekTo(Duration(milliseconds: value.toInt()));
                      },
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDuration(_currentPosition),
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      Text(
                        _formatDuration(_totalDuration),
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 20),
            
            // Main controls
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.shuffle,
                      color: _isShuffleOn ? Colors.green : Colors.grey,
                      size: 28,
                    ),
                    onPressed: _toggleShuffle,
                  ),
                  IconButton(
                    icon: Icon(Icons.skip_previous, color: Colors.white, size: 40),
                    onPressed: _playPrevious,
                  ),
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: _isLoading
                          ? SizedBox(
                              width: 30,
                              height: 30,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                              ),
                            )
                          : Icon(
                              _isPlaying ? Icons.pause : Icons.play_arrow,
                              color: Colors.black,
                              size: 35,
                            ),
                      onPressed: _isLoading ? null : _togglePlayPause,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.skip_next, color: Colors.white, size: 40),
                    onPressed: _playNext,
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.repeat,
                      color: _isRepeatOn ? Colors.green : Colors.grey,
                      size: 28,
                    ),
                    onPressed: _toggleRepeat,
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 20),
            
            // Volume control
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Icon(Icons.volume_down, color: Colors.grey),
                  Expanded(
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: Colors.white,
                        inactiveTrackColor: Colors.grey.shade600,
                        thumbColor: Colors.white,
                        overlayColor: Colors.white.withOpacity(0.2),
                        trackHeight: 3,
                      ),
                      child: Slider(
                        value: _volume,
                        onChanged: (value) => _setVolume(value),
                      ),
                    ),
                  ),
                  Icon(Icons.volume_up, color: Colors.grey),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildMiniPlayer();
  }
}