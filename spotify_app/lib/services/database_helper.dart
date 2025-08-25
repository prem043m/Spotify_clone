//import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:spotify_app/models/music.dart';

class DatabaseHelper {
  static Database? _database;
  static const String dbname = 'spotify_clone.db';
  static const int dbVersion = 1;

  // Table names

  static const String playlistsTable = 'playlists';
  static const String playlistSongsTable = 'playlist_songs';
  static const String recentlyPlayedTable = 'recently_played';
  static const String likedSongsTable = 'liked_songs';
  static const String offlineSongsTable = 'offline_songs';

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), dbname);
    return await openDatabase(
      path,
      version: dbVersion,
      onCreate: _createDatabase,
      onUpgrade: _upgradeDatabase,
    );
  }

  static Future<void> _createDatabase(Database db, int version) async {
    //playlists table
    await db.execute('''
      CREATE TABLE  $playlistsTable(
      id TEXT PRIMARY KEY,
      name TEXT NOT NULL,
      description TEXT,
      image TEXt,
      created_at INTEGER,
      is_public INTEGER DEFAULT 0,
      is_collaborative INTEGER DEFAULT 0,
      songs_count INTEGER DEFAULT 0
      )
''');

    //playlist songs table
    await db.execute('''
     CREATE TABLE $playlistSongsTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        playlist_id TEXT,
        song_name TEXT,
        song_image TEXT,
        song_desc TEXT,
        song_audio_url TEXT,
        added_at INTEGER,
        FOREIGN KEY (playlist_id) REFERENCES $playlistsTable (id)
      )
''');

    // Recently played table
    await db.execute('''
      CREATE TABLE $recentlyPlayedTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        song_name TEXT UNIQUE,
        song_image TEXT,
        song_desc TEXT,
        song_audio_url TEXT,
        played_at INTEGER,
        play_count INTEGER DEFAULT 1
      )
    ''');

    // Liked songs table
    await db.execute('''
      CREATE TABLE $likedSongsTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        song_name TEXT UNIQUE,
        song_image TEXT,
        song_desc TEXT,
        song_audio_url TEXT,
        liked_at INTEGER
      )
    ''');

    // Offline songs table
    await db.execute('''
      CREATE TABLE $offlineSongsTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        song_name TEXT UNIQUE,
        song_image TEXT,
        song_desc TEXT,
        song_audio_url TEXT,
        local_path TEXT,
        download_date INTEGER,
        file_size INTEGER
      )
    ''');
  }

  static Future<void> _upgradeDatabase(
      Database db, int oldVersion, int newVersion) async {
    // Handle database upgrades here
    if (oldVersion < 2) {
      // Add new columns or tables for future versions
    }
  }

  // Playlist operations
  static Future<void> insertPlaylist(Map<String, dynamic> playlist) async {
    final db = await database;
    await db.insert(playlistsTable, playlist,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<List<Map<String, dynamic>>> getPlayLists() async {
    final db = await database;
    return await db.query(playlistsTable, orderBy: 'created_at DESC');
  }

  static Future<void> deletePlaylist(String playlistId) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn
          .delete(playlistsTable, where: 'id = ?', whereArgs: [playlistId]);
      await txn.delete(playlistSongsTable,
          where: 'playlist_id = ?', whereArgs: [playlistId]);
    });
  }

  static Future<void> updatePlaylist(
      String playlistId, Map<String, dynamic> updates) async {
    final db = await database;
    await db.update(playlistsTable, updates,
        where: 'id = ?', whereArgs: [playlistId]);
  }

  //playlist songs operations
  static Future<void> addSongToPlaylist(String playlistId, Music song) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.insert(playlistSongsTable, {
        'playlist_id': playlistId,
        'song_name': song.name,
        'song_image': song.image,
        'song_desc': song.desc,
        'song_audio_url': song.audioURL,
        'added_at': DateTime.now().millisecondsSinceEpoch,
      });

      // update songs count
      await txn.rawUpdate(
          'UPDATE $playlistsTable SET songs_count = songs_count+1 WHERE id = ?',
          [playlistId]);
    });
  }

  static Future<void> removeSongFromPlaylist(
      String playlistId, String songName) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete(playlistSongsTable,
          where: 'playlist_id = ?', whereArgs: [playlistId, songName]);

      //update songs count
      await txn.rawUpdate(
          'UPDATE $playlistsTable SET songs_count = songs_count -1 WHERE id = ?',
          [playlistId]);
    });
  }

  static Future<List<Music>> getPlaylistSongs(String playlistId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(playlistSongsTable,
        where: 'playlist_id = ?',
        whereArgs: [playlistId],
        orderBy: 'added_at DESC');
    return maps
        .map((map) => Music(
              map['song_name'],
              map['song_image'],
              map['song_desc'],
              map['song_audio_url'],
            ))
        .toList();
  }

  // Recently played operations
  static Future<void> addToRecentlyPlayed(Music song) async {
    final db = await database;
    await db.insert(
      recentlyPlayedTable,
      {
        'song_name': song.name,
        'song_image': song.image,
        'song_desc': song.desc,
        'song_audio_url': song.audioURL,
        'played_at': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    // keep only last 50 entries
    await db.rawDelete('''
      DELETE FROM $recentlyPlayedTable
      WHERE id NOT IN(
      SELECT id FROM $recentlyPlayedTable
      ORDER BY played_at DESC
      LIMIT 50
      )
    ''');
  }

  static Future<List<Music>> getRecentlyPlayed({int limit = 20}) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      recentlyPlayedTable,
      orderBy: 'played_at DESC',
      limit: limit,
    );

    return maps
        .map((map) => Music(map['song_name'], map['song_image'],
            map['song_desc'], map['song_audio_url']))
        .toList();
  }

   // Liked songs operations
  static Future<void> addToLikedSongs(Music song) async {
    final db = await database;
    await db.insert(
      likedSongsTable,
      {
        'song_name': song.name,
        'song_image': song.image,
        'song_desc': song.desc,
        'song_audio_url': song.audioURL,
        'liked_at': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> removeFromLikedSongs(String songName) async {
    final db = await database;
    await db.delete(likedSongsTable, where: 'song_name = ?', whereArgs: [songName]);
  }

  static Future<List<Music>> getLikedSongs() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      likedSongsTable,
      orderBy: 'liked_at DESC',
    );

    return maps.map((map) => Music(
      map['song_name'],
      map['song_image'],
      map['song_desc'],
      map['song_audio_url'],
    )).toList();
  }

  static Future<bool> isSongLiked(String songName) async {
    final db = await database;
    final result = await db.query(
      likedSongsTable,
      where: 'song_name = ?',
      whereArgs: [songName],
      limit: 1,
    );
    return result.isNotEmpty;
  }

  // Offline songs operations
  static Future<void> addOfflineSong(Music song, String localPath, int fileSize) async {
    final db = await database;
    await db.insert(
      offlineSongsTable,
      {
        'song_name': song.name,
        'song_image': song.image,
        'song_desc': song.desc,
        'song_audio_url': song.audioURL,
        'local_path': localPath,
        'download_date': DateTime.now().millisecondsSinceEpoch,
        'file_size': fileSize,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> removeOfflineSong(String songName) async {
    final db = await database;
    await db.delete(offlineSongsTable, where: 'song_name = ?', whereArgs: [songName]);
  }

  static Future<List<Music>> getOfflineSongs() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      offlineSongsTable,
      orderBy: 'download_date DESC',
    );

    return maps.map((map) => Music(
      map['song_name'],
      map['song_image'],
      map['song_desc'],
      map['song_audio_url'],
    )).toList();
  }

  static Future<String?> getOfflinePath(String songName) async {
    final db = await database;
    final result = await db.query(
      offlineSongsTable,
      columns: ['local_path'],
      where: 'song_name = ?',
      whereArgs: [songName],
      limit: 1,
    );
    
    if (result.isNotEmpty) {
      return result.first['local_path'] as String?;
    }
    return null;
  }

  // Clear all data
  static Future<void> clearAllData() async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete(playlistsTable);
      await txn.delete(playlistSongsTable);
      await txn.delete(recentlyPlayedTable);
      await txn.delete(likedSongsTable);
      await txn.delete(offlineSongsTable);
    });
  }

  // Get database statistics
  static Future<Map<String, int>> getDatabaseStats() async {
    final db = await database;
    
    final playlistCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM $playlistsTable')
    ) ?? 0;
    
    final songsCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM $playlistSongsTable')
    ) ?? 0;
    
    final recentCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM $recentlyPlayedTable')
    ) ?? 0;
    
    final likedCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM $likedSongsTable')
    ) ?? 0;
    
    final offlineCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM $offlineSongsTable')
    ) ?? 0;

    return {
      'playlists': playlistCount,
      'songs': songsCount,
      'recent': recentCount,
      'liked': likedCount,
      'offline': offlineCount,
    };
  }

  static reorderPlaylistSongs(String playlistId, List<Music> songs) {}

  static addMultipleSongsToPlaylist(String playlistId, List<Music> songsToAdd) {}

  static removeMultipleSongsFromPlaylist(String playlistId, List<String> songNames) {}

}
