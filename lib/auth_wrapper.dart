import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:thisuxnew/screens/home_screen.dart';
import 'package:thisuxnew/screens/login_screen.dart';

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          return snapshot.hasData ? HomeScreen() : LoginScreen();
        }
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }
}
