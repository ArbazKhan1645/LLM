import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:get/get.dart';
import '../controllers/chat_controller.dart';

class ChatView extends GetView<ChatController> {
  const ChatView({super.key});

  @override
  Widget build(BuildContext context) {
    return const ChatScreen();
  }
}

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // Messages List with optimized rebuilds
          Expanded(
            child: Stack(
              children: [
                Obx(() => _buildMessagesList()),
                Obx(() => _buildScrollToBottomButton()),
              ],
            ),
          ),
          // Typing Indicator
          Obx(() => _buildTypingIndicator()),
          // Message Input
          _buildMessageInput(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new,
          color: Colors.black87,
          size: 20,
        ),
        onPressed: () => Get.back(),
      ),
      centerTitle: true,
      title: const Text(
        'CHAT',
        style: TextStyle(
          color: Colors.black87,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.0,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.more_vert, color: Colors.black87),
          onPressed: _showChatOptions,
        ),
      ],
    );
  }

  Widget _buildMessagesList() {
    final controller = Get.find<ChatController>();
    return ListView.builder(
      controller: controller.scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      itemCount: controller.messages.length,
      itemBuilder: (context, index) {
        final message = controller.messages[index];
        final isLastMessage = index == controller.messages.length - 1;

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: MessageBubble(
            message: message,
            isTyping: isLastMessage,
            scrollController: controller.scrollController,
          ),
        );
      },
    );
  }

  Widget _buildScrollToBottomButton() {
    final controller = Get.find<ChatController>();
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      bottom: controller.showScrollToBottom.value ? 16 : -60,
      right: 16,
      child: Material(
        borderRadius: BorderRadius.circular(22),
        elevation: 4,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: controller.scrollToBottom,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF4A90E2),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Icon(
              Icons.keyboard_arrow_down,
              color: Colors.white,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    final controller = Get.find<ChatController>();
    if (!controller.isAssistantTyping.value) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFE3F2FD),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'AI is thinking',
                  style: TextStyle(color: Colors.black87, fontSize: 14),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 20,
                  height: 8,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(
                      3,
                      (index) => _buildTypingDot(index * 200),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingDot(int delay) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 600 + delay),
      curve: Curves.easeInOut,
      width: 4,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        shape: BoxShape.circle,
      ),
      margin: const EdgeInsets.symmetric(horizontal: 1),
      transform: Matrix4.identity()..scale(1.0 + (delay % 600 / 600) * 0.5),
    );
  }

  Widget _buildMessageInput() {
    final controller = Get.find<ChatController>();
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Attachment button
            _buildIconButton(icon: Icons.attach_file, onPressed: () {}),
            const SizedBox(width: 8),
            // Message input field
            Expanded(
              child: Container(
                constraints: const BoxConstraints(maxHeight: 120),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: controller.messageController,
                  minLines: 1,
                  maxLines: 5,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    hintText: 'Type a message...',
                    hintStyle: TextStyle(color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  style: const TextStyle(fontSize: 16),
                  onChanged: controller.onMessageChanged,
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Send button
            Obx(() => _buildSendButton(controller)),
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Material(
      borderRadius: BorderRadius.circular(24),
      color: Colors.black87,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onPressed,
        child: Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }

  Widget _buildSendButton(ChatController controller) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child:
          controller.isSending.value
              ? const SizedBox(
                width: 44,
                height: 44,
                child: Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFF4A90E2),
                    ),
                  ),
                ),
              )
              : _buildIconButton(
                icon: Icons.send,
                onPressed: controller.sendMessage,
              ),
    );
  }

  void _showChatOptions() {
    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              _buildOptionItem(
                'Clear Chat',
                Icons.delete_outline,
                Colors.red.shade400,
                () {
                  Get.find<ChatController>().messages.clear();
                  Get.back();
                },
              ),
              _buildOptionItem(
                'Export Chat',
                Icons.download,
                Colors.blue.shade400,
                () {
                  Get.back();
                  Get.snackbar('Export', 'Chat exported successfully');
                },
              ),
              _buildOptionItem(
                'Settings',
                Icons.settings,
                Colors.grey.shade600,
                () => Get.back(),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionItem(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(title),
      onTap: onTap,
    );
  }
}

class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isTyping;
  final ScrollController? scrollController;

  const MessageBubble({
    super.key,
    required this.message,
    this.isTyping = false,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return message.isUser ? _buildUserMessage() : _buildAssistantMessage();
  }

  Widget _buildUserMessage() {
    return Align(
      alignment: Alignment.centerRight,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(Get.context!).size.width * 0.8,
        ),
        child: Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.only(left: 48),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(4),
            ),
          ),
          child: Text(message.text, style: const TextStyle(fontSize: 15)),
        ),
      ),
    );
  }

  Widget _buildAssistantMessage() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(
            radius: 16,
            backgroundColor: Color(0xFFE3F2FD),
            child: Icon(
              Icons.smart_toy_outlined,
              color: Color(0xFF1976D2),
              size: 16,
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(right: 48),
              decoration: const BoxDecoration(
                color: Color(0xFFE3F2FD),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child:
                  isTyping
                      ? TypeWriterText(
                        text: message.text,
                        duration: const Duration(milliseconds: 20),
                        isAnimating: (animating) {},
                        textStyle: const TextStyle(fontSize: 15),
                        scrollController: scrollController,
                      )
                      : MarkdownBody(
                        data: message.text,
                        styleSheet: MarkdownStyleSheet(
                          p: const TextStyle(fontSize: 15),
                          h1: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                          ),
                          h2: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                          ),
                          h3: const TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.w900,
                          ),
                          h4: const TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w900,
                          ),
                          h5: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                          ),
                          h6: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                          tableBody: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                          ),
                          listBullet: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
            ),
          ),
        ],
      ),
    );
  }
}

class TypeWriterText extends StatefulWidget {
  final String text;
  final Duration duration;
  final TextStyle textStyle;
  final Function(bool) isAnimating;
  final ScrollController? scrollController;

  const TypeWriterText({
    super.key,
    required this.text,
    required this.duration,
    required this.isAnimating,
    required this.textStyle,
    this.scrollController,
  });

  @override
  State<TypeWriterText> createState() => _TypeWriterTextState();
}

class _TypeWriterTextState extends State<TypeWriterText>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late AnimationController _controller;
  late Animation<int> _characterCount;

  @override
  bool get wantKeepAlive => true; // Retain the widget's state

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: widget.duration * widget.text.length,
      vsync: this,
    )..forward();

    _characterCount = StepTween(
      begin: 0,
      end: widget.text.length,
    ).animate(_controller);

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.isAnimating(true);
      }
    });

    // Add listener to scroll to bottom when text changes
    _controller.addListener(_scrollToBottom);
  }

  void _scrollToBottom() {
    if (widget.scrollController != null &&
        widget.scrollController!.hasClients &&
        _controller.isAnimating) {
      Future.microtask(() {
        widget.isAnimating(false);
        widget.scrollController!.animateTo(
          widget.scrollController!.position.maxScrollExtent,
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOut,
        );
      });
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_scrollToBottom);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    return AnimatedBuilder(
      animation: _characterCount,
      builder: (context, child) {
        final currentText = widget.text.substring(0, _characterCount.value);
        return DefaultTextStyle(
          style: widget.textStyle,
          child: MarkdownBody(
            data: currentText,
            styleSheet: MarkdownStyleSheet(
              p: widget.textStyle,
              h1: widget.textStyle.copyWith(
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
              h2: widget.textStyle.copyWith(
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
              h3: widget.textStyle.copyWith(
                fontSize: 21,
                fontWeight: FontWeight.w900,
              ),
              h4: widget.textStyle.copyWith(
                fontSize: 19,
                fontWeight: FontWeight.w900,
              ),
              h5: widget.textStyle.copyWith(
                fontSize: 17,
                fontWeight: FontWeight.w900,
              ),
              h6: widget.textStyle.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
              tableBody: widget.textStyle.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w900,
              ),
              listBullet: widget.textStyle.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        );
      },
    );
  }
}
