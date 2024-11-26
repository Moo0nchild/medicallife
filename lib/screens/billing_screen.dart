import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medicalife/screens/add_billing_screen.dart';
import 'package:medicalife/screens/home_screen.dart';

class BillingScreen extends StatefulWidget {
  @override
  _BillingScreenState createState() => _BillingScreenState();
}

class _BillingScreenState extends State<BillingScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String selectedEstado = 'pendiente'; // Estado seleccionado por defecto

  Future<void> _actualizarFactura(String facturaId) async {
    await _firestore.collection('billing').doc(facturaId).update({
      'estado': 'pagada',
      'fecha_pago': Timestamp.now(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Facturas'),
        leading: IconButton(
          icon: Icon(Icons.home),
          onPressed: () {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => HomeScreen()));
          },
          tooltip: 'Volver al Home',
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.receipt),
            onPressed: () {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => AddBillingScreen()));
            },
            tooltip: 'Añadir Factura',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: DropdownButton<String>(
              value: selectedEstado,
              onChanged: (String? newValue) {
                setState(() {
                  selectedEstado = newValue!;
                });
              },
              items: <String>['pendiente', 'pagada', 'anulada']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              underline: Container(height: 2, color: Colors.blue),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('billing')
                  .where('estado', isEqualTo: selectedEstado)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData)
                  return Center(child: CircularProgressIndicator());

                final facturas = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: facturas.length,
                  itemBuilder: (context, index) {
                    var factura = facturas[index];
                    return ListTile(
                      title: Text('Factura: ${factura.id}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Estado: ${factura['estado']}'),
                          Text('Monto: \$${factura['monto'].toStringAsFixed(2)}'),
                        ],
                      ),
                      trailing: factura['estado'] == 'pendiente'
                          ? ElevatedButton(
                              onPressed: () {
                                _actualizarFactura(factura.id);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content:
                                          Text('Factura actualizada a pagada')),
                                );
                              },
                              child: Text('Marcar como Pagada'),
                            )
                          : Text(factura['estado'] == 'pagada'
                              ? 'Pagada'
                              : 'Anulada'),
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
