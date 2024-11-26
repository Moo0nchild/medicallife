import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Registro de un nuevo usuario
  Future<User?> registerUser(String nombre, String email, String password, String rol) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      User? user = result.user;
      await _firestore.collection('users').doc(user!.uid).set({
        'nombre': nombre,
        'email': email,
        'rol': rol,
        'fecha_creacion': Timestamp.now(),
        'activo': true,
      });
      return user;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // Inicio de sesión
  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      return result.user;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
}
