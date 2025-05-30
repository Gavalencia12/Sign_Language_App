import 'package:flutter/material.dart';
import 'package:speakhands_mobile/l10n/app_localizations.dart';


// Widget para cada ícono con texto, borde rosa y fondo celeste, usando imagen en vez de icono
class LearningOption extends StatelessWidget {
  final String text;
  final String imagePath; // ruta de imagen en assets
  final VoidCallback? onTap;

  const LearningOption({
    required this.text,
    required this.imagePath,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Color(0xFFC7F0F0), // fondo celeste claro
              shape: BoxShape.circle,
              border: Border.all(color: Colors.pink.shade300, width: 5), // borde rosa
            ),
            padding: EdgeInsets.all(16),
            child: Image.asset(
              imagePath,
              width: 48,
              height: 48,
              fit: BoxFit.contain,
            ),
          ),
          SizedBox(height: 8),
          Text(
            text.toUpperCase(),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

// Ejemplo del body para Nivel 1
class LevelOneBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Color(0xFFC7F0F0),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                AppLocalizations.of(context)!.section1,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
            ),
          ),
          SizedBox(height: 20),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 24,
              crossAxisSpacing: 24,
              children: [
                LearningOption(text: AppLocalizations.of(context)!.alphabet, imagePath: "assets/images/iconos/alfabeto.png"),                
                LearningOption(text: AppLocalizations.of(context)!.numbers, imagePath: "assets/images/iconos/numeros.png"),
                LearningOption(text: AppLocalizations.of(context)!.greetings, imagePath: "assets/images/iconos/saludo.webp"),
                LearningOption(text: AppLocalizations.of(context)!.pronouns, imagePath: "assets/images/iconos/pronombres.png"),
                LearningOption(text: AppLocalizations.of(context)!.test, imagePath: "assets/images/iconos/examen.png"),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class LevelTwoBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Color(0xFFC7F0F0),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                AppLocalizations.of(context)!.section2,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
            ),
          ),
          SizedBox(height: 20),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 24,
              crossAxisSpacing: 24,
              children: [
                LearningOption(text: AppLocalizations.of(context)!.colors, imagePath: "assets/images/iconos/paleta.png"),
                LearningOption(text: AppLocalizations.of(context)!.family, imagePath: "assets/images/iconos/familia.png"),
                LearningOption(text: AppLocalizations.of(context)!.animals, imagePath: "assets/images/iconos/mascotas.png"),
                LearningOption(text: AppLocalizations.of(context)!.dates, imagePath: "assets/images/iconos/calendario.png"),
                LearningOption(text: AppLocalizations.of(context)!.test, imagePath: "assets/images/iconos/examen.png"),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class LevelThreeBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Color(0xFFC7F0F0),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                AppLocalizations.of(context)!.section3,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
            ),
          ),
          SizedBox(height: 20),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 24,
              crossAxisSpacing: 24,
              children: [
                LearningOption(text: AppLocalizations.of(context)!.sentence_structure, imagePath: "assets/images/iconos/prioridad.png"),
                LearningOption(text: AppLocalizations.of(context)!.questions, imagePath: "assets/images/iconos/signo-de-interrogacion.png"),
                LearningOption(text: AppLocalizations.of(context)!.time, imagePath: "assets/images/iconos/tiempo-rapido.png"),
                LearningOption(text: AppLocalizations.of(context)!.negations_affirmations, imagePath: "assets/images/iconos/prueba.png"),
                LearningOption(text: AppLocalizations.of(context)!.test, imagePath: "assets/images/iconos/examen.png"),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class LevelFourBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Color(0xFFC7F0F0),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                AppLocalizations.of(context)!.section4,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
            ),
          ),
          SizedBox(height: 20),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 24,
              crossAxisSpacing: 24,
              children: [
                LearningOption(text: AppLocalizations.of(context)!.transport, imagePath: "assets/images/iconos/transporte.png"),
                LearningOption(text: AppLocalizations.of(context)!.object, imagePath: "assets/images/iconos/camping.png"),
                LearningOption(text: AppLocalizations.of(context)!.emotions, imagePath: "assets/images/iconos/pensamiento-negativo.png"),
                LearningOption(text: AppLocalizations.of(context)!.emergencies, imagePath: "assets/images/iconos/kit-de-primeros-auxilios.png"),
                LearningOption(text: AppLocalizations.of(context)!.test, imagePath: "assets/images/iconos/examen.png"),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
