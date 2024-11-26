import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:medicalife/screens/home_screen.dart';

class AppointmentScreen extends StatefulWidget {
  @override
  _AddAppointmentScreenState createState() => _AddAppointmentScreenState();
}

class _AddAppointmentScreenState extends State<AppointmentScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _pacienteController = TextEditingController();
  final TextEditingController _medicoController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();

  String? _pacienteNombre;
  String? _medicoNombre;
  bool _pacienteExists = false;
  bool _medicoExists = false;
  DateTime? _selectedDateTime; // Controlador para fecha y hora

  Future<void> _checkPaciente() async {
    String identificacion = _pacienteController.text;
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

  Future<void> _checkMedico() async {
    String identificacion = _medicoController.text;
    final QuerySnapshot querySnapshot = await _firestore
        .collection('users')
        .where('identificacion', isEqualTo: identificacion)
        .where('rol', isEqualTo: 'medico')
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      setState(() {
        _medicoNombre = querySnapshot.docs[0]['nombre'];
        _medicoExists = true;
      });
    } else {
      setState(() {
        _medicoExists = false;
        _medicoNombre = null;
      });
    }
  }

  Future<void> _selectDateTime(BuildContext context) async {
    // Seleccionar fecha
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      // Seleccionar hora
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime ?? DateTime.now()),
      );

      if (pickedTime != null) {
        setState(() {
          _selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  Future<bool> _isAppointmentConflict(DateTime selectedDateTime, String medicoId) async {
    final startTime = selectedDateTime;
    final endTime = selectedDateTime.add(Duration(minutes: 20));

    final QuerySnapshot querySnapshot = await _firestore
        .collection('appointments')
        .where('medico_id', isEqualTo: medicoId)
        .where('fecha', isGreaterThan: startTime)
        .where('fecha', isLessThan: endTime)
        .get();

    return querySnapshot.docs.isNotEmpty; // Conflicto si hay citas dentro del rango
  }

  Future<void> _addAppointment() async {
    if (_pacienteExists && _medicoExists && _selectedDateTime != null) {
      bool conflict = await _isAppointmentConflict(_selectedDateTime!, _medicoController.text);
      
      if (conflict) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Conflicto: El médico ya tiene una cita en este horario.')),
        );
        return; // Salir si hay conflicto
      }

      await _firestore.collection('appointments').add({
  'paciente_id': _pacienteController.text,
  'medico_id': _medicoController.text,
  'fecha': Timestamp.fromDate(_selectedDateTime!), // Convertir DateTime a Timestamp
  'descripcion': _descripcionController.text,
  'estado': 'pendiente',
});


      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cita añadida')),
      );

      // Limpiar los campos después de añadir la cita
      _pacienteController.clear();
      _medicoController.clear();
      _descripcionController.clear();
      setState(() {
        _pacienteExists = false;
        _medicoExists = false;
        _pacienteNombre = null;
        _medicoNombre = null;
        _selectedDateTime = null; // Reiniciar la fecha seleccionada
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('El paciente o médico no existen, o la fecha no fue seleccionada.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Añadir Cita'),
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
              controller: _pacienteController,
              decoration: InputDecoration(labelText: 'ID del Paciente'),
              onChanged: (value) {
                _checkPaciente();
              },
            ),
            if (_pacienteExists) ...[
              Text('Paciente encontrado: $_pacienteNombre', style: TextStyle(color: Colors.green)),
            ] else if (_pacienteNombre == null && _pacienteController.text.isNotEmpty) ...[
              Text('Paciente no encontrado', style: TextStyle(color: Colors.red)),
            ],
            TextField(
              controller: _medicoController,
              decoration: InputDecoration(labelText: 'ID del Médico'),
              onChanged: (value) {
                _checkMedico();
              },
            ),
            if (_medicoExists) ...[
              Text('Médico encontrado: $_medicoNombre', style: TextStyle(color: Colors.green)),
            ] else if (_medicoNombre == null && _medicoController.text.isNotEmpty) ...[
              Text('Médico no encontrado', style: TextStyle(color: Colors.red)),
            ],
            TextField(
              controller: _descripcionController,
              decoration: InputDecoration(labelText: 'Descripción de la Cita'),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _selectedDateTime == null
                      ? 'Fecha y Hora: No seleccionada'
                      : 'Fecha y Hora: ${DateFormat('dd/MM/yyyy HH:mm').format(_selectedDateTime!)}',
                  style: TextStyle(fontSize: 16),
                ),
                TextButton(
                  onPressed: () => _selectDateTime(context),
                  child: Text('Seleccionar Fecha y Hora'),
                ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addAppointment,
              child: Text('Añadir Cita'),
            ),
          ],
        ),
      ),
    );
  }
}
