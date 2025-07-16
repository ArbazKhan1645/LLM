// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:llm_video_shopify/app/routes/app_pages.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ZapierChatbotWebView extends StatefulWidget {
  const ZapierChatbotWebView({super.key});

  @override
  State<ZapierChatbotWebView> createState() => _ZapierChatbotWebViewState();
}

class _ZapierChatbotWebViewState extends State<ZapierChatbotWebView> {
  late final WebViewController _controller;
  bool isLoading = true;
  String lastAiResponse = '';
  bool autoFocusDisabled = true;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    _controller =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setNavigationDelegate(
            NavigationDelegate(
              onPageStarted: (String url) {
                setState(() {
                  isLoading = true;
                });
              },
              onPageFinished: (String url) {
                setState(() {
                  isLoading = false;
                });
                // Apply styling immediately
                _applyInputStyling();

                Future.delayed(const Duration(seconds: 1), () {
                  _injectResponseDetectionScript();
                  if (autoFocusDisabled) {
                    _disableAutoFocus();
                  }
                  // Apply styling again after scripts load
                  _applyInputStyling();
                });
              },
            ),
          )
          ..loadRequest(Uri.parse('https://pitchpal.zapier.app'));
  }

  void _applyInputStyling() {
    _controller.runJavaScript('''
      (function() {
        console.log('Applying input field styling...');
        
        function styleInputs() {
          // Style all input fields, textareas, and contenteditable elements
          const inputSelectors = [
            'input[type="text"]',
            'input[type="email"]', 
            'input[type="password"]',
            'input[type="search"]',
            'input:not([type])',
            'textarea',
            '[contenteditable="true"]',
            '[role="textbox"]'
          ];
          
          inputSelectors.forEach(selector => {
            document.querySelectorAll(selector).forEach(input => {
              // Set background and text colors
              input.style.backgroundColor = '#ffffff !important';
              input.style.color = '#000000 !important';
              input.style.border = '2px solid #007bff !important';
              input.style.borderRadius = '8px !important';
              input.style.padding = '12px !important';
              input.style.fontSize = '16px !important';
              input.style.fontFamily = 'system-ui, -apple-system, sans-serif !important';
              input.style.outline = 'none !important';
              input.style.boxShadow = 'none !important';
              
              // Focus state styling
              input.addEventListener('focus', function() {
                this.style.backgroundColor = '#ffffff !important';
                this.style.color = '#000000 !important';
                this.style.borderColor = '#0056b3 !important';
                this.style.boxShadow = '0 0 0 3px rgba(0, 123, 255, 0.25) !important';
              });
              
              // Blur state styling
              input.addEventListener('blur', function() {
                this.style.backgroundColor = '#ffffff !important';
                this.style.color = '#000000 !important';
                this.style.borderColor = '#007bff !important';
                this.style.boxShadow = 'none !important';
              });
              
              // Input event to maintain styling
              input.addEventListener('input', function() {
                this.style.backgroundColor = '#ffffff !important';
                this.style.color = '#000000 !important';
              });
            });
          });
          
          // Override any CSS that might interfere
          const styleElement = document.createElement('style');
          styleElement.textContent = `
            input, textarea, [contenteditable="true"], [role="textbox"] {
              background-color: #ffffff !important;
              color: #000000 !important;
              border: 2px solid #007bff !important;
              border-radius: 8px !important;
              padding: 12px !important;
              font-size: 16px !important;
              font-family: system-ui, -apple-system, sans-serif !important;
            }
            
            input:focus, textarea:focus, [contenteditable="true"]:focus, [role="textbox"]:focus {
              background-color: #ffffff !important;
              color: #000000 !important;
              border-color: #0056b3 !important;
              box-shadow: 0 0 0 3px rgba(0, 123, 255, 0.25) !important;
              outline: none !important;
            }
            
            input::placeholder, textarea::placeholder {
              color: #6c757d !important;
              opacity: 1 !important;
            }
            
            /* Dark theme overrides */
            [data-theme="dark"] input,
            [data-theme="dark"] textarea,
            .dark input,
            .dark textarea,
            body.dark input,
            body.dark textarea {
              background-color: #ffffff !important;
              color: #000000 !important;
              border-color: #007bff !important;
            }
          `;
          
          // Add to head if not already added
          if (!document.getElementById('custom-input-styles')) {
            styleElement.id = 'custom-input-styles';
            document.head.appendChild(styleElement);
          }
        }
        
        // Apply styling immediately
        styleInputs();
        
        // Watch for new inputs being added
        const observer = new MutationObserver(function(mutations) {
          let shouldRestyle = false;
          mutations.forEach(function(mutation) {
            if (mutation.type === 'childList') {
              mutation.addedNodes.forEach(function(node) {
                if (node.nodeType === 1) {
                  if (node.matches && node.matches('input, textarea, [contenteditable], [role="textbox"]')) {
                    shouldRestyle = true;
                  }
                  if (node.querySelectorAll) {
                    const inputs = node.querySelectorAll('input, textarea, [contenteditable], [role="textbox"]');
                    if (inputs.length > 0) {
                      shouldRestyle = true;
                    }
                  }
                }
              });
            }
          });
          
          if (shouldRestyle) {
            setTimeout(styleInputs, 100);
          }
        });
        
        observer.observe(document.body, {
          childList: true,
          subtree: true
        });
        
        console.log('Input styling applied');
      })();
    ''');
  }

  void _disableAutoFocus() {
    _controller.runJavaScript('''
      (function() {
        console.log('Disabling auto-focus...');
        
        function preventAutoFocus() {
          // Remove autofocus from existing elements
          document.querySelectorAll('[autofocus]').forEach(el => {
            el.removeAttribute('autofocus');
            el.blur();
          });
          
          // Blur any currently focused inputs
          document.querySelectorAll('input:focus, textarea:focus').forEach(el => el.blur());
          
          // Track user interactions
          let userInteracting = false;
          let interactionTimeout;
          
          function markUserInteraction() {
            userInteracting = true;
            clearTimeout(interactionTimeout);
            interactionTimeout = setTimeout(() => { userInteracting = false; }, 300);
          }
          
          document.addEventListener('touchstart', markUserInteraction, { passive: true });
          document.addEventListener('mousedown', markUserInteraction);
          document.addEventListener('click', markUserInteraction);
          
          // Override focus for all inputs
          document.querySelectorAll('input, textarea, [contenteditable]').forEach(input => {
            const originalFocus = input.focus;
            input.focus = function() {
              if (userInteracting) {
                originalFocus.call(this);
              }
            };
          });
          
          // Handle dynamically added inputs
          new MutationObserver(mutations => {
            mutations.forEach(mutation => {
              mutation.addedNodes.forEach(node => {
                if (node.nodeType === 1) {
                  const inputs = node.querySelectorAll ? 
                    node.querySelectorAll('input, textarea, [contenteditable]') : [];
                  
                  if (node.matches && node.matches('input, textarea, [contenteditable]')) {
                    inputs.push(node);
                  }
                  
                  inputs.forEach(input => {
                    input.removeAttribute('autofocus');
                    input.blur();
                    
                    const originalFocus = input.focus;
                    input.focus = function() {
                      if (userInteracting) {
                        originalFocus.call(this);
                      }
                    };
                  });
                }
              });
            });
          }).observe(document.body, { childList: true, subtree: true });
        }
        
        // Run immediately and after delays
        preventAutoFocus();
        setTimeout(preventAutoFocus, 1000);
        setTimeout(preventAutoFocus, 3000);
        
        console.log('Auto-focus disabled');
        
        // Ensure input styling is maintained
        setTimeout(() => {
          document.querySelectorAll('input, textarea, [contenteditable]').forEach(input => {
            input.style.backgroundColor = '#ffffff !important';
            input.style.color = '#000000 !important';
          });
        }, 500);
      })();
    ''');
  }

  void _enableAutoFocus() {
    _controller.runJavaScript('''
      (function() {
        console.log('Enabling auto-focus...');
        // Reload page to restore original behavior
        window.location.reload();
      })();
    ''');
  }

  void _reapplyStyling() {
    _applyInputStyling();
  }

  void _injectResponseDetectionScript() {
    _controller.runJavaScript('''
      (function() {
        console.log('Injecting response detection...');
        
        let lastBotMessage = '';
        
        function extractCompleteResponse() {
          // Find all container elements
          const containers = document.querySelectorAll('li, div, article, section');
          let uniqueContainers = new Map();
          
          containers.forEach((container, index) => {
            const text = (container.textContent || '').trim();
            
            if (text.length < 50) return;
            
            // Skip user messages
            if (text.toLowerCase().startsWith('you:') || 
                text.toLowerCase().startsWith('user:') ||
                container.querySelector('input, textarea')) return;
            
            // Clean text
            let cleanText = text
              .replace(/^(PitchPal|Bot|AI|Assistant)\\s*:?\\s*/i, '')
              .replace(/Positive rating\\s*/gi, '')
              .replace(/Negative rating\\s*/gi, '')
              .replace(/\\d+:\\d+\\s*(am|pm)\\s*/gi, '')
              .trim();
            
            // Use first 100 chars as key to detect duplicates
            const contentKey = cleanText.substring(0, 100).toLowerCase();
            
            if (!uniqueContainers.has(contentKey) || cleanText.length > uniqueContainers.get(contentKey).text.length) {
              let score = 0;
              
              // Score based on content
              if (cleanText.toLowerCase().includes('thank you')) score += 5;
              if (cleanText.toLowerCase().includes('business proposal')) score += 4;
              if (cleanText.toLowerCase().includes('questions')) score += 3;
              if (cleanText.toLowerCase().includes('information')) score += 2;
              if (cleanText.length > 500) score += 3;
              if (cleanText.length > 1000) score += 5;
              
              uniqueContainers.set(contentKey, {
                text: cleanText,
                score: score,
                index: index
              });
            }
          });
          
          // Find best container
          let bestResponse = '';
          let bestScore = 0;
          
          uniqueContainers.forEach(containerData => {
            if (containerData.score > bestScore) {
              bestScore = containerData.score;
              bestResponse = containerData.text;
            }
          });
          
          // Add unique list items if needed
          if (bestResponse) {
            const listItems = document.querySelectorAll('li');
            let additionalItems = [];
            let seenContent = new Set();
            
            // Track existing content
            bestResponse.split('\\n').forEach(line => {
              if (line.trim().length > 10) {
                seenContent.add(line.trim().toLowerCase().substring(0, 50));
              }
            });
            
            listItems.forEach(li => {
              const text = (li.textContent || '').trim();
              
              if (text.length > 20 && text.length < 200 && 
                  text.includes(':') && 
                  !text.toLowerCase().startsWith('you:')) {
                
                const contentKey = text.toLowerCase().substring(0, 50);
                
                if (!seenContent.has(contentKey)) {
                  const isRelevant = (
                    text.includes('Company Name') ||
                    text.includes('Business Description') ||
                    text.includes('Key Differentiators') ||
                    text.includes('Target Market') ||
                    text.includes('Project Details') ||
                    text.includes('Website Link') ||
                    text.includes('Best-Fit')
                  );
                  
                  if (isRelevant) {
                    additionalItems.push(text);
                    seenContent.add(contentKey);
                  }
                }
              }
            });
            
            if (additionalItems.length > 0 && !bestResponse.includes(additionalItems[0])) {
              bestResponse += '\\n' + additionalItems.join('\\n');
            }
          }
          
          // Remove duplicate lines
          if (bestResponse) {
            const lines = bestResponse.split('\\n');
            const uniqueLines = [];
            const linesSeen = new Set();
            
            lines.forEach(line => {
              const trimmedLine = line.trim();
              if (trimmedLine.length > 5) {
                const lineKey = trimmedLine.toLowerCase().substring(0, 30);
                if (!linesSeen.has(lineKey)) {
                  uniqueLines.push(trimmedLine);
                  linesSeen.add(lineKey);
                }
              }
            });
            
            return uniqueLines.join('\\n').trim();
          }
          
          return '';
        }
        
        function checkForNewResponse() {
          const response = extractCompleteResponse();
          if (response && response !== lastBotMessage && response.length > 50) {
            lastBotMessage = response;
            window.latestBotResponse = response;
            console.log('New response detected:', response.substring(0, 100));
          }
        }
        
        // Monitor for changes
        new MutationObserver(() => {
          setTimeout(checkForNewResponse, 1000);
        }).observe(document.body, { childList: true, subtree: true });
        
        // Initial check
        setTimeout(checkForNewResponse, 2000);
        setInterval(checkForNewResponse, 3000);
        
        window.getLatestBotResponse = extractCompleteResponse;
        console.log('Response detection active');
      })();
    ''');
  }

  Future<void> _copyLatestResponseAndNavigate() async {
    try {
      final storedResponse = await _controller.runJavaScriptReturningResult('''
        window.latestBotResponse || '';
      ''');

      String response = '';
      if (storedResponse.toString().replaceAll('"', '').trim().isNotEmpty) {
        response = storedResponse.toString().replaceAll('"', '').trim();
      } else {
        final extractedResponse = await _controller
            .runJavaScriptReturningResult('''
          (function() {
            if (window.getLatestBotResponse) {
              return window.getLatestBotResponse();
            }
            return '';
          })();
        ''');

        response = extractedResponse.toString().replaceAll('"', '').trim();
      }

      if (response.isNotEmpty && response.length > 10) {
        await Clipboard.setData(ClipboardData(text: response));

        setState(() {
          lastAiResponse = response;
        });

        Get.toNamed(
          Routes.VIDEO_SCRIPT,
          arguments: formatProposalText(response),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'No AI response found. Please wait for the bot to respond.',
            ),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  final unwantedPatterns = [
    RegExp(
      r"^(PitchPalThank you|Hello|I\'m here|Let\'s get started)",
      caseSensitive: false,
    ),
    RegExp(
      r'(Thank you for providing|To assist you|I need some additional)',
      caseSensitive: false,
    ),
    RegExp(
      r'(Once I have this information|I can create|comprehensive)',
      caseSensitive: false,
    ),
    RegExp(
      r'(Jump to latest|The more information|better the quality)',
      caseSensitive: false,
    ),
    RegExp(r'^(Hi|Hello)[\s!]', caseSensitive: false),
    RegExp(
      r'(help you craft|professional business|tailored to your needs)',
      caseSensitive: false,
    ),
  ]; // ✅ Don't forget this semicolon

  String formatProposalText(String input) {
    // Normalize line breaks and unwanted characters
    var inputs =
        input
            .replaceAll(r'\n', '\n')
            .replaceAll(r'\N', '\n')
            .replaceAll(RegExp(r'(Positive rating|Negative rating)'), '')
            .replaceAll(
              RegExp(r'\d{1,2}:\d{2}(am|pm)', caseSensitive: false),
              '',
            )
            .trim();

    for (final pattern in unwantedPatterns) {
      inputs = inputs.replaceAll(pattern, '');
    }
    print(inputs);

    // Step 1: Find all "About ... business" sections
    final sectionRegex = RegExp(
      r'(About .*? business)(.*?)(?=About .*? business|$)',
      dotAll: true,
    );
    final matches = sectionRegex.allMatches(inputs);

    // Step 2: Format each matched business block
    final buffer = StringBuffer();

    for (final match in matches) {
      final heading = match.group(1)?.trim() ?? 'Unknown Business';
      final content = match.group(2)?.trim() ?? '';

      buffer.writeln('🔹 ${_formatHeading(heading)}\n');
      buffer.writeln(_formatSectionContent(content));
      buffer.writeln('\n');
    }

    return buffer.toString().trim();
  }

  String _formatHeading(String raw) {
    final match = RegExp(
      r'About (.+?) business',
      caseSensitive: false,
    ).firstMatch(raw);
    return match != null ? 'Business Type: ${match.group(1)?.trim()}' : raw;
  }

  String _formatSectionContent(String section) {
    final lines =
        section
            .split('\n')
            .map((l) => l.trim())
            .where((l) => l.isNotEmpty)
            .toList();

    // Multiple regex patterns to handle different formats
    final colonRegex = RegExp(r'^(.*?):\s*(.+)$'); // "Title: Content"
    final dashRegex = RegExp(r'^(.*?)\s*-\s*(.+)$'); // "Title - Content"
    final questionRegex = RegExp(r'^(.*?\?)\s*(.*)$'); // "Question? Answer"

    final buffer = StringBuffer();
    int count = 1;
    String? currentTitle;
    StringBuffer? currentContent;

    void flush() {
      if (currentTitle != null && currentContent != null) {
        buffer.writeln('$count. $currentTitle');
        buffer.writeln('• ${currentContent.toString().trim()}\n');
        count++;
      }
    }

    for (final line in lines) {
      RegExpMatch? match;

      // Try different patterns in order of preference
      match = colonRegex.firstMatch(line);
      match ??= dashRegex.firstMatch(line);
      match ??= questionRegex.firstMatch(line);

      if (match != null) {
        flush();
        currentTitle = match.group(1)?.trim();
        final content = match.group(2)?.trim() ?? '';
        currentContent = StringBuffer(content);
      } else {
        // Handle lines without clear title-content structure
        if (currentContent != null) {
          // Add to existing content
          currentContent!.writeln(line);
        } else {
          // Treat the line as both title and content
          flush();
          currentTitle = line;
          currentContent = StringBuffer('');
        }
      }
    }

    flush();

    // If no structured content was found, format as simple numbered list
    if (buffer.isEmpty && lines.isNotEmpty) {
      for (int i = 0; i < lines.length; i++) {
        buffer.writeln('${i + 1}. ${lines[i]}');
        if (i < lines.length - 1) buffer.writeln();
      }
    }

    // Remove point number 1 (usually greeting) and renumber the rest
    String result = buffer.toString().trim();

    if (result.isNotEmpty) {
      // Split by double newlines to get complete point blocks
      final pointBlocks = result.split('\n\n');

      // Remove the first point block (index 0) if it exists
      if (pointBlocks.isNotEmpty) {
        pointBlocks.removeAt(0);
      }

      // Renumber the remaining points
      final renumberedBlocks = <String>[];
      int newNumber = 1;

      for (final block in pointBlocks) {
        if (block.trim().isNotEmpty) {
          // Replace the number at the beginning of each block
          final renumberedBlock = block.replaceFirst(
            RegExp(r'^\d+\.'),
            '$newNumber.',
          );
          renumberedBlocks.add(renumberedBlock);
          newNumber++;
        }
      }

      result = renumberedBlocks.join('\n\n');
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.black,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          'PitchPal Video Script',
          style: TextStyle(color: Colors.black),
        ),

        foregroundColor: Colors.white,
        backgroundColor: Colors.white,
        elevation: 2,
        actions: [
          // IconButton(
          //   icon: Icon(
          //     autoFocusDisabled ? Icons.keyboard_hide : Icons.keyboard,
          //     color: Colors.black,
          //   ),
          //   onPressed: () {
          //     setState(() {
          //       autoFocusDisabled = !autoFocusDisabled;
          //     });

          //     if (autoFocusDisabled) {
          //       _disableAutoFocus();
          //       ScaffoldMessenger.of(context).showSnackBar(
          //         const SnackBar(
          //           content: Text('Auto-focus disabled. Tap inputs to type.'),
          //           backgroundColor: Colors.green,
          //         ),
          //       );
          //     } else {
          //       _enableAutoFocus();
          //       ScaffoldMessenger.of(context).showSnackBar(
          //         const SnackBar(
          //           content: Text('Auto-focus enabled. Page will reload.'),
          //           backgroundColor: Colors.blue,
          //         ),
          //       );
          //     }
          //   },
          //   tooltip:
          //       autoFocusDisabled ? 'Enable Auto-Focus' : 'Disable Auto-Focus',
          // ),
          Container(
            decoration: BoxDecoration(
              color: Colors.blue.shade100,

              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              icon: const Icon(Icons.videocam, color: Colors.blue),
              onPressed: _copyLatestResponseAndNavigate,
              tooltip: 'Ganerate Video Script',
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            onPressed: () => _controller.reload(),
            tooltip: 'Refresh',
          ),
          // IconButton(
          //   icon: const Icon(Icons.bug_report),
          //   onPressed: () async {
          //     final debugInfo = await _controller.runJavaScriptReturningResult(
          //       '''
          //       (function() {
          //         const containers = document.querySelectorAll('li, div, article, section');
          //         let info = { containers: [], extracted: '' };

          //         containers.forEach((container, index) => {
          //           const text = (container.textContent || '').trim();
          //           if (text.length > 20) {
          //             info.containers.push({
          //               index: index,
          //               tag: container.tagName,
          //               classes: container.className,
          //               textLength: text.length,
          //               preview: text.substring(0, 100)
          //             });
          //           }
          //         });

          //         if (window.getLatestBotResponse) {
          //           info.extracted = window.getLatestBotResponse() || 'No response';
          //         }

          //         return JSON.stringify(info, null, 2);
          //       })();
          //     ''',
          //     );

          //     showDialog(
          //       context: context,
          //       builder:
          //           (context) => AlertDialog(
          //             title: const Text('Debug Info'),
          //             content: SizedBox(
          //               width: double.maxFinite,
          //               height: 400,
          //               child: SingleChildScrollView(
          //                 child: SelectableText(
          //                   debugInfo.toString(),
          //                   style: const TextStyle(
          //                     fontFamily: 'monospace',
          //                     fontSize: 12,
          //                   ),
          //                 ),
          //               ),
          //             ),
          //             actions: [
          //               TextButton(
          //                 onPressed: () => Navigator.pop(context),
          //                 child: const Text('Close'),
          //               ),
          //             ],
          //           ),
          //     );
          //   },
          //   tooltip: 'Debug',
          // ),
        ],
      ),
      body: GestureDetector(
        onTap: () {
          _controller.runJavaScript('''
            window.userInteracting = true;
            setTimeout(() => { window.userInteracting = false; }, 1000);
          ''');
        },
        child: Stack(
          children: [
            WebViewWidget(controller: _controller),
            if (isLoading)
              Container(
                color: Colors.white,
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Loading PitchPal AI...'),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
      // floatingActionButton: Container(
      //   margin: const EdgeInsets.only(bottom: 20),
      //   child: FloatingActionButton.extended(
      //     onPressed: _copyLatestResponseAndNavigate,
      //     icon: const Icon(Icons.copy),
      //     label: const Text('Copy & Next'),
      //     backgroundColor: Colors.blue[600],
      //     foregroundColor: Colors.white,
      //     elevation: 4,
      //   ),
      // ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class SolutionScreen extends StatelessWidget {
  final String aiResponse;

  const SolutionScreen({super.key, required this.aiResponse});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Solution'),
        backgroundColor: Colors.green[600],
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green[50]!, Colors.green[100]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.smart_toy, color: Colors.green[600]),
                      const SizedBox(width: 8),
                      Text(
                        'AI Generated Solution',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    aiResponse,
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: aiResponse));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Copied to clipboard!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                    icon: const Icon(Icons.copy),
                    label: const Text('Copy Again'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[100],
                      foregroundColor: Colors.grey[700],
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder:
                            (context) => AlertDialog(
                              title: const Text('Solution Processed'),
                              content: const Text(
                                'The AI solution has been processed and saved.',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('OK'),
                                ),
                              ],
                            ),
                      );
                    },
                    icon: const Icon(Icons.check_circle),
                    label: const Text('Use Solution'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[600],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Back to Chat'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),

            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, color: Colors.blue[600], size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This solution was automatically copied from PitchPal AI.',
                      style: TextStyle(fontSize: 14, color: Colors.blue[700]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
