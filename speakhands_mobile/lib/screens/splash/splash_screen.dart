import 'dart:async';
import 'package:flutter/material.dart';
import 'package:speakhands_mobile/routes/app_router.dart';
import 'package:speakhands_mobile/theme/app_colors.dart';
import 'package:speakhands_mobile/theme/text_styles.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final List<String> _images = const [
    'assets/images/hola.gif',
    'assets/images/L.png',
    'assets/images/S.png',
    'assets/images/M.png',
  ];

  // Duraciones (rápidas)
  static const Duration fadeDuration = Duration(milliseconds: 220);   // crossfade
  static const Duration holdDuration = Duration(milliseconds:450);   // tiempo visible
  static const Duration bgFinalDuration = Duration(milliseconds: 600); // fondo al final
  static const Duration progressDuration = Duration(milliseconds: 1500); // barra de carga

  // Tamaños
  static const double _baseSize = 150;
  static const double _smallerFactor = 0.75;
  double _sizeFor(int i) => i == 0 ? _baseSize : _baseSize * _smallerFactor;

  int _index = 0;
  Timer? _stepTimer;

  // Estados de la fase final
  bool _finalPhase = false; // cuando termina la secuencia de imágenes
  bool _finalFade = false;  // apaga la última imagen
  bool _navigateScheduled = false;

  // Fondo
  late Color _bgStart;
  late Color _bgEnd;

  @override
  void initState() {
    super.initState();

  WidgetsBinding.instance.addPostFrameCallback((_) {
    setState(() {
      _bgStart = AppColors.surface(context);
      _bgEnd = AppColors.background(context);
    });
  });
    // Avanza imágenes en secuencia
    final step = holdDuration + fadeDuration;
    _stepTimer = Timer.periodic(step, (t) {
      if (!mounted) return;

      // Si estamos en la primera imagen (el GIF), la dejamos más tiempo
      final extraDelay = (_index == 0) ? Duration(seconds: 2) : Duration.zero;

      Future.delayed(extraDelay, () {
        if (!mounted) return;

        if (_index < _images.length - 1) {
          setState(() => _index++);
        } else {
          t.cancel();
          setState(() {
            _finalPhase = true;
            _finalFade = true;
          });

          if (!_navigateScheduled) {
            _navigateScheduled = true;
            Future.delayed(const Duration(seconds: 2), () {
              AppRouter.replaceWith(context, '/main');
            });
          }
        }
      });
    });
  }

  @override
  void dispose() {
    _stepTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    
    final Color textColor =  AppColors.primary(context);
    final Color accentColor = AppColors.text(context);
    
    return Scaffold(
      body: AnimatedContainer(
        duration: bgFinalDuration,
        curve: Curves.easeInOut,
        color: _finalPhase ? _bgEnd : _bgStart,
        child: Stack(
          children: [
            // Contenido centrado: imágenes + (al final) textos
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Marco fijo para evitar saltos de layout
                  SizedBox.square(
                    dimension: _baseSize,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        for (int i = 0; i < _images.length; i++)
                          AnimatedOpacity(
                            opacity: (_index == i && !_finalFade) ? 1.0 : 0.0,
                            duration: fadeDuration,
                            curve: Curves.easeInOut,
                            child: Image.asset(
                              _images[i],
                              height: _sizeFor(i),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Mensaje final: aparece sólo en fase final
                  AnimatedOpacity(
                    opacity: _finalPhase ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                    child: AnimatedSlide(
                      offset: _finalPhase ? Offset.zero : const Offset(0, 0.15),
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                      child: Column(
                        children: [
                          // "SpeakHands"
                          RichText(
                            text: TextSpan(
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                color: textColor,
                                height: 1.2,
                              ),
                              children: [
                                const TextSpan(text: 'Speak'),
                                TextSpan(
                                  text: 'Hands',
                                  style: TextStyle(color:accentColor),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Deja que tus manos hablen',
                            style: AppTextStyles.textTitle.copyWith(color: accentColor),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Barra de carga delgada, pegada casi al fondo
            Align(
              alignment: const Alignment(0, 0.9),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28.0),
                child: AnimatedOpacity(
                  opacity: _finalPhase ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 250),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: _finalPhase ? 1.0 : 0.0),
                    duration: progressDuration,
                    curve: Curves.easeInOut,
                    builder: (context, value, child) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: Stack(
                          children: [
                            // pista
                            Container(
                              height: 4,
                              decoration: BoxDecoration(
                                color: accentColor,
                                borderRadius: BorderRadius.circular(999),
                              ),
                            ),
                            // progreso
                            FractionallySizedBox(
                              widthFactor: value.clamp(0.0, 1.0),
                              child: Container(
                                height: 4,
                                decoration: BoxDecoration(
                                  color: textColor,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
