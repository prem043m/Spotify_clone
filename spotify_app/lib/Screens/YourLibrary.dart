import 'package:flutter/material.dart';
import 'package:spotify_app/models/music.dart';
import 'package:spotify_app/services/music_operations.dart';

class YourLibrary extends StatefulWidget {
  final Function(Music) _miniPlayer;

  const YourLibrary(this._miniPlayer, {super.key});

  @override
  State<YourLibrary> createState() => _YourLibraryState();
}

class _YourLibraryState extends State<YourLibrary>
    with TickerProviderStateMixin {
  late TabController _tabController;
  List<Music> get _recentlyPlayed => _recentlyPlayed;
  List<Music> get _likedSongs => _likedSongs;
  List<Map<String, dynamic>> _playlists = [];
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadLibraryData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _handleSongPlay(Music song) {
    setState(() {
      _recentlyPlayed.remove(song);
      _recentlyPlayed.insert(0, song);

      if (_recentlyPlayed.length > 10) {
        _recentlyPlayed.removeRange(10, _recentlyPlayed.length);
      }
    });
  }

  void _toggleLike(Music song) {
    setState(() {
      if (_likedSongs.contains(song)) {
        _likedSongs.remove(song);
      } else {
        _likedSongs.add(song);
      }
    });
  }

  void _loadLibraryData() {
    // Simulate loading user's library data
    List<Music> allMusic = MusicOperations.getMusic();

    setState(() {
      // Simulate user playlists
      _playlists = [
        {
          'name': 'My Favorites',
          'songs': allMusic.take(2).toList(),
          'image':
              'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=300&h=300&fit=crop',
          'description': '2 songs'
        },
        {
          'name': 'Workout Mix',
          'songs': [allMusic.first],
          'image':
              'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=300&h=300&fit=crop',
          'description': '1 song'
        },
        {
          'name': 'Chill Vibes',
          'songs': allMusic.skip(1).take(2).toList(),
          'image':
              'https://images.unsplash.com/photo-1514525253161-7a46d19cd819?w=300&h=300&fit=crop',
          'description': '2 songs'
        },
      ];
    });
  }

  Widget _buildFilterChips() {
    List<String> filters = [
      'All',
      'Playlists',
      'Artists',
      'Albums',
      'Downloaded'
    ];

    return Container(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          String filter = filters[index];
          bool isSelected = _selectedFilter == filter;

          return Padding(
            padding: EdgeInsets.only(right: 12),
            child: FilterChip(
              label: Text(
                filter,
                style: TextStyle(
                  color: isSelected ? Colors.black : Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedFilter = filter;
                });
              },
              backgroundColor: Colors.grey.shade800,
              selectedColor: Colors.white,
              side: BorderSide.none,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLibraryHeader() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.grey.shade700,
            child: Icon(Icons.person, color: Colors.white),
          ),
          SizedBox(width: 12),
          Text(
            'Your Library',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Spacer(),
          IconButton(
            icon: Icon(Icons.search, color: Colors.white),
            onPressed: () {
              // TODO: Implement library search
            },
          ),
          IconButton(
            icon: Icon(Icons.add, color: Colors.white),
            onPressed: () {
              _showCreatePlaylistDialog();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccessRow() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildQuickAccessCard(
              'Liked Songs',
              Icons.favorite,
              Colors.purple,
              '${_likedSongs.length} songs',
              () => _showLikedSongs(),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: _buildQuickAccessCard(
              'Recently Played',
              Icons.history,
              Colors.green,
              '${_recentlyPlayed.length} songs',
              () => _showRecentlyPlayed(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccessCard(String title, IconData icon, Color color,
      String subtitle, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade900,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaylistCard(Map<String, dynamic> playlist) {
    return Card(
      color: Colors.grey.shade900,
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Image.network(
            playlist['image'],
            width: 50,
            height: 50,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 50,
                height: 50,
                color: Colors.grey.shade600,
                child: Icon(Icons.playlist_play, color: Colors.white),
              );
            },
          ),
        ),
        title: Text(
          playlist['name'],
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          playlist['description'],
          style: TextStyle(color: Colors.grey),
        ),
        trailing: PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, color: Colors.grey),
          color: Colors.grey.shade800,
          onSelected: (value) {
            switch (value) {
              case 'edit':
                _editPlaylist(playlist);
                break;
              case 'delete':
                _deletePlaylist(playlist);
                break;
              case 'share':
                _sharePlaylist(playlist);
                break;
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'edit',
              child: Text('Edit', style: TextStyle(color: Colors.white)),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Text('Delete', style: TextStyle(color: Colors.white)),
            ),
            PopupMenuItem(
              value: 'share',
              child: Text('Share', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
        onTap: () => _showPlaylistSongs(playlist),
      ),
    );
  }

  Widget _buildPlaylistsList() {
    List<Map<String, dynamic>> filteredPlaylists = _playlists;

    if (_selectedFilter == 'Playlists' || _selectedFilter == 'All') {
      // Show only playlists
      filteredPlaylists = _playlists;
    } else if (_selectedFilter == 'Artists') {
      // TODO: Filter by artists
      filteredPlaylists = [];
    } else if (_selectedFilter == 'Albums') {
      // TODO: Filter by albums
      filteredPlaylists = [];
    } else if (_selectedFilter == 'Downloaded') {
      // TODO: Filter by downloaded content
      filteredPlaylists = [];
    }

    if (filteredPlaylists.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(Icons.library_music, color: Colors.grey, size: 64),
              SizedBox(height: 16),
              Text(
                'No ${_selectedFilter.toLowerCase()} found',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: filteredPlaylists.length,
      itemBuilder: (context, index) {
        return _buildPlaylistCard(filteredPlaylists[index]);
      },
    );
  }

  void _showCreatePlaylistDialog() {
    TextEditingController nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey.shade800,
        title: Text('Create Playlist', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: nameController,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Enter playlist name',
            hintStyle: TextStyle(color: Colors.grey),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                _createPlaylist(nameController.text);
                Navigator.pop(context);
              }
            },
            child: Text('Create', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _createPlaylist(String name) {
    setState(() {
      _playlists.add({
        'name': name,
        'songs': <Music>[],
        'image':
            'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=300&h=300&fit=crop',
        'description': '0 songs'
      });
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Playlist "$name" created'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _editPlaylist(Map<String, dynamic> playlist) {
    // TODO: Implement playlist editing
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Edit playlist: ${playlist['name']}')),
    );
  }

  void _deletePlaylist(Map<String, dynamic> playlist) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey.shade800,
        title: Text('Delete Playlist', style: TextStyle(color: Colors.white)),
        content: Text(
          'Are you sure you want to delete "${playlist['name']}"?',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _playlists.remove(playlist);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Playlist deleted'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _sharePlaylist(Map<String, dynamic> playlist) {
    // TODO: Implement playlist sharing
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Share playlist: ${playlist['name']}')),
    );
  }

  void _showPlaylistSongs(Map<String, dynamic> playlist) {
    List<Music> songs = playlist['songs'];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey.shade900,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Column(
          children: [
            Container(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      playlist['image'],
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          playlist['name'],
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          playlist['description'],
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: songs.length,
                itemBuilder: (context, index) {
                  Music song = songs[index];
                  return ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Image.network(
                        song.image,
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                      ),
                    ),
                    title: Text(
                      song.name,
                      style: TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      song.desc,
                      style: TextStyle(color: Colors.grey),
                    ),
                    trailing: Icon(Icons.play_arrow, color: Colors.white),
                    onTap: () {
                      widget._miniPlayer(song);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLikedSongs() {
    // Navigate to liked songs or show in modal
    _showSongsList('Liked Songs', _likedSongs);
  }

  void _showRecentlyPlayed() {
    // Navigate to recently played or show in modal
    _showSongsList('Recently Played', _recentlyPlayed);
  }

  void _showSongsList(String title, List<Music> songs) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey.shade900,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Column(
          children: [
            Container(
              padding: EdgeInsets.all(16),
              child: Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: songs.length,
                itemBuilder: (context, index) {
                  Music song = songs[index];
                  return ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Image.network(
                        song.image,
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                      ),
                    ),
                    title: Text(
                      song.name,
                      style: TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      song.desc,
                      style: TextStyle(color: Colors.grey),
                    ),
                    trailing: IconButton(
                      onPressed: () {
                        _toggleLike(song);
                      },
                      icon: Icon(
                          _likedSongs.contains(song)
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: _likedSongs.contains(song)
                              ? Colors.pink
                              : Colors.white),
                    ),
                    onTap: () {
                      _handleSongPlay(song);
                      widget._miniPlayer(song);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLibraryHeader(),
              _buildFilterChips(),
              SizedBox(height: 16),
              _buildQuickAccessRow(),
              SizedBox(height: 24),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Made by you',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 12),
              _buildPlaylistsList(),
              SizedBox(height: 100), // Extra space for mini player
            ],
          ),
        ),
      ),
    );
  }
}
