import 'package:flutter/material.dart';
import 'package:speakhands_mobile/l10n/app_localizations.dart';

class WelcomeWidget extends StatelessWidget {
  final String userName;
  final String? userPhotoUrl;
  final bool isDarkMode;

  const WelcomeWidget({
    super.key,
    required this.userName,
    this.userPhotoUrl,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final subTextColor = isDarkMode ? Colors.white70 : Colors.grey.shade700;
    final textColor = isDarkMode ? Colors.white : const Color(0xFF2F3A4A);
    final backgroundColor = isDarkMode ? Colors.grey[850] : Colors.white;
    final bellColor = Colors.redAccent;

    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: Colors.white,
            child: (userPhotoUrl != null && userPhotoUrl!.isNotEmpty)
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: Image.network(
                      userPhotoUrl!,
                      width: 44,
                      height: 44,
                      fit: BoxFit.cover,
                    ),
                  )
                : const Icon(Icons.person, size: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppLocalizations.of(context)!.welcome_back, style: TextStyle(color: subTextColor, fontSize: 14)),
                Text(userName, style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
          ),
          Stack(
            children: [
              Icon(Icons.notifications_none, size: 28, color: bellColor),
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: bellColor,
                    shape: BoxShape.circle,
                  ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
