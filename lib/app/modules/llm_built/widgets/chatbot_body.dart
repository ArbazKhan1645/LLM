import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:llm_video_shopify/app/modules/llm_built/controllers/llm_built_controller.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:async';

class ChatbotView extends GetView<LlmBuiltController> {
  const ChatbotView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('PitchPal'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Force refresh from app bar
              Get.find<_OptimizedWebViewState>()._forceRefresh();
            },
          ),
        ],
      ),
      body: _OptimizedWebView(),
    );
  }
}

class _OptimizedWebView extends StatefulWidget {
  @override
  _OptimizedWebViewState createState() => _OptimizedWebViewState();
}

class _OptimizedWebViewState extends State<_OptimizedWebView> {
  late final WebViewController _webViewController;
  bool _isLoading = true;
  bool _hasError = false;
  String errorMessage = '';
  int _retryCount = 0;
  final int _maxRetries = 3;
  Timer? _retryTimer;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    // Register this instance for external access
    Get.put(this);
    _initializeWebViewWithRetry();
  }

  void _initializeWebViewWithRetry() async {
    try {
      await _initializeWebView();
      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      debugPrint('WebView initialization failed: $e');
      if (_retryCount < _maxRetries) {
        _retryCount++;
        _retryTimer = Timer(Duration(seconds: 2), () {
          _initializeWebViewWithRetry();
        });
      } else {
        setState(() {
          _hasError = true;
          errorMessage =
              'Failed to initialize WebView after $_maxRetries attempts';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _initializeWebView() async {
    _webViewController = WebViewController();

    await _webViewController.setJavaScriptMode(JavaScriptMode.unrestricted);
    await _webViewController.setBackgroundColor(Colors.white);

    // Add user agent to help with compatibility
    await _webViewController.setUserAgent(
      'Mozilla/5.0 (Linux; Android 10; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.120 Mobile Safari/537.36',
    );

    // Enhanced navigation delegate
    await _webViewController.setNavigationDelegate(
      NavigationDelegate(
        onProgress: (int progress) {
          // Update loading progress
          debugPrint('Loading progress: $progress%');
        },
        onPageStarted: (String url) {
          debugPrint('Page started loading: $url');
          if (mounted) {
            setState(() {
              _isLoading = true;
              _hasError = false;
            });
          }
        },
        onPageFinished: (String url) {
          debugPrint('Page finished loading: $url');
          if (mounted) {
            setState(() {
              _isLoading = false;
              _retryCount = 0; // Reset retry count on success
            });
          }

          // Inject JavaScript to handle potential issues
          _injectErrorHandlingJS();
        },
        onWebResourceError: (WebResourceError error) {
          debugPrint('WebView error: ${error.description}');
          if (mounted) {
            setState(() {
              _isLoading = false;
              errorMessage = error.description ?? 'Unknown error occurred';
              _hasError = true;
            });
          }

          // Auto-retry on certain errors
          if (_shouldAutoRetry(error)) {
            _autoRetryAfterDelay();
          }
        },
        onHttpError: (HttpResponseError error) {
          debugPrint('HTTP error: ${error.response?.statusCode}');
          if (mounted) {
            setState(() {
              _isLoading = false;
              errorMessage =
                  'HTTP Error: ${error.response?.statusCode ?? 'Unknown'}';
              _hasError = true;
            });
          }
        },
        onNavigationRequest: (NavigationRequest request) {
          debugPrint('Navigation request: ${request.url}');

          // Allow navigation to the main domain and common subdomains
          if (request.url.startsWith('https://pitchpal.zapier.app/') ||
              request.url.startsWith('https://zapier.app/') ||
              request.url.startsWith('https://hooks.zapier.com/')) {
            return NavigationDecision.navigate;
          }

          // For external links, you might want to open in browser
          // launchUrl(Uri.parse(request.url));
          return NavigationDecision.prevent;
        },
      ),
    );

    // Load the URL with error handling
    await _loadUrlWithRetry();
  }

  Future<void> _loadUrlWithRetry() async {
    try {
      await _webViewController.loadRequest(
        Uri.parse('https://pitchpal.zapier.app/'),
      );
    } catch (e) {
      debugPrint('Failed to load URL: $e');
      if (_retryCount < _maxRetries) {
        _retryCount++;
        await Future.delayed(Duration(seconds: 2));
        await _loadUrlWithRetry();
      } else {
        throw Exception('Failed to load URL after $_maxRetries attempts');
      }
    }
  }

  bool _shouldAutoRetry(WebResourceError error) {
    // Auto-retry on network-related errors
    final retryableErrors = [
      'net::ERR_INTERNET_DISCONNECTED',
      'net::ERR_NETWORK_CHANGED',
      'net::ERR_TIMED_OUT',
      'net::ERR_CONNECTION_REFUSED',
      'net::ERR_TEMPORARILY_THROTTLED',
    ];

    return retryableErrors.any(
      (errorCode) => error.description?.contains(errorCode) ?? false,
    );
  }

  void _autoRetryAfterDelay() {
    if (_retryCount < _maxRetries) {
      _retryTimer?.cancel();
      _retryTimer = Timer(Duration(seconds: 5), () {
        _retryCount++;
        _refreshWebView();
      });
    }
  }

  void _injectErrorHandlingJS() {
    _webViewController.runJavaScript('''
      // Handle JavaScript errors
      window.addEventListener('error', function(e) {
        console.log('JS Error:', e.message);
      });
      
      // Handle unhandled promise rejections
      window.addEventListener('unhandledrejection', function(e) {
        console.log('Unhandled Promise Rejection:', e.reason);
      });
      
      // Add a custom refresh function
      window.flutterRefresh = function() {
        location.reload();
      };
    ''');
  }

  Future<void> _refreshWebView() async {
    if (!_isInitialized) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      await _webViewController.reload();
    } catch (e) {
      debugPrint('Refresh failed: $e');
      setState(() {
        _hasError = true;
        errorMessage = 'Failed to refresh: $e';
        _isLoading = false;
      });
    }
  }

  void _forceRefresh() {
    _retryCount = 0;
    _refreshWebView();
  }

  Future<void> _hardReset() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _retryCount = 0;
    });

    // Clear cache and cookies
    await _webViewController.clearCache();
    await _webViewController.clearLocalStorage();

    // Reinitialize
    await _initializeWebView();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Main WebView
        if (_isInitialized && !_hasError)
          RefreshIndicator(
            onRefresh: _refreshWebView,
            child: WebViewWidget(controller: _webViewController),
          ),

        // Loading indicator
        if (_isLoading)
          Container(
            color: Colors.white,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'Loading PitchPal...',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  if (_retryCount > 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        'Retry attempt $_retryCount/$_maxRetries',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
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
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                    SizedBox(height: 16),
                    Text(
                      'Failed to load PitchPal',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      errorMessage,
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: _refreshWebView,
                          child: Text('Retry'),
                        ),
                        SizedBox(width: 16),
                        OutlinedButton(
                          onPressed: _hardReset,
                          child: Text('Hard Reset'),
                        ),
                      ],
                    ),
                    if (_retryCount >= _maxRetries)
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Text(
                          'If the problem persists, please check your internet connection and try again later.',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  @override
  void dispose() {
    _retryTimer?.cancel();
    Get.delete<_OptimizedWebViewState>();
    super.dispose();
  }
}
