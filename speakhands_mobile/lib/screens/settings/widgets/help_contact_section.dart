import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:speakhands_mobile/theme/app_colors.dart';
import 'package:speakhands_mobile/l10n/app_localizations.dart';

/// A contact section displayed at the bottom of the Help screen.
/// 
/// Provides quick options for users to reach technical support:
/// - Tap the email to open the default mail app.
/// - Tap the phone number to open the dialer.
/// 
/// Uses `url_launcher` for launching intents and shows a SnackBar if
/// no compatible app is found.
class HelpContactSection extends StatelessWidget {
  const HelpContactSection({super.key});

  // Opens the default email app with recipient and subject prefilled.
  Future<void> _launchEmail(BuildContext context) async {
    final Uri uri = Uri(
      scheme: 'mailto',
      path: 'languageappsign@gmail.com',
      queryParameters: {'subject': 'Soporte Técnico'},
    );

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.email_app_not_found,
          ),
        ),
      );
    }
  }

  // Opens the phone dialer with number prefilled.
  Future<void> _launchPhone(BuildContext context) async {
    final Uri uri = Uri(scheme: 'tel', path: '+523142184467');

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.phone_call_failed,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final textColor = AppColors.text(context);
    final linkColor = AppColors.primary(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Title (translated)
        Text(
          loc.need_more_help,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: textColor,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),

        // Email (clickable)
        GestureDetector(
          onTap: () => _launchEmail(context),
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

        // Phone number (clickable)
        GestureDetector(
          onTap: () => _launchPhone(context),
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
