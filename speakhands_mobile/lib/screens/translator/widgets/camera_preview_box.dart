import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:speakhands_mobile/l10n/app_localizations.dart';
import 'package:speakhands_mobile/theme/app_colors.dart';

class CameraPreviewBox extends StatelessWidget {
  final bool isCameraActive;
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
        /* color: Colors.grey[300], */
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
