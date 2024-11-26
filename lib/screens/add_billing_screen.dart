import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:medicalife/screens/home_screen.dart';

class AddBillingScreen extends StatefulWidget {
  @override
  _AddBillingScreenState createState() => _AddBillingScreenState();
}
class _AddBillingScreenState extends State<AddBillingScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _identificacionController = TextEditingController();
  final TextEditingController _montoController = TextEditingController();

  String? _pacienteNombre;
  bool _pacienteExists = false;

  Future<void> _checkPaciente() async {
    String identificacion = _identificacionController.text;

    // Verificar si el paciente existe
    final QuerySnapshot querySnapshot = await _firestore
        .collection('users')
        .where('identificacion', isEqualTo: identificacion)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      setState(() {
        _pacienteNombre = querySnapshot.docs[0]['nombre'];
        _pacienteExists = true;
      });
    } else {
      setState(() {
        _pacienteExists = false;
        _pacienteNombre = null;
      });
    }
  }

  Future<void> _addFactura() async {
    if (_pacienteExists) {
      await _firestore.collection('billing').add({
        'paciente_id': _identificacionController.text,
        'monto': double.tryParse(_montoController.text) ?? 0.0,
        'fecha_emision': Timestamp.now(),
        'estado': 'pendiente',
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Factura añadida')),
      );
      _identificacionController.clear();
      _montoController.clear();
      setState(() {
        _pacienteExists = false;
        _pacienteNombre = null;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('El paciente no existe.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Añadir Factura'),
        leading: IconButton(
          icon: Icon(Icons.home),
          onPressed: () {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()));
          },
          tooltip: 'Volver al Home',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _identificacionController,
              decoration: InputDecoration(labelText: 'Identificación del Paciente'),
              onChanged: (value) {
                _checkPaciente();
              },
            ),
            if (_pacienteExists) ...[
              Text('Paciente encontrado: $_pacienteNombre', style: TextStyle(color: Colors.green)),
            ] else if (_identificacionController.text.isNotEmpty) ...[
              Text('Paciente no encontrado', style: TextStyle(color: Colors.red)),
            ],
            TextField(
              controller: _montoController,
              decoration: InputDecoration(labelText: 'Monto'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _addFactura();
              },
              child: Text('Añadir Factura'),
            ),
          ],
        ),
      ),
    );
  }
}
