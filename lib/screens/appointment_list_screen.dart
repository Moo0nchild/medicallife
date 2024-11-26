import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:medicalife/models/user_model.dart';
import 'package:medicalife/screens/appointment_screen.dart';
import 'package:medicalife/screens/home_screen.dart';

class AppointmentListScreen extends StatefulWidget {
  @override
  _AppointmentListScreenState createState() => _AppointmentListScreenState();
}

class _AppointmentListScreenState extends State<AppointmentListScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String searchQuery = '';

  Future<void> _marcarCitaComoVista(String citaId) async {
    await _firestore.collection('appointments').doc(citaId).update({
      'estado': 'vista',
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('Citas Médicas'),
        leading: IconButton(
          icon: Icon(Icons.home),
          onPressed: () {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()));
          },
          tooltip: 'Volver al Home',
        ),
        actions: [
          StreamBuilder<DocumentSnapshot>(
            stream: _firestore.collection('users').doc(user?.uid).snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Container();
              }

              UserModel currentUser = UserModel.fromFirestore(snapshot.data!.data() as Map<String, dynamic>, snapshot.data!.id);

              return currentUser.rol != 'Paciente' ? IconButton(
                icon: Icon(Icons.event_note),
                onPressed: () {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AppointmentScreen()));
                },
                tooltip: 'Añadir Cita',
              ) : SizedBox.shrink();
            },
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            },
            tooltip: 'Cerrar sesión',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: 'Buscar por fecha, descripción o paciente ID',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('appointments').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                final citas = snapshot.data!.docs.where((cita) {
                  final pacienteId = cita['paciente_id'].toString().toLowerCase();
                  final descripcion = cita['descripcion'].toString().toLowerCase();
                  final fecha = DateFormat('dd/MM/yyyy').format(cita['fecha'].toDate()).toLowerCase();

                  return pacienteId.contains(searchQuery) ||
                         descripcion.contains(searchQuery) ||
                         fecha.contains(searchQuery);
                }).toList();

                return ListView.builder(
                  itemCount: citas.length,
                  itemBuilder: (context, index) {
                    var cita = citas[index];
                    return Card(
                      elevation: 5,
                      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Paciente: ${cita['paciente_id']}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            SizedBox(height: 8),
                            Text('Descripción: ${cita['descripcion']}', style: TextStyle(fontSize: 16)),
                            SizedBox(height: 8),
                            Text('Fecha: ${DateFormat('dd/MM/yyyy').format(cita['fecha'].toDate())}', style: TextStyle(fontSize: 16)),
                            SizedBox(height: 8),
                            Text('Estado: ${cita['estado']}', style: TextStyle(fontSize: 16, color: Colors.grey)),
                            SizedBox(height: 12),
                            if (cita['estado'] != 'vista')
                              ElevatedButton(
                                onPressed: () {
                                  _marcarCitaComoVista(cita.id);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Cita marcada como vista')),
                                  );
                                },
                                child: Text('Marcar como Vista'),
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
