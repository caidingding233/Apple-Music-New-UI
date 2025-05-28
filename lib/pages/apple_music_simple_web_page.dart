import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart' as fw;
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

/// Apple Music 简化版嵌入页面（使用旧 WebView API）
class AppleMusicSimpleWebPage extends StatefulWidget {
  const AppleMusicSimpleWebPage({super.key});

  @override
  State<AppleMusicSimpleWebPage> createState() => _AppleMusicSimpleWebPageState();
}

class _AppleMusicSimpleWebPageState extends State<AppleMusicSimpleWebPage> {
  fw.WebViewController? _controller;
  bool _isLoading = true;
  InAppWebViewController? _inAppController;

  @override
  Widget build(BuildContext context) {
    // macOS 使用 InAppWebView，其他平台保持 WebView
    Widget webViewWidget;
    if (defaultTargetPlatform == TargetPlatform.macOS) {
      webViewWidget = InAppWebView(
        initialUrlRequest: URLRequest(url: Uri.parse('https://music.apple.com')),
        initialOptions: InAppWebViewGroupOptions(
          crossPlatform: InAppWebViewOptions(
            javaScriptEnabled: true,
            mediaPlaybackRequiresUserGesture: false,
            transparentBackground: false,
          ),
        ),
        onLoadStart: (_, __) => setState(() => _isLoading = true),
        onLoadStop: (_, __) => setState(() => _isLoading = false),
        onWebViewCreated: (controller) {
          _inAppController = controller;
        },
      );
    } else {
      webViewWidget = fw.WebView(
        initialUrl: 'https://music.apple.com',
        javascriptMode: fw.JavascriptMode.unrestricted,
        onWebViewCreated: (ctrl) => _controller = ctrl,
        onPageStarted: (_) => setState(() => _isLoading = true),
        onPageFinished: (_) => setState(() => _isLoading = false),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Apple Music 网页版'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              if (defaultTargetPlatform == TargetPlatform.macOS) {
                _inAppController?.reload();
              } else {
                _controller?.reload();
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (_isLoading) const LinearProgressIndicator(minHeight: 2),
          Expanded(child: webViewWidget),
        ],
      ),
    );
  }
} 