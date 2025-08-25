import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spotify_app/providers/user_provider.dart';
import 'package:spotify_app/providers/audio_provider.dart';
import 'package:spotify_app/services/offline_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Settings', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Consumer2<UserProvider, AudioProvider>(
        builder: (context, userProvider, audioProvider, child) {
          return SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSection('Account', [
                  _buildUserInfo(userProvider),
                ]),
                
                SizedBox(height: 24),
                
                _buildSection('Playback', [
                  _buildSwitchTile(
                    'Dark Mode',
                    userProvider.isDarkMode,
                    (value) => userProvider.toggleDarkMode(),
                    Icons.dark_mode,
                  ),
                  _buildSliderTile(
                    'Default Volume',
                    userProvider.defaultVolume,
                    (value) => userProvider.setDefaultVolume(value),
                    Icons.volume_up,
                  ),
                  _buildSwitchTile(
                    'Autoplay',
                    userProvider.autoplayEnabled,
                    (value) => userProvider.toggleAutoplay(),
                    Icons.play_arrow,
                  ),
                  _buildSwitchTile(
                    'Crossfade',
                    userProvider.crossfadeEnabled,
                    (value) => userProvider.toggleCrossfade(),
                    Icons.multiple_stop,
                  ),
                  if (userProvider.crossfadeEnabled)
                    _buildSliderTile(
                      'Crossfade Duration',
                      userProvider.crossfadeDuration.toDouble(),
                      (value) => userProvider.setCrossfadeDuration(value.toInt()),
                      Icons.timer,
                      min: 0,
                      max: 12,
                      divisions: 12,
                      suffix: 's',
                    ),
                ]),
                
                SizedBox(height: 24),
                
                _buildSection('Audio Quality', [
                  _buildDropdownTile(
                    'Streaming Quality',
                    userProvider.audioQuality,
                    ['Low', 'Normal', 'High', 'Very High'],
                    (value) => userProvider.setAudioQuality(value!),
                    Icons.high_quality,
                  ),
                ]),
                
                SizedBox(height: 24),
                
                _buildSection('Download', [
                  _buildSwitchTile(
                    'Download over WiFi only',
                    userProvider.downloadOverWifiOnly,
                    (value) => userProvider.toggleDownloadOverWifiOnly(),
                    Icons.wifi,
                  ),
                  _buildSwitchTile(
                    'Offline Mode',
                    audioProvider.isOfflineMode,
                    (value) => audioProvider.toggleOfflineMode(),
                    Icons.offline_bolt,
                  ),
                  _buildStorageInfo(),
                ]),
                
                SizedBox(height: 24),
                
                _buildSection('Privacy', [
                  _buildSwitchTile(
                    'Show Explicit Content',
                    userProvider.showExplicitContent,
                    (value) => userProvider.toggleExplicitContent(),
                    Icons.explicit,
                  ),
                ]),
                
                SizedBox(height: 24),
                
                _buildSection('Notifications', [
                  _buildSwitchTile(
                    'Playback Notifications',
                    userProvider.playbackNotifications,
                    (value) => userProvider.togglePlaybackNotifications(),
                    Icons.notifications,
                  ),
                  _buildSwitchTile(
                    'New Music Notifications',
                    userProvider.newMusicNotifications,
                    (value) => userProvider.toggleNewMusicNotifications(),
                    Icons.new_releases,
                  ),
                  _buildSwitchTile(
                    'Playlist Updates',
                    userProvider.playlistUpdateNotifications,
                    (value) => userProvider.togglePlaylistUpdateNotifications(),
                    Icons.playlist_add,
                  ),
                ]),
                
                SizedBox(height: 24),
                
                _buildSection('Data & Storage', [
                  _buildActionTile(
                    'Clear Search History',
                    'Remove all search history',
                    Icons.history,
                    () => _clearSearchHistory(),
                  ),
                  _buildActionTile(
                    'Clear Recently Played',
                    'Remove recently played songs',
                    Icons.clear_all,
                    () => _clearRecentlyPlayed(),
                  ),
                  _buildActionTile(
                    'Storage Usage',
                    'View storage statistics',
                    Icons.storage,
                    () => _showStorageStats(),
                  ),
                  _buildActionTile(
                    'Export Data',
                    'Backup your data',
                    Icons.backup,
                    () => _exportData(),
                  ),
                  _buildActionTile(
                    'Clear All Data',
                    'Reset app to default state',
                    Icons.delete_forever,
                    () => _clearAllData(),
                    isDestructive: true,
                  ),
                ]),
                
                SizedBox(height: 100), // Space for bottom navigation
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildUserInfo(UserProvider userProvider) {
    return Card(
      color: Colors.grey.shade900,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.green,
          child: Text(
            userProvider.userName.isNotEmpty ? userProvider.userName[0].toUpperCase() : 'U',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(userProvider.userName, style: TextStyle(color: Colors.white)),
        subtitle: Text(userProvider.userEmail, style: TextStyle(color: Colors.grey)),
        trailing: Icon(Icons.edit, color: Colors.white),
        onTap: () => _editUserInfo(),
      ),
    );
  }

  Widget _buildSwitchTile(String title, bool value, Function(bool) onChanged, IconData icon) {
    return Card(
      color: Colors.grey.shade900,
      child: SwitchListTile(
        title: Text(title, style: TextStyle(color: Colors.white)),
        value: value,
        onChanged: onChanged,
        secondary: Icon(icon, color: Colors.white),
        activeColor: Colors.green,
      ),
    );
  }

  Widget _buildSliderTile(
    String title,
    double value,
    Function(double) onChanged,
    IconData icon, {
    double min = 0.0,
    double max = 1.0,
    int? divisions,
    String suffix = '',
  }) {
    return Card(
      color: Colors.grey.shade900,
      child: ListTile(
        leading: Icon(icon, color: Colors.white),
        title: Text(title, style: TextStyle(color: Colors.white)),
        subtitle: Column(
          children: [
            Slider(
              value: value,
              min: min,
              max: max,
              divisions: divisions,
              onChanged: onChanged,
              activeColor: Colors.green,
            ),
            Text(
              '${divisions != null ? value.toInt() : value.toStringAsFixed(2)}$suffix',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownTile(
    String title,
    String value,
    List<String> options,
    Function(String?) onChanged,
    IconData icon,
  ) {
    return Card(
      color: Colors.grey.shade900,
      child: ListTile(
        leading: Icon(icon, color: Colors.white),
        title: Text(title, style: TextStyle(color: Colors.white)),
        trailing: DropdownButton<String>(
          value: value,
          dropdownColor: Colors.grey.shade800,
          style: TextStyle(color: Colors.white),
          items: options.map((String option) {
            return DropdownMenuItem<String>(
              value: option,
              child: Text(option),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildActionTile(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return Card(
      color: Colors.grey.shade900,
      child: ListTile(
        leading: Icon(icon, color: isDestructive ? Colors.red : Colors.white),
        title: Text(
          title,
          style: TextStyle(color: isDestructive ? Colors.red : Colors.white),
        ),
        subtitle: Text(subtitle, style: TextStyle(color: Colors.grey)),
        trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
        onTap: onTap,
      ),
    );
  }

  Widget _buildStorageInfo() {
    return FutureBuilder<int>(
      future: OfflineService.getOfflineStorageSize(),
      builder: (context, snapshot) {
        String sizeText = 'Calculating...';
        if (snapshot.hasData) {
          sizeText = OfflineService.formatFileSize(snapshot.data!);
        }
        
        return Card(
          color: Colors.grey.shade900,
          child: ListTile(
            leading: Icon(Icons.storage, color: Colors.white),
            title: Text('Offline Storage', style: TextStyle(color: Colors.white)),
            subtitle: Text(sizeText, style: TextStyle(color: Colors.grey)),
            trailing: TextButton(
              onPressed: () => _manageOfflineStorage(),
              child: Text('Manage', style: TextStyle(color: Colors.green)),
            ),
          ),
        );
      },
    );
  }

  // Action methods
  void _editUserInfo() {
    // TODO: Implement user info editing
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Edit user info coming soon!')),
    );
  }

  void _clearSearchHistory() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey.shade800,
        title: Text('Clear Search History', style: TextStyle(color: Colors.white)),
        content: Text(
          'This will remove all your search history. This action cannot be undone.',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Provider.of<UserProvider>(context, listen: false).clearSearchHistory();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Search history cleared')),
              );
            },
            child: Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _clearRecentlyPlayed() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey.shade800,
        title: Text('Clear Recently Played', style: TextStyle(color: Colors.white)),
        content: Text(
          'This will remove all recently played songs. This action cannot be undone.',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Provider.of<AudioProvider>(context, listen: false).clearRecentlyPlayed();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Recently played cleared')),
              );
            },
            child: Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showStorageStats() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    Map<String, dynamic> stats = await userProvider.getStorageStats();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey.shade800,
        title: Text('Storage Statistics', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStatRow('Playlists', stats['playlists'].toString()),
            _buildStatRow('Songs in Playlists', stats['playlistSongs'].toString()),
            _buildStatRow('Recently Played', stats['recentlyPlayed'].toString()),
            _buildStatRow('Liked Songs', stats['likedSongs'].toString()),
            _buildStatRow('Offline Songs', stats['offlineSongs'].toString()),
            _buildStatRow('Search History Items', stats['searchHistoryItems'].toString()),
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

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.white)),
          Text(value, style: TextStyle(color: Colors.green)),
        ],
      ),
    );
  }

  void _exportData() async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      Map<String, dynamic> data = await userProvider.exportUserData();
      
      // In a real app, you'd save this to a file or share it
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Data exported successfully! ${data.keys.length} sections exported.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to export data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _manageOfflineStorage() {
    // TODO: Navigate to offline storage management screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Offline storage management coming soon!')),
    );
  }

  void _clearAllData() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey.shade800,
        title: Text('Clear All Data', style: TextStyle(color: Colors.red)),
        content: Text(
          'This will permanently delete all your playlists, preferences, and downloaded music. This action cannot be undone.',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              final userProvider = Provider.of<UserProvider>(context, listen: false);
              await userProvider.clearAllUserData();
              await OfflineService.clearAllOfflineData();
              
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('All data cleared successfully'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: Text('Clear All', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}