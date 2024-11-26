import 'package:cloud_firestore/cloud_firestore.dart';

class AppointmentModel {
  final String id;
  final String pacienteId;
  final String medicoId;
  final DateTime fecha;
  final String descripcion;
  final String estado;
  final double costo;

  AppointmentModel({
    required this.id,
    required this.pacienteId,
    required this.medicoId,
    required this.fecha,
    required this.descripcion,
    required this.estado,
    required this.costo,
  });

  factory AppointmentModel.fromFirestore(Map<String, dynamic> data, String documentId) {
    return AppointmentModel(
      id: documentId,
      pacienteId: data['paciente_id'],
      medicoId: data['medico_id'],
      fecha: (data['fecha'] as Timestamp).toDate(),
      descripcion: data['descripcion'],
      estado: data['estado'],
      costo: data['costo'],
    );
  }
}
