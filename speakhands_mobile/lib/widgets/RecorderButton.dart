import 'package:flutter/material.dart';
import 'package:speakhands_mobile/theme/app_colors.dart';

// A circular, animated button that toggles between **recording** and **idle** states.
// Commonly used for starting and stopping audio or gesture recordings.
// Provides visual feedback through:
// - Smooth color transitions,
// - Dynamic shadow effects,
// - Adaptive theme-aware styling.

// Features:
// - Changes color and icon when recording.
// - Adapts shadows for dark/light themes.
class RecorderButton extends StatelessWidget {
  // Indicates whether the button is currently recording.
  final bool isRecording;

  // Action triggered when the button is pressed.
  final VoidCallback onPressed;

  RecorderButton({
    super.key,
    required this.isRecording,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    // === Dynamic color configuration ===
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color activeColor = AppColors.primary(context);
    final Color stopColor = Colors.redAccent;
    final Color iconColor = AppColors.onPrimary(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: isRecording ? stopColor : activeColor,
        shape: BoxShape.circle,
        boxShadow: [
          if (isRecording)
            // Glowing shadow when recording
            BoxShadow(
              color: stopColor.withOpacity(0.6),
              blurRadius: 20,
              spreadRadius: 4,
            )
          else
            // Softer shadow when idle
            BoxShadow(
              color:
                  isDark
                      ? Colors.black.withOpacity(0.5)
                      : Colors.black.withOpacity(0.15),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
        ],
      ),

      // Interactive button area
      child: IconButton(
        iconSize: 36,
        icon: Icon(
          isRecording ? Icons.stop_rounded : Icons.mic_rounded,
          color: iconColor,
        ),
        onPressed: onPressed,
        tooltip: isRecording ? 'Detener grabación' : 'Iniciar grabación',
      ),
    );
  }
}
