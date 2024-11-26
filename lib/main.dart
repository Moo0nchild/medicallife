import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:medicalife/firebase_options.dart';
import 'package:medicalife/screens/login_screen.dart';
import 'dart:async';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  Timer? _timer;
  bool _isInBackground = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // La aplicación ha pasado a segundo plano
      _isInBackground = true;
      _startTimer();
    } else if (state == AppLifecycleState.resumed) {
      // La aplicación ha regresado al primer plano
      _isInBackground = false;
      _timer?.cancel();
    }
  }

  void _startTimer() {
    _timer = Timer(Duration(minutes: 3), () {
      if (_isInBackground) {
        // Aquí puedes cerrar la aplicación o realizar cualquier acción que desees
        // Por ejemplo, mostrar un mensaje o hacer logout
        Get.offAll(LoginScreen()); // Redirigir al login si la aplicación se cierra
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Medicalife',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginScreen(),
    );
  }
}
