import 'package:flutter/material.dart';
import 'package:musicplayer/pages/apple_music_simple_web_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const WebViewTestApp());
}

class WebViewTestApp extends StatelessWidget {
  const WebViewTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Apple Music WebView 测试',
      theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      home: const TestHomePage(),
    );
  }
}

class TestHomePage extends StatelessWidget {
  const TestHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Apple Music WebView 测试')),
      body: Center(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFA233B)),
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AppleMusicSimpleWebPage()),
          ),
          child: const Text('打开 Apple Music 网页版'),
        ),
      ),
    );
  }
} 