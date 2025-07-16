import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:llm_video_shopify/app/modules/llm_built/controllers/llm_built_controller.dart';
import 'package:webview_flutter/webview_flutter.dart';

class StorebotView extends GetView<LlmBuiltController> {
  const StorebotView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Prevents the WebView from resizing when keyboard appears
      resizeToAvoidBottomInset: false,

      body: SafeArea(child: _OptimizedWebView()),
    );
  }
}

class _OptimizedWebView extends StatefulWidget {
  @override
  _OptimizedWebViewState createState() => _OptimizedWebViewState();
}

class _OptimizedWebViewState extends State<_OptimizedWebView>
    with AutomaticKeepAliveClientMixin {
  late final WebViewController _webViewController;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  bool get wantKeepAlive => true; // Keeps the WebView alive

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    _webViewController = WebViewController();

    _webViewController
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      // Performance optimizations
      ..setUserAgent(
        'Mozilla/5.0 (Linux; Android 10) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.120 Mobile Safari/537.36',
      )
      // Navigation delegate for better control
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading progress if needed
          },
          onPageStarted: (String url) {
            if (mounted) {
              setState(() {
                _isLoading = true;
                _hasError = false;
              });
            }
          },
          onPageFinished: (String url) {
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
            }

            // Inject CSS to optimize performance and keyboard handling
            _injectOptimizationScript();
          },
          onWebResourceError: (WebResourceError error) {
            if (mounted) {
              setState(() {
                _isLoading = false;
                _hasError = true;
              });
            }
          },
          onNavigationRequest: (NavigationRequest request) {
            // Allow navigation to the main domain and common subdomains
            if (request.url.startsWith(
                  'https://pitchdifferent.net/collections/',
                ) ||
                request.url.startsWith('https://pitchdifferent.net/cart') ||
                request.url.startsWith(
                  'https://pitchdifferent.net/products/',
                ) ||
                request.url.startsWith(
                  'https://pitchdifferent.net/checkouts',
                )) {
              return NavigationDecision.navigate;
            }
            // Block other navigations to prevent performance issues
            return NavigationDecision.prevent;
          },
        ),
      )
      // Load the URL
      ..loadRequest(Uri.parse('https://pitchdifferent.net/collections/all'));
  }

  void _injectOptimizationScript() {
    // Inject JavaScript to improve performance
    _webViewController.runJavaScript('''
      // Optimize scrolling performance
      document.body.style.webkitOverflowScrolling = 'touch';
      document.body.style.overflowScrolling = 'touch';
      
      // Prevent zoom on input focus (reduces keyboard lag)
      var meta = document.createElement('meta');
      meta.name = 'viewport';
      meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';
      document.getElementsByTagName('head')[0].appendChild(meta);
      
      // Debounce scroll events
      let scrollTimeout;
      window.addEventListener('scroll', function() {
        clearTimeout(scrollTimeout);
        scrollTimeout = setTimeout(function() {
          // Scroll handling logic if needed
        }, 16); // ~60fps
      }, { passive: true });
      
      // Optimize animations
      document.body.style.willChange = 'auto';
      
      // Reduce reflows and repaints
      document.body.style.transform = 'translateZ(0)';
    ''');
  }

  Future<void> _refreshWebView() async {
    await _webViewController.reload();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    return Stack(
      children: [
        // Main WebView
        RefreshIndicator(
          onRefresh: _refreshWebView,
          child: WebViewWidget(controller: _webViewController),
        ),

        // Loading indicator
        if (_isLoading)
          Container(
            color: Colors.white,
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'Loading PitchPal...',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),

        // Error state
        if (_hasError && !_isLoading)
          Container(
            color: Colors.white,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'Failed to load PitchPal',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Please check your internet connection',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _hasError = false;
                      });
                      _webViewController.reload();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  @override
  void dispose() {
    // Clean up resources
    super.dispose();
  }
}
