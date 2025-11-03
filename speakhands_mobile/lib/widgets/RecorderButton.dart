import 'package:flutter/material.dart';
import 'package:speakhands_mobile/theme/app_colors.dart';

class RecorderButton extends StatelessWidget {
  final bool isRecording;
  final VoidCallback onPressed;

  RecorderButton({super.key, required this.isRecording, required this.onPressed});

  @override
  Widget build(BuildContext context) {
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
            BoxShadow(
              color: stopColor.withOpacity(0.6),
              blurRadius: 20,
              spreadRadius: 4,
            )
          else
            BoxShadow(
              color: isDark
                  ? Colors.black.withOpacity(0.5)
                  : Colors.black.withOpacity(0.15),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
        ],
      ),
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
