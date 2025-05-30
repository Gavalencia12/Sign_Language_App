import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:speakhands_mobile/l10n/app_localizations.dart';


class PathProgress extends StatelessWidget {
  final int totalSections;
  final int currentSection; // 1-based index

  const PathProgress({
    Key? key,
    required this.totalSections,
    required this.currentSection,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: LayoutBuilder(builder: (context, constraints) {
        final width = constraints.maxWidth;
        // Definimos un ancho mayor para permitir scroll
        final scrollWidth = width * 1.8; // Puedes ajustar este factor según necesidad
        

        final points = List.generate(totalSections, (index) {
          final x = (scrollWidth / (totalSections )) * index;
          final y = 40 + (index.isOdd ? -10.0 : 10.0)+10;
          return Offset(x, y);
        });

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: constraints.maxWidth * 1.68, // Ancho mayor para permitir scroll
            height: 270,
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: PathPainter(points: points, currentSection: currentSection),
                  ),
                ),
                ...List.generate(totalSections, (index) {
                  final isActive = index + 1 <= currentSection;
                  return Positioned(
                    left: points[index].dx,
                    top: points[index].dy - 18,
                    child: Column(
                      children: [
                        _FlagNode(isActive: isActive),
                        const SizedBox(height: 6),
                        Text(
                          '${AppLocalizations.of(context)!.section} ${index + 1}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color:  Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),

          ),
        );
      }),
    );
  }

}

class PathPainter extends CustomPainter {
  final List<Offset> points;
  final int currentSection;

  PathPainter({required this.points, required this.currentSection});

  final Paint _linePaintActive = Paint()
    ..color = Colors.pink
    ..strokeWidth = 3
    ..style = PaintingStyle.stroke;

  final Paint _linePaintInactive = Paint()
    ..color = Colors.grey.shade300
    ..strokeWidth = 3
    ..style = PaintingStyle.stroke;

  final Paint _dottedPaintActive = Paint()
    ..color = Colors.pink
    ..strokeWidth = 3
    ..style = PaintingStyle.stroke;

  final Paint _dottedPaintInactive = Paint()
    ..color = Colors.grey.shade300
    ..strokeWidth = 3
    ..style = PaintingStyle.stroke;

  @override
  void paint(Canvas canvas, Size size) {
    // Dibujamos segmentos entre puntos con curvas suaves y línea punteada

    for (int i = 0; i < points.length - 1; i++) {
      final p1 = points[i];
      final p2 = points[i + 1];

      final isSegmentActive = (i + 1) < currentSection;

      final paint = isSegmentActive ? _linePaintActive : _linePaintInactive;

      // Para curva suave, calculamos puntos de control
      final midX = (p1.dx + p2.dx) / 2;
      final controlPoint1 = Offset(midX, p1.dy);
      final controlPoint2 = Offset(midX, p2.dy);

      // Dibujar línea punteada con Path
      final path = Path();
      path.moveTo(p1.dx, p1.dy);
      path.cubicTo(controlPoint1.dx, controlPoint1.dy, controlPoint2.dx, controlPoint2.dy, p2.dx, p2.dy);

      // Dibujar línea punteada
      drawDashedPath(canvas, path, paint, dashWidth: 8, dashSpace: 6);
    }
  }

  void drawDashedPath(Canvas canvas, Path path, Paint paint, {double dashWidth = 5, double dashSpace = 5}) {
    final PathMetrics pathMetrics = path.computeMetrics();
    for (PathMetric pathMetric in pathMetrics) {
      double distance = 0.0;
      while (distance < pathMetric.length) {
        final double length = dashWidth;
        final Path extractPath = pathMetric.extractPath(distance, distance + length);
        canvas.drawPath(extractPath, paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant PathPainter oldDelegate) {
    return oldDelegate.currentSection != currentSection || oldDelegate.points != points;
  }
}

class _FlagNode extends StatelessWidget {
  final bool isActive;

  const _FlagNode({Key? key, required this.isActive}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Óvalo externo
        Container(
          width: 42,
          height: 40,
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(100),
            border: Border.all(
              color: isActive ? Colors.pink : Colors.grey,
              width: 2,
            ),
          ),
        ),
        // Óvalo interno blanco
        Container(
          width: 30,
          height: 28,
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(50),
            border: Border.all(
              color: isActive ? Colors.pink : Colors.grey,
              width: 2,
            ),
          ),
        ),
        Container(
          width: 20,
          height: 18,
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(50),
            border: Border.all(
              color: isActive ? Colors.pink : Colors.grey,
              width: 2,
            ),
          ),
        ),
        if (isActive)
        Transform.translate(
          offset: const Offset(8, -14),  // mueve la bandera hacia arriba y a la derecha
          child: Image.asset(
            'assets/images/flag_red.png',
            width: 40,
            height: 40,
            fit: BoxFit.contain,
          ),
        ),
      ],
    );
  }
}

