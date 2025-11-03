import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:speakhands_mobile/theme/app_colors.dart';

// A responsive widget designed to display either:
// - an **image** (e.g., for sign alphabet examples),
// - a **video** (for demonstrating gestures), or
// - an optional **caption** overlay.

// This widget adapts its background and text color dynamically
// based on the current theme (light or dark).

// Features:
// - Displays full-width image or video with rounded corners.
// - Adds a subtle background tint matching the theme.
// - Handles asynchronous video initialization safely.
// - Includes a bottom caption bar for contextual text.
class CameraPreviewWidget extends StatelessWidget {
  // Path to the image asset.
  final String? imagePath;

  // Controller for playing a video.
  final VideoPlayerController? videoPlayerController;

  // Text displayed in a caption overlay at the bottom.
  final String? captionText;

  const CameraPreviewWidget({
    super.key,
    this.imagePath,
    this.videoPlayerController,
    this.captionText,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color:
            isDark
                ? AppColors.secondaryDark.withOpacity(0.5)
                : AppColors.secondaryLight.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // === IMAGE PREVIEW ===
          if (imagePath != null)
            Positioned.fill(child: Image.asset(imagePath!, fit: BoxFit.cover)),

          // === VIDEO PREVIEW ===
          if (videoPlayerController != null)
            FutureBuilder(
              future: videoPlayerController!.initialize(),
              builder: (_, snap) {
                if (snap.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                return Positioned.fill(
                  child: FittedBox(
                    fit: BoxFit.cover, // Ensures video fills the area
                    clipBehavior: Clip.hardEdge, // Prevents overflow
                    child: SizedBox(
                      width: videoPlayerController!.value.size.width,
                      height: videoPlayerController!.value.size.height,
                      child: VideoPlayer(videoPlayerController!),
                    ),
                  ),
                );
              },
            ),

          // === CAPTION OVERLAY ===
          if ((captionText ?? '').isNotEmpty)
            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    captionText!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.onPrimary(context),
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
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
