import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';  // Assuming you have a HomeScreen for authenticated users

const firebaseConfig = FirebaseOptions(
  apiKey: 'AIzaSyACH6kHBWl2fUjjv0F8Dyvyx_TuAOJ4rac',
  appId: '1:399437922547:web:e6b8bd74256f21b62ef786',
  messagingSenderId: '399437922547',
  projectId: 'firestore-720bc',
  authDomain: 'firestore-720bc.firebaseapp.com',
  storageBucket: 'firestore-720bc.firebasestorage.app',
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: firebaseConfig);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Firestore App',
      theme: ThemeData(primarySwatch: Colors.blue),
      // Instead of initialRoute, we will navigate to a screen based on the user state dynamically
      home: AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    // Check if the user is logged in
    User? user = FirebaseAuth.instance.currentUser;

    // Return the appropriate screen based on authentication status
    if (user == null) {
      return LoginScreen(); // Show login screen if not logged in
    } else {
      return HomeScreen(); // Show home screen if logged in
    }
  }
}

