import 'package:app/select.dart';
import 'package:app/welcome.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'login.dart';
import 'mechanic.dart';


void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug, // Use PlayIntegrity for production
    appleProvider: AppleProvider.debug,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // home: welcome(),
      home: AuthGate(),

    );
  }
}

class AuthGate extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        debugPrint("AuthGate: authStateChanges - ${snapshot.connectionState}, user=${snapshot.data}");

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        final user = snapshot.data;

        if (user == null) {
          debugPrint("AuthGate: No user, going to login screen");
          return login();
        }

        debugPrint("AuthGate: Logged in as ${user.uid}");

        return FutureBuilder<QuerySnapshot>(
          future: FirebaseFirestore.instance
              .collection('user')
              .where('uid', isEqualTo: user.uid)
              .get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError || !snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return login(); // fallback
            }

            var data = snapshot.data!.docs.first.data() as Map<String, dynamic>;
            String role = data['role'];

            if (role == '1') {
              return select();
            } else if (role == '2') {
              return mechanic();
            } else {
              return login();
            }
          },
        );
      },
    );
  }
}




