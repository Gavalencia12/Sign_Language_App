import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:speakhands_mobile/l10n/app_localizations.dart';
import 'package:speakhands_mobile/theme/app_colors.dart';

// A widget that displays a live camera preview or a fallback message
// when the camera is not active or initialized.

// This widget is primarily used in the **interpreter** or **translator**
// screens to render real-time camera input for gesture or hand sign
// detection.

// Responsibilities:
// - Display an active camera feed using `CameraPreview`.
// - Show a localized placeholder message when the camera is inactive.
// - Apply consistent UI styling with app colors and rounded borders.
class CameraPreviewBox extends StatelessWidget {
  // Indicates whether the camera is currently active.
  final bool isCameraActive;

  // The [CameraController] instance used to render the preview.
  final CameraController? controller;

  const CameraPreviewBox({
    super.key,
    required this.isCameraActive,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.text(context).withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Center(
        child:
            isCameraActive &&
                    controller != null &&
                    controller!.value.isInitialized
                ? FittedBox(
                  key: const ValueKey('camera_active'),
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: controller!.value.previewSize!.height,
                    height: controller!.value.previewSize!.width,
                    child: CameraPreview(controller!),
                  ),
                )
                : Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    loc.camera_not_active,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.text(context).withOpacity(0.7),
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
      ),
    );
  }
}
