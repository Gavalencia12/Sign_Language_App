import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:speakhands_mobile/theme/app_colors.dart';

class HelpContactSection extends StatelessWidget {
  const HelpContactSection({super.key});

  Future<void> _launchEmail() async {
    final uri = Uri.parse('mailto:languageappsign@gmail.com?subject=Soporte%20Técnico');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

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

        // 🔹 Título
        Text(
          '¿Necesitas más ayuda? ¡Contáctanos!',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: textColor,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),

        // 🔹 Email
        GestureDetector(
          onTap: _launchEmail,
          child: Text('languageappsign@gmail.com',
              style: TextStyle(
                color: linkColor,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
          ),
        ),

        const SizedBox(height: 8),

        // 🔹 Teléfono
        GestureDetector(
          onTap: _launchPhone,
          child: Text('+52 (314) 218-4467',
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
