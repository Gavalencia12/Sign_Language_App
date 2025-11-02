// widget con la cámara + overlay

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:speakhands_mobile/l10n/app_localizations.dart';

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
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(8),
      ),
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
                : Text(
                  loc.camera_not_active,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
                  textAlign: TextAlign.center,
                ),
      ),
    );
  }
}
