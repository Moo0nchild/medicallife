import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medicalife/screens/AddUserScreen.dart';

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
        title: Text('Administración'),
        leading: IconButton(
  icon: Icon(Icons.arrow_back), // Puedes cambiar el ícono si prefieres algo distinto
  onPressed: () {
    Navigator.pop(context);  // Vuelve a la pantalla anterior
  },
  tooltip: 'Volver',
),
actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => AddUserScreen()));
            },tooltip: 'Añadir Usuario',
          ),
        ],

      ),
      body: StreamBuilder(
        stream: _firestore.collection('billing').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) return CircularProgressIndicator();

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
    );
  }
}
