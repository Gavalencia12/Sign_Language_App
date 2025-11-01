// widgets/camera_preview.dart
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class CameraPreviewWidget extends StatelessWidget {
  final String? imagePath;
  final VideoPlayerController? videoPlayerController;
  final String? captionText;

  const CameraPreviewWidget({
    Key? key,
    this.imagePath,
    this.videoPlayerController,
    this.captionText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[300],
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
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    captionText!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
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
