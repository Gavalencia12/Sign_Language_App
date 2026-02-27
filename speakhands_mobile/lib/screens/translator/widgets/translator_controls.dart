import 'package:flutter/material.dart';
import 'package:speakhands_mobile/theme/app_colors.dart';

// A reusable control panel widget that provides quick-access
// buttons for refreshing and pausing the translation process.

// Typically used in the **translator** screen of the app to allow
// users to control the sign language detection process — for example,
// restarting the camera or pausing gesture recognition.

// ### Features:
// - Two circular buttons:
// - *Refresh* – restarts translation or camera feed.
// - *Pause* – temporarily stops recognition.
class TranslatorControls extends StatelessWidget {
  // Callback triggered when the user taps the "Refresh" button.
  final VoidCallback onRefresh;

  // Callback triggered when the user taps the "Pause" button.
  final VoidCallback onPause;

  const TranslatorControls({
    super.key,
    required this.onRefresh,
    required this.onPause,
  });

  // Builds a circular action button with the given [icon], [color],
  // and [onPressed] behavior.
  // Used internally to construct both "Refresh" and "Pause" controls.
  Widget _circleButton(
    BuildContext context,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return Material(
      color: color,
      shape: const CircleBorder(),
      child: IconButton(
        icon: Icon(icon, color: AppColors.onPrimary(context)),
        onPressed: onPressed,
        tooltip: icon == Icons.refresh ? "Refrescar" : "Pausar",
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.text(context).withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: AppColors.primary(context).withOpacity(0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Refresh button
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _circleButton(
                context,
                Icons.refresh,
                AppColors.primary(context),
                onRefresh,
              ),
              const SizedBox(height: 4),
              Text(
                "Refrescar",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.text(context),
                ),
              ),
            ],
          ),

          // Pause button
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _circleButton(
                context,
                Icons.pause,
                AppColors.secondary(context),
                onPause,
              ),
              const SizedBox(height: 4),
              Text(
                "Pausar",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.text(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
