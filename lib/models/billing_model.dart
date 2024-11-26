import 'package:cloud_firestore/cloud_firestore.dart';

class BillingModel {
  final String id;
  final String pacienteId;
  final String citaId;
  final double monto;
  final DateTime fechaEmision;
  final String estado;
  final String metodoPago;
  final DateTime? fechaPago;

  BillingModel({
    required this.id,
    required this.pacienteId,
    required this.citaId,
    required this.monto,
    required this.fechaEmision,
    required this.estado,
    required this.metodoPago,
    this.fechaPago,
  });

  factory BillingModel.fromFirestore(Map<String, dynamic> data, String documentId) {
    return BillingModel(
      id: documentId,
      pacienteId: data['paciente_id'],
      citaId: data['cita_id'],
      monto: data['monto'],
      fechaEmision: (data['fecha_emision'] as Timestamp).toDate(),
      estado: data['estado'],
      metodoPago: data['metodo_pago'],
      fechaPago: data['fecha_pago'] != null ? (data['fecha_pago'] as Timestamp).toDate() : null,
    );
  }
}
