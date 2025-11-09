import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:speakhands_mobile/theme/app_colors.dart';

class CameraPreviewWidget extends StatelessWidget {
  final String? imagePath;
  final File? imageFile;
  final String? imageUrl;
  final Map<String, String>? authHeaders;
  final VideoPlayerController? vp;
  final Future<void>? vpInit;
  final String? captionText;
  final String? mediaError; 

  const CameraPreviewWidget({
    Key? key,
    this.imagePath,
    this.imageFile,
    this.imageUrl,
    this.authHeaders,
    this.vp,
    this.vpInit,
    this.captionText,
    this.mediaError, 
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
        alignment: Alignment.center, 
        children: [
          if (vp != null && vpInit != null)
            FutureBuilder(
              future: vpInit,
              builder: (_, snap) {
                if (snap.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snap.hasError) {
                  return Container(color: Colors.black.withOpacity(0.1));
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
            )
          else if (imageFile != null)
            Positioned.fill(
              child: Image.file(imageFile!, fit: BoxFit.cover),
            )
          else if (imageUrl != null)
            Positioned.fill(
              child: Image.network(
                imageUrl!,
                headers: authHeaders,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return const Center(child: CircularProgressIndicator());
                },
                errorBuilder: (context, error, stack) {
                  return Container(color: Colors.black.withOpacity(0.1));
                },
              ),
            )
          else if (imagePath != null)
            Positioned.fill(
              child: Image.asset(imagePath!, fit: BoxFit.cover),
            )
          else if (mediaError == null)
            Center(
             
            ),
          
          if (mediaError != null)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.6),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      mediaError!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white, 
                        fontWeight: FontWeight.bold,
                        fontSize: 16
                      ),
                    ),
                  ),
                ),
              ),
            ),


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
