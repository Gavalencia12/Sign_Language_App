import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

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
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,        // <- evita expandirse
  crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          '¿Necesitas más ayuda? ¡Contáctanos!',
          textAlign: TextAlign.center,
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _launchEmail,
          child: const Text('languageappsign@gmail.com',
              style: TextStyle(color: Colors.blue, fontSize: 16)),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _launchPhone,
          child: const Text('+52 (314) 218-4467',
              style: TextStyle(color: Colors.blue, fontSize: 16)),
        ),
      ],
    );
  }
}
