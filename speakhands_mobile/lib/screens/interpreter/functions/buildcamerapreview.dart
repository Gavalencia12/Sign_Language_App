import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:speakhands_mobile/theme/app_colors.dart';

class CameraPreviewWidget extends StatelessWidget {
  final String? imagePath;
  final VideoPlayerController? vp;
  final Future<void>? vpInit;
  final String? captionText;

  const CameraPreviewWidget({
    Key? key,
    this.imagePath,
    this.vp,
    this.vpInit,
    this.captionText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // IMAGE (alphabet or term image) all box
          if (imagePath != null)
            Positioned.fill(
              child: Image.asset(imagePath!, fit: BoxFit.cover),
            ),

          // VIDEO all box
          if (vp != null && vpInit != null)
            FutureBuilder(
              future: vpInit,
              builder: (_, snap) {
                if (snap.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                return Positioned.fill(
                  child: FittedBox(
                    fit: BoxFit.cover,
                    clipBehavior: Clip.hardEdge,
                    child: SizedBox(
                      width: vp!.value.size.width,
                      height: vp!.value.size.height,
                      child: VideoPlayer(vp!),
                    ),
                  ),
                );
              },
            ),

          // CAPTION (bottom-centered stripe)
          if ((captionText ?? '').isNotEmpty)
            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary(context),
                    borderRadius: BorderRadius.circular(8),
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
