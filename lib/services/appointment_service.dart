import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/appointment_model.dart';

class AppointmentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Crear una cita
  Future<void> crearCita(String pacienteId, String medicoId, DateTime fecha, String descripcion, double costo) async {
    await _firestore.collection('appointments').add({
      'paciente_id': pacienteId,
      'medico_id': medicoId,
      'fecha': Timestamp.fromDate(fecha),
      'descripcion': descripcion,
      'estado': 'pendiente',
      'costo': costo,
    });
  }

  // Obtener citas por ID de paciente
  Stream<List<AppointmentModel>> obtenerCitasPorPaciente(String pacienteId) {
    return _firestore.collection('appointments').where('paciente_id', isEqualTo: pacienteId).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => AppointmentModel.fromFirestore(doc.data(), doc.id)).toList();
    });
  }
}
