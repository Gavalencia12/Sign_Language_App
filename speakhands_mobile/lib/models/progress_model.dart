class Progreso {
  final String idProgreso;
  final String idUsuario;
  final String idSeccion;
  final String nivelAprendizaje;
  final String fecha;
  final int puntuacion;

  Progreso({
    required this.idProgreso,
    required this.idUsuario,
    required this.idSeccion,
    required this.nivelAprendizaje,
    required this.fecha,
    required this.puntuacion,
  });

  factory Progreso.fromMap(Map<dynamic, dynamic> map, String idProgreso) {
    return Progreso(
      idProgreso: idProgreso,
      idUsuario: map['idusuario'] ?? '',
      idSeccion: map['idseccion'] ?? '',
      nivelAprendizaje: map['nivel_aprendizaje'] ?? '',
      fecha: map['fecha'] ?? '',
      puntuacion: map['puntuacion'] ?? 0,
    );
  }
}
