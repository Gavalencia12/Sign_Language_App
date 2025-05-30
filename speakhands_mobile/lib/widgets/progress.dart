import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speakhands_mobile/providers/theme_provider.dart';
import 'package:speakhands_mobile/models/progress_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:speakhands_mobile/screens/main_nav.dart';
import 'package:speakhands_mobile/l10n/app_localizations.dart';

class ProgresoWidget extends StatelessWidget {
  final List<Progreso> progresos;
  final Future<void> Function(String uid, String idSeccion) iniciarProgreso;
  final String idSeccionActual;

  const ProgresoWidget({
    super.key,
    required this.progresos,
    required this.iniciarProgreso,
    required this.idSeccionActual, // <-- inicializar
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final cardColor = themeProvider.isDarkMode ? const Color.fromARGB(255, 76, 227, 197) : const Color(0xFFE34C94);

    final progresoSeccionActual = progresos.firstWhere(
      (p) => p.idSeccion == idSeccionActual,
      orElse: () => Progreso(
        idProgreso: '',
        idUsuario: '',
        idSeccion: '',
        nivelAprendizaje: '',
        fecha: '',
        puntuacion: 0,
      ),
    );

    final bool tieneProgresoSeccionActual = progresoSeccionActual.idProgreso.isNotEmpty;

    if (progresos.isEmpty) {
      return InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          final user = FirebaseAuth.instance.currentUser;
          if (user != null && !tieneProgresoSeccionActual) {
            iniciarProgreso(user.uid, 'seccion_1');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(AppLocalizations.of(context)!.lets_start_learning,)),
            );
          }
          MainNavigation.globalKey.currentState?.changeTab(2);
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              flex: 3,
              child: Card(
                color: cardColor,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            AppLocalizations.of(context)!.not_progress_yet,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        AppLocalizations.of(context)!.lets_start_learning,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Card(
                color: cardColor,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                ),
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: RichText(
                      text: TextSpan(
                        text: '0',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 28,
                        ),
                        children: const [
                          TextSpan(
                            text: '%',
                            style: TextStyle(
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
    else{
        return InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          final user = FirebaseAuth.instance.currentUser;
          if (user != null && !tieneProgresoSeccionActual) {
            iniciarProgreso(user.uid, 'seccion_1');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Started learning section 1!')),
            );
          }
          MainNavigation.globalKey.currentState?.changeTab(2);
        },

        child:Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              flex: 3,
              child: Card(
                color: cardColor,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            AppLocalizations.of(context)!.section1,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            "${AppLocalizations.of(context)!.lesson} 1",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        AppLocalizations.of(context)!.describe_alphabet,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Card(
                color: cardColor,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                ),
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: RichText(
                      text: TextSpan(
                        text: '0',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 28,
                        ),
                        children: const [
                          TextSpan(
                            text: '%',
                            style: TextStyle(
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
  }
}

class ChallengeProgressWidget extends StatelessWidget {
  final String lessonTitle;
  final int progressPercent;
  final int challengeNumber;
  final List<bool> progressSteps; // true = check, false = cross

  const ChallengeProgressWidget({
    super.key,
    required this.lessonTitle,
    required this.progressPercent,
    required this.challengeNumber,
    required this.progressSteps,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final backgroundColor = themeProvider.isDarkMode
        ? const Color(0xFF207D7A)
        : const Color(0xFF2A8C8B);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con texto y fuego + número
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context)!.challenge_of_the_day,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              Row(
                children: [
                  Text(
                    challengeNumber.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.local_fire_department,
                    color: Colors.orangeAccent,
                    size: 22,
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Texto y porcentaje grande
          Row(
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.complete_lesson,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      lessonTitle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Center(
                  child: RichText(
                    text: TextSpan(
                      text: progressPercent.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 48,
                      ),
                      children: const [
                        TextSpan(
                          text: '%',
                          style: TextStyle(
                            fontSize: 32,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Barra con checks/cross y medalla
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              color: themeProvider.isDarkMode
                  ? Color.fromARGB(255, 226, 232, 243)
                  : Color.fromARGB(255, 233, 238, 247),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 5,
                  offset: Offset(0, 2),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (var paso in progressSteps)
                  CircleAvatar(
                    radius: 18,
                    backgroundColor:
                        paso ? Colors.teal[300] : Colors.grey[400],
                    child: Icon(
                      paso ? Icons.check : Icons.close,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.amber,
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(6),
                  child: const Icon(
                    Icons.emoji_events,
                    color: Colors.redAccent,
                    size: 28,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}