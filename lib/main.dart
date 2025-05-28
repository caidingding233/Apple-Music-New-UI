import 'package:flutter/material.dart';
import 'package:audio_service/audio_service.dart';
import 'package:provider/provider.dart';
import 'package:musicplayer/Bottom%20NavBar/bottom_nav.dart';
import 'package:musicplayer/pages/list.dart';
import 'package:musicplayer/pages/album_page.dart';
import 'package:musicplayer/pages/artist_list.dart';
import 'package:musicplayer/pages/artist_page.dart';
import 'package:musicplayer/pages/browse_page.dart';
import 'package:musicplayer/pages/home_page.dart';
import 'package:musicplayer/pages/music_list.dart';
import 'package:musicplayer/pages/music_player.dart';
import 'package:musicplayer/pages/radio.dart';
import 'package:musicplayer/pages/search_page.dart';
import 'package:musicplayer/pages/library_page.dart';
import 'package:musicplayer/pages/login_page.dart';
import 'package:musicplayer/pages/demo_music_page.dart';
import 'package:musicplayer/pages/simple_demo_page.dart';
import 'package:musicplayer/pages/real_apple_music_page.dart';
import 'package:musicplayer/services/harmony_audio_service.dart';
import 'package:musicplayer/services/auth_service.dart';
import 'package:musicplayer/services/music_service.dart';
import 'package:musicplayer/services/music_player_service.dart';
import 'package:musicplayer/services/apple_music_service.dart';
import 'package:musicplayer/utils/harmony_device_adapter.dart';
// import 'package:musicplayer/harmony_plugins/flutter_ohos_plugin/lib/flutter_ohos_plugin.dart';

// 启用鸿蒙音频服务
late AudioHandler _audioHandler;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化音频服务
  _audioHandler = await AudioService.init(
    builder: () => HarmonyAudioHandler.instance,
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.example.musicplayer.channel.audio',
      androidNotificationChannelName: 'Apple Music 鸿蒙版',
      androidNotificationOngoing: true,
      androidShowNotificationBadge: true,
    ),
  );
  
  // 初始化鸿蒙音频服务
  await HarmonyAudioHandler.instance.initialize();
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthService>(create: (_) => AuthService()),
        ChangeNotifierProvider<MusicService>(create: (_) => MusicService()),
        ChangeNotifierProvider<MusicPlayerService>(create: (_) => MusicPlayerService()),
        ChangeNotifierProvider<AppleMusicService>(create: (_) => AppleMusicService()),
      ],
      child: MaterialApp(
        theme: ThemeData(
          colorScheme: const ColorScheme.dark(),
          scaffoldBackgroundColor: const Color.fromARGB(255, 33, 33, 36),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
          ),
        ),
        debugShowCheckedModeBanner: false,
        home: const AuthWrapper(),
        routes: {
          '/login': (context) => const LoginPage(),
          '/demo': (context) => const DemoMusicPage(),
          '/real-apple-music': (context) => const RealAppleMusicPage(),
          '/list_test': (context) => const ListTest(),
          '/firstpage': (context) => FirstPage(),
          '/browse': (context) => const BrowsePage(),
          '/radio': (context) => const RadioPage(),
          '/library': (context) => const LibraryPage(),
          '/search': (context) => const SearchPage(),
          '/home': (context) => const HomePage(),
          '/album': (context) => const AlbumPage(),
          '/artist': (context) => const ArtistPage(),
          '/artistlist': (context) => const ArtistList(),
          '/musiclist': (context) => const MusicList(),
          '/player': (context) => const MusicPlayer(),
        },
      ),
    );
  }
}

/// 认证包装器 - 根据登录状态显示不同页面
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, child) {
        if (authService.isLoggedIn) {
          // 已登录，显示真正的Apple Music页面
          return const RealAppleMusicPage();
        } else {
          // 未登录，显示登录页面
          return const LoginPage();
        }
      },
    );
  }
}
