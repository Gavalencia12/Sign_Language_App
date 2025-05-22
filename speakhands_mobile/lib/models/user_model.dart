class Usuario {
  final String nombre;
  final String email;
  final String edad;
  final String discapacidad;
  final String fechaNacimiento;
  final String foto;
  final String sexo;
  final String telefono;
  final String about;

  Usuario({
    required this.nombre,
    required this.email,
    required this.edad,
    required this.discapacidad,
    required this.fechaNacimiento,
    required this.foto,
    required this.sexo,
    required this.telefono,
    required this.about,
  });

  factory Usuario.fromMap(Map<dynamic, dynamic> map) {
    return Usuario(
      nombre: map['nombre'] ?? '',
      email: map['email'] ?? '',
      edad: map['edad'] ?? '',
      discapacidad: map['discapacidad'] ?? '',
      fechaNacimiento: map['fecha_nacimiento'] ?? '',
      foto: map['foto'] ?? '',
      sexo: map['sexo'] ?? '',
      telefono: map['telefono'] ?? '',
      about: map['about'] ?? '',
    );
  }
}
