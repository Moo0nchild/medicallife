import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;               // UID del usuario
  final String identificacion;   // Identificación del usuario
  final String nombre;           // Nombre del usuario
  final String email;            // Correo electrónico del usuario
  final String telefono;         // Número de teléfono del usuario
  final String rol;              // Rol del usuario (ej. administrador, médico)
  final bool activo;             // Estado activo del usuario
  final DateTime fechaCreacion;  // Fecha de creación del usuario
  final DateTime fechaNacimiento; // Fecha de nacimiento del usuario

  UserModel({
    required this.id,
    required this.identificacion,
    required this.nombre,
    required this.email,
    required this.telefono,
    required this.rol,
    required this.activo,
    required this.fechaCreacion,
    required this.fechaNacimiento,
  });

  factory UserModel.fromFirestore(Map<String, dynamic> data, String documentId) {
    return UserModel(
      id: documentId, // El ID es el UID del usuario
      identificacion: data['identificacion'],
      nombre: data['nombre'],
      email: data['email'],
      telefono: data['telefono'],
      rol: data['rol'],
      activo: data['activo'] == 'true', // Convierte la cadena a booleano
      fechaCreacion: (data['fecha_creacion'] as Timestamp).toDate(),
      fechaNacimiento: (data['fechanacimiento'] as Timestamp).toDate(),
    );
  }
}
