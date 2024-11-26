import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medicalife/screens/AddUserScreen.dart';
import 'package:medicalife/screens/UserManagementScreen.dart'; // Pantalla para controlar usuarios

class AdminScreen extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _anularFactura(String facturaId) async {
    await _firestore.collection('billing').doc(facturaId).update({
      'estado': 'anulada',
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Panel de Administración'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Volver a la pantalla anterior
          },
          tooltip: 'Volver',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => AddUserScreen()));
            },
            tooltip: 'Añadir Usuario',
          ),
        ],
      ),
      body: Column(
        children: [
          // Botón para controlar usuarios
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UserManagementScreen()),
                );
              },
              child: Text('Controlar Usuarios'),
            ),
          ),

          // Lista de facturas
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('billing').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

                final facturas = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: facturas.length,
                  itemBuilder: (context, index) {
                    var factura = facturas[index];
                    return ListTile(
                      title: Text('Factura: ${factura.id}'),
                      subtitle: Text('Estado: ${factura['estado']}'),
                      trailing: factura['estado'] != 'anulada'
                          ? ElevatedButton(
                              onPressed: () {
                                _anularFactura(factura.id);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Factura anulada')),
                                );
                              },
                              child: Text('Anular Factura'),
                            )
                          : Text('Anulada'),
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
