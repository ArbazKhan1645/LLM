import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:llm_video_shopify/app/modules/video_script/controllers/video_script_controller.dart';
import 'package:llm_video_shopify/app/routes/app_pages.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';

// Import the existing controller from the previous implementation
// import '../controllers/app_controller.dart';

class SendVideoScreen extends StatefulWidget {
  const SendVideoScreen({super.key});

  @override
  _SendVideoScreenState createState() => _SendVideoScreenState();
}

class _SendVideoScreenState extends State<SendVideoScreen> {
  final VideoScriptController controller = Get.find<VideoScriptController>();
  bool sendToCartersWorkstation = false;
  String selectedRecipient = '';
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Ensure video player is initialized for thumbnail
    if (controller.recordedVideoPath.value.isNotEmpty &&
        !controller.isVideoPlayerInitialized.value) {
      controller.initializeVideoPlayer();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Send Video',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Video Preview Section
              Obx(() => _buildVideoPreview()),

              // Select Recipient Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'SELECT RECIPIENT',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.black54,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Search Field
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: TextField(
                        onTap: () {
                          Get.toNamed(Routes.CHAT_ROOM);
                        },
                        readOnly: true,

                        controller: searchController,
                        onChanged: (value) {
                          setState(() {
                            selectedRecipient = value;
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Search name or contact',
                          hintStyle: TextStyle(color: Colors.grey[500]),
                          prefixIcon: Icon(
                            Icons.search,
                            color: Colors.grey[500],
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(16),
                        ),
                      ),
                    ),

                    // const SizedBox(height: 20),

                    // // Preview Contact
                    // const Text(
                    //   'PREVIEW CONTACT',
                    //   style: TextStyle(
                    //     fontSize: 12,
                    //     fontWeight: FontWeight.w600,
                    //     color: Colors.black54,
                    //     letterSpacing: 1.2,
                    //   ),
                    // ),

                    // // Show selected recipient if any
                    // if (selectedRecipient.isNotEmpty) ...[
                    //   const SizedBox(height: 12),
                    //   Container(
                    //     padding: const EdgeInsets.all(12),
                    //     decoration: BoxDecoration(
                    //       color: Colors.white,
                    //       borderRadius: BorderRadius.circular(8),
                    //       border: Border.all(color: Colors.grey[300]!),
                    //     ),
                    //     child: Row(
                    //       children: [
                    //         CircleAvatar(
                    //           backgroundColor: const Color(0xFF4A90E2),
                    //           radius: 20,
                    //           child: Text(
                    //             selectedRecipient[0].toUpperCase(),
                    //             style: const TextStyle(
                    //               color: Colors.white,
                    //               fontWeight: FontWeight.w600,
                    //             ),
                    //           ),
                    //         ),
                    //         const SizedBox(width: 12),
                    //         Text(
                    //           selectedRecipient,
                    //           style: const TextStyle(
                    //             fontSize: 16,
                    //             fontWeight: FontWeight.w500,
                    //           ),
                    //         ),
                    //       ],
                    //     ),
                    //   ),
                    // ],

                    // const SizedBox(height: 20),

                    // // Send to Carter's Workstation Toggle
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //   children: [
                    //     const Expanded(
                    //       child: Text(
                    //         'SEND TO CARTER\'S WORKSTATION',
                    //         style: TextStyle(
                    //           fontSize: 12,
                    //           fontWeight: FontWeight.w600,
                    //           color: Colors.black54,
                    //           letterSpacing: 1.2,
                    //         ),
                    //       ),
                    //     ),
                    //     Switch(
                    //       value: sendToCartersWorkstation,
                    //       onChanged: (value) {
                    //         setState(() {
                    //           sendToCartersWorkstation = value;
                    //         });
                    //       },
                    //       activeColor: const Color(0xFF4A90E2),
                    //     ),
                    //   ],
                    // ),

                    // const SizedBox(height: 40),

                    // // Send Video Button
                    // Obx(
                    //   () => SizedBox(
                    //     width: double.infinity,
                    //     height: 50,
                    //     child: ElevatedButton(
                    //       onPressed:
                    //           controller.recordedVideoPath.value.isEmpty
                    //               ? null
                    //               : () => _showConfirmationDialog(context),
                    //       style: ElevatedButton.styleFrom(
                    //         backgroundColor:
                    //             controller.recordedVideoPath.value.isEmpty
                    //                 ? Colors.grey[400]
                    //                 : const Color(0xFF4A90E2),
                    //         shape: RoundedRectangleBorder(
                    //           borderRadius: BorderRadius.circular(25),
                    //         ),
                    //         elevation: 0,
                    //       ),
                    //       child: const Text(
                    //         'SEND VIDEO',
                    //         style: TextStyle(
                    //           color: Colors.white,
                    //           fontSize: 14,
                    //           fontWeight: FontWeight.w700,
                    //           letterSpacing: 1.2,
                    //         ),
                    //       ),
                    //     ),
                    //   ),
                    // ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVideoPreview() {
    if (controller.recordedVideoPath.value.isEmpty) {
      return Container(
        width: double.infinity,
        height: 300,
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey[300],
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.videocam_off, color: Colors.grey, size: 48),
              SizedBox(height: 16),
              Text(
                'No video recorded',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      height: 300,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.black,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            // Video thumbnail/preview
            if (controller.isVideoPlayerInitialized.value)
              Positioned.fill(
                child: AspectRatio(
                  aspectRatio:
                      controller.videoPlayerController!.value.aspectRatio,
                  child: VideoPlayer(controller.videoPlayerController!),
                ),
              )
            else
              Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.black,
                child: const Center(
                  child: CircularProgressIndicator(color: Color(0xFF4A90E2)),
                ),
              ),

            // Overlay gradient
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.3)],
                ),
              ),
            ),

            // Duration badge
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _formatDuration(controller.recordingDuration.value),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            // Play and Camera buttons
            Positioned(
              bottom: 12,
              left: 12,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => _toggleVideoPlayback(),
                    child: _buildCircularIconButton(
                      controller.isVideoPlayerInitialized.value &&
                              controller.videoPlayerController!.value.isPlaying
                          ? Icons.pause
                          : Icons.play_arrow,
                      Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => Get.back(), // Go back to recording
                    child: _buildCircularIconButton(
                      Icons.camera_alt,
                      Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            // Video file info
            Positioned(
              bottom: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${(File(controller.recordedVideoPath.value).lengthSync() / (1024 * 1024)).toStringAsFixed(1)} MB',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircularIconButton(IconData icon, Color iconColor) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: iconColor, size: 20),
    );
  }

  void _toggleVideoPlayback() {
    if (controller.isVideoPlayerInitialized.value) {
      if (controller.videoPlayerController!.value.isPlaying) {
        controller.videoPlayerController!.pause();
      } else {
        controller.videoPlayerController!.play();
      }
    }
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void _showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return ConfirmationDialog(
          onConfirm: () {
            Navigator.of(context).pop();
            _simulateSendVideo();
          },
          onCancel: () {
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  void _simulateSendVideo() async {
    // Show loading state
    Get.dialog(
      const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: Color(0xFF4A90E2)),
                SizedBox(height: 16),
                Text('Sending video...'),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );

    Get.back(); // Close loading dialog
    _showSuccessDialog(context);
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return SuccessDialog(
          onSendAnother: () {
            Navigator.of(context).pop();
            // Reset form
            setState(() {
              selectedRecipient = '';
              sendToCartersWorkstation = false;
              searchController.clear();
            });
          },
          onGoToHistory: () {
            Navigator.of(context).pop();
            // Navigate to history screen
            Get.toNamed(Routes.VIDEO_HISTORY);
          },
        );
      },
    );
  }
}

class ConfirmationDialog extends StatelessWidget {
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const ConfirmationDialog({
    super.key,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 300,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'ARE YOU SURE YOU WANT TO SEND THIS VIDEO?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
                letterSpacing: 0.5,
              ),
            ),

            const SizedBox(height: 24),

            // Yes Button
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                onPressed: onConfirm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A90E2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'YES',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // No Button
            SizedBox(
              width: double.infinity,
              height: 44,
              child: OutlinedButton(
                onPressed: onCancel,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.grey[300]!),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22),
                  ),
                ),
                child: const Text(
                  'NO',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SuccessDialog extends StatelessWidget {
  final VoidCallback onSendAnother;
  final VoidCallback onGoToHistory;

  const SuccessDialog({
    super.key,
    required this.onSendAnother,
    required this.onGoToHistory,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 300,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Success Icon
            Container(
              width: 60,
              height: 60,
              decoration: const BoxDecoration(
                color: Color(0xFF4CAF50),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 30),
            ),

            const SizedBox(height: 20),

            const Text(
              'YOUR VIDEO HAS BEEN SENT SUCCESSFULLY',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
                letterSpacing: 0.5,
              ),
            ),

            const SizedBox(height: 24),

            // Send Another Button
            SizedBox(
              width: double.infinity,
              height: 44,
              child: OutlinedButton(
                onPressed: onSendAnother,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.grey[300]!),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22),
                  ),
                ),
                child: const Text(
                  'SEND ANOTHER',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Go to History Button
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                onPressed: onGoToHistory,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A90E2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'GO TO HISTORY',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
