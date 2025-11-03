import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:speakhands_mobile/theme/app_colors.dart';

// A contact section widget displayed at the bottom of the Help screen.
// It provides two interactive options for users to reach support:
// - Sending an email to the technical support team.
// - Making a direct phone call.
// Both actions use the `url_launcher` package to open the default
// email or phone app on the user’s device.
class HelpContactSection extends StatelessWidget {
  const HelpContactSection({super.key});

  // Opens the user's default email application with a prefilled recipient
  // and subject line for technical support inquiries.
  Future<void> _launchEmail() async {
    final uri = Uri.parse(
      'mailto:languageappsign@gmail.com?subject=Soporte%20Técnico',
    );
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  // Opens the phone dialer with the app's support number prefilled.
  Future<void> _launchPhone() async {
    final uri = Uri.parse('tel:+523142184467');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    final Color textColor = AppColors.text(context);
    final Color linkColor = AppColors.primary(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Section title
        Text(
          '¿Necesitas más ayuda? ¡Contáctanos!',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),

        // Email (tap to open mail client)
        GestureDetector(
          onTap: _launchEmail,
          child: Text(
            'languageappsign@gmail.com',
            style: TextStyle(
              color: linkColor,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),

        const SizedBox(height: 8),

        // Phone number (tap to open dialer)
        GestureDetector(
          onTap: _launchPhone,
          child: Text(
            '+52 (314) 218-4467',
            style: TextStyle(
              color: linkColor,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
