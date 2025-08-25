import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spotify_app/screens/Home.dart';
import 'package:spotify_app/screens/Search.dart';
import 'package:spotify_app/screens/YourLibrary.dart';
import 'package:spotify_app/Screens/settings_screen.dart';
import 'package:spotify_app/models/music.dart';
import 'package:spotify_app/providers/audio_provider.dart';
import 'package:spotify_app/providers/user_provider.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int currentTabIndex = 0;

  // Mini player function that uses Provider
  void miniPlayer(Music? music, {bool stop = false}) {
    final audioProvider = Provider.of<AudioProvider>(context, listen: false);
    
    if (music == null || stop) {
      audioProvider.stop();
    } else {
      audioProvider.playSong(music);
    }
  }

  // Function to play playlist
  void playPlaylist(List<Music> playlist, {int startIndex = 0}) {
    final audioProvider = Provider.of<AudioProvider>(context, listen: false);
    audioProvider.playPlaylist(playlist, startIndex: startIndex);
  }

  Widget _buildMiniPlayer() {
    return Consumer<AudioProvider>(
      builder: (context, audioProvider, child) {
        if (!audioProvider.hasActivePlayer || audioProvider.currentMusic == null) {
          return SizedBox.shrink();
        }

        Music currentSong = audioProvider.currentMusic!;
        
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
                
                // Like button
                Consumer<AudioProvider>(
                  builder: (context, audioProvider, child) {
                    bool isLiked = audioProvider.isLiked(currentSong);
                    return IconButton(
                      icon: Icon(
                        isLiked ? Icons.favorite : Icons.favorite_border,
                        color: isLiked ? Colors.red : Colors.white,
                      ),
                      onPressed: () => audioProvider.toggleLike(currentSong),
                    );
                  },
                ),
                
                // Control buttons
                IconButton(
                  icon: Icon(Icons.skip_previous, color: Colors.white),
                  onPressed: () => audioProvider.playPrevious(),
                ),
                IconButton(
                  icon: audioProvider.isLoading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Icon(
                          audioProvider.isPlaying ? Icons.pause : Icons.play_arrow,
                          color: Colors.white,
                        ),
                  onPressed: audioProvider.isLoading ? null : () => audioProvider.togglePlayPause(),
                ),
                IconButton(
                  icon: Icon(Icons.skip_next, color: Colors.white),
                  onPressed: () => audioProvider.playNext(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showFullPlayer() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildFullPlayerModal(),
    );
  }

  Widget _buildFullPlayerModal() {
    return Consumer<AudioProvider>(
      builder: (context, audioProvider, child) {
        if (audioProvider.currentMusic == null) return const SizedBox.shrink();
        
        Music currentSong = audioProvider.currentMusic!;
        
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
                
                // Header
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Icon(Icons.keyboard_arrow_down, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Column(
                        children: [
                          Text(
                            'Now Playing',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${audioProvider.currentSongIndex + 1} of ${audioProvider.currentPlaylist.length}',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: Icon(Icons.more_vert, color: Colors.white),
                        onPressed: () => _showSongOptions(currentSong),
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
                
                // Song info and like button
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              currentSong.name,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
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
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          audioProvider.isLiked(currentSong) ? Icons.favorite : Icons.favorite_border,
                          color: audioProvider.isLiked(currentSong) ? Colors.red : Colors.white,
                          size: 32,
                        ),
                        onPressed: () => audioProvider.toggleLike(currentSong),
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
                          value: audioProvider.totalDuration.inMilliseconds > 0
                              ? audioProvider.currentPosition.inMilliseconds.toDouble()
                              : 0.0,
                          max: audioProvider.totalDuration.inMilliseconds.toDouble(),
                          onChanged: (value) {
                            audioProvider.seekTo(Duration(milliseconds: value.toInt()));
                          },
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            audioProvider.formatDuration(audioProvider.currentPosition),
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                          Text(
                            audioProvider.formatDuration(audioProvider.totalDuration),
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
                          color: audioProvider.isShuffleOn ? Colors.green : Colors.grey,
                          size: 28,
                        ),
                        onPressed: () => audioProvider.toggleShuffle(),
                      ),
                      IconButton(
                        icon: Icon(Icons.skip_previous, color: Colors.white, size: 40),
                        onPressed: () => audioProvider.playPrevious(),
                      ),
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: audioProvider.isLoading
                              ? SizedBox(
                                  width: 30,
                                  height: 30,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 3,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                                  ),
                                )
                              : Icon(
                                  audioProvider.isPlaying ? Icons.pause : Icons.play_arrow,
                                  color: Colors.black,
                                  size: 35,
                                ),
                          onPressed: audioProvider.isLoading ? null : () => audioProvider.togglePlayPause(),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.skip_next, color: Colors.white, size: 40),
                        onPressed: () => audioProvider.playNext(),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.repeat,
                          color: audioProvider.isRepeatOn ? Colors.green : Colors.grey,
                          size: 28,
                        ),
                        onPressed: () => audioProvider.toggleRepeat(),
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
                            value: audioProvider.volume,
                            onChanged: (value) => audioProvider.setVolume(value),
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
      },
    );
  }

  void _showSongOptions(Music song) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey.shade900,
      builder: (context) => Container(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.playlist_add, color: Colors.white),
              title: Text('Add to Playlist', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _showAddToPlaylistDialog(song);
              },
            ),
            ListTile(
              leading: Icon(Icons.share, color: Colors.white),
              title: Text('Share', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement sharing
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Share functionality coming soon!')),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.info, color: Colors.white),
              title: Text('Song Info', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _showSongInfo(song);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAddToPlaylistDialog(Music song) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey.shade800,
        title: Text('Add to Playlist', style: TextStyle(color: Colors.white)),
        content: Container(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: userProvider.userPlaylists.length,
            itemBuilder: (context, index) {
              var playlist = userProvider.userPlaylists[index];
              return ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Image.network(
                    playlist['image'],
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                  ),
                ),
                title: Text(
                  playlist['name'],
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  userProvider.addSongToPlaylist(playlist['id'], song);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Added to ${playlist['name']}')),
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }

  void _showSongInfo(Music song) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey.shade800,
        title: Text('Song Information', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Title: ${song.name}', style: TextStyle(color: Colors.white)),
            SizedBox(height: 8),
            Text('Description: ${song.desc}', style: TextStyle(color: Colors.white)),
            SizedBox(height: 8),
            Text('Audio URL: ${song.audioURL}', style: TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: currentTabIndex,
        children: [
          Home(miniPlayer),
          Search(miniPlayer),
          YourLibrary(miniPlayer),
        ],
      ),
      backgroundColor: Colors.black,
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildMiniPlayer(),
          BottomNavigationBar(
            currentIndex: currentTabIndex,
            onTap: (currentIndex) {
              setState(() {
                currentTabIndex = currentIndex;
              });
            },
            selectedLabelStyle: const TextStyle(color: Colors.white),
            selectedItemColor: Colors.white,
            backgroundColor: Colors.black45,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home, color: Colors.white),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.search, color: Colors.white),
                label: 'Search',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.library_books, color: Colors.white),
                label: 'Your library',
              )
            ],
          ),
        ],
      ),
    );
  }
}