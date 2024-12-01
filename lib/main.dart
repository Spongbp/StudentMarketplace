// main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/ufv_app_state.dart';
import '../pages/home_page.dart';
import '../pages/signin_page.dart';
import '../pages/signup_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensures everything is initialized properly

  // Initialize Firebase
  await Firebase.initializeApp();

  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug,
  );

  const debugToken = "8F06BC2E-9E3A-470E-80F9-0F669C068BF9";
  await FirebaseAppCheck.instance.setTokenAutoRefreshEnabled(false);
  print("Debug Token set: $debugToken");

  // Run the app
  runApp(UFVApp());
}


class UFVApp extends StatelessWidget {
  const UFVApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => UFVAppState(),
      child: MaterialApp(
        title: 'UFV Student Marketplace',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        ),
        initialRoute: '/signin', // Set SignInPage as the initial route
        routes: {
          '/signin': (context) => SignInPage(),
          '/signup': (context) => SignUpPage(),
          '/home': (context) => UFVHomePage(),
        },
      ),
    );
  }
}
