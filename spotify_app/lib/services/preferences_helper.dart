import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesHelper {
  static const String _keyUserName = 'user_name';
  static const String _keyUserEmail = 'user_email';
  static const String _keyIsDarkMode = 'is_dark_mode';
  static const String _keyDefaultVolume = 'default_volume';
  static const String _keyShowExplicitContent = 'show_explicit_content';
  static const String _keyAutoplayEnabled = 'autoplay_enabled';
  static const String _keyCrossfadeEnabled = 'crossfade_enabled';
  static const String _keyCrossfadeDuration = 'crossfade_duration';
  static const String _keyAudioQuality = 'audio_quality';
  static const String _keyDownloadOverWifiOnly = 'download_over_wifi_only';
  static const String _keySearchHistory = 'search_history';
  static const String _keyRecentCategories = 'recent_categories';
  static const String _keyLibrarySort = 'library_sort';
  static const String _keyLibraryFilter = 'library_filter';
  static const String _keyPlaybackNotifications = 'playback_notifications';
  static const String _keyNewMusicNotifications = 'new_music_notifications';
  static const String _keyPlaylistUpdateNotifications = 'playlist_update_notifications';
  static const String _keyFirstLaunch = 'first_launch';
  static const String _keyLastSyncTime = 'last_sync_time';
  static const String _keyOfflineMode = 'offline_mode';
  static const String _keyCurrentPlaybackPosition = 'current_playback_position';
  static const String _keyCurrentSong = 'current_song';
  static const String _keyCurrentPlaylist = 'current_playlist';
  static const String _keyShuffleMode = 'shuffle_mode';
  static const String _keyRepeatMode = 'repeat_mode';

  static SharedPreferences? _prefs;

  static Future<SharedPreferences> get _preferences async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  // User info
  static Future<void> setUserName(String name) async {
    final prefs = await _preferences;
    await prefs.setString(_keyUserName, name);
  }

  static Future<String> getUserName() async {
    final prefs = await _preferences;
    return prefs.getString(_keyUserName) ?? 'Music Lover';
  }

  static Future<void> setUserEmail(String email) async {
    final prefs = await _preferences;
    await prefs.setString(_keyUserEmail, email);
  }

  static Future<String> getUserEmail() async {
    final prefs = await _preferences;
    return prefs.getString(_keyUserEmail) ?? 'user@spotify.com';
  }

  // Theme preferences
  static Future<void> setDarkMode(bool isDark) async {
    final prefs = await _preferences;
    await prefs.setBool(_keyIsDarkMode, isDark);
  }

  static Future<bool> getDarkMode() async {
    final prefs = await _preferences;
    return prefs.getBool(_keyIsDarkMode) ?? true;
  }

  // Audio preferences
  static Future<void> setDefaultVolume(double volume) async {
    final prefs = await _preferences;
    await prefs.setDouble(_keyDefaultVolume, volume);
  }

  static Future<double> getDefaultVolume() async {
    final prefs = await _preferences;
    return prefs.getDouble(_keyDefaultVolume) ?? 0.8;
  }

  static Future<void> setShowExplicitContent(bool show) async {
    final prefs = await _preferences;
    await prefs.setBool(_keyShowExplicitContent, show);
  }

  static Future<bool> getShowExplicitContent() async {
    final prefs = await _preferences;
    return prefs.getBool(_keyShowExplicitContent) ?? true;
  }

  static Future<void> setAutoplayEnabled(bool enabled) async {
    final prefs = await _preferences;
    await prefs.setBool(_keyAutoplayEnabled, enabled);
  }

  static Future<bool> getAutoplayEnabled() async {
    final prefs = await _preferences;
    return prefs.getBool(_keyAutoplayEnabled) ?? true;
  }

  static Future<void> setCrossfadeEnabled(bool enabled) async {
    final prefs = await _preferences;
    await prefs.setBool(_keyCrossfadeEnabled, enabled);
  }

  static Future<bool> getCrossfadeEnabled() async {
    final prefs = await _preferences;
    return prefs.getBool(_keyCrossfadeEnabled) ?? false;
  }

  static Future<void> setCrossfadeDuration(int seconds) async {
    final prefs = await _preferences;
    await prefs.setInt(_keyCrossfadeDuration, seconds);
  }

  static Future<int> getCrossfadeDuration() async {
    final prefs = await _preferences;
    return prefs.getInt(_keyCrossfadeDuration) ?? 0;
  }

  static Future<void> setAudioQuality(String quality) async {
    final prefs = await _preferences;
    await prefs.setString(_keyAudioQuality, quality);
  }

  static Future<String> getAudioQuality() async {
    final prefs = await _preferences;
    return prefs.getString(_keyAudioQuality) ?? 'High';
  }

  static Future<void> setDownloadOverWifiOnly(bool wifiOnly) async {
    final prefs = await _preferences;
    await prefs.setBool(_keyDownloadOverWifiOnly, wifiOnly);
  }

  static Future<bool> getDownloadOverWifiOnly() async {
    final prefs = await _preferences;
    return prefs.getBool(_keyDownloadOverWifiOnly) ?? true;
  }

  // Search and browsing
  static Future<void> setSearchHistory(List<String> history) async {
    final prefs = await _preferences;
    await prefs.setString(_keySearchHistory, jsonEncode(history));
  }

  static Future<List<String>> getSearchHistory() async {
    final prefs = await _preferences;
    final String? historyJson = prefs.getString(_keySearchHistory);
    if (historyJson != null) {
      return List<String>.from(jsonDecode(historyJson));
    }
    return [];
  }

  static Future<void> setRecentCategories(List<String> categories) async {
    final prefs = await _preferences;
    await prefs.setString(_keyRecentCategories, jsonEncode(categories));
  }

  static Future<List<String>> getRecentCategories() async {
    final prefs = await _preferences;
    final String? categoriesJson = prefs.getString(_keyRecentCategories);
    if (categoriesJson != null) {
      return List<String>.from(jsonDecode(categoriesJson));
    }
    return [];
  }

  // Library preferences
  static Future<void> setLibrarySort(String sort) async {
    final prefs = await _preferences;
    await prefs.setString(_keyLibrarySort, sort);
  }

  static Future<String> getLibrarySort() async {
    final prefs = await _preferences;
    return prefs.getString(_keyLibrarySort) ?? 'Recently Added';
  }

  static Future<void> setLibraryFilter(String filter) async {
    final prefs = await _preferences;
    await prefs.setString(_keyLibraryFilter, filter);
  }

  static Future<String> getLibraryFilter() async {
    final prefs = await _preferences;
    return prefs.getString(_keyLibraryFilter) ?? 'All';
  }

  // Notification preferences
  static Future<void> setPlaybackNotifications(bool enabled) async {
    final prefs = await _preferences;
    await prefs.setBool(_keyPlaybackNotifications, enabled);
  }

  static Future<bool> getPlaybackNotifications() async {
    final prefs = await _preferences;
    return prefs.getBool(_keyPlaybackNotifications) ?? true;
  }

  static Future<void> setNewMusicNotifications(bool enabled) async {
    final prefs = await _preferences;
    await prefs.setBool(_keyNewMusicNotifications, enabled);
  }

  static Future<bool> getNewMusicNotifications() async {
    final prefs = await _preferences;
    return prefs.getBool(_keyNewMusicNotifications) ?? true;
  }

  static Future<void> setPlaylistUpdateNotifications(bool enabled) async {
    final prefs = await _preferences;
    await prefs.setBool(_keyPlaylistUpdateNotifications, enabled);
  }

  static Future<bool> getPlaylistUpdateNotifications() async {
    final prefs = await _preferences;
    return prefs.getBool(_keyPlaylistUpdateNotifications) ?? true;
  }

  // App state
  static Future<void> setFirstLaunch(bool isFirst) async {
    final prefs = await _preferences;
    await prefs.setBool(_keyFirstLaunch, isFirst);
  }

  static Future<bool> isFirstLaunch() async {
    final prefs = await _preferences;
    return prefs.getBool(_keyFirstLaunch) ?? true;
  }

  static Future<void> setLastSyncTime(DateTime time) async {
    final prefs = await _preferences;
    await prefs.setInt(_keyLastSyncTime, time.millisecondsSinceEpoch);
  }

  static Future<DateTime?> getLastSyncTime() async {
    final prefs = await _preferences;
    final int? timestamp = prefs.getInt(_keyLastSyncTime);
    if (timestamp != null) {
      return DateTime.fromMillisecondsSinceEpoch(timestamp);
    }
    return null;
  }

  static Future<void> setOfflineMode(bool isOffline) async {
    final prefs = await _preferences;
    await prefs.setBool(_keyOfflineMode, isOffline);
  }

  static Future<bool> getOfflineMode() async {
    final prefs = await _preferences;
    return prefs.getBool(_keyOfflineMode) ?? false;
  }

  // Playback state persistence
  static Future<void> setCurrentPlaybackPosition(Duration position) async {
    final prefs = await _preferences;
    await prefs.setInt(_keyCurrentPlaybackPosition, position.inMilliseconds);
  }

  static Future<Duration> getCurrentPlaybackPosition() async {
    final prefs = await _preferences;
    final int? milliseconds = prefs.getInt(_keyCurrentPlaybackPosition);
    return Duration(milliseconds: milliseconds ?? 0);
  }

  static Future<void> setCurrentSong(Map<String, dynamic>? song) async {
    final prefs = await _preferences;
    if (song != null) {
      await prefs.setString(_keyCurrentSong, jsonEncode(song));
    } else {
      await prefs.remove(_keyCurrentSong);
    }
  }

  static Future<Map<String, dynamic>?> getCurrentSong() async {
    final prefs = await _preferences;
    final String? songJson = prefs.getString(_keyCurrentSong);
    if (songJson != null) {
      return Map<String, dynamic>.from(jsonDecode(songJson));
    }
    return null;
  }

  static Future<void> setCurrentPlaylist(List<Map<String, dynamic>> playlist) async {
    final prefs = await _preferences;
    await prefs.setString(_keyCurrentPlaylist, jsonEncode(playlist));
  }

  static Future<List<Map<String, dynamic>>> getCurrentPlaylist() async {
    final prefs = await _preferences;
    final String? playlistJson = prefs.getString(_keyCurrentPlaylist);
    if (playlistJson != null) {
      return List<Map<String, dynamic>>.from(jsonDecode(playlistJson));
    }
    return [];
  }

  static Future<void> setShuffleMode(bool enabled) async {
    final prefs = await _preferences;
    await prefs.setBool(_keyShuffleMode, enabled);
  }

  static Future<bool> getShuffleMode() async {
    final prefs = await _preferences;
    return prefs.getBool(_keyShuffleMode) ?? false;
  }

  static Future<void> setRepeatMode(bool enabled) async {
    final prefs = await _preferences;
    await prefs.setBool(_keyRepeatMode, enabled);
  }

  static Future<bool> getRepeatMode() async {
    final prefs = await _preferences;
    return prefs.getBool(_keyRepeatMode) ?? false;
  }

  // Clear all preferences
  static Future<void> clearAllPreferences() async {
    final prefs = await _preferences;
    await prefs.clear();
  }

  // Export all preferences
  static Future<Map<String, dynamic>> exportPreferences() async {
    final prefs = await _preferences;
    final keys = prefs.getKeys();
    final Map<String, dynamic> data = {};
    
    for (String key in keys) {
      final value = prefs.get(key);
      data[key] = value;
    }
    
    return data;
  }

  // Import preferences
  static Future<void> importPreferences(Map<String, dynamic> data) async {
    final prefs = await _preferences;
    
    for (String key in data.keys) {
      final value = data[key];
      if (value is String) {
        await prefs.setString(key, value);
      } else if (value is int) {
        await prefs.setInt(key, value);
      } else if (value is double) {
        await prefs.setDouble(key, value);
      } else if (value is bool) {
        await prefs.setBool(key, value);
      } else if (value is List<String>) {
        await prefs.setStringList(key, value);
      }
    }
  }

  static init() {}
}