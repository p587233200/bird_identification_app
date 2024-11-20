import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:async';

class HuggingChatPage extends StatefulWidget {
  const HuggingChatPage({Key? key}) : super(key: key);

  @override
  State<HuggingChatPage> createState() => _HuggingChatPageState();
}

class _HuggingChatPageState extends State<HuggingChatPage> {
  late WebViewController _controller;
  bool _isLoading = true;
  String _errorMessage = '';

  // 模擬 Chrome 瀏覽器的 User-Agent
  final String _userAgent =
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36';

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  Future<void> _initWebView() async {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setUserAgent(_userAgent)  // 設置自訂 User-Agent
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
              _errorMessage = '';
            });
          },
          onPageFinished: (String url) async {
            // 注入 JavaScript 來修改某些網頁行為（如果需要）
            await _injectCustomJS();
            setState(() {
              _isLoading = false;
            });
          },
          onWebResourceError: (WebResourceError error) {
            print('WebView Error: ${error.description}');  // 添加錯誤日誌
            setState(() {
              _isLoading = false;
              _errorMessage = '載入失敗: ${error.description}';
            });
          },
          onNavigationRequest: (NavigationRequest request) {
            print('Navigating to: ${request.url}');  // 添加導航日誌
            return NavigationDecision.navigate;
          },
        ),
      )
    // 添加自訂標頭
      ..loadRequest(
        Uri.parse('https://hf.co/chat/assistant/662677dee22a8dbead82fa87'),
        headers: {
          'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
          'Accept-Language': 'en-US,en;q=0.5',
          'Referer': 'https://huggingface.co/',
        },
      );
  }

  Future<void> _injectCustomJS() async {
    // 注入自訂 JavaScript 來處理特定問題
    await _controller.runJavaScript('''
      // 可以在這裡添加自訂 JavaScript
      // 例如修改某些元素或行為
    ''');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hugging Chat'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _controller.reload();
            },
          ),
          // 添加更多的操作按鈕
          IconButton(
            icon: const Icon(Icons.open_in_browser),
            onPressed: () async {
              // 在外部瀏覽器中開啟
              final url = await _controller.currentUrl();
              if (url != null) {
                // 使用 url_launcher 套件開啟外部瀏覽器
                // await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
              }
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
          if (_errorMessage.isNotEmpty)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _errorMessage,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      _controller.reload();
                    },
                    child: const Text('重試'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // 清除快取並重新載入
                      _controller.clearCache();
                      _controller.clearLocalStorage();
                      _controller.reload();
                    },
                    child: const Text('清除快取並重試'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}