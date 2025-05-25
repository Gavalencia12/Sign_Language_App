import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speakhands_mobile/providers/theme_provider.dart';
import 'package:speakhands_mobile/models/progress_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:speakhands_mobile/screens/learn_screen.dart'; 

class ProgresoWidget extends StatelessWidget {
  final List<Progreso> progresos;
  final Future<void> Function(String uid, String idSeccion) iniciarProgreso;

  const ProgresoWidget({super.key, required this.progresos, required this.iniciarProgreso});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final cardColor = themeProvider.isDarkMode ? const Color.fromARGB(255, 76, 227, 197) : const Color(0xFFE34C94);

    final progresoSeccion1 = progresos.firstWhere(
      (p) => p.idSeccion == 'seccion_1',
      orElse: () => Progreso(
        idProgreso: '',
        idUsuario: '',
        idSeccion: '',
        nivelAprendizaje: '',
        fecha: '',
        puntuacion: 0,
      ),
    );

    final bool tieneProgresoSeccion1 = progresoSeccion1.idProgreso.isNotEmpty;

    if (progresos.isEmpty) {
      return InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          final user = FirebaseAuth.instance.currentUser;
          if (user != null && !tieneProgresoSeccion1) {
            iniciarProgreso(user.uid, 'seccion_1');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Started learning section 1!')),
            );
          }
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const LearnScreen()),
          );
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
                            "Not progress yet,",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        "Let's start learning!",
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
          if (user != null && !tieneProgresoSeccion1) {
            iniciarProgreso(user.uid, 'seccion_1');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Started learning section 1!')),
            );
          }
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const LearnScreen()),
          );
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
                            "SECTION 6, ",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            "LESSON 2",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        "Describe Emotions",
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
                        text: '30',
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
