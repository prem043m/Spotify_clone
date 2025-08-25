import 'dart:io';
//import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:spotify_app/models/music.dart';
import 'package:spotify_app/services/database_helper.dart';
import 'package:spotify_app/services/preferences_helper.dart';

class OfflineService {
  static const String _offlineFolder = 'offline_music';
  
  // Download a song for offline playback
  static Future<bool> downloadSong(Music song, {Function(double)? onProgress}) async {
    try {
      // Check if already downloaded
      String? existingPath = await DatabaseHelper.getOfflinePath(song.name);
      if (existingPath != null && await File(existingPath).exists()) {
        return true; // Already downloaded
      }

      // Check WiFi-only setting
      bool wifiOnly = await PreferencesHelper.getDownloadOverWifiOnly();
      if (wifiOnly && !await _isOnWiFi()) {
        throw Exception('WiFi-only download enabled, but not connected to WiFi');
      }

      // Create offline directory
      Directory appDir = await getApplicationDocumentsDirectory();
      Directory offlineDir = Directory('${appDir.path}/$_offlineFolder');
      if (!await offlineDir.exists()) {
        await offlineDir.create(recursive: true);
      }

      // Generate local file path
      String fileName = _sanitizeFileName(song.name) + '.m4a';
      String localPath = '${offlineDir.path}/$fileName';

      // Download the file
      final response = await http.get(Uri.parse(song.audioURL));
      if (response.statusCode == 200) {
        File localFile = File(localPath);
        await localFile.writeAsBytes(response.bodyBytes);

        // Save to database
        await DatabaseHelper.addOfflineSong(
          song, 
          localPath, 
          response.bodyBytes.length
        );

        return true;
      } else {
        throw Exception('Failed to download: HTTP ${response.statusCode}');
      }
    } catch (e) {
      print('Error downloading song: $e');
      return false;
    }
  }

  // Download entire playlist
  static Future<Map<String, dynamic>> downloadPlaylist(
    List<Music> songs, 
    {Function(int, int, String)? onProgress}
  ) async {
    int total = songs.length;
    int completed = 0;
    int failed = 0;
    List<String> failedSongs = [];

    for (Music song in songs) {
      try {
        onProgress?.call(completed, total, song.name);
        
        bool success = await downloadSong(song);
        if (success) {
          completed++;
        } else {
          failed++;
          failedSongs.add(song.name);
        }
      } catch (e) {
        failed++;
        failedSongs.add(song.name);
        print('Failed to download ${song.name}: $e');
      }
    }

    return {
      'total': total,
      'completed': completed,
      'failed': failed,
      'failedSongs': failedSongs,
    };
  }

  // Remove downloaded song
  static Future<bool> removeSong(String songName) async {
    try {
      String? localPath = await DatabaseHelper.getOfflinePath(songName);
      if (localPath != null) {
        File file = File(localPath);
        if (await file.exists()) {
          await file.delete();
        }
        await DatabaseHelper.removeOfflineSong(songName);
        return true;
      }
      return false;
    } catch (e) {
      print('Error removing offline song: $e');
      return false;
    }
  }

  // Get offline song path
  static Future<String?> getOfflinePath(String songName) async {
    return await DatabaseHelper.getOfflinePath(songName);
  }

  // Check if song is available offline
  static Future<bool> isAvailableOffline(String songName) async {
    String? path = await getOfflinePath(songName);
    if (path != null) {
      return await File(path).exists();
    }
    return false;
  }

  // Get all offline songs
  static Future<List<Music>> getOfflineSongs() async {
    return await DatabaseHelper.getOfflineSongs();
  }

  // Clear all offline data
  static Future<void> clearAllOfflineData() async {
    try {
      Directory appDir = await getApplicationDocumentsDirectory();
      Directory offlineDir = Directory('${appDir.path}/$_offlineFolder');
      
      if (await offlineDir.exists()) {
        await offlineDir.delete(recursive: true);
      }
      
      // Clear database entries
      List<Music> offlineSongs = await DatabaseHelper.getOfflineSongs();
      for (Music song in offlineSongs) {
        await DatabaseHelper.removeOfflineSong(song.name);
      }
    } catch (e) {
      print('Error clearing offline data: $e');
    }
  }

  // Get offline storage size
  static Future<int> getOfflineStorageSize() async {
    try {
      Directory appDir = await getApplicationDocumentsDirectory();
      Directory offlineDir = Directory('${appDir.path}/$_offlineFolder');
      
      if (!await offlineDir.exists()) {
        return 0;
      }

      int totalSize = 0;
      await for (FileSystemEntity entity in offlineDir.list(recursive: true)) {
        if (entity is File) {
          totalSize += await entity.length();
        }
      }
      
      return totalSize;
    } catch (e) {
      print('Error calculating offline storage size: $e');
      return 0;
    }
  }

  // Helper methods
  static String _sanitizeFileName(String fileName) {
    return fileName
        .replaceAll(RegExp(r'[^\w\s-]'), '')
        .replaceAll(RegExp(r'\s+'), '_')
        .toLowerCase();
  }

  static Future<bool> _isOnWiFi() async {
    // This is a simplified check. In a real app, you'd use 
    // connectivity_plus package to check network type
    return true; // Assume WiFi for now
  }

  // Format file size
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}