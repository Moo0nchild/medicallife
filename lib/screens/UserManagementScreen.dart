import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserManagementScreen extends StatefulWidget {
  @override
  _UserManagementScreenState createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  late Stream<QuerySnapshot> _usersStream;
  String _searchQuery = ''; // Para almacenar el texto de búsqueda

  @override
  void initState() {
    super.initState();
    // Inicializa el stream para escuchar los cambios en la colección de usuarios
    _usersStream = _firestore.collection('users').snapshots();
  }

  Future<void> _deleteUser(String userId) async {
    try {
      // Eliminar el usuario de Firestore
      await _firestore.collection('users').doc(userId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Usuario eliminado correctamente')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar el usuario: $e')),
      );
    }
  }

  Future<void> _updateUser(String userId, Map<String, dynamic> updatedData) async {
    try {
      // Actualizar los datos del usuario en Firestore
      await _firestore.collection('users').doc(userId).update(updatedData);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Datos actualizados correctamente')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar los datos: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Administrar Usuarios'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                _showSearchDialog();
              },
            ),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _usersStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No hay usuarios registrados.'));
          }

          final users = snapshot.data!.docs.where((user) {
            // Filtrar usuarios por nombre o cédula
            final userData = user.data() as Map<String, dynamic>;
            return userData['identificacion'].toString().contains(_searchQuery) ||
                   userData['nombre'].toLowerCase().contains(_searchQuery.toLowerCase());
          }).toList();

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              var userData = users[index].data() as Map<String, dynamic>;
              var userId = users[index].id; // UID del usuario
              
              return Card(
                margin: EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text(userData['nombre']),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Email: ${userData['email']}'),
                      Text('Teléfono: ${userData['telefono']}'),
                      Text('Rol: ${userData['rol']}'),
                      Text('Identificación: ${userData['identificacion']}'),
                    ],
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'Eliminar') {
                        _deleteUser(userId);
                      } else if (value == 'Editar') {
                        _showEditDialog(userId, userData);
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(value: 'Eliminar', child: Text('Eliminar')),
                      PopupMenuItem(value: 'Editar', child: Text('Editar')),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showEditDialog(String userId, Map<String, dynamic> userData) {
    String newName = userData['nombre'];
    String newEmail = userData['email'];
    String newPhone = userData['telefono'];
    String newRole = userData['rol'];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Editar Usuario'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: 'Nombre'),
                onChanged: (value) {
                  newName = value;
                },
                controller: TextEditingController(text: newName),
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Email'),
                onChanged: (value) {
                  newEmail = value;
                },
                controller: TextEditingController(text: newEmail),
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Teléfono'),
                onChanged: (value) {
                  newPhone = value;
                },
                controller: TextEditingController(text: newPhone),
              ),
              DropdownButton<String>(
                value: newRole,
                items: [
                  DropdownMenuItem(child: Text('Administrador'), value: 'administrador'),
                  DropdownMenuItem(child: Text('Médico'), value: 'medico'),
                ],
                onChanged: (value) {
                  if (value != null) {
                    newRole = value;
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                _updateUser(userId, {
                  'nombre': newName,
                  'email': newEmail,
                  'telefono': newPhone,
                  'rol': newRole,
                });
                Navigator.of(context).pop();
              },
              child: Text('Actualizar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Buscar Usuario'),
          content: TextField(
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            decoration: InputDecoration(labelText: 'Buscar por cédula o nombre'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }
}
