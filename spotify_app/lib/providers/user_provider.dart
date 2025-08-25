import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:spotify_app/models/music.dart';
import 'package:spotify_app/services/database_helper.dart';
import 'package:spotify_app/services/preferences_helper.dart';

class UserProvider with ChangeNotifier {
  // User info
  String _userName = 'Music Lover';
  String _userEmail = 'user@spotify.com';
  
  // User preferences
  bool _isDarkMode = true;
  double _defaultVolume = 0.8;
  bool _showExplicitContent = true;
  bool _autoplayEnabled = true;
  bool _crossfadeEnabled = false;
  int _crossfadeDuration = 0;
  
  // Playback quality
  String _audioQuality = 'High';
  bool _downloadOverWifiOnly = true;
  
  // User playlists
  List<Map<String, dynamic>> _userPlaylists = [];
  
  // Search history
  List<String> _searchHistory = [];
  final int _maxSearchHistory = 10;
  
  // Recently searched categories
  List<String> _recentCategories = [];
  
  // User's library organization preference
  String _librarySort = 'Recently Added';
  String _libraryFilter = 'All';
  
  // Notification preferences
  bool _playbackNotifications = true;
  bool _newMusicNotifications = true;
  bool _playlistUpdateNotifications = true;

  // Loading state
  bool _isLoading = false;

  // Constructor
  UserProvider() {
    _loadUserData();
  }

  // Getters
  String get userName => _userName;
  String get userEmail => _userEmail;
  bool get isDarkMode => _isDarkMode;
  double get defaultVolume => _defaultVolume;
  bool get showExplicitContent => _showExplicitContent;
  bool get autoplayEnabled => _autoplayEnabled;
  bool get crossfadeEnabled => _crossfadeEnabled;
  int get crossfadeDuration => _crossfadeDuration;
  String get audioQuality => _audioQuality;
  bool get downloadOverWifiOnly => _downloadOverWifiOnly;
  List<Map<String, dynamic>> get userPlaylists => _userPlaylists;
  List<String> get searchHistory => _searchHistory;
  List<String> get recentCategories => _recentCategories;
  String get librarySort => _librarySort;
  String get libraryFilter => _libraryFilter;
  bool get playbackNotifications => _playbackNotifications;
  bool get newMusicNotifications => _newMusicNotifications;
  bool get playlistUpdateNotifications => _playlistUpdateNotifications;
  bool get isLoading => _isLoading;

  // Load all user data from storage
  Future<void> _loadUserData() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Load preferences
      _userName = await PreferencesHelper.getUserName();
      _userEmail = await PreferencesHelper.getUserEmail();
      _isDarkMode = await PreferencesHelper.getDarkMode();
      _defaultVolume = await PreferencesHelper.getDefaultVolume();
      _showExplicitContent = await PreferencesHelper.getShowExplicitContent();
      _autoplayEnabled = await PreferencesHelper.getAutoplayEnabled();
      _crossfadeEnabled = await PreferencesHelper.getCrossfadeEnabled();
      _crossfadeDuration = await PreferencesHelper.getCrossfadeDuration();
      _audioQuality = await PreferencesHelper.getAudioQuality();
      _downloadOverWifiOnly = await PreferencesHelper.getDownloadOverWifiOnly();
      _searchHistory = await PreferencesHelper.getSearchHistory();
      _recentCategories = await PreferencesHelper.getRecentCategories();
      _librarySort = await PreferencesHelper.getLibrarySort();
      _libraryFilter = await PreferencesHelper.getLibraryFilter();
      _playbackNotifications = await PreferencesHelper.getPlaybackNotifications();
      _newMusicNotifications = await PreferencesHelper.getNewMusicNotifications();
      _playlistUpdateNotifications = await PreferencesHelper.getPlaylistUpdateNotifications();

      // Load playlists from database
      await _loadPlaylists();

    } catch (e) {
      print('Error loading user data: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // Load playlists from database
  Future<void> _loadPlaylists() async {
    try {
      List<Map<String, dynamic>> dbPlaylists = await DatabaseHelper.getPlayLists();
      
      _userPlaylists = [];
      for (Map<String, dynamic> playlist in dbPlaylists) {
        List<Music> songs = await DatabaseHelper.getPlaylistSongs(playlist['id']);
        
        _userPlaylists.add({
          'id': playlist['id'],
          'name': playlist['name'],
          'description': playlist['description'] ?? '',
          'image': playlist['image'] ?? 'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=300&h=300&fit=crop',
          'songs': songs,
          'createdAt': DateTime.fromMillisecondsSinceEpoch(playlist['created_at'] ?? 0),
          'isPublic': (playlist['is_public'] ?? 0) == 1,
          'isCollaborative': (playlist['is_collaborative'] ?? 0) == 1,
        });
      }
    } catch (e) {
      print('Error loading playlists: $e');
    }
  }

  // User info methods
  Future<void> updateUserInfo(String name, String email) async {
    _userName = name;
    _userEmail = email;
    
    await PreferencesHelper.setUserName(name);
    await PreferencesHelper.setUserEmail(email);
    
    notifyListeners();
  }

  // Theme methods
  Future<void> toggleDarkMode() async {
    _isDarkMode = !_isDarkMode;
    await PreferencesHelper.setDarkMode(_isDarkMode);
    notifyListeners();
  }

  Future<void> setDarkMode(bool isDark) async {
    _isDarkMode = isDark;
    await PreferencesHelper.setDarkMode(_isDarkMode);
    notifyListeners();
  }

  // Audio preferences
  Future<void> setDefaultVolume(double volume) async {
    _defaultVolume = volume.clamp(0.0, 1.0);
    await PreferencesHelper.setDefaultVolume(_defaultVolume);
    notifyListeners();
  }

  Future<void> toggleExplicitContent() async {
    _showExplicitContent = !_showExplicitContent;
    await PreferencesHelper.setShowExplicitContent(_showExplicitContent);
    notifyListeners();
  }

  Future<void> toggleAutoplay() async {
    _autoplayEnabled = !_autoplayEnabled;
    await PreferencesHelper.setAutoplayEnabled(_autoplayEnabled);
    notifyListeners();
  }

  Future<void> toggleCrossfade() async {
    _crossfadeEnabled = !_crossfadeEnabled;
    await PreferencesHelper.setCrossfadeEnabled(_crossfadeEnabled);
    notifyListeners();
  }

  Future<void> setCrossfadeDuration(int seconds) async {
    _crossfadeDuration = seconds.clamp(0, 12);
    await PreferencesHelper.setCrossfadeDuration(_crossfadeDuration);
    notifyListeners();
  }

  Future<void> setAudioQuality(String quality) async {
    if (['Low', 'Normal', 'High', 'Very High'].contains(quality)) {
      _audioQuality = quality;
      await PreferencesHelper.setAudioQuality(_audioQuality);
      notifyListeners();
    }
  }

  Future<void> toggleDownloadOverWifiOnly() async {
    _downloadOverWifiOnly = !_downloadOverWifiOnly;
    await PreferencesHelper.setDownloadOverWifiOnly(_downloadOverWifiOnly);
    notifyListeners();
  }

  // Playlist management
  Future<void> createPlaylist(String name, {String description = '', String imageUrl = '', required bool isCollaborative}) async {
    String playlistId = DateTime.now().millisecondsSinceEpoch.toString();
    int createdAt = DateTime.now().millisecondsSinceEpoch;
    
    Map<String, dynamic> newPlaylist = {
      'id': playlistId,
      'name': name,
      'description': description,
      'image': imageUrl.isEmpty ? 'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=300&h=300&fit=crop' : imageUrl,
      'created_at': createdAt,
      'is_public': 0,
      'is_collaborative': 0,
      'songs_count': 0,
    };
    
    await DatabaseHelper.insertPlaylist(newPlaylist);
    await _loadPlaylists();
    notifyListeners();
  }

  Future<void> deletePlaylist(String playlistId) async {
    await DatabaseHelper.deletePlaylist(playlistId);
    await _loadPlaylists();
    notifyListeners();
  }

  Future<void> updatePlaylist(String playlistId, {String? name, String? description, String? imageUrl}) async {
    Map<String, dynamic> updates = {};
    if (name != null) updates['name'] = name;
    if (description != null) updates['description'] = description;
    if (imageUrl != null) updates['image'] = imageUrl;
    
    if (updates.isNotEmpty) {
      await DatabaseHelper.updatePlaylist(playlistId, updates);
      await _loadPlaylists();
      notifyListeners();
    }
  }

  Future<void> addSongToPlaylist(String playlistId, Music song) async {
    try {
      await DatabaseHelper.addSongToPlaylist(playlistId, song);
      await _loadPlaylists();
      notifyListeners();
    } catch (e) {
      print('Error adding song to playlist: $e');
    }
  }

  Future<void> removeSongFromPlaylist(String playlistId, Music song) async {
    try {
      await DatabaseHelper.removeSongFromPlaylist(playlistId, song.name);
      await _loadPlaylists();
      notifyListeners();
    } catch (e) {
      print('Error removing song from playlist: $e');
    }
  }

  // Search history management
  Future<void> addToSearchHistory(String query) async {
    if (query.trim().isEmpty) return;
    
    // Remove if already exists
    _searchHistory.removeWhere((item) => item.toLowerCase() == query.toLowerCase());
    
    // Add to beginning
    _searchHistory.insert(0, query.trim());
    
    // Keep only max items
    if (_searchHistory.length > _maxSearchHistory) {
      _searchHistory = _searchHistory.take(_maxSearchHistory).toList();
    }
    
    await PreferencesHelper.setSearchHistory(_searchHistory);
    notifyListeners();
  }

  Future<void> removeFromSearchHistory(String query) async {
    _searchHistory.removeWhere((item) => item == query);
    await PreferencesHelper.setSearchHistory(_searchHistory);
    notifyListeners();
  }

  Future<void> clearSearchHistory() async {
    _searchHistory.clear();
    await PreferencesHelper.setSearchHistory(_searchHistory);
    notifyListeners();
  }

  // Recent categories
  Future<void> addToRecentCategories(String category) async {
    _recentCategories.removeWhere((item) => item == category);
    _recentCategories.insert(0, category);
    
    if (_recentCategories.length > 5) {
      _recentCategories = _recentCategories.take(5).toList();
    }
    
    await PreferencesHelper.setRecentCategories(_recentCategories);
    notifyListeners();
  }

  // Library preferences
  Future<void> setLibrarySort(String sortBy) async {
    if (['Recently Added', 'Alphabetical', 'Recently Played', 'Creator'].contains(sortBy)) {
      _librarySort = sortBy;
      await PreferencesHelper.setLibrarySort(_librarySort);
      notifyListeners();
    }
  }

  Future<void> setLibraryFilter(String filter) async {
    if (['All', 'Downloaded', 'Made by you'].contains(filter)) {
      _libraryFilter = filter;
      await PreferencesHelper.setLibraryFilter(_libraryFilter);
      notifyListeners();
    }
  }

  // Notification preferences
  Future<void> togglePlaybackNotifications() async {
    _playbackNotifications = !_playbackNotifications;
    await PreferencesHelper.setPlaybackNotifications(_playbackNotifications);
    notifyListeners();
  }

  Future<void> toggleNewMusicNotifications() async {
    _newMusicNotifications = !_newMusicNotifications;
    await PreferencesHelper.setNewMusicNotifications(_newMusicNotifications);
    notifyListeners();
  }

  Future<void> togglePlaylistUpdateNotifications() async {
    _playlistUpdateNotifications = !_playlistUpdateNotifications;
    await PreferencesHelper.setPlaylistUpdateNotifications(_playlistUpdateNotifications);
    notifyListeners();
  }

  // Initialize with sample data (for first time users)
  Future<void> initializeWithSampleData(List<Music> sampleMusic) async {
    bool isFirstLaunch = await PreferencesHelper.isFirstLaunch();
    
    if (isFirstLaunch && _userPlaylists.isEmpty) {
      // Create sample playlists
      await createPlaylist(
        'My Favorites',
        description: 'My personal collection of favorite songs',
        imageUrl: 'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=300&h=300&fit=crop', isCollaborative: false,
      );
      
      await createPlaylist(
        'Workout Mix',
        description: 'High energy songs for working out',
        imageUrl: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=300&h=300&fit=crop', isCollaborative: false,
      );
      
      await createPlaylist(
        'Chill Vibes',
        description: 'Relaxing songs for unwinding',
        imageUrl: 'https://images.unsplash.com/photo-1514525253161-7a46d19cd819?w=300&h=300&fit=crop', isCollaborative: false,
      );

      // Add some songs to playlists
      if (sampleMusic.isNotEmpty && _userPlaylists.length >= 2) {
        String favoritesId = _userPlaylists[0]['id'];
        String workoutId = _userPlaylists[1]['id'];
        
        for (int i = 0; i < sampleMusic.length && i < 2; i++) {
          await addSongToPlaylist(favoritesId, sampleMusic[i]);
        }
        
        if (sampleMusic.isNotEmpty) {
          await addSongToPlaylist(workoutId, sampleMusic[0]);
        }
      }

      // Add sample search history
      _searchHistory = ['toofan', 'gully boy', 'atif aslam', 'hindi songs'];
      await PreferencesHelper.setSearchHistory(_searchHistory);
      
      _recentCategories = ['Top Hits', 'Old Songs', 'Bollywood'];
      await PreferencesHelper.setRecentCategories(_recentCategories);
      
      // Mark as not first launch
      await PreferencesHelper.setFirstLaunch(false);
      
      notifyListeners();
    }
  }

  // Get playlist by ID
  Map<String, dynamic>? getPlaylistById(String playlistId) {
    try {
      return _userPlaylists.firstWhere((playlist) => playlist['id'] == playlistId);
    } catch (e) {
      return null;
    }
  }

  // Get total songs count across all playlists
  int get totalSongsInPlaylists {
    int total = 0;
    for (var playlist in _userPlaylists) {
      total += (playlist['songs'] as List<Music>).length;
    }
    return total;
  }

  // Sync data (for backup/restore)
  Future<Map<String, dynamic>> exportUserData() async {
    try {
      Map<String, dynamic> preferences = await PreferencesHelper.exportPreferences();
      Map<String, int> dbStats = await DatabaseHelper.getDatabaseStats();
      
      return {
        'userData': {
          'userName': _userName,
          'userEmail': _userEmail,
          'exportDate': DateTime.now().toIso8601String(),
        },
        'preferences': preferences,
        'statistics': dbStats,
        'playlistsCount': _userPlaylists.length,
        'totalSongs': totalSongsInPlaylists,
      };
    } catch (e) {
      print('Error exporting user data: $e');
      return {};
    }
  }

  // Import user data (for restore)
  Future<bool> importUserData(Map<String, dynamic> data) async {
    try {
      if (data['preferences'] != null) {
        await PreferencesHelper.importPreferences(data['preferences']);
      }
      
      // Reload all data after import
      await _loadUserData();
      
      return true;
    } catch (e) {
      print('Error importing user data: $e');
      return false;
    }
  }

  // Clear all user data
  Future<void> clearAllUserData() async {
    try {
      _isLoading = true;
      notifyListeners();
      
      // Clear database
      await DatabaseHelper.clearAllData();
      
      // Clear preferences
      await PreferencesHelper.clearAllPreferences();
      
      // Reset local variables
      _userPlaylists.clear();
      _searchHistory.clear();
      _recentCategories.clear();
      
      // Reset to defaults
      _userName = 'Music Lover';
      _userEmail = 'user@spotify.com';
      _isDarkMode = true;
      _defaultVolume = 0.8;
      _showExplicitContent = true;
      _autoplayEnabled = true;
      _crossfadeEnabled = false;
      _crossfadeDuration = 0;
      _audioQuality = 'High';
      _downloadOverWifiOnly = true;
      _librarySort = 'Recently Added';
      _libraryFilter = 'All';
      _playbackNotifications = true;
      _newMusicNotifications = true;
      _playlistUpdateNotifications = true;
      
      _isLoading = false;
      notifyListeners();
      
    } catch (e) {
      print('Error clearing user data: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get storage usage statistics
  Future<Map<String, dynamic>> getStorageStats() async {
    try {
      Map<String, int> dbStats = await DatabaseHelper.getDatabaseStats();
      
      return {
        'playlists': dbStats['playlists'] ?? 0,
        'playlistSongs': dbStats['songs'] ?? 0,
        'recentlyPlayed': dbStats['recent'] ?? 0,
        'likedSongs': dbStats['liked'] ?? 0,
        'offlineSongs': dbStats['offline'] ?? 0,
        'searchHistoryItems': _searchHistory.length,
        'recentCategories': _recentCategories.length,
      };
    } catch (e) {
      print('Error getting storage stats: $e');
      return {};
    }
  }

  // Refresh data from storage
  Future<void> refreshData() async {
    await _loadUserData();
  }

  // Auto-save timer for critical data
  Timer? _autoSaveTimer;
  
  void startAutoSave() {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer.periodic(Duration(minutes: 5), (timer) {
      _saveCurrentState();
    });
  }
  
  void stopAutoSave() {
    _autoSaveTimer?.cancel();
  }
  
  Future<void> _saveCurrentState() async {
    try {
      await PreferencesHelper.setLastSyncTime(DateTime.now());
      // Additional auto-save logic can be added here
    } catch (e) {
      print('Error in auto-save: $e');
    }
  }

  @override
  void dispose() {
    stopAutoSave();
    super.dispose();
  }
}