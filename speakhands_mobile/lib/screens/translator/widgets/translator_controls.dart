import 'package:flutter/material.dart';

class TranslatorControls extends StatelessWidget {
  final VoidCallback onRefresh;
  final VoidCallback onPause;

  const TranslatorControls({
    super.key,
    required this.onRefresh,
    required this.onPause,
  });

  Widget _circleButton(IconData icon, Color color, VoidCallback onPressed) {
    return Material(
      color: color,
      shape: const CircleBorder(),
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        onPressed: onPressed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      decoration: BoxDecoration(
        color:
            Theme.of(context).brightness == Brightness.dark
                ? Colors.white.withOpacity(0.05)
                : Colors.black.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _circleButton(Icons.refresh, Colors.teal, onRefresh),
              const SizedBox(height: 4),
              const Text(
                "Refrescar",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _circleButton(Icons.pause, Colors.blue, onPause),
              const SizedBox(height: 4),
              const Text(
                "Pausar",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
