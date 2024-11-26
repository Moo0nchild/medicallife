import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddUserScreen extends StatefulWidget {
  @override
  _AddUserScreenState createState() => _AddUserScreenState();
}

class _AddUserScreenState extends State<AddUserScreen> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _email = '';
  String _password = '';
  String _phone = ''; // Nuevo campo de número de teléfono
  String _role = 'medico'; // Rol por defecto
  String _identificacion = ''; // Nuevo campo para la identificación
  DateTime _fechaNacimiento = DateTime.now(); // Nuevo campo para la fecha de nacimiento
  bool _activo = true; // Nuevo campo para el estado activo

  // Firebase instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _addUser() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        // Crear el usuario en Firebase Authentication
        UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: _email,
          password: _password,
        );

        // Guardar la información del usuario en Firestore utilizando el UID
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'nombre': _name,
          'email': _email,
          'telefono': _phone, // Guardar el número de teléfono
          'rol': _role,
          'activo': _activo.toString(), // Convertir a cadena
          'fecha_creacion': Timestamp.now(), // Asegúrate de que este campo coincida con el modelo
          'fechanacimiento': Timestamp.fromDate(_fechaNacimiento), // Guardar la fecha de nacimiento
          'identificacion': _identificacion, // Guardar la identificación
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Usuario añadido correctamente')),
        );

        Navigator.pop(context); // Volver a la pantalla anterior
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.message}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Añadir Usuario'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Volver a la pantalla anterior
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Nombre'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa un nombre';
                  }
                  return null;
                },
                onSaved: (value) {
                  _name = value!;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Correo electrónico'),
                validator: (value) {
                  if (value == null || !value.contains('@')) {
                    return 'Por favor ingresa un correo válido';
                  }
                  return null;
                },
                onSaved: (value) {
                  _email = value!;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Contraseña'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.length < 6) {
                    return 'La contraseña debe tener al menos 6 caracteres';
                  }
                  return null;
                },
                onSaved: (value) {
                  _password = value!;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Número de teléfono'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa un número de teléfono';
                  }
                  return null;
                },
                onSaved: (value) {
                  _phone = value!;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Identificación'), // Campo para la identificación
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa la identificación';
                  }
                  return null;
                },
                onSaved: (value) {
                  _identificacion = value!;
                },
              ),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Rol'),
                value: _role,
                items: [
                  DropdownMenuItem(
                    child: Text('Administrador'),
                    value: 'administrador',
                  ),
                  DropdownMenuItem(
                    child: Text('Médico'),
                    value: 'medico',
                  ),
                  DropdownMenuItem(
                    child: Text('Paciente'),
                    value: 'Paciente',
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _role = value!;
                  });
                },
              ),
              // Aquí puedes agregar un DatePicker para la fecha de nacimiento si lo deseas
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _addUser,
                child: Text('Añadir Usuario'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
