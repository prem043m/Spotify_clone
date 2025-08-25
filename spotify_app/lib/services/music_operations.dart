import 'package:spotify_app/models/music.dart';

class MusicOperations {
  static List<Music> getMusic() {
    return [
      Music(
        'Arjit Singh Hit Songs',
        'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=300&h=300&fit=crop',
        'Best of Arjit Singh',
        'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
      ),
      Music(
        'Bollywood Classics',
        'https://images.unsplash.com/photo-1514525253161-7a46d19cd819?w=300&h=300&fit=crop',
        'Golden Era Hits',
        'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3',
      ),
      Music(
        'Latest Hindi Songs',
        'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=300&h=300&fit=crop',
        '2024 Chart Toppers',
        'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3',
      ),
      Music(
        'Punjabi Hits',
        'https://images.unsplash.com/photo-1516280440614-37939bbacd81?w=300&h=300&fit=crop',
        'Best Punjabi Collection',
        'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-4.mp3',
      ),
       Music(
        'Toofan',
        'https://c.saavncdn.com/325/Toofaan-Hindi-2021-20210715130152-500x500.jpg',
        'Dekh Toofan Aaya Hai',
        'https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview122/v4/9f/50/9d/9f509dab-4fc8-e761-21fd-63ee6d7948b0/mzaf_15478495451126525488.plus.aac.p.m4a',
      ),
      Music(
          'Gully Boy',
          'https://m.media-amazon.com/images/S/pv-target-images/6837cb65d1dc471e1524c795465dd3ed340e82c8a19d5a6dac07c3228dd9b447.jpg',
          'Apma Time Aayega',
          'https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview221/v4/4a/4a/1e/4a4a1e51-5960-83ce-8f3a-56855d1a772b/mzaf_16621016366649355175.plus.aac.p.m4a'),
      Music(
        'Pehli Dafa',
        'https://c-cdnet.cdn.smule.com/rs-s-sf-4/arr/21/31/8bb0d9f8-75de-47bd-bf86-a6d611eeda07.jpg',
        'Pehli Dafa song by Atif Alsam',
        'https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview125/v4/a0/94/f9/a094f99f-c175-d9dd-c475-040048553ea1/mzaf_16550135546441316062.plus.aac.p.m4a',
      ),
      Music(
          'iraaday',
          'https://i1.sndcdn.com/artworks-cQQh0tygRiehkryF-LfKbgw-t500x500.jpg',
          'Iraaday song by Abdul hanan and rovalio',
          'https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview116/v4/d4/c1/00/d4c100e1-e10e-2921-e7b5-e35fe63686b7/mzaf_5395771005331787492.plus.aac.p.m4a')
    ];
  }
}