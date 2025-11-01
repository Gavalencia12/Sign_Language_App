// widget se encargará de mostrar el texto de los subtítulos y de manejar su formato (por ejemplo, ajustar el tamaño según el contenido).

import 'package:flutter/material.dart';

class CaptionText extends StatelessWidget {
  final String text;

  CaptionText({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 18.0,
        color: Colors.black,
        fontWeight: FontWeight.bold,
      ),
      overflow: TextOverflow.ellipsis,
    );
  }
}
