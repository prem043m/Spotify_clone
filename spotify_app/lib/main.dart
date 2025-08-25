import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spotify_app/screens/app.dart';
import 'package:spotify_app/providers/audio_provider.dart';
import 'package:spotify_app/providers/user_provider.dart';
import 'package:spotify_app/services/music_operations.dart';
import 'package:spotify_app/services/database_helper.dart';
import 'package:spotify_app/services/preferences_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize database first
  await DatabaseHelper.database;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AudioProvider()),
        ChangeNotifierProvider(create: (context) => UserProvider()),
      ],
      child: MySpotifyApp(),
    ),
  );
}

class MySpotifyApp extends StatefulWidget {
  @override
  State<MySpotifyApp> createState() => _MySpotifyAppState();
}

class _MySpotifyAppState extends State<MySpotifyApp> {
  @override
  void initState() {
    super.initState();
    // Initialize providers with sample data after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeProviders();
    });
  }

  void _initializeProviders() {
    final audioProvider = Provider.of<AudioProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    // Get sample music data
    final sampleMusic = MusicOperations.getMusic();

    // Initialize providers with sample data
    audioProvider.initializeSampleData(sampleMusic);
    userProvider.initializeWithSampleData(sampleMusic);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        return MaterialApp(
          title: 'Spotify Clone',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            brightness:
                userProvider.isDarkMode ? Brightness.dark : Brightness.light,
            primarySwatch: Colors.green,
            scaffoldBackgroundColor:
                userProvider.isDarkMode ? Colors.black : Colors.white,
            appBarTheme: AppBarTheme(
              backgroundColor:
                  userProvider.isDarkMode ? Colors.black : Colors.white,
              foregroundColor:
                  userProvider.isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          home: const MyApp(),
        );
      },
    );
  }
}
