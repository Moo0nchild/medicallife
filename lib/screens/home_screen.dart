import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medicalife/screens/admin_screen.dart';  // Pantalla de administración
import 'package:medicalife/screens/appointment_list_screen.dart';
import 'package:medicalife/screens/billing_screen.dart';  // Pantalla de facturación

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool isAdmin = false;
  bool isLoading = true; // Indicador de carga

  @override
  void initState() {
    super.initState();
    _checkAdminStatus(); // Chequear el rol del usuario al inicializar
  }

  Future<void> _checkAdminStatus() async {
    User? user = _auth.currentUser;

    if (user != null) {
      // Verificamos si el usuario es administrador
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();

      if (userDoc.exists && userDoc['rol'] == 'administrador') {
        setState(() {
          isAdmin = true;
        });
      }
    }
    setState(() {
      isLoading = false; // Indicador de que ya terminó la verificación
    });
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('Bienvenido a MedicalLife'),
    ),
    body: isLoading
        ? Center(child: CircularProgressIndicator())
        : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Botones estáticos
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  if (!isAdmin) ...[ // Mostrar solo para pacientes
                    Column(
                      children: [
                        IconButton(
                          icon: Icon(Icons.calendar_month),
                          onPressed: () {
                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AppointmentListScreen()));
                          },
                          tooltip: 'Citas',
                        ),
                        Text('Citas Médicas'),
                      ],
                    ),
                  ] else ...[ // Mostrar para administradores
                    Column(
                      children: [
                        IconButton(
                          icon: Icon(Icons.calendar_month),
                          onPressed: () {
                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AppointmentListScreen()));
                          },
                          tooltip: 'Citas',
                        ),
                        Text('Citas Médicas'),
                      ],
                    ),
                    Column(
                      children: [
                        IconButton(
                          icon: Icon(Icons.receipt),
                          onPressed: () {
                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => BillingScreen()));
                          },
                          tooltip: 'Añadir Factura',
                        ),
                        Text('Facturas'),
                      ],
                    ),
                  ],
                ],
              ),

              // Botón de administración solo si es administrador
              if (isAdmin) ...[
                SizedBox(height: 20),
                Column(
                  children: [
                    IconButton(
                      icon: Icon(Icons.admin_panel_settings),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => AdminScreen()));
                      },
                      tooltip: 'Administración',
                    ),
                    Text('Administración'),
                  ],
                ),
              ],

              // Botón de cerrar sesión
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _auth.signOut();
                  Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
                },
                child: Text('Cerrar sesión'),
              ),
            ],
          ),
  );
}


}
