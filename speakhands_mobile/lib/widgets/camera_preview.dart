import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:speakhands_mobile/theme/app_colors.dart';

class CameraPreviewWidget extends StatelessWidget {
  final String? imagePath;
  final VideoPlayerController? videoPlayerController;
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
        color: isDark
            ? AppColors.secondaryDark.withOpacity(0.5)
            : AppColors.secondaryLight.withOpacity(0.5),
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
          if (videoPlayerController != null)
            FutureBuilder(
              future: videoPlayerController!.initialize(),
              builder: (_, snap) {
                if (snap.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                return Positioned.fill(
                  child: FittedBox(
                    fit: BoxFit.cover, // <- clave para cubrir
                    clipBehavior: Clip.hardEdge, // <- asegura el recorte
                    child: SizedBox(
                      // Usa el tamaño nativo del video para que FittedBox escale bien
                      width: videoPlayerController!.value.size.width,
                      height: videoPlayerController!.value.size.height,
                      child: VideoPlayer(videoPlayerController!),
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6
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
