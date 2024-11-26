import 'package:cloud_firestore/cloud_firestore.dart';

class BillingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Crear factura
  Future<void> crearFactura(String pacienteId, String citaId, double monto) async {
    await _firestore.collection('billing').add({
      'paciente_id': pacienteId,
      'cita_id': citaId,
      'monto': monto,
      'fecha_emision': Timestamp.now(),
      'estado': 'pendiente',
      'metodo_pago': 'manual',
    });
  }

  // Actualizar estado de la factura a pagada
  Future<void> registrarPago(String facturaId) async {
    await _firestore.collection('billing').doc(facturaId).update({
      'estado': 'pagada',
      'fecha_pago': Timestamp.now(),
    });
  }
}
